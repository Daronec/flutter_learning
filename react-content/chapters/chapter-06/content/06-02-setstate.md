# setState() — основы обновления состояния

## Введение

`setState()` — это основной механизм обновления состояния в Flutter. Он является частью `State`-класса и сообщает фреймворку, что внутреннее состояние виджета изменилось, и его необходимо перестроить.

> **Ключевая идея:** `setState()` не обновляет UI напрямую — он лишь планирует перестройку виджета.

## Как работает setState()

### Цикл перестройки

```
setState() вызван
    ↓
Flutter отмечает виджет как «нуждающийся в перестройке» (dirty)
    ↓
В конце текущего кадра фреймворк вызывает build()
    ↓
Виджет перестраивается с новыми данными
    ↓
UI обновлён
```

### Базовый пример

```dart
import 'package:flutter/material.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пример setState')),
      body: Center(
        child: Text(
          'Счётчик: $_counter',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Что именно делает setState()

1. **Отмечает виджет как dirty** — фреймворк помечает виджет, который нужно перестроить
2. **Планирует перестройку** — перестройка происходит в конце текущего кадра
3. **Вызывает build()** — виджет перестраивается с новыми данными
4. **Сравнивает дерево** — фреймворк использует `Element` для сравнения старого и нового дерева

## Что НЕ делает setState()

- ❌ Не обновляет UI мгновенно
- ❌ Не перестраивает всё приложение
- ❌ Не перестраивает дочерние виджеты, если они не зависят от состояния
- ❌ Не вызывает `initState()` или `dispose()`

## Типы перестройки

### Полная перестройка

```dart
// Перестраивается весь виджет и его дочерние виджеты
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Счётчик: $_counter'),
      Text('Дата: ${DateTime.now()}'), // Эта строка будет перестроена
      const Divider(),
      Text('Постоянный текст'), // Этот виджет тоже перестроится
    ],
  );
}
```

### Оптимизированная перестройка

```dart
// Используем const для статических виджетов
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Счётчик: $_counter'),
      const Divider(), // const — не будет перестраиваться
      const Text('Постоянный текст'), // const — не будет перестраиваться
    ],
  );
}
```

## Performance: что учитывать

### Стоимость перестройки

```
setState() вызван
    ↓
build() вызывается для этого виджета
    ↓
build() вызывается для ВСЕХ дочерних виджетов
    ↓
Каждый дочерний виджет вызывает свой build()
    ↓
ElementTree сравнивает старое и новое дерево
    ↓
Только изменённые RenderObjects обновляются
```

### Оптимизация перестройки

#### 1. Используйте `const` конструкторы

```dart
// ❌ Плохо — каждый раз создаётся новый виджет
ListView(
  children: List.generate(100, (i) => ListTile(title: Text('Item $i'))),
)

// ✅ Хорошо — статические виджеты помечены как const
ListView(
  children: List.generate(100, (i) {
    return ListTile(
      title: Text('Item $i'), // Динамический
      subtitle: const Text('Подзаголовок'), // Статический — const
    );
  }),
)
```

#### 2. Выносите виджеты в отдельные классы

```dart
// ❌ Плохо — виджет создаётся внутри build()
class BadExample extends StatefulWidget {
  @override
  State<BadExample> createState() => _BadExampleState();
}

class _BadExampleState extends State<BadExample> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Каждый раз создаётся новый класс
        _DynamicWidget(count: _count),
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: const Text('Update'),
        ),
      ],
    );
  }
}

// ✅ Хорошо — отдельный класс виджета
class GoodExample extends StatefulWidget {
  @override
  State<GoodExample> createState() => _GoodExampleState();
}

class _GoodExampleState extends State<GoodExample> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Экземпляр создаётся один раз
        DynamicWidget(count: _count),
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class DynamicWidget extends StatelessWidget {
  final int count;
  const DynamicWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Text('Count: $count');
  }
}
```

#### 3. Используйте `AutomaticKeepAliveClientMixin`

```dart
class KeepAliveWidget extends StatefulWidget {
  const KeepAliveWidget({super.key});

