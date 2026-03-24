# WASM Trong Dự Án

Tài liệu này giải thích cách WebAssembly hoạt động, vai trò của nó trong dự án, và nó được ứng dụng cụ thể như thế nào trong phần ZKP.

## 1. WASM là gì

WebAssembly (WASM) là một định dạng bytecode chạy trong trình duyệt hoặc runtime hỗ trợ WASM. Nó không phải là ngôn ngữ lập trình riêng, mà là đích biên dịch của nhiều ngôn ngữ như Rust, C, C++.

Trong dự án này, WASM được dùng để:
- chạy logic verify proof ngay trên client,
- giảm sự phụ thuộc vào backend,
- cho phép người dùng tự kiểm tra kết quả proof,
- và giữ phần mật mã học chạy trong môi trường sandbox của trình duyệt.

## 2. Cách WASM hoạt động ở mức khái niệm

### Bước 1 - Viết logic ở Rust

Phần verify proof được viết bằng Rust trong crate [zkp](zkp).

### Bước 2 - Biên dịch sang WASM

Crate `zkp` khai báo `crate-type = ["cdylib", "rlib"]` và dùng `wasm-bindgen` để xuất hàm sang JavaScript/WASM boundary.

### Bước 3 - Load vào frontend

Frontend tải module WASM và gọi hàm được export, ví dụ `verify_proof(proof_json, public_inputs_json)`.

### Bước 4 - Thực thi trong sandbox

Khi chạy trong browser, WASM hoạt động trong môi trường sandbox an toàn hơn so với việc tự viết toàn bộ logic verify bằng JavaScript thuần.

## 3. WASM được dùng ở đâu trong code nguồn

### 3.1 Export ở `zkp/src/lib.rs`

File [zkp/src/lib.rs](zkp/src/lib.rs) có hàm:

```text
verify_proof(proof_json, public_inputs_json)
```

Hàm này được đánh dấu bằng `wasm_bindgen`, nghĩa là nó là điểm vào cho phía client gọi qua WASM.

### 3.2 Logic verify nằm trong `zkp/src/verifier.rs`

Module verifier xử lý:
- parse proof JSON,
- parse public inputs JSON,
- rebuild hash từ Merkle path,
- so sánh root,
- trả về `true` hoặc `false`.

### 3.3 Phần SNARK nằm ở server/native

Module [zkp/src/snark.rs](zkp/src/snark.rs) chỉ được build khi **không phải wasm32**.

Điều này cho thấy dự án đã tách rõ:
- server/native: sinh Groth16 proof,
- client/WASM: verify proof.

## 4. WASM có được ứng dụng trong ZKP của bài này không

Câu trả lời là: **có, nhưng theo đúng phạm vi verify ở client, không phải toàn bộ ZKP pipeline**.

### Phần dùng WASM

Trong bài này, WASM được dùng cho:
- verify Merkle proof JSON,
- kiểm tra public inputs,
- xác minh root hash hợp lệ ở client.

### Phần không chạy trong WASM

Các phần sau vẫn chạy ở Rust native/backend:
- build Merkle Sum Tree,
- sinh Poseidon hash,
- tạo Groth16 proof,
- query snapshot từ DB,
- cache proof package ở API.

Nghĩa là WASM ở đây là lớp **client-side verification**, không phải toàn bộ prover.

## 5. Luồng hoạt động thực tế của WASM trong ZKP

### Luồng ở backend

1. API [core/src/api/zkp.rs](core/src/api/zkp.rs) đọc balances từ database.
2. Backend build Merkle Sum Tree.
3. Backend sinh Merkle proof cho user hiện tại.
4. Backend tạo SNARK package bằng `create_membership_snark`.
5. Backend trả về proof JSON, public inputs, root hash, và metadata.

### Luồng ở frontend/client

1. Frontend nhận proof JSON và public inputs.
2. Frontend gọi hàm WASM `verify_proof`.
3. WASM chạy logic verify trong Rust compiled-to-wasm.
4. Kết quả trả về là `valid` hoặc `invalid`.

