# Cơ Sở Dữ Liệu Trong Dự Án

Tài liệu này giải thích cấu trúc database, mối liên hệ giữa các bảng, và lý do hệ thống được xây dựng theo cách đó.

## 1. Vai trò của database trong kiến trúc tổng thể

Database trong dự án **không tham gia vào quá trình khớp lệnh trực tiếp**. Matching engine chạy hoàn toàn trong RAM, còn PostgreSQL chỉ làm nhiệm vụ **async persistence** và **lưu lịch sử**.

Nói cách khác:
- Engine xử lý lệnh theo thời gian thực trong bộ nhớ.
- Database ghi lại kết quả sau đó để phục vụ truy vấn, audit, thống kê, và proof of solvency.

Thiết kế này được chọn vì:
- tránh làm chậm matching engine,
- đảm bảo độ trễ thấp,
- vẫn giữ được tính bền vững dữ liệu,
- và cho phép truy vấn lịch sử mà không ảnh hưởng đến luồng khớp lệnh.

## 2. Lớp kết nối DB

### Connection pool

File [core/src/db/pool.rs](core/src/db/pool.rs) tạo `PgPool` bằng `sqlx`.

Các điểm chính:
- đọc `DATABASE_URL` từ môi trường,
- tải migrations tự động,
- giới hạn số connection đồng thời ở mức nhỏ,
- dùng một pool dùng chung cho toàn bộ process.

### Vì sao chỉ dùng pool nhỏ

Hệ thống là monolith, matching engine không nên phụ thuộc vào DB trong luồng nóng. Vì thế:
- DB chỉ ghi nền,
- không cần quá nhiều connection,
- tránh tranh chấp tài nguyên,
- giảm áp lực lên PostgreSQL.

### Ý nghĩa kiến trúc

Pool là cầu nối giữa Axum handlers và PostgreSQL, nhưng không bao giờ được phép trở thành bottleneck của matching engine.

## 3. Schema Rust và schema PostgreSQL

File [core/src/db/schema.rs](core/src/db/schema.rs) định nghĩa các struct Rust mirror tương ứng với bảng PostgreSQL.

### Mục tiêu của lớp schema

Lớp này giúp:
- map dữ liệu từ DB sang Rust một cách rõ ràng,
- dùng `sqlx::FromRow` để đọc dữ liệu trực tiếp,
- giữ kiểu dữ liệu tài chính chính xác bằng `rust_decimal::Decimal`,
- và tránh phải viết ORM phức tạp.

### Lý do không dùng ORM

Dự án chọn `sqlx` vì:
- kiểm soát SQL trực tiếp,
- truy vấn rõ ràng,
- phù hợp với hệ thống cần hiệu năng và auditability,
- dễ tối ưu theo từng bảng và từng luồng ghi.

## 4. Các bảng chính và quan hệ giữa chúng

Database hiện có các bảng quan trọng sau:

- `users`
- `assets`
- `markets`
- `balances`
- `orders_log`
- `trades_log`
- `candles`
- `zkp_snapshots`

### 4.1 `users`

Bảng [core/migrations/0001_initial_schema.sql](core/migrations/0001_initial_schema.sql) định nghĩa `users` là bảng gốc cho danh tính người dùng.

Các trường chính:
- `id`: khóa chính, lấy từ header `x-user-id` ở API layer trong môi trường dev/test,
- `username`: tên đăng nhập,
- `display_name`: tên hiển thị,
- `password_hash`: hash Argon2id,
- `created_at`.

### Vì sao `users` là bảng gốc

Vì mọi thực thể khác đều quy chiếu về user:
- số dư thuộc user,
- lệnh thuộc user,
- trade có maker/taker user,
- và snapshot ZKP cũng cần gắn theo người dùng.

### 4.2 `assets`

`assets` là danh mục tài sản giao dịch.

Các trường chính:
- `symbol`: mã tài sản,
- `name`: tên hiển thị,
- `decimals`: số chữ số thập phân,
- `created_at`.

### Vai trò

`assets` định nghĩa tài sản hợp lệ trên sàn và là cơ sở để:
- tạo balances,
- cấu hình markets,
- xác định đơn vị tính,
- và hiển thị dữ liệu thị trường.

