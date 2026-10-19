# ChangeNotifier и Consumer

## Введение

`ChangeNotifier` — это базовый класс из `flutter/foundation.dart`, который реализует паттерн Наблюдатель (Observer). Он позволяет виджетам подписываться на изменения данных и автоматически обновлять UI при их изменении.

> **Ключевая идея:** `ChangeNotifier` хранит данные и уведомляет всех подписчиков об их изменении.

## Основы ChangeNotifier

### Базовый класс

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Создаём модель, наследуясь от ChangeNotifier
class CounterModel with ChangeNotifier {
  int _value = 0;

  // Геттер для чтения значения
  int get value => _value;

  // Метод изменения состояния
  void increment() {
    _value++;
    notifyListeners(); // Уведомляем всех слушателей
  }

  void decrement() {
    _value--;
    notifyListeners();
  }

  void reset() {
    _value = 0;
    notifyListeners();
  }
}
```

### Как работает notifyListeners()

```
notifyListeners() вызван
    ↓
Перебирается список всех зарегистрированных слушателей
    ↓
Каждому слушателю отправляется уведомление
    ↓
Каждый слушатель вызывает setState() или rebuild()
    ↓
UI обновляется
```

## Использование Consumer

### Consumer — базовый пример

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConsumerExample extends StatelessWidget {
  const ConsumerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consumer Example')),
      body: Center(
        child: Consumer<CounterModel>(
          builder: (context, counter, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Значение: ${counter.value}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                child!, // Статический дочерний виджет
              ],
            );
          },
          child: const Divider(height: 32), // Не перестраивается
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterModel>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Consumer с несколькими значениями

```dart
class UserDisplay extends StatelessWidget {
  const UserDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserModel, ThemeModel>(
      builder: (context, user, theme, child) {
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: Text(user.name[0]),
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
          ),
        );
      },
    );
  }
}
```

### Consumer с Selector

```dart
class OptimizedCounter extends StatelessWidget {
  const OptimizedCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CounterModel, int>(
      selector: (context, counter) => counter.value,
      builder: (context, value, child) {
        return Text(
          'Счётчик: $value',
          style: const TextStyle(fontSize: 48),
        );
      },
    );
  }
}
```

## Создание ChangeNotifier классов

### Простой ChangeNotifier

```dart
class SimpleModel with ChangeNotifier {
  String _text = 'Привет, мир!';

  String get text => _text;

  void updateText(String newText) {
    _text = newText;
    notifyListeners();
  }
}
```

### ChangeNotifier с коллекцией

```dart
class TodoModel with ChangeNotifier {
  final List<TodoItem> _items = [];

  // Делаем копию списка для безопасности
  List<TodoItem> get items => List.unmodifiable(_items);

  int get completedCount => _items.where((item) => item.isCompleted).length;

  void addTodo(String title) {
    _items.add(TodoItem(title: title, isCompleted: false));
    notifyListeners();
  }

  void toggleTodo(int index) {
    _items[index] = TodoItem(
      title: _items[index].title,
      isCompleted: !_items[index].isCompleted,
    );
    notifyListeners();
  }

  void removeTodo(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCompleted() {
    _items.removeWhere((item) => item.isCompleted);
    notifyListeners();
  }
}

class TodoItem {
  final String title;
  final bool isCompleted;

