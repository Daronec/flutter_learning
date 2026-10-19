# ValueListenableBuilder и ListenableBuilder

## Введение

`ValueListenableBuilder` и `ListenableBuilder` — это виджеты-построители, которые позволяют реактивно обновлять UI при изменении данных. Они являются частью фреймворка Flutter и не требуют дополнительных пакетов.

> **Ключевая идея:** Эти виджеты автоматически подписываются на изменения и перестраиваются только при их возникновении.

## ValueListenableBuilder

### Основы

`ValueListenableBuilder` перестраивается, когда связанный `ValueListenable`发出 уведомление. Он идеален для одиночных значений.

### Базовый синтаксис

```dart
ValueListenableBuilder<T>(
  valueListenable: myNotifier,
  builder: (context, value, child) {
    return Text('Значение: $value');
  },
  child: child, // Опциональный дочерний виджет
)
```

### Пример: ValueNotifier

```dart
import 'package:flutter/material.dart';

class ValueNotifierExample extends StatefulWidget {
  const ValueNotifierExample({super.key});

  @override
  State<ValueNotifierExample> createState() => _ValueNotifierExampleState();
}

class _ValueNotifierExampleState extends State<ValueNotifierExample> {
  // ValueNotifier — простой способ хранения одного значения
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  @override
  void dispose() {
    _counter.dispose(); // Обязательно освобождаем ресурсы
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ValueNotifier Example')),
      body: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: _counter,
          builder: (context, count, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Счётчик: $count',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                child!, // Статический дочерний виджет
              ],
            );
          },
          child: const Divider(height: 32),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _counter.value++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Пример: TextField с ValueNotifier

```dart
class SearchExample extends StatefulWidget {
  const SearchExample({super.key});

  @override
  State<SearchExample> createState() => _SearchExampleState();
}

class _SearchExampleState extends State<SearchExample> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

  @override
  void dispose() {
    _controller.dispose();
    _searchQuery.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchQuery.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поиск')),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Введите запрос...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const Divider(height: 1),
          // Фильтрованный список
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: _searchQuery,
              builder: (context, query, child) {
                final filtered = allItems.where((item) {
                  return item.toLowerCase().contains(query.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('Ничего не найдено'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(filtered[index]));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Пример: ValueListenableBuilder с анимацией

```dart
class AnimatedSliderExample extends StatefulWidget {
  const AnimatedSliderExample({super.key});

  @override
  State<AnimatedSliderExample> createState() => _AnimatedSliderExampleState();
}

class _AnimatedSliderExampleState extends State<AnimatedSliderExample> {
  final ValueNotifier<double> _opacity = ValueNotifier<double>(1.0);

  @override
  void dispose() {
    _opacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Анимация')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: _opacity,
              builder: (context, opacity, child) {
                return AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 300),
                  child: const Text(
                    'Привет, мир!',
                    style: TextStyle(fontSize: 48),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Slider(
              value: _opacity.value,
              onChanged: (value) => _opacity.value = value,
            ),
          ],
        ),
      ),
    );
  }
}
```

## ListenableBuilder

### Основы

`ListenableBuilder` работает с любым `Listenable` (включая `ChangeNotifier`, `ValueNotifier`, `Animation`, `Stream`). Он более универсален, чем `ValueListenableBuilder`.

### Базовый синтаксис

```dart
ListenableBuilder(
  listenable: myListenable,
  builder: (context, child) {
    return Text('Обновлено');
  },
  child: child,
)
```

### Пример: ListenableBuilder с ChangeNotifier

```dart
class ListenableBuilderExample extends StatelessWidget {
  final CounterModel _model = CounterModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ListenableBuilder Example')),
      body: Center(
        child: ListenableBuilder(
          listenable: _model,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Счётчик: ${_model.count}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                child!,
              ],
            );
          },
          child: const Divider(height: 32),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _model.increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CounterModel with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}
```

### Пример: ListenableBuilder с Animation

```dart
class AnimationBuilderExample extends StatefulWidget {
  const AnimationBuilderExample({super.key});

  @override
  State<AnimationBuilderExample> createState() =>
      _AnimationBuilderExampleState();
}

class _AnimationBuilderExampleState
    extends State<AnimationBuilderExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation Builder')),
      body: Center(
        child: ListenableBuilder(
          listenable: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: const Text(
                'Анимация!',
                style: TextStyle(fontSize: 48),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _controller.reverse(),
        child: const Icon(Icons.replay),
      ),
    );
  }
}
```

## Сравнение ValueListenableBuilder и ListenableBuilder

| Характеристика | ValueListenableBuilder | ListenableBuilder |
|---|---|---|
| **Тип данных** | Одно значение | Любой Listenable |
| **Доступ к значению** | `value` в builder | Только через listenable |
| **Производительность** | Оптимизирован для одного значения | Более общий |
| **Синтаксис** | `builder: (ctx, value, child)` | `builder: (ctx, child)` |
| **Идеально для** | ValueNotifier, TextEditingController | Animation, ChangeNotifier |

## Когда использовать каждый

### Используйте ValueListenableBuilder, когда:

1. Нужно отслеживать одно конкретное значение
2. Значение меняется часто (например, ввод текста)
3. Значение нужно передать в builder напрямую

```dart
// Идеально для ValueNotifier
ValueListenableBuilder<String>(
  valueListenable: _searchQuery,
  builder: (context, query, child) {
    return Text('Вы ищете: $query');
  },
)
```

### Используйте ListenableBuilder, когда:

1. Нужно отслеживать Animation
2. Нужно отслеживать ChangeNotifier без доступа к значениям
3. Нужно отслеживать несколько Listenable одновременно

```dart
// Идеально для Animation
ListenableBuilder(
  listenable: _animation,
  builder: (context, child) {
    return Transform.scale(
      scale: _animation.value,
      child: child,
    );
  },
)
```

## Best Practices

### ✅ Делайте

- Вызывайте `dispose()` для всех ValueNotifier и Listenable
- Используйте `child` параметр для статических виджетов
- Используйте `ValueListenableBuilder` для одиночных значений
- Используйте `ListenableBuilder` для анимаций и ChangeNotifier

### ❌ Не делайте

- Не создавайте ValueNotifier внутри `build()`
- Не забывайте освобождать ресурсы через `dispose()`
- Не используйте `ListenableBuilder` там, где достаточно `ValueListenableBuilder`

## Заключение

`ValueListenableBuilder` и `ListenableBuilder` — это мощные встроенные виджеты Flutter для реактивного обновления UI. Они не требуют дополнительных пакетов и хорошо интегрируются с другими механизмами управления состоянием.

> **Правило:** Используйте `ValueListenableBuilder` для одиночных значений и `ListenableBuilder` для анимаций и сложных Listenable.
