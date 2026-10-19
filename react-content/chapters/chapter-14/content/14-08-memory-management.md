# 14-08. Memory Management и утечки памяти

## Введение

Управление памятью — критически важная часть разработки Flutter-приложений. Утечки памяти могут привести к ухудшению производительности, падению приложения и плохому пользовательскому опыту.

## Основы управления памятью

### Garbage Collection в Dart

Dart использует автоматический сборщик мусора (Garbage Collection):

```
┌─────────────────────────────────────────────┐
│              Heap Memory                     │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Object A │  │ Object B │  │ Object C │  │
│  │ (active) │  │ (active) │  │ (unused) │  │
│  └──────────┘  └──────────┘  └──────────┘  │
│                                              │
│  GC: Находит unused объекты и освобождает    │
│  память                                      │
└─────────────────────────────────────────────┘
```

### Типы памяти в Flutter

| Тип | Описание |
|-----|----------|
| Heap | Динамическая память для объектов |
| Stack | Вызовы функций и локальные переменные |
| Native | Память, выделенная нативным кодом |
| GPU | Память графического процессора |

## Причины утечек памяти

### 1. Неправильное управление контроллерами

```dart
// Плохо — контроллер неDispose
class BadExample extends StatefulWidget {
  @override
  State<BadExample> createState() => _BadExampleState();
}

class _BadExampleState extends State<BadExample> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // НЕТ dispose!
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}

// Хорошо — правильный dispose
class GoodExample extends StatefulWidget {
  @override
  State<GoodExample> createState() => _GoodExampleState();
}

class _GoodExampleState extends State<GoodExample> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose(); // Освобождает память
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
```

### 2. Неподписки на Stream

```dart
// Плохо — подписка не отменяется
class BadStreamExample extends StatefulWidget {
  @override
  State<BadStreamExample> createState() => _BadStreamExampleState();
}

class _BadStreamExampleState extends State<BadStreamExample> {
  final StreamController<int> _controller = StreamController<int>();

  @override
  void initState() {
    super.initState();
    // Подписка остаётся даже после dispose
    _controller.stream.listen((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Text('Bad Stream');
  }
}

// Хорошо — правильная отписка
class GoodStreamExample extends StatefulWidget {
  @override
  State<GoodStreamExample> createState() => _GoodStreamExampleState();
}

class _GoodStreamExampleState extends State<GoodStreamExample> {
  late StreamSubscription<int> _subscription;
  final StreamController<int> _controller = StreamController<int>();

  @override
  void initState() {
    super.initState();
    _subscription = _controller.stream.listen((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // Отменяем подписку
    _controller.close();    // Закрываем контроллер
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Text('Good Stream');
  }
}
```

### 3. Замыкания (Closures) и сильные ссылки

```dart
// Плохо — замыкание удерживает ссылку на this
class BadClosureExample extends StatefulWidget {
  @override
  State<BadClosureExample> createState() => _BadClosureExampleState();
}

class _BadClosureExampleState extends State<BadClosureExample> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Замыкание удерживает ссылку на _BadClosureExampleState
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Text('Bad Closure');
  }
}

// Хорошо — явное освобождение
class GoodClosureExample extends StatefulWidget {
  @override
  State<GoodClosureExample> createState() => _GoodClosureExampleState();
}

class _GoodClosureExampleState extends State<GoodClosureExample> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null; // Явно обнуляем
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Text('Good Closure');
  }
}
```

### 4. Глобальные и статические ссылки

```dart
// Плохо — глобальная ссылка удерживает объекты
final List<Object> _globalCache = [];

class GlobalReferenceExample extends StatefulWidget {
  @override
  State<GlobalReferenceExample> createState() =>
      _GlobalReferenceExampleState();
}

class _GlobalReferenceExampleState
    extends State<GlobalReferenceExample> {
  @override
  Widget build(BuildContext context) {
    // Добавляем в глобальный кэш, но никогда не удаляем
    _globalCache.add({'key': 'value', 'data': 'large data'});
    return const Text('Global Reference');
  }
}

// Хорошо — кэш с ограничением размера
class BoundedCacheExample extends StatefulWidget {
  @override
  State<BoundedCacheExample> createState() => _BoundedCacheExampleState();
}

class _BoundedCacheExampleState extends State<BoundedCacheExample> {
  final Map<String, dynamic> _cache = {};
  static const int _maxSize = 100;

  void _addToCache(String key, dynamic value) {
    if (_cache.length >= _maxSize) {
      // Удаляем старый элемент
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[key] = value;
  }

  @override
  Widget build(BuildContext context) {
    return const Text('Bounded Cache');
  }
}
```

