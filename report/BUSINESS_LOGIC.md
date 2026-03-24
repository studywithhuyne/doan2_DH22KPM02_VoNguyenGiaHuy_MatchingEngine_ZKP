# Phân Tích Nghiệp Vụ Của Hệ Thống

Tài liệu này mô tả nghiệp vụ cốt lõi của dự án, tức là hệ thống đang vận hành như một sàn giao dịch tập trung (CEX) mô phỏng. Nội dung tập trung vào: người dùng, tài sản, số dư, đặt lệnh, khớp lệnh, hủy lệnh, lưu vết giao dịch, admin, simulator, và ZKP solvency.

## 1. Mô hình nghiệp vụ tổng thể

Hệ thống được xây theo mô hình một sàn giao dịch tập trung nhưng chạy theo dạng monolith:

- Người dùng đăng ký, đăng nhập, giữ số dư theo từng tài sản.
- Người dùng đặt lệnh mua/bán vào các cặp giao dịch.
- Matching engine khớp lệnh ngay trong RAM.
- Kết quả khớp được ghi xuống PostgreSQL theo dạng lịch sử và snapshot.
- Giao diện Svelte hiển thị orderbook, trade feed, wallet, chart, ZKP proof, và admin panel.

Điểm nghiệp vụ quan trọng nhất của hệ thống là:
- **matching không phụ thuộc database**,
- **số dư có trạng thái available / locked**,
- **lệnh có vòng đời rõ ràng: open → partial → filled / cancelled**,
- **trade luôn phát sinh từ một maker và một taker cụ thể**,
- **ZKP dùng để chứng minh solvency từ snapshot số dư**.

## 2. Các thực thể nghiệp vụ chính

### 2.1 User

User là chủ thể trung tâm của hệ thống.

Mỗi user có:
- `id`,
- `username`,
- `display_name`,
- `password_hash` nếu dùng auth username/password,
- trạng thái `is_suspended` ở tầng admin.

Nghiệp vụ liên quan đến user:
- đăng ký,
- đăng nhập,
- cập nhật tên hiển thị,
- xem danh sách user,
- thực hiện deposit/withdraw/transfer,
- đặt và hủy lệnh,
- xem trade history,
- nhận proof ZKP của chính mình.

### 2.2 Asset

Asset là một loại tài sản mà sàn hỗ trợ, ví dụ BTC, ETH, SOL, BNB, USDT.

Mỗi asset có:
- `symbol`,
- `name`,
- `decimals`,
- `is_active`.

Nghiệp vụ:
- tạo asset mới,
- bật/tắt asset,
- dùng asset để cấu thành market,
- làm đơn vị trong số dư và giao dịch.

### 2.3 Market

Market là cặp giao dịch, ví dụ `BTC_USDT`.

Mỗi market có:
- `symbol`,
- `base_asset`,
- `quote_asset`,
- `is_active`.

Nghiệp vụ:
- xác định cặp nào được phép giao dịch,
- làm đơn vị routing cho engine,
- có thể bị halt khi admin khóa.

### 2.4 Balance

Balance được tách thành:
- `available`: số dư có thể dùng ngay,
- `locked`: số dư đang bị khóa cho lệnh mở.

Đây là một quyết định nghiệp vụ quan trọng vì một sàn giao dịch phải ngăn user dùng vượt số dư. Khi user đặt lệnh, một phần tài sản sẽ bị khóa; khi lệnh hủy hoặc khớp xong, phần còn lại sẽ được hoàn trả hoặc chuyển trạng thái.

### 2.5 Order

Order là yêu cầu giao dịch của user.

Order có các trường nghiệp vụ:
- `order_id`,
- `user_id`,
- `symbol`,
- `side` buy/sell,
- `price`,
- `amount`,
- `remaining`.

Vòng đời order:
- tạo mới,
- đưa vào sổ lệnh hoặc khớp ngay,
- có thể khớp một phần,
- sau cùng trở thành filled hoặc cancelled.

### 2.6 Trade

Trade là kết quả khớp giữa maker và taker.

Trade luôn có:
- `maker_order_id`,
- `taker_order_id`,
- `symbol`,
- `price`,
- `amount`.

Nghiệp vụ trade là bằng chứng thực tế rằng thanh khoản đã được chuyển từ bên cung sang bên cầu.

### 2.7 Wallet / Treasury

Hệ thống có hai lớp liên quan đến ví:
- ví người dùng,
- quỹ exchange / treasury nội bộ.

Wallet của user quản lý số dư tài sản giao dịch.
Treasury của sàn dùng cho mô phỏng vốn hoạt động, revenue, solvency và admin view.

### 2.8 ZKP Snapshot

ZKP snapshot là bản chụp số dư để chứng minh solvency.

