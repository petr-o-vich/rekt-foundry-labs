# bZx (oracle manipulation class) — lab

Кейс: bZx — https://rekt.news/bzx-rekt/

## Эксплойт (3–4 шага)
1. Протокол считает залог по spot-цене из источника, который можно быстро сдвинуть.
2. Атакер разгоняет spot-цену collateral в коротком окне.
3. `maxBorrow` становится завышенным, протокол выдаёт лишнюю ликвидность.
4. После нормализации цены позиция фактически недообеспечена, убыток фиксирует пул.

## Баг (1 строка)
Borrow-лимит зависит от одиночной манипулируемой spot-цены без проверки отклонения.

## Фикс (1 строка)
Проверять spot против anchor/TWAP и блокировать borrow при отклонении выше лимита (deviation cap).

## Идея теста в Foundry
`testExploitBorrowsAgainstManipulatedSpotOracle` показывает дренаж на vulnerable; `testBorrowBlockedWhenSpotDeviatesFromAnchor` подтверждает, что fixed режет ту же атаку.

## Чеклист (макс 3)
- Для collateral-оракула: anchor/TWAP + лимит отклонения в bps.
- Не принимать single-block spikes при расчёте LTV.
- Держать regression-тест на сценарий «pump before borrow».
