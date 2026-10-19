# Navigator 2.0: Router, RouteInformationParser, PageRouteBuilder

Navigator 2.0 — это декларативная система навигации, introduced в Flutter 2.0. В отличие от императивного Navigator 1.0, Navigator 2.0 позволяет синхронизировать навигацию с состоянием приложения и URL.

## Концепция декларативной навигации

### Императивный vs Декларативный подход

```
Императивный (Navigator 1.0):
  Navigator.push(context, route);  // «Сделай это»

Декларативный (Navigator 2.0):
  Router(
    routerConfig: config,
    child: app,
  );  // «Вот моё состояние, сам определи маршрут»
```

Navigator 2.0 основан на трёх ключевых компонентах:

1. **Router** — виджет, управляющий навигацией
2. **RouteInformationParser** — парсинг и генерация информации о маршруте
3. **RouteInformationReporter** — отчёт об изменениях маршрута

## Router виджет

### Базовое использование Router

```dart
import 'package:flutter/material.dart';
import 'package:flutter/router.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Router(
      routerConfig: AppRouter.config,
      child: const MyAppContent(),
    );
  }
}

class AppRouter {
  static final config = RouterConfig<String>(
    routeInformationParser: AppRouteInformationParser(),
    routeInformationProvider: _locationProvider,
    routeMatcher: const RouteMatcher(),
  );

  static final _locationProvider = ValueListenableProvider<String>(
    initialValue: '/',
  );
}
```

### Router с состоянием

```dart
class AppRouter {
  // Состояние навигации
  static final _navState = ValueNotifier<AppNavigationState>(
    const AppNavigationState(),
  );

  static final config = RouterConfig<String>(
    routeInformationParser: AppRouteInformationParser(),
    routeInformationProvider: _navState,
    navigatorBuilder: (context, child, navigator) {
      return Navigator(
        pages: [
          KeyedSubtree(
            key: ValueKey(navigator.currentRoute),
            child: child!,
          ),
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) return false;
          _navState.value = _navState.value.copyWith(
            pages: _navState.value.pages.skip(1).toList(),
          );
          return true;
        },
      );
    },
  );
}
```

## RouteInformationParser

### Базовый парсер

`RouteInformationParser` преобразует URL в состояние приложения и обратно:

```dart
class AppRouteInformationParser
    extends RouteInformationParser<String> {

  @override
  Future<String> parseRouteInformation(
    RouteInformation informedRoute,
  ) async {
    final uri = Uri.parse(informedRoute.location ?? '/');

    if (uri.path == '/') {
      return '/';
    } else if (uri.path.startsWith('/product/')) {
      final productId = uri.pathSegments.last;
      return '/product/$productId';
    } else if (uri.path == '/settings') {
      return '/settings';
    } else {
      return '/404';
    }
  }

  @override
  RouteInformation? restoreRouteInformation(String configuredRoute) {
    return RouteInformation(location: configuredRoute);
  }
}
```

### Типизированный парсер

```dart
enum AppRoute { home, product, settings, notFound }

class TypedRouteParser
    extends RouteInformationParser<AppRoute> {

  @override
  Future<AppRoute> parseRouteInformation(
    RouteInformation informedRoute,
  ) async {
    final uri = Uri.parse(informedRoute.location ?? '/');

    if (uri.path == '/') {
      return AppRoute.home;
    } else if (uri.path.startsWith('/product/')) {
      return AppRoute.product;
    } else if (uri.path == '/settings') {
      return AppRoute.settings;
    } else {
      return AppRoute.notFound;
    }
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoute route) {
    switch (route) {
      case AppRoute.home:
        return const RouteInformation(location: '/');
      case AppRoute.product:
        return const RouteInformation(location: '/product/1');
      case AppRoute.settings:
        return const RouteInformation(location: '/settings');
      case AppRoute.notFound:
        return const RouteInformation(location: '/404');
    }
  }
}
```

## RouteInformationReporter

`RouteInformationReporter` позволяет приложению сообщать об изменениях маршрута:

```dart
class AppRouter {
  static final _reporter = ValueNotifier<RouteInformation>(
    const RouteInformation(location: '/'),
  );

  static void navigateTo(String path) {
    _reporter.value = RouteInformation(location: path);
  }
}

// Использование
AppRouter.navigateTo('/product/42');
```

## Declarative Navigator с Page API

### Базовый пример с Page API

```dart
class NavigationState {
  final List<Page> pages;

  const NavigationState({required this.pages});

  NavigationState copyWith({List<Page>? pages}) {
    return NavigationState(pages: pages ?? this.pages);
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NavigationState _state = const NavigationState(pages: [
    HomePagePage(),
  ]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: RouterConfig(
        routeInformationParser: TypedRouteParser(),
        routeInformationProvider:
            ValueListenableProvider<NavigationState>(_state),
        navigatorBuilder: (context, child, navigator) {
          return Navigator(
            pages: _state.pages,
            onPopPage: (route, result) {
              if (!route.didPop(result)) return false;
              setState(() {
                _state = _state.copyWith(
                  pages: _state.pages.skip(1).toList(),
                );
              });
              return true;
            },
          );
        },
      ),
    );
  }
}

// Кастомная Page
class HomePagePage extends Page {
  const HomePagePage();

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      builder: (context) => const HomePage(),
    );
  }
}
```

### Page с аргументами

```dart
class ProductPage extends Page {
  final String productId;

  const ProductPage({required this.productId});

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      builder: (context) => ProductScreen(productId: productId),
      settings: RouteSettings(
        arguments: ProductModel.fromJson({
          'id': productId,
          'name': 'Product',
          'price': 99.99,
        }),
      ),
    );
  }
}

// Добавление страницы в стек
void navigateToProduct(String productId) {
  setState(() {
    _state = NavigationState(
      pages: [
        const HomePagePage(),
        ProductPage(productId: productId),
      ],
    );
  });
}
```

## Best Practices

1. **Используйте MaterialApp.router** — это самый простой способ подключить Router 2.0.
2. **Синхронизируйте состояние с URL** — каждый change навигации должен отражаться в URL.
3. **Используйте кастомные Page классы** для переиспользуемой логики маршрутов.
4. **Избегайте прямой манипуляции стека** — управляйте через состояние.
5. **Используйте go_router для production** — он абстрагирует сложность Navigator 2.0.
6. **Тестируйте парсер маршрутов** — убедитесь, что `parseRouteInformation` и `restoreRouteInformation` работают корректно.

## Когда использовать Navigator 2.0

| Сценарий | Подход |
|---|---|
| Простая навигация | Navigator 1.0 |
| Deep links | Navigator 2.0 / go_router |
| URL-синхронизация | Navigator 2.0 / go_router |
| Сложная маршрутизация | go_router (рекомендуется) |
| Гибкая кастомизация | Navigator 2.0 |

Navigator 2.0 даёт полный контроль, но требует значительных усилий. Для большинства проектов рекомендуется использовать **go_router**, который предоставляет декларативный API поверх Navigator 2.0.