Mỗi snapshot lưu:
- `snapshot_id`,
- `root_hash`,
- `users_included`,
- thời điểm tạo.

## 3. Luồng nghiệp vụ xác thực

### 3.1 Đăng ký

Trong `register_handler`:
1. Chuẩn hóa username.
2. Kiểm tra mật khẩu hợp lệ.
3. Hash mật khẩu bằng Argon2id.
4. Tạo user mới.
5. Khởi tạo balance rỗng cho toàn bộ asset.
6. Trả về identity cho frontend.

### Ý nghĩa nghiệp vụ

Đăng ký không chỉ tạo tài khoản mà còn chuẩn bị sẵn ví cho người dùng để họ có thể giao dịch ngay sau đó.

### 3.2 Đăng nhập

Trong `login_handler`:
1. Tìm user theo username.
2. Kiểm tra password bằng Argon2id.
3. Trả về thông tin danh tính.
4. Frontend lưu session tối thiểu ở localStorage.

### 3.3 Xác thực request tiếp theo

Hệ thống dev/test dùng header `x-user-id` làm định danh.

Điều này phản ánh một mô hình nghiệp vụ đơn giản:
- user đăng nhập,
- frontend giữ ID,
- API tin vào ID đó trong môi trường mô phỏng.

### 3.4 Cập nhật display name

User có thể đổi tên hiển thị nhưng không đổi username.

Điều này tách rõ:
- danh tính đăng nhập,
- và tên hiển thị cho UI.

## 4. Luồng nghiệp vụ số dư và ví

### 4.1 Deposit

Trong `deposit_handler`:
1. Kiểm tra asset hợp lệ.
2. Đảm bảo user có balance row tương ứng.
3. Tăng `available` cho user.
4. Đồng bộ lại in-memory ledger.

Ý nghĩa nghiệp vụ:
- user nạp tiền vào ví giao dịch,
- hệ thống ghi nhận tăng số dư khả dụng.

### 4.2 Withdraw

Trong `withdraw_handler`:
1. Kiểm tra asset hợp lệ.
2. Kiểm tra số dư khả dụng.
3. Trừ `available`.
4. Cập nhật ledger trong RAM.

Ý nghĩa nghiệp vụ:
- user rút tiền từ ví giao dịch,
- hệ thống không cho rút nếu thiếu số dư.

### 4.3 Transfer

Transfer có hai chế độ nghiệp vụ:

#### A. Mock internal wallet transfer

Khi có `asset`, `from_wallet`, `to_wallet`:
- đây là mô phỏng chuyển nội bộ,
- chủ yếu dùng trong dev/test,
- không làm đổi khối lượng giao dịch thực tế trên orderbook.

#### B. Chuyển giữa hai asset

Khi có `from_asset` và `to_asset`:
- hệ thống trừ một asset,
- cộng asset kia,
- theo tỷ lệ 1:1 trong mô phỏng,
- cập nhật DB và ledger.

Ý nghĩa nghiệp vụ:
- hỗ trợ thao tác ví thử nghiệm,
- tạo khả năng test workflow không cần tích hợp cổng thanh toán thật.

### 4.4 Tại sao tách available và locked

Đây là trọng tâm nghiệp vụ của một sàn giao dịch.

- Khi đặt lệnh buy, quote asset bị khóa.
- Khi đặt lệnh sell, base asset bị khóa.
- Khi khớp, phần locked được chuyển sang settlement.
- Khi hủy, phần locked được hoàn lại.

Nếu không tách `available` và `locked`, hệ thống sẽ không kiểm soát được tài sản đang “bị cam kết” cho lệnh mở.

## 5. Luồng nghiệp vụ đặt lệnh và khớp lệnh

### 5.1 Mục tiêu kinh doanh của matching

Mục tiêu là khớp lệnh nhanh, chính xác, và công bằng theo thứ tự:
- giá tốt nhất,
- rồi đến thời gian vào sớm nhất.

Đây là price-time priority, là nguyên tắc cơ bản của hầu hết sàn giao dịch tập trung.

### 5.2 Đặt lệnh

Trong `place_order`:
1. Frontend gửi side, price, amount, market.
2. API xác thực user và market.
3. Engine cấp `order_id`.
4. Ledger khóa số dư cần thiết.
5. Order được đưa vào engine để match.

### 5.3 Khớp lệnh

Matching engine sẽ:
- tìm maker có giá phù hợp,
- khớp theo FIFO trong cùng mức giá,
- tạo `Trade` cho từng fill,
- giảm `remaining` của order,
- nếu còn dư thì order trở thành resting order.

### 5.4 Kết quả nghiệp vụ của một order

Một order có thể đi qua 4 trạng thái:
- `open`: mới vào book,
- `partial`: khớp một phần,
- `filled`: khớp hết,
- `cancelled`: bị hủy trước khi khớp hết.

