# Проблемы и риски в текущей архитектуре
    - Синхронные вызовы между сервисами (REST):
    - core-app и ins-comp-settlement делают синхронные REST-запросы к ins-product-aggregator, который, в свою очередь, синхронно запрашивает внешние страховые API.
    - Это создаёт «цепочку ожидания» → если хотя бы один страховой API отвечает медленно или падает, все верхнеуровневые вызовы тоже зависают.

## Проблемы и риски в текущей архитектуре
Синхронные вызовы между сервисами (REST):
- core-app и ins-comp-settlement делают синхронные REST-запросы к ins-product-aggregator, который, в свою очередь, синхронно запрашивает внешние страховые API.
- Это создаёт «цепочку ожидания», если хотя бы один страховой API отвечает медленно или падает, все верхнеуровневые вызовы тоже зависают.

Рост количества партнёров. Сейчас 5 страховых компаний, планируется ещё 5.
- Это удвоит число внешних вызовов в рамках одного REST-запроса, что увеличит задержки и риск таймаутов.

Запросы раз в 15 минут и сутки → stale data:
- При ошибках API или сетевых сбоях возможны неполные/устаревшие данные в core-app и ins-comp-settlement.

### ИТОГ
- Устранение зависимости от синхронных вызовов.
- Улучшение отказоустойчивости и масштабируемости.
- Повышение актуальности данных.
- Подготовка архитектуры к масштабированию на большее количество партнёров.

