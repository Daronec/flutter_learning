---
tags:
  - navigation
  - routing
chapter: 7
section: 7
title: Глубокие ссылки (Deep Links) и Universal Links
alias: 07 07 deep links
status: complete
---

# Глубокие ссылки (Deep Links) и Universal Links

Deep Links позволяют открывать конкретные экраны приложения напрямую из внешних источников: веб-страниц, сообщений, уведомлений и других приложений.

## Что такое Deep Links

Deep Link — это URL, который ведёт не на главную страницу, а на конкретный контент внутри приложения.

### Типы Deep Links

| Тип | Описание | Платформа |
|---|---|---|
| HTTP/HTTPS | Обычные URL | Обе |
| Custom Scheme | `myapp://` | Обе |
| Android App Links | `https://` с верификацией | Android |
| iOS Universal Links | `https://` с верификацией | iOS |
| Firebase Dynamic Links | Временные ссылки (deprecated) | Обе |

## Конфигурация Deep Links

### Настройка go_router с Deep Links

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  // Начальный маршрут
  initialLocation: '/',

  // Deep link configuration
  debugLabel: 'myapp',

  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'product/:productId',
          name: 'product',
          builder: (context, state) {
            return ProductScreen(
              productId: state.pathParameters['productId']!,
              source: state.uri.queryParameters['source'],
            );
          },
        ),
        GoRoute(
          path: 'user/:userId',
          name: 'user',
          builder: (context, state) {
            return UserScreen(
              userId: state.pathParameters['userId']!,
            );
          },
        ),
      ],
    ),
  ],
);
```

### Обработка Deep Links в main

```dart
void main() {
  // Получаем начальный URI из Deep Link
  final initialUri = switch (defaultTargetPlatform) {
    TargetPlatform.iOS || TargetPlatform.macOS =>
      PlatformDispatcher.instance.views.first.platformDispatcher,
    _ => null,
  };

  // Передаём начальный URI в router
  runApp(
    MyApp(
      initialLocation: initialUri?.toString() ?? '/',
    ),
  );
}
```

### Обработка входящих Deep Links

```dart
class DeepLinkHandler {
  // Обработка URI из внешнего источника
  static Future<void> handleDeepLink(Uri uri) async {
    final path = uri.path;
    final queryParameters = uri.queryParameters;

    // Парсинг пути
    if (path.startsWith('/product/')) {
      final productId = path.split('/').last;
      // Навигация к товару
      await navigateToProduct(productId);
    } else if (path.startsWith('/user/')) {
      final userId = path.split('/').last;
      // Навигация к пользователю
      await navigateToUser(userId);
    } else if (path == '/settings') {
      // Навигация к настройкам
      await navigateToSettings();
    }

    // Обработка параметров
    if (queryParameters.containsKey('source')) {
      print('Источник: ${queryParameters['source']}');
    }
  }

  static Future<void> navigateToProduct(String productId) async {
    // Логика навигации
    print('Открыть товар: $productId');
  }

  static Future<void> navigateToUser(String userId) async {
    print('Открыть пользователя: $userId');
  }

  static Future<void> navigateToSettings() async {
    print('Открыть настройки');
  }
}
```

## Android: App Links

### Настройка AndroidManifest.xml

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
  <application>
    <activity
      android:name=".MainActivity"
      android:exported="true">

      <intent-filter android:autoVerify="true">
        <!-- Обработка HTTP/HTTPS -->
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />

        <!-- Домен -->
        <data
          android:scheme="https"
          android:host="myapp.com"
          android:pathPrefix="/product" />

        <data
          android:scheme="https"
          android:host="myapp.com"
          android:pathPrefix="/user" />
      </intent-filter>

      <!-- Custom Scheme -->
      <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />

        <data
          android:scheme="myapp"
          android:host="product" />
        <data
          android:scheme="myapp"
          android:host="user" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

### Настройка assetlinks.json (для Android App Links)

```json
// https://myapp.com/.well-known/assetlinks.json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.example.myapp",
      "sha256_cert_fingerprints": [
        "AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99"
      ]
    }
  }
]
```

## iOS: Universal Links

### Настройка App Search API (Associated Domains)

```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>

<!-- Для Universal Links -->
<key>NSUserActivityTypes</key>
<array>
  <string>NSUserActivityTypeBrowsingWeb</string>
</array>
```

### Настройка Associated Domains в Xcode

```
// Добавляем в Capabilities → Associated Domains:
webcredentials:myapp.com
applinks:myapp.com
```

### Настройка apple-app-site-association

```json
// https://myapp.com/apple-app-site-association
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.example.myapp",
        "paths": [
          "PRODUCT/*",
          "USER/*",
          "NOT [/]"
        ]
      }
    ]
  }
}
```

## Обработка Deep Links в приложении

### Обработка в Flutter

```dart
class DeepLinkManager extends StatefulWidget {
  final String initialLocation;

