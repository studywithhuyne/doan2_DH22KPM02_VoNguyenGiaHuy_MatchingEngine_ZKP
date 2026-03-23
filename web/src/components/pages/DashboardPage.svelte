<script lang="ts">
  import { onMount } from "svelte";
  import { authState } from "../../stores/authStore";
  import { router } from "../../stores/routerStore";
  import { fetchAssets, fetchBalances, fetchLiveTickers } from "../../lib/api/client";
  import type { AssetDto, BalanceDto, LiveTickerDto } from "../../lib/api/client";

  type AssetRow = {
    symbol: string;
    available: string;
    usdtPrice: string;
    changePct: string;
  };

  let selectedAsset = $state("USDT");
  let rows = $state<AssetRow[]>([]);
  let isLoading = $state(false);

  function mergeRows(assets: AssetDto[], balances: BalanceDto[], tickers: LiveTickerDto[]): AssetRow[] {
    const balanceMap = new Map(balances.map((b) => [b.asset, b]));
    const tickerMap = new Map(tickers.map((t) => [t.symbol, t]));

    return assets
      .map((asset) => {
        const balance = balanceMap.get(asset.symbol);
        const ticker = asset.symbol === "USDT" ? null : tickerMap.get(`${asset.symbol}USDT`);
        return {
          symbol: asset.symbol,
          available: balance?.available ?? "0",
          usdtPrice: asset.symbol === "USDT" ? "1.00" : ticker?.last_price ?? "--",
          changePct: ticker?.price_change_percent_24h ?? "0",
        };
      })
      .sort((a, b) => a.symbol.localeCompare(b.symbol));
  }

  function asNumber(raw: string): number {
    const n = Number(raw);
    return Number.isFinite(n) ? n : 0;
  }

  const estimatedBalance = $derived(rows.find((r) => r.symbol === selectedAsset)?.available ?? "0");

  async function loadDashboard() {
    const userId = $authState.userId;
    if (!userId) {
      rows = [];
      return;
    }

    isLoading = true;
    try {
      const assets = await fetchAssets();
      const balances = await fetchBalances(userId);
      const tradable = assets
        .map((a) => a.symbol)
        .filter((s) => s !== "USDT")
        .map((s) => `${s}USDT`);
      const tickers = tradable.length > 0 ? await fetchLiveTickers(tradable) : [];

      rows = mergeRows(assets, balances, tickers);
      if (!rows.some((r) => r.symbol === selectedAsset)) {
        selectedAsset = rows[0]?.symbol ?? "USDT";
      }
    } catch {
      rows = [];
    } finally {
      isLoading = false;
    }
  }

  function openAsset(action: "deposit" | "withdraw" | "transfer") {
    localStorage.setItem("asset_default_action", action);
    router.navigate("/asset");
  }

  onMount(() => {
    void loadDashboard();
  });
</script>

<section class="space-y-4 md:space-y-6">
  <section class="terminal-panel-strong p-6">
    <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
      <div>
        <p class="text-4xl font-semibold tracking-tight text-slate-100">Estimated Balance</p>
        <div class="mt-4 flex items-end gap-2">
          <p class="mono text-5xl font-bold text-slate-100">
            {parseFloat(estimatedBalance).toLocaleString(undefined, { maximumFractionDigits: 8 })}
          </p>
          <select
            bind:value={selectedAsset}
            class="rounded-lg border border-slate-700/80 bg-slate-900/80 px-3 py-2 text-xl text-slate-200 outline-none focus:border-sky-500/50"
          >
            {#each rows as row}
              <option value={row.symbol}>{row.symbol}</option>
            {/each}
          </select>
        </div>
        <p class="mt-2 mono text-xl text-slate-400">≈ ${parseFloat(estimatedBalance).toLocaleString(undefined, { maximumFractionDigits: 2 })}</p>
      </div>

      <div class="grid grid-cols-2 gap-2 sm:grid-cols-4">
        <button type="button" onclick={() => openAsset("deposit")} class="rounded-lg border border-slate-700/80 bg-slate-800 px-4 py-2 text-lg font-semibold text-slate-200 transition hover:border-slate-500">Deposit</button>
        <button type="button" onclick={() => openAsset("withdraw")} class="rounded-lg border border-slate-700/80 bg-slate-800 px-4 py-2 text-lg font-semibold text-slate-200 transition hover:border-slate-500">Withdraw</button>
        <button type="button" onclick={() => openAsset("transfer")} class="rounded-lg border border-slate-700/80 bg-slate-800 px-4 py-2 text-lg font-semibold text-slate-200 transition hover:border-slate-500">Transfer</button>
        <button type="button" onclick={() => router.navigate("/trade-history")} class="rounded-lg border border-slate-700/80 bg-slate-800 px-4 py-2 text-lg font-semibold text-slate-200 transition hover:border-slate-500">History</button>
      </div>
    </div>
  </section>

  <section class="terminal-panel-strong p-6">
    <div class="mb-4 flex items-center justify-between">
      <h2 class="text-4xl font-semibold tracking-tight text-slate-100">Markets</h2>
      <a href="#/asset" class="text-lg font-semibold text-slate-200">More</a>
    </div>

    <div class="overflow-x-auto">
      <table class="w-full text-xl">
        <thead>
          <tr class="border-b border-slate-800/60 text-sm uppercase tracking-wider text-slate-500">
            <th class="py-3 text-left">Coin</th>
            <th class="py-3 text-right">Holding</th>
            <th class="py-3 text-right">Coin Price</th>
            <th class="py-3 text-right">24H Change</th>
            <th class="py-3 text-right">Trade</th>
          </tr>
        </thead>
        <tbody>
          {#if isLoading}
            <tr>
              <td colspan="5" class="py-6 text-center text-sm text-slate-500">Loading market data...</td>
            </tr>
          {:else}
            {#each rows as row}
              <tr class="border-b border-slate-800/30">
                <td class="py-3 font-semibold text-slate-200">{row.symbol}</td>
                <td class="py-3 text-right mono text-slate-300">{parseFloat(row.available).toLocaleString(undefined, { maximumFractionDigits: 8 })}</td>
                <td class="py-3 text-right mono text-slate-200">{row.usdtPrice === "--" ? "--" : `$${asNumber(row.usdtPrice).toLocaleString(undefined, { maximumFractionDigits: 6 })}`}</td>
                <td class="py-3 text-right mono {asNumber(row.changePct) >= 0 ? 'text-emerald-400' : 'text-rose-400'}">
                  {asNumber(row.changePct) >= 0 ? "+" : ""}{asNumber(row.changePct).toFixed(2)}%
                </td>
                <td class="py-3 text-right">
                  <a href="#/trade" class="font-semibold text-amber-300 underline">Trade</a>
                </td>
              </tr>
            {/each}
          {/if}
        </tbody>
      </table>
    </div>
  </section>
</section>
