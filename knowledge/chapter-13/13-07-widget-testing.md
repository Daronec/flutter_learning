---
tags:
  - testing
  - unit-tests
  - widget-tests
chapter: 13
section: 7
title: Widget testing: find, tester, pump
alias: 13 07 widget testing
status: complete
---

# Widget testing: find, tester, pump

Widget testing — это один из самых распространённых видов тестирования в Flutter. Он позволяет проверять рендеринг виджетов, реакцию на действия пользователя и взаимодействие между виджетами.

## Основные понятия

### WidgetTester

`WidgetTester` — это основной класс для работы с виджетами в тестах. Он предоставляет методы для:

- Запуска виджетов (`pumpWidget`)
- Поиска виджетов (`find`)
- Взаимодействия (`tap`, `drag`, `enterText`)
- Ожидания (`pump`, `pumpAndSettle`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Базовый пример WidgetTester', (WidgetTester tester) async {
    // tester — это WidgetTester
    await tester.pumpWidget(const Text('Hello'));
    expect(find.text('Hello'), findsOneWidget);
  });
}
```

## Система поиска (find)

### Основные методы find

| Метод | Описание | Пример |
|-------|----------|--------|
| `find.byType` | Поиск по типу виджета | `find.byType(Text)` |
| `find.byKey` | Поиск по ключу | `find.byKey(myKey)` |
| `find.text` | Поиск по тексту | `find.text('Hello')` |
| `find.byIcon` | Поиск по иконке | `find.byIcon(Icons.add)` |
| `find.byValueKey` | Поиск по ValueKey | `find.byValueKey('id')` |
| `find.descendant` | Поиск потомков | `find.descendant(...)` |
| `find.ancestor` | Поиск предков | `find.ancestor(...)` |

### Поиск по типу

```dart
void main() {
  testWidgets('Поиск по типу виджета', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Заголовок')),
          body: Column(
            children: [
              Text('Текст 1'),
              Text('Текст 2'),
              ElevatedButton(onPressed: () {}, child: Text('Кнопка')),
            ],
          ),
        ),
      ),
    );

    // Все Text виджеты
    expect(find.byType(Text), findsNWidgets(3));

    // Первый Text виджет
    expect(find.byType(Text).first, findsOneWidget);

    // Второй Text виджет
    expect(find.byType(Text).at(1), findsOneWidget);

    // ElevatedButton
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Column
    expect(find.byType(Column), findsOneWidget);
  });
}
```

### Поиск по ключу (рекомендуемый способ)

```dart
void main() {
  testWidgets('Поиск по ключу', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text(
                'Имя',
                key: Key('name_label'),
              ),
              TextField(
                key: Key('name_field'),
                decoration: InputDecoration(labelText: 'Имя'),
              ),
              ElevatedButton(
                key: Key('submit_button'),
                onPressed: () {},
                child: Text('Отправить'),
              ),
            ],
          ),
        ),
      ),
    );

    // Надёжный поиск по ключу
    expect(find.byKey(const Key('name_label')), findsOneWidget);
    expect(find.byKey(const Key('name_field')), findsOneWidget);
    expect(find.byKey(const Key('submit_button')), findsOneWidget);

    // Взаимодействие по ключу
    await tester.enterText(find.byKey(const Key('name_field')), 'Иван');
    await tester.tap(find.byKey(const Key('submit_button')));
  });
}
```

### Поиск по тексту

```dart
void main() {
  testWidgets('Поиск по тексту', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Привет, Мир!'),
              Text('Добро пожаловать'),
              Text('Привет, Мир!'), // Дубликат
            ],
          ),
        ),
      ),
    );

    // Один виджет с текстом
    expect(find.text('Добро пожаловать'), findsOneWidget);

    // Два виджета с одинаковым текстом
    expect(find.text('Привет, Мир!'), findsNWidgets(2));

    // Поиск по части текста
    expect(find.textContaining('Привет'), findsNWidgets(2));

    // Поиск по регулярному выражению
    expect(find.textRegExp(r'^Привет.*'), findsOneWidget);
  });
}
```

### Поиск по иконке

```dart
void main() {
  testWidgets('Поиск по иконке', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              IconButton(icon: Icon(Icons.add), onPressed: () {}),
              IconButton(icon: Icon(Icons.delete), onPressed: () {}),
              IconButton(icon: Icon(Icons.settings), onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsNothing);
  });
}
```

### Продвинутый поиск

```dart
void main() {
  testWidgets('Продвинутый поиск', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Иван'),
                subtitle: Text('ivan@example.com'),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Мария'),
                subtitle: Text('maria@example.com'),
              ),
            ],
          ),
        ),
      ),
    );

    // Поиск потомка
    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(ListTile),
      ),
      findsNWidgets(2),
    );

    // Поиск предка
    expect(
      find.ancestor(
        of: find.byIcon(Icons.person),
        matching: find.byType(ListTile),
      ),
      findsNWidgets(2),
    );

    // Поиск по виджету с данными
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && widget.data == 'Мария',
        description: 'текст "Мария"',
      ),
      findsOneWidget,
    );
  });
}
```

## Взаимодействие с виджетами

### Tap — нажатие

```dart
void main() {
  testWidgets('Нажатие на кнопку', (WidgetTester tester) async {
    int tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Счётчик: $tapCount'),
              ElevatedButton(
                key: Key('increment'),
                onPressed: () => tapCount++,
                child: Text('Увеличить'),
              ),
            ],
          ),
        ),
      ),
    );

    // Проверяем начальное значение
    expect(find.text('Счётчик: 0'), findsOneWidget);

    // Нажимаем кнопку
    await tester.tap(find.byKey(const Key('increment')));
    await tester.pump();

    // Проверяем обновлённое значение
    expect(find.text('Счётчик: 1'), findsOneWidget);

    // Нажимаем ещё раз
    await tester.tap(find.byKey(const Key('increment')));
    await tester.pump();

    expect(find.text('Счётчик: 2'), findsOneWidget);
  });
}
```

### enterText — ввод текста

```dart
void main() {
  testWidgets('Ввод текста', (WidgetTester tester) async {
    String enteredText = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextFormField(
                key: Key('input'),
                onChanged: (value) => enteredText = value,
              ),
              Text('Введено: $enteredText'),
            ],
          ),
        ),
      ),
    );

    // Вводим текст
    await tester.enterText(find.byKey(const Key('input')), 'Hello');
    await tester.pump();

    expect(find.text('Введено: Hello'), findsOneWidget);

    // Очищаем и вводим другой текст
    await tester.enterText(find.byKey(const Key('input')), 'World');
    await tester.pump();

    expect(find.text('Введено: World'), findsOneWidget);
  });
}
```

### drag — перетаскивание

```dart
void main() {
  testWidgets('Перетаскивание', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) {
              return ListTile(title: Text('Элемент $index'));
            },
          ),
        ),
      ),
    );

    // Проверяем первый элемент виден
    expect(find.text('Элемент 0'), findsOneWidget);

    // Скроллим вниз
    final listView = find.byType(ListView);
    await tester.drag(listView, Offset(0, -400));
    await tester.pump();

    // Элемент 20 должен быть виден после скролла
    expect(find.text('Элемент 20'), findsOneWidget);
  });
}
```

### longPress — долгое нажатие

```dart
void main() {
  testWidgets('Долгое нажатие', (WidgetTester tester) async {
    bool longPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            key: Key('gesture'),
            onLongPress: () => longPressed = true,
            child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
              child: Center(child: Text('Нажми долго')),
            ),
          ),
        ),
      ),
    );

    // Долгое нажатие (по умолчанию 500мс)
    await tester.longPress(find.byKey(const Key('gesture')));
    await tester.pump();

    expect(longPressed, isTrue);
  });
}
```

## pump и pumpAndSettle

### pump — один кадр

```dart
void main() {
  testWidgets('pump — один кадр', (WidgetTester tester) async {
    await tester.pumpWidget(const Text('Hello'));
    expect(find.text('Hello'), findsOneWidget);

    // Обновляем виджет
    await tester.pumpWidget(const Text('World'));
    expect(find.text('World'), findsOneWidget);
    expect(find.text('Hello'), findsNothing);
  });
}
```

### pump с задержкой

```dart
void main() {
  testWidgets('pump с задержкой', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TimerDemo(),
          ),
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);

    // Переходим на 1 секунду вперёд
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1'), findsOneWidget);

    // Ещё на 2 секунды
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('3'), findsOneWidget);
  });
}

