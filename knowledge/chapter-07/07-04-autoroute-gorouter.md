# AutoRoute и go_router — декларативная маршрутизация

go_router и AutoRoute — это популярные библиотеки для декларативной маршрутизации в Flutter. Обе абстрагируют сложность Navigator 2.0, предоставляя удобный API.

## go_router: основы

### Установка

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
```

### Базовая конфигурация

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Экраны
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/details/42'),
              child: const Text('Перейти к деталям'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/settings'),
              child: const Text('Настройки'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final int productId;

  const DetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product #$productId')),
      body: Center(child: Text('Товар ID: $productId')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Настройки')),
    );
  }
}
```

### Конфигурация Router

```dart
final _navigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  // Начальный маршрут
  initialLocation: '/',

  // Ключ навигатора для доступа извне
  navigatorKey: _navigatorKey,

  // Маршруты
  routes: [
    // Главный маршрут
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        // Вложенный маршрут
        GoRoute(
          path: 'details/:productId',
          name: 'details',
          builder: (context, state) {
            final productId = int.parse(
              state.pathParameters['productId']!,
            );
            return DetailsScreen(productId: productId);
          },
        ),
      ],
    ),

    // Отдельный маршрут
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],

  // Обработка несуществующих маршрутов
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('404', style: TextStyle(fontSize: 48)),
          const Text('Страница не найдена'),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('На главную'),
          ),
        ],
      ),
    ),
  ),
);
```

### Подключение к приложению

```dart
void main() {
  runApp(
    MaterialApp.router(
      title: 'GoRouter Demo',
      routerConfig: router,
      // Важно для работы go_router
      debugShowCheckedModeBanner: false,
    ),
  );
}
```

## go_router: конфигурация

### Навигация через context

```dart
// Переход на маршрут (заменяет текущий)
context.go('/settings');

// Push нового маршрута в стек
context.push('/details/42');

// PushReplacement
context.pushReplacement('/settings');

// Навигация по имени
context.goNamed('home');
context.pushNamed('details', pathParameters: {'productId': '42'});

// Проверка текущего маршрута
print(context.currentLocation); // '/details/42'
print(context.currentRouteName); // 'details'

// Проверка параметров
final state = GoRouterState.of(context);
final productId = state.pathParameters['productId'];
final extra = state.extra as ProductModel?;
```

### Shell routes для вложенной навигации

```dart
GoRoute(
  path: '/',
  redirect: (context, state) {
    // Перенаправление если не авторизован
    if (!isAuthenticated && state.matchedLocation != '/login') {
      return '/login';
    }
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: 'home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: 'profile/:id',
          name: 'profile',
          builder: (context, state) {
            return ProfileScreen(
              userId: state.pathParameters['id']!,
            );
          },
        ),
      ],
    ),
  ],
),

// MainNavigation — общий виджет для shell
class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/profile/123');
        },
      ),
    );
  }
}
```

### Extra — передача дополнительных данных

```dart
// Push с extra данными
context.push(
  '/details/42',
  extra: ProductModel(id: 42, name: 'Laptop'),
);

// Получение extra на целевом экране
class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProductModel? product =
        GoRouterState.of(context).extra as ProductModel?;

    return Scaffold(
      appBar: AppBar(title: Text(product?.name ?? 'Unknown')),
      body: Center(child: Text('Цена: \$${product?.price ?? 0}')),
    );
  }
}
```

### Deep Links

```dart
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/product/:id',
      redirect: (context, state) {
        // Проверка deep link извне
        if (state.uri.queryParameters.containsKey('source')) {
          print('Deep link from: ${state.uri.queryParameters['source']}');
        }
        return null;
      },
      builder: (context, state) => ProductScreen(
        productId: state.pathParameters['id']!,
      ),
    ),
  ],
);
```

## AutoRoute: основы

### Установка

```yaml
# pubspec.yaml
dependencies:
  auto_route: ^8.0.0

dev_dependencies:
  auto_route_generator: ^8.0.0
  build_runner: ^2.4.0
```

### Определение маршрутов (annotations)

```dart
// routes.dart
import 'package:auto_route/auto_route.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        // Главный маршрут
        AutoRoute(
          page: home,
          path: '/',
          initial: true,
        ),
        // Детали продукта
        AutoRoute(
          page: productRoute,
          path: '/product/:productId',
        ),
        // Настройки
        AutoRoute(
          page: settingsRoute,
          path: '/settings',
        ),
        // 404
        AutoRoute(
          page: notFoundRoute,
          path: '/404',
        ),
      ];
}

// Генерация:
// flutter pub run build_runner build
```

### Использование сгенерированного роутера

```dart
void main() {
  runApp(
    MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      home: const MyHomePage(),
    ),
  );
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final router = AppRouter.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => router.pushProductRoute(productId: '42'),
              child: const Text('Детали'),
            ),
            ElevatedButton(
              onPressed: () => router.pushSettingsRoute(),
              child: const Text('Настройки'),
            ),
          ],
        ),
      ),
    );
  }
}

// Навигация в экранах
class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final router = AppRouter.of(context);
    final productId = router.currentConfiguration.pathParameters['productId'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Product #$productId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(child: Text('ID: $productId')),
    );
  }
}
```

## Сравнение go_router и AutoRoute

| Характеристика | go_router | AutoRoute |
|---|---|---|
| Автор | Flutter team | Community |
| Конфигурация | Код | Annotations |
| Deep links | Встроенная | Встроенная |
| Shell routes | Да | Да |
| Генерация кода | Нет | Да (build_runner) |
| Флаги | Да | Да |
| Анимации | Встроенные | Встроенные |
| Обслуживание | Активное | Активное |
| Размер | Меньше | Больше (генерация) |

## Best Practices

1. **Используйте go_router для новых проектов** — он поддерживается Flutter team и не требует генерации кода.
2. **Используйте ShellRoute** для вложенных навигаций с общим UI (BottomNavigationBar).
3. **Используйте `redirect`** для авторизации и перенаправлений.
4. **Используйте `errorBuilder`** для обработки 404 страниц.
5. **Используйте `extra`** для передачи дополнительных данных вместо аргументов.
6. **Избегайте глубокой вложенности** маршрутов — это усложняет отладку.
7. **Используйте именованные маршруты** для лучшей читаемости и тестирования.
8. **Для AutoRoute** — используйте `replaceInRouteName` для удобных имён страниц.
