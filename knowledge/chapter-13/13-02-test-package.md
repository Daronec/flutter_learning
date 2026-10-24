---
tags:
  - testing
  - unit-tests
  - widget-tests
chapter: 13
section: 2
title: Пакет test — основа для unit-тестов
alias: 13 02 test package
status: complete
---

# Пакет test — основа для unit-тестов

Пакет `test` — это стандартный фреймворк для тестирования в Dart. Он является основой для unit-тестирования в Flutter и предоставляет мощный набор инструментов для написания чистых, читаемых и поддерживаемых тестов.

## Установка и настройка

### Добавление в pubspec.yaml

```yaml
# pubspec.yaml
dev_dependencies:
  test: ^1.25.0
  flutter_test:
    sdk: flutter
```

### Запуск тестов

```bash
# Запуск всех тестов
flutter test

# Запуск конкретного файла
flutter test test/calculator_test.dart

# Запуск тестов с фильтрацией по имени
flutter test --name "add"

# Запуск с подробным выводом
flutter test -r expanded

# Запуск с отслеживанием покрытия
flutter test --coverage

# Мониторинг изменений (watch mode)
flutter test --reporter expanded
```

## Базовая структура теста

Каждый тест в пакете `test` состоит из трёх основных частей:

1. **Arrange** (Подготовка) — создание объектов и настройка данных
2. **Act** (Действие) — вызов тестируемого метода
3. **Assert** (Проверка) — проверка результата

### Пример базового теста

```dart
import 'package:test/test.dart';

class BankAccount {
  final String _owner;
  double _balance;

  BankAccount(this._owner, this._balance);

  double get balance => _balance;
  String get owner => _owner;

  void deposit(double amount) {
    if (amount <= 0) throw ArgumentError('Сумма должна быть положительной');
    _balance += amount;
  }

  bool withdraw(double amount) {
    if (amount <= 0) return false;
    if (amount > _balance) return false;
    _balance -= amount;
    return true;
  }
}

void main() {
  test('BankAccount должен иметь начальное значение баланса', () {
    // Arrange
    final account = BankAccount('Иван', 100.0);

    // Act
    final balance = account.balance;

    // Assert
    expect(balance, equals(100.0));
    expect(account.owner, equals('Иван'));
  });
}
```

## Группировка тестов с group

Для организации связанных тестов используется функция `group`:

```dart
void main() {
  group('BankAccount', () {
    late BankAccount account;

    setUp(() {
      account = BankAccount('Иван', 100.0);
    });

    test('должен иметь начальное значение баланса', () {
      expect(account.balance, equals(100.0));
    });

    group('deposit', () {
      test('должен увеличивать баланс', () {
        account.deposit(50.0);
        expect(account.balance, equals(150.0));
      });

      test('должен бросать исключение при отрицательной сумме', () {
        expect(() => account.deposit(-10.0), throwsArgumentError);
      });

      test('должен принимать ноль как недействительную сумму', () {
        expect(() => account.deposit(0.0), throwsArgumentError);
      });
    });

    group('withdraw', () {
      test('должен уменьшать баланс при достаточных средствах', () {
        final success = account.withdraw(30.0);
        expect(success, isTrue);
        expect(account.balance, equals(70.0));
      });

      test('должен возвращать false при недостаточных средствах', () {
        final success = account.withdraw(200.0);
        expect(success, isFalse);
        expect(account.balance, equals(100.0));
      });
    });
  });
}
```

## setUp и tearDown

Методы `setUp` и `tearDown` позволяют выполнять код до и после каждого теста:

```dart
void main() {
  late List<String> items;
  late Map<String, int> scores;

  setUp(() {
    // Выполняется перед КАЖДЫМ тестом
    items = [];
    scores = {};
    print('setUp: подготовка выполнена');
  });

  tearDown(() {
    // Выполняется после КАЖДОГО теста
    items.clear();
    scores.clear();
    print('tearDown: очистка выполнена');
  });

  test('должен добавлять элементы в список', () {
    items.add('Первый');
    items.add('Второй');
    expect(items.length, equals(2));
  });

  test('должен добавлять очки игроку', () {
    scores['Игрок1'] = 100;
    scores['Игрок2'] = 200;
    expect(scores['Игрок1'], equals(100));
  });

  test('должен работать с пустым списком', () {
    expect(items.isEmpty, isTrue);
  });
}
```