Đây là vòng đời nghiệp vụ chuẩn của lệnh trên sàn.

### 5.5 Maker và taker

- **Maker**: lệnh nghỉ trong sổ lệnh, cung cấp thanh khoản.
- **Taker**: lệnh đi vào để ăn thanh khoản sẵn có.

Business meaning:
- maker giúp tạo market depth,
- taker làm giao dịch xảy ra ngay.

### 5.6 Tại sao lệnh có thể khớp một phần

Vì khối lượng của taker và maker không nhất thiết bằng nhau.

Hệ thống cho phép:
- taker lớn hơn maker → cắn nhiều maker,
- maker lớn hơn taker → khớp một phần và còn dư.

Điều này phản ánh thực tế vận hành của một orderbook.

## 6. Luồng nghiệp vụ hủy lệnh

### 6.1 Mục tiêu

Cho phép user rút lại ý định giao dịch nếu lệnh chưa khớp hết.

### 6.2 Cách xử lý

Khi user hủy:
1. Hệ thống kiểm tra lệnh có thuộc user đó không.
2. Xóa khỏi engine nếu còn nằm trong RAM.
3. Hoàn trả số dư đã khóa.
4. Cập nhật DB `orders_log` thành `cancelled`.

### 6.3 Ý nghĩa nghiệp vụ

Hủy lệnh là quyền cơ bản của người dùng. Nó đảm bảo user có thể thu hồi lệnh chưa muốn tiếp tục giữ trên thị trường.

## 7. Luồng nghiệp vụ trade history và market data

### 7.1 Lịch sử trade cá nhân

User có thể xem lịch sử trade của riêng mình.

Backend truy vấn `trades_log` theo `maker_user_id` hoặc `taker_user_id`.

Nghiệp vụ này quan trọng vì:
- user cần đối soát giao dịch,
- admin cần kiểm tra hoạt động,
- và hệ thống cần feed dữ liệu cho UI.

### 7.2 Recent trades công khai

Public trade feed cho phép mọi người thấy các giao dịch gần nhất của market.

Mục đích:
- tăng minh bạch thị trường,
- làm dữ liệu cho bảng trade gần nhất,
- tạo cảm giác sàn đang hoạt động realtime.

### 7.3 Orderbook và average price

Frontend và API cần orderbook snapshot để:
- hiển thị depth,
- tính mid price,
- tính micro price,
- làm giá tham chiếu cho form đặt lệnh.

Nghiệp vụ này tạo thành phần “market view” của sàn.

### 7.4 Candles và chart

Trade phát sinh được gom thành OHLCV candles để:
- vẽ biểu đồ giá,
- phân tích xu hướng,
- cung cấp dữ liệu lịch sử cho UI.

## 8. Luồng nghiệp vụ thanh toán và settlement

### 8.1 Khi trade khớp

Sau khi engine tạo trade:
- số dư bị khóa phải được giải phóng hợp lý,
- bên mua nhận base asset,
- bên bán nhận quote asset,
- phí được tính theo maker/taker fee.

### 8.2 Phí giao dịch

Hệ thống dùng phí maker/taker khác nhau.

Ý nghĩa nghiệp vụ:
- maker thường được phí thấp hơn để khuyến khích tạo thanh khoản,
- taker trả phí cao hơn vì ăn thanh khoản ngay.

### 8.3 Tại sao cần settlement riêng

Matching chỉ quyết định ai khớp với ai.
Settlement mới là phần cập nhật tài sản thật của user.

Tách hai bước này giúp:
- logic rõ ràng,
- dễ audit,
- dễ kiểm thử,
- và giảm rủi ro sai số nghiệp vụ.

## 9. Luồng nghiệp vụ admin

### 9.1 Dashboard quản trị

Admin có thể xem:
- total users,
- active orders,
- volume 24h,
- treasury metrics,
- trạng thái ZKP snapshot.

### 9.2 Quản lý tài sản và market

Admin có thể:
- thêm asset mới,
- tạo market mặc định với USDT,
- halt market,
- bật/tắt asset.

Đây là nghiệp vụ vận hành cốt lõi của một sàn.

### 9.3 Quản lý người dùng

Admin có thể:
- xem danh sách user,
- suspend user.

Việc suspend user giúp chặn hoạt động khi có vi phạm hoặc cần kiểm soát rủi ro.

### 9.4 Treasury

Admin có thể nạp/rút treasury nội bộ để mô phỏng quỹ sàn.

Nghiệp vụ này phục vụ:
- kiểm tra solvency,
- theo dõi total exchange funds,
- và tạo dữ liệu cho báo cáo nội bộ.

## 10. Luồng nghiệp vụ simulator

### 10.1 Simulator là gì

