# Multiplatform development — единая кодовая база

Multiplatform development в Flutter позволяет создавать приложения для нескольких платформ с минимальными изменениями кода. Эффективная стратегия разделения кода между платформами — ключ к успешной multiplatform-разработке.

## Стратегии multiplatform development

### Уровни общего кода

```
┌─────────────────────────────────────────────────┐
│              Shared Code (90%)                   │
│  • Business Logic (use cases)                   │
│  • Data Layer (repositories, models)            │
│  • Core UI Components                           │
│  • State Management                             │
├─────────────────────────────────────────────────┤
│          Platform-Specific Layer (5-10%)         │
│  • Platform UI (navigation, dialogs)            │
│  • Platform APIs (camera, location)             │
│  • Platform Settings                            │
├─────────────────────────────────────────────────┤
│              Native Code (0-5%)                  │
│  • Native Plugins (Platform Channels)           │
│  • Platform Integration                         │
└─────────────────────────────────────────────────┘
```

### Коэффициент повторного использования

| Стратегия | Общий код | Особенности |
|-----------|-----------|-------------|
| Единый UI | 95-100% | Один UI для всех платформ |
| Общий UI + нативные элементы | 80-90% | Нативные навигация/диалоги |
| Общий код + кастомный UI | 60-80% | Разные UI для разных платформ |
| Минимальный общий код | 30-50% | Только бизнес-логика общая |

## Shared code patterns

### Архитектура с разделением слоёв

```
my_app/
├── lib/
│   ├── core/                 # Общий код
│   │   ├── constants/        # Константы
│   │   ├── errors/           # Обработка ошибок
│   │   ├── utils/            # Утилиты
│   │   └── theme/            # Общая тема
│   ├── features/             # Фичи
│   │   ├── auth/
│   │   ├── home/
│   │   └── settings/
│   ├── data/                 # Data layer
│   │   ├── models/
│   │   ├── repositories/
│   │   └── datasources/
│   ├── presentation/         # Presentation layer
│   │   ├── providers/
│   │   └── widgets/
│   └── main.dart
├── android/
├── ios/
├── web/
└── linux/
```

### Platform abstraction

```dart
// core/platform/platform_interface.dart
import 'package:flutter/foundation.dart';

/// Абстракция для платформенных операций
abstract class PlatformService {
  static PlatformService? _instance;

  static PlatformService get instance {
    _instance ??= _PlatformService();
    return _instance!;
  }

  /// Получение имени платформы
  String get platformName;

  /// Получение версии ОС
  Future<String> getOsVersion();

  /// Проверка подключения к интернету
  Future<bool> isConnected();

  /// Получение локали
  Locale getLocale();

  /// Открыть URL
  Future<bool> openUrl(String url);
}

/// Реализация по умолчанию (для Web и Desktop)
class _PlatformService implements PlatformService {
  @override
  String get platformName => kIsWeb ? 'Web' : defaultTargetPlatform.name;

  @override
  Future<String> getOsVersion() async {
    if (kIsWeb) return 'Web';
    // Для Desktop можно использовать Platform Channel
    return 'N/A';
  }

  @override
  Future<bool> isConnected() async {
    // Web: navigator.onLine
    // Mobile: connectivity_plus
    return true;
  }

  @override
  Locale getLocale() => PlatformDispatcher.instance.locale;

  @override
  Future<bool> openUrl(String url) async {
    if (kIsWeb) {
      // Web: открыть в новой вкладке
      return true;
    }
    return false;
  }
}
```

### Platform-specific implementations

```dart
// core/platform/platform_web.dart
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class WebPlatformService implements PlatformService {
  @override
  String get platformName => 'Web';

  @override
  Future<String> getOsVersion() async {
    return 'Web';
  }

  @override
  Future<bool> isConnected() async {
    return web.window.navigator.onLine;
  }

  @override
  Locale getLocale() => PlatformDispatcher.instance.locale;

  @override
  Future<bool> openUrl(String url) async {
    web.window.open(url, '_blank');
    return true;
  }
}

// core/platform/platform_mobile.dart
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MobilePlatformService implements PlatformService {
  @override
  String get platformName => defaultTargetPlatform.name;

  @override
  Future<String> getOsVersion() async {
    // Через Platform Channel
    return 'N/A';
  }

  @override
  Future<bool> isConnected() async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);
  }

  @override
  Locale getLocale() => PlatformDispatcher.instance.locale;

  @override
  Future<bool> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
```

### Factory pattern для платформенного кода

```dart
// core/platform/platform_factory.dart
import 'package:flutter/foundation.dart';

enum PlatformType { android, ios, web, windows, macos, linux }

class PlatformFactory {
  static PlatformType get currentPlatform {
    if (kIsWeb) return PlatformType.web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PlatformType.android;
      case TargetPlatform.iOS:
        return PlatformType.ios;
      case TargetPlatform.windows:
        return PlatformType.windows;
      case TargetPlatform.macOS:
        return PlatformType.macos;
      case TargetPlatform.linux:
        return PlatformType.linux;
      default:
        return PlatformType.web;
    }
  }

  static bool get isMobile =>
      currentPlatform == PlatformType.android ||
      currentPlatform == PlatformType.ios;

  static bool get isDesktop =>
      currentPlatform == PlatformType.windows ||
      currentPlatform == PlatformType.macos ||
      currentPlatform == PlatformType.linux;

  static bool get isWeb => currentPlatform == PlatformType.web;
}
```

