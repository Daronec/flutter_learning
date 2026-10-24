---
tags:
  - architecture
  - clean-architecture
  - repository
chapter: 11
section: 4
title: GetIt — Сервис-локация в Flutter
alias: 11 04 getit
status: complete
---

# GetIt — Сервис-локация в Flutter

## Введение

GetIt — это простой и эффективный пакет для реализации паттерна Service Locator в Dart/Flutter. Позволяет регистрировать и получать зависимости по типу без создания сложных DI-фреймворков.

## Установка

```yaml
dependencies:
  get_it: ^7.6.7
```

## Базовое использование

### Регистрация зависимостей

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setup() {
  // Singleton — один экземпляр на всё приложение
  getIt.registerSingleton<ApiService>(ApiService());

  // Lazy Singleton — создаётся при первом запросе
  getIt.registerLazySingleton<StorageService>(() => StorageService());

  // Factory — новый экземпляр при каждом запросе
  getIt.registerFactory<ProductViewModel>(() => ProductViewModel(
    api: getIt<ApiService>(),
    storage: getIt<StorageService>(),
  ));

  // Factory с параметрами
  getIt.registerFactoryParam<ChatViewModel, String, void>(
    (chatId, _) => ChatViewModel(chatId: chatId),
  );
}
```

### Получение зависимостей

```dart
// Получение singleton
final apiService = getIt<ApiService>();

// Получение factory
final viewModel = getIt<ProductViewModel>();

// Получение с параметрами
final chatViewModel = getIt<ChatViewModel>('chat-123');
```

## Типы регистрации

### Singleton

```dart
// Один экземпляр, создаётся сразу
getIt.registerSingleton<MyService>(MyService());

// Проверка
assert(getIt.isRegistered<MyService>());
assert(getIt.isSingleton<MyService>());
```

### Lazy Singleton

```dart
// Создаётся при первом запросе
getIt.registerLazySingleton<MyService>(() => MyService());

// Первый вызов создаёт экземпляр
final service1 = getIt<MyService>();
final service2 = getIt<MyService>();
assert(service1 == service2); // Один и тот же объект
```

### Factory

```dart
// Новый экземпляр каждый раз
getIt.registerFactory<MyService>(() => MyService());

final service1 = getIt<MyService>();
final service2 = getIt<MyService>();
assert(service1 != service2); // Разные объекты
```

### Singleton с фабрикой

```dart
// Singleton, но создаётся через фабрику
getIt.registerSingleton<MyService>(
  MyService.new, // или () => MyService()
);
```

## Пример полной настройки

```dart
// di/app_get_it.dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // SharedPreferences (нужна инициализация)
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // HTTP клиент
  getIt.registerLazySingleton<Dio>(() => Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  )));

  // Сервисы
  getIt.registerLazySingleton<AuthService>(() => AuthService(
    dio: getIt<Dio>(),
    prefs: getIt<SharedPreferences>(),
  ));

  getIt.registerLazySingleton<UserService>(() => UserService(
    dio: getIt<Dio>(),
    auth: getIt<AuthService>(),
  ));

  // View Models — factory
  getIt.registerFactory<HomeViewModel>(() => HomeViewModel(
    userService: getIt<UserService>(),
    authService: getIt<AuthService>(),
  ));

  getIt.registerFactory<SettingsViewModel>(() => SettingsViewModel(
    prefs: getIt<SharedPreferences>(),
  ));
}
```

## Использование с BLoC

```dart
// view_models/home_view_model.dart
class HomeViewModel extends ChangeNotifier {
  final UserService _userService;
  final AuthService _authService;

  HomeViewModel({
    required UserService userService,
    required AuthService authService,
  })  : _userService = userService,
        _authService = authService;

  // Или через GetIt
  factory HomeViewModel.fromGetIt() {
    return HomeViewModel(
      userService: getIt<UserService>(),
      authService: getIt<AuthService>(),
    );
  }

  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers();
    } catch (e) {
      // Обработка ошибки
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## Переопределение для тестов

```dart
// tests/home_view_model_test.dart
import 'package:get_it/get_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  late MockUserService mockUserService;

  setUp(() {
    mockUserService = MockUserService();
    when(mockUserService.getAllUsers()).thenAnswer((_) async => []);

    // Переопределяем регистрацию для тестов
    GetIt.instance.registerSingleton<UserService>(mockUserService);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  test('HomeViewModel loads users', () async {
    final viewModel = HomeViewModel(
      userService: mockUserService,
      authService: getIt<AuthService>(),
    );

    await viewModel.loadUsers();
    expect(viewModel.users, isEmpty);
    verify(mockUserService.getAllUsers()).called(1);
  });
}
```

## Сравнение типов регистрации

| Тип | Поведение | Когда использовать |
|-----|----------|-------------------|
| `registerSingleton` | Один экземпляр, создаётся сразу | Сервисы, клиенты |
| `registerLazySingleton` | Один экземпляр, ленивая инициализация | Тяжёлые объекты |
| `registerFactory` | Новый экземпляр каждый раз | ViewModels, Use Cases |
| `registerLazyFactory` | Новый экземпляр, ленивая инициализация | Редко используемые объекты |

## Лучшие практики

1. **Регистрируйте все зависимости в одном месте**
2. **Используйте `registerLazySingleton` для тяжёлых объектов**
3. **Используйте `registerFactory` для ViewModels**
4. **Переопределяйте зависимости в тестах через `registerSingleton`**
5. **Вызывайте `reset()` при завершении тестов**
6. **Не храните состояние в сервисах** — они синглтоны
