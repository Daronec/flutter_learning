---
tags:
  - testing
  - unit-tests
  - widget-tests
chapter: 13
section: 1
title: Виды тестов в Flutter
alias: 13 01 test types
status: complete
---

# Виды тестов в Flutter

Тестирование — неотъемлемая часть разработки качественного приложения. В экосистеме Flutter существует три основных вида тестов, каждый из которых решает свои задачи и проверяет разные уровни приложения.

## Классификация тестов

| Тип теста | Что тестирует | Скорость | Сложность | Инструмент |
|-----------|--------------|----------|-----------|------------|
| Unit-тесты | Отдельные функции, классы, логику | Очень быстро (мс) | Низкая | `test` |
| Widget-тесты | Отдельные виджеты, их рендеринг и взаимодействие | Быстро (сек) | Средняя | `flutter_test` |
| Integration-тесты | Всё приложение целиком, взаимодействие с системой | Медленно (мин) | Высокая | `integration_test` |

## Unit-тесты

Unit-тесты — это самые мелкие и быстрые тесты. Они проверяют отдельные функции, методы или классы в изоляции от внешних зависимостей.

### Что тестировать

- Бизнес-логику (сервисы, репозитории, use-case)
- Функции преобразования данных
- Логика валидации
- Математические вычисления
- Парсинг данных

### Пример unit-теста

```dart
import 'package:test/test.dart';

// Класс, который мы будем тестировать
class Calculator {
  int add(int a, int b) => a + b;
  int subtract(int a, int b) => a - b;
  double divide(int a, int b) {
    if (b == 0) throw ArgumentError('Деление на ноль');
    return a / b;
  }
}

void main() {
  group('Calculator', () {
    late Calculator calculator;

    setUp(() {
      calculator = Calculator();
    });

    test('add должен складывать два числа', () {
      expect(calculator.add(2, 3), equals(5));
      expect(calculator.add(-1, 1), equals(0));
      expect(calculator.add(0, 0), equals(0));
    });

    test('subtract должен вычитать второе число из первого', () {
      expect(calculator.subtract(5, 3), equals(2));
      expect(calculator.subtract(3, 5), equals(-2));
    });

    test('divide должен бросать исключение при делении на ноль', () {
      expect(() => calculator.divide(10, 0), throwsArgumentError);
    });
  });
}
```

### Преимущества unit-тестов

- **Скорость**: выполняются за миллисекунды
- **Изоляция**: не зависят от фреймворка Flutter
- **Простота**: легко писать и читать
- **Покрывание логики**: идеальны для проверки бизнес-логики

### Недостатки

- Не проверяют UI
- Не проверяют взаимодействие с платформой
- Не гарантируют корректную работу виджетов

## Widget-тесты

Widget-тесты проверяют отдельные виджеты: как они рендерятся, реагируют на действия пользователя и взаимодействуют друг с другом.

### Что тестировать

- Рендеринг виджета (какие элементы отображаются)
- Реакцию на пользовательские действия (нажатия, ввод текста)
- Передачу параметров через конструктор
- Состояние виджета при разных входных данных

### Пример widget-теста

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Тестируемый виджет
class CounterWidget extends StatefulWidget {
  final int initialCount;

