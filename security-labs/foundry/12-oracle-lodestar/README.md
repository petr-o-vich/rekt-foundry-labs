# Lodestar Finance (oracle manipulation class) — lab

Кейс: Lodestar Finance — https://rekt.news/lodestar-rekt/

## Эксплойт (3–4 шага)
1. Протокол принимает цену collateral-актива из манипулируемого источника.
2. Атакер раздувает spot-цену collateral перед borrow.
3. Система считает завышенный `maxBorrow` и выдаёт лишнюю ликвидность.
4. После отката цены долг остаётся недообеспеченным, убыток у пула.

## Баг (1 строка)
Borrow лимит рассчитывается по одиночной manipulable spot-цене без sanity checks.

## Фикс (1 строка)
Использовать cap на рост collateral-цены (TWAP/anchor + maxIncreaseBps) и считать LTV только от capped price.

## Идея теста в Foundry
`testExploitBorrowsAgainstInflatedCollateralPrice` показывает избыточный займ на vulnerable; `testBorrowBlockedByCollateralPriceCap` подтверждает блокировку на fixed.

## Чеклист (макс 3)
- Для collateral-price использовать anchor (TWAP/Chainlink) + отклонение в bps.
- Ограничивать рост цены collateral за update (cap/rate limit).
- Держать regression-тест на сценарий «single-block collateral pump before borrow».
