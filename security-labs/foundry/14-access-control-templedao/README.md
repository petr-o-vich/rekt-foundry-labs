# TempleDAO (access control class) — lab

Кейс: TempleDAO — https://rekt.news/templedao-rekt/

## Эксплойт (3–4 шага)
1. В treasury есть функция миграции средств для операционных переводов.
2. Функция не ограничена по роли (нет `onlyOwner`/RBAC проверки).
3. Любой внешний адрес вызывает миграцию на свой кошелёк.
4. Treasury уходит в ноль одной транзакцией.

## Баг (1 строка)
Критическая функция перевода средств доступна любому вызвавшему (missing access control).

## Фикс (1 строка)
Ограничить миграцию строгой ролью (`onlyOwner` или RBAC) и держать тест на неавторизованный вызов.

## Идея теста в Foundry
`testExploitUnauthorizedMigrateDrainsTreasury` на vulnerable подтверждает дренаж; `testUnauthorizedMigrateReverts` на fixed подтверждает блокировку того же пути.

## Чеклист (макс 3)
- Все admin/treasury-функции закрыты `onlyOwner`/RBAC.
- Изменения ролей только через timelock/multisig.
- Regression-тесты на каждый privileged entrypoint.
