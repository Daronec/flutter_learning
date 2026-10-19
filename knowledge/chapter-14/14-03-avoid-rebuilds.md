# 14-03. Избегание лишних rebuild'ов

## Введение

Один из самых частых источников проблем с производительностью в Flutter — это избыточные rebuild'ы виджетов. Каждый вызов `setState()` запускает перестройку всего поддерева виджетов, что может привести к заметным задержкам, особенно в сложных интерфейсах.

## Как работает setState

### Что делает setState

```dart
setState(() {
  _counter++;
});
```

Метод `setState()` выполняет следующие действия:

1. Помечает виджет как нуждающийся в перестройке
2. Запускает `build()` метод для этого виджета и всех его дочерних виджетов
3. Создаёт новое дерево виджетов
4. Сравнивает с предыдущим деревом
5. Обновляет только изменившиеся элементы

### Проблема: rebuild всего дерева

```dart
class ProblemWidget extends StatefulWidget {
  @override
  State<ProblemWidget> createState() => _ProblemWidgetState();
}

class _ProblemWidgetState extends State<ProblemWidget> {
  int _counter = 0;
  String _name = 'User';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // При изменении _counter перестраивается ВСЁ дерево
        Text('$_name'),
        Text('$_counter'),
        ElevatedButton(
          onPressed: () => setState(() => _counter++),
          child: const Text('Increment'),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _name = 'Admin'),
          child: const Text('Change Name'),
        ),
      ],
    );
  }
}
```

При нажатии кнопки "Increment" перестраивается весь `Column`, включая `Text('$_name')`, хотя он не изменился.

## Stateless vs Stateful виджеты

### Когда использовать StatelessWidget

`StatelessWidget` не перестраивается при изменении состояния — он rebuild'ится только когда родитель вызывает `setState()`:

```dart
// StatelessWidget — не перестраивается сам по себе
class CounterDisplay extends StatelessWidget {
  final int count;
  const CounterDisplay({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text('$count');
  }
}

class NameDisplay extends StatelessWidget {
  final String name;
  const NameDisplay({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(name);
  }
}
```

### Когда использовать StatefulWidget

`StatefulWidget` нужен, когда виджет должен управлять своим собственным состоянием:

```dart
class CounterButton extends StatefulWidget {
  final Function(int) onIncrement;
  const CounterButton({super.key, required this.onIncrement});

  @override
  State<CounterButton> createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton> {
  int _pressCount = 0;

  void _handleTap() {
    setState(() => _pressCount++);
    widget.onIncrement(_pressCount);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handleTap,
      child: Text('Pressed: $_pressCount'),
    );
  }
}
```

### Разделение состояния

Ключевой принцип: выносите состояние в отдельные виджеты, чтобы минимизировать область rebuild'а:

```dart
// Плохо — всё в одном виджете
class BadExample extends StatefulWidget {
  @override
  State<BadExample> createState() => _BadExampleState();
}

class _BadExampleState extends State<BadExample> {
  int _counter = 0;
  String _name = 'User';
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_name),
        Text('$_counter'),
        Visibility(
          visible: _isVisible,
          child: const Text('Hidden'),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _counter++),
          child: const Text('Inc'),
        ),
      ],
    );
  }
}

// Хорошо — разделение по виджетам
class GoodExample extends StatefulWidget {
  @override
  State<GoodExample> createState() => _GoodExampleState();
}

class _GoodExampleState extends State<GoodExample> {
  int _counter = 0;
  String _name = 'User';
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Этот виджет rebuild'ится только при изменении _name
        NameDisplay(name: _name),
        // Этот виджет rebuild'ится только при изменении _counter
        CounterDisplay(count: _counter),
        // Этот виджет rebuild'ится только при изменении _isVisible
        VisibilityWidget(visible: _isVisible),
        // Этот виджет rebuild'ится только при изменении _counter
        IncrementButton(
          onIncrement: () => setState(() => _counter++),
        ),
      ],
    );
  }
}

class NameDisplay extends StatelessWidget {
  final String name;
  const NameDisplay({super.key, required this.name});

  @override
  Widget build(BuildContext context) => Text(name);
}

class CounterDisplay extends StatelessWidget {
  final int count;
  const CounterDisplay({super.key, required this.count});

  @override
  Widget build(BuildContext context) => Text('$count');
}

class VisibilityWidget extends StatelessWidget {
  final bool visible;
  const VisibilityWidget({super.key, required this.visible});

  @override
  Widget build(BuildContext context) =>
      Visibility(visible: visible, child: const Text('Hidden'));
}

class IncrementButton extends StatelessWidget {
  final VoidCallback onIncrement;
  const IncrementButton({super.key, required this.onIncrement});

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onIncrement, child: const Text('Inc'));
}
```

## Selector Widget

### Паттерн Selector

Selector — это паттерн, который позволяет перестраивать только те виджеты, которые зависят от конкретных частей состояния.

### Реализация Selector

```dart
// Базовый Selector
class Selector<T, S> extends StatelessWidget {
  final T Function(BuildContext) selector;
  final Widget Function(BuildContext, S) builder;
  final Widget? child;

  const Selector({
    super.key,
    required this.selector,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем значение через selector
    final selected = selector(context);
    return builder(context, selected);
  }
}
```

### Использование с Provider

