# Analytics — сбор метрик использования

## Введение

Analytics — сбор и анализ данных об использовании приложения. Позволяет понимать поведение пользователей, принимать решения на основе данных и улучшать продукт.

## Firebase Analytics

### Установка

**Файл: `pubspec.yaml`**

```yaml
dependencies:
  firebase_analytics: ^10.8.0
```

### Инициализация

**Файл: `lib/main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
final FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Включение сбора данных (для iOS 14+)
  await analytics.setAnalyticsCollectionEnabled(true);

  runApp(const MyApp());
}
```

### Настройка навигации

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.blue),
      navigatorKey: navigatorKey,
      navigatorObservers: [observer],
      home: const HomePage(),
    );
  }
}
```

## Отправка событий

### Стандартные события

```dart
// Просмотр экрана
await analytics.logViewSearchResults(
  searchTerm: 'flutter tutorial',
);

// Просмотр контента
await analytics.logViewItemList(
  itemListId: 'search_results',
  itemListName: 'Результаты поиска',
  items: [
    AnalyticsEventItem(
      itemId: 'item_001',
      itemName: 'Flutter Basics',
      itemCategory: 'course',
      price: 990.0,
    ),
    AnalyticsEventItem(
      itemId: 'item_002',
      itemName: 'Advanced Flutter',
      itemCategory: 'course',
      price: 1990.0,
    ),
  ],
);

// Выбор контента
await analytics.logSelectItem(
  itemListId: 'search_results',
  itemListName: 'Результаты поиска',
  items: [
    AnalyticsEventItem(
      itemId: 'item_001',
      itemName: 'Flutter Basics',
    ),
  ],
);

// Просмотр контента
await analytics.logViewItem(
  itemId: 'item_001',
  itemName: 'Flutter Basics',
  itemCategory: 'course',
  price: 990.0,
  currency: 'RUB',
);
```

### Пользовательские события

```dart
// Простое событие
await analytics.logEvent(name: 'button_pressed');

// Событие с параметрами
await analytics.logEvent(
  name: 'checkout_started',
  parameters: {
    'items_count': 3,
    'total_amount': 2970.0,
    'currency': 'RUB',
    'payment_method': 'card',
  },
);

// Событие с items
await analytics.logEvent(
  name: 'purchase',
  parameters: {
    'transaction_id': 'txn_123456',
    'value': 2970.0,
    'currency': 'RUB',
    'items': [
      {
        'item_id': 'item_001',
        'item_name': 'Flutter Basics',
        'item_category': 'course',
        'price': 990.0,
        'quantity': 1,
      },
      {
        'item_id': 'item_002',
        'item_name': 'Advanced Flutter',
        'item_category': 'course',
        'price': 1980.0,
        'quantity': 1,
      },
    ],
  },
);
```

### Создание класса для аналитики

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Экраны
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // Пользователь
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  // Поиск
  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  // E-commerce
  Future<void> logAddToCart(
    String itemId,
    String itemName,
    double price, {
    String currency = 'RUB',
    int quantity = 1,
  }) async {
    await _analytics.logAddToCart(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          price: price,
          currency: currency,
          quantity: quantity,
        ),
      ],
    );
  }

  Future<void> logRemoveFromCart(
    String itemId,
    String itemName,
    double price, {
    String currency = 'RUB',
  }) async {
    await _analytics.logRemoveFromCart(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          price: price,
          currency: currency,
        ),
      ],
    );
  }

  // Настройки
  Future<void> logSetUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> logSetUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // Кастомные события
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}

// Использование
final analytics = AnalyticsService();

// В кнопке
ElevatedButton(
  onPressed: () async {
    await analytics.logEvent('share_button_pressed', parameters: {
      'share_method': 'telegram',
      'content_type': 'article',
    });
    // логика шаринга
  },
  child: const Text('Поделиться'),
)
```

## Пользовательские свойства

### Свойства пользователя

```dart
// Установка свойств пользователя
await FirebaseAnalytics.instance.setUserProperty(
  name: 'user_type',
  value: 'premium',
);

await FirebaseAnalytics.instance.setUserProperty(
  name: 'registration_source',
  value: 'google_ads',
);

await FirebaseAnalytics.instance.setUserProperty(
  name: 'subscription_level',
  value: 'gold',
);
```

