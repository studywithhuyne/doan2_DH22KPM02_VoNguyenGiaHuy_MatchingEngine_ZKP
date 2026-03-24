# ZKP Trong Dự Án

Tài liệu này giải thích toàn bộ phần Zero-Knowledge Proof (ZKP) đang có trong dự án, cách các module được xây dựng, cách tạo circuit, và cách ZKP được ứng dụng vào luồng thực tế của hệ thống.

## 1. Mục tiêu của phần ZKP

Phần ZKP trong dự án phục vụ mục đích chính là **Proof of Solvency**.

Nói ngắn gọn, hệ thống muốn chứng minh rằng:
- số dư người dùng được ghi nhận đúng,
- tổng liabilities có thể được tổng hợp từ snapshot nội bộ,
- dữ liệu không bị sửa giữa các tầng tính toán,
- và client có thể tự xác minh một proof mà không cần tin hoàn toàn vào backend.

Phần ZKP trong repo hiện tại được triển khai bằng Rust crate `zkp/`, sử dụng hệ sinh thái `arkworks` và `wasm-bindgen`.

## 2. Các module ZKP hiện có

Trong `zkp/src/lib.rs`, crate ZKP được chia thành các module sau:

- `tree` - xây Merkle Sum Tree, sinh proof Merkle theo từng lá.
- `poseidon` - tạo hash Poseidon cho lá và node cha.
- `circuit` - circuit ràng buộc quan hệ cha-con trong Merkle tree.
- `verifier` - verify proof JSON ở phía client/browser.
- `snark` - tạo Groth16 proof cho membership/leaf commitment ở phía server.

Ngoài ra, `verify_proof(proof_json, public_inputs_json)` được export qua `wasm_bindgen` để phía frontend có thể gọi trực tiếp.

## 3. Kiến trúc ZKP tổng thể

Phần ZKP của dự án đang có 2 lớp kiểm chứng chính:

### Lớp A - Merkle Sum Tree + verifier JSON

Đây là luồng chính đang được dùng để chứng minh tính toàn vẹn của snapshot số dư:
1. Lấy snapshot số dư từ database.
2. Chuẩn hóa thành danh sách leaf.
3. Xây Merkle Sum Tree bằng Poseidon hash.
4. Sinh Merkle proof cho user hiện tại.
5. Frontend hoặc client gọi verifier WASM để xác minh đường đi từ leaf lên root.

### Lớp B - Groth16 membership SNARK

Đây là một circuit riêng trong `snark.rs`:
1. Encode `user_id` và `leaf_balance` thành field element.
2. Tạo commitment cho leaf bằng Poseidon.
3. Dựng circuit membership.
4. Sinh Groth16 proof.
5. Serialize proof và public inputs sang base64.
6. API trả package này về cho client.

Hai lớp này bổ sung cho nhau:
- Merkle Sum Tree giúp chứng minh toàn bộ snapshot và root balance.
- Groth16 proof giúp chứng minh một user cụ thể thuộc snapshot hợp lệ.

## 4. Dữ liệu đầu vào của ZKP

### Snapshot số dư

Trong `core/src/api/zkp.rs`, API lấy dữ liệu từ bảng `balances`:
- `user_id`
- `available`
- `locked`

Sau đó hệ thống tính:

```text
balance = available + locked
```

Giá trị này được chuyển thành `BalanceSnapshot` trong `zkp/src/tree.rs`.

### Kiểu dữ liệu chính

- `BalanceSnapshot`: snapshot chuẩn hóa của một user.
- `DbBalanceSnapshot`: snapshot đọc trực tiếp từ DB.
- `MerkleNode`: gồm `hash` và `balance`.
- `MerkleProofStep`: một bước trong đường đi Merkle.
- `MerkleProof`: proof hoàn chỉnh cho một leaf.
- `MerkleSumTree`: toàn bộ cây.

## 5. Cách xây Merkle Sum Tree

### Mục tiêu

Merkle Sum Tree vừa đảm bảo tính toàn vẹn của dữ liệu, vừa giữ tổng số dư ở mỗi node.

### Cách hoạt động

Trong `zkp/src/tree.rs`, quy trình build tree diễn ra theo kiểu bottom-up:

1. Tạo leaf nodes từ snapshot.
2. Nếu số leaf là lẻ, nhân bản leaf cuối để bảo đảm số lượng chẵn.
3. Ghép từng cặp node con trái và phải.
4. Tính balance node cha bằng tổng balance của 2 node con.
5. Tính hash node cha bằng Poseidon hash trên:
	- hash trái,
	- hash phải,
	- balance trái,
	- balance phải.
