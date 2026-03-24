# Luồng Dữ Liệu Trong Dự Án

Tài liệu này phân tích cách dữ liệu di chuyển khi hệ thống hoạt động, dữ liệu được truyền qua những lớp nào, và nó được lưu trữ ở đâu trong từng giai đoạn.

## 1. Bức tranh tổng thể

Hệ thống được thiết kế theo mô hình 3 lớp chính:

1. **Frontend Svelte SPA**: nhận input người dùng, hiển thị dữ liệu, kết nối WebSocket.
2. **Backend Rust Axum**: xử lý API, matching engine, websocket broadcast, zkp, auth, admin.
3. **PostgreSQL**: lưu trạng thái bền vững, lịch sử, snapshot, candles, và dữ liệu phục vụ audit.

Điểm quan trọng nhất của kiến trúc này là:
- **matching chạy trong RAM**,
- **DB chỉ làm persistence và truy vấn lịch sử**,
- **frontend chỉ là lớp hiển thị + điều phối tương tác**.

## 2. Luồng dữ liệu từ trình duyệt vào hệ thống

### 2.1 Khởi tạo ứng dụng

Khi người dùng mở ứng dụng:
1. `web/src/main.ts` mount `App.svelte`.
2. `App.svelte` chạy `onMount`.
3. Frontend đồng thời:
	- kết nối WebSocket qua `orderBook.connect()`,
	- bootstrap auth qua `bootstrapAuth()`,
	- bootstrap admin auth qua `bootstrapAdminAuth()`.

### 2.2 Điều hướng và trạng thái giao diện

Frontend dùng Svelte stores để giữ trạng thái toàn cục:
- `router` cho route hash,
- `authState` cho user đăng nhập,
- `selectedMarket` cho cặp giao dịch hiện tại,
- `orderBook` cho snapshot bids/asks/trades,
- `connectionState` cho trạng thái REST/WebSocket.

Nghĩa là dữ liệu UI không nằm rải rác trong từng component, mà được tập trung ở store để các component đọc chung.

## 3. Luồng dữ liệu xác thực người dùng

### 3.1 Đăng nhập / đăng ký

Khi người dùng login hoặc register:
1. Form ở frontend gọi API qua `postLogin` hoặc `postRegister`.
2. Backend xác thực thông tin.
3. Nếu hợp lệ, backend trả về `user_id`, `username`, `display_name`.
4. `authStore` lưu thông tin này vào `localStorage` dưới key `cex_auth_v1`.
5. Store cập nhật `authState` để toàn bộ UI biết user đã đăng nhập.

### 3.2 Khôi phục phiên

Khi reload trang:
1. `bootstrapAuth()` đọc `localStorage`.
2. Nếu có dữ liệu hợp lệ, frontend gọi `fetchAuthMe(userId)`.
3. Backend xác thực lại user và trả thông tin hiện tại.
4. `authState` được set lại.

### 3.3 Ý nghĩa lưu trữ

Ở lớp frontend, chỉ lưu thông tin session tối thiểu để khôi phục UI.
Ở lớp backend, danh tính thật nằm trong bảng `users` của PostgreSQL.

## 4. Luồng dữ liệu đặt lệnh giao dịch

Đây là luồng quan trọng nhất của toàn hệ thống.

### 4.1 User nhập dữ liệu trên UI

Trong `TradeFormPanel.svelte`, người dùng nhập:
- side buy/sell,
- price,
- amount,
- market/base asset.

Component này còn đọc thêm:
- `fetchAveragePrice()` để lấy giá tham chiếu,
- `fetchBalances()` để hiển thị số dư khả dụng,
- `selectedMarket` để biết đang giao dịch cặp nào.

### 4.2 Gửi request đặt lệnh

Khi bấm submit:
1. Frontend gọi `POST /api/orders`.
2. Request body chứa:
	- `side`,
	- `price`,
	- `amount`,
	- `base_asset`,
	- `quote_asset`.
3. Header gửi kèm `x-user-id`.

### 4.3 Tầng API nhận request

