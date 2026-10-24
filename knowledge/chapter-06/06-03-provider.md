---
tags:
  - state-management
  - provider
  - bloc
  - riverpod
chapter: 6
section: 3
title: Provider — паттерн observer и наследование
alias: 06 03 provider
status: complete
---

# Provider — паттерн observer и наследование

## Введение

**Provider** — это обёртка над `InheritedWidget`, которая делает управление состоянием в Flutter простым и интуитивным. Это один из самых популярных пакетов для управления состоянием в экосистеме Flutter.

> **Ключевая идея:** Provider позволяет передавать данные вниз по дереву виджетов без передачи через конструкторы.

## Установка

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.0
```

```bash
flutter pub get
```

## Основные концепции Provider

### 1. ChangeNotifierProvider

Создаёт экземпляр `ChangeNotifier` и предоставляет его виджетам.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Модель состояния
class CounterModel with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}

// Корневой виджет приложения
void main() {
  runApp(
    // Создаём ChangeNotifierProvider на уровне всего приложения
    ChangeNotifierProvider(
      create: (_) => CounterModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Provider Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CounterPage(),
    );
  }
}

// Страница счётчика
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Счётчик')),
      body: Center(
        // Consumer получает доступ к модели
        child: Consumer<CounterModel>(
          builder: (context, counter, child) {
            return Text(
              'Счётчик: ${counter.count}',
              style: Theme.of(context).textTheme.headlineLarge,
            );
          },
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => context.read<CounterModel>().increment(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => context.read<CounterModel>().decrement(),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
```

### 2. MultiProvider — несколько провайдеров

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 3. ProxyProvider — зависимость между провайдерами

```dart
class UserModel with ChangeNotifier {
  String _name = '';
  String get name => _name;

  void setName(String name) {
    _name = name;
    notifyListeners();
  }
}

class GreetingModel with ChangeNotifier {
  String _greeting = '';
  String get greeting => _greeting;

  // ProxyProvider передаёт UserModel в factory
  void updateGreeting(String name) {
    _greeting = 'Привет, $name!';
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
        ProxyProvider<UserModel, GreetingModel>(
          update: (context, user, greeting) {
            greeting ??= GreetingModel();
            greeting.updateGreeting(user.name);
            return greeting;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

## Widget-клиенты Provider

### Consumer — самый популярный виджет

```dart
// Базовый Consumer
Consumer<CounterModel>(
  builder: (context, counter, child) {
    return Text('Счётчик: ${counter.count}');
  },
)

// Consumer с child для оптимизации
Consumer<CounterModel>(
  builder: (context, counter, child) {
    return Column(
      children: [
        Text('Счётчик: ${counter.count}'),
        child!, // Статический дочерний виджет
      ],
    );
  },
  child: const Divider(), // Этот виджет не перестраивается
)
```

### Selector — выборочное прослушивание

```dart
// Selector перестраивается только при изменении выбранного значения
Selector<CounterModel, int>(
  selector: (context, counter) => counter.count,
  builder: (context, count, child) {
    return Text('Счётчик: $count');
  },
)

// Selector с несколькими значениями
Selector2<UserModel, ThemeModel, String>(
  selector: (context, user, theme) => '${user.name} — ${theme.name}',
  builder: (context, text, child) {
    return Text(text);
  },
)
```

### Provider.of — прямой доступ к провайдеру

```dart
// Чтение значения (не подписывается на изменения)
final counter = context.read<CounterModel>();
counter.increment();

// Подписка на изменения (вызывает rebuild при изменении)
final counter = context.watch<CounterModel>();
// counter.count автоматически обновляется

// Для стримов
final stream = context.select<CounterModel, Stream<int>>(
  (model) => model.countStream,
);
```

## Сравнение методов доступа

| Метод | Перестройка | Использование |
|---|---|---|
| `context.read<T>()` | ❌ Нет | Только чтение/запись, без подписки |
| `context.watch<T>()` | ✅ Да | Автоматическая подписка |
| `Consumer<T>` | ✅ Да | Виджет-обёртка для builder |
| `Selector<T, R>` | ✅ Да (условно) | Подписка на конкретное значение |

## Типы провайдеров

### 1. ChangeNotifierProvider

```dart
class TodoModel with ChangeNotifier {
  final List<String> _todos = [];
  List<String> get todos => List.unmodifiable(_todos);

  void addTodo(String todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void removeTodo(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }
}

// Использование
ChangeNotifierProvider(
  create: (_) => TodoModel(),
  child: TodoPage(),
)
```

### 2. StreamProvider

```dart
class WeatherService {
  Stream<String> get weatherUpdates => _controller.stream;
  final StreamController<String> _controller = StreamController<String>();

  void updateWeather(String weather) {
    _controller.add(weather);
  }
}

StreamProvider<String>(
  create: (_) => WeatherService().weatherUpdates,
  initialData: 'Неизвестно',
  child: WeatherDisplay(),
)
```

### 3. FutureProvider

```dart
FutureProvider<List<String>>(
  create: (_) => fetchTodos(),
  child: TodoList(),
)

// С обработкой ошибок
FutureProvider<List<String>>(
  create: (_) => fetchTodos(),
  onError: (error, child) => ErrorWidget(error),
  child: TodoList(),
)
```

### 4. ValueListenableProvider

```dart
ValueListenableProvider<bool>(
  create: (_) => ValueNotifier<bool>(false),
  child: DarkModeToggle(),
)

// Чтение ValueListenable
final isDark = context.watch<bool>();
```

## Best Practices

### ✅ Делайте

- Размещайте провайдеры как можно выше в дереве
- Используйте `Selector` для оптимизации перестройки
- Используйте `const` конструкторы для статических виджетов
- Делите модели на логические группы
- Используйте `ProxyProvider` для зависимых моделей

### ❌ Не делайте

- Не создавайте провайдер в каждом виджете
- Не используйте `context.watch` там, где достаточно `context.read`
- Не храните бизнес-логику в провайдерах
- Не создавайте слишком много провайдеров

## Структура проекта с Provider

```
lib/
├── main.dart
├── models/
│   ├── counter_model.dart
│   ├── user_model.dart
│   └── theme_model.dart
├── providers/
│   ├── counter_provider.dart
│   ├── user_provider.dart
│   └── theme_provider.dart
├── pages/
│   ├── home_page.dart
│   └── profile_page.dart
└── widgets/
    ├── counter_display.dart
    └── theme_toggle.dart
```

## Заключение

Provider — это отличный выбор для проектов среднего размера. Он прост в освоении, хорошо документирован и имеет большое сообщество. Для простых приложений можно использовать только `ChangeNotifierProvider`, а для сложных — комбинацию всех типов провайдеров.

> **Правило:** Используйте Provider для управления состоянием, которое нужно разделить между несколькими виджетами. Для простых локальных состояний используйте `setState()`.