## Platform-specific code

### Conditional imports

```dart
// Использование conditional imports для платформенного кода

// main_platform.dart
export 'src/platform_web.dart' if (dart.library.io) 'src/platform_mobile.dart';

// Использование:
import 'main_platform.dart';

class MyService {
  final PlatformService _platform = PlatformService.instance;

  String getPlatformInfo() {
    return 'Platform: ${_platform.platformName}';
  }
}
```

### Platform-specific assets

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    # Platform-specific assets
    - assets/images/platform/
      - if: web
        path: assets/images/web/
      - if: mobile
        path: assets/images/mobile/
      - if: desktop
        path: assets/images/desktop/
```

### Platform-specific widgets

```dart
// presentation/widgets/platform_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class PlatformNavigation extends StatelessWidget {
  final Widget home;
  final List<Widget> routes;

  const PlatformNavigation({
    super.key,
    required this.home,
    required this.routes,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformFactory.isMobile) {
      return _MobileNavigation(home: home, routes: routes);
    } else if (PlatformFactory.isDesktop) {
      return _DesktopNavigation(home: home, routes: routes);
    } else {
      return _WebNavigation(home: home, routes: routes);
    }
  }
}

class _MobileNavigation extends StatelessWidget {
  final Widget home;
  final List<Widget> routes;

  const _MobileNavigation({required this.home, required this.routes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: home,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _DesktopNavigation extends StatelessWidget {
  final Widget home;
  final List<Widget> routes;

  const _DesktopNavigation({required this.home, required this.routes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          Expanded(child: home),
        ],
      ),
    );
  }
}

class _WebNavigation extends StatelessWidget {
  final Widget home;
  final List<Widget> routes;

  const _WebNavigation({required this.home, required this.routes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(title: const Text('My App')),
          Expanded(child: home),
        ],
      ),
    );
  }
}
```

## State management across platforms

### Единое состояние для всех платформ

```dart
// features/auth/auth_repository.dart
abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<void> signUp(String email, String password);
}

// features/auth/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final HttpDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await _dataSource.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _dataSource.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  @override
  Future<void> signOut() async {
    await _dataSource.post('/auth/logout');
  }

  @override
  Future<void> signUp(String email, String password) async {
    await _dataSource.post('/auth/register', data: {
      'email': email,
      'password': password,
    });
  }
}
```

### Platform-specific data sources

```dart
// data/datasources/storage/local_storage.dart
abstract class LocalStorage {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

// data/datasources/storage/local_storage_web.dart
class LocalStorageWeb implements LocalStorage {
  @override
  Future<void> setString(String key, String value) async {
    web.window.localStorage.setItem(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return web.window.localStorage.getItem(key);
  }

  @override
  Future<void> remove(String key) async {
    web.window.localStorage.removeItem(key);
  }

  @override
  Future<void> clear() async {
    web.window.localStorage.clear();
  }
}

// data/datasources/storage/local_storage_mobile.dart
class LocalStorageMobile implements LocalStorage {
  final SharedPreferences _prefs;

  LocalStorageMobile(this._prefs);

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}
```

## Best Practices

1. **Извлекайте бизнес-логику** — держите её полностью независимой от платформы:
   ```dart
   // core/usecases/ — полностью общий код
   class GetUsersUseCase {
     final UserRepository _repo;
     GetUsersUseCase(this._repo);
     Future<List<User>> call() => _repo.getUsers();
   }
   ```

2. **Используйте Dependency Injection** — для подстановки платформенных реализаций:
   ```dart
   final storage = PlatformFactory.isWeb
       ? LocalStorageWeb()
       : LocalStorageMobile(SharedPreferences.getInstance());
   ```

3. **Абстрагируйте платформенные API** — через интерфейсы:
   ```dart
   abstract class CameraService {
     Future<List<XFile>> getImages();
     Future<XFile?> captureImage();
   }
   ```

4. **Тестируйте общий код** — unit-тесты для бизнес-логики:
   ```dart
   void main() {
     test('AuthRepository signs in correctly', () async {
       // Тестирование без платформы
     });
   }
   ```

5. **Избегайте `kIsWeb` в бизнес-логике** — используйте абстракции:
   ```dart
   // Плохо
   if (kIsWeb) { /* ... */ }

   // Хорошо
   final storage = await StorageService.getInstance();
   ```

6. **Используйте `conditional imports`** — для платформенных реализаций.

7. **Единая тема** — настройте общую тему с платформенными вариациями:
   ```dart
   ThemeData getPlatformTheme() {
     if (PlatformFactory.isDesktop) {
       return desktopTheme;
     }
     return mobileTheme;
   }
   ```

8. **Платформенные гайдлайны** — следуйте HIG каждой платформы:
   ```dart
   // iOS: Material Design с адаптацией под iOS
   // Android: Material Design 3
   // Web: Material Web
   // Desktop: Fluent (Windows), HIG (macOS)
   ```

9. **CI/CD для всех платформ** — автоматическая сборка и тестирование:
   ```yaml
   # .github/workflows/build.yml
   jobs:
     build:
       strategy:
         matrix:
           platform: [android, ios, web, windows, macos, linux]
   ```

10. **Документируйте платформенные различия** — для команды разработчиков.