### 4.3 `markets`

`markets` là bảng định nghĩa cặp giao dịch, ví dụ `BTC_USDT`.

Các trường chính:
- `symbol`,
- `base_asset`,
- `quote_asset`,
- `created_at`.

### Quan hệ

`markets.base_asset` và `markets.quote_asset` đều tham chiếu sang `assets(symbol)`.

### Vì sao có bảng này

Để:
- giới hạn các cặp giao dịch hợp lệ,
- tránh user nhập cặp sai,
- tách logic symbol của thị trường khỏi symbol tài sản,
- và giúp backend xử lý routing theo thị trường.

### 4.4 `balances`

`balances` là bảng số dư theo từng user và từng tài sản.

Các trường chính:
- `user_id`,
- `asset_symbol`,
- `available`,
- `locked`,
- `updated_at`.

### Khóa chính

Khóa chính là `(user_id, asset_symbol)`.

### Lý do thiết kế như vậy

Mỗi user chỉ cần một ví cho mỗi tài sản, nên khóa ghép giúp:
- tránh trùng bản ghi,
- truy vấn số dư nhanh,
- cập nhật lock/available rõ ràng,
- phù hợp với hành vi exchange thực tế.

### Ý nghĩa của `available` và `locked`

- `available`: số dư có thể dùng ngay.
- `locked`: số dư đang bị khóa bởi lệnh mở.

Thiết kế tách đôi này rất quan trọng vì khi đặt lệnh, sàn phải khóa một phần tài sản để đảm bảo user không dùng vượt số dư.

### 4.5 `orders_log`

`orders_log` là nhật ký tất cả lệnh đã đi qua engine.

Các trường chính:
- `id`: UUID nội bộ,
- `order_id`: ID gốc của engine,
- `user_id`: chủ lệnh,
- `market_symbol`: cặp giao dịch,
- `side`: buy/sell,
- `price`, `amount`, `filled`,
- `status`: open/partial/filled/cancelled,
- `created_at`, `updated_at`.

### Vì sao cần bảng log riêng

Engine chỉ giữ trạng thái trong RAM. Nếu chỉ có in-memory state thì:
- restart sẽ mất lịch sử,
- không có audit trail,
- không thể truy xuất order history,
- không thể đối soát khớp lệnh.

Vì vậy `orders_log` là lớp ghi nhận bền vững cho mọi lệnh.

### Tính chất denormalize có chủ đích

`orders_log` lưu sẵn `market_symbol`, `side`, `price`, `amount`, `filled`, `status` để:
- đọc nhanh,
- tránh join nhiều bảng khi hiển thị lịch sử lệnh,
- phục vụ query user history hiệu quả.

### 4.6 `trades_log`

`trades_log` là bảng ghi toàn bộ giao dịch đã khớp.

Các trường chính:
- `maker_order_id`, `taker_order_id`,
- `maker_user_id`, `taker_user_id`,
- `market_symbol`, `price`, `amount`,
- `executed_at`.

### Lý do lưu dư dữ liệu

Bảng này cố tình lưu `maker_user_id`, `taker_user_id`, `market_symbol` thay vì chỉ lưu khóa ngoại tối thiểu.

Lý do:
- đọc lịch sử trade nhanh hơn,
- không cần join nhiều bảng,
- thuận tiện dựng public trades feed,
- thuận tiện cho thống kê maker/taker riêng biệt.

### Quan hệ với `orders_log`

`maker_order_id` và `taker_order_id` tham chiếu tới `orders_log(order_id)`.

Điều này cho phép:
- đối soát trade với order gốc,
- truy vết fill của từng lệnh,
- và giữ chuỗi sự kiện rõ ràng từ order sang trade.

### 4.7 `candles`

`candles` lưu dữ liệu OHLCV cho biểu đồ.

Các trường chính:
- `market_symbol`,
- `interval`,
- `open_time`,
- `open`, `high`, `low`, `close`, `volume`.

### Lý do có bảng này

