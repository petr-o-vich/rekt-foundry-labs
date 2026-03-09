# 01-reentrancy-cream

Кейс: Cream Finance (reentrancy class) — https://rekt.news/cream-rekt/

## Exploit path
1. Атакующий получает баланс в уязвимом vault/рынке.
2. Вызывает `withdraw()`.
3. Контракт делает внешний `call` до обновления состояния.
4. Через `receive()` атакующий делает re-enter и повторно withdraw, пока баланс не обнулён.

## Root bug
Нарушение CEI: внешний вызов до обновления внутреннего учёта.

## Fix
CEI + `nonReentrant` + проверка достаточности баланса до перевода.

## Foundry test idea
Один и тот же attacker-контракт должен:
- успешно выкачать лишние средства из `VulnerableVault`;
- не суметь повторить это на `FixedVault`.

## Pre-deploy checklist
- Все изменения стейта происходят до external call.
- Все функции вывода/клейма защищены от reentry.
- Есть тест со злонамеренным receiver-контрактом.