  const CounterWidget({super.key, this.initialCount = 0});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  void _increment() {
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('Счётчик: $_count'),
            ElevatedButton(
              key: const Key('increment_button'),
              onPressed: _increment,
              child: const Text('Увеличить'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('CounterWidget должен отображать начальное значение',
      (WidgetTester tester) async {
    // Строим виджет
    await tester.pumpWidget(const CounterWidget(initialCount: 5));

    // Проверяем текст
    expect(find.text('Счётчик: 5'), findsOneWidget);

    // Нажимаем кнопку
    await tester.tap(find.byKey(const Key('increment_button')));
    await tester.pump();

    // Проверяем, что счётчик увеличился
    expect(find.text('Счётчик: 6'), findsOneWidget);
  });
}
```

### Преимущества widget-тестов

- Проверяют UI-компоненты
- Тестируют взаимодействие пользователя с виджетом
- Быстрее integration-тестов
- Не требуют реального устройства

### Недостатки

- Не проверяют реальное устройство/платформу
- Не проверяют навигацию между экранами
- Могут не выявить проблемы с анимациями

## Integration-тесты

Integration-тесты (также называемые end-to-end тестами) проверяют всё приложение целиком: от запуска до выполнения пользовательских сценариев.

### Что тестировать

- Пользовательские сценарии (user flows)
- Навигацию между экранами
- Взаимодействие с API и базой данных
- Анимации и переходы
- Работу на реальном устройстве

### Пример integration-теста

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:my_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end тесты', () {
    testWidgets('Пользователь может зарегистрироваться',
        (WidgetTester tester) async {
      // Запускаем приложение
      pumpWidget(const MyApp());

      // Ждём инициализации
      await tester.pumpAndSettle();

      // Переходим на экран регистрации
      expect(find.text('Войти'), findsOneWidget);
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      // Заполняем форму
      expect(find.byType(TextFormField), findsNWidgets(2));
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'password123',
      );

      // Нажимаем кнопку отправки
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();

      // Проверяем, что попали на главный экран
      expect(find.text('Главная'), findsOneWidget);
    });
  });
}
```

### Преимущества integration-тестов

- Проверяют реальное поведение приложения
- Тестируют всё приложение целиком
- Запускаются на реальном устройстве или эмуляторе
- Выявляют проблемы интеграции компонентов

### Недостатки

- Медленные (секунды и минуты)
- Сложнее писать и поддерживать
- Требуют эмулятора или устройства
- Хрупкие (ломается при изменении UI)

## Сравнительная таблица

| Характеристика | Unit | Widget | Integration |
|---------------|------|--------|-------------|
| Время выполнения | < 1 мс | 10–100 мс | 10–60 сек |
| Зависимость от Flutter | Нет | Да (flutter_test) | Да (integration_test) |
| Нужен эмулятор | Нет | Нет | Да |
| Что проверяет | Логику | Рендеринг, события | Пользовательский сценарий |
| Частота запуска | Каждый коммит | Каждый коммит | Регулярно |
| Количество тестов | 100–1000+ | 50–200 | 10–50 |

## Пирамида тестирования

```
       /\
      /  \     Integration-тесты (мало)
     /----\
    /      \   Widget-тесты (средне)
   /--------\
  /          \ Unit-тесты (много)
 /------------\
```

Рекомендуется遵循 пирамиды тестирования: больше всего unit-тестов, меньше widget-тестов и ещё меньше integration-тестов. Это обеспечивает баланс между скоростью, покрытием и надёжностью.

## Когда использовать каждый вид тестов

### Unit-тесты — используйте всегда

```dart
// Идеально для чистых функций
class UserService {
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String formatName(String firstName, String lastName) {
    return '$firstName $lastName'.trim();
  }
}
```

### Widget-тесты — используйте для сложных виджетов

```dart
// Идеально для пользовательских виджетов с состоянием
class ProductCard extends StatelessWidget {
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.network(product.imageUrl),
          Text(product.name),
          Text('\$${product.price}'),
          ElevatedButton(
            onPressed: () => addToCart(product),
            child: const Text('В корзину'),
          ),
        ],
      ),
    );
  }
}
```

### Integration-тесты — используйте для критических сценариев

```dart
// Идеально для ключевых пользовательских путей
// 1. Регистрация → Вход → Просмотр профиля
// 2. Поиск товара → Добавление в корзину → Оформление заказа
// 3. Получение уведомления → Переход на экран
```

## Лучшие практики

1. **Начинайте с unit-тестов** — они самые быстрые и дешёвые
2. **Тестируйте поведение, а не реализацию** — не привязывайтесь к внутренним деталям
3. **Используйте AAA-паттерн** (Arrange-Act-Assert) для всех тестов
4. **Держите тесты изолированными** — каждый тест должен быть независимым
5. **Называйте тесты описательно** — название должно говорить, что происходит
6. **Не тестируйте фреймворк** — не пишите тесты на то, что уже протестировано Flutter
7. **Поддерживайте покрытие** — стремитесь к 70–80% для unit-тестов

## Заключение

Выбор типа теста зависит от того, что именно вы хотите проверить. Unit-тесты идеальны для бизнес-логики, widget-тесты — для UI-компонентов, а integration-тесты — для проверки пользовательских сценариев. Сбалансированное использование всех трёх видов обеспечивает высокое качество приложения при разумных затратах времени на тестирование.
## РЎРІСЏР·Р°РЅРЅС‹Рµ РіР»Р°РІС‹

[[14-01. Flutter Performance Toolkit и DevTools]] [[Clean Architecture в Flutter]] 