Trading UI không nên tự cộng trade từng lần mỗi khi render biểu đồ. Việc tổng hợp candle ở tầng persistence giúp:
- hiển thị nhanh hơn,
- giảm tải frontend,
- phù hợp với các khoảng 1m, 5m, 1h, 1d,
- và giữ dữ liệu biểu đồ ổn định.

### 4.8 `zkp_snapshots`

`zkp_snapshots` lưu metadata của snapshot phục vụ ZKP.

Các trường chính:
- `snapshot_id`,
- `root_hash`,
- `users_included`,
- `created_at`.

### Vai trò

Bảng này không lưu toàn bộ leaf, mà chỉ lưu metadata cấp cao để:
- truy vết snapshot đã dùng cho proof,
- lưu dấu vết root hash,
- phục vụ audit solvency về sau.

## 5. Dòng chảy dữ liệu giữa các bảng

### 5.1 Khi user đặt lệnh

1. API nhận lệnh.
2. Matching engine xử lý trong RAM.
3. Worker ghi một dòng vào `orders_log` với trạng thái `open`.
4. Nếu lệnh khớp một phần hoặc toàn phần, `orders_log.filled` và `status` được cập nhật.

### 5.2 Khi có trade khớp

1. Engine tạo `Trade`.
2. Worker ghi `trades_log`.
3. Worker cập nhật `orders_log.filled`.
4. Worker cập nhật `balances.available` và `balances.locked` theo logic settlement.
5. Worker aggregate sang `candles` để phục vụ chart.

### 5.3 Khi user hủy lệnh

1. Engine xóa lệnh khỏi orderbook RAM.
2. Worker cập nhật `orders_log.status = cancelled`.
3. Phần số dư bị khóa sẽ được hoàn trả ở tầng nghiệp vụ nếu cần.

### 5.4 Khi sinh ZKP snapshot

1. API đọc số dư từ `balances`.
2. Dùng `available + locked` để tạo snapshot.
3. Build Merkle Sum Tree.
4. Lưu metadata root vào `zkp_snapshots`.

## 6. Worker bất đồng bộ và lý do tồn tại

File [core/src/db/worker.rs](core/src/db/worker.rs) là một background worker dùng `tokio::mpsc`.

### Vai trò

Worker nhận các event như:
- `OrderPlaced`,
- `TradeFilled`,
- `OrderCancelled`.

Sau đó nó ghi xuống PostgreSQL theo batch.

### Vì sao cần worker riêng

Nếu API ghi DB trực tiếp trong luồng matching thì:
- request latency tăng,
- engine bị chặn bởi I/O,
- throughput giảm,
- và khó giữ matching hoàn toàn trong RAM.

Worker giúp tách rõ:
- luồng nóng: matching in-memory,
- luồng lạnh: persistence async.

### Quy tắc quan trọng của worker

Worker yêu cầu thứ tự event đúng:
1. Ghi `OrderPlaced` trước.
2. Sau đó mới ghi `TradeFilled`.

Lý do là `trades_log` có khóa ngoại trỏ về `orders_log`, nên order gốc phải tồn tại trước.

### Batch flush

Worker gom event theo batch để:
- giảm số round-trip DB,
- tăng throughput,
- giảm áp lực connection pool.

## 7. Lý do dùng các kiểu dữ liệu này

### `NUMERIC(30,8)` cho số tiền

Tiền và khối lượng trong exchange phải chính xác tuyệt đối. Vì vậy PostgreSQL dùng `NUMERIC(30,8)` thay vì float.

### `BIGINT` cho ID

ID user, order, và các khóa liên quan dùng `BIGINT` để:
- dễ cast từ Rust `u64` khi qua boundary,
- đủ lớn cho hệ thống nhiều bản ghi,
- đơn giản hóa mapping với `sqlx`.

### `UUID` cho log nội bộ

Các bảng log dùng UUID làm khóa kỹ thuật để:
- tránh lộ thứ tự tăng dần,
- hỗ trợ tracing nội bộ,
- và tách giữa ID nghiệp vụ với ID lưu trữ.

### `TIMESTAMPTZ`

Mọi mốc thời gian đều dùng timezone-aware timestamp để đảm bảo nhất quán khi hệ thống chạy trong Docker, CI, hoặc nhiều môi trường khác nhau.

