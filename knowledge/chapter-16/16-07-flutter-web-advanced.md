---
tags:
  - platform-channels
  - native
  - plugins
chapter: 16
section: 7
title: Flutter для Web — особенности и ограничения
alias: 16 07 flutter web advanced
status: complete
---

# Flutter для Web — особенности и ограничения

Flutter для Web позволяет разворачивать Flutter-приложения в браузере. Однако веб-архитектура имеет специфические особенности и ограничения, которые необходимо учитывать при разработке.

## Web Architecture

### Режимы компиляции для Web

| Режим | Компилятор | Размер бандла | Производительность | Использование |
|-------|-----------|---------------|-------------------|---------------|
| HTML | Dart2JS | ~2-4 MB | JIT/AOT | По умолчанию |
| CanvasKit | Dart2JS + CanvasKit | ~6-7 MB | AOT (максимум) | `--web-renderer canvaskit` |
| Skia | Dart2JS + Skia WASM | ~4-5 MB | AOT | `--web-renderer skwasm` |

### Сравнение web-рендереров

| Рендерер | Технология | Качество | Производительность | Размер |
|----------|-----------|----------|-------------------|--------|
| HTML | DOM + CSS | Стандартный | Высокая | ~1 MB |
| CanvasKit | WebGL (CanvasKit WASM) | Максимальный | Высокая | ~6 MB |
| Skia (SKWasm) | WebAssembly | Высокий | Средняя | ~4 MB |

### Выбор рендерера

```bash
# HTML renderer (по умолчанию)
flutter run -d chrome

# CanvasKit renderer
flutter run -d chrome --web-renderer canvaskit

# Skia renderer (SKWasm)
flutter run -d chrome --web-renderer skwasm
```

## Особенности Web

### Platform.isWeb

```dart
import 'package:flutter/foundation.dart';

class PlatformChecker {
  bool get isWeb => kIsWeb;
  bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
}

// Использование в коде
Widget build(BuildContext context) {
  if (kIsWeb) {
    return WebSpecificWidget();
  } else {
    return MobileSpecificWidget();
  }
}
```

### Web-specific ограничения

| Ограничение | Описание | Обходной путь |
|------------|----------|---------------|
| Нет доступа к файловой системе | Браузер не даёт прямой доступ | Используйте `file_uploader` пакет |
| Ограниченный доступ к устройствам | Камера, GPS через Web API | Используйте `web` пакеты |
| Нет native UI | Нет нативных диалогов | Используйте `url_launcher` или кастомные |
| Ограниченная память | Ограничения браузера | Оптимизируйте бандл |
| Нет Background Execution | Нет фонового выполнения | Используйте Service Workers |

## Оптимизация Web-бандла

### Анализ размера бандла

```bash
# Анализ размера бандла
flutter build web --source-maps

# Вывод:
# Total Web bundle size: 3.2 MB
# JavaScript: 2.1 MB
# CanvasKit: 1.1 MB
```

### Стратегии уменьшения размера

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  # Используйте только необходимые пакеты
  http: ^1.1.0
  # Избегайте крупных пакетов если можно
  # bad: flutter_svg + flutter_sparkline
  # good: custom SVG widget

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### Tree Shaking

```bash
# Tree shaking включён по умолчанию в release
flutter build web --release

# Дополнительные флаги оптимизации
flutter build web --release \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=canvaskit.js \
  --split-debug-info=build/debug_info
```

### Lazy Loading для CanvasKit

```dart
// Кастомный main с lazy loading CanvasKit
import 'package:flutter/web_ui.dart' as ui;

void main() async {
  // Проверяем поддержку CanvasKit
  final supportsCanvasKit = await ui.WebGLInfo.instance.supportsWebGL();

  if (supportsCanvasKit) {
    // Используем CanvasKit
    ui.WebRendererDefault = ui.WebRenderer.canvaskit;
  } else {
    // Fallback на HTML
    ui.WebRendererDefault = ui.WebRenderer.html;
  }

  runApp(const MyApp());
}
```

## Web-specific API

### Работа с URL и навигацией

```dart
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WebNavigator {
  /// Открыть ссылку в новой вкладке
  Future<bool> openInNewTab(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }

  /// Получить параметры URL
  Map<String, String> getQueryParameters() {
    if (!kIsWeb) return {};
    // В реальном проекте используйте 'web' пакет или 'url_strategy'
    final href = window.location.href; // через 'web' package
    final uri = Uri.parse(href);
    return uri.queryParameters;
  }

  /// Изменить URL без перезагрузки
  void navigateTo(String path) {
    if (kIsWeb) {
      window.history.pushState(null, '', path);
    }
  }
}
```