  const DeepLinkManager({super.key, required this.initialLocation});

  @override
  State<DeepLinkManager> createState() => _DeepLinkManagerState();
}

class _DeepLinkManagerState extends State<DeepLinkManager> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: widget.initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'product/:id',
              builder: (context, state) {
                return ProductScreen(
                  productId: state.pathParameters['id']!,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

// Запуск
void main() {
  // Получаем начальный URI
  final initialUri = WidgetsBinding.instance.platformDispatcher
      .views.first
      .platformDispatcher;

  runApp(const DeepLinkManager(initialLocation: '/'));
}
```

### Обработка через Platform Channel

```dart
// Обработка Deep Links через Platform Channel
class DeepLinkService {
  static const platform = MethodChannel('com.example/myapp/deeplink');

  static Future<Uri?> getInitialUri() async {
    try {
      final String? uriString =
          await platform.invokeMethod<String>('getInitialUri');
      return uriString != null ? Uri.parse(uriString) : null;
    } catch (e) {
      print('Error getting initial URI: $e');
      return null;
    }
  }

  static Stream<Uri> getOnNewUriStream() {
    const eventChannel = EventChannel('com.example/myapp/uri');
    return eventChannel
        .receiveBroadcastStream()
        .map((event) => Uri.parse(event as String));
  }
}

// Использование
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Получаем начальный URI
  final initialUri = await DeepLinkService.getInitialUri();
  final initialLocation = initialUri?.path ?? '/';

  // Слушаем новые URI
  DeepLinkService.getOnNewUriStream().listen((uri) {
    // Навигация при получении нового Deep Link
    final location = uri.path;
    // Обновляем router
  });

  runApp(MyApp(initialLocation: initialLocation));
}
```

## Dynamic Links (Firebase)

### Создание Dynamic Link

```dart
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

Future<void> createDynamicLink() async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://myapp.page.link',
    link: Uri.parse('https://myapp.com/product/123'),
    androidParameters: const AndroidParameters(
      packageName: 'com.example.myapp',
      minimumVersion: 0,
    ),
    iosParameters: const IOSParameters(
      bundleId: 'com.example.myapp',
      minimumVersion: '1.0.0',
    ),
    socialMetaTagParameters: SocialMetaTagParameters(
      title: 'Отличный товар',
      description: 'Посмотрите этот товар',
      imageUrl: Uri.parse('https://myapp.com/images/product.jpg'),
    ),
  );

  final DynamicLink dynamicLink =
      await parameters.buildShortLink();

  print('Dynamic Link: ${dynamicLink.shortUrl}');
}
```

### Обработка Dynamic Link

```dart
class DynamicLinkHandler {
  static Future<void> initialize() async {
    // Обработка начального Dynamic Link
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      await _handleDynamicLink(initialLink.link);
    }

    // Обработка Dynamic Link при открытии приложения
    FirebaseDynamicLinks.instance.onLink.listen(
      (pendingDynamicLink) async {
        if (pendingDynamicLink != null) {
          await _handleDynamicLink(pendingDynamicLink.link);
        }
      },
      onError: (e) => print('Error handling dynamic link: $e'),
    );
  }

  static Future<void> _handleDynamicLink(Uri link) async {
    final path = link.path;

    if (path.startsWith('/product/')) {
      final productId = path.split('/').last;
      // Навигация к товару
      print('Открыть товар: $productId');
    } else if (path.startsWith('/user/')) {
      final userId = path.split('/').last;
      print('Открыть пользователя: $userId');
    }
  }
}

// Вызов в main
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DynamicLinkHandler.initialize();
  runApp(const MyApp());
}
```

## Best Practices

1. **Обрабатывайте Deep Links до инициализации UI** — проверяйте начальный URI в `main()`.
2. **Используйте HTTPS** — это работает как на Android (App Links), так и на iOS (Universal Links).
3. **Верифицируйте домены** — для Android App Links и iOS Universal Links.
4. **Обеспечьте fallback** — если приложение не установлено, перенаправляйте на веб-версию.
5. **Добавляйте параметры отслеживания** — `source`, `campaign` для аналитики.
6. **Тестируйте на обоих платформах** — поведение может отличаться.
7. **Используйте go_router** — он име��т встроенную поддержку Deep Links.
8. **Обновляйте apple-app-site-association** — при изменении маршрутов.

## Сравнение подходов

| Подход | Сложность | Надёжность | Рекомендация |
|---|---|---|---|
| Custom Scheme | Низкая | Средняя | Простые приложения |
| HTTP/HTTPS | Средняя | Высокая | Production приложения |
| Firebase Dynamic Links | Средняя | Высокая | Маркетинговые кампании |
| go_router + HTTP | Низкая | Высокая | Flutter приложения |
