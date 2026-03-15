<script>
  import { orderBook } from "../../stores/orderBookStore.js";
</script>

<section class="terminal-panel-strong p-4 sm:p-5">
  <div class="mb-4 flex items-center justify-between">
    <h2 class="text-lg font-semibold text-slate-100">OrderBook</h2>
    <span class="mono text-xs text-slate-400">Top 10 depth (live)</span>
  </div>

  <div class="grid gap-3 sm:grid-cols-2">
    <div class="rounded-xl border border-emerald-400/20 bg-emerald-500/5 p-3">
      <p class="mono mb-2 text-xs tracking-wide text-emerald-300">BIDS</p>
      <ul class="space-y-1 text-sm">
        {#each $orderBook.bids.slice(0, 10) as bid}
          <li class="flex justify-between text-emerald-200">
            <span>{bid.price}</span>
            <span class="mono">{bid.amount}</span>
          </li>
        {/each}
        {#if $orderBook.bids.length === 0}
          <li class="text-slate-500 text-center italic text-xs py-2">No bids</li>
        {/if}
      </ul>
    </div>

    <div class="rounded-xl border border-rose-400/20 bg-rose-500/5 p-3">
      <p class="mono mb-2 text-xs tracking-wide text-rose-300">ASKS</p>
      <ul class="space-y-1 text-sm">
        {#each $orderBook.asks.slice(0, 10) as ask}
          <li class="flex justify-between text-rose-200">
            <span>{ask.price}</span>
            <span class="mono">{ask.amount}</span>
          </li>
        {/each}
        {#if $orderBook.asks.length === 0}
          <li class="text-slate-500 text-center italic text-xs py-2">No asks</li>
        {/if}
      </ul>
    </div>
  </div>
</section>
