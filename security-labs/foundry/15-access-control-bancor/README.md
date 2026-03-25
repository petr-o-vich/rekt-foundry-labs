# Bancor (access control class) — lab

Кейс: Bancor — https://rekt.news/bancor-rekt/

## Эксплойт (3–4 шага)
1. В хранилище есть emergency-функция вывода ликвидности.
2. Привилегированный путь вывода открыт внешнему вызову без проверки роли.
3. Атакер вызывает функцию напрямую и переводит средства на свой адрес.
4. Баланс vault обнуляется одной транзакцией.

## Баг (1 строка)
Критический withdraw entrypoint оставлен публичным без `onlyOwner`/RBAC.

## Фикс (1 строка)
Закрыть emergency-вывод строгой проверкой роли (`msg.sender == owner` / RBAC) и закрепить regression-тестом.

## Идея теста в Foundry
`testExploitPublicEmergencyWithdrawDrainsVault` подтверждает дренаж на vulnerable, `testUnauthorizedEmergencyWithdrawReverts` блокирует тот же путь на fixed.

## Чеклист (макс 3)
- Все emergency/admin функции покрыты `onlyOwner` или RBAC.
- Любые изменения ролей — только через timelock/multisig.
- На каждый privileged entrypoint есть негативный тест для неавторизованного вызова.