Trong [core/src/api/orders.rs](core/src/api/orders.rs):
1. `UserId` extractor lấy `x-user-id`.
2. `resolve_market()` kiểm tra market trong DB.
3. `state.alloc_order_id()` cấp ID mới.
4. `ledger.reserve_for_new_order()` khóa số dư tạm thời.
5. `state.register_order_user()` ghi mapping `order_id → (user_id, symbol)`.
6. `state.engine.write()` lấy write lock và gọi `match_order()`.

### 4.4 Matching chạy trong RAM

Matching engine xử lý hoàn toàn trong bộ nhớ:
- đọc orderbook hiện tại,
- so giá mua/bán,
- khớp theo price-time priority,
- tạo danh sách `Trade`,
- cập nhật order còn dư hoặc đưa lệnh vào book nếu chưa khớp hết.

Điểm quan trọng là:
- **không có I/O trong matching**,
- **không có query DB trong lúc khớp**,
- **engine giữ toàn bộ trạng thái book trong RAM**.

### 4.5 Sau khi khớp xong

Khi engine trả về `Vec<Trade>`:
1. Ledger in-memory được settlement ngay.
2. REST handler ghi metric latency / order count.
3. Gửi `PersistenceEvent::OrderPlaced` vào worker.
4. Với mỗi trade, gửi thêm `PersistenceEvent::TradeFilled`.
5. Broadcast `WsEvent::RecentTrade` và `WsEvent::OrderbookUpdate`.
6. Trả response JSON về frontend.

### 4.6 Dữ liệu trả lại frontend

Response đặt lệnh trả về:
- `order_id`,
- số trade khớp ngay,
- tổng `matched_amount`,
- `updated_balances` cho base/quote asset.

Điều này giúp frontend cập nhật UI ngay mà không cần gọi thêm `/api/balances` ngay sau đó.

## 5. Luồng dữ liệu hủy lệnh

### 5.1 User bấm hủy

Frontend gọi `DELETE /api/orders/:id`.

### 5.2 API xử lý

Trong `cancel_order()`:
1. Kiểm tra chủ sở hữu từ `order_users` trong memory.
2. Nếu không có mapping, fallback sang `orders_log` trong DB.
3. Kiểm tra user có quyền hủy không.
4. Acquire write lock của engine.
5. Gọi `engine.cancel_order(symbol, order_id)`.
6. Nếu xóa khỏi RAM thành công, hoàn lại reservation trong ledger.
7. Gửi `PersistenceEvent::OrderCancelled` cho worker.
8. Broadcast lại orderbook snapshot.

### 5.3 Dữ liệu được lưu ở đâu

- Trong RAM: book bị xóa ngay.
- Trong DB: `orders_log.status` được cập nhật thành `cancelled`.
- Trên WebSocket: client nhận snapshot mới để UI cập nhật.

## 6. Luồng dữ liệu WebSocket realtime

### 6.1 Nguồn dữ liệu

WebSocket feed lấy dữ liệu từ `AppState.broadcast`, là một `tokio::sync::broadcast::Sender<WsEvent>`.

### 6.2 Dữ liệu phát ra từ backend

Trong `core/src/api/ws.rs`, server phát 2 kiểu event chính:
- `OrderbookUpdate`: snapshot top depth mới nhất,
- `RecentTrade`: một fill vừa xảy ra.

### 6.3 Khi nào broadcast xảy ra

Trong `orders.rs`:
- sau khi đặt lệnh xong,
- sau mỗi trade fill,
- sau khi hủy lệnh.

Điều đó có nghĩa WebSocket không tự sinh dữ liệu; nó chỉ là kênh phát các thay đổi đã được engine và API tạo ra.

### 6.4 Phía frontend nhận dữ liệu

Trong [web/src/stores/orderBookStore.ts](web/src/stores/orderBookStore.ts):
1. Store mở WebSocket tới `/ws`.
2. Khi socket mở, nó cũng fetch snapshot đầu tiên từ `/api/orderbook?symbol=...`.
3. Khi nhận `orderbook_update`, store thay toàn bộ bids/asks hiện tại.
4. Khi nhận `recent_trade`, store prepend trade mới vào danh sách trade.
5. Nếu symbol nhận được không trùng `selectedMarket`, message bị bỏ qua.

### 6.5 Tại sao cần cả snapshot lẫn event

