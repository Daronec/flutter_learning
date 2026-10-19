# Matchers и ассерции

Matchers — это мощный механизм сравнения значений в тестах Dart/Flutter. Они обеспечивают читаемые сообщения об ошибках и гибкие возможности проверки.

## Основы matchers

### Базовый синтаксис

```dart
import 'package:test/test.dart';

void main() {
  test('пример использования matchers', () {
    expect(1 + 1, equals(2));
    expect('hello', isNotEmpty);
    expect([1, 2, 3], contains(2));
  });
}
```

### Структура expect

```dart
expect(
  actual,        // Фактическое значение
  matcher,       // Matcher для сравнения
  reason: '',    // Необязательное сообщение при ошибке
);
```

## Основные matchers

### Равенство и сравнение

| Matcher | Описание | Пример |
|---------|----------|--------|
| `equals()` | Проверка равенства | `expect(5, equals(5))` |
| `isNull()` | Проверка на null | `expect(value, isNull)` |
| `isNotNull()` | Проверка на не-null | `expect(value, isNotNull)` |
| `isTrue()` / `isFalse()` | Проверка булева значения | `expect(flag, isTrue)` |
| `identical()` | Проверка идентичности объектов | `expect(a, identical(b))` |
| `closeTo()` | Числа с допуском | `expect(3.14, closeTo(3.141, 0.01))` |

```dart
void main() {
  group('Равенство и сравнение', () {
    test('equals — проверка равенства', () {
      expect('hello', equals('hello'));
      expect(42, equals(42));
      expect([1, 2], equals([1, 2]));
    });

    test('isNull и isNotNull', () {
      String? nullable;
      expect(nullable, isNull);

      nullable = 'value';
      expect(nullable, isNotNull);
    });

    test('isTrue и isFalse', () {
      expect(true, isTrue);
      expect(false, isFalse);
    });

    test('identical — проверка идентичности', () {
      final a = [1, 2, 3];
      final b = a;
      expect(a, identical(b)); // Один и тот же объект
      expect(a, isNot(identical([1, 2, 3]))); // Разные объекты
    });

    test('closeTo — числа с допуском', () {
      expect(3.14159, closeTo(3.14, 0.01));
      expect(0.1 + 0.2, closeTo(0.3, 0.0001));
    });
  });
}
```

### Коллекции

| Matcher | Описание | Пример |
|---------|----------|--------|
| `contains()` | Содержит элемент | `expect(list, contains(1))` |
| `isEmpty` / `isNotEmpty` | Пустая / не пустая | `expect(list, isEmpty)` |
| `hasLength()` | Проверка длины | `expect(list, hasLength(3))` |
| `every()` | Все элементы проходят проверку | `expect(list, everyElement(isPositive))` |
| `unorderedEquals()` | Неупорядоченное равенство | `expect([1,2], unorderedEquals([2,1]))` |

```dart
void main() {
  group('Коллекции', () {
    test('contains — проверка наличия элемента', () {
      final list = [1, 2, 3, 4, 5];
      expect(list, contains(3));
      expect(list, isNot(contains(10)));
    });

    test('isEmpty и isNotEmpty', () {
      expect([], isEmpty);
      expect([1], isNotEmpty);

      expect('', isEmpty);
      expect('hello', isNotEmpty);

      expect({}, isEmpty);
      expect({'key': 'value'}, isNotEmpty);
    });

    test('hasLength — проверка длины', () {
      expect([1, 2, 3], hasLength(3));
      expect('hello', hasLength(5));
      expect({'a': 1, 'b': 2}, hasLength(2));
    });

    test('everyElement — проверка всех элементов', () {
      expect([2, 4, 6, 8], everyElement(isPositive));
      expect([2, 4, 6, 8], everyElement(even));
      expect([1, 2, 3], isNot(everyElement(even)));
    });

    test('unorderedEquals — неупорядоченное равенство', () {
      expect([1, 2, 3], unorderedEquals([3, 2, 1]));
      expect({'a': 1, 'b': 2}, unorderedEquals({'b': 2, 'a': 1}));
    });
  });
}
```

### Строки

| Matcher | Описание | Пример |
|---------|----------|--------|
| `contains()` | Содержит подстроку | `expect(str, contains('hello'))` |
| `startsWith()` | Начинается с | `expect(str, startsWith('Hello'))` |
| `endsWith()` | Заканчивается на | `expect(str, endsWith('!'))` |
| `matches()` | Соответствует regex | `expect(str, matches(RegExp(r'^\d+$')))` |
| `isEmpty` / `isNotEmpty` | Пустая / не пустая | `expect(str, isNotEmpty)` |

