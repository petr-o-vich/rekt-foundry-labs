# Harvest Finance (slippage/oracle manipulation class) — lab

Кейс: Harvest Finance — https://rekt.news/harvest-finance-rekt/

## Эксплойт (3–4 шага)
1. Стратегия продаёт большой объём актива в AMM и не проверяет минимальный acceptable output.
2. Атакер временно двигает цену в пуле (flash-loan style manipulation).
3. Стратегия исполняет swap по искусственно плохому курсу.
4. Хранилище получает сильно меньше стейбла, убыток остаётся у пользователей.

## Баг (1 строка)
Отсутствие slippage-ограничения при trade execution по манипулируемой on-chain цене.

## Фикс (1 строка)
Проверять `minOut` относительно референс-цены (oracle/TWAP) и отклонять сделку при превышении slippage.

## Идея теста в Foundry
`testPriceManipulationDrainsValueViaBadSwap` показывает потерю value на vulnerable; `testManipulatedPriceRevertsOnSlippageGuard` подтверждает блокировку атаки на fixed.

## Чеклист (макс 3)
- Каждый swap в стратегиях должен иметь детерминированный `minOut`.
- `minOut` считать от oracle/TWAP, не от текущей spot-цены пула.
- Добавить regression-тест на сценарий «price pushed right before harvest». 
