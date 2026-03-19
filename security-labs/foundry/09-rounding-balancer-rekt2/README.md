# Balancer (rounding direction bug class) — lab

Кейс: Balancer — https://rekt.news/balancer-rekt2

## Эксплойт (3–4 шага)
1. В vulnerable-пуле path `exact BPT out` округляет плату `tokenIn` вниз.
2. При `bptSupply > tokenReserve` маленький `bptOut` можно сминтить за 0 токенов.
3. Обратный path `exact BPT in` ошибочно округляет `tokenOut` вверх.
4. Атакер делает круг: бесплатный mint BPT → burn BPT → получает реальный tokenOut из резерва.

## Баг (1 строка)
Несогласованное направление округления в двух swap-путях (вниз там, где нужно вверх, и наоборот).

## Фикс (1 строка)
Для `exactOut` округлять вход вверх (ceil), для `exactIn` округлять выход вниз (floor) и держать симметрию инвариантов.

## Идея теста в Foundry
`testZeroCostMintThenRoundedUpExitDrainsReserve` доказывает profit на vulnerable; `testRoundTripNoFreeProfit` подтверждает отсутствие бесплатного арбитража после фикса.

## Чеклист (макс 3)
- Зафиксировать политику округления для каждого swap path и не смешивать направления.
- Добавить тесты на edge-кейсы `supply > reserve` и «малые количества» (1–3 unit).
- Проверять, что round-trip одной и той же позиции не генерирует прибыль из воздуха.