### Свойства приложения

```dart
// Настройка параметров приложения
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

// Отключение сбора для конкретного пользователя
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);

// Настройка длительности сессии (в секундах)
await FirebaseAnalytics.instance.setSessionTimeoutDuration(
  const Duration(minutes: 30),
);

// A/B тестирование
await FirebaseAnalytics.instance.setCurrentScreen(
  screenName: 'home_screen',
);
```

## Пользовательские параметры

```dart
// Установка параметров аналитики
await FirebaseAnalytics.instance.setCurrentScreen(screenName: 'settings');

// Кастомные параметры для отчётов
await FirebaseAnalytics.instance.setDefaultEventParameters({
  'app_version': '1.2.3',
  'platform': 'android',
  'device_type': 'mobile',
});

// Очистка параметров
await FirebaseAnalytics.instance.setDefaultEventParameters(null);
```

## Отслеживание производительности

### Замер времени выполнения

```dart
class PerformanceTracker {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<T> measure<T>(String eventName, Future<T> Function() action) async {
    final startTime = DateTime.now();
    try {
      final result = await action();
      final duration = DateTime.now().difference(startTime);

      await _analytics.logEvent(
        name: eventName,
        parameters: {
          'duration_ms': duration.inMilliseconds,
          'status': 'success',
        },
      );

      return result;
    } catch (e) {
      final duration = DateTime.now().difference(startTime);

      await _analytics.logEvent(
        name: eventName,
        parameters: {
          'duration_ms': duration.inMilliseconds,
          'status': 'error',
          'error': e.toString(),
        },
      );

      rethrow;
    }
  }
}

// Использование
final tracker = PerformanceTracker();

// Замер загрузки данных
final data = await tracker.measure(
  'api_data_load',
  () => repository.fetchData(),
);

// Замер сохранения
await tracker.measure(
  'data_save',
  () => repository.saveData(data),
);
```

### Отслеживание HTTP запросов

```dart
class AnalyticsInterceptor extends Interceptor {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.context = RequestOptionsContext(
      startTime: DateTime.now(),
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final context = options.context as RequestOptionsContext;
    final duration = DateTime.now().difference(context.startTime);

    _analytics.logEvent(
      name: 'http_request',
      parameters: {
        'endpoint': options.path,
        'method': options.method,
        'status_code': response.statusCode,
        'duration_ms': duration.inMilliseconds,
        'success': response.statusCode! < 400,
      },
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final context = options.context as RequestOptionsContext;
    final duration = DateTime.now().difference(context.startTime);

    _analytics.logEvent(
      name: 'http_request_error',
      parameters: {
        'endpoint': options.path,
        'method': options.method,
        'error_type': err.type.toString(),
        'duration_ms': duration.inMilliseconds,
      },
    );

    handler.next(err);
  }
}
```

## Конверсии и цели

### Настройка целей

```dart
// Отслеживание конверсий
class ConversionTracker {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logConversion(String eventName, {Map<String, dynamic>? params}) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: params,
    );

    // Отправка в Google Ads (если подключено)
    // await _analytics.setConsent(adStorage: true);
  }

  Future<void> logSignUp() async {
    await logConversion('sign_up', parameters: {
      'method': 'email',
    });
  }

  Future<void> logPurchase(double value, String currency) async {
    await logConversion('purchase', parameters: {
      'value': value,
      'currency': currency,
    });
  }

  Future<void> logSubscription(String plan) async {
    await logConversion('subscribe', parameters: {
      'plan': plan,
    });
  }
}
```

## Best Practices

- **Используйте осмысленные имена событий** — `purchase_completed`, а не `event_1`
- **Не передавайте персональные данные** через параметры событий
- **Ограничьте количество кастомных параметров** — не более 25 на событие
- **Тестируйте события** через DebugView в Firebase Console
- **Следите за лимитами** — 500 различных типов событий на проект
- **Используйте стандартные события** где это возможно
- **Анализируйте данные регулярно** для принятия решений
