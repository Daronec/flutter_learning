# 14-01. Flutter Performance Toolkit и DevTools

## Введение

Инструменты производительности Flutter — это набор встроенных утилит, которые помогают разработчикам анализировать, профилировать и оптимизировать приложения. Правильное использование этих инструментов позволяет выявлять узкие места, находить утечки памяти и обеспечивать плавный пользовательский опыт.

## Flutter DevTools

### Что такое DevTools

Flutter DevTools — это набор инструментов для отладки и профилирования приложений Flutter. Он предоставляет визуальный интерфейс для анализа различных аспектов приложения: производительности, памяти, сети, логов и структуры виджетов.

### Установка DevTools

Установка DevTools выполняется через пакетный менеджер Dart:

```bash
dart pub global activate devtools
```

После установки DevTools можно запустить несколькими способами:

```bash
# Запуск через командную строку
devtools

# Запуск с указанием порта
devtools --port 9100

# Запуск с привязкой к конкретному хосту
devtools --host-address 127.0.0.1 --port 9100
```

### Запуск DevTools из VS Code

В VS Code DevTools интегрируется через расширение Flutter:

1. Откройте проект Flutter в VS Code
2. Нажмите `Ctrl+Shift+P` (или `Cmd+Shift+P` на macOS)
3. Введите `Flutter: Open DevTools`
4. DevTools откроется в браузере

### Запуск DevTools из Android Studio / IntelliJ

1. Убедитесь, что установлен плагин Flutter
2. Запустите приложение в режиме отладки
3. В панели вывода найдите ссылку на DevTools
4. Нажмите на ссылку для открытия DevTools в браузере

### Запуск DevTools из терминала

При запуске приложения через `flutter run` DevTools автоматически запускается:

```
Launching lib/main.dart on Chrome in debug mode...

Waiting for connection from debug service on Chrome...
Flutter run key commands.
r Hot reload.
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on Chrome is available at:
http://127.0.0.1:54321/abcdef1234567890
The Flutter DevTools debugger and profiler on http://127.0.0.1:9100/
is available at: http://127.0.0.1:9100/?uri=http://127.0.0.1:54321/abcdef1234567890
```

## Основные разделы DevTools

| Раздел | Назначение |
|--------|-----------|
| Widgets | Иерархия виджетов и их свойства |
| Layout Explorer | Визуализация ограничений и размеров виджетов |
| Performance | Временная шкала рендеринга и событий |
| Memory | Анализ использования памяти |
| Network | Мониторинг сетевых запросов |
| Logging | Вывод логов приложения |
| Pub Dev | Информация о зависимостях |

## Performance Overlay

### Включение Performance Overlay

Performance Overlay — это оверлей, отображающий информацию о производительности прямо на экране приложения. Он включается через параметр `showPerformanceOverlay`:

```dart
void main() {
  runApp(
    MaterialApp(
      // Включение оверлея производительности
      showPerformanceOverlay: true,
      home: MyHomePage(),
    ),
  );
}
```

### Что показывает Performance Overlay

В левом верхнем углу экрана отображается несколько индикаторов:

| Индикатор | Описание |
|-----------|----------|
| FPS (Frame) | Количество кадров в секунду |
| Jank | Количество кадров, пропущенных из-за задержек |
| Build | Время сборки виджетов |
| Layout | Время выполнения layout |
| Paint | Время рендеринга |
| Raster | Время обработки GPU (в галее) |

### Цветовая кодировка FPS

| Цвет | FPS | Оценка |
|------|-----|--------|
| Зелёный | 55-60 | Отлично |
| Жёлтый | 45-54 | Хорошо |
| Оранжевый | 30-44 | Удовлетворительно |
| Красный | < 30 | Плохо |

### Включение через код во время выполнения

Performance Overlay можно включить программно:

```dart
import 'package:flutter/foundation.dart';

void togglePerformanceOverlay() {
  // Переключение оверлея
  debugPaintSizeEnabled = !debugPaintSizeEnabled;
  debugPaintLayerBordersEnabled = !debugPaintLayerBordersEnabled;
}
```

