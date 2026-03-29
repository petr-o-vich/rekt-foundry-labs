# 19-oracle-access-control-aevo

1. Case: Aevo — https://rekt.news/aevo-rekt
2. Exploit path:
   - Protocol settles options by an `expiryPrice` set on-chain.
   - Vulnerable setter has no role check, so anyone can post settlement prices.
   - Attacker writes manipulated expiry price and immediately settles position.
   - Pool pays attacker from treasury using fake oracle outcome.
3. Root bug: missing access control on critical oracle settlement write.
4. Fix: strict `onlyOracle` gate + immutable oracle authority (or governed timelock rotation).
5. Foundry test idea: attacker sets malicious expiry price and drains payout in vulnerable contract; same action reverts with `not oracle` in fixed contract.
6. Pre-deploy checklist:
   - Every oracle/settlement setter must be role-gated and tested for unauthorized calls.
   - Separate write authority (oracle) from payout authority (vault) with explicit checks.
   - Emit events for settlement writes and monitor anomalous price updates before payout windows.
