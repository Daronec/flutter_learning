# 2.10 Пакетная система: pubspec, зависимости, pub.dev

## pubspec.yaml

### Структура файла

```yaml
name: my_app                    # Имя пакета (уникальное, lowercase_with_underscores)
description: My Flutter app     # Описание пакета
version: 1.0.0+1                # Версия: semantic + build number

# Запрещённые имена пакетов
# flutter, dart, package, http, etc.

environment:
  sdk: '>=3.0.0 <4.0.0'        # Совместимость с версией Dart SDK
  flutter: ">=3.0.0"            # Совместимость с версией Flutter

dependencies:
  flutter:
    sdk: flutter               # Flutter SDK
  cupertino_icons: ^1.0.6      # Внешняя зависимость
  http: ^1.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  lint: ^2.0.0
  build_runner: ^2.4.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - config/app.json
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

## Зависимости

### Типы зависимостей

| Тип | Описание | Пример |
|---|---|---|
| **SDK** | Зависимость от SDK | `flutter`, `dart` |
| **Публикованные** | Пакеты с pub.dev | `http`, `provider` |
| **Git** | Из Git-репозитория | `url: git://...` |
| **Path** | Локальная зависимость | `path: ../shared` |
| **Hosted** | С произвольного сервера | `url: https://...` |

### Версионирование (Semantic Versioning)

```
MAJOR.MINOR.PATCH

1.0.0 → 2.0.0  — Breaking changes
1.0.0 → 1.1.0  — New features (backwards compatible)
1.0.0 → 1.0.1  — Bug fixes
```

### Караты версий

```yaml
# ^ — совместимые с версией
http: ^1.1.0     # >=1.1.0 <2.0.0

# ~ — патч-совместимые
http: ~1.1.0     # >=1.1.0 <1.2.0

# >= — минимальная версия
http: ">=1.0.0"

# = — точная версия
http: "=1.0.0"
```

### Зависимость из Git

```yaml
dependencies:
  my_package:
    git:
      url: git://github.com/user/my_package.git
      ref: main  # branch, tag, or commit
```

### Локальная зависимость

```yaml
dependencies:
  shared_utils:
    path: ../shared_utils
```

## pub.dev

### Что такое pub.dev?

[pub.dev](https://pub.dev) — официальный реестр пакетов для Dart и Flutter.

### Поиск и использование пакетов

1. Перейти на [pub.dev](https://pub.dev)
2. Найти нужный пакет (например, `provider`)
3. Скопировать команду:
```bash
flutter pub add provider
```
4. Или добавить в `pubspec.yaml` вручную

### Популярные пакеты

| Пакет | Назначение |
|---|---|
| `provider` | Управление состоянием |
| `http` | HTTP запросы |
| `dio` | Продвинутый HTTP-клиент |
| `flutter_bloc` | BLoC паттерн |
| `get_it` | Dependency Injection |
| `sqflite` | SQLite база данных |
| `hive` | NoSQL хранилище |
| `freezed` | Код-генерация для data classes |
| `json_serializable` | JSON сериализация |
| `go_router` | Декларативная маршрутизация |

## Команды pub

### Основные команды

```bash
# Установка зависимостей
flutter pub get
dart pub get

# Обновление зависимостей
flutter pub upgrade
flutter pub upgrade --major-versions

# Добавление зависимости
flutter pub add provider
flutter pub add --dev lint

# Удаление зависимости
flutter pub remove provider

# Просмотр зависимостей
flutter pub deps

# Публикация пакета
flutter pub publish

# Проверка пакета перед публикацией
flutter pub publish --dry-run

# Кэш
flutter pub cache clean
flutter pub cache repair
```

## pubspec.lock

### Назначение

```yaml
# pubspec.lock — автоматически генерируемый файл
# Фиксирует точные версии всех зависимостей

packages:
  provider:
    dependency: "direct main"
    description:
      name: provider
      url: "https://pub.dev"
    source: hosted
    version: "6.1.1"
  flutter_plugin:
    dependency: "direct dev"
    description:
      name: flutter_plugin
      url: "github.com"
    source: git
    ref: main
    resolved_ref: "abc123def456"
    tree: ...
    url: "https://github.com/user/flutter_plugin.git"
```

### Правила

- ✅ **Должен быть в git** — обеспечивает воспроизводимую сборку
- ❌ **Не редактировать вручную**
- 🔄 **Обновлять** через `flutter pub upgrade`

## Создание собственного пакета

### Типы пакетов

| Тип | Описание |
|---|---|
| **app** | Приложение (по умолчанию) |
| **package** | Библиотека кода |
| **plugin** | Библиотека с нативным кодом |
| **module** | Модуль для встраивания в нативное приложение |

### Создание пакета

```bash
# Package (код без нативных частей)
flutter create --template=package shared_utils

# Plugin (с нативной частью)
flutter create --template=plugin my_plugin --platforms=android,ios
```

### Структура пакета

```
my_package/
├── lib/
│   ├── my_package.dart      # Главный export
│   └── src/
│       ├── utils.dart
│       └── models.dart
├── test/
│   └── my_package_test.dart
├── pubspec.yaml
└── README.md
```

### pubspec для пакета

```yaml
name: my_package
description: A useful Flutter package
version: 0.1.0

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter

flutter:
```

## Best Practices

### Управление зависимостями

1. **Используйте `^` для версий** — автоматическое обновление патчей
2. **Регулярно обновляйте зависимости** — `flutter pub upgrade`
3. **Проверяйте pubspec.lock** — фиксируйте версии
4. **Используйте `--dry-run`** перед публикацией
5. **Читайте CHANGELOG** при обновлении зависимостей

### Публикация

1. Напишите хороший README.md
2. Добавьте примеры кода
3. Напишите тесты
4. Запустите `flutter pub publish --dry-run`
5. Опубликуйте `flutter pub publish`

## Заключение

Пакетная система Dart — мощный инструмент для управления зависимостями. pub.dev содержит тысячи пакетов, которые ускоряют разработку. Понимание версионирования и управления зависимостями — ключ к стабильной разработке.
