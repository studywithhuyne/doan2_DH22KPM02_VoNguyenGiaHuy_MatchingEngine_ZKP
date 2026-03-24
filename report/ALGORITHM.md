# Thuật Toán Dùng Trong Dự Án

Tài liệu này mô tả các thuật toán chính đang được triển khai trong dự án, cách chúng hoạt động, và vai trò của từng thuật toán trong luồng chạy thực tế của hệ thống.

## 1. Thuật toán sổ lệnh giới hạn - Limit Order Book

### Mục tiêu
Sổ lệnh là nơi lưu các lệnh mua và bán đang chờ khớp. Dự án này dùng cấu trúc sổ lệnh theo ưu tiên giá - thời gian, tức là:
- Giá tốt hơn được ưu tiên trước.
- Nếu cùng mức giá, lệnh vào trước được khớp trước.

### Cấu trúc dữ liệu sử dụng
Trong `core/src/engine/order_book.rs`, sổ lệnh được cài đặt bằng:
- `BTreeMap<Reverse<Decimal>, VecDeque<Order>>` cho bên mua.
- `BTreeMap<Decimal, VecDeque<Order>>` cho bên bán.
- `HashMap<u64, (Side, Decimal)>` để tra cứu nhanh lệnh theo `order_id` khi hủy.

### Ý tưởng hoạt động
1. Bên mua được sắp theo giá giảm dần để giá cao nhất đứng đầu.
2. Bên bán được sắp theo giá tăng dần để giá thấp nhất đứng đầu.
3. Mỗi mức giá chứa một hàng đợi `VecDeque<Order>` để giữ FIFO.
4. Khi truy vấn độ sâu sổ lệnh, hệ thống cộng tổng khối lượng còn lại trong từng mức giá.

### Vai trò trong dự án
Đây là lõi của toàn bộ engine giao dịch. Mọi thuật toán khớp lệnh, hủy lệnh và hiển thị orderbook đều phụ thuộc vào cấu trúc này.

### Độ phức tạp
- Tìm mức giá tốt nhất: `O(log P)` khi cần truy cập cây giá, với `P` là số mức giá.
- Thêm lệnh mới: `O(log P)`.
- Duyệt từng lệnh trong cùng mức giá: `O(1)` cho thao tác đầu hàng đợi, nhưng hủy ở giữa hàng đợi có thể là `O(Q)` với `Q` là số lệnh tại mức giá đó.

## 2. Thuật toán thêm lệnh - Add Order

### Mục tiêu
Thêm một lệnh giới hạn vào sổ lệnh mà không thực hiện khớp ngay lập tức.

### Quy trình thực hiện
Trong hàm `add_order`:
1. Kiểm tra giá phải lớn hơn 0.
2. Kiểm tra khối lượng phải lớn hơn 0.
3. Kiểm tra trùng `order_id` bằng `order_map`.
4. Xác định lệnh thuộc phía mua hay bán.
5. Đưa lệnh vào cuối `VecDeque` của mức giá tương ứng để giữ FIFO.
6. Ghi vào `order_map` để phục vụ hủy lệnh nhanh.

### Vì sao dùng cách này
- Giữ đúng ưu tiên thời gian trong cùng mức giá.
- Tách rõ lệnh nghỉ (resting order) và lệnh chủ động (aggressive order).
- Tối ưu cho kịch bản sổ lệnh nhiều lệnh cùng mức giá.

### Vai trò trong dự án
Đây là cách hệ thống lưu lệnh còn dư sau khi khớp xong, hoặc các lệnh người dùng gửi vào nhưng chưa có mức giá đối ứng phù hợp.

## 3. Thuật toán hủy lệnh - Cancel Order

### Mục tiêu
Xóa một lệnh đang nằm trong sổ lệnh theo `order_id`.

### Quy trình thực hiện
Trong hàm `cancel_order`:
1. Tra cứu nhanh `(side, price)` từ `order_map`.
2. Nếu không tìm thấy thì trả lỗi `OrderNotFound`.
3. Dùng `side` để chọn đúng cây giá mua hoặc bán.
4. Tìm vị trí lệnh trong `VecDeque` của mức giá đó.
5. Xóa lệnh khỏi hàng đợi.
6. Nếu mức giá không còn lệnh nào, xóa luôn node khỏi `BTreeMap`.

