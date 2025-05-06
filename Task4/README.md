# Краткое описание
В рамках расширения платформы InsureTech добавлен новый продукт — онлайн-оформление ОСАГО.
Решение реализовано через выделение отдельного микросервиса osago-aggregator, который взаимодействует со страховыми компаниями через REST API и обрабатывает поступающие предложения асинхронно.

## Компоненты архитектуры 
- osago-aggregator
1) Отвечает за:
    - Отправку заявок в страховые компании (/create)
    - Опрос предложений (/getOffer)
    - Публикацию событий с предложениями (OsagoOfferReceived)

2) Задеплоен в двух экземплярах:
    - В зоне A — активный
    - В зоне B — пассивный (standby, включается при отказе)

3) Хранилище заявок: osago-db (PostgreSQL или Redis)
Используется для:
    - хранения статусов заявок,
    - временного кэширования результатов,

- core-app
    - Принимает запросы от фронтенда
    - Отправляет заявку в osago-aggregator (через REST)
    - Подписан на Kafka-события (OsagoOfferReceived)


### Особенности масштабирования и надёжности
    - Все сервисы задеплоены в двух зонах доступности (Active-Passive).
    - osago-aggregator присутствует и в A, и в B, с failover-переходом.
    - Используется Kafka как асинхронная шина, чтобы избежать блокировок и обеспечить масштабируемость по RPS.