## 6. Vì sao nên dùng WASM cho phần verify

### 6.1 Chạy cùng logic Rust

Vì phần verify viết bằng Rust nên biên dịch sang WASM giúp tái sử dụng logic mà không phải port sang JavaScript.

### 6.2 Tăng tính tin cậy

Verifier chạy phía client nghĩa là người dùng không phải hoàn toàn tin vào backend. Họ có thể kiểm tra proof ngay trên trình duyệt.

### 6.3 Sandbox an toàn

WASM giúp giới hạn quyền truy cập của code verify. Điều này phù hợp với tác vụ mật mã học và parsing proof.

### 6.4 Hiệu năng đủ tốt

Verifier ZKP thường cần thao tác lặp trên hash, balance, và path. WASM thường nhanh hơn JavaScript thuần ở các tác vụ tính toán kiểu này.

## 7. WASM trong dự án khác gì so với backend Rust

### Backend Rust

Backend Rust dùng để:
- sinh proof,
- truy cập DB,
- build tree,
- tạo SNARK package,
- cache kết quả,
- trả response qua Axum.

### WASM client

WASM chỉ dùng để:
- xác minh proof đã được backend phát hành,
- kiểm tra root/hash/public inputs,
- hiển thị kết quả verify cho user.

Như vậy WASM không thay thế backend, mà bổ sung một lớp xác minh độc lập ở phía client.

## 8. WASM có tham gia vào SNARK Groth16 không

### Câu trả lời ngắn

**Không phải phần prover Groth16 chính trong code hiện tại.**

### Giải thích

Trong `zkp/src/snark.rs`, proof Groth16 được tạo ở native Rust bằng `ark-groth16`, và module này chỉ được build khi không phải `wasm32`.

Điều đó nghĩa là:
- tạo SNARK proof: chạy server/native,
- verify JSON proof ở client: chạy WASM.

### Ý nghĩa

WASM ở đây không sinh proof Groth16, nhưng nó vẫn phục vụ phần ZKP quan trọng nhất ở phía người dùng: verify kết quả.

## 9. WASM trong dự án có phải là phần ZKP không

### Có

Vì logic WASM đang mang chính là logic xác minh proof của hệ ZKP.

### Nhưng không phải toàn bộ ZKP

Phần ZKP còn bao gồm:
- Merkle Sum Tree,
- Poseidon hash,
- circuit constraints,
- Groth16 proof generation,
- snapshot query,
- proof packaging.

WASM chỉ đảm nhiệm phần verify ở client.

## 10. Lý do kiến trúc hợp lý

Thiết kế hiện tại có 3 tầng rõ ràng:

1. **DB + API**: lấy snapshot và tạo proof.
2. **Rust native ZKP**: xây tree, tạo SNARK, mã hóa proof.
3. **WASM client verifier**: kiểm tra proof ở browser.

Lý do tách như vậy:
- giảm trust vào backend,
- giữ prover nặng ở server,
- để client tự xác minh,
- và tận dụng Rust ở cả hai phía native và browser.

## 11. Liên hệ với frontend Svelte

Phần frontend Svelte có thể gọi module WASM trong trang verify ZK. Điều này hợp với kiến trúc SPA vì:
- dữ liệu proof là JSON,
- verify diễn ra tại client,
- UI chỉ cần hiển thị trạng thái valid/invalid,
- không cần server round-trip để xác minh từng lần.

## 12. Kết luận

WASM trong dự án này được dùng đúng vai trò của nó:
- biên dịch logic verify Rust sang browser,
- cho phép client tự xác minh proof,
- bổ sung cho phần ZKP solvency,
- và không thay thế phần prover/native backend.

Nếu hỏi trực tiếp “WASM có được ứng dụng trong ZKP của bài này không?”, câu trả lời là: **có, ở lớp verifier client-side**.

