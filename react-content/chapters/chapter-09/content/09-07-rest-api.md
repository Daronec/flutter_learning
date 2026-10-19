# REST API — принципы и паттерны в Flutter

REST (Representational State Transfer) — это архитектурный стиль для построения распределённых систем. Большинство современных API следуют принципам REST.

## Принципы REST

| Принцип | Описание |
|---------|----------|
| Client-Server | Клиент и сервер разделены |
| Stateless | Каждый запрос независим, без сохранения состояния |
| Cacheable | Ответы могут кэшироваться |
| Uniform Interface | Единый интерфейс для всех операций |
| Layered System | Архитектура состоит из слоёв |
| Code on Demand (опционально) | Сервер может передавать исполняемый код |

## Ресурсы и URI

### Именование ресурсов

```
# Ресурсы — существительные во множественном числе
GET    /api/users          — список пользователей
POST   /api/users          — создать пользователя
GET    /api/users/123      — получить пользователя с ID 123
PUT    /api/users/123      — обновить пользователя
DELETE /api/users/123      — удалить пользователя

# Вложенные ресурсы
GET    /api/users/123/posts      — посты пользователя
POST   /api/users/123/posts      — создать пост пользователя
GET    /api/users/123/posts/456  — конкретный пост
```

### Примеры эндпоинтов

| Метод | URI | Описание |
|-------|-----|----------|
| GET | `/api/products` | Получить список продуктов |
| GET | `/api/products/42` | Получить продукт с ID 42 |
| POST | `/api/products` | Создать новый продукт |
| PUT | `/api/products/42` | Полностью обновить продукт |
| PATCH | `/api/products/42` | Частично обновить продукт |
| DELETE | `/api/products/42` | Удалить продукт |

## Фильтрация, пагинация и сортировка

### Query parameters

```
# Фильтрация
GET /api/users?role=admin&status=active

# Пагинация
GET /api/products?page=1&limit=20

# Сортировка
GET /api/products?sort=price&order=asc

# Комбинация
GET /api/users?role=admin&status=active&page=1&limit=10&sort=name
```

### Реализация в Flutter

```dart
import 'package:dio/dio.dart';

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<List<User>> getUsers({
    int page = 1,
    int limit = 20,
    String? role,
    String? status,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    final response = await _dio.get(
      '/users',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (role != null) 'role': role,
        if (status != null) 'status': status,
        'sort': sortBy,
        'order': sortOrder,
      },
    );

    final List<dynamic> data = response.data;
    return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
  }
}
```

## Ответы API

### Успешные ответы

```json
{
  "id": 1,
  "name": "Иван Петров",
  "email": "ivan@example.com",
  "created_at": "2024-01-15T10:30:00Z"
}
```

### Ответы со списком

```json
{
  "data": [
    {"id": 1, "name": "Иван"},
    {"id": 2, "name": "Мария"}
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Ответы об ошибках

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Ошибка валидации данных",
    "details": [
      {"field": "email", "message": "Неверный формат email"},
      {"field": "name", "message": "Имя обязательно"}
    ]
  }
}
```

## Реализация REST-клиента в Flutter

### Сервис для работы с API

```dart
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Получить список пользователей
  Future<List<User>> getUsers() async {
    final response = await _dio.get('/users');
    final List<dynamic> data = response.data;
    return data
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Получить пользователя по ID
  Future<User> getUser(int id) async {
    final response = await _dio.get('/users/$id');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // Создать пользователя
  Future<User> createUser(Map<String, dynamic> userData) async {
    final response = await _dio.post('/users', data: userData);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // Обновить пользователя
  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    final response = await _dio.put('/users/$id', data: userData);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  // Удалить пользователя
  Future<void> deleteUser(int id) async {
    await _dio.delete('/users/$id');
  }
}
```

### Repository паттерн

```dart
class UserRepository {
  final ApiService _apiService;
  final LocalStorage _storage;

  UserRepository(this._apiService, this._storage);

  Future<List<User>> getUsers() async {
    try {
      // Сначала пробуем из кэша
      final cached = _storage.getCachedUsers();
      if (cached != null) {
        return cached;
      }

      // Если кэш пуст — запрос к API
      return await _apiService.getUsers();
    } catch (e) {
      // При ошибке возвращаем кэш или пустой список
      return _storage.getCachedUsers() ?? [];
    }
  }

  Future<User> getUser(int id) async {
    return await _apiService.getUser(id);
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    return await _apiService.createUser(data);
  }
}
```

## Best Practices

- **Используйте существительные** для именования ресурсов
- **Возвращайте правильные HTTP-статусы** — 200, 201, 400, 404, 500
- **Используйте пагинацию** для больших списков
- **Поддерживайте фильтрацию и сортировку** через query parameters
- **Возвращайте структурированные ошибки** с кодами и деталями
- **Версионируйте API** — `/api/v1/users`, `/api/v2/users`
- **Документируйте API** — используйте OpenAPI/Swagger
