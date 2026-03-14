// ZKP crate: Merkle Sum Tree + ZK-Proof of Solvency
// Compiled to WebAssembly via wasm-pack for client-side proof verification

pub mod circuit; // ZK circuit constraints (arkworks/halo2) - implemented in ZKP-04
pub mod tree;    // Merkle Sum Tree builder - implemented in ZKP-03