### setUpAll и tearDownAll

Для дорогостоящей инициализации, которая нужна только один раз:

```dart
void main() {
  late DatabaseConnection connection;

  setUpAll(() async {
    // Выполняется ОДИН РАЗ перед всеми тестами в группе
    connection = await DatabaseConnection.connect('test.db');
    await connection.createTables();
    print('setUpAll: база данных готова');
  });

  tearDownAll(() async {
    // Выполняется ОДИН РАЗ после всех тестов в группе
    await connection.close();
    print('tearDownAll: соединение закрыто');
  });

  test('должен вставлять данные', () async {
    await connection.insert('users', {'name': 'Иван'});
    expect(await connection.count('users'), equals(1));
  });

  test('должен находить данные по ID', () async {
    await connection.insert('users', {'name': 'Мария'});
    final user = await connection.find('users', 1);
    expect(user!['name'], equals('Мария'));
  });
}
```

## describe и описания тестов

Функция `describe` помогает структурировать тесты:

```dart
void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockApi mockApi;

    setUp(() {
      mockApi = MockApi();
      repository = UserRepository(api: mockApi);
    });

    group('loadUsers', () {
      test('должен возвращать список пользователей при успешном запросе', () {
        // ...
      });

      test('должен возвращать пустой список при отсутствии данных', () {
        // ...
      });

      test('должен обрабатывать ошибку сети', () {
        // ...
      });
    });

    group('createUser', () {
      test('должен создавать пользователя и возвращать ID', () {
        // ...
      });

      test('должен валидировать email', () {
        // ...
      });
    });
  });
}
```

## Асинхронные тесты

Для тестирования асинхронного кода используйте `async/await`:

```dart
class UserRepository {
  final ApiClient api;

  UserRepository({required this.api});

  Future<List<User>> loadUsers() async {
    final response = await api.get('/users');
    return response.map((json) => User.fromJson(json)).toList();
  }

  Future<User> loadUserById(int id) async {
    final response = await api.get('/users/$id');
    return User.fromJson(response);
  }

  Future<void> deleteUser(int id) async {
    await api.delete('/users/$id');
  }
}

void main() {
  group('UserRepository', () {
    late UserRepository repository;
    late MockApiClient mockApi;

    setUp(() {
      mockApi = MockApiClient();
      repository = UserRepository(api: mockApi);
    });

    test('loadUsers должен возвращать список пользователей', () async {
      // Arrange
      mockApi.stubGet(
        '/users',
        [
          {'id': 1, 'name': 'Иван'},
          {'id': 2, 'name': 'Мария'},
        ],
      );

      // Act
      final users = await repository.loadUsers();

      // Assert
      expect(users.length, equals(2));
      expect(users[0].name, equals('Иван'));
      expect(users[1].name, equals('Мария'));
    });

    test('loadUserById должен возвращать пользователя по ID', () async {
      // Arrange
      mockApi.stubGet(
        '/users/42',
        {'id': 42, 'name': 'Пётр'},
      );

      // Act
      final user = await repository.loadUserById(42);

      // Assert
      expect(user.id, equals(42));
      expect(user.name, equals('Пётр'));
    });

    test('deleteUser должен вызывать API', () async {
      // Arrange
      mockApi.stubDelete('/users/5');

      // Act
      await repository.deleteUser(5);

      // Assert
      expect(mockApi.calledDelete, isTrue);
    });
  });
}
```

## Фильтрация тестов

### Запуск конкретных тестов

```bash
# По имени
flutter test --name "должен возвращать"

# По описанию group
flutter test --name "loadUsers"

# По файлу
flutter test test/repository/user_repository_test.dart
```

### Пропуск тестов

