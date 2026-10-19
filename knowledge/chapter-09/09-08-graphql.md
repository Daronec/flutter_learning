# GraphQL — основы и интеграция с Flutter

GraphQL — это язык запросов и серверная runtime-технология для API, разработанная Facebook. В отличие от REST, GraphQL позволяет клиенту запрашивать точно те данные, которые нужны.

## REST vs GraphQL

| REST | GraphQL |
|------|---------|
| Несколько endpoint'ов | Один endpoint |
| Фиксированная структура ответа | Гибкая структура запроса |
| Over-fetching / Under-fetching | Запрашиваем только нужное |
| Версионирование API | Эволюция без версий |
| HTTP методы для действий | Один метод — POST |

## Основные концепции

### Типы запросов

| Тип | Описание |
|-----|----------|
| Query | Чтение данных (аналог GET) |
| Mutation | Изменение данных (аналог POST/PUT/DELETE) |
| Subscription | Real-time обновления (WebSocket) |

### Базовый Query

```graphql
# Запрос конкретных полей
query {
  user(id: 1) {
    id
    name
    email
  }
}

# Запрос списка с полями
query {
  users(limit: 10) {
    id
    name
    avatarUrl
  }
}
```

### Query с переменными

```graphql
query GetUser($id: ID!) {
  user(id: $id) {
    id
    name
    email
    posts {
      title
      createdAt
    }
  }
}
```

```json
// Переменные для запроса
{
  "id": "1"
}
```

### Mutation

```graphql
# Создание пользователя
mutation CreateUser($input: CreateUserInput!) {
  createUser(input: $input) {
    id
    name
    email
  }
}

# Обновление
mutation UpdateUser($id: ID!, $input: UpdateUserInput!) {
  updateUser(id: $id, input: $input) {
    id
    name
    email
  }
}

# Удаление
mutation DeleteUser($id: ID!) {
  deleteUser(id: $id) {
    success
    message
  }
}
```

### Nested запросы

```graphql
query GetUserWithPosts($id: ID!) {
  user(id: $id) {
    id
    name
    email
    posts {
      id
      title
      content
      comments {
        id
        text
        author {
          name
        }
      }
    }
  }
}
```

## Пакет graphql

### Установка

```yaml
dependencies:
  graphql: ^5.1.3+1
  normalize: ^9.0.3
```

### Настройка клиента

```dart
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  final ValueNotifier<GraphQLClient> client = createGraphQLClient();

  runApp(
    GraphQLProvider(
      client: client,
      child: MyApp(),
    ),
  );
}

ValueNotifier<GraphQLClient> createGraphQLClient() {
  final HttpLink httpLink = HttpLink(
    'https://api.example.com/graphql',
  );

  return ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
    ),
  );
}
```

### Выполнение Query

```dart
// Query с помощью runQuery
final QueryOptions options = QueryOptions(
  document: gql('''
    query GetUsers {
      users {
        id
        name
        email
      }
    }
  '''),
);

final QueryResult result = await client.query(options);

if (result.hasException) {
  print('Ошибка: ${result.exception}');
} else {
  final List<dynamic> users = result.data!['users'];
  for (var user in users) {
    print('${user['name']} — ${user['email']}');
  }
}
```

### Query с переменными

```dart
final QueryOptions options = QueryOptions(
  document: gql('''
    query GetUser($id: ID!) {
      user(id: $id) {
        id
        name
        email
        posts {
          title
          createdAt
        }
      }
    }
  '''),
  variables: {'id': '1'},
);

final QueryResult result = await client.query(options);
final Map<String, dynamic> data = result.data!;
final user = data['user'];
```

### Mutation

```dart
final MutationOptions options = MutationOptions(
  document: gql('''
    mutation CreateUser($name: String!, $email: String!) {
      createUser(input: {name: $name, email: $email}) {
        id
        name
        email
      }
    }
  '''),
  variables: {
    'name': 'Иван Петров',
    'email': 'ivan@example.com',
  },
);

final QueryResult result = await client.mutate(options);

if (result.hasException) {
  print('Ошибка: ${result.exception}');
} else {
  final newUser = result.data!['createUser'];
  print('Создан: ${newUser['name']}');
}
```

### Subscription (Real-time)

```dart
final SubscriptionOptions options = SubscriptionOptions(
  document: gql('''
    subscription OnNewMessage {
      onNewMessage {
        id
        text
        sender {
          name
        }
      }
    }
  '''),
);

client.subscribe(Options(options)).listen(
  (result) {
    final message = result.data!['onNewMessage'];
    print('Новое сообщение: ${message['text']}');
  },
  onError: (error) {
    print('Ошибка подписки: $error');
  },
);
```

### Использование с Flutter Widget

```dart
class UserListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GraphQLQuery(
      options: QueryOptions(
        document: gql('query { users { id name email } }'),
      ),
      builder: (BuildResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (result.hasException) {
          return Center(child: Text('Ошибка: ${result.exception}'));
        }

        final List<dynamic> users = result.data!['users'];
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user['name']),
              subtitle: Text(user['email']),
            );
          },
        );
      },
    );
  }
}
```

## Best Practices

- **Используйте переменные** — никогда не подставляйте данные напрямую в запрос
- **Запрашивайте только нужные поля** — не используйте `*` или избыточные данные
- **Кэшируйте ответы** — GraphQL-клиент автоматически кэширует данные
- **Используйте Mutation** для изменений — не Query
- **Обрабатывайте ошибки** — проверяйте `result.hasException`
- **Используйте Subscription** для real-time данных — чат, уведомления
