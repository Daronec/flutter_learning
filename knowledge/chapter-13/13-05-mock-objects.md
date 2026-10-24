---
tags:
  - testing
  - unit-tests
  - widget-tests
chapter: 13
section: 5
title: Mock-объекты: mockito, mocktail
alias: 13 05 mock objects
status: complete
---

# Mock-объекты: mockito, mocktail

Mock-объекты — это имитации реальных объектов, используемые для изоляции тестируемого кода от внешних зависимостей. В Dart/Flutter популярен пакет `mockito`, а также его более простая альтернатива — `mocktail`.

## Зачем нужны mock-объекты

Mock-объекты позволяют:

- Тестировать код без реальных зависимостей (API, база данных)
- Проверять, что методы были вызваны с нужными параметрами
- Имитировать различные сценарии (успех, ошибка, таймаут)
- Ускорять тесты (не нужно реальных сетевых запросов)

## mockito

### Установка

```yaml
# pubspec.yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

### Генерация mock-классов

```bash
# Генерация mock-классов
dart run build_runner build --delete-conflicting-outputs
```

### Создание интерфейса и mock

```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Интерфейс API
abstract class ApiClient {
  Future<Map<String, dynamic>> getUser(int id);
  Future<List<Map<String, dynamic>>> getUsers();
  Future<void> createUser(Map<String, dynamic> user);
  Future<void> deleteUser(int id);
}

// Анонтация для генерации mock
@GenerateMocks([ApiClient])
import 'api_client_mock.dart';

// Тестируемый сервис
class UserService {
  final ApiClient api;

  UserService({required this.api});

  Future<User> loadUser(int id) async {
    final data = await api.getUser(id);
    return User.fromJson(data);
  }

  Future<List<User>> loadAllUsers() async {
    final data = await api.getUsers();
    return data.map((json) => User.fromJson(json)).toList();
  }

