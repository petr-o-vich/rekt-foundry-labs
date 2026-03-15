# Li.Fi (arbitrary call in bridge executor class) — lab

Кейс: Li.Fi — https://rekt.news/lifi-rekt/

## Эксплойт (3–4 шага)
1. Исполнитель бриджа принимает произвольный `target + calldata`.
2. В нём нет жёсткой авторизации и фильтрации вызова.
3. Атакер подсовывает вызов токена `transfer(attacker, amount)`.
4. Контракт-исполнитель сам подписывает этот вызов своим балансом и отдаёт средства.

## Баг (1 строка)
Неограниченный low-level call без RBAC и без whitelist по target/selector.

## Фикс (1 строка)
Жёсткий relayer-only доступ + whitelist target + whitelist function selector.

## Идея теста в Foundry
`testArbitraryCallDrainsExecutorBalance` подтверждает слив на vulnerable; `testExploitPathBlockedByAuth` и `testRelayerCannotCallUnapprovedSelectorOrTarget` показывают, что тот же вектор в fixed закрыт.

## Чеклист (макс 3)
- Любой `call`-роутер — только через RBAC.
- Разрешать только конкретные target и selectors.
- Для calldata-sensitive потоков добавлять explicit validation параметров.
