# 16-oracle-inverse-finance

1. Case: Inverse Finance — https://rekt.news/inverse-finance-rekt/
2. Exploit path:
   - Attacker posts a small amount of collateral.
   - Attacker manipulates the spot price used by lending logic.
   - Protocol recalculates borrow power from manipulated spot.
   - Attacker borrows far above real collateral value and drains liquidity.
3. Root bug: collateral valuation trusts a manipulable single-block spot oracle.
4. Fix: consume oracle data through bounded updates (rate-limited price sync) before borrow checks.
5. Foundry test idea: replay the same manipulated-spot sequence and prove oversized borrow reverts on fixed contract.
6. Pre-deploy checklist:
   - Enforce oracle consumer safeguards (TWAP / bounded update / staleness guards).
   - Cap per-account borrow growth between oracle syncs.
   - Alert on abnormal oracle deltas and auto-pause borrowing.
