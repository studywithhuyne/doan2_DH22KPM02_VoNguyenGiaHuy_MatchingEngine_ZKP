mod api;
mod db;
mod engine;

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();
    tracing::info!("Matching Engine starting...");
}