  Future<void> registerUser(String name, String email) async {
    await api.createUser({'name': name, 'email': email});
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}
```

### when — настройка поведения mock

```dart
import 'package:test/test.dart';
import 'package:mockito/mockito';

// Предположим, что MockApiClient сгенерирован через @GenerateMocks
class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('UserService', () {
    late MockApiClient mockApi;
    late UserService service;

    setUp(() {
      mockApi = MockApiClient();
      service = UserService(api: mockApi);
    });

    test('loadUser должен возвращать пользователя из API', () async {
      // Настраиваем mock: когда вызывается getUser(1), возвращаем данные
      when(mockApi.getUser(1)).thenAnswer(
        (_) async => {
          'id': 1,
          'name': 'Иван',
          'email': 'ivan@example.com',
        },
      );

      // Вызываем метод
      final user = await service.loadUser(1);

      // Проверяем результат
      expect(user.id, equals(1));
      expect(user.name, equals('Иван'));
      expect(user.email, equals('ivan@example.com'));
    });

    test('loadAllUsers должен возвращать список пользователей', () async {
      when(mockApi.getUsers()).thenAnswer(
        (_) async => [
          {'id': 1, 'name': 'Иван', 'email': 'ivan@example.com'},
          {'id': 2, 'name': 'Мария', 'email': 'maria@example.com'},
        ],
      );

      final users = await service.loadAllUsers();

      expect(users.length, equals(2));
      expect(users[0].name, equals('Иван'));
      expect(users[1].name, equals('Мария'));
    });
  });
}
```

### thenThrow — имитация ошибок

```dart
void main() {
  group('UserService — обработка ошибок', () {
    late MockApiClient mockApi;
    late UserService service;

    setUp(() {
      mockApi = MockApiClient();
      service = UserService(api: mockApi);
    });

    test('loadUser должен обрабатывать ошибку сети', () async {
      when(mockApi.getUser(1)).thenThrow(
        Exception('Ошибка сети'),
      );

      expect(
        () => service.loadUser(1),
        throwsA(isA<Exception>()),
      );
    });

    test('loadUser должен обрабатывать 404', () async {
      when(mockApi.getUser(999)).thenThrow(
        Exception('Пользователь не найден'),
      );

      expect(
        () => service.loadUser(999),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

### thenAnswer — сложная логика

```dart
void main() {
  group('thenAnswer — сложная логика', () {
    test('должен возвращать разные данные для разных ID', () async {
      when(mockApi.getUser(any)).thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as int;
        return {
          'id': id,
          'name': 'Пользователь $id',
          'email': 'user$id@example.com',
        };
      });

      final user1 = await service.loadUser(1);
      expect(user1.name, equals('Пользователь 1'));

      final user2 = await service.loadUser(2);
      expect(user2.name, equals('Пользователь 2'));
    });

    test('должен проверять аргументы вызова', () async {
      when(mockApi.createUser(any)).thenAnswer((invocation) async {
        final user = invocation.positionalArguments[0] as Map;
        expect(user['name'], isNotEmpty);
        expect(user['email'], contains('@'));
        return {};
      });

      await service.registerUser('Иван', 'ivan@example.com');
    });
  });
}
```

### verify — проверка вызовов

```dart
void main() {
  group('verify — проверка вызовов', () {
    late MockApiClient mockApi;
    late UserService service;

    setUp(() {
      mockApi = MockApiClient();
      service = UserService(api: mockApi);
    });

    test('registerUser должен вызвать createUser с правильными данными',
        () async {
      when(mockApi.createUser(any)).thenAnswer((_) async => {});

      await service.registerUser('Иван', 'ivan@example.com');

      // Проверяем, что метод был вызван
      verify(mockApi.createUser(
        {'name': 'Иван', 'email': 'ivan@example.com'},
      )).called(1);
    });

    test('registerUser должен вызвать createUser ровно один раз', () async {
      when(mockApi.createUser(any)).thenAnswer((_) async => {});

      await service.registerUser('Иван', 'ivan@example.com');

      verify(mockApi.createUser(any)).called(1);
    });

    test('должен проверять порядок вызовов', () async {
      when(mockApi.getUser(any)).thenAnswer(
        (_) async => {'id': 1, 'name': 'Иван', 'email': 'ivan@example.com'},
      );
      when(mockApi.createUser(any)).thenAnswer((_) async => {});

      await service.loadUser(1);
      await service.registerUser('Мария', 'maria@example.com');

      // getUser должен быть вызван до createUser
      verify(mockApi.getUser(1)).called(1);
      verify(mockApi.createUser(any)).called(1);
    });
  });
}
```

### verifyNever — проверка отсутствия вызовов

```dart
void main() {
  group('verifyNever', () {
    test('не должен вызывать deleteUser для неактивного пользователя',
        () async {
      when(mockApi.getUser(1)).thenAnswer(
        (_) async => {
          'id': 1,
          'name': 'Иван',
          'email': 'ivan@example.com',
          'active': false,
        },
      );

      // Метод, который не должен вызывать deleteUser
      final user = await service.loadUser(1);

      verifyNever(mockApi.deleteUser(any));
    });
  });
}
```

### verifyInOrder — проверка последовательности

```dart
void main() {
  test('должен вызывать методы в правильном порядке', () async {
    when(mockApi.getUser(1)).thenAnswer(
      (_) async => {'id': 1, 'name': 'Иван', 'email': 'ivan@example.com'},
    );
    when(mockApi.createUser(any)).thenAnswer((_) async => {});
    when(mockApi.deleteUser(any)).thenAnswer((_) async => {});

    // Вызываем несколько методов
    await service.loadUser(1);
    await service.registerUser('Мария', 'maria@example.com');
    await service.registerUser('Пётр', 'petr@example.com');

    // Проверяем порядок
    verifyInOrder([
      mockApi.getUser(1),
      mockApi.createUser({'name': 'Мария', 'email': 'maria@example.com'}),
      mockApi.createUser({'name': 'Пётр', 'email': 'petr@example.com'}),
    ]);
  });
}
```

## mocktail — более простая альтернатива

### Установка

```yaml
# pubspec.yaml
dev_dependencies:
  mocktail: ^1.0.3
```

### mocktail не требует генерации

Главное преимущество mocktail — не нужно использовать build_runner. Mock создаётся напрямую:

```dart
import 'package:mocktail/mocktail.dart';

// Создаём mock напрямую, без генерации
class MockApiClient extends Mock implements ApiClient {}
```

### Базовое использование mocktail

```dart
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

abstract class ApiClient {
  Future<Map<String, dynamic>> getUser(int id);
  Future<List<Map<String, dynamic>>> getUsers();
}

class MockApiClient extends Mock implements ApiClient {}

class UserService {
  final ApiClient api;

  UserService({required this.api});

  Future<User> loadUser(int id) async {
    final data = await api.getUser(id);
    return User.fromJson(data);
  }
}

class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'] as int, name: json['name'] as String);
  }
}

void main() {
  group('UserService с mocktail', () {
    late MockApiClient mockApi;
    late UserService service;

    setUp(() {
      mockApi = MockApiClient();
      service = UserService(api: mockApi);
    });

    test('loadUser должен возвращать пользователя', () async {
      // thenAnswer — аналог mockito
      when(
        () => mockApi.getUser(any()),
      ).thenAnswer(
        (_) async => {'id': 1, 'name': 'Иван'},
      );

      final user = await service.loadUser(1);
      expect(user.name, equals('Иван'));
    });

    test('должен проверять вызовы', () async {
      when(
        () => mockApi.getUser(any()),
      ).thenAnswer(
        (_) async => {'id': 1, 'name': 'Иван'},
      );

      await service.loadUser(1);

      // verify — аналог mockito
      verify(
        () => mockApi.getUser(1),
      ).called(1);
    });

    test('должен обрабатывать ошибки', () async {
      when(
        () => mockApi.getUser(any()),
      ).thenThrow(Exception('Ошибка сети'));

      expect(
        () => service.loadUser(1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

### whenNeverThrow — упрощённая обработка ошибок

```dart
void main() {
  test('mocktail — whenNeverThrow', () {
    when(() => mockApi.getUser(any())).thenThrow(Exception('test'));

    // Пр��верка ошибки
    expect(
      () => mockApi.getUser(1),
      throwsA(isA<Exception>()),
    );
  });
}
```

### Сравнение mockito и mocktail

| Характеристика | mockito | mocktail |
|---------------|---------|----------|
| Генерация кода | Да (build_runner) | Нет |
| Сложность настройки | Высокая | Низкая |
| Скорость | Зависит от генерации | Быстрая |
| Синтаксис | `when(mock.method(arg))` | `when(() => mock.method(arg))` |
| Поддержка null-safety | Да | Да |
| Размер зависимостей | Больше | Меньше |
| Сообщения об ошибках | Подробные | Проще |

### Когда использовать что

| Ситуация | Рекомендация |
|----------|-------------|
| Простые mock-объекты | mocktail |
| Сложная генерация | mockito |
| Быстрый старт | mocktail |
| Крупный проект с множеством mock | mockito |
| Минимум зависимостей | mocktail |

## Лучшие практики

1. **Тестируйте только один метод за раз** — изолируйте тестируемый код
2. **Используйте abstract class / interface** — для лёгкого мокирования
3. **Называйте mock-классы понятно** — `MockApiClient`, `MockDatabase`
4. **Проверяйте вызовы с правильными аргументами** — используйте `verify`
5. **Не переусердствуйте с mock** — не мокируйте то, что не тестируете
6. **Используйте mocktail для простоты** — если нет сложных требований к генерации
7. **Изолируйте setUp** — каждый тест должен иметь чистые mock-объекты

## Заключение

Mock-объекты — незаменимый инструмент для тестирования кода с зависимостями. `mockito` — зрелый и мощный фреймворк с генерацией кода, а `mocktail` — его более простая и лёгкая альтернатива. Выбор зависит от потребностей проекта.