```dart
import 'package:provider/provider.dart';

// Модель состояния
class AppState extends ChangeNotifier {
  int _counter = 0;
  String _name = 'User';
  bool _isLoading = false;

  int get counter => _counter;
  String get name => _name;
  bool get isLoading => _isLoading;

  void increment() {
    _counter++;
    notifyListeners();
  }

  void updateName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

// Виджет, rebuild'ится только при изменении counter
class CounterWidget extends StatelessWidget {
  const CounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, int>(
      selector: (context) => context.select((AppState state) => state.counter),
      builder: (context, counter, _) {
        return Text('Counter: $counter');
      },
    );
  }
}

// Виджет, rebuild'ится только при изменении name
class NameWidget extends StatelessWidget {
  const NameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, String>(
      selector: (context) => context.select((AppState state) => state.name),
      builder: (context, name, _) {
        return Text('Name: $name');
      },
    );
  }
}

// Виджет, rebuild'ится только при изменении isLoading
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, bool>(
      selector: (context) => context.select((AppState state) => state.isLoading),
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const CircularProgressIndicator();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
```

### Механизм select

Метод `context.select()` — это ключевая функция для избежания лишних rebuild'ов:

```dart
// select отслеживает конкретное значение
// Виджет перестраивается ТОЛЬКО когда это значение меняется
int counter = context.select((AppState state) => state.counter);

// Аналогично для вложенных свойств
String userName = context.select((AppState state) => state.user.name);
```

### Сравнение подходов

| Подход | Rebuild'ится при | Сложность |
|--------|-----------------|-----------|
| `setState()` в родительском | Любое изменение в State | Низкая |
| Разделение виджетов | Изменение конкретного состояния | Средняя |
| `Selector` + `select` | Изменение выбранного значения | Низкая |
| `ValueListenableBuilder` | Изменение ValueListenable | Низкая |

## ValueListenableBuilder

### Использование ValueListenableBuilder

`ValueListenableBuilder` — это встроенный виджет Flutter для реактивного обновления:

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  final ValueNotifier<String> _name = ValueNotifier<String>('User');

  @override
  void dispose() {
    _counter.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rebuild'ится только при изменении _counter
        ValueListenableBuilder<int>(
          valueListenable: _counter,
          builder: (context, value, child) {
            return Text('Counter: $value');
          },
        ),
        // Rebuild'ится только при изменении _name
        ValueListenableBuilder<String>(
          valueListenable: _name,
          builder: (context, value, child) {
            return Text('Name: $value');
          },
        ),
        ElevatedButton(
          onPressed: () => _counter.value++,
          child: const Text('Increment Counter'),
        ),
        ElevatedButton(
          onPressed: () => _name.value = 'Admin',
          child: const Text('Change Name'),
        ),
      ],
    );
  }
}
```

## InheritedWidget и наследуемые зависимости

### Создание кастомного Selector

```dart
class SelectableWidget<T> extends InheritedWidget {
  final T Function(BuildContext) selector;
  final Widget child;

  const SelectableWidget({
    super.key,
    required this.selector,
    required super.child,
  });

  static SelectableWidget<T> of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SelectableWidget<T>>()!;
  }

  @override
  bool updateShouldNotify(SelectableWidget<T> oldWidget) {
    return true;
  }
}

class SelectorExample extends StatefulWidget {
  @override
  State<SelectorExample> createState() => _SelectorExampleState();
}

class _SelectorExampleState extends State<SelectorExample> {
  int _counter = 0;
  String _name = 'User';

  @override
  Widget build(BuildContext context) {
    return SelectableWidget<int>(
      selector: (context) => _counter,
      child: Column(
        children: [
          // Rebuild'ится только при изменении _counter
          Text('$_counter'),
          // Rebuild'ится только при изменении _name
          Text('$_name'),
          ElevatedButton(
            onPressed: () => setState(() => _counter++),
            child: const Text('Inc'),
          ),
        ],
      ),
    );
  }
}
```

## Best Practices

### Рекомендации по избежанию лишних rebuild'ов

1. **Используйте StatelessWidget там, где это возможно** — они не имеют собственного состояния
2. **Разделяйте виджеты по состоянию** — каждый виджет должен зависеть только от своего состояния
3. **Используйте `context.select()` с Provider** — это самый простой и эффективный способ
4. **Используйте `ValueListenableBuilder` для простых случаев** — встроенный виджет без зависимостей
5. **Избегайте `setState()` в больших деревьях виджетов** — выносите состояние вниз
6. **Используйте `const` для статических дочерних виджетов** — это уменьшает работу при сравнении

### Чек-лист оптимизации rebuild'ов

- [ ] Все независимые части UI вынесены в отдельные виджеты
- [ ] Используется `context.select()` для подписки на конкретные значения
- [ ] Нет `setState()` в корневом виджете с большим деревом дочерних виджетов
- [ ] `ValueNotifier` используется для простых уведомлений
- [ ] Все статические виджеты помечены как `const`
- [ ] Performance Overlay показывает стабильный FPS

## Заключение

Избегание лишних rebuild'ов — это одна из самых важных техник оптимизации в Flutter. Правильное разделение виджетов и использование `Selector`/`select` позволяет перестраивать только те части интерфейса, которые действительно изменились. Это приводит к значительному улучшению производительности, особенно в сложных приложениях.
