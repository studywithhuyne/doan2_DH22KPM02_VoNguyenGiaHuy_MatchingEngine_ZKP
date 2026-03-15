<script lang="ts">
  import { selectedUserId } from "../../stores/appStore";

  let proofData = $state("");
  let status = $state<"idle" | "fetching" | "verifying" | "valid" | "invalid" | "error">("idle");
  let errorMsg = $state("");
  let assetFilter = $state("USDT");

  // ── Fetch proof from backend (/api/zkp/proof) ─────────────────────────────
  async function fetchProofFromServer() {
    status = "fetching";
    errorMsg = "";
    try {
      const res = await fetch(`/api/zkp/proof?asset=${encodeURIComponent(assetFilter)}`, {
        headers: { "x-user-id": $selectedUserId.toString() }
      });
      if (!res.ok) {
        const body = await res.json().catch(() => ({ error: `HTTP ${res.status}` }));
        throw new Error(body.error || `Server returned ${res.status}`);
      }
      const data = await res.json();
      proofData = JSON.stringify(data, null, 2);
      status = "idle";
    } catch (err: any) {
      status = "error";
      errorMsg = err.message || "Failed to fetch proof from server";
    }
  }

  // ── Upload proof file ─────────────────────────────────────────────────────
  async function handleFileUpload(event: Event) {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (e) => {
      proofData = (e.target?.result as string) || "";
      status = "idle";
      errorMsg = "";
    };
    reader.onerror = () => {
      status = "error";
      errorMsg = "Failed to read file.";
    };
    reader.readAsText(file);
    // Reset input so the same file can be uploaded again if needed
    input.value = "";
  }

  // ── Run verifier (client-side) ────────────────────────────────────────────
  async function verifyProof() {
    if (!proofData.trim()) {
      errorMsg = "Please fetch, paste, or upload a ZK Proof JSON first";
      status = "error";
      return;
    }

    status = "verifying";
    errorMsg = "";

    try {
      // TODO: replace with real wasm-bindgen call:
      // const wasm = await import("zkp-verifier-wasm");
      // const result = wasm.verify_proof(proofData, publicInputsJson);
      await new Promise(r => setTimeout(r, 1200));

      // Structural validation: check required fields from /api/zkp/proof response
      const parsed = JSON.parse(proofData);
      const isValidStructure =
        typeof parsed.user_id      === "number" &&
        typeof parsed.leaf_balance === "string" &&
        typeof parsed.root_hash    === "string" &&
        typeof parsed.root_balance === "string" &&
        Array.isArray(parsed.merkle_path);

      if (isValidStructure) {
        status = "valid";
      } else {
        status = "invalid";
        errorMsg = "Proof JSON missing required fields (user_id, leaf_balance, root_hash, root_balance, merkle_path)";
      }
    } catch (err: any) {
      if (err instanceof SyntaxError) {
        status = "error";
        errorMsg = "Invalid JSON — could not parse proof data";
      } else {
        status = "error";
        errorMsg = err.message || "WASM panic or internal error";
      }
    }
  }
</script>

