---
tags:
  - flutter
  - intro
  - basics
chapter: 1
section: 6
title: Первый запуск: создание и запуск приложения
alias: 01 06 first run
status: complete
---

# 1.6 Первый запуск: создание и запуск приложения

## Создание проекта

### Команда flutter create

```bash
# Создание проекта в текущей директории
flutter create my_app

# Создание проекта с указанием имени пакета
flutter create com.example.my_app

# Создание проекта для конкретной платформы
flutter create my_app --platforms=android,ios    # только мобильные
flutter create my_app --platforms=web            # только веб
flutter create my_app --platforms=windows,linux  # только десктоп

# Создание проекта с выбором языка
flutter create my_app --org com.example          # organization reverse domain
```

### Аргументы команды

| Аргумент | Описание |
|---|---|
| `--org` | Reverse domain name (например, com.example) |
| `--platforms` | Список платформ (android, ios, linux, macos, web, windows) |
| `--template` | Шаблон: app, plugin, packages, module |
| `--dart-sdk` | Путь к Dart SDK |

## Запуск приложения

### Запуск на подключённом устройстве

```bash
# Показать доступные устройства
flutter devices

# Запустить на первом доступном устройстве
flutter run

# Запустить на конкретном устройстве
flutter run -d <device-id>

# Запустить на эмуляторе Android
flutter run -d emulator

# Запустить на iOS симуляторе
flutter run -d iPhone

# Запустить в Chrome (веб)
flutter run -d chrome

# Запустить на Windows
flutter run -d windows
```

### Режимы запуска

| Режим | Описание |
|---|---|
| **Debug** | По умолчанию, с DevTools, отладкой, без оптимизации |
| **Profile** | Для профилирования производительности |
| **Release** | Оптимизированная сборка для публикации |

```bash
# Запуск в разных режимах
flutter run --debug          # Debug (по умолчанию)
flutter run --profile        # Profile
flutter run --release        # Release
```

## Структура стартового приложения

После создания проекта в `lib/main.dart` генерируется стартовое приложение:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
```

### Разбор компонентов

1. **`void main()`** — точка входа, аналог `main()` в других языках
2. **`runApp()`** — функция, которая «запускает» виджет как корневой
3. **`MaterialApp`** — корневой виджет Material Design приложения
4. **`theme`** — тема приложения (цвета, шрифты)
5. **`home`** — первый экран, отображаемый при запуске

## Запуск с параметрами

```bash
# Горячая перезагрузка при запуске
flutter run --flavor dev

# С указанием профиля сборки
flutter run --dart-define=ENV=production

# На конкретной платформе
flutter run -d windows --release
```

## Горячая перезагрузка (Hot Reload)

При запуске через IDE (Android Studio, VS Code):
- **Ctrl+S** (Windows/Linux) или **Cmd+S** (macOS) — сохранение файла
- IDE автоматически выполняет Hot Reload
- Состояние сохраняется, UI обновляется мгновенно

Через терминал:
```
r — Hot Reload
R — Hot Restart
q — Quit
```

## Создание простого приложения

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мое первое приложение',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Привет, Flutter!'),
        ),
        body: const Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}
```

## Заключение

Первый запуск Flutter-приложения — простой процесс:
1. `flutter create my_app` — создание проекта
2. `flutter run` — запуск на устройстве
3. Hot Reload — мгновенное отображение изменений
