---
tags:
  - state-management
  - provider
  - bloc
  - riverpod
chapter: 6
section: 10
title: Redux и MobX — альтернативные подходы
alias: 06 10 redux mobx
status: complete
---

# Redux и MobX — альтернативные подходы

## Введение

Помимо Provider, Riverpod и BLoC, в Flutter существуют и другие подходы к управлению состоянием. **Redux** — это паттерн, заимствованный из мира JavaScript, а **MobX** — реактивная библиотека с автоматическим отслеживанием изменений.

> **Ключевая идея:** Redux обеспечивает предсказуемость через однонаправленный поток данных, а MobX — автоматическую реактивность.

## Redux

### Основные концепции

Redux основан на трёх принципах:

1. **Единый источник истины** — всё состояние хранится в одном объекте
2. **State read-only** — состояние можно только читать, не изменять напрямую
3. **Изменения через чистые функции** — редюсеры описывают, как состояние меняется

### Архитектура Redux

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (Widgets)                     │
│  - Отображает состояние                                  │
│  - Dispatches действия (actions)                         │
└─────────────────────────────────────────────────────────┘
                           ↓ Action
┌─────────────────────────────────────────────────────────┐
│                   Reducer                                 │
│  - Чистая функция                                        │
│  - (state, action) → newState                            │
│  - Не имеет побочных эффектов                            │
└─────────────────────────────────────────────────────────┘
                           ↓ New State
┌─────────────────────────────────────────────────────────┐
│                     Store                                 │
│  - Хранит всё состояние                                   │
│  - Предоставляет доступ к состоянию                       │
│  - Уведомляет слушателей при изменении                    │
└─────────────────────────────────────────────────────────┘
```

### Установка

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_redux: ^0.10.0
  redux: ^5.0.0
```

### Пример: Redux Counter

```dart
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

// 1. Определяем состояние
class CounterState {
  final int count;

  CounterState(this.count);

  CounterState copyWith({int? count}) {
    return CounterState(count ?? this.count);
  }
}

// 2. Определяем действия
abstract class CounterAction {}
class IncrementAction extends CounterAction {}
class DecrementAction extends CounterAction {}
class ResetAction extends CounterAction {}

// 3. Определяем редюсер
CounterState counterReducer(CounterState state, dynamic action) {
  if (action is IncrementAction) {
    return CounterState(state.count + 1);
  }
  if (action is DecrementAction) {
    return CounterState(state.count - 1);
  }
  if (action is ResetAction) {
    return CounterState(0);
  }
  return state;
}

// 4. Создаём Store
final store = Store<CounterState>(
  counterReducer,
  initialState: CounterState(0),
);

// 5. Используем в UI
void main() {
  runApp(
    StoreProvider<CounterState>(
      store: store,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redux Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Redux Counter')),
        body: Center(
          child: StoreConnector<CounterState, int>(
            converter: (store) => store.state.count,
            builder: (context, count) {
              return Text(
                'Счётчик: $count',
                style: const TextStyle(fontSize: 48),
              );
            },
          ),
        ),
        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => store.dispatch(IncrementAction()),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () => store.dispatch(DecrementAction()),
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Преимущества и недостатки Redux

| Преимущества | Недостатки |
|---|---|
| Предсказуемость | Много шаблонного кода |
| Простое тестирование | Сложность для начинающих |
| DevTools для отладки | Вертикальное увеличение |
| Time-travel debugging | Не подходит для простых приложений |

## MobX

### Основные концепции

MobX использует реактивное программирование с автоматическим отслеживанием зависимостей:

1. **State** — наблюдаемые данные (`@observable`)
2. **Actions** — изменения состояния (`@action`)
3. **Computed values** — вычисляемые значения (`@computed`)
4. **Reactions** — побочные эффекты (`@effect`, `observer`)

### Установка

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  mobx: ^2.2.0
  flutter_mobx: ^2.1.0

dev_dependencies:
  build_runner: ^2.4.0
  mobx_codegen: ^2.4.0
```

