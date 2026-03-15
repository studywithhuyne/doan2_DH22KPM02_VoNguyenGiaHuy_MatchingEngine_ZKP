// Engine, api, and db modules are declared in lib.rs (matching_engine crate).
// Import them here as needed when implementing Axum routes in API-01+.

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();
    tracing::info!("Matching Engine starting...");
}