```dart
void main() {
  group('Строки', () {
    test('contains — подстрока', () {
      expect('Hello World', contains('World'));
      expect('Hello World', isNot(contains('Universe')));
    });

    test('startsWith и endsWith', () {
      expect('Hello', startsWith('Hel'));
      expect('Hello', endsWith('lo'));
    });

    test('matches — регулярные выражения', () {
      expect('12345', matches(RegExp(r'^\d+$')));
      expect('test@email.com', matches(RegExp(r'^[\w-]+@[\w-]+\.\w+$')));
      expect('abc', isNot(matches(RegExp(r'^\d+$'))));
    });

    test('caseSensitiveMatch', () {
      expect('Hello', equals('Hello'));
      expect('Hello', isNot(equals('hello')));
    });
  });
}
```

### Типы

| Matcher | Описание | Пример |
|---------|----------|--------|
| `isA<Type>()` | Проверка типа | `expect(obj, isA<String>())` |
| `isInstanceOf` | Псевним для isA | `expect(obj, isInstanceOf<String>())` |

```dart
void main() {
  group('Типы', () {
    test('isA — проверка типа', () {
      expect('hello', isA<String>());
      expect(42, isA<int>());
      expect([1, 2], isA<List>());
      expect({'a': 1}, isA<Map>());
    });

    test('isA с вложенными типами', () {
      expect({'a': [1, 2]}, isA<Map<String, List<int>>>());
    });
  });
}
```

### Исключения

| Matcher | Описание | Пример |
|---------|----------|--------|
| `throwsA()` | Бросает исключение | `expect(fn, throwsA(...))` |
| `throwsException` | Бросает Exception | `expect(fn, throwsException)` |
| `throwsArgumentError` | Бросает ArgumentError | `expect(fn, throwsArgumentError)` |
| `throwsStateError` | Бросает StateError | `expect(fn, throwsStateError)` |

```dart
void main() {
  group('Исключения', () {
    void divide(int a, int b) {
      if (b == 0) throw ArgumentError('Деление на ноль');
      return a ~/ b;
    }

    void invalidOperation() {
      throw StateError('Недопустимая операция');
    }

    test('throwsA — проверка исключения', () {
      expect(() => divide(10, 0), throwsA(isA<ArgumentError>()));
    });

    test('throwsA с предикатом', () {
      expect(
        () => divide(10, 0),
        throwsA(
          predicate<ArgumentError>(
            (e) => e.message.contains('деление'),
          ),
        ),
      );
    });

    test('throwsStateError', () {
      expect(() => invalidOperation(), throwsStateError);
    });

    test('throwsException', () {
      expect(() => throw Exception('test'), throwsException);
    });
  });
}
```

### Логические matchers

| Matcher | Описание | Пример |
|---------|----------|--------|
| `isTrue` / `isFalse` | Булевы значения | `expect(flag, isTrue)` |
| `isTrue` | Равно true | `expect(true, isTrue)` |
| `isNot()` | Инверсия | `expect(x, isNot(equals(5)))` |
| `anyOf()` | Любое из условий | `expect(x, anyOf([gt(5), lt(0)]))` |
| `allOf()` | Все условия | `expect(x, allOf([gt(0), lt(10)]))` |

```dart
import 'package:test/test.dart';

void main() {
  group('Логические matchers', () {
    test('isNot — инверсия', () {
      expect(5, isNot(equals(10)));
      expect('hello', isNot(equals('world')));
    });

    test('anyOf — любое из условий', () {
      expect(15, anyOf([greaterThan(10), lessThan(0)]));
      expect(-5, anyOf([greaterThan(10), lessThan(0)]));
    });

    test('allOf — все условия', () {
      expect(5, allOf([greaterThan(0), lessThan(10)]));
      expect(15, isNot(allOf([greaterThan(0), lessThan(10)])));
    });
  });
}
```

## Пользовательские matchers

### Создание через predicate

```dart
void main() {
  group('Пользовательские matchers', () {
    test('predicate — пользовательская проверка', () {
      // Проверка: число чётное и положительное
      expect(
        4,
        predicate<int>(
          (n) => n > 0 && n % 2 == 0,
          'положительное чётное число',
        ),
      );

      // Проверка: email валидный
      expect(
        'test@mail.com',
        predicate<String>(
          (email) => RegExp(r'^[\w-]+@[\w-]+\.\w+$').hasMatch(email),
          'валидный email',
        ),
      );
    });
  });
}
```

### Создание через Matcher class

