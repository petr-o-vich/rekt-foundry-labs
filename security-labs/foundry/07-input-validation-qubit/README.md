# Qubit Finance (deposit validation bypass class) — lab

Кейс: Qubit Finance — https://rekt.news/qubit-rekt/

## Эксплойт (3–4 шага)
1. Мост/депозитный контракт минтит wrapped-актив после `deposit(token, amount)`.
2. В vulnerable-версии для `token == address(0)` нет проверки `msg.value`.
3. Атакер вызывает `deposit(address(0), hugeAmount)` с нулевым `msg.value`.
4. Контракт минтит synthetic токены «из воздуха» без реального депозита.

## Баг (1 строка)
Отсутствие строгой валидации входных параметров (`token`, `msg.value`, `amount`) в deposit-флоу.

## Фикс (1 строка)
Жестко валидировать native-ветку (`msg.value == amount && amount > 0`) и не минтить до подтвержденного поступления актива.

## Идея теста в Foundry
`testMintFromThinAirViaZeroAddressDeposit` доказывает free mint на vulnerable; `testZeroValueNativeDepositBlocked` подтверждает блокировку в fixed.

## Чеклист (макс 3)
- Для native-депозита всегда сверять `msg.value` и `amount`.
- Минтить receipt/wrapped токен только после фактического зачисления.
- Отдельный негативный тест: `token=0x0`, `msg.value=0`, `amount>0` должен падать.