class TimerDemo extends StatefulWidget {
  @override
  State<TimerDemo> createState() => _TimerDemoState();
}

class _TimerDemoState extends State<TimerDemo> {
  int _count = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => _count++);
    });
  }

  @override
  Widget build(BuildContext context) => Text('$_count');

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

### pumpAndSettle — ожидание анимаций

```dart
void main() {
  testWidgets('pumpAndSettle — ожидание анимаций', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedCrossFade(
              firstChild: Text('Первый'),
              secondChild: Text('Второй'),
              crossFadeState: CrossFadeState.showFirst,
              duration: Duration(seconds: 1),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Первый'), findsOneWidget);
    expect(find.text('Второй'), findsNothing);

    // Переключаем
    await tester.tap(find.byType(AnimatedCrossFade));
    // Или через обновление виджета
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedCrossFade(
              firstChild: Text('Первый'),
              secondChild: Text('Второй'),
              crossFadeState: CrossFadeState.showSecond,
              duration: Duration(seconds: 1),
            ),
          ),
        ),
      ),
    );

    // Ждём завершения анимации
    await tester.pumpAndSettle();

    expect(find.text('Второй'), findsOneWidget);
  });
}
```

### pumpAndSettle с таймаутом

```dart
void main() {
  testWidgets('pumpAndSettle с таймаутом', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedOpacity(
              opacity: 0,
              duration: Duration(days: 365), // Очень долгая анимация
              child: Text('Появляюсь'),
            ),
          ),
        ),
      ),
    );

    // Останавливаем после 500мс
    await tester.pumpAndSettle(Duration(milliseconds: 500));

    // Анимация не завершена, но тест не завис
    expect(find.text('Появляюсь'), findsOneWidget);
  });
}
```

