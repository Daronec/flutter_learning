---
tags:
  - build
  - deployment
  - ci-cd
chapter: 15
section: 9
title: Crash Reporting — Firebase Crashlytics
alias: 15 09 crash reporting
status: complete
---

# Crash Reporting — Firebase Crashlytics

## Введение

Crashlytics — бесплатный инструмент от Google для мониторинга крашей и ошибок в реальном времени. Позволяет быстро обнаруживать, классифицировать и исправлять проблемы в приложении.

## Установка и настройка

### Добавление зависимостей

**Файл: `pubspec.yaml`**

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_crashlytics: ^3.4.0

dev_dependencies:
  firebase_crashlytics: ^3.4.0
  flutter_test:
    sdk: flutter
```

### Инициализация

**Файл: `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Настройка Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Перехват незафиксированных исключений
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

### Настройка для Android

**Файл: `android/app/build.gradle`**

```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"
    id "com.google.firebase.crashlytics"
}

dependencies {
    // Firebase Crashlytics
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-crashlytics'
}
```

### Настройка для iOS

**Файл: `ios/Podfile`**

```ruby
platform :ios, '13.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
      ]
    end
  end
end
```

## Запись ошибок

### Запись исключений

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class MyService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('https://api.example.com/data'));
      // обработка данных
    } catch (e, stackTrace) {
      // Запись исключения в Crashlytics
      await _crashlytics.recordError(e, stackTrace);
      // Или для фатальных ошибок
      await _crashlytics.recordFatalError(e, stackTrace);
    }
  }
}
```

### Запись предупреждений и логов

```dart
await FirebaseCrashlytics.instance.log('Начало загрузки данных');
await FirebaseCrashlytics.instance.log('Получено 150 записей');
await FirebaseCrashlytics.instance.log('Обработка завершена');

// Запись предупреждения
await FirebaseCrashlytics.instance.log('Внимание: данные устарели');
```

### Запись необработанных исключений

```dart
// Запись с кастомными данными
try {
  await processPayment(amount: 100.0, currency: 'RUB');
} catch (e, stackTrace) {
  await FirebaseCrashlytics.instance.recordError(
    e,
    stackTrace,
    reason: 'Payment processing failed',
    labels: {
      'payment_method': 'card',
      'amount': '100.0',
      'currency': 'RUB',
    },
    keys: {
      'user_id': 'user_123',
      'order_id': 'order_456',
    },
  );
}
```

## Симуляция крашей для тестирования

```dart
// Включить симуляцию в режиме отладки
void setupCrashlyticsTesting() {
  if (kDebugMode) {
    // Для Android
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Для iOS
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }
}

// Кнопка для тестирования
ElevatedButton(
  onPressed: () async {
    await FirebaseCrashlytics.instance.crash();
  },
  child: const Text('Test Crash'),
)
```

## Отслеживание пользовательских событий

### Пользовательские идентификаторы

```dart
// Установка пользовательского ID
FirebaseCrashlytics.instance.setUserId('user_12345');

// Очистка ID
FirebaseCrashlytics.instance.setUserId(null);

// В сервисе авторизации
class AuthService {
  Future<void> login(String userId) async {
    // ... логика авторизации ...
    FirebaseCrashlytics.instance.setUserId(userId);
  }

  Future<void> logout() async {
    FirebaseCrashlytics.instance.setUserId(null);
  }
}
```

### Пользовательские атрибуты

```dart
// Установка атрибутов
FirebaseCrashlytics.instance.setCustomKey('plan', 'premium');
FirebaseCrashlytics.instance.setCustomKey('subscription_expires', '2025-12-31');
FirebaseCrashlytics.instance.setCustomKey('device_model', 'iPhone 14');
FirebaseCrashlytics.instance.setCustomKey('app_version', '1.2.3');

// Удаление атрибутов
FirebaseCrashlytics.instance.deleteCustomKey('plan');
FirebaseCrashlytics.instance.deleteAllCustomKeys();
```

### Пользовательские трассировки (Custom Traces)

```dart
Future<void> uploadImages(List<String> imagePaths) async {
  final trace = FirebaseCrashlytics.instance.trace('upload_images');
  trace.putLabel('image_count', imagePaths.length.toString());
  trace.putLabel('total_size', '${imagePaths.length * 2}MB');

  try {
    for (int i = 0; i < imagePaths.length; i++) {
      trace.putLabel('uploading', 'image_${i + 1}/${imagePaths.length}');
      await uploadSingleImage(imagePaths[i]);
    }
    trace.putLabel('status', 'success');
  } catch (e) {
    trace.putLabel('status', 'failed');
    trace.putLabel('failed_image', e.toString());
    rethrow;
  } finally {
    await trace.start();
    // ... код ...
    await trace.stop();
  }
}
```

## Работа с Flutter ошибками

### Запись Flutter ошибок

```dart
// Запись ошибок из Future
Future<void> loadData() async {
  try {
    await _repository.fetchData();
  } catch (error, stack) {
    // Запись ошибки в Crashlytics
    await FirebaseCrashlytics.instance.recordError(error, stack);

    // Показ пользователю
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка загрузки данных')),
    );
  }
}

// Запись ошибок из Stream
Stream<void> streamData() async* {
  try {
    yield* _repository.streamData().handleError((error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack);
    });
  } catch (e) {
    FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
  }
}
```

### Обработка ошибок в isolate

```dart
@pragma('vm:entry-point')
void isolateMain(String data) {
  final receivePort = ReceivePort();

  Isolate.spawn(_isolateWorker, receivePort.sendPort);

  receivePort.listen((message) {
    if (message is SendPort) {
      // Отправка обратно в main isolate
    }
  });
}

void _isolateWorker(SendPort sendPort) {
  try {
    // Тяжёлые вычисления
    final result = heavyComputation();
    sendPort.send(result);
  } catch (e, stack) {
    // Ошибки в isolate не попадают в Crashlytics автоматически
    // Нужно использовать FirebaseCrashlytics из main isolate
    // или передать ошибку через SendPort
  }
}
```

## Аналитика в Crashlytics

### Группировка крашей

Crashlytics автоматически группирует краши по:
- Типу исключения
- Stacktrace
- Устройству и ОС
- Версии приложения

### Важные метрики

| Метрика | Описание |
|---------|----------|
| Affected users | Процент пользователей, затронутых крашем |
| Crash-free rate | Процент пользователей без крашей |
| Sessions | Количество сессий с крашем |
| Events | Количество событий перед крашем |

### Настройка уведомлений

```
Настройка в Firebase Console:
1. Перейти в Crashlytics
2. Выбрать приложение
3. Настройки → Уведомления
4. Выбрать события:
   □ Новые краши
   □ Возвратившиеся краши
   □ Изменение crash-free rate
5. Каналы уведомлений:
   □ Email
   □ Slack
   □ PagerDuty
```

## Best Practices

- **Записывайте все ожидаемые исключения** — не только фатальные
- **Используйте setUserId** для привязки крашей к пользователям
- **Добавляйте кастомные ключи** для контекста ошибки
- **Тестируйте Crashlytics** с симуляцией крашей
- **Мониторьте crash-free rate** после каждого релиза
- **Используйте трассировки** для сложных операций
- **Не записывайте персональные данные** в логи ошибок
