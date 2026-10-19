# BLoC (Business Logic Component) — паттерн проектирования

## Введение

**BLoC (Business Logic Component)** — это паттерн проектирования, который разделяет бизнес-логику и UI. Он основан на реактивном программировании и использует Streams для передачи данных между слоями приложения.

> **Ключевая идея:** BLoC получает события (Events) и генерирует состояния (States). UI реагирует на изменения состояний.

## Принципы BLoC

### 1. Разделение ответственности

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (Widgets)                     │
│  - Отображает данные                                     │
│  - Генерирует события при взаимодействии                 │
└─────────────────────────────────────────────────────────┘
                           ↓ Events
┌─────────────────────────────────────────────────────────┐
│                 BLoC Layer (Logic)                       │
│  - Принимает события                                     │
│  - Обрабатывает бизнес-логику                            │
│  - Генерирует состояния                                  │
└─────────────────────────────────────────────────────────┘
                           ↓ States
┌─────────────────────────────────────────────────────────┐
│                    UI Layer (Widgets)                     │
│  - Реагирует на изменения состояний                      │
│  - Перестраивает UI                                      │
└─────────────────────────────────────────────────────────┘
```

### 2. Однонаправленный поток данных

```
UI → Event → BLoC → State → UI
```

## Установка

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.0
  bloc: ^8.1.0
```

```bash
flutter pub get
```

## Основы BLoC

### 1. Определение событий и состояний

```dart
// События — что может произойти
abstract class CounterEvent {}

class CounterIncrementPressed extends CounterEvent {}
class CounterDecrementPressed extends CounterEvent {}
class CounterResetPressed extends CounterEvent {}

// Состояния — что может быть отображено
abstract class CounterState {
  final int count;

  CounterState({required this.count});
}

class CounterInitial extends CounterState {
  CounterInitial() : super(count: 0);
}

class CounterIncremented extends CounterState {
  CounterIncremented(int count) : super(count: count);
}

class CounterDecremented extends CounterState {
  CounterDecremented(int count) : super(count: count);
}

class CounterResetted extends CounterState {
  CounterResetted(int count) : super(count: count);
}
```

### 2. Создание BLoC

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    // Обработка событий
    on<CounterIncrementPressed>(_onIncrement);
    on<CounterDecrementPressed>(_onDecrement);
    on<CounterResetPressed>(_onReset);
  }

  void _onIncrement(CounterIncrementPressed event, Emitter<CounterState> emit) {
    emit(CounterIncremented(state.count + 1));
  }

  void _onDecrement(CounterDecrementPressed event, Emitter<CounterState> emit) {
    emit(CounterDecremented(state.count - 1));
  }

  void _onReset(CounterResetPressed event, Emitter<CounterState> emit) {
    emit(CounterResetted(0));
  }
}
```

### 3. Использование в UI

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('BLoC Counter')),
        body: BlocBuilder<CounterBloc, CounterState>(
          builder: (context, state) {
            return Center(
              child: Text(
                'Счётчик: ${state.count}',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            );
          },
        ),
        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => context.read<CounterBloc>().add(CounterIncrementPressed()),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              onPressed: () => context.read<CounterBloc>().add(CounterDecrementPressed()),
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      ),
    );
  }
}
```

## flutter_bloc package

### Основные виджеты

| Виджет | Назначение |
|---|---|
| `BlocProvider` | Предоставляет BLoC виджетам |
| `BlocBuilder` | Строит UI на основе состояний |
| `BlocListener` | Выполняет действия при изменении состояний |
| `BlocConsume` | Одноразовое получение состояния |

### BlocBuilder — построение UI

```dart
BlocBuilder<CounterBloc, CounterState>(
  builder: (context, state) {
    if (state is CounterInitial) {
      return const Text('Начальное состояние');
    } else if (state is CounterIncremented) {
      return Text('Счётчик: ${state.count}');
    } else if (state is CounterDecremented) {
      return Text('Счётчик: ${state.count}');
    }
    return const Text('Неизвестное состояние');
  },
)
```

### BlocListener — побочные эффекты

