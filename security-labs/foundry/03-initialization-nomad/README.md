# Nomad Bridge (initialization bug class) — lab

Кейс: Nomad Bridge — https://rekt.news/nomad-rekt/

## Эксплойт (3–5 шагов)
1. Контракт допускает публичный `initialize` без `initialized` guard.
2. Атакер ставит `trustedRoot = 0x00` (или любой удобный root).
3. Делает фейковое `messageHash` и вызывает `relay(...)`.
4. Проверка `providedRoot == trustedRoot` проходит, деньги уходят атакеру.

## Баг (1 строка)
Неправильная инициализация trust root: публичная реинициализация + отсутствие запрета на нулевой root.

## Фикс (1 строка)
`initializer` only-once + `onlyOwner` на root management + запрет zero root + ограниченный relayer + replay-protection.

## Идея теста в Foundry
`testAnyoneCanSetZeroRootAndDrain` доказывает drain на уязвимом контракте; `testAttackerCannotReinitializeOrRelay` и replay-check блокируют тот же путь в fixed.

## Чеклист (3 пункта)
- Инициализация строго один раз, с non-zero параметрами.
- Root update только через RBAC/тимлок и аудитируемые события.
- Relay доступен только доверенному модулю + анти-реплей по уникальному message id.