6. Lặp lại cho đến khi chỉ còn 1 node gốc.

### Vì sao cần tổng balance ở node cha

Đây là điểm khác biệt quan trọng so với Merkle Tree thường:
- Merkle Tree thường chỉ chứng minh dữ liệu không bị sửa.
- Merkle Sum Tree còn cho phép kiểm tra tổng liabilities ở root.

Nghĩa là nếu root.balance đúng, thì toàn bộ hệ thống có thể chứng minh tổng số dư cộng dồn của các leaf bên dưới.

### Ý nghĩa trong dự án

Tree này là nền móng cho Proof of Solvency, vì nó cho phép kiểm tra:
- dữ liệu leaf hợp lệ,
- root hash ổn định,
- và tổng số dư không bị bịa hoặc thay đổi trái phép.

## 6. Cách sinh Merkle proof

### Mục tiêu

Tạo một đường đi từ leaf đến root để chứng minh leaf đó nằm trong cây.

### Thuật toán

Khi gọi `generate_proof(leaf_index)`:

1. Kiểm tra `leaf_index` có nằm trong phạm vi leaf gốc hay không.
2. Với từng level của tree:
	- xác định node hiện tại đang ở bên trái hay phải,
	- tính chỉ số sibling tương ứng,
	- lấy `sibling_hash`, `sibling_balance`, `sibling_is_left`.
3. Đẩy mỗi bước vào `path`.
4. Chia đôi chỉ số để đi lên tầng cha kế tiếp.
5. Trả về `MerkleProof` gồm:
	- leaf,
	- path,
	- root.

### Dữ liệu trong proof

Một proof đầy đủ chứa:
- leaf ban đầu,
- từng sibling trên đường đi,
- root cuối cùng.

### Ý nghĩa trong dự án

Proof này được dùng cho phía verifier để tái dựng lại hash từ leaf lên root và kiểm tra rằng dữ liệu snapshot là nhất quán.

## 7. Cách tạo Poseidon hash

### Mục tiêu

Poseidon là hàm hash thân thiện với ZK circuit, vì nó được thiết kế để giảm chi phí ràng buộc trong proof systems.

### Cài đặt trong dự án

Trong `zkp/src/poseidon.rs`, dự án dùng:
- `ark_bn254::Fr` làm field nền,
- `ark_sponge::poseidon::PoseidonSponge`,
- `PoseidonParameters` được khởi tạo có chủ đích theo cấu hình cố định.

### Hai kiểu hash chính

#### Leaf hash

```text
leaf_hash = Poseidon(user_id, balance)
```

Hàm `poseidon_leaf_hash(user_id, balance)` dùng để tạo hash cho một leaf.

#### Internal hash

```text
parent_hash = Poseidon(left_hash, right_hash, left_balance, right_balance)
```

Hàm `poseidon_internal_hash(...)` dùng để tạo hash của node cha từ hai node con.

### Quy trình chuyển số liệu tài chính sang field

Vì ZK circuit hoạt động trên field arithmetic, nên `Decimal` phải được chuyển sang field element:
1. Kiểm tra balance không âm.
2. Rescale decimal về scale cố định `8`.
3. Lấy mantissa.
4. Chuyển sang `u128` rồi sang `Fr`.

### Ý nghĩa trong dự án

Poseidon là lớp băm duy nhất dùng xuyên suốt từ leaf, node cha, circuit, đến verifier.

## 8. Cách tạo circuit ZK cho quan hệ node cha-con

Đây là phần quan trọng nhất nếu xét riêng “cách tạo circuit”. File chính là `zkp/src/circuit.rs`.

### Mục tiêu của circuit

Circuit này chứng minh rằng một node cha trong Merkle Sum Tree là hợp lệ, tức là:
- hash cha đúng,
- tổng balance cha đúng,
- và phép cộng không overflow.

### Cấu trúc circuit

Struct chính là `MerkleNodeRelationCircuit` với các trường:

- `left_hash`
- `right_hash`
- `parent_hash`
- `left_balance_scaled`
- `right_balance_scaled`
- `parent_balance_scaled`

Các giá trị hash được lưu dưới dạng 32 byte, còn balance được lưu dưới dạng số nguyên đã scale.

### Cách circuit được tạo