```dart
BlocListener<CounterBloc, CounterState>(
  listener: (context, state) {
    if (state is CounterResetted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Счётчик сброшен')),
      );
    }
  },
  child: BlocBuilder<CounterBloc, CounterState>(
    builder: (context, state) {
      return Text('Счётчик: ${state.count}');
    },
  ),
)
```

## Архитектура BLoC

### Слои приложения

```
lib/
├── main.dart
├── blocs/
│   ├── counter/
│   │   ├── counter_event.dart
│   │   ├── counter_state.dart
│   │   └── counter_bloc.dart
│   ├── auth/
│   │   ├── auth_event.dart
│   │   ├── auth_state.dart
│   │   └── auth_bloc.dart
│   └── todos/
│       ├── todo_event.dart
│       ├── todo_state.dart
│       └── todo_bloc.dart
├── repositories/
│   ├── auth_repository.dart
│   └── todo_repository.dart
├── models/
│   ├── user.dart
│   └── todo.dart
└── pages/
    ├── counter_page.dart
    ├── auth_page.dart
    └── todos_page.dart
```

### Пример: BLoC с репозиторием

```dart
// Репозиторий
class TodoRepository {
  Future<List<Todo>> fetchTodos() async {
    // Запрос к API
    return await api.getTodos();
  }

  Future<void> saveTodo(Todo todo) async {
    await api.saveTodo(todo);
  }
}

// События
abstract class TodoEvent {}

class TodoLoaded extends TodoEvent {}
class TodoAdded extends TodoEvent {
  final String title;
  TodoAdded(this.title);
}

class TodoToggled extends TodoEvent {
  final String id;
  TodoToggled(this.id);
}

// Состояния
abstract class TodoState {
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

  TodoState({required this.todos, required this.isLoading, this.error});

  TodoState.initial() : this(todos: [], isLoading: false);
}

class TodoLoading extends TodoState {
  TodoLoading() : super(todos: [], isLoading: true);
}

class TodoLoadedState extends TodoState {
  TodoLoadedState({required List<Todo> todos})
      : super(todos: todos, isLoading: false);
}

class TodoErrorState extends TodoState {
  TodoErrorState(String error) : super(todos: [], isLoading: false, error: error);
}

// BLoC
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repository;

  TodoBloc(this._repository) : super(TodoState.initial()) {
    on<TodoLoaded>(_onTodoLoaded);
    on<TodoAdded>(_onTodoAdded);
    on<TodoToggled>(_onTodoToggled);
  }

  Future<void> _onTodoLoaded(
    TodoLoaded event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodoLoading());
    try {
      final todos = await _repository.fetchTodos();
      emit(TodoLoadedState(todos: todos));
    } catch (e) {
      emit(TodoErrorState(e.toString()));
    }
  }

  Future<void> _onTodoAdded(
    TodoAdded event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoadedState) {
      final newTodo = Todo(id: DateTime.now().toString(), title: event.title);
      await _repository.saveTodo(newTodo);
      emit(TodoLoadedState(todos: [...currentState.todos, newTodo]));
    }
  }

  Future<void> _onTodoToggled(
    TodoToggled event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoadedState) {
      final updatedTodos = currentState.todos.map((todo) {
        if (todo.id == event.id) {
          return todo.copyWith(isCompleted: !todo.isCompleted);
        }
        return todo;
      }).toList();
      emit(TodoLoadedState(todos: updatedTodos));
    }
  }
}
```

## Best Practices

### ✅ Делайте

- Делайте события и состояния независимыми классами
- Используйте `emit` вместо `add` для изменения состояния
- Обрабатывайте ошибки в BLoC
- Используйте `BlocListener` для побочных эффектов
- Тестируйте BLoC отдельно от UI

### ❌ Не делайте

- Не размещайте бизнес-логику в UI
- Не создавайте слишком много событий
- Не смешивайте разные домены в одном BLoC
- Не обращайтесь к API напрямую из UI

## Заключение

BLoC — это мощный паттерн для управления состоянием в сложных приложениях. Он обеспечивает чёткое разделение ответственности и делает код легко тестируемым.

> **Правило:** Используйте BLoC для приложений среднего и большого размера. Для простых приложений используйте Provider или Riverpod.
