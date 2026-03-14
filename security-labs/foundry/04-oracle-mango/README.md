# Mango Markets (oracle manipulation class) — lab

Кейс: Mango Markets — https://rekt.news/mango-markets-rekt/

## Эксплойт (3–4 шага)
1. Протокол принимает spot-цену из пула как «истину» для залога.
2. Атакер сам двигает цену в этом же тонком рынке.
3. На завышенной цене открывает крупный займ.
4. Цена возвращается, долг остаётся протоколу.

## Баг (1 строка)
Доверие к мгновенной, манипулируемой цене без защиты от thin-liquidity атак.

## Фикс (1 строка)
Использовать TWAP + cap на скачок цены + консервативный LTV.

## Идея теста в Foundry
`testManipulateSpotThenOverBorrow` показывает вывод всей ликвидности на vulnerable; `testBorrowBlockedAfterPriceSpike` подтверждает, что fixed блокирует тот же вектор.

## Чеклист (макс 3)
- Для залога использовать TWAP/median, не spot из одного пула.
- Ввести cap на price deviation за короткое окно.
- Жёсткий max LTV и circuit-breaker на аномалии.
