---
tags:
  - build
  - deployment
  - ci-cd
chapter: 15
section: 7
title: Firebase App Distribution — тестовый деплой
alias: 15 07 firebase distribution
status: complete
---

# Firebase App Distribution — тестовый деплой

## Введение

Firebase App Distribution — бесплатный сервис от Google для распространения предварительных сборок приложения среди тестировщиков. Идеально подходит для этапа тестирования перед публикацией в магазинах.

## Настройка Firebase

### Создание проекта

1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Нажмите **Добавить проект**
3. Укажите название проекта
4. Подключите Google Analytics (рекомендуется)
5. Создайте проект

### Добавление приложения

**Для Android:**

```bash
# Установка Firebase CLI
npm install -g firebase-tools

# Вход в Firebase
firebase login

# Инициализация Firebase в проекте
flutterfire configure

# Следуйте инструкциям:
# 1. Выберите Firebase проект
# 2. Добавьте Android приложение (package name)
# 3. Добавьте iOS приложение (bundle ID)
```

**Файл: `firebase_options.dart`** (генерируется автоматически)

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get android {
    return const FirebaseOptions(
      apiKey: 'AIzaSy...',
      appId: '1:123456789:android:abcdef',
      messagingSenderId: '123456789',
      projectId: 'your-project-id',
    );
  }

  static FirebaseOptions get ios {
    return const FirebaseOptions(
      apiKey: 'AIzaSy...',
      appId: '1:123456789:ios:abcdef',
      messagingSenderId: '123456789',
      projectId: 'your-project-id',
      iosBundleId: 'com.mycompany.myapp',
    );
  }
}
```

### Подключение Firebase в приложении

**Файл: `pubspec.yaml`**

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_app_installations: ^0.2.4+8
```

**Файл: `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

## Настройка App Distribution

### Добавление тестировщиков

**Через Firebase Console:**

1. Откройте **App Distribution** в консоли
2. Перейдите на вкладку **Testers**
3. Добавьте тестировщиков:
   - По email (до 200 на проект)
   - Как группы тестировщиков

**Через Firebase CLI:**

```bash
# Добавление тестировщика
firebase appdistribution:testers:add \
  --project=your-project-id \
  --testers=tester@example.com

# Добавление группы тестировщиков
firebase appdistribution:testers:add \
  --project=your-project-id \
  --testers=@my-team

# Удаление тестировщика
firebase appdistribution:testers:remove \
  --project=your-project-id \
  --testers=tester@example.com

# Список всех тестировщиков
firebase appdistribution:testers:list \
  --project=your-project-id
```

### Создание групп тестировщиков

```bash
# Создание группы
firebase appdistribution:testers:add \
  --project=your-project-id \
  --testers=@qa-team,@dev-team,@internal

# QA команда
firebase appdistribution:testers:add \
  --project=your-project-id \
  --testers=@qa-team \
  --emails=qa1@example.com,qa2@example.com

# Внутренняя команда
firebase appdistribution:testers:add \
  --project=your-project-id \
  --testers=@internal \
  --emails=dev1@example.com,dev2@example.com
```

## Распространение сборок

### Через Firebase CLI

```bash
# Сборка и загрузка APK/AAB
flutter build apk --release
flutter build appbundle --release

# Загрузка APK
firebase appdistribution:distribute \
  build/app/outputs/apk/release/app-release.apk \
  --app=1:123456789:android:abcdef \
  --testers=@qa-team,@dev-team \
  --release-notes="Исправления багов и новые функции"

# Загрузка AAB
firebase appdistribution:distribute \
  build/app/outputs/bundle/release/app-release.aab \
  --app=1:123456789:android:abcdef \
  --testers=@qa-team \
  --release-notes-path=./release-notes.txt

# Загрузка для iOS
firebase appdistribution:distribute \
  build/ios/ipa/MyApp.ipa \
  --app=1:123456789:ios:abcdef \
  --testers=@qa-team \
  --release-notes="Beta release with new features"