# Ссылка на draw.io
В первй части задания, я уже решил сразу построить верную структуру и общение в микросервисом по средством Event-Driven архитектуры
https://viewer.diagrams.net/?tags=%7B%7D&lightbox=1&highlight=0000ff&edit=_blank&layers=1&nav=1&title=%D0%94%D0%B8%D0%B0%D0%B3%D1%80%D0%B0%D0%BC%D0%BC%D0%B0%20%D1%81%20%D0%BD%D0%BE%D0%B2%D1%8B%D0%BC%20%D1%81%D0%B5%D1%80%D0%B2%D0%B8%D1%81%D0%BE%D0%BC%20%D0%B1%D0%B5%D0%B7%20%D0%B7%D0%BE%D0%BD.drawio&dark=auto#R%3Cmxfile%3E%3Cdiagram%20name%3D%22%D0%A1%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0%20%E2%80%94%201%22%20id%3D%22bx8_xxog-MDYi9NOV8Kx%22%3E7V1Zc6O4Fv41rkk%2FOMW%2BPHpJepbu6Uxnqmb6vsm2jJnG4BE4y%2Fz6KyEJC5BjkmaLTVJlw0EI%2BZyj7yxaGOmz7dNHBHabz9EKBiNNWT2N9PlI03RdV%2FAXoTxTiqrrBqV4yF8x2oFw7%2F8HGZHd6O39FYxzBZMoChJ%2FlycuozCEyyRHAwhFj%2Fli6yjIP3UHPFgi3C9BUKb%2B5a%2BSDaU6mn2g%2Fwx9b8OfrFouvbIAy%2B8eivYhe95I02%2FTP3p5C3hd7IfGG7CKHgWSfjPSZyiKEnq0fZrBgDCXs43ed3vkatZuBMOkyg3e4%2FqPp9X8bxhE4f9%2BdpL%2FHqIvY0djjUueOUPgCvOHnUYo2UReFILg5kCdpj8akmoVfHYo8ymKdpioYuI%2FMEmembDBPokwaZNsA3YVPvnJ3%2BT2a5OdfROuzJ9YzenJMz8JE%2FQs3EROv4nXDrelZ%2Fy%2BMpsY5%2BJoj5bwBd4w1iQAeTB5oZxFyxG%2BCQ9gQvgIoy3E7cEFEAxA4j%2Fk9Q4w9fWycgcR4gMmxVdIlLX6AQR7yBWzIOG8%2FB43fgLvdyDlxSPu5XlZHeXfA0QJfHrxF3OUsBgkcIxwWJd4PHQ4VWG0jdDZTKUhJqk9ZJJm5ZmkSJhkW2UmWU0xydEHbDjGG6MiNmi9wgZDovZWgNs%2FXfkPOUlb%2F%2B6JXZoejNx4GQURGukT0lpvcUUMP26Foqvs2%2FiQclQplFMdhxZQXYUfWLQofwg%2B8th32pgdgtLGrKMwGa%2FB1g%2BwACc%2F%2FQqTKQJ%2BGOPCn6Mw%2BglXv8XfMe2mtHic6tkE2%2ByZs0vkj8W64N6Sz%2BlN%2Bokp6siZpce2QNfSTyW9So%2FNXHnWfCya9Bd0%2B6PeIlhdheqa6OdUoC2WC7g0eiWtiZFyXBFkMy9JZZ5%2B4obTYhMuKvzp5IulN2rKVXquClVTUeuCIpj06oeXZY2pKd9L1AplC4iLrUeSB0gQ%2BF6Ij5cYtCCW0ZTYGB87tBN2YeuvVikWy4xWHp8bMO5uRdtumw2BnHkU5LCqha9AuYA0drwC6PsV7gbr9I8i2ANAV%2BOxB9OL7Jb0AulCGvn%2FIEe42fx3Qe60Pe9W8E7Bq5NI3pIIXm%2FMX1FLTBz8lXyMctJfUfVeOSxWD%2F30At5lQUpnwYxdj1f3Hoz%2F5O4XXMNHkMBH8HzmdrUArxmWdgWvmtsJvLYOlRwCT2Ol2yus5O3uFVjqeSXWNQlYmm0mNdQhBq4tXDw3HpA8wCwfU9JgMYssb4Tg0GFl%2BhT13yHSTTZwH6fByC0xlgisQQiGgPWYYdV1s1vDagxjMMedjqrGWLd7ZYw1mTE%2BU6f8lzDeI%2FgnXG5wRX%2FBRa8QMcf17s2LmKBUx%2BnXbcmmTAUbZJUymjx52RagH5BGPe0zrv0gmFFNxffqKwCd9RLT4wRF36FwxVo6cLGuB9HHqmLmIN0wypCuahJMb8zN1JzLCJaq5pW0fuWVzI6HNrU32Vy7JaFyW3pSqka%2FImDT6Faqdp89qcpC5XnKnghVrym9eW7B6sAD7BIjOAa7XX8dznNy81P%2F9UY2Rk4pWXpEE8bblREbfreFAfVbYTbFDStMh08P%2FrAuVCsO2k%2BEeiwhP3Ob3o4PVKFa2s6p0Cpaiduc83zmjrblXuddbVMy%2FKVxv6AVV9tQBgNxSTiEa8At3u7GMXbLArgl6txbA9A5Yk%2FEmUwUD23y6aocFVOEzMFvhp%2BGQHEEdC1g%2B1w4rYLAFK4HBH5L8vp0okOTTT5objxN7zaUHr064soSJd8KQXX9k4TNzpLX6a0ThMgsiazALvLDJBZqviOE0dHRWtM1C%2FpBazxoS9a0HzDfsvl6PRu2NoyKw9Zqc5N8lBJXep%2BxKvQ0rcGeVjUP2bPkhiGb4Db4rgMPBh6IjyXljz%2BXVUTab%2B2epBX9BtbfxSkQtMIqHuN7%2FcXvWH1IHKFZYEvsOitQZG%2FxOn2%2ByPAj0VBhODWLgMRclrj8Z87jl9NZo85%2FXC4tdyMEamzRiiw%2BE6M098hQ81uzZdU7WUfhXv%2BnKnG%2F80U%2FVBLuqUZjq2uGbNvFZdt2KFrtl8kYeB6CHkjIaqce2sx%2BJNxcir%2B6gMUmp7w8ciEuL1WEAkZuCWofgbT%2FeTM1nzezTPtaMkXIbjNzZmkDktbhATtHPOCvN%2Fd%2F1uKNyL2GE1pe8iRqUOIsV8bzc5ItImTeQHNJKfd07i5%2B9LcBCGHawwFKWK5JeRMSrEC8yXCGFuOb9pg18djW8j6XrkqAQup0mUZjfL602cQgXMKv8N89jJMZgiDBMm%2B%2By5a152Wlr6xTTsGNz%2Fa%2BElWKLysVNaoxhVJlHfdMFeq3%2FQKiECaQVDQL9jHBY02ZDD7scR9WXOck5hBUWcpE6s9mNx7bnsMV8gxmKXHRoJ9bHEUJAn8XHwvpa%2FZbawIUveAIZHPbRUBxJCbKbQpQjJoA5cyc2WXgY9mP%2FXAd9Rduzgns0ySvXlpXowgzDqfHV9RU2ynoUOGMlTmXyYtdh%2FV1waNScOFlcxRbjfXNYRL7Zcf6NWm2rRY0u%2BsMgOkMij0o9o8rdjaNPFPsctalVcVWlZpyLpeu2eYRzf51Pp1dgmYbxSm7kn2cZJrdXO5HOb5D4qDZg2ZX1myLZxG5Zkvc7JY1e5hOOWh2HQl7rYDZdseabV3QAFCagH7NKqRUZ7sbNmpPLd0qeY12EZcvlBgQtxnEfXVnKC3J%2BxIDL%2FqyXkP0FS6h%2F5DrE%2BeL4G6%2Bq2iWZKGc3q5zUp4b0eoKHsestoRnbFzrvOQdRD7%2B%2BURW%2BaU94mqeZvct4bv1nd6OVWFV9mRtjzNAo%2Byxd1GceAje%2F%2FGJVATYaPzV5MQrFYYBstqH91XBUogvOJkLo1R8MN9NC7vp2zRuNDKs5mZv1shGzQoDVfna2hq0ijdgRw6Xz4GPoRPpp83SgoLsp0VGyKT7ZZ%2FgaiCjU%2F7OVQJ9HW3AUZhK5EqmEmXTi3IrArSmDJvTzVZ3P7Z9KVkgUdF8cXNICEV7%2BHazxidMnDRr3Iz0xap1swv8j0nbsmxR2mPlWlFOLUauWd48LHtv8nY7famK%2Bnppq1i2hYXnhtGurI33Kuv3%2BMI%2FwzTy0lY0u11xV95ZsWfizgKmS8kqTszSlDBxAthUSKrwtbBatr0dJs7zk7gKmyVp%2FQ1gOud8bt%2FAbEJxIWoQIxHKeXzpDSJrfXZcO5vSFDx%2FVZG9Rbfdd6koQ4rjssfbXr8O0y7Er5KZ6y2PYHSalhUdXGGTpZNej%2BDk0Fsdze2p18PXKjTu9eBTFJH%2Bk137iHV68zlaQVLi%2Fw%3D%3D%3C%2Fdiagram%3E%3C%2Fmxfile%3E

## Внедрение Transactional Outbox:
Используем паттерн Transactional Outbox в core-app, чтобы надёжно отправлять события в очередь при фиксации транзакции в БД.

#   #   #   #   #   #   #   #   #   #   #   #   #   #   #

Я восстановил и адаптировал диаграмму из задания 3, добавив взаимодействие с Kafka и паттерн Transactional Outbox
обавлен брокер Kafka

## Отдельный компонент — Outbox Dispatcher (в виде фонового процесса, сервиса или библиотеки)
Периодически читает таблицу outbox. Публикует события в Kafka.
После успешной отправки помечает событие как обработанное.
Это решает проблему атомарности между записью в базу и отправкой события.

## Асинхронные взаимодействия выделены. 
Вместо REST-запросов в ins-comp-settlement, product-aggregator указано получение данных из Kafka (Event Streaming).

REST используется только там, где требуется синхронность: между InsureTech Web и core-app, core-app и client-info.