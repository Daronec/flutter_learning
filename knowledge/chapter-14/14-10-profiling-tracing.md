# 14-10. Profiling vs Tracing — Методы диагностики

## Введение

Profiling и Tracing — это два основных метода диагностики производительности Flutter-приложений. Profiling помогает понять, какие части кода наиболее затратны, а Tracing позволяет детально проанализировать каждый этап выполнения.

## Profiling Mode

### Что такое Profiling Mode

Profiling Mode — это режим запуска приложения, оптимизированный для сбора данных о производительности без значительного влияния на выполнение:

| Режим | Назначение | Производительность |
|-------|-----------|-------------------|
| Debug | Разработка с Hot Reload | Низкая |
| Profile | Диагностика производительности | Близка к Release |
| Release | Финальная сборка | Максимальная |

### Запуск в Profiling Mode

```bash
# Запуск в Profiling Mode
flutter run --profile

# Запуск с конкретным устройством
flutter run --profile -d <device_id>

# Запуск с конкретным портом для DevTools
flutter run --profile --trace-startup
```

### Запуск из VS Code

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Profile",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--profile"]
    }
  ]
}
```

### Запуск из Android Studio

1. Откройте конфигурацию запуска
2. Выберите режим `Profile` вместо `Debug`
3. Запустите приложение

## CPU Profiling

### Запуск CPU Profiler

```dart
import 'dart:developer' as developer;

void main() {
  runApp(const MyApp());
}

// Ручной запуск профилирования
void startCpuProfiling() {
  developer.startServiceExtension('ext.flutter.profiler');
}

void stopCpuProfiling() {
  developer.postEvent('Flutter.CPUProfile', <String, dynamic>{});
}
```

### Flame Chart

Flame Chart — это визуализация CPU-профиля в виде горизонтальных полосок:

```
main() [100ms]
├── runApp() [95ms]
│   ├── BuildPhase [30ms]
│   │   ├── HomePage.build() [25ms]
│   │   │   ├── ListView.builder [15ms]
│   │   │   │   ├── _UserTile.build() [10ms]
│   │   │   │   └── _UserTile.build() [5ms]
│   │   │   └── Text widget [5ms]
│   │   └── SettingsWidget.build() [5ms]
│   ├── LayoutPhase [20ms]
│   │   └── RenderObject.layout() [20ms]
│   └── PaintPhase [45ms]
│       ├── RenderObject.paint() [30ms]
│       └── ImagePainter.paint() [15ms]
└── EventLoop [5ms]
```

### Анализ CPU-профиля

| Метрика | Описание | Норма |
|---------|----------|-------|
| Self Time | Время, затраченное только на эту функцию | < 50ms |
| Total Time | Время функции + все дочерние | < 16.7ms на кадр |
| Call Count | Количество вызовов функции | Минимизировать |

## Timeline Tracing

### Что такое Timeline Tracing

Timeline Tracing — это запись всех событий приложения во времени. Это позволяет детально проанализировать каждый кадр и выявить причины задержек.

### Запись Timeline

```dart
import 'dart:developer' as developer;

void startTimeline() {
  // Начало записи
  developer.log('Timeline start', name: 'app.timeline');
}

void stopTimeline() {
  // Конец записи
  developer.log('Timeline stop', name: 'app.timeline');
}
```

### Типы событий на Timeline

| Событие | Описание | Цвет |
|---------|----------|------|
| Dart | Dart-код | Синий |
| Platform | Нативный код | Зелёный |
| GPU | Графический процессор | Оранжевый |
| Rendering | Рендеринг | Красный |
| GC | Garbage Collection | Фиолетовый |

### Анализ фреймов на Timeline

```
┌──────────────────────────────────────────────────────────────┐
│  Frame Analysis                                              │
│                                                              │
│  Frame 1: 16.2ms ✓ (60 FPS)                                  │
│  Build: 2.1ms                                                │
│  Layout: 1.3ms                                               │
│  Paint: 3.4ms                                                │
│  Composite: 0.8ms                                            │
│  GPU: 8.6ms                                                  │
│                                                              │
│  Frame 2: 16.5ms ✓ (60 FPS)                                  │
│  Build: 2.3ms                                                │
│  Layout: 1.1ms                                               │
│  Paint: 3.2ms                                                │
│  Composite: 0.9ms                                            │
│  GPU: 9.0ms                                                  │
│                                                              │
│  Frame 3: 67.8ms ✗ (JANK!)                                   │
│  Build: 2.0ms                                                │
│  Layout: 1.2ms                                               │
│  Paint: 3.1ms                                                │
│  Shader Compilation: 55.0ms ⚠️                               │
│  Composite: 0.8ms                                            │
│  GPU: 5.7ms                                                  │
└──────────────────────────────────────────────────────────────┘
```

### Горячие точки на Timeline

```dart
// Метка для отслеживания конкретного участка кода
void performTask() {
  developer.timelineSync('Starting task', details: {
    'taskId': '001',
    'priority': 'high',
  });

  // Выполнение задачи
  heavyComputation();

  developer.timelineSync('Task completed', details: {
    'taskId': '001',
    'duration': '150ms',
  });
}

