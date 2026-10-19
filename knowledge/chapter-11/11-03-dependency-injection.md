# Dependency Injection в Flutter

## Введение

Dependency Injection (DI) — это паттерн проектирования, при котором объект получает зависимости извне, а не создаёт их самостоятельно. Это снижает связность кода и улучшает тестируемость.

## Проблемы без DI

```dart
// ❌ Плохо: жёсткая зависимость
class UserService {
  final Dio _client = Dio(); // Создаём внутри
  final SharedPreferences _prefs = SharedPreferences.getInstance();

  Future<User> getUser(String id) async {
    final response = await _client.get('/users/$id');
    return User.fromJson(response.data);
  }
}
```

Проблемы:
- Невозможно мокать зависимости в тестах
- Трудно заменить реализацию (например, Dio на MockDio)
- Нарушается принцип единственной ответственности

## Решения с DI

```dart
// ✅ Хорошо: зависимости внедряются извне
class UserService {
  final Dio _client;
  final SharedPreferences _prefs;

  UserService({required Dio client, required SharedPreferences prefs})
      : _client = client,
        _prefs = prefs;

  Future<User> getUser(String id) async {
    final response = await _client.get('/users/$id');
    return User.fromJson(response.data);
  }
}
```

## Принципы DI

### Принцип инверсии зависимостей (DIP)

> Модули верхнего уровня не должны зависеть от модулей нижнего уровня. Оба должны зависеть от абстракций.

```dart
// Абстракция (доменный уровень)
abstract class DataRepository {
  Future<List<Product>> getProducts();
}

// Конкретная реализация (уровень данных)
class ProductRepositoryImpl implements DataRepository {
  final Dio client;
  ProductRepositoryImpl({required this.client});

  @override
  Future<List<Product>> getProducts() async {
    final response = await client.get('/products');
    return (response.data as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
}

// Потребитель зависит от абстракции
class ProductViewModel {
  final DataRepository repository;
  ProductViewModel(this.repository);
}
```

### Принцип единственной ответственности (SRP)

Каждый класс/модуль отвечает за одну вещь:
- **NetworkService** — только HTTP-запросы
- **StorageService** — только локальное хранение
- **UserService** — только бизнес-логика работы с пользователями

## Паттерны DI

### 1. Constructor Injection (Внедрение через конструктор)

Самый распространённый и рекомендуемый способ:

```dart
class OrderService {
  final ApiService api;
  final StorageService storage;
  final Logger logger;

  OrderService({
    required this.api,
    required this.storage,
    required this.logger,
  });
}
```

### 2. Setter Injection (Внедрение через свойство)

Полезно для необязательных зависимостей:

```dart
class OrderService {
  late final ApiService api;
  StorageService? storage; // Необязательная зависимость
  Logger logger = Logger(); // Значение по умолчанию

  void setApi(ApiService api) {
    this.api = api;
  }
}
```

### 3. Method Injection (Внедрение через метод)

Для зависимостей, используемых только в одном методе:

```dart
class ReportGenerator {
  Future<String> generateReport({required DatabaseService db}) async {
    final data = await db.fetchData();
    return _format(data);
  }
}
```

## Service Locator Pattern

Service Locator — это способ глобального доступа к зависимостям через центральный реестр:

```dart
// Регистрация
final locator = GetIt.instance;
locator.registerLazySingleton<ApiService>(() => ApiService());
locator.registerLazySingleton<StorageService>(() => StorageService());
locator.registerFactory<UserService>(() => UserService(
  api: locator<ApiService>(),
  storage: locator<StorageService>(),
));

// Использование
final userService = locator<UserService>();
```

## Сравнение подходов

| Подход | Плюсы | Минусы |
|--------|-------|--------|
| Constructor Injection | Явные зависимости, легко тестировать | Много параметров в конструкторе |
| Service Locator | Простое использование | Скрытые зависимости, сложно тестировать |
| DI-фреймворк | Автоматизация, аннотации | Дополнительная сложность, магия |

## Лучшие практики

1. **Предпочитайте Constructor Injection** — зависимости явные и видимые
2. **Регистрируйте зависимости в одном месте** — файл main или DI-конфиг
3. **Используйте абстракции (интерфейсы)** для зависимостей
4. **Singleton для сервисов**, Factory для view-model
5. **Не используйте Service Locator в доменном слое**
6. **Тестируйте с моками** — DI делает это простым