  TodoItem({required this.title, required this.isCompleted});
}
```

### ChangeNotifier с асинхронными операциями

```dart
class UserDataModel with ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchUser(int userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await UserService.fetchUser(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(String name) async {
    if (_user == null) return;

    _loading = true;
    notifyListeners();

    try {
      _user = User(id: _user!.id, name: name);
      await UserService.saveUser(_user!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
```

## Использование notifyListeners()

### Когда вызывать notifyListeners()

```dart
class SettingsModel with ChangeNotifier {
  bool _isDarkMode = false;
  int _fontSize = 16;
  String _language = 'ru';

  bool get isDarkMode => _isDarkMode;
  int get fontSize => _fontSize;
  String get language => _language;

  // ✅ Вызываем notifyListeners() при каждом изменении
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setFontSize(int size) {
    _fontSize = size;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }
}
```

### Оптимизация: вызываем notifyListeners() только при необходимости

```dart
class OptimizedModel with ChangeNotifier {
  List<String> _items = [];

  List<String> get items => List.unmodifiable(_items);

  // ❌ Плохо — notifyListeners() вызывается всегда
  void addItem(String item) {
    _items.add(item);
    notifyListeners(); // Всегда
  }

  // ✅ Хорошо — notifyListeners() только при реальном изменении
  void addItemOptimized(String item) {
    if (!_items.contains(item)) {
      _items.add(item);
      notifyListeners();
    }
  }

  // ✅ Хорошо — batch-изменения
  void addMultipleItems(List<String> newItems) {
    final hasChanges = newItems.any((item) => !_items.contains(item));
    if (hasChanges) {
      _items.addAll(newItems.where((item) => !_items.contains(item)));
      notifyListeners();
    }
  }
}
```

## Performance Tips

### 1. Используйте const для статических виджетов

```dart
class EfficientList extends StatelessWidget {
  final List<String> items;
  const EfficientList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]),
          subtitle: const Text('Статический подзаголовок'),
        );
      },
    );
  }
}
```

### 2. Используйте Selector для оптимизации

```dart
// ❌ Плохо — перестраивается при любом изменении модели
Consumer<UserModel>(
  builder: (context, user, child) {
    return Text(user.name);
  },
)

// ✅ Хорошо — перестраивается только при изменении name
Selector<UserModel, String>(
  selector: (context, user) => user.name,
  builder: (context, name, child) {
    return Text(name);
  },
)
```

### 3. Избегайте вложенных Consumer

```dart
// ❌ Плохо — вложенные Consumer
Consumer<UserModel>(
  builder: (context, user, child) {
    return Consumer<OrderModel>(
      builder: (context, order, child2) {
        return Text('${user.name}: ${order.total}');
      },
    );
  },
)

// ✅ Хорошо — один Consumer с Selector
Selector2<UserModel, OrderModel, String>(
  selector: (context, user, order) => '${user.name}: ${order.total}',
  builder: (context, text, child) {
    return Text(text);
  },
)
```

### 4. Используйте context.read вместо context.watch

```dart
// ❌ Плохо — перестраивается при изменении модели
ElevatedButton(
  onPressed: () {
    final user = context.watch<UserModel>(); // Подписка
    user.logout();
  },
  child: const Text('Выйти'),
)

// ✅ Хорошо — не перестраивается при изменении модели
ElevatedButton(
  onPressed: () {
    final user = context.read<UserModel>(); // Без подписки
    user.logout();
  },
  child: const Text('Выйти'),
)
```

## Best Practices

### ✅ Делайте

- Используйте `with ChangeNotifier` для миксинов
- Делайте геттеры для публичного доступа к данным
- Вызывайте `notifyListeners()` после каждого изменения
- Используйте `List.unmodifiable()` для списков
- Используйте `Selector` для оптимизации
- Проверяйте `mounted` перед `notifyListeners()` в асинхронном коде

### ❌ Не делайте

- Не вызывайте `notifyListeners()` без необходимости
- Не храните в `ChangeNotifier` виджеты
- Не выполняйте тяжёлые вычисления в `notifyListeners()`
- Не создавайте `ChangeNotifier` внутри `build()`

## Заключение

`ChangeNotifier` — это простой и эффективный способ управления состоянием. В сочетании с `Consumer` и `Provider` он покрывает большинство сценариев управления состоянием в Flutter-приложениях.

> **Правило:** Используйте `ChangeNotifier` для управления состоянием, которое нужно разделить между несколькими виджетами. Для простых локальных состояний используйте `setState()`.
