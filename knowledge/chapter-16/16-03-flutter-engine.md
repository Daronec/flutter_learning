---
tags:
  - platform-channels
  - native
  - plugins
chapter: 16
section: 3
title: Flutter Engine — как это работает изнутри
alias: 16 03 flutter engine
status: complete
---

# Flutter Engine — как это работает изнутри

Flutter Engine — это слой выполнения Flutter, написанный на C++. Он обеспечивает рендеринг, компиляцию кода, поддержку график и системных сервисов. Понимание работы Engine критично для оптимизации производительности и решения сложных проблем.

## Архитектура Flutter Engine

### Компоненты Engine

```
┌─────────────────────────────────────────────────────┐
│                  Flutter Framework                   │
│  (Dart)  Widgets → Rendering → Animation → Services │
├─────────────────────────────────────────────────────┤
│                  Flutter Engine                      │
│  (C++)  Dart VM → Renderer → Platform → Embedder    │
├─────────────────────────────────────────────────────┤
│              Platform Embedder                       │
│  (iOS/Android/Desktop)  Window & Input Management    │
└─────────────────────────────────────────────────────┘
```

### Основные модули Engine

| Модуль | Язык | Описание |
|--------|------|----------|
| Dart Runtime | C++ | Выполнение Dart-кода, GC, изоляты |
| Skia/Impeller Renderer | C++ | Графический рендерер |
| Text | C++ | Рендеринг текста, шрифты |
| Platform Channel | C++ | Коммуникация с платформой |
| Embedder API | C++ | Интеграция с ОС |
| Graphics | C++ | Абстракция над GPU API |

## Dart Runtime

### Изоляты (Isolates)

Каждый Dart-код выполняется в изолированной среде. Flutter использует изоляты для параллельного выполнения:

```dart
import 'dart:isolate';

/// Основной поток (Isolate)
void main() async {
  // Получаем порт для коммуникации
  final receivePort = ReceivePort();

  // Создаём новый Isolate для тяжёлых вычислений
  await Isolate.spawn(heavyComputation, receivePort.sendPort);

  // Получаем результат
  await for (final message in receivePort) {
    if (message is SendPort) {
      // Отправляем данные в Isolate
      message.send([1, 2, 3, 4, 5]);
    } else if (message is int) {
      print('Результат: $message'); // 15
    }
  }
}

/// Функция в отдельном Isolate
void heavyComputation(SendPort mainSendPort) {
  final mainPort = ReceivePort();
  mainSendPort.send(mainPort.sendPort);

  for each (final msg in mainPort) {
    if (msg is List<int>) {
      final sum = msg.fold(0, (a, b) => a + b);
      mainSendPort.send(sum);
    }
  }
}
```

### Dart VM Architecture

```
┌──────────────────────────────────────┐
│         Dart Isolate                 │
│  ┌────────────────────────────────┐  │
│  │         Heap Memory            │  │
│  │  (Young Generation + Old Gen)  │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │      Stack (per-thread)        │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │      JIT/AOT Compiler          │  │
│  │  (Dart → Assembly)             │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │     Garbage Collector          │  │
│  │  (Generational, Concurrent)    │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

## Компиляция Dart-кода

### Режимы компиляции

| Режим | Компилятор | Использование | Производительность |
|-------|-----------|---------------|-------------------|
| JIT (Just-In-Time) | Dart Compiler | `flutter run` (debug) | Быстрая разработка, Hot Reload |
| AOT (Ahead-Of-Time) | Dart AOT Compiler | `flutter build apk/ipa` | Максимальная производительность |
| JIT (Profile) | Dart Compiler | `flutter run --profile` | Профилирование, анализ |

### JIT vs AOT

```
JIT (Debug Mode):
┌─────────────────────────────────┐
│  Dart Source Code               │
│       ↓                         │
│  Dart Kernel (Dill)             │
│       ↓                         │
│  JIT Compilation (runtime)      │
│       ↓                         │
│  Native Machine Code            │
└─────────────────────────────────┘
→ Hot Reload: частичная перезагрузка
→ Hot Restart: полная перезагрузка

AOT (Release Mode):
┌─────────────────────────────────┐
│  Dart Source Code               │
│       ↓                         │
│  Dart Kernel (Dill)             │
│       ↓                         │
│  AOT Compiler (pre-compilation) │
│       ↓                         │
│  Native Machine Code (snapshot) │
└─────────────────────────────────┘
→ Мгновенный запуск
→ Нет JIT-оверхеда
```

## Renderer Pipeline

### Этапы рендеринга

```
┌─────────────┐    ┌──────────────┐    ┌───────────────┐    ┌───────────┐
│   Layout    │───→│   Painting   │───→│   Compositing │───→│  Raster   │
│   Phase     │    │   Phase      │    │   & Compositing│   │  Pipeline │
└─────────────┘    └──────────────┘    └───────────────┘    └───────────┘
   (Dart)            (Dart)             (Dart/C++)           (C++)
   Вычисление        Создание           Составление         GPU-рендеринг
   размеров          команд             кадров              через GPU API
```

### Pipeline в деталях

```dart
// 1. Layout Phase (RenderObject tree)
class MyRenderObject extends RenderBox {
  @override
  void performLayout() {
    // Вычисляем размеры и позиции дочерних элементов
    child!.layout(constraints, parentUsesSize: true);
    size = child!.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Рисуем элемент
    context.paintChild(child!, offset);
  }
}

// 2. Painting Phase
// Создаёт списки команд рисования (OOP tree)

// 3. Compositing Phase
// Определяет, какие слои нужно композитить