```bash
flutter pub get
flutter pub run build_runner build
```

### Пример: MobX Counter

```dart
import 'package:mobx/mobx.dart';

// Создаём store
class CounterStore = _CounterStore with _$CounterStore;

abstract class _CounterStore with Store {
  @observable
  int count = 0;

  @action
  void increment() {
    count++;
  }

  @action
  void decrement() {
    count--;
  }

  @computed
  String get countMessage => 'Счётчик: $count';

  @action
  void reset() {
    count = 0;
  }
}
```

### Использование в UI

```dart
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CounterPage extends StatelessWidget {
  final CounterStore _store = CounterStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MobX Counter')),
      body: Observer(
        builder: (_) {
          return Center(
            child: Text(
              _store.countMessage,
              style: const TextStyle(fontSize: 48),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _store.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Пример: MobX с данными

```dart
class TodoStore = _TodoStore with _$TodoStore;

abstract class _TodoStore with Store {
  @observable
  ObservableList<TodoItem> todos = ObservableList.of([]);

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @computed
  int get completedCount => todos.where((t) => t.isCompleted).length;

  @computed
  int get remainingCount => todos.where((t) => !t.isCompleted).length;

  @action
  Future<void> fetchTodos() async {
    isLoading = true;
    try {
      todos.clear();
      // Загрузка данных
      todos.addAll(await api.getTodos());
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void addTodo(String title) {
    todos.add(TodoItem(title: title, isCompleted: false));
  }

  @action
  void toggleTodo(int index) {
    todos[index] = TodoItem(
      title: todos[index].title,
      isCompleted: !todos[index].isCompleted,
    );
  }
}

class TodoItem {
  final String title;
  final bool isCompleted;

  TodoItem({required this.title, required this.isCompleted});
}
```

## Сравподход управления состоянием

| Характеристика | Provider | Riverpod | BLoC | Redux | MobX |
|---|---|---|---|---|---|
| **Сложность** | Низкая | Средняя | Высокая | Высокая | Средняя |
| **Тестируемость** | Средняя | Высокая | Высокая | Высокая | Средняя |
| **Шаблоны** | Мало | Мало | Много | Много | Мало |
| **Производительность** | Высокая | Высокая | Средняя | Средняя | Высокая |
| **Сообщество** | Большое | Растущее | Большое | Умеренное | Умеренное |
| **Flutter-first** | Да | Да | Да | Нет | Нет |

## Когда использовать каждый подход

### Используйте Provider, когда:

- Приложение среднего размера
- Нужно простое решение
- Команда знакома с паттерном Observer

### Используйте Riverpod, когда:

- Нужна безопасность типов
- Нужно тестировать без Flutter
- Вы хотите современное решение

### Используйте BLoC, когда:

- Приложение большого размера
- Нужна чёткая архитектура
- Команда знакома с паттерном

### Используйте Redux, когда:

- Команда знает Redux из других проектов
- Нужна максимальная предсказуемость
- Нужен time-travel debugging

### Используйте MobX, когда:

- Нужно автоматическое отслеживание зависимостей
- Приложение имеет сложную реактивность
- Команда хочет меньше шаблонного кода

## Best Practices

### ✅ Делайте

- Выбирайте подход по размеру проекта
- Не переусложняйте архитектуру для простых задач
- Тестируйте бизнес-логику отдельно от UI
- Документируйте архитектуру приложения

### ❌ Не делайте

- Не используйте Redux для простых приложений
- Не смешивайте несколько подходов в одном проекте
- Не создавайте слишком много слоёв абстракции
- Не игнорируйте производительность

## Заключение

Каждый подход к управлению состоянием имеет свои преимущества и недостатки. Выбор зависит от размера проекта, опыта команды и требований приложения.

> **Правило:** Начните с простого решения (setState, Provider) и усложняйте только при необходимости.