## Тестирование StatefulWidget

### Полный пример

```dart
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

  void _increment() => setState(() => _count++);
  void _decrement() => setState(() => _count--);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('$_count'),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              key: Key('decrement'),
              onPressed: _count > 0 ? _decrement : null,
              child: Text('-'),
            ),
            ElevatedButton(
              key: Key('increment'),
              onPressed: _increment,
              child: Text('+'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('CounterWidget', () {
    testWidgets('должен отображать начальное значение',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CounterWidget(initialCount: 5));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('должен увеличивать счётчик',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CounterWidget());
      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.byKey(const Key('increment')));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('должен уменьшать счётчик',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CounterWidget(initialCount: 5));
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.byKey(const Key('decrement')));
      await tester.pump();
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('кнопка уменьшения должна быть неактивна при 0',
        (WidgetTester tester) async {
      await tester.pumpWidget(const CounterWidget());
      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('decrement')),
      );
      expect(button.onPressed, isNull);
    });
  });
}
```

## Лучшие практики

1. **Используйте Key для поиска** — `find.byKey` надёжнее `find.byType`
2. **Используйте pumpAndSettle** — для анимаций и асинхронных операций
3. **Тестируйте пользовательские действия** — tap, drag, enterText
4. **Проверяйте наличие и отсутствие виджетов** — `findsOneWidget`, `findsNothing`
5. **Используйте WidgetTester для взаимодействия** — это основной инструмент
6. **Изолируйте тесты** — каждый тест должен запускать свой виджет
7. **Не тестируйте фреймворк** — не пишите тесты на стандартные виджеты

## Заключение

Widget testing — это основной инструмент для проверки UI в Flutter. Комбинация `find`, `pump`, `pumpAndSettle` и методов взаимодействия (`tap`, `enterText`, `drag`) покрывает большинство сценариев тестирования виджетов.
