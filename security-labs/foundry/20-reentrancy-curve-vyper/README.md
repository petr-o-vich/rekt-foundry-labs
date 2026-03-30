# 20-reentrancy-curve-vyper

1. Case: Curve (Vyper compiler reentrancy wave) — https://rekt.news/curve-rekt/
2. Exploit path:
   - Pool exposes an ETH withdrawal path vulnerable to reentrancy.
   - Attacker deposits seed capital and triggers `withdraw`.
   - Fallback re-enters `withdraw` before balance accounting is finalized.
   - Contract pays multiple times from shared pool liquidity.
3. Root bug: external call before state update (classic reentrancy window).
4. Fix: CEI ordering + explicit `nonReentrant` lock on withdrawal.
5. Foundry test idea: attacker drains extra ETH from vulnerable pool via fallback recursion; same flow fails on fixed pool and funds stay intact.
6. Pre-deploy checklist:
   - Every payout path must update state before external calls.
   - Add `nonReentrant` on user-triggered value transfer entrypoints.
   - Fuzz repeated callback paths for invariant: total user credits ≤ pool assets.