#### Bước 1 - Chuẩn bị witness và public-like values

Trong `generate_constraints`, circuit tạo các biến:
- `left_hash_var`, `right_hash_var`, `parent_hash_var`
- `left_balance_var`, `right_balance_var`, `parent_balance_var`
- `left_balance_fp`, `right_balance_fp`, `parent_balance_fp`

Các biến này được khai báo bằng `new_witness`, nghĩa là chúng được cung cấp như witness trong quá trình tạo proof.

#### Bước 2 - Ràng buộc tổng balance

Circuit áp đặt:

```text
left_balance_fp + right_balance_fp = parent_balance_fp
```

Đây là constraint số học đầu tiên và quan trọng nhất.

#### Bước 3 - Ràng buộc hash Poseidon

Circuit khởi tạo `PoseidonSpongeVar` và absorb theo đúng thứ tự:
- left hash
- right hash
- left balance
- right balance

Sau đó squeeze ra `expected_parent_hash` và ràng buộc:

```text
expected_parent_hash = parent_hash_var
```

#### Bước 4 - Kiểm tra không overflow `u128`

Ngoài ràng buộc ở field, circuit còn kiểm tra cộng số nguyên theo từng bit:
- chuyển `UInt128` sang bits,
- tính carry,
- enforce từng bit cộng đúng,
- đảm bảo carry cuối cùng bằng 0.

Nói cách khác, circuit không chỉ kiểm tra “kết quả số học trong field”, mà còn kiểm tra đúng semantics của phép cộng số nguyên không dấu 128-bit.

### Vì sao cần bước overflow check

Nếu chỉ check trên field thì có thể xuất hiện trường hợp kết quả modular arithmetic hợp lệ nhưng không đúng với cộng số học thực tế. Bước kiểm tra carry ngăn điều đó.

### Vai trò trong dự án

Circuit này là khối nền tảng cho việc chứng minh rằng một node cha trong cây Merkle Sum Tree được tạo đúng từ hai node con hợp lệ.

## 9. Circuit Groth16 membership trong `snark.rs`

Ngoài circuit Merkle node relation, dự án còn có một circuit Groth16 để chứng minh membership của một user đối với leaf commitment.

### Mục tiêu

Chứng minh rằng:
- `user_id` đúng với public input mong đợi,
- `leaf_balance` được băm đúng thành leaf commitment bằng Poseidon.

### Circuit hoạt động như thế nào

Trong `zkp/src/snark.rs`, circuit nội bộ là `MembershipCircuit`.

#### Input public

- `leaf_commitment`
- `expected_user_id`

#### Witness

- `user_id`
- `leaf_balance`

#### Các ràng buộc

1. `user_id_witness = expected_user_id_public`
2. `Poseidon(user_id_witness, leaf_balance_witness) = leaf_commitment_public`

### Quy trình tạo proof

Trong `create_membership_snark`:
1. Chuyển `user_id` và `leaf_balance` sang `Fr`.
2. Tính `leaf_commitment` từ Poseidon.
3. Khởi tạo `MembershipCircuit`.
4. Gọi `create_random_proof` của Groth16.
5. Lấy verifying key và verify ngay trong server để kiểm tra proof vừa tạo.
6. Serialize proof sang base64.
7. Serialize public inputs sang base64.
8. Trả về `SnarkProofPackage`.

### Khi nào dùng circuit này

Circuit này phù hợp khi dự án cần một proof nhỏ gọn chứng minh một user cụ thể có leaf hợp lệ trong một snapshot chứng minh solvency.

## 10. Verifier phía client

### Mục tiêu

Cho phép frontend hoặc browser tự verify proof thay vì phụ thuộc hoàn toàn vào backend.

### Cách hoạt động

File `zkp/src/verifier.rs` xử lý JSON proof như sau:

1. Parse proof JSON.
2. Parse public inputs JSON.
3. Nếu cần, kiểm tra `expected_user_id`.
4. Tính lại leaf hash từ `user_id` và `leaf_balance`.
5. Duyệt từng bước trong `merkle_path`.
6. Ở mỗi bước, ghép sibling hash và sibling balance theo chiều trái/phải đúng với `sibling_is_left`.
7. So sánh hash cuối cùng với root trong proof và root mong đợi.

### Ý nghĩa trong dự án

Verifier này biến ZKP từ một thứ chỉ chạy trong backend thành một cơ chế mà client có thể kiểm tra độc lập.

### Export sang WASM

