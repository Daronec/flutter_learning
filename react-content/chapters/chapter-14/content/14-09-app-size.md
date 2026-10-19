# 14-09. App Size Optimization — Уменьшение размера бандла

## Введение

Размер приложения — важный фактор, влияющий на конверсию и пользовательский опыт. Пользователи не хотят скачивать большие приложения, а магазины приложений имеют ограничения на размер. Оптимизация размера бандла позволяет уменьшить размер приложения и улучшить время загрузки.

## Tree Shaking

### Что такое Tree Shaking

Tree Shaking — это процесс удаления неиспользуемого кода из финального бандла. Dart-компилятор автоматически анализирует код и удаляет всё, что не используется.

### Как работает Tree Shaking

```
Исходный код:
  ├── module_a.dart
  │   ├── function_a1()    ← используется
  │   └── function_a2()    ← НЕ используется
  ├── module_b.dart
  │   ├── function_b1()    ← используется
  │   └── function_b2()    ← НЕ используется
  └── main.dart

Результат Tree Shaking:
  ├── module_a.dart
  │   └── function_a1()    ← ✓
  ├── module_b.dart
  │   └── function_b1()    ← ✓
  └── main.dart
```

### Пример: Tree Shaking в действии

```dart
// main.dart
import 'package:flutter/material.dart';
import 'utils/math_utils.dart';
import 'utils/string_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Используется только MathUtils, StringUtils будет удалён
    final result = MathUtils.add(1, 2);
    return MaterialApp(home: Text('Result: $result'));
  }
}

// utils/math_utils.dart
class MathUtils {
  static int add(int a, int b) => a + b;
  static int subtract(int a, int b) => a - b;
  static int multiply(int a, int b) => a * b;
}

// utils/string_utils.dart
class StringUtils {
  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  static String reverse(String s) => s.split('').reversed.join();
}
// StringUtils будет удалён — не используется
```

### Tree Shaking для Flutter виджетов

```dart
// Tree Shaking работает и для виджетов
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      // Эти маршруты будут удалены, если не используются
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Hello')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings')),
    );
  }
}

// SettingsPage и ProfilePage будут удалены из бандла,
// если они не используются в runtime
```

## Release Mode

### Разница между Debug и Release

| Характеристика | Debug | Release |
|---------------|-------|---------|
| Tree Shaking | Нет | Да |
| AOT компиляция | Нет (JIT) | Да (AOT) |
| Размер бандла | Большой | Маленький |
| Производительность | Низкая | Высокая |
| Hot Reload | Да | Нет |

### Команды сборки

```bash
# Сборка APK для Android
flutter build apk --release

# Сборка APK с анализом размера
flutter build apk --release --analyze-size

# Сборка App Bundle для Google Play
flutter build appbundle --release

# Сборка IPA для iOS
flutter build ios --release

# Сборка для Web
flutter build web --release
```

## ProGuard / R8

### Что такое ProGuard/R8

ProGuard и R8 — это инструменты для оптимизации Java/Kotlin-кода в Android:

- **ProGuard** — удаляет неиспользуемый код и переименовывает классы
- **R8** — более современный инструмент, включает функциональность ProGuard

### Настройка R8

```proguard
# android/app/proguard-rules.pro

# Сохраняем модели данных
-keep class com.example.model.** { *; }

# Сохраняем JSON-сериализуемые классы
-keep class * implements java.io.Serializable { *; }

# Сохраняем Flutter-методы
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Сохраняем нативные методы
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Сохраняем Reflection-классы
-keep class com.example.util.** { *; }
```

### Настройка в build.gradle

```groovy
// android/app/build.gradle
android {
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true      // Включаем минификацию
            shrinkResources true    // Включаем удаление ресурсов
            proguardFiles getDefaultProguardFile(
                'proguard-android-optimize.txt'),
                'proguard-rules.pro'
        }
    }
}
```

### Shrink Resources

```groovy
// android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true  // Удаляет неиспользуемые ресурсы
            proguardFiles getDefaultProguardFile(
                'proguard-android-optimize.txt'),
                'proguard-rules.pro'
        }
    }
}
```

## Оптимизация ресурсов

### Оптимизация изображений