WebSocket event chỉ cung cấp thay đổi liên tục, nhưng snapshot initial giúp:
- khởi tạo UI ngay khi vừa kết nối,
- phục hồi state khi reconnect,
- tránh phụ thuộc hoàn toàn vào lịch sử message có thể đã bị bỏ lỡ.

## 7. Luồng dữ liệu balances và wallet

### 7.1 Lưu trạng thái ở đâu

Có 3 lớp liên quan đến số dư:

1. **In-memory ledger** trong `AppState.ledger`.
2. **Database `balances`** để lưu bền vững.
3. **UI state** trong frontend chỉ để hiển thị.

### 7.2 Khi đặt lệnh

`ledger.reserve_for_new_order()` sẽ khóa số dư cần thiết ngay trong RAM để tránh overspend.

### 7.3 Khi trade khớp

Worker khi nhận `TradeFilled` sẽ cập nhật DB `balances` và đồng thời system ledger cũng đã được cập nhật trong luồng API.

### 7.4 Khi frontend cần hiển thị số dư

Frontend gọi `GET /api/balances` hoặc dùng `updated_balances` trả về trực tiếp từ `POST /api/orders`.

Điều này giảm số round-trip không cần thiết.

## 8. Luồng dữ liệu từ matching engine đến database

### 8.1 Vì sao tách worker riêng

Engine không ghi DB trực tiếp vì DB là I/O chậm hơn RAM rất nhiều. Thay vào đó, handler chỉ đẩy event sang worker.

### 8.2 Event queue

`AppState.events` là một `tokio::mpsc::Sender<PersistenceEvent>`.

Các event chính:
- `OrderPlaced`,
- `TradeFilled`,
- `OrderCancelled`.

### 8.3 Worker flush xuống PostgreSQL

Trong `core/src/db/worker.rs`:
1. Worker nhận event từ channel.
2. Gom batch theo kích thước và thời gian.
3. Ghi vào `orders_log`, `trades_log`, `balances`, `candles`.
4. Cập nhật trạng thái order bằng `filled` / `partial` / `cancelled`.

### 8.4 Quan hệ thứ tự dữ liệu

Worker phải ghi `OrderPlaced` trước rồi mới ghi `TradeFilled` để đảm bảo khóa ngoại từ `trades_log` về `orders_log` luôn hợp lệ.

### 8.5 Những gì được lưu bền vững

Trong DB sẽ có:
- lịch sử order,
- lịch sử trade,
- số dư hiện tại,
- candle chart,
- snapshot metadata cho ZKP.

## 9. Luồng dữ liệu biểu đồ và market data

### 9.1 Market data nguồn từ đâu

Chart và ticker không lấy trực tiếp từ engine book raw. Chúng được tổng hợp từ:
- trades log,
- candle aggregation,
- and recent price state.

### 9.2 Dữ liệu candle

Worker tổng hợp OHLCV theo nhiều interval và upsert vào `candles`.

### 9.3 Phía frontend

Các component như chart hoặc ticker sẽ gọi REST API để lấy snapshot dữ liệu lịch sử, sau đó dùng WebSocket để cập nhật dữ liệu mới nhất.

### 9.4 Lý do thiết kế như vậy

UI chart cần dữ liệu bền vững và có thể load lại, nên candle phải được lưu ở DB thay vì chỉ tồn tại trong RAM.

## 10. Luồng dữ liệu ZKP / Proof of Solvency

### 10.1 Nguồn dữ liệu

API [core/src/api/zkp.rs](core/src/api/zkp.rs) đọc từ bảng `balances`.

### 10.2 Chuyển thành snapshot

Mỗi user được chuyển thành:
- `user_id`,
- `balance = available + locked`.

### 10.3 Xây Merkle Sum Tree

Backend gọi `build_poseidon_merkle_sum_tree()` để tạo root và path.

### 10.4 Sinh proof

Backend sinh:
- Merkle proof cho user,
- SNARK package từ `create_membership_snark()`.

### 10.5 Lưu trữ liên quan

- `zkp_snapshots` lưu metadata snapshot,
- response API trả `root_hash`, `leaf_balance`, `public_inputs`, `snark`.

### 10.6 Frontend và WASM