```

### С параметрами

```bash
# Установка срока действия ссылки
firebase appdistribution:distribute \
  app-release.aab \
  --app=YOUR_APP_ID \
  --testers=@qa-team \
  --expirations-days=7 \
  --release-notes="Release notes here"

# Загрузка с группами
firebase appdistribution:distribute \
  app-release.aab \
  --app=YOUR_APP_ID \
  --groups=qa-team,internal \
  --release-notes="New build available"

# Проверка перед загрузкой
firebase appdistribution:distribute \
  app-release.aab \
  --app=YOUR_APP_ID \
  --testers=@qa-team \
  --dry-run
```

### Файл с примечаниями к релизу

**Файл: `release-notes.txt`**

```
Версия 1.1.0:

Новые функции:
• Добавлен тёмный режим
• Новый экран настроек
• Оптимизация загрузки изображений

Исправления:
• Исправлен крэш при авторизации
• Исправлено отображение на маленьких экранах
```

## Интеграция с CI/CD

### GitHub Actions

```yaml
# .github/workflows/firebase-distribution.yml
name: Firebase App Distribution

on:
  push:
    tags:
      - 'v*'

jobs:
  distribute:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x.x'

      - name: Setup Firebase
        uses: w9jds/firebase-action@v12
        with:
          args: appdistribution:distribute
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
          APP_ID: ${{ secrets.APP_ID }}
          APK_PATH: build/app/outputs/apk/release/app-release.aab
          TESTERS: "@qa-team,@dev-team"
          RELEASE_NOTES: "New release from CI/CD"

      - name: Build and Distribute
        run: |
          flutter pub get
          flutter build appbundle --release

          firebase appdistribution:distribute \
            build/app/outputs/bundle/release/app-release.aab \
            --app=$APP_ID \
            --testers=$TESTERS \
            --release-notes="$RELEASE_NOTES"
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
          APP_ID: ${{ secrets.APP_ID }}
          TESTERS: "@qa-team,@dev-team"
          RELEASE_NOTES: "Версия ${{ github.ref_name }}"
```

### Fastlane

```ruby
# Fastfile
platform :android do
  desc "Distribute to Firebase App Distribution"
  lane :distribute_firebase do
    flutter_build(
      target: "lib/main.dart",
      release: true,
      build_type: "appbundle"
    )

    firebase_app_distribution(
      app: "1:123456789:android:abcdef",
      testers: "qa@example.com,dev@example.com",
      release_notes: "New release from Fastlane",
      android_artifact_type: "APP_BUNDLE",
      firebase_cli_token: ENV['FIREBASE_TOKEN']
    )
  end
end
```

## Получение уведомлений тестировщиками

### Процесс для тестировщика

```
1. Тестировщик получает email-уведомление
   └── "Вы приглашены тестировать MyApp v1.1.0"

2. Переходит по ссылке или открывает Firebase App Distribution app
   └── На Android: установка через Google Play
   └── На iOS: установка через TestFlight или IPA

3. Устанавливает приложение
   └── Первый раз: регистрация через Firebase

4. Тестирует приложение
   └── Отправляет feedback через приложение

5. Получает уведомления о новых версиях
   └── Email или push-уведомление
```

### Firebase App Distribution App

Тестировщики могут использовать официальное приложение для управления бета-тестированием:

- **Android**: доступен в Google Play
- **iOS**: доступен в App Store
- **Функции**:
  - Просмотр доступных сборок
  - Установка/удаление сборок
  - Отправка feedback разработчикам
  - Получение уведомлений

## Best Practices

- **Используйте группы тестировщиков** для организации
- **Добавляйте release notes** к каждому релизу
- **Устанавливайте срок действия** ссылок (7–30 дней)
- **Тестируйте процесс установки** перед массовым распространением
- **Собирайте feedback** от тестировщиков
- **Используйте CI/CD** для автоматизации релизов