### Điểm quan trọng
Việc lưu thêm `side` và `price` trong `order_map` giúp hệ thống không phải duyệt cả hai phía của sổ lệnh. Đây là tối ưu quan trọng để hủy lệnh nhanh hơn.

### Vai trò trong dự án
Đảm bảo người dùng có thể hủy lệnh đã đặt mà không làm chậm toàn bộ engine.

## 4. Thuật toán khớp lệnh - Matching Core

### Mục tiêu
Khớp một lệnh vào các lệnh đối ứng đang chờ trong sổ lệnh.

### Nguyên tắc khớp
Hệ thống dùng price-time priority:
- Lệnh mua khớp với mức ask thấp nhất trước.
- Lệnh bán khớp với mức bid cao nhất trước.
- Trong cùng một mức giá, lệnh vào trước được khớp trước.

### Luồng xử lý chung
Trong `match_order`:
1. Kiểm tra giá và khối lượng hợp lệ.
2. Kiểm tra trùng `order_id`.
3. Nếu là lệnh mua, gọi `fill_buy`.
4. Nếu là lệnh bán, gọi `fill_sell`.
5. Nếu lệnh vào còn dư sau khi khớp, đưa nó vào sổ lệnh như một resting order.

### Thuật toán khớp cho lệnh mua
`fill_buy` thực hiện:
1. Lấy mức ask tốt nhất hiện tại.
2. Kiểm tra xem ask tốt nhất có nhỏ hơn hoặc bằng giá lệnh mua hay không.
3. Lấy lệnh đầu hàng đợi tại mức giá đó.
4. Tính khối lượng khớp bằng `min(taker.remaining, maker.remaining)`.
5. Trừ số dư còn lại ở cả taker và maker.
6. Tạo bản ghi `Trade` với giá khớp bằng giá của maker.
7. Nếu maker đã hết khối lượng thì xóa khỏi queue và cập nhật `order_map`.
8. Lặp lại đến khi taker hết khối lượng hoặc không còn mức giá phù hợp.

### Thuật toán khớp cho lệnh bán
`fill_sell` hoạt động tương tự nhưng theo chiều ngược lại:
1. Lấy mức bid tốt nhất.
2. Kiểm tra bid tốt nhất có lớn hơn hoặc bằng giá lệnh bán hay không.
3. Lấy maker đầu hàng đợi.
4. Khớp theo `min(...)`.
5. Ghi nhận `Trade` tại giá của maker.
6. Xóa maker nếu đã khớp hết.
7. Dừng khi taker đã hết hoặc không còn giá đối ứng.

### Self-trade prevention
Trong cả `fill_buy` và `fill_sell`, nếu maker và taker cùng `user_id` thì hệ thống dừng khớp để tránh tự giao dịch chính mình.

### Vai trò trong dự án
Đây là thuật toán quan trọng nhất của matching engine. Nó quyết định cách lệnh được khớp, cách trade được sinh ra, và cách số dư trong engine thay đổi.

### Đặc điểm thiết kế
- Mọi logic khớp là synchronous, không có I/O.
- Engine được gọi trong tầng API async thông qua `Arc<RwLock<Engine>>`.
- Giá khớp luôn lấy theo giá của maker để giữ đúng nguyên tắc thị trường.

## 5. Thuật toán đi sổ lệnh - Walking the Book

### Mục tiêu
Cho phép một lệnh lớn khớp qua nhiều mức giá và nhiều maker khác nhau.

### Cách hoạt động
Nếu khối lượng của taker lớn hơn khối lượng tại mức giá tốt nhất, engine sẽ:
1. Khớp hết maker đầu tiên.
2. Chuyển sang maker tiếp theo tại cùng mức giá nếu còn.
3. Khi mức giá đó cạn, chuyển sang mức giá kế tiếp.
4. Tiếp tục cho đến khi taker đầy đủ hoặc không còn mức giá thỏa điều kiện.

### Vai trò trong dự án
Đây là thuật toán bảo đảm một lệnh lớn vẫn có thể khớp từng phần với nhiều lệnh nhỏ, đúng hành vi của sàn giao dịch thực tế.

## 6. Thuật toán định tuyến theo symbol - Multi-Symbol Routing

### Mục tiêu
Hỗ trợ nhiều thị trường giao dịch cùng lúc, ví dụ `BTC_USDT`, `ETH_USDT`.