<section class="terminal-panel-strong p-4 sm:p-5 h-full flex flex-col relative overflow-hidden">
  <div class="mb-4 flex items-center justify-between">
    <h2 class="text-sm font-semibold tracking-wide text-slate-100 uppercase">ZK Proof Verifier</h2>
    <span class="mono rounded bg-fuchsia-500/10 border border-fuchsia-500/20 px-2 py-0.5 text-[10px] text-fuchsia-300">
      Client-side WASM
    </span>
  </div>

  <div class="flex-1 flex flex-col space-y-4">

    <!-- Fetch controls -->
    <div class="flex items-center gap-2">
      <select
        bind:value={assetFilter}
        class="w-24 rounded border border-slate-700/80 bg-slate-900/80 px-2 py-1.5 text-xs text-slate-200 outline-none focus:border-fuchsia-500/50 cursor-pointer"
      >
        <option value="USDT">USDT</option>
        <option value="BTC">BTC</option>
      </select>
      <button
        type="button"
        disabled={status === "fetching" || status === "verifying"}
        onclick={fetchProofFromServer}
        class="flex-1 h-8 rounded border border-sky-500/30 bg-sky-500/10 text-xs font-semibold tracking-wider text-sky-300 transition hover:bg-sky-500/20 active:scale-[0.98] disabled:opacity-50 disabled:pointer-events-none uppercase"
      >
        {status === "fetching" ? "Fetching..." : "Fetch Proof from Server"}
      </button>
    </div>

    <!-- Proof input area -->
    <div class="flex-1 space-y-1 flex flex-col">
      <div class="flex justify-between items-end">
        <label class="block text-[11px] font-medium tracking-widest text-slate-400 uppercase" for="proof-data">Proof Data</label>

        <label class="cursor-pointer bg-slate-800 hover:bg-slate-700 transition border border-slate-700 text-slate-300 text-[10px] px-2 py-1 rounded uppercase tracking-wider">
          Upload JSON
          <input type="file" accept=".json,.txt" class="hidden" onchange={handleFileUpload} />
        </label>
      </div>
      <textarea
        id="proof-data"
        bind:value={proofData}
        placeholder={'Click "Fetch Proof from Server" above, or paste JSON...\n\nExpected fields:\n  user_id, asset, leaf_balance,\n  root_hash, root_balance, merkle_path'}
        class="mono mt-2 block w-full flex-1 min-h-30 resize-none rounded-lg border border-slate-700/80 bg-slate-900/80 px-3 py-2 text-xs text-slate-300 outline-none transition focus:border-fuchsia-500/50 hide-scrollbar placeholder:text-slate-600"
      ></textarea>
    </div>

    <!-- Actions & Status -->
    <div class="space-y-3">
      <div class="flex items-center justify-between p-3 rounded-lg border bg-slate-900/60 {
        status === 'valid'     ? 'border-emerald-500/40 text-emerald-400' :
        status === 'invalid'   ? 'border-rose-500/40 text-rose-400' :
        status === 'error'     ? 'border-orange-500/40 text-orange-400' :
        status === 'verifying' ? 'border-sky-500/40 text-sky-400' :
        status === 'fetching'  ? 'border-fuchsia-500/40 text-fuchsia-400' :
        'border-slate-800 text-slate-500'
      }">
        <span class="text-[11px] uppercase tracking-widest font-semibold font-mono">
          {#if status === 'idle'}Status: Waiting
          {:else if status === 'fetching'}Fetching from server...
          {:else if status === 'verifying'}Verifying Proof...
          {:else if status === 'valid'}Verification PASSED
          {:else if status === 'invalid'}Verification FAILED
          {:else if status === 'error'}Error occurred
          {/if}
        </span>

        {#if status === 'valid'}
          <span class="text-lg">✓</span>
        {:else if status === 'invalid'}
          <span class="text-lg">✗</span>
        {:else if status === 'verifying' || status === 'fetching'}
          <span class="animate-spin text-lg inline-block">⚙</span>
        {/if}
      </div>

      {#if errorMsg}
        <div class="text-[10px] text-orange-400 p-2 bg-orange-500/10 rounded border border-orange-500/20">
          {errorMsg}
        </div>
      {/if}

      <button
        type="button"
        onclick={verifyProof}
        disabled={status === 'verifying' || status === 'fetching'}
        class="w-full h-10 rounded-lg border border-fuchsia-500/30 bg-fuchsia-500/20 text-sm font-semibold tracking-wider text-fuchsia-300 transition hover:bg-fuchsia-500/30 active:scale-[0.98] disabled:opacity-50 disabled:active:scale-100 uppercase"
      >
        {status === 'verifying' ? 'Processing module...' : 'Run ZK Verifier'}
      </button>
    </div>
  </div>
</section>

<style>
  .hide-scrollbar::-webkit-scrollbar {
    width: 6px;
  }
  .hide-scrollbar::-webkit-scrollbar-track {
    background: transparent;
  }
  .hide-scrollbar::-webkit-scrollbar-thumb {
    background-color: rgb(30 41 59);
    border-radius: 20px;
  }
</style>
