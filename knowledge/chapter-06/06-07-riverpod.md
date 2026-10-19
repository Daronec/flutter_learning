# ScopedModel и Riverpod — альтернативы Provider

## Введение

Помимо Provider, в экосистеме Flutter существуют другие популярные решения для управления состоянием. **Riverpod** — это наиболее современная альтернатива, разработанная тем же автором, что и Provider. **ScopedModel** — более старое решение, которое также стоит знать.

> **Ключевая идея:** Riverpod решает многие проблемы Provider, добавляя безопасность типов и тестирование.

## Riverpod — основы

### Установка

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
```

```bash
flutter pub get
```

### Provider vs Riverpod — ключевые различия

| Характеристика | Provider | Riverpod |
|---|---|---|
| **Зависимость от Flutter** | Да | Нет (можно тестировать без Flutter) |
| **Безопасность типов** | Runtime | Compile-time |
| **Авто-dispose** | Ручной | Автоматический |
| **Тестирование** | Сложнее | Проще |
| **API** | `context.read/watch` | `ref.read/watch` |
| **Генерация кода** | Нет | Есть (riverpod_generator) |

## Основные концепции Riverpod

### 1. StateProvider — простое состояние

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Определение провайдера
final counterProvider = StateProvider<int>((ref) => 0);

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StateProvider')),
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            // Чтение значения
            final count = ref.watch(counterProvider);

            return Text(
              'Счётчик: $count',
              style: Theme.of(context).textTheme.headlineLarge,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Изменение значения
          ref.read(counterProvider.notifier).state++;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 2. StateNotifierProvider — сложное состояние

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Создаём StateNotifier
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

// Определяем провайдер
final counterProvider = StateNotifierProvider<CounterNotifier, int>(
  (ref) => CounterNotifier(),
);

// Использование в виджете
class CounterDisplay extends ConsumerWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Text('Счётчик: $count');
  }
}
```

### 3. ConsumerWidget — базовый виджет

```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(nameProvider);
    final age = ref.watch(ageProvider);

    return Text('$name, $age лет');
  }
}
```

### 4. ConsumerStatefulWidget — с состоянием

```dart
class MyStatefulWidget extends ConsumerStatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);

    return Text(data);
  }
}
```

## Подробный пример: Приложение-список задач

### Модель

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  final String id;
  final String title;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Todo copyWith({String? id, String? title, bool? isCompleted}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  void addTodo(String title) {
    state = [
      ...state,
      Todo(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title),
    ];
  }

  void toggleTodo(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void clearCompleted() {
    state = state.where((todo) => !todo.isCompleted).toList();
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});
```

### Виджеты

```dart
class TodoList extends ConsumerWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => ref.read(todoProvider.notifier).toggleTodo(todo.id),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => ref.read(todoProvider.notifier).removeTodo(todo.id),
          ),
        );
      },
    );
  }
}
```

## Сравнение с Provider

### Provider-версия

```dart
// Модель
class CounterModel with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

// Использование
ChangeNotifierProvider(
  create: (_) => CounterModel(),
  child: Consumer<CounterModel>(
    builder: (context, model, child) {
      return Text('Счётчик: ${model.count}');
    },
  ),
)
```

### Riverpod-версия

```dart
// Провайдер
final counterProvider = StateNotifierProvider<CounterNotifier, int>(
  (ref) => CounterNotifier(),
);

// Использование
ConsumerWidget(
  builder: (context, ref) {
    final count = ref.watch(counterProvider);
    return Text('Счётчик: $count');
  },
)
```

## Best Practices для Riverpod

### ✅ Делайте

- Используйте `StateNotifierProvider` для сложного состояния
- Используйте `StateProvider` для простых значений
- Используйте `Family` для параметризованных провайдеров
- Используйте `AutoDispose` для провайдеров, которые можно удалить
- Тестируйте провайдеры без Flutter

### ❌ Не делайте

- Не создавайте провайдеры внутри `build()`
- Не используйте `ref.read` там, где нужен `ref.watch`
- Не забывайте о жизненном цикле провайдеров

## Заключение

Riverpod — это современная и мощная альтернатива Provider. Он решает многие проблемы Provider и предоставляет более безопасный и тестируемый API. Для новых проектов рекомендуется использовать Riverpod.

> **Правило:** Используйте Riverpod для новых проектов. Используйте Provider для существующих проектов, чтобы избежать рефакторинга.