// Использование timelineSync для маркировки
void buildWidget() {
  developer.timelineSync('Building HomePage', details: {
    'widget': 'HomePage',
    'phase': 'build',
  });

  // Build-логика
  final widget = _buildContent();

  developer.timelineSync('HomePage built', details: {
    'widget': 'HomePage',
    'phase': 'build',
    'duration': '25ms',
  });

  return widget;
}
```

## Memory Profiling

### Запуск Memory Profiler

```dart
import 'dart:developer' as developer;

// Ручной вызов GC
void triggerGC() {
  developer.postEvent('Flutter.GC', <String, String>{});
}

// Мониторинг памяти
void logMemoryUsage() {
  developer.Service.getVM().then((vm) {
    debugPrint('Total Heap: ${vm.totalHeapSize} bytes');
    debugPrint('Used Heap: ${vm.usedHeapSize} bytes');
    debugPrint('Total External: ${vm.totalExternalSize} bytes');
  });
}
```

### Heap Snapshot

```
┌─────────────────────────────────────────────────────────────┐
│  Heap Snapshot Comparison                                   │
│                                                             │
│  Snapshot 1 (Start)    Snapshot 2 (After navigation)        │
│  ┌─────────────────┐   ┌─────────────────┐                  │
│  │ String: 1.2 MB  │   │ String: 1.3 MB  │                  │
│  │ List: 0.8 MB    │   │ List: 1.5 MB    │                  │
│  │ Map: 0.5 MB     │   │ Map: 2.3 MB     │                  │
│  │ _PageState: 10  │   │ _PageState: 50  │                  │
│  │ Total: 2.5 MB   │   │ Total: 5.1 MB   │                  │
│  └─────────────────┘   └─────────────────┘                  │
│                                                             │
│  Δ: +2.6 MB (возможная утечка)                              │
└─────────────────────────────────────────────────────────────┘
```

## Network Profiling

### Network DevTools

DevTools предоставляет вкладку Network для мониторинга сетевых запросов:

1. Откройте DevTools
2. Перейдите во вкладку Network
3. Выполните действия в приложении
4. Анализируйте запросы

### Анализ сетевых запросов

| Метрика | Описание | Норма |
|---------|----------|-------|
| Duration | Время выполнения запроса | < 2s |
| Size | Размер ответа | Минимизировать |
| Status | HTTP статус код | 200 |
| Cache | Использование кэша | Кэшировано |

### Оптимизация сетевых запросов

```dart
class OptimizedHttpClient {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  // Сжатие запросов
  OptimizedHttpClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Сжатие тела запроса
        options.headers['Accept-Encoding'] = 'gzip';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Декомпрессия ответа
        if (response.headers.value('Content-Encoding') == 'gzip') {
          // Автоматическая декомпрессия Dio
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        // Обработка ошибок
        return handler.next(e);
      },
    ));
  }

  Future<Response> getData(String url) async {
    return _dio.get(url);
  }
}
```

## Сравнение Profiling и Tracing

### Когда использовать Profiling

| Сценарий | Profiling | Tracing |
|----------|-----------|---------|
| Поиск медленных функций | Да | Нет |
| Анализ CPU-нагрузок | Да | Нет |
| Поиск утечек памяти | Да | Нет |
| Анализ каждого кадра | Нет | Да |
| Поиск причин jank | Нет | Да |
| Анализ GPU-нагрузок | Нет | Да |

### Сравнение инструментов

| Инструмент | Profiling | Tracing | Что показывает |
|------------|-----------|---------|---------------|
| DevTools Performance | Да | Да | FPS, Build, Layout, Paint |
| DevTools Memory | Да | Нет | Heap, Allocations, Leaks |
| DevTools Network | Да | Да | Запросы, Время, Размер |
| DevTools Widgets | Да | Нет | Иерархия, Свойства |
| Timeline | Нет | Да | События во времени |

## Best Practices

### Рекомендации по диагностике

1. **Начинайте с Performance Overlay** — быстрая оценка FPS
2. **Используйте DevTools Timeline** — детальный анализ каждого кадра
3. **Профилируйте на реальном устройстве** — эмуляторы могут не показывать проблемы
4. **Сравнивайте до и после оптимизации** — документируйте улучшения
5. **Используйте Flame Chart** — для поиска наиболее затратных функций
6. **Регулярно проверяйте Memory** — для обнаружения утечек

### Чек-лист диагностики

- [ ] Performance Overlay показывает стабильный FPS
- [ ] DevTools Timeline не показывает красных кадров
- [ ] Flame Chart не показывает функций > 50ms
- [ ] Memory Profiler не показывает утечек
- [ ] Network Profiler показывает оптимизированные запросы
- [ ] Тестирование на реальных устройствах завершено

## Заключение

Profiling и Tracing — это мощные инструменты для диагностики производительности Flutter-приложений. Profiling помогает найти наиболее затратные функции, а Tracing позволяет детально проанализировать каждый кадр. Использование обоих подходов обеспечивает полную картину производительности приложения.
