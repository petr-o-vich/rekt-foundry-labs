# Ronin Bridge (validator takeover class) — lab

Кейс: Ronin Bridge — https://rekt.news/ronin-rekt/

## Эксплойт (3–4 шага)
1. Контракт моста хранит набор валидаторов и порог подписей для вывода.
2. В vulnerable-версии `addValidator` открыт для любого адреса.
3. Атакер добавляет свои 5 адресов в validator set.
4. Формирует «валидные» подписи своим набором и выводит всю ликвидность.

## Баг (1 строка)
Критический апдейт validator set без контроля доступа.

## Фикс (1 строка)
Ограничить изменение validator set только governance/owner (+ желательно timelock/multisig).

## Идея теста в Foundry
`testUnauthorizedValidatorInjectionLetsAttackerDrainBridge` показывает полный drain на vulnerable; `testFakeSignerSetCannotDrainFunds` подтверждает блокировку атаки на fixed.

## Чеклист (макс 3)
- Любые функции управления валидаторами/кворумом — только через строгий RBAC.
- Порог подписей и состав валидаторов менять только через timelock.
- Тестировать сценарий «attacker tries to self-authorize signers» как обязательный regression.