// 4. Raster Pipeline (C++)
// Отправляет команды на GPU
```

## Embedder API

Embedder — это слой интеграции Flutter Engine с конкретной платформой.

### Android Embedder

```kotlin
// Android: FlutterActivity обеспечивает базовую интеграцию
class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Регистрация плагинов
        flutterEngine.plugins.add(MyPlugin())

        // Регистрация обработчиков
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
    }
}
```

### iOS Embedder

```swift
// iOS: FlutterAppDelegate обеспечивает базовую интеграцию
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

### Desktop Embedder (Linux example)

```cpp
// Linux: C++ Embedder
#include <flutter/flutter_engine.h>
#include <flutter/flutter_view_controller.h>

int main(int argc, char** argv) {
    // Создание экземпляра Engine
    const auto* settings = new flutter::FlutterEngineSettings();
    settings->exit_embedder_shutdown = true;

    flutter::FlutterEngine engine(settings);

    // Запуск Dart-EntryPoint
    engine.RestartAndLaunchFromEntrypoint(
        "main",  // entrypoint
        nullptr  // entrypoint library
    );

    // Создание View Controller
    flutter::FlutterViewController controller(&engine, 0, nullptr);

    return 0;
}
```

## Lifecycle Engine

### Жизненный цикл Flutter Engine

```
┌────────────────────────────────────────────────────────┐
│                  Engine Lifecycle                       │
│                                                        │
│  1. Create Engine → 2. Initialize → 3. Run             │
│       ↓                                                    │
│  4. Pause → 5. Stop → 6. Destroy                        │
│                                                        │
│  Platform callbacks:                                   │
│  - onPlatformResumed  → Dart: WidgetsBinding           │
│  - onPlatformPaused   → Dart: WidgetsBinding           │
│  - onFirstFrame       → Dart: WidgetsBinding           │
│  - onMetricsChanged   → Dart: WidgetsBinding           │
│  - onTextScaleChanged → Dart: WidgetsBinding           │
└────────────────────────────────────────────────────────┘
```

### Управление жизненным циклом в Dart

```dart
import 'package:flutter/widgets.dart';

class LifecycleAwareWidget extends StatefulWidget {
  @override
  _LifecycleAwareWidgetState createState() => _LifecycleAwareWidgetState();
}

class _LifecycleAwareWidgetState extends State<LifecycleAwareWidget>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    // Регистрируем наблюдателя за жизненным циклом
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Удаляем наблюдателя
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Изменение метрик экрана (поворот, нечеловек и т.д.)
    print('Метрики изменены');
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Изменение темы системы
    print('Тема системы изменена: ${PlatformDispatcher.instance.platformBrightness}');
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    // Изменение языка системы
    print('Язык изменён: ${locales?.first}');
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    // Изменение настроек доступности
    print('Доступность изменена');
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Lifecycle Aware'));
  }
}
```

## Performance Profiling

### Инструменты профилирования

| Инструмент | Назначение | Что показывает |
|------------|-----------|----------------|
| DevTools | Основной инструмент | FPS, CPU, Memory, Network |
| `flutter profile` | Режим профилирования | AOT-производительность |
| `flutter trace` | Trace-запись | Детальные события |
| `--trace-startup` | Профиль запуска | Время инициализации |

### Ключевые метрики

```dart
// Отслеживание производительности
import 'package:flutter/foundation.dart';

void measurePerformance() {
  // Отслеживание времени выполнения
  final stopwatch = Stopwatch()..start();

  // Выполняем операцию
  heavyOperation();

  stopwatch.stop();
  debugPrint('Время выполнения: ${stopwatch.elapsedMilliseconds}ms');

  // Отслеживание FPS
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final observer = DurationObserver(
      duration: const Duration(milliseconds: 16), // 60 FPS
      onVsync: (duration) {
        debugPrint('Пропущен кадр: ${duration.inMilliseconds}ms');
      },
    );
    WidgetsBinding.instance.addObserver(observer);
  });
}

/// Наблюдатель за длительностью кадра
class DurationObserver extends WidgetsBindingObserver {
  final Duration duration;
  final Function(Duration) onVsync;

  DurationObserver({required this.duration, required this.onVsync});

  @override
  void didFrameDuration(Duration duration) {
    if (duration > this.duration) {
      onVsync(duration);
    }
  }
}
```

## Best Practices

1. **Избегайте блокировки UI-потока** — тяжёлые вычисления выносите в Isolate:
   ```dart
   await compute(parseJson, jsonString);
   ```

2. **Используйте `const` конструкторы** — уменьшают нагрузку на Widget tree:
   ```dart
   // Хорошо — переиспользуется
   const SizedBox(height: 16);

   // Плохо — создаётся каждый кадр
   SizedBox(height: 16);
   ```

3. **Минимизируйте rebuild** — используйте `const`, `Selector` (provider), `shouldRebuild`:
   ```dart
   class _MyState extends State<MyWidget> with SingleTickerProviderStateMixin {
     @override
     bool shouldRebuild(covariant SliverPersistentDelegate oldDelegate) {
       return false; // Кэшируем
     }
   }
   ```

4. **Кэшируйте сложные вычисления** — используйте `memoization`:
   ```dart
   String? _cachedResult;
   String getExpensiveResult() {
     if (_cachedResult != null) return _cachedResult!;
     _cachedResult = expensiveComputation();
     return _cachedResult!;
   }
   ```

5. **Используйте `repaintBoundary`** — изолируйте области перерисовки:
   ```dart
   RepaintBoundary(
     child: ComplexWidget(), // Перерисовывается независимо
   )
   ```

6. **Профилируйте в Release-режиме** — Debug-режим значительно медленнее:
   ```bash
   flutter build apk --release
   flutter profile
   ```

7. **Мониторьте размер Dart Snapshot** — большой snapshot увеличивает время запуска:
   ```bash
   # Проверка размера snapshot
   ls -lh build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
   ```