## Timeline View

### Что такое Timeline

Timeline — это временная шкала, которая отображает все события, происходящие во время выполнения приложения. Она позволяет детально проанализировать каждый кадр и выявить причины задержек.

### Доступ к Timeline

Timeline доступен в разделе Performance DevTools. Для записи таймлайна:

1. Откройте DevTools
2. Перейдите во вкладку Performance
3. Нажмите кнопку записи (красный кружок)
4. Выполните действия в приложении
5. Остановите запись

### Типы событий на Timeline

| Тип события | Описание |
|-------------|----------|
| Dart | События Dart-кода (функции, async-операции) |
| Platform | События нативной платформы (Android/iOS) |
| GPU | События графического процессора |
| Rendering | События рендеринга |

### Анализ фреймов на Timeline

Каждый кадр (frame) на Timeline состоит из нескольких фаз:

```
┌─────────────────────────────────────────────────────┐
│  Frame 100                                           │
│  ┌──────┬───────┬───────┬───────┬───────┬───────┐  │
│  │ Build│ Layout│ Paint │ Composite │ GPU │ VSync │  │
│  │ 1.2ms│ 0.3ms │ 0.8ms │   0.5ms   │ 8ms │ 16.7ms│  │
│  └──────┴───────┴───────┴───────┴───────┴───────┘  │
│  Всего: 10.8ms из 16.7ms (60 FPS)                    │
└─────────────────────────────────────────────────────┘
```

### Цветовая маркировка событий

| Цвет | Значение |
|------|----------|
| Зелёный | Укладывается в 16.7ms (60 FPS) |
| Жёлтый | Почти укладывается, но с запасом |
| Красный | Пропущенный кадр (jank) |

### Горячие клавиши для записи

```dart
// Включение записи таймлайна
import 'package:flutter/foundation.dart';

void startTimeline() {
  // Включает трассировку Dart-событий
  debugProfileBuildsEnabled = true;
}

void stopTimeline() {
  debugProfileBuildsEnabled = false;
}
```

## Profiler и его возможности

### Раздел Profiler в DevTools

Profiler позволяет профилировать выполнение Dart-кода:

1. Откройте DevTools
2. Перейдите во вкладку Performance
3. Нажмите "Start Profiling"
4. Выполните действие в приложении
5. Остановите профилирование

### Анализ CPU-профиля

Profiler показывает:

- Сколько времени заняла каждая функция
- Сколько раз была вызвана каждая функция
- Какие функции являются наиболее затратными

### Flame Chart

Flame Chart — это визуализация CPU-профиля в виде горизонтальных полосок:

```
main()
├── runApp()
│   ├── BuildPhase
│   │   ├── MyWidget.build()
│   │   │   ├── Text widget
│   │   │   └── Container widget
│   │   └── ListView.builder
│   │       └── _ListViewItem.build()
│   └── LayoutPhase
│       └── RenderObject.layout()
```

## Best Practices

### Рекомендации по использованию инструментов

1. **Регулярно используйте Performance Overlay** — отслеживайте FPS во время разработки
2. **Анализируйте Timeline при проблемах с производительностью** — выявляйте узкие места
3. **Используйте Memory DevTools для поиска утечек** — проверяйте память при изменении состояний
4. **Профилируйте на реальном устройстве** — эмуляторы могут показывать другие результаты
5. **Сравнивайте до и после оптимизации** — документируйте улучшения

### Полезные команды

```bash
# Проверка размера приложения
flutter build apk --analyze-size

# Проверка зависимостей
flutter pub deps

# Анализ дерева виджетов
flutter debug dump-widget-tree

# Анализ графа рендеринга
flutter debug dump-render-tree
```

## Заключение

Flutter Performance Toolkit и DevTools предоставляют мощный набор инструментов для анализа и оптимизации производительности. Понимание того, как использовать каждый инструмент, позволяет быстро выявлять и устранять проблемы производительности.

В следующих разделах мы рассмотрим конкретные техники оптимизации: оптимизацию виджетов, избегание лишних rebuild'ов, ленивую загрузку и другие техники.