```dart
void main() {
  test('этот тест выполняется', () {
    expect(1 + 1, equals(2));
  });

  test('этот тест пропускается', () {
    expect(1 + 1, equals(3));
  }, skip: 'Пока не реализовано');

  test('этот тест пропускается на определённой платформе', () {
    expect(Platform.isWindows, isFalse);
  }, skip: Platform.isWindows);
}
```

### Ожидание исключений

```dart
class PaymentService {
  Future<void> processPayment(double amount) async {
    if (amount <= 0) {
      throw ArgumentError('Сумма должна быть положительной');
    }
    if (amount > 10000) {
      throw InsufficientFundsException('Превышен лимит');
    }
    // Обработка платежа
  }
}

void main() {
  group('PaymentService', () {
    late PaymentService service;

    setUp(() {
      service = PaymentService();
    });

    test('должен бросать ArgumentError при отрицательной сумме', () {
      expect(
        () => service.processPayment(-10.0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('должен бросать InsufficientFundsException при превышении лимита',
        () async {
      expect(
        () => service.processPayment(15000.0),
        throwsA(isA<InsufficientFundsException>()),
      );
    });

    test('должен бросать исключение с конкретным сообщением', () {
      expect(
        () => service.processPayment(-5.0),
        throwsA(
          predicate<ArgumentError>(
            (e) => e.message.contains('положительной'),
          ),
        ),
      );
    });
  });
}
```

## Тестирование потоков (Streams)

```dart
class CounterStream {
  final _controller = StreamController<int>.broadcast();

  Stream<int> get stream => _controller.stream;

  void increment() {
    _controller.add(_controller.hasData ? _controller.last + 1 : 1);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('CounterStream', () {
    late CounterStream counter;

    setUp(() {
      counter = CounterStream();
    });

    tearDown(() {
      counter.dispose();
    });

    test('должен отправлять значения в поток', () async {
      final received = <int>[];
      final subscription = counter.stream.listen(received.add);

      counter.increment();
      await Future.delayed(Duration(milliseconds: 10));
      counter.increment();
      counter.increment();

      await subscription.cancel();
      expect(received, equals([1, 2, 3]));
    });

    test('должен обрабатывать ошибки потока', () async {
      final errorController = StreamController<int>.broadcast();
      final errors = <Object>[];

      errorController.stream.listen(
        (value) {},
        onError: (error) => errors.add(error),
      );

      errorController.addError(Exception('Тестовая ошибка'));
      await Future.delayed(Duration(milliseconds: 10));

      expect(errors.length, equals(1));
      expect(errors.first, isA<Exception>());

      await errorController.close();
    });
  });
}
```

## Настройка конфигурации тестов

### Файл конфигурации test.yaml

```yaml
# test/test.yaml
name: my_app_tests
timeout: long
concurrency: 4
randomize: true
```

### Командные флаги

```bash
# Установить таймаут для всех тестов
flutter test --timeout 5m

# Запустить тесты в определённом порядке
flutter test --concurrency 1

# Случайный порядок выполнения
flutter test --randomize

# Включить покрытие
flutter test --coverage
```

## Лучшие практики

1. **Используйте setUp для изоляции** — каждый тест должен работать с новыми объектами
2. **Группируйте связанные тесты** — используйте `group` для организации
3. **Описывайте тесты понятно** — название теста должно объяснять поведение
4. **Тестируйте один аспект за раз** — один тест = одна проверка
5. **Используйте async/await** — для асинхронного кода всегда используйте await
6. **Очищайте ресурсы** — используйте tearDown для освобождения памяти
7. **Не делайте тесты зависимыми** — порядок выполнения не должен влиять на результат
8. **Используйте setUpAll для дорогостоящих операций** — инициализация один раз

## Заключение

Пакет `test` предоставляет мощный и гибкий фреймворк для unit-тестирования в Dart. Его основные преимущества — простота, скорость и полная интеграция с экосистемой Dart/Flutter. Понимание основ `test` package является фундаментом для написания качественных тестов в Flutter-приложениях.
