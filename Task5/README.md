# Анализ текущего REST API (из Swagger):
Ручки:
GET /clients/{id} ---	Информация о клиенте
GET /clients/{id}/documents ---	Документы клиента
GET /clients/{id}/relatives ---	Родственники клиента


## Основные сущности:
type Client {
    id: ID!
    name: String
    age: Int
    documents: Document
    relatives: Relative
}

type Document {
    id: ID!
    type: String
    number: String
    issueDate: String
    expiryDate: String
}

type Relative {
    id: ID!
    relationType: String
    name: String
    age: Int
}


### Основной Query:
type Query {
    client(id: ID!): Client
}


#### Пример запроса в GraphQL
Этот запрос заменяет три REST-запроса, и возвращает только нужные поля.
query {
    client(id: "123") {
        name
        age
        documents {
            type
            number
        }
        relatives {
            name
            relationType
        }
    }
}