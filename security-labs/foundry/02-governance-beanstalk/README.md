# 02-governance-beanstalk

Кейс: Beanstalk (flash-loan governance hijack) — https://rekt.news/beanstalk-rekt

## Exploit path
1. Атакующий берёт flash loan governance-токена.
2. В том же tx получает временный баланс выше порога голосования.
3. Сразу вызывает `executeDrain()` без задержки/снэпшота.
4. Treasury переводит средства атакующему, после чего loan возвращается.

## Root bug
Голосование/исполнение опиралось на мгновенный `balanceOf` и позволяло исполнение в том же tx.

## Fix
Делать lock+snapshot voting power и обязательный timelock между proposal и execute.

## Foundry test idea
Один тест должен показать drain через flash loan на `VulnerableGovernance`; второй — что тот же путь на `FixedGovernance` ревертится из-за timelock.

## Pre-deploy checklist
- Нельзя исполнять governance-действия в tx, где получен voting power.
- Voting power фиксируется (snapshot/lock), а не читается из live `balanceOf`.
- Критичные действия только через timelock + мониторинг очереди.