## Debugging Memory

### DevTools Memory Tab

DevTools предоставляет инструменты для анализа памяти:

1. Откройте DevTools
2. Перейдите во вкладку Memory
3. Нажмите "Take Heap Snapshot"
4. Сравните снимки для выявления утечек

### Heap Snapshot

```
┌─────────────────────────────────────────────────────┐
│  Heap Snapshot Analysis                              │
│                                                      │
│  Type              Count    Shallow    Retained      │
│  String            1,234    45 KB       120 KB       │
│  List              567      23 KB       89 KB        │
│  Map               234      12 KB       45 KB        │
│  _MyWidgetState    45       5 KB        23 KB        │
│  TextEditingController 34   3 KB        15 KB        │
│                                                      │
│  Утечка: 34 TextEditingController без dispose         │
└─────────────────────────────────────────────────────┘
```

### Profiling Memory в реальном времени

```dart
import 'dart:developer' as developer;

// Ручной вызов GC
void triggerGC() {
  developer.postEvent('Flutter.GC', <String, String>{});
}

// Мониторинг памяти
void logMemory() {
  final memory = developer.Service.getVM();
  debugPrint('Memory: ${memory.totalHeapSize} bytes');
  debugPrint('Used: ${memory.usedHeapSize} bytes');
}
```

### Использование debugDumpTree

```dart
// Вывод дерева виджетов для анализа
void debugWidgetTree() {
  debugDumpApp();          // Вывод всего приложения
  debugDumpLayerTree();    // Вывод графа слоёв
  debugDumpRenderTree();   // Вывод графа рендеринга
}
```

### Leak Tracker

```dart
import 'package:leak_tracker/leak_tracker.dart';

// Включение отслеживания утечек
void main() {
  // Включение leak tracker
  debugLeakTrackingEnabled = true;

  runApp(const MyApp());
}

// При обнаружении утечки leak tracker выведет:
// LEAK: TextEditingController was not disposed
//   at: lib/main.dart:42:18
//   leaked from: lib/main.dart:25:10
```

## Best Practices

### Рекомендации по управлению памятью

1. **Всегда вызывайте `dispose()`** для контроллеров, подписок и ресурсов
2. **Используйте `mounted` проверку** перед вызовом `setState()`
3. **Избегайте глобальных кэшей без ограничений**
4. **Используйте DevTools Memory для анализа**
5. **Регулярно вызывайте GC** при тестировании
6. **Используйте `leak_tracker`** для обнаружения утечек

### Чек-лист проверки памяти

- [ ] Все `TextEditingController` имеют `dispose()`
- [ ] Все `StreamSubscription` имеют `cancel()`
- [ ] Все `Timer` имеют `cancel()`
- [ ] Все `AnimationController` имеют `dispose()`
- [ ] Все `ScrollController` имеют `dispose()`
- [ ] Нет глобальных кэшей без ограничений
- [ ] DevTools Memory не показывает утечек
- [ ] Приложение стабильно при длительной работе

### Common Disposable Resources

| Ресурс | Метод освобождения |
|--------|-------------------|
| `TextEditingController` | `dispose()` |
| `FocusNode` | `dispose()` |
| `AnimationController` | `dispose()` |
| `StreamSubscription` | `cancel()` |
| `Timer` | `cancel()` |
| `ScrollController` | `dispose()` |
| `TabController` | `dispose()` |
| `NavigatorObserver` | Ничего (не требует dispose) |

## Заключение

Управление памятью — это критически важная часть разработки Flutter-приложений. Правильное освобождение ресурсов, использование DevTools для анализа и соблюдение best practices позволяют создавать стабильные приложения без утечек памяти.