## 8. Chỉ mục và tối ưu truy vấn

Các index trong migration [core/migrations/0001_initial_schema.sql](core/migrations/0001_initial_schema.sql) được tạo ra để phục vụ các truy vấn phổ biến nhất.

### Những truy vấn quan trọng

- lấy open orders theo user,
- lấy lịch sử lệnh theo user,
- lấy lịch sử trade theo maker hoặc taker,
- lấy trade theo market,
- lấy candles gần nhất theo market và interval.

### Vì sao index theo kiểu này

Vì UI và API thường cần:
- lịch sử của một user,
- public trades của thị trường,
- và chart candles mới nhất.

Index được chọn để giảm thời gian đọc ở các đường hot path đó.

## 9. Lịch sử tiến hóa schema

### Migration 0001 - schema gốc

[core/migrations/0001_initial_schema.sql](core/migrations/0001_initial_schema.sql) tạo toàn bộ nền tảng:
- enum `order_side`, `order_status`,
- users, assets, markets, balances,
- orders_log, trades_log, candles,
- index và seed data.

### Migration 0002 - display_name

[core/migrations/0002_user_display_name.sql](core/migrations/0002_user_display_name.sql) thêm `display_name` vào `users`.

Lý do:
- tách tên đăng nhập và tên hiển thị,
- hỗ trợ UI thân thiện hơn,
- vẫn giữ compatibility với dữ liệu cũ bằng cách backfill từ `username`.

### Migration 0003 - admin features

[core/migrations/0003_admin_features.sql](core/migrations/0003_admin_features.sql) thêm:
- `users.is_suspended`,
- `markets.is_active`,
- `assets.is_active`.

Lý do:
- cần khả năng khóa user,
- bật/tắt market hoặc asset mà không xóa dữ liệu lịch sử,
- phù hợp cho kiểm soát vận hành.

### Migration 0004 - ZKP snapshots

[core/migrations/0004_zkp_snapshots.sql](core/migrations/0004_zkp_snapshots.sql) thêm bảng `zkp_snapshots`.

Lý do:
- lưu dấu vết của proof snapshot,
- gắn root hash với thời điểm sinh proof,
- phục vụ audit solvency.

## 10. Lý do thiết kế theo kiểu hiện tại

### Tách engine và database

Đây là quyết định kiến trúc quan trọng nhất.

Nếu DB tham gia vào matching trực tiếp thì:
- độ trễ tăng,
- dễ phát sinh lock contention,
- khó đảm bảo determinism,
- và throughput giảm mạnh.

Tách DB ra thành persistence layer giúp hệ thống:
- giữ matching nhanh,
- vẫn có lịch sử bền vững,
- và dễ mở rộng audit/analytics.

### Denormalize có chủ đích

Các bảng log lưu nhiều trường dư thừa là có chủ đích, không phải lỗi thiết kế.

Mục tiêu là:
- đọc nhanh,
- giảm JOIN,
- tối ưu dashboard và API lịch sử.

### Khóa chính và khóa ngoại chặt chẽ

Các FK được dùng để bảo đảm tính toàn vẹn:
- order luôn thuộc user hợp lệ,
- trade luôn trỏ về order thật,
- balance luôn gắn với asset hợp lệ,
- market luôn gắn với asset hợp lệ.

### Phù hợp với mô hình CEX trong monolith

Vì dự án là monolith nên schema được thiết kế để:
- dễ truy vấn trong cùng một DB,
- dễ audit,
- dễ backup/restore,
- và đồng bộ với worker async đơn giản.

## 11. Kết luận

Database của dự án được xây theo 3 mục tiêu chính:

1. **Không làm chậm matching engine**: mọi ghi xuống DB đều async.
2. **Giữ tính toàn vẹn dữ liệu**: FK, enum, check constraint, index.
3. **Phục vụ các nhu cầu thực tế của sàn**: order history, trade history, balances, chart candles, ZKP snapshots.

Nói gọn lại, database ở đây không phải nơi xử lý giao dịch chính, mà là lớp lưu vết, đối soát, và phục vụ kiểm chứng cho một hệ thống matching engine chạy trong RAM.