### Cách hoạt động
Trong `core/src/engine/engine.rs`:
1. Engine lưu `HashMap<String, OrderBook>` theo symbol.
2. Khi có lệnh mới, engine tìm book tương ứng bằng `order.symbol`.
3. Nếu book chưa tồn tại thì tạo mới.
4. Sau đó chuyển lệnh vào `OrderBook` của symbol đó để khớp.

### Vai trò trong dự án
Tách riêng thanh khoản từng cặp giao dịch, tránh lệnh ở thị trường này ảnh hưởng đến thị trường khác.

### Độ phức tạp
- Tra cứu book theo symbol: trung bình `O(1)`.

## 7. Thuật toán tạo cây Merkle Sum Tree

### Mục tiêu
Chứng minh tổng số dư trong hệ thống mà vẫn cho phép xác minh tính toàn vẹn của từng lá.

### Dữ liệu đầu vào
Trong `zkp/src/tree.rs`, mỗi lá là một `MerkleNode` gồm:
- `hash`
- `balance`

Các lá được tạo từ snapshot số dư của người dùng, hoặc từ snapshot DB đã chuẩn hóa.

### Quy trình xây cây
1. Tạo danh sách lá từ snapshot.
2. Nếu số lá lẻ, nhân bản lá cuối để có số lượng chẵn.
3. Ghép cặp từng hai node con trái/phải.
4. Tính balance của node cha bằng tổng balance của hai node con.
5. Tính hash của node cha bằng Poseidon hash trên hash và balance của hai node con.
6. Lặp lại theo kiểu bottom-up cho đến khi còn một node gốc duy nhất.

### Vì sao là Merkle Sum Tree
Không chỉ chứng minh dữ liệu không bị sửa, cây còn mang theo tổng số dư tại mỗi node. Nhờ vậy, root của cây có thể phản ánh tổng số dư toàn hệ thống.

### Vai trò trong dự án
Đây là nền tảng để tạo proof solvency: hệ thống có thể chứng minh tổng số dư người dùng mà không phải lộ toàn bộ dữ liệu nội bộ.

## 8. Thuật toán tạo chứng minh Merkle

### Mục tiêu
Sinh đường đi từ một lá lên root để chứng minh lá đó thuộc cây và không bị chỉnh sửa.

### Quy trình
Trong `generate_proof`:
1. Kiểm tra chỉ số lá hợp lệ.
2. Với mỗi tầng của cây, xác định sibling của node hiện tại.
3. Ghi lại:
	- `sibling_hash`
	- `sibling_balance`
	- `sibling_is_left`
4. Chia đôi chỉ số để đi lên tầng cha.
5. Trả về proof gồm lá, đường đi, và root.

### Vai trò trong dự án
Proof này được dùng bởi verifier để tái tạo lại hash từ lá lên root và kiểm tra tính hợp lệ của nhánh trong cây.

## 9. Thuật toán Poseidon Hash

### Mục tiêu
Tạo hàm băm phù hợp cho môi trường zero-knowledge proof.

### Cách dùng trong dự án
Trong `zkp/src/poseidon.rs`:
- `poseidon_leaf_hash(user_id, balance)` tạo hash cho lá.
- `poseidon_internal_hash(left_hash, right_hash, left_balance, right_balance)` tạo hash cho node cha.

### Quy trình kỹ thuật
1. Dùng `arkworks` để khởi tạo Poseidon sponge trên field `Fr`.
2. Nén các giá trị đầu vào vào sponge.
3. Rút ra một field element làm hash.
4. Chuyển field element về 32 byte để lưu trong cây.

### Vì sao dùng Poseidon
Poseidon được thiết kế thân thiện với circuit ZK, giúp kiểm chứng rẻ hơn so với nhiều hash thông thường.

### Vai trò trong dự án
Poseidon là hàm băm trung tâm của toàn bộ phần ZKP solvency.

## 10. Thuật toán ràng buộc circuit ZK

### Mục tiêu
Xây dựng mạch chứng minh rằng:
- hash của node cha là hợp lệ,
- balance của node cha bằng tổng hai node con,
- phép cộng không bị tràn số.

### Triển khai
Trong `zkp/src/circuit.rs`, `MerkleNodeRelationCircuit` đại diện cho một quan hệ cha - con trong cây.

### Các ràng buộc chính
1. **Ràng buộc tổng balance**
	- `parent_balance = left_balance + right_balance`
2. **Ràng buộc hash**
	- `parent_hash = Poseidon(left_hash, right_hash, left_balance, right_balance)`
