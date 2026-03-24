(# Technology, Algorithms, and Cryptography Used)

**Công nghệ chính**
- **Ngôn ngữ:** Rust (edition 2021).
- **Async & Web:** `tokio`, `axum` (WebSocket support).
- **Cơ sở dữ liệu:** PostgreSQL (async persistence) qua `sqlx`.
- **Số thập phân tài chính:** `rust_decimal` (tất cả tiền, giá, khối lượng).
- **Đồng bộ hóa & hiệu năng:** `parking_lot` RwLock, `BTreeMap` cho orderbook.
- **Frontend:** Svelte + Vite (SPA) trong thư mục `web/`.
- **Container & proxy:** Docker, docker-compose, Nginx (static + reverse proxy).
- **Giám sát:** `tracing`, `metrics`, `metrics-exporter-prometheus`.

**Thuật toán & cấu trúc dữ liệu**
- **Limit Order Book (LOB):** Price–time priority matching; bids lưu theo thứ tự giảm, asks theo thứ tự tăng (sử dụng `std::collections::BTreeMap`).
- **Matching Engine:** Core matching logic là các hàm đồng bộ (no I/O) trong `core/src/engine` (ví dụ: `match_order`, `add_order`).
- **Decimal arithmetic:** Mọi phép toán về tiền tệ dùng `rust_decimal` để tránh lỗi làm tròn của `f32/f64`.
- **Orderbook walking:** Taker có thể tiêu thụ nhiều Maker — thuật toán đi qua các mức giá theo thứ tự ưu tiên.
- **Đồng thời:** Engine state được bọc trong `Arc<RwLock<...>>` (hoặc `Arc<parking_lot::RwLock<...>>`) để truy cập an toàn từ handlers async.

**Kỹ thuật mã hóa & ZKP (Zero-Knowledge Proofs)**
- **Merkle Sum Tree:** Cây Merkle có tổng (Merkle Sum Tree) để chứng minh tổng số dư; cài đặt trong [zkp/tree.rs](zkp/tree.rs).
- **Poseidon Hash:** Hàm hash thân thiện với ZK được sử dụng (ark-sponge / Poseidon); mã liên quan trong [zkp/poseidon.rs](zkp/poseidon.rs).
- **Circuit & Prover:** Mạch ZK được triển khai trong [zkp/circuit.rs](zkp/circuit.rs) và dùng thư viện `arkworks` (`ark-ff`, `ark-sponge`, `ark-r1cs-std`).
- **Proof system:** Dự án khai báo `ark-groth16` cho phần prover (thực thi trên server/dev); verifier được biên dịch sang WASM.
- **WASM verifier:** Verifier biên dịch bởi `wasm-bindgen` để chạy ở phía client; mã ở [zkp/verifier.rs](zkp/verifier.rs).
- **Lưu trữ & truyền chứng minh:** `serde`/`serde_json` và `base64` để serialize/encode proof payloads.

**Bảo mật, xác thực và hashing**
- **Ed25519:** `ed25519-dalek` dùng cho chữ ký API key / message signing.
- **Argon2id:** `argon2` cho hashing mật khẩu (resistant to GPU/ASIC).
- **JWT (dev):** `jsonwebtoken` được cấu hình cho một số endpoint (môi trường dev/test).
- **Hashing nội bộ:** `blake3` dùng cho một số định danh ledger tốc độ cao.

**Kiểm thử & benchmarking**
- **Unit tests:** Các hàm core của Engine có `#[test]` trong crate `core`.
- **Property tests / Fuzzing:** `proptest` dùng để sinh orders ngẫu nhiên và kiểm tra không panic / invariant preservation.
- **Benchmarks:** `criterion` cho benchmark micro-bench của engine (thư mục `core/benches`).

**Tệp liên quan (tham khảo nhanh)**
- [core/src/engine/engine.rs](core/src/engine/engine.rs)
- [core/src/engine/order_book.rs](core/src/engine/order_book.rs)
- [core/Cargo.toml](core/Cargo.toml)
- [zkp/circuit.rs](zkp/circuit.rs)
- [zkp/tree.rs](zkp/tree.rs)
- [zkp/poseidon.rs](zkp/poseidon.rs)
- [zkp/verifier.rs](zkp/verifier.rs)
- [zkp/Cargo.toml](zkp/Cargo.toml)

---
_Ghi chú:_ Nội dung trên dựa trên các dependency và tệp nguồn hiện có trong workspace (xem `core/Cargo.toml` và `zkp/Cargo.toml`). Nếu bạn muốn, tôi có thể mở rộng chi tiết implementation (ví dụ: mô tả chi tiết hàm `match_order`, sơ đồ Merkle Sum Tree, hoặc flow proving/verifying) hoặc thêm sơ đồ minh họa.