Trong `zkp/src/lib.rs`, hàm `verify_proof(proof_json, public_inputs_json)` được đánh dấu bằng `wasm_bindgen`, nghĩa là frontend có thể gọi từ WebAssembly.

## 11. Cách ZKP được ứng dụng trong API của dự án

File tích hợp chính là `core/src/api/zkp.rs`.

### Luồng `proof_handler`

1. API nhận `user_id` từ middleware auth.
2. Đọc snapshot số dư của asset từ DB.
3. Chuyển dữ liệu thành `BalanceSnapshot`.
4. Xây Merkle Sum Tree bằng `build_poseidon_merkle_sum_tree`.
5. Sinh Merkle proof cho leaf của user hiện tại bằng `generate_proof`.
6. Tạo `root_hash` và `leaf_balance` để đưa cho client.
7. Gọi `create_membership_snark` để sinh SNARK package.
8. Trả về response chứa:
	- snapshot size,
	- leaf index,
	- leaf balance,
	- root hash,
	- public inputs,
	- SNARK proof,
	- và thông tin solvency nếu có cấu hình `cold_wallet_assets`.

### Luồng `solvency_handler`

Đây là endpoint kiểm tra ở mức tổng thể:
1. Lấy tất cả balances của asset.
2. Build Merkle Sum Tree.
3. Lấy `root.balance` làm tổng liabilities.
4. So sánh với `cold_wallet_assets`.
5. Trả về kết quả `liabilities_leq_assets`.

### Ý nghĩa thực tế

API này biến ZKP từ module riêng thành một phần của ứng dụng thật:
- backend trích snapshot,
- tree và proof được sinh ở server,
- client có thể verify,
- và hệ thống có thể công bố tình trạng solvency theo asset.

## 12. Cách ZKP được dùng ở frontend

### WASM verifier

Frontend không cần hiểu toàn bộ logic cryptography. Nó chỉ cần:
- nhận proof JSON,
- nhận public inputs JSON,
- gọi `verify_proof` từ WASM,
- hiển thị `valid` hoặc `invalid`.

### Lợi ích

- giảm độ tin cậy phải đặt vào server,
- giúp người dùng tự kiểm tra proof,
- phù hợp với yêu cầu minh bạch của Proof of Solvency.

## 13. Lưu ý kỹ thuật quan trọng

### Poseidon parameters hiện tại

Trong code hiện tại, tham số Poseidon được tạo có tính xác định từ seed. Điều này giúp test và dev ổn định, nhưng trước production cần audit lại bộ hằng số Poseidon để đảm bảo tiêu chuẩn mật mã học.

### Scale của Decimal

Balance được rescale về `8` chữ số thập phân trước khi đưa vào field/circuit. Điều này đảm bảo mọi so sánh và cộng số dư là nhất quán.

### Không dùng `f32`/`f64`

Toàn bộ phần ZKP và số dư tài chính đều dùng `Decimal`. Đây là điều bắt buộc để tránh sai số làm tròn.

### SNARK vs Merkle proof

Hai thứ này khác nhau:
- Merkle proof chứng minh một leaf nằm trong tree.
- Groth16 SNARK chứng minh một quan hệ số học/hashing đúng trong circuit.

Trong dự án, chúng được dùng song song để tăng độ tin cậy.

## 14. Tóm tắt ngắn gọn luồng ZKP trong dự án

1. DB cung cấp snapshot balances.
2. Snapshot được chuẩn hóa thành leaf.
3. Poseidon hash tạo leaf hash và parent hash.
4. Merkle Sum Tree được build bottom-up.
5. Proof Merkle được sinh cho user.
6. `circuit.rs` mô tả ràng buộc node cha-con.
7. `snark.rs` tạo Groth16 proof cho membership.
8. `verifier.rs` xác minh proof ở client.
9. `core/src/api/zkp.rs` nối toàn bộ phần này vào API thực tế.

## 15. Kết luận

Phần ZKP của dự án không phải là một mô hình đơn lẻ, mà là một chuỗi gồm:
- chuẩn hóa snapshot,
- xây Merkle Sum Tree,
- tạo Poseidon hash,
- dựng circuit constraint,
- sinh SNARK proof,
- và verify ở client bằng WASM.

Điểm cốt lõi là dự án dùng ZKP để biến dữ liệu số dư nội bộ thành một bằng chứng có thể kiểm tra được, thay vì chỉ công bố số liệu dạng niềm tin.

