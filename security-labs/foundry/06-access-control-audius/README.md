# Audius (governance takeover class) — lab

Кейс: Audius — https://rekt.news/audius-rekt/

## Эксплойт (3–4 шага)
1. Governance-контракт инициализируется `initialize(guardian, treasury)`.
2. В vulnerable-версии инициализация не защищена от повторного вызова.
3. Атакер повторно вызывает `initialize`, ставит себя guardian.
4. Через privileged-функцию `emergencyTransfer` выводит токены из treasury-контракта.

## Баг (1 строка)
Повторно вызываемая инициализация позволяет перехватить привилегированную роль.

## Фикс (1 строка)
One-time initializer (`initialized` guard) + строгая проверка привилегий.

## Идея теста в Foundry
`testReinitializeHijacksGuardianAndDrainsFunds` показывает takeover на vulnerable; `testReinitializeBlockedAndDrainDenied` подтверждает, что fixed ломает тот же путь.

## Чеклист (макс 3)
- Все `initialize`/`setUp` функции — строго one-shot.
- Привилегированные роли не должны меняться без governance-процедуры.
- Для critical ролей добавить тест «повторная инициализация невозможна».