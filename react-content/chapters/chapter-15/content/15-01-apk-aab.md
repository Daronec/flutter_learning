# Сборка APK и AAB — команды и параметры

## Введение

Перед публикацией приложения в магазин приложений необходимо собрать релизную версию. Flutter поддерживает несколько форматов сборки для разных платформ. Понимание различий между форматами и правильная настройка сборки — ключевой этап подготовки приложения к релизу.

## Форматы сборки

### APK (Android Package Kit)

APK — это файл пакета Android, который содержит всё необходимое для установки приложения. Это универсальный формат, который можно установить на любое Android-устройство напрямую.

**Когда использовать APK:**
- Тестирование на реальных устройствах
- Распространение через сторонние магазины (Amazon Appstore)
- Внутреннее тестирование в команде
- Распространение через мессенджеры или веб-сайт

**Недостатки APK:**
- Файл содержит код для всех архитектур (большой размер)
- Google Play больше не принимает новые APK (с август 2021)
- Нет оптимизации под конкретное устройство

### AAB (Android App Bundle)

AAB — это новый формат пакета, разработанный Google. Он содержит весь скомпилированный код и ресурсы, но передаёт генерацию оптимизированных APK на сторону Google Play.

**Преимущества AAB:**
- Меньший размер загрузки (Google Play генерирует APK под конкретную архитектуру)
- Android App Store оптимизирует загрузку (Play Feature Delivery)
- Обязательный формат для новых приложений в Google Play

**Недостатки AAB:**
- Нельзя установить напрямую на устройство
- Требует Google Play Console для развёртывания

## Команды сборки

### Сборка APK

```bash
# Сборка APK для ARM (по умолчанию, для большинства устройств)
flutter build apk

# Сборка APK для всех архитектур (ARM64, ARM, x86_64, x86)
flutter build apk --split-per-abi

# Сборка APK в режиме Release (оптимизация, минификация)
flutter build apk --release

# Сборка APK в режиме Debug (для отладки)
flutter build apk --debug

# Сборка APK в режиме Profile (для профилирования производительности)
flutter build apk --profile
```

### Сборка AAB

```bash
# Сборка AAB в режиме Release
flutter build appbundle

# Сборка AAB с указанием целевой платформы
flutter build appbundle --target-platform=android-arm,android-arm64

# Сборка AAB с выводом в конкретную директорию
flutter build appbundle --output=./build/output
```

## Режимы сборки

### Debug Mode

Режим отладки, используется во время разработки. Не оптимизирован, содержит отладочную информацию.

```bash
flutter build apk --debug
```

**Характеристики:**
- Hot reload и hot restart поддерживаются
- Отладочные инструменты включены
- Нет минификации кода
- Размер файла максимальный

### Profile Mode

Режим профилирования, используется для анализа производительности.

```bash
flutter build apk --profile
```

**Характеристики:**
- Оптимизации включены (как в Release)
- Доступны инструменты профилирования в DevTools
- Подходит для замера FPS, использования памяти, CPU

### Release Mode

Релизный режим, используется для публикации.

```bash
flutter build appbundle --release
```

**Характеристики:**
- Все оптимизации включены
- Минификация кода (при настройке)
- Обфускация (при настройке)
- Минимальный размер файла

## Параметры сборки

### Разделение по архитектурам

```bash
# Создать отдельные APK для каждой архитектуры
flutter build apk --split-per-abi

# Результат:
# build/app/outputs/flutter-apk/
# ├── app-arm64-v8a-release.apk
# ├── app-armeabi-v7a-release.apk
# └── app-x86_64-release.apk
```

### Связывание (Shrinking и Obfuscation)

```bash
# Минификация и обфускация кода
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Для AAB
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

Параметры:
- `--obfuscate` — обфускация имён переменных и методов
- `--split-debug-info` — путь для хранения карты отладочной информации

### Кастомный entrypoint

```bash
# Указание пользовательского entry point
flutter build apk --release --target=lib/main_prod.dart

# Пример main_prod.dart
void main() {
  const bool isProd = bool.fromEnvironment('dart.define.is_prod', defaultValue: true);

  runApp(
    MyApp(
      environment: isProd ? Environment.PROD : Environment.DEV,
    ),
  );
}
```

### Определение переменных среды

```bash
# Определение переменных через dart.define
flutter build apk --release \
  --dart-define=API_URL=https://api.production.com \
  --dart-define=DEBUG_MODE=false \
  --dart-define=FEATURE_FLAG_NEW_UI=true

# Использование в коде
void main() {
  const String apiUrl = String.fromEnvironment('API_URL');
  const bool debugMode = bool.fromEnvironment('DEBUG_MODE', defaultValue: false);
  const bool featureFlag = bool.fromEnvironment('FEATURE_FLAG_NEW_UI', defaultValue: false);

  runApp(MyApp(apiUrl: apiUrl));
}
```

## Сравнение режимов сборки

| Параметр | Debug | Profile | Release |
|----------|-------|---------|---------|
| Оптимизации | Нет | Да | Да |
| Hot reload | Да | Нет | Нет |
| Отладка | Полная | Ограниченная | Нет |
| Размер файла | Большой | Средний | Минимальный |
| Производительность | Низкая | Хорошая | Максимальная |
| Назначение | Разработка | Профилирование | Публикация |

## Расположение файлов

```
build/
└── app/
    ├── intermediates/     # Промежуточные файлы сборки
    ├── outputs/
    │   ├── apk/
    │   │   └── release/
    │   │       ├── app-release.apk
    │   │       └── output-metadata.json
    │   └── bundle/
    │       └── release/
    │           └── app-release.aab
    └── debug/
        └── app-debug.apk
```

## Best Practices

- **Всегда собирайте в Release режиме** перед публикацией
- **Используйте AAB** для Google Play Store
- **Сохраняйте debug-info** для расшифровки stacktrace после обфускации
- **Тестируйте APK** на реальных устройствах перед публикацией
- **Проверяйте размер** — оптимизируйте ресурсы и код
- **Используйте переменные среды** для настройки под разные окружения
