# 18-delegatecall-furucombo

1. Case: Furucombo — https://rekt.news/furucombo-rekt
2. Exploit path:
   - Proxy exposes generic `execute(target, data)` and uses `delegatecall`.
   - No target allowlist, so attacker points to malicious module.
   - Module "initialize" logic writes attacker address into proxy owner slot.
   - Attacker calls privileged `sweep` and drains funds.
3. Root bug: untrusted delegatecall target can mutate proxy storage (owner takeover).
4. Fix: strict target allowlist for delegatecall modules + owner-only trust management.
5. Foundry test idea: replay attacker delegatecall payload and assert it reverts with `target not trusted` on fixed contract.
6. Pre-deploy checklist:
   - Delegatecall only to explicitly allowlisted audited modules.
   - Keep privileged entrypoints behind explicit role checks.
   - Alert on trust-list changes and emergency pause on anomalies.