### Работа с LocalStorage

```dart
// Для работы с LocalStorage на Web используйте пакет 'web'
// pubspec.yaml:
// dependencies:
//   web: ^0.3.0

import 'package:web/web.dart' as web;

class WebStorage {
  /// Сохранить данные в LocalStorage
  static void save(String key, String value) {
    if (kIsWeb) {
      web.window.localStorage.setItem(key, value);
    }
  }

  /// Получить данные из LocalStorage
  static String? load(String key) {
    if (kIsWeb) {
      return web.window.localStorage.getItem(key);
    }
    return null;
  }

  /// Удалить данные
  static void remove(String key) {
    if (kIsWeb) {
      web.window.localStorage.removeItem(key);
    }
  }

  /// Очистить всё
  static void clear() {
    if (kIsWeb) {
      web.window.localStorage.clear();
    }
  }
}
```

### Работа с IndexedDB

```dart
// Для более сложного хранения используйте IndexedDB
// Пакет: indexed_db_flutter или isar с web поддержкой

class WebDatabase {
  static const _dbName = 'flutter_web_db';
  static const _version = 1;
  static const _storeName = 'data';

  // В реальном проекте используйте пакет 'isar' или 'drift' с web поддержкой
  // Для простого хранения достаточно SharedPreferences + LocalStorage fallback
}
```

## Web Performance

### Оптимизация загрузки

```html
<!-- web/index.html — оптимизация загрузки -->
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>My App</title>
  <script>
    // Кэшируем CanvasKit для ускорения повторных загрузок
    window.flutter_web_config = {
      "canvaskitUrl": "canvaskit/canvaskit.js",
    };
  </script>
</head>
<body>
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

### Preloading ресурсов

```dart
// Предзагрузка ресурсов для ускорения
class ResourcePreloader {
  static Future<void> preloadAssets() async {
    // Предзагрузка шрифтов
    await _preloadFonts();
    // Предзагрузка изображений
    await _preloadImages();
  }

  static Future<void> _preloadFonts() async {
    // Шрифты загружаются автоматически через pubspec.yaml
  }

  static Future<void> _preloadImages() async {
    // Предзагрузка критических изображений
    final image = NetworkImage('https://example.com/critical.jpg');
    // В реальном проекте используйте precacheImage
  }
}
```

### Code Splitting

```dart
// Разделение кода для lazy loading
class LazyLoadedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // В Flutter для Web code splitting работает через
    // динамический импорт (dart:deferred_library)
    return const ComplexWidget();
  }
}

// Для lazy loading используйте:
// import 'package:my_app/lazy_module.dart' deferred as lazy;
//
// Future<void> loadLazyModule() async {
//   await lazy.loadLibrary();
//   lazy.doSomething();
// }
```

## SEO и Web-specific

### SEO для Flutter Web

```dart
// Flutter Web не индексируется поисковиками по умолчанию
// Решения:

// 1. Использовать SSR (Server-Side Rendering) — через next.dart или аналогичные
// 2. Использовать Prerendered HTML
// 3. Использовать SSG (Static Site Generation)

// flutter build web --prerender-index
// Это генерирует статический HTML для SEO
```

### PWA (Progressive Web App)

```yaml
# pubspec.yaml — настройка PWA
flutter:
  assets:
    - assets/icons/icon-192.png
    - assets/icons/icon-512.png
    - assets/manifest.json
```

```json
// assets/manifest.json
{
  "name": "Flutter Web App",
  "short_name": "FlutterApp",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2196f3",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

## Best Practices

1. **Используйте `kIsWeb` для платформенного кода** — проверяйте платформу:
   ```dart
   if (kIsWeb) {
     // Web-specific implementation
   }
   ```

2. **Оптимизируйте размер бандла** — анализируйте с `flutter build web --source-maps`.

3. **Используйте CanvasKit только при необходимости** — HTML-рендерер легче.

4. **Кэшируйте ресурсы** — используйте Service Workers для PWA.

5. **Тестируйте на разных браузерах** — Chrome, Firefox, Safari, Edge.

6. **Избегайте нативных API** — используйте web-совместимые пакеты.

7. **Включайте `--split-debug-info`** — для профилирования:
   ```bash
   flutter build web --release --split-debug-info=build/symbols
   ```

8. **Используйте `--web-renderer html`** для простых приложений:
   ```bash
   flutter build web --web-renderer html
   ```

9. **Проверяйте производительность** — используйте DevTools Performance tab.

10. **Поддерживайте fallback** — для устройств с плохой поддержкой WebGL.
