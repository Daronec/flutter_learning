---
tags:
  - flutter
  - intro
  - basics
chapter: 1
section: 5
title: Структура Flutter-проекта: папки и файлы
alias: 01 05 project structure
status: complete
---

# 1.5 Структура Flutter-проекта: папки и файлы

## Обзор структуры

При создании нового Flutter-проекта (`flutter create my_app`) генерируется следующая структура:

```
my_app/
├── .idea/                    # Конфигурации для IDE (Android Studio, VS Code)
├── android/                  # Нативный Android-проект (Kotlin/Java)
├── ios/                      # Нативный iOS-проект (Swift/Objective-C)
├── linux/                    # Нативный Linux-проект (C++)
├── macos/                    # Нативный macOS-проект (C++)
├── web/                      # Файлы для веб-версии (index.html, favicon)
├── windows/                  # Нативный Windows-проект (C++)
├── lib/                      # Исходный код Dart (основная часть проекта)
│   └── main.dart             # Точка входа приложения
├── test/                     # Unit и widget тесты
├── pubspec.yaml              # Конфигурация проекта и зависимости
├── pubspec.lock              # Зафиксированные версии зависимостей
├── README.md                 # Документация проекта
└── analysis_options.yaml     # Правила статического анализа (lints)
```

## Ключевые файлы и директории

### lib/ — основная директория кода

```
lib/
├── main.dart                 # Точка входа (функция main())
├── home/                     # Пример: группировка по экранам
│   ├── home_page.dart
│   ├── home_viewmodel.dart
│   └── widgets/
├── shared/                   # Общие компоненты
│   ├── widgets/              # Переиспользуемые виджеты
│   └── theme/                # Тема приложения
└── utils/                    # Утилиты и хелперы
```

**main.dart** — точка входа:
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
```

### pubspec.yaml — конфигурация проекта

Основные разделы:

```yaml
name: my_app                  # Имя пакета (уникальное, в нижнем регистре)
description: My Flutter app   # Описание
version: 1.0.0+1              # Версия + build number

environment:
  sdk: '>=3.0.0 <4.0.0'       # Совместимость с версией Dart
  flutter: ">=3.0.0"          # Совместимость с версией Flutter

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                # Внешняя зависимость

dev_dependencies:
  flutter_test:
    sdk: flutter
  lint: ^2.0.0                # Dev-зависимости

flutter:
  uses-material-design: true   # Material Icons
  assets:
    - assets/images/           # Статические файлы
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
```

### android/ — Android-часть

```
android/
├── app/
│   ├── src/main/
│   │   ├── AndroidManifest.xml   # Манифест Android-приложения
│   │   ├── java/ или kotlin/     # Нативный код
│   │   └── res/                  # Ресурсы (drawable, layout, values)
│   ├── build.gradle.kts          # Gradle-конфигурация
│   └── proguard-rules.pro        # Правила обфускации
├── build.gradle.kts              # Корневой Gradle
└── local.properties              # Путь к Android SDK
```

### ios/ — iOS-часть

```
ios/
├── Runner/
│   ├── Runner.xcodeproj          # Xcode проект
│   ├── AppDelegate.swift         # Точка входа iOS
│   └── Info.plist                # Конфигурация iOS
├── Flutter/
│   └── App.framework             # Скомпилированный Flutter-движок
└── Podfile                       # CocoaPods зависимости
```

## Дополнительные файлы

### pubspec.lock

- Автоматически генерируемый файл
- Фиксирует точные версии всех зависимостей
- Не редактируется вручную
- Должен быть в `.gitignore` (в некоторых проектах)

### analysis_options.yaml

- Правила статического анализа Dart
- Lint-правила для проверки кода
- Можно настроить строгость проверки

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    avoid_print: true
```

### .gitignore

```gitignore
# Flutter/Dart
.dart_tool/
.packages
build/
*.iml
.idea/
```

## Платформозависимые директории

- **android/**, **ios/** — для нативной интеграции и публикации
- **linux/**, **macos/**, **windows/** — для десктоп-версии
- **web/** — для веб-версии

> **Важно**: Основная логика приложения находится в `lib/`. Платформозависимые папки генерируются автоматически и обычно не требуют ручного редактирования.

## Заключение

Понимание структуры проекта помогает:
- Организовать код по модулям
- Правильно управлять зависимостями
- Настроить ресурсы и ассеты
- Публиковать приложение в магазины