Frontend có thể fetch proof rồi hiển thị và kiểm tra trạng thái proof tại client.
Trong code hiện tại, panel ZKP ở frontend đang đọc dữ liệu proof JSON từ API và dựa vào trường `snark.verified` để hiển thị kết quả.
Crate ZKP vẫn có export WASM verifier ở `zkp/src/lib.rs`, nhưng phần UI hiện tại chưa gọi trực tiếp module WASM đó.

## 11. Luồng dữ liệu admin và simulator

### 11.1 Admin

Admin endpoints có thể:
- nạp rút treasury,
- thêm asset,
- khóa market,
- suspend user,
- trigger ZKP snapshot,
- xem lịch sử snapshot.

Những thay đổi này đi qua DB và cập nhật trạng thái vận hành, nhưng không làm thay đổi logic matching core trực tiếp ngoài các ràng buộc trạng thái.

### 11.2 Simulator

Phần simulator là nguồn tạo lệnh tự động cho môi trường test.

Luồng dữ liệu của nó là:
1. Bật/tắt qua API simulator.
2. Worker nền phát sinh order theo profile.
3. Order đi vào cùng pipeline như user thật.

Điều này quan trọng vì simulator không đi đường riêng; nó dùng đúng pipeline production để kiểm thử tải và data flow.

## 12. Dữ liệu được lưu ở đâu theo loại

### 12.1 Trong trình duyệt

- `localStorage`: auth tạm thời.
- Svelte store: state giao diện hiện tại.
- không lưu book thật trong browser, chỉ lưu snapshot / view state.

### 12.2 Trong RAM backend

- `Engine`: orderbook đang chạy.
- `ledger`: số dư khả dụng / bị khóa.
- `order_users`: map order → owner.
- `last_trade_price`: giá tham chiếu gần nhất.
- `broadcast`: event bus websocket.
- `simulator`: trạng thái runtime của bộ sinh lệnh.

### 12.3 Trong PostgreSQL

- `users`, `assets`, `markets`.
- `balances`.
- `orders_log`, `trades_log`.
- `candles`.
- `zkp_snapshots`.

## 13. Vì sao phải chia luồng như vậy

### 13.1 Tốc độ

Matching cần tốc độ thấp nhất có thể, nên phải ở RAM.

### 13.2 Tính bền vững

DB cần giữ lịch sử và trạng thái phục vụ audit, report, và khôi phục.

### 13.3 Tách trách nhiệm rõ ràng

- frontend: render và input,
- API: validation và orchestration,
- engine: matching,
- worker: persistence,
- DB: storage,
- WebSocket: realtime push.

### 13.4 Dễ kiểm chứng

Khi dữ liệu được tách lớp như vậy, việc kiểm tra lỗi và đối soát sẽ rõ ràng hơn:
- order sinh từ đâu,
- trade phát sinh từ order nào,
- số dư thay đổi thế nào,
- snapshot ZKP được tạo từ dữ liệu nào.

## 14. Tóm tắt luồng end-to-end

### Khi user đặt lệnh

1. User nhập dữ liệu ở frontend.
2. Frontend gọi API `/api/orders`.
3. API xác thực user và market.
4. Ledger giữ số dư.
5. Engine khớp lệnh trong RAM.
6. Trade phát sinh.
7. Worker ghi DB.
8. WebSocket broadcast cập nhật.
9. Frontend cập nhật UI.

### Khi user hủy lệnh

1. User gửi yêu cầu hủy.
2. API xác thực quyền sở hữu.
3. Engine xóa lệnh khỏi book.
4. Worker cập nhật DB.
5. WebSocket phát snapshot mới.

### Khi kiểm tra ZKP

1. API đọc balances.
2. Build Merkle Sum Tree.
3. Sinh proof và root.
4. Trả proof JSON.
5. Frontend/WASM verify proof.

## 15. Kết luận

Luồng dữ liệu của dự án được thiết kế rất rõ:
- **input** đi từ frontend vào API,
- **matching** diễn ra hoàn toàn trong RAM,
- **persistence** được đẩy sang worker và PostgreSQL,
- **realtime updates** đi qua WebSocket,
- **ZKP** lấy snapshot từ DB rồi phát hành proof để client tự xác minh.

Thiết kế này giúp hệ thống đạt 3 mục tiêu cùng lúc:
- tốc độ cao,
- dữ liệu bền vững,
- và khả năng kiểm chứng minh bạch.