```yaml
# pubspec.yaml
flutter:
  assets:
    # Указываем конкретные пути, а не директории
    - assets/images/logo.png
    - assets/images/banner.webp
    - assets/icons/home.svg
```

### Удаление неиспользуемых ресурсов

```bash
# Проверка размера assets
find assets -type f -exec du -ch {} + | tail -n 1

# Оптимизация изображений
# Используйте инструменты сжатия для всех изображений
# PNG: pngquant, optipng
# JPEG: jpegoptim, mozjpeg
# WebP: cwebp
```

### Asset-файлы

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/fonts/
    - assets/data/

  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

## Оптимизация зависимостей

### Анализ зависимостей

```bash
# Просмотр всех зависимостей
flutter pub deps

# Поиск неиспользуемых зависимостей
# Удалите зависимости, которые не используются
flutter pub remove unused_package
```

### Минимизация зависимостей

| Критерий | Действие |
|----------|----------|
| Зависимость не используется | Удалить |
| Большая зависимость для простой задачи | Найти лёгкую альтернативу |
| Дублирующиеся функции | Объединить |
| Тяжёлый пакет | Рассмотреть нативную реализацию |

### Пример: замена тяжёлых зависимостей

```yaml
# Плохо — heavy dependency для простой задачи
dependencies:
  intl: ^0.19.0      # ~1 MB — для форматирования даты
  json_serializable: ^6.8.0  # ~500 KB — для простой сериализации

# Хорошо — используем встроенные средства
dependencies:
  # Форматирование даты без intl
  # json_serializable без кодогенерации
  # Используем встроенные DateTime и manual JSON
```

## Оптимизация для разных платформ

### Android оптимизации

```groovy
// android/app/build.gradle
android {
    // Разделение APK по архитектурам
    splits {
        abi {
            reset()
            enable true
            include "armeabi-v7a", "arm64-v8a", "x86_64"
            universalApk true
        }
    }

    // Минификация
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile(
                'proguard-android-optimize.txt'),
                'proguard-rules.pro'
        }
    }
}
```

### iOS оптимизации

```bash
# Сжатие биткода для iOS
# Xcode -> Build Settings -> Enable Bitcode = YES

# Сжатие изображений
# Используйте .jpg вместо .png для фотографий
# Используйте .webp через плагин

# Оптимизация размера фреймворка
# flutter build ios --release --no-codesign
```

## Анализ размера приложения

### Анализ размера APK

```bash
# Генерация отчёта о размере
flutter build apk --release --analyze-size

# Создание APK с анализом
flutter build apk --release
```

### Анализ размера IPA

```bash
# Сборка iOS с анализом
flutter build ios --release

# Анализ размера через Xcode
# Xcode -> Product -> Archive -> Analytics
```

### Онлайн-анализаторы

| Инструмент | Платформа | Описание |
|------------|-----------|----------|
| APK Analyzer | Android | Встроенный в Android Studio |
| iMazing | iOS | Анализ IPA-файлов |
| size-apk | Android | CLI-инструмент |
| Flutter Size | Flutter | Пакет для анализа размера виджетов |

## Best Practices

### Рекомендации по уменьшению размера

1. **Всегда собирайте в Release mode** — Tree Shaking и минификация
2. **Используйте WebP вместо PNG/JPEG** — на 25-35% меньше размер
3. **Удалите неиспользуемые зависимости** — уменьшает бандл
4. **Включите ProGuard/R8 для Android** — удаляет неиспользуемый код
5. **Указывайте конкретные assets** — не включайте целые директории
6. **Используйте `shrinkResources true`** — удаляет неиспользуемые ресурсы

### Чек-лист оптимизации размера

- [ ] Сборка в Release mode
- [ ] ProGuard/R8 включён для Android
- [ ] Shrink resources включён
- [ ] Изображения в формате WebP
- [ ] Неиспользуемые зависимости удалены
- [ ] Конкретные пути к assets
- [ ] Размер APK < 50 MB (для Google Play)
- [ ] Размер IPA оптимизирован

## Заключение

Оптимизация размера приложения — это комплексная задача, включающая Tree Shaking, минификацию кода, сжатие ресурсов и удаление неиспользуемых зависимостей. Правильная настройка этих процессов позволяет значительно уменьшить размер бандла без потери функциональности.