3. **Ràng buộc không tràn số**
	- Dùng `UInt128` và các bit carry để đảm bảo phép cộng `u128` không overflow.

### Cách hoạt động
Circuit nhận dữ liệu witness, chuyển các giá trị sang biến ràng buộc của hệ thống `arkworks`, sau đó kiểm tra các điều kiện trên bằng constraint system.

### Vai trò trong dự án
Đây là phần xác minh toán học của proof solvency. Nếu một bước trong cây sai, circuit sẽ không thỏa mãn.

## 11. Thuật toán xác minh proof ở client

### Mục tiêu
Cho phép client kiểm tra proof đã cung cấp có dẫn đến root hợp lệ hay không.

### Quy trình
Trong `zkp/src/verifier.rs`:
1. Parse JSON proof và public inputs.
2. Kiểm tra `user_id` nếu public input yêu cầu.
3. Tính hash lá từ `user_id` và `leaf_balance`.
4. Duyệt từng bước trong `merkle_path`.
5. Ở mỗi bước, dùng sibling hash và sibling balance để tái tạo hash node cha.
6. So sánh hash cuối cùng với root đã khai báo và root mong đợi.

### Ý nghĩa
Verifier không cần truy cập toàn bộ hệ thống backend. Chỉ cần proof và public inputs là có thể xác nhận tính hợp lệ của đường đi Merkle.

### Vai trò trong dự án
Đây là thành phần giúp hệ thống chứng minh solvency ở phía client/browser thông qua WASM.

## 12. Thuật toán chuẩn hóa snapshot số dư

### Mục tiêu
Chuyển dữ liệu snapshot từ DB sang định dạng an toàn để xây cây Merkle.

### Cách hoạt động
1. Nhận `available` và `locked` của từng user.
2. Cộng hai giá trị này thành balance tổng.
3. Kiểm tra `user_id` hợp lệ.
4. Loại bỏ trường hợp số dư âm hoặc tràn số.

### Vai trò trong dự án
Đảm bảo dữ liệu đầu vào cho cây Merkle Sum Tree là nhất quán, hợp lệ và có thể kiểm chứng.

## 13. Thuật toán kiểm thử bất biến bằng property testing

### Mục tiêu
Sinh dữ liệu ngẫu nhiên để kiểm tra engine không panic và không làm hỏng invariant.

### Cách dùng trong dự án
`proptest` được dùng để sinh các chuỗi lệnh ngẫu nhiên, sau đó kiểm tra:
- engine không panic,
- số dư không bị lệch,
- logic khớp không tạo kết quả sai.

### Vai trò trong dự án
Đây là lớp bảo vệ quan trọng cho engine giao dịch, đặc biệt khi số lượng lệnh và tình huống biên rất lớn.

## 14. Thuật toán benchmark hiệu năng

### Mục tiêu
Đo thời gian xử lý của các hàm lõi như `match_order` và giữ độ trễ ở mức rất thấp.

### Cách hoạt động
`criterion` chạy các bài benchmark lặp lại nhiều lần, thống kê thời gian trung bình và phân phối hiệu năng.

### Vai trò trong dự án
Cho phép theo dõi xem thay đổi code có làm chậm matching engine hay không.

## 15. Tóm tắt luồng hoạt động tổng thể

1. User gửi lệnh qua API.
2. API đưa lệnh vào `Engine` theo symbol.
3. `Engine` chuyển xuống `OrderBook`.
4. `OrderBook` chạy matching theo price-time priority.
5. Nếu còn dư, lệnh trở thành resting order.
6. Trade phát sinh được ghi nhận và có thể đẩy sang tầng lưu trữ bất đồng bộ.
7. Khi kiểm tra solvency, hệ thống lấy snapshot số dư, xây Merkle Sum Tree, sinh proof và xác minh bằng verifier.

## 16. Kết luận

Các thuật toán trong dự án tập trung vào 2 mảng lớn:
- **Matching engine tốc độ cao**: dùng `BTreeMap`, `VecDeque`, FIFO, price-time priority, và routing theo symbol.
- **ZKP solvency**: dùng Merkle Sum Tree, Poseidon Hash, circuit ràng buộc số học, và verifier chạy trên client.

Toàn bộ thiết kế đều hướng đến 3 mục tiêu chính:
- chính xác về số học tài chính,
- hiệu năng cao cho matching,
- và khả năng chứng minh tính toàn vẹn số dư bằng mật mã học.