  @override
  State<KeepAliveWidget> createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Обязательно для AutomaticKeepAliveClientMixin
    return const Text('Сохраняет состояние при скрытии');
  }
}
```

## Common Mistakes (Распространённые ошибки)

### Ошибка 1: Вызов setState() после первого build()

```dart
class BadExample extends StatefulWidget {
  @override
  State<BadExample> createState() => _BadExampleState();
}

class _BadExampleState extends State<BadExample> {
  @override
  void initState() {
    super.initState();
    // ❌ ОШИБКА! setState() нельзя вызывать до build()
    setState(() {
      _data = fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_data);
  }
}

// ✅ Правильно
class GoodExample extends StatefulWidget {
  @override
  State<GoodExample> createState() => _GoodExampleState();
}

class _GoodExampleState extends State<GoodExample> {
  String? _data;

  @override
  void initState() {
    super.initState();
    // Используем Future, чтобы вызвать setState после build()
    fetchData().then((value) {
      if (mounted) {
        setState(() {
          _data = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_data ?? 'Загрузка...');
  }
}
```

### Ошибка 2: Забыть проверить `mounted`

```dart
// ❌ Плохо — setState может быть вызван после dispose()
void _fetchData() async {
  final data = await fetchData();
  setState(() {
    _data = data;
  });
}

// ✅ Хорошо — проверяем mounted
void _fetchData() async {
  final data = await fetchData();
  if (mounted) {
    setState(() {
      _data = data;
    });
  }
}
```

### Ошибка 3: Изменение состояния без setState()

```dart
// ❌ Плохо — setState не вызван, UI не обновится
void _increment() {
  _counter++; // Изменение без setState
}

// ✅ Хорошо
void _increment() {
  setState(() {
    _counter++;
  });
}
```

### Ошибка 4: Изменение объектов, которые не влияют на UI

```dart
// ❌ Плохо — setState вызывается, хотя UI не меняется
void _doSomething() {
  setState(() {
    _logger.add('Action performed'); // Логгер не влияет на UI
  });
}

// ✅ Хорошо — только изменяем то, что влияет на UI
void _doSomething() {
  _logger.add('Action performed'); // Без setState
  setState(() {
    _result = _computeResult(); // Только UI-зависимые данные
  });
}
```

## Асинхронный код и setState

### Работа с Future

```dart
class AsyncExample extends StatefulWidget {
  const AsyncExample({super.key});

  @override
  State<AsyncExample> createState() => _AsyncExampleState();
}

class _AsyncExampleState extends State<AsyncExample> {
  String? _data;
  bool _loading = false;
  String? _error;

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await fetchData();
      if (mounted) {
        setState(() {
          _data = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const CircularProgressIndicator();
    if (_error != null) return Text('Ошибка: $_error');
    if (_data != null) return Text('Данные: $_data');
    return ElevatedButton(
      onPressed: _fetchData,
      child: const Text('Загрузить'),
    );
  }
}
```

## Best Practices

### ✅ Делайте

- Вызывайте `setState()` только при необходимости
- Используйте `mounted` для асинхронных операций
- Делайте `build()` как можно проще
- Используйте `const` для статических виджетов
- Выносите сложные виджеты в отдельные классы

### ❌ Не делайте

- Не вызывайте `setState()` в `initState()` синхронно
- Не выполняйте тяжёлые вычисления внутри `setState()`
- Не вызывайте `setState()` слишком часто
- Не держите в состоянии то, что можно вычислить

## Заключение

`setState()` — простой и эффективный механизм для управления локальным состоянием. Для простых сценариев его более чем достаточно. Однако для сложных приложений с множеством виджетов, разделяющих состояние, потребуется более продвинутые решения, такие как Provider, Riverpod или BLoC.

> **Правило:** Используйте `setState()` для локального состояния в одном виджете. Для глобального состояния — выбирайте подходящий паттерн управления состоянием.
