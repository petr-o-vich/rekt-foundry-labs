# 17-signature-replay-1inch

1. Case: 1Inch — https://rekt.news/1inch-rekt
2. Exploit path:
   - Maker signs one off-chain order for a bounded token amount.
   - Router verifies signature but does not consume an order nonce.
   - Attacker replays the same signed payload multiple times.
   - Vault balance is drained through repeated "valid" fills.
3. Root bug: signed order authorization is replayable because nonce/UID is never marked used.
4. Fix: enforce one-time order consumption via `used[orderHash]` before transfer execution.
5. Foundry test idea: execute the same signed order twice and prove the second fill reverts on fixed contract.
6. Pre-deploy checklist:
   - Enforce nonce/UID invalidation on first successful fill.
   - Domain-separate signed payloads (chainId + contract + expiry).
   - Monitor repeated fill attempts for same order hash.