Simulator là luồng nền tự phát sinh lệnh giả lập để kiểm thử tải và kiểm thử hoạt động của sàn.

### 10.2 Mục đích nghiệp vụ

Nó dùng để:
- tạo thanh khoản giả lập,
- sinh trades liên tục,
- test orderbook, candle, trade feed,
- kiểm tra hệ thống dưới tải cao.

### 10.3 Cách hoạt động

Simulator:
- chọn cặp giao dịch,
- chọn user ngẫu nhiên,
- sinh buy/sell với giá quanh anchor,
- gửi request qua chính API `/api/orders`.

Điều này quan trọng vì simulator không đi một pipeline riêng. Nó sử dụng đúng pipeline của user thật, nên phản ánh khá trung thực nghiệp vụ sản phẩm.

## 11. Luồng nghiệp vụ ZKP solvency

### 11.1 Mục tiêu kinh doanh

Chứng minh rằng tổng số dư người dùng được hệ thống ghi nhận là hợp lệ và có thể kiểm chứng.

### 11.2 Nguồn dữ liệu

API đọc `balances`, tạo snapshot tổng số dư trên từng user.

### 11.3 Kết quả nghiệp vụ

Hệ thống tạo:
- root hash,
- Merkle proof,
- SNARK proof package,
- snapshot metadata.

### 11.4 Ý nghĩa

Đây là lớp minh bạch tài chính của sàn:
- chứng minh tồn tại snapshot,
- chứng minh root hợp lệ,
- cho phép kiểm tra solvency mà không lộ toàn bộ dữ liệu nội bộ.

## 12. Luồng nghiệp vụ realtime frontend

### 12.1 Orderbook live

Frontend mở WebSocket để nhận:
- `orderbook_update`,
- `recent_trade`.

### 12.2 Tại sao cần realtime

Đối với sàn giao dịch, dữ liệu không thể chỉ đọc theo batch. Người dùng cần thấy:
- giá biến động,
- lệnh khớp ngay,
- orderbook thay đổi tức thì.

Realtime là phần nghiệp vụ quan trọng để tạo trải nghiệm giao dịch đúng chuẩn.

### 12.3 Cập nhật UI

Svelte stores giữ trạng thái hiện tại của:
- auth,
- market,
- orderbook,
- connection,
- simulator.

Điều này giúp UI cập nhật theo sự kiện thay vì rerender toàn bộ ứng dụng.

## 13. Quan hệ nghiệp vụ giữa các tầng

### 13.1 Frontend

Frontend nhận dữ liệu, gửi hành động, hiển thị trạng thái.

### 13.2 API

API là nơi kiểm tra nghiệp vụ:
- quyền user,
- market active,
- balance đủ hay không,
- lệnh có hợp lệ không.

### 13.3 Matching engine

Engine chỉ làm một việc: khớp lệnh đúng và nhanh.

### 13.4 Persistence worker

Worker đảm bảo kết quả nghiệp vụ được ghi bền vững.

### 13.5 Database

DB giữ lịch sử, snapshot, metrics và dữ liệu audit.

## 14. Tại sao kiến trúc nghiệp vụ được xây theo kiểu này

### 14.1 Tách nóng / lạnh

Phần nóng:
- matching,
- engine state,
- ledger in-memory,
- websocket broadcast.

Phần lạnh:
- DB persistence,
- history,
- audit,
- ZKP snapshot.

Lý do là tốc độ và độ tin cậy.

### 14.2 Dữ liệu nghiệp vụ phải nhất quán nhưng không được làm chậm hệ thống

Sàn giao dịch cần:
- đúng số dư,
- đúng trạng thái order,
- đúng lịch sử trade,
- nhưng vẫn phải xử lý nhanh.

### 14.3 Dễ kiểm toán và đối soát

Mỗi sự kiện nghiệp vụ đều có dấu vết:
- ai đặt lệnh,
- lệnh nào khớp,
- số dư thay đổi ra sao,
- snapshot ZKP nào được tạo từ dữ liệu nào.

## 15. Kết luận

Nghiệp vụ của hệ thống này xoay quanh một sàn giao dịch tập trung mô phỏng hoàn chỉnh:

- user quản lý tài khoản và số dư,
- user nạp/rút/chuyển tiền,
- user đặt lệnh mua/bán,
- engine khớp lệnh ngay trong RAM,
- worker ghi nhận kết quả xuống DB,
- frontend hiển thị realtime,
- admin quản lý vận hành,
- simulator tạo tải,
- ZKP chứng minh solvency.

Nếu tóm gọn trong một câu: **đây là một hệ thống nghiệp vụ giao dịch tập trung, trong đó logic giao dịch thời gian thực được ưu tiên tuyệt đối, còn database và ZKP đóng vai trò lưu vết, kiểm chứng và minh bạch hóa kết quả**.