#### Ссылка на draw.io
https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=%D0%94%D0%B8%D0%B0%D0%B3%D1%80%D0%B0%D0%BC%D0%BC%D0%B0%20%D1%81%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%BC%20%D1%81%D0%B5%D1%80%D0%B2%D0%B8%D1%81%D0%BE%D0%BC%20%D0%B1%D0%B5%D0%B7%20%D0%B7%D0%BE%D0%BD%20%D1%81%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%BC%20%D1%81%D0%B5%D1%80%D0%B2%D0%B8%D1%81%D0%BE%D0%BC.drawio&dark=auto#R%3Cmxfile%3E%3Cdiagram%20name%3D%22%D0%A1%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0%20%E2%80%94%201%22%20id%3D%22bx8_xxog-MDYi9NOV8Kx%22%3E7V1bk6O2Ev41rsw%2BeAtx59GXmc0mu9nJTqqSnDdsyzZZbBzAc8mvPxKSsARijD3cxma3ymMLIUDd6v76omagTTbPn0J3t%2F4aLKA%2FUJXF80CbDlRV13QH%2FcEtL6QF6JpFWlaht6Bth4YH7z9IGxXauvcWMBI6xkHgx95ObJwH2y2cx0KbG4bBk9htGfjiVXfuCuYaHuaun2%2F901vEa9Jqq9ah%2FWfordbsysCkTzxz5z9WYbDf0usNVO0u%2BUcOb1w2Fn3QaO0ugieuSbsdaJMwCGLybfM8gT6eXDZt5Ly7gqPpfYdwG5c5YfW0%2FP15Mf0L%2BsH2fz%2Fb8X%2BPwbehrdKbi1%2FYhMAFmh%2F6MwjjdbAKtq5%2Fe2gdJw8N8bAK%2BnXo8yUIdqgRoMZ%2FYBy%2FUGK7%2BzhATet449Oj8NmL%2F8KnfzTor7%2B5I9NnOnLy44X92MbhC3cS%2Fvk3f%2BxwWvKLnZefJjpzUbAP5%2FCVuaFTE7vhCsav9DNJPzxv3AUoET7BYAPR%2FaAOIfTd2HsU%2Bc6l7LtK%2Bx1IiL5QKp5AUXrXj66%2Fh4wxMxQW6fe09mL4sHOTuXhCq1ykVeH8PcIwhs%2BvPjE9qpk6OYXJCJsuiafDggMKbVtzi81Qapok0MFJUk1xkhTJJFlmfpLMuibJ1nrZUDQ3eknZoHZKNugStjd9dP%2FjhfcoUNr8d4%2F10vig5IbzwA%2FCgTbCd7ua3WiI7dBdKBqgf%2FUPyYwqmX7AtkkH4Cjsi0m6sougbyv6N7mZXQilN7MMtvFw6W48HxFw9NMvMB6HrreNUOevwTb4CQ2%2FQX8jskxJ9yjhsxHS2RN7F8svi3jBucOf49vkE7WAgT1Jvltcu5p8KslR8t0Q%2BtPbR6RJnqDdhzqHsBqAYIn5c8y1zeYzONc7Ra2Rnsy4wtFmmqPKNPlEN066jRip0KctdktOVJWb5Dfghiak1jhGMMjRD6%2FTGrUm855rLdE3I3GR9ohFAen63mqLvs%2BR0IKIRmOsYzwEaEf0wMZbLBJZLFNaonyuQbk7JXW7ZdQk5IxCIYdYbXuClPPxzQ4XbvjjBi2DZfKPSLBHN7wZDlcwOUhPSQ7gJaTi%2Fx%2FkEm4y%2FY2jO7mfd0t4O4PqJJQ3JYTXasMrIDeJPV4RbZSjeAVonQIsZgdxekbepUZKa8aMVQ2qew%2FKf3T%2FGY3wyY3hk%2Fty4Xo1I15TWdqWeAUyo7m3Hthlcf%2Fi69KB8P0bu%2BdC3saWiCWi2gSGUgyrs0MIgwIGeFOEesedkumTYF5Vwde%2FGc2x3P6QX0TkCcSnmoXXgWKH6Vpiy81qebmpTitopnFkwhDHcWjidAqasPvuFDbRRJ2hqRJsYjTpQwS9y6ky78ylzQFWdpOcsrM5nXXL%2BWJs2qdLTrb7EC%2BTNdxHie1%2Fh7Fp6C7drdv7h4pwrKYZ7SpWvQ95FoOOssqYBfk7ooxVmTK%2BUBv48zbah%2FAPOF%2Bjgf6Es05JRGHW21cvfDwADJmVlNEpY04HmbkAAosVNCXQD5IGHMeMS8%2F3J4RT0bnawoX2co7aozgMfkDuiDm34WxZka0EFEMQ6bqeF%2BlAlcj02mCmal%2BHsVTWjat2y41rtJxJoJ6lc62GiMp06VGq6t2ygA29XapaXUZSpYnKwgIdISpoye%2FEqMqRlFu3R6gKBJoeSNweVQEwOkVWraIg0aX5IPo5QJZOCIfubtddO%2BKSrLfELLmVZRqRltTrpXJZS2kAyOLSku64nLRb2pkkoRzMHI0blk99GnHjmJzb7S45nUSO0mHJfY6FWBL%2BdOqziS7cfjKdj6IFZUiSCFQG9xqxoHSlVxDXJIfQCOiON7thhHCZDzcwif12VAG0LrFHfD4okYcW%2FnT4KPxYFL%2Bp%2FNS5FpuTrhnZzsf6y0hgIq57CXxOTOK4%2F0qVpXDVFybV2vWQDE42pDMml1WfzcWI00JMIjl1FIY4TSbtsAu8bRxxI9%2FjhkFhEN5wjAx%2FkBEP3JLe2hvUtyzruWPZCLpeMhsB1JcqqeRmpfOOyMxKU2tcaWXdyx3zWemyNOEeu%2FZz0M8Bf9nSGapmQYbqr%2B7yB5%2FZIksY7ZTx8OYnfsfsg%2B0I1XQ3WK%2FTDtnpzR4n1%2BcnvMAaykTJUwuI92XxmyinzH457jVq%2FeEEt9wtZ6jRrX8y%2B4y30pyCDIJzvWXlF1lL5l73M9AY7nwVh0rMPaDXtkex97ZdnbdtFwaL%2FTweuqtVCFdujPeMdlBndsPh5hD5q3Gy2GAtr0cu%2BE36CtdB5yS1eprA6%2F1m7KjoNzMN66Mk88tq0nNmqr0krQIB2wUI%2BPvtwx%2BVoBE5ajjC5TkkUQETp74y5p%2BTFNqRoYH6nFLOcd9d9ORtfHcLkxXuhjH1NSlnSYKFG61TOUO6sdJnRkVzbKki5tKARFBIQZeh1zbP15Yk7m7n8Dv8dw%2BjeBJCN0Y0r3%2FJ5rnndaYvzVN2BsanFQR5lmKb83mOqo2hgGzhXihD%2FbqfwXALY4gHmvj7CMvjZEdxj2GLMCy%2FfY33IQCZy0SKZ9MTi4ocOZyfwcg5LmrEudkoiu97u6jIpK8Yt1YkULQMEEi3LPACxZaoKKcugaJXJFAuDMzOfQ%2FRfuhtl0F3xc0lCfvEyZsWlcg4dlUum1C6UapcvbXDgBNWn%2BJCkhfbNuurEo9KBsLLchQbtfWNPon9um39ijjbAhnObtsDYNg9Y%2FeM%2FXbGTtPIU8bOe10aZWygVORzuXbOLioa9st0PLkGztazKbuSangyzq7P96MU15ntObvn7NKcbTIvIuNsCcxumLP7dMqes6tw2KsZmS0pqdgoZ5tXFABKHNCn7EJKeLa9sFFzbOmU8Ws0K3FBjyWuyr8aRO4qGI5KJoKd4ovsKVSh%2BLQ4J%2FWdGFxLo3h4YbFYm%2FJqdM8QAnOHhOjUY86kNflJigSMwCEbztFoe%2B%2B5PpKmZokSPn0FX4v7O%2FuE30owddFGjW9Yon5bLmH4Hc6h9yhglotF2CljpwmZOT4Hstqq9SEZtuWz5%2FN6bMeTYX2uuMB1rhTbyagEyVJJSw43tFT6ZI%2FezVJF0CdjzkrqazdrzfalhKph7GuPZmbAjSw9r%2BFgppqbs0arR9hGufIRQ%2F2jxnrew9BDj48pJZaV4CtJ1FsKlb0A4HjRTIUO2ZG6EnYPZmWXvQ%2BieBXCh9%2B%2F4IFcmgl%2BMzryUtTeNVV5ajngsD3%2FiuIp53ZiieQO8SQl78O9VbFryknfjZtmbGaSJMXRmnI7RWt3h7%2FOX3wPic5QO66UZkTIfpmlDSl1v%2B1jNAyk7WR%2BpwCLvpaKP2a2sTiSbSzp1hZhN7pal2Kz26me%2F7Y3ouDN%2BSXVF1OHuCGrD89XayxZ%2F6haY2qkK1qt3QLf51HbNC2e2kPlo6IcK4RVMb0Zrnxv9HZafS0yOJ3aANE2U%2FRM15ultf5ead3yizbOWtu6oYvUVlSrWXKXLuvfMXKnBtO1ZLSMjNx2JH7z0Zhzg7M6TGpaWh01TsUNRJlCvWp3DZjWZ16oWZ9uZs1YDbwlQmaexL1PJVnj8e1mCqJmkD9Q7Dz0b%2Fj1rErv4rjuIMTpNYAyyRVOSbdsjYG0Vt2yPMAt%2F8YiAeSQU23V6Sjq0bv1LiOg9emStScZjM5OY%2BMLVkw4jJXX%2FfZZkvHdzuqlAnMSj1RG958HtDLr3TzJG6c7%2BtU7JF6SjJMzkV1lWrNpwDd0Mmknss09qWZspMQI0MxWXQRnacvmSuCnqfjHg5Va17RiXx2hVvlNkvYXs15pXYLSEoLYeOWpyne48KLaVdT1epEqhadnOwKPvkKx%2FO6L83FJHx0vAkyZbEaz7NaN%2Bt4ZBLR2w%2BODk0MqIlx6BStZNYTFT0FQlb%2Bw642Jqy3n9wlvh1LK0bq5NL7yhGXvY6qdruhnGGDdkB77hITf%2BmuwgLjH%2FwE%3D%3C%2Fdiagram%3E%3C%2Fmxfile%3E

#   #   #   #   #   #   #   #   #   #   #   #   #   #   #

## Новый сервис: osago-aggregator
Назначение: отправляет заявки ОСАГО в страховые компании и асинхронно опрашивает ответы.

## Хранилище: osago-aggregator-db
    - Хранения промежуточных данных (отправленные заявки, stateless ответы).
    - Обеспечения повторного запроса при сбоях.
Причина: при пиковой нагрузке нужно устойчивое хранение состояния между шагами "отправка к получению ответа".


##  Интеграция с core-app
    - REST API: core отправляет заявку на ОСАГО ? osago-aggregator.
    - Паттерны: Timeout, Retry, Circuit Breaker для вызовов к страховым.
    - Kafka: когда osago-aggregator получает ответ от страховой — публикует событие OsagoProposalReady в Kafka.
    - core подписан на эти события

## Интеграция с внешними страховыми
osago-aggregator вызывает две REST ручки у каждой страховой:
    - POST /createRequest
    - GET /getProposal