```dart
/// Пользовательский matcher для проверки email
class EmailMatcher extends Matcher {
  final String _description;

  EmailMatcher() : _description = 'является валидным email';

  @override
  Description describe(Description description) {
    return description.add(_description);
  }

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! String) return false;
    return RegExp(r'^[\w-]+@[\w-]+\.\w+$').hasMatch(item);
  }
}

Matcher get email => EmailMatcher();

void main() {
  group('Пользовательский EmailMatcher', () {
    test('должен валидировать email', () {
      expect('test@mail.com', email);
      expect('user@example.org', email);
      expect('not-an-email', isNot(email));
      expect('', isNot(email));
    });
  });
}
```

### Создание через matcher() helper

```dart
/// Matcher для проверки диапазона чисел
Matcher inRange(int min, int max) {
  return TypeMatcher<int>(
    description: 'число в диапазоне [$min, $max]',
    matches: (int value) => value >= min && value <= max,
  );
}

void main() {
  group('Matcher inRange', () {
    test('должен проверять диапазон', () {
      expect(5, inRange(1, 10));
      expect(0, isNot(inRange(1, 10)));
      expect(11, isNot(inRange(1, 10)));
      expect(1, inRange(1, 10));
      expect(10, inRange(1, 10));
    });
  });
}
```

## Matchеры для Flutter виджетов

### find.matchers

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Matchers для виджетов', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Hello'),
              Text('World'),
              Text('Hello'),
            ],
          ),
        ),
      ),
    );

    // findsOneWidget — ровно один виджет
    expect(find.text('World'), findsOneWidget);

    // findsNWidgets — N виджетов
    expect(find.text('Hello'), findsNWidgets(2));

    // findsWidgets — хотя бы один
    expect(find.byType(Text), findsWidgets);

    // findsNothing — ни одного
    expect(find.text('Goodbye'), findsNothing);

    // findsByType — по типу
    expect(find.byType(Column), findsOneWidget);
  });
}
```

### Matcher для виджетов с данными

```dart
void main() {
  testWidgets('поиск виджета по данным', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              ListTile(title: Text('Иван')),
              ListTile(title: Text('Мария')),
              ListTile(title: Text('Пётр')),
            ],
          ),
        ),
      ),
    );

    // Поиск по тексту
    expect(find.text('Мария'), findsOneWidget);

    // Поиск по индексу
    expect(
      find.byType(ListTile).at(0),
      findsOneWidget,
    );

    // Поиск по ключу
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Text(
            'Hello',
            key: Key('greeting'),
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('greeting')), findsOneWidget);
  });
}
```

## Комбинирование matchers

### Вложенные matchers

```dart
void main() {
  group('Комбинирование matchers', () {
    test('вложенные matchers', () {
      final map = {'users': [1, 2, 3]};

      // Map содержит ключ 'users', значение — список с 3 элементами
      expect(
        map,
        allOf([
          hasEntry('users', isA<List>()),
          predicate<Map>((m) => m['users']!.length == 3),
        ]),
      );
    });

    test('matcher для вложенных структур', () {
      final response = {
        'status': 'success',
        'data': {
          'id': 42,
          'name': 'Тест',
          'active': true,
        },
      };

      expect(
        response,
        allOf([
          hasEntry('status', 'success'),
          predicate<Map>((r) {
            final data = r['data'] as Map;
            return data['id'] == 42 && data['name'] == 'Тест';
          }),
        ]),
      );
    });
  });
}
```

### Custom matcher для JSON

```dart
/// Matcher для проверки JSON-объекта
Matcher jsonEquals(Map<String, dynamic> expected) {
  return TypeMatcher<Map<String, dynamic>>(
    description: 'JSON равен $expected',
    matches: (Map<String, dynamic> actual) {
      if (actual.length != expected.length) return false;
      for (final key in expected.keys) {
        if (!actual.containsKey(key)) return false;
        if (actual[key] != expected[key]) return false;
      }
      return true;
    },
  );
}

void main() {
  test('jsonEquals — проверка JSON', () {
    expect(
      {'name': 'Иван', 'age': 30},
      jsonEquals({'name': 'Иван', 'age': 30}),
    );
    expect(
      {'name': 'Иван', 'age': 30},
      isNot(jsonEquals({'name': 'Мария', 'age': 30})),
    );
  });
}
```

## Лучшие практики

1. **Используйте описательные matchers** — `equals`, `contains`, `isEmpty` читаемы
2. **Предпочитайте специфичные matchers** — `throwsArgumentError` вместо `throwsA`
3. **Используйте predicate для сложной логики** — когда стандартных matchers недостаточно
4. **Создавайте переиспользуемые matchers** — для повторяющихся проверок
5. **Проверяйте сообщения об ошибках** — они должны быть понятными
6. **Используйте isNot для отрицательных проверок** — `isNot(contains(...))`

## Заключение

Matchers — это мощный инструмент для написания читаемых и надёжных тестов. Понимание основных matchers и умение создавать пользовательские позволяет эффективно проверять любое поведение в тестах.
