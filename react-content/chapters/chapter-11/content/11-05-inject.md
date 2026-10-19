# Inject — DI-фреймворк для Dart

## Введение

Inject — это фреймворк для Dependency Injection в Dart, вдохновлённый Dagger (Android) и SwiftUI (iOS). Он использует аннотации и генерацию кода для автоматического создания кода DI.

## Установка

```yaml
dependencies:
  inject: ^1.3.0

dev_dependencies:
  inject_generator: ^1.3.0
  build_runner: ^2.4.0
```

## Основные концепции

Inject работает на основе трёх основных аннотаций:

| Аннотация | Назначение |
|-----------|-----------|
| `@Injectable` | Помечает класс как управляемый DI |
| `@Inject` | Помечает конструктор для внедрения |
| `@Module` | Определяет модуль с зависимостями |

## Базовое использование

### Объявление зависимостей

```dart
// services/api_service.dart
import 'package:inject/inject.dart';

@Injectable()
class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'https://api.example.com'});

  Future<Map<String, dynamic>> get(String path) async {
    // Реализация...
    return {};
  }
}
```

```dart
// services/auth_service.dart
import 'package:inject/inject.dart';

@Injectable()
class AuthService {
  final ApiService api;

  AuthService({required this.api});

  Future<String> login(String email, String password) async {
    final response = await api.get('/auth/login');
    return response['token'] as String;
  }
}
```

### Использование в ViewModel

```dart
// view_models/home_view_model.dart
import 'package:inject/inject.dart';

@Injectable()
class HomeViewModel {
  final AuthService authService;
  final ApiService apiService;

  HomeViewModel({
    required this.authService,
    required this.apiService,
  });

  Future<void> loadData() async {
    final token = await authService.login('user@example.com', 'password');
    // Использование token...
  }
}
```

## Генерация кода

После объявления классов запускаем генератор:

```bash
dart run build_runner build
```

Генератор создаёт файл `inject.injectable.dart`:

```dart
// inject.injectable.dart (сгенерированный код)
class Injector {
  static final Injector _instance = Injector._();
  static Injector get instance => _instance;
  Injector._();

  ApiService? _apiService;
  AuthService? _authService;
  HomeViewModel? _homeViewModel;

  ApiService get apiService {
    _apiService ??= ApiService();
    return _apiService!;
  }

  AuthService get authService {
    _authService ??= AuthService(api: apiService);
    return _authService!;
  }

  HomeViewModel get homeViewModel {
    _homeViewModel ??= HomeViewModel(
      authService: authService,
      apiService: apiService,
    );
    return _homeViewModel!;
  }
}
```

### Использование инжектора

```dart
void main() async {
  // Инициализация
  await Injector.instance.init();

  // Получение зависимости
  final viewModel = Injector.instance.homeViewModel;
  await viewModel.loadData();

  runApp(MyApp(viewModel: viewModel));
}
```

## Модули

Модули позволяют группировать связанные зависимости:

```dart
// modules/network_module.dart
import 'package:inject/inject.dart';

@Module()
class NetworkModule {
  @Inject()
  Dio createDio() {
    return Dio(BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 5),
    ));
  }

  @Inject()
  ApiService createApiService(Dio dio) {
    return ApiService(dio: dio);
  }
}
```

```dart
// modules/storage_module.dart
import 'package:inject/inject.dart';

@Module()
class StorageModule {
  @Inject()
  SharedPreferences createPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @Inject()
  StorageService createStorageService(SharedPreferences prefs) {
    return StorageService(prefs: prefs);
  }
}
```

## Провайдеры (Providers)

Провайдеры позволяют передавать зависимости извне:

```dart
@Injectable(provider: true)
class ConfigService {
  final String apiKey;
  final String environment;

  ConfigService({
    required this.apiKey,
    required this.environment,
  });
}

// Передача провайдера
final config = ConfigService(
  apiKey: 'my-api-key',
  environment: 'production',
);

Injector.instance.registerProvider(config);
```

## Scopes (Области видимости)

Inject поддерживает разные области видимости:

```dart
@Injectable(scope: 'request')
class RequestScopedService {
  // Создаётся и уничтожается в рамках области
}

@Injectable(scope: 'session')
class SessionScopedService {
  // Живёт в рамках сессии
}

// Управление областями
final scope = Injector.instance.createScope('request');
final service = scope.resolve<RequestScopedService>();
scope.dispose(); // Уничтожает все зависимости области
```

## Типы инъекций

| Тип | Аннотация | Описание |
|-----|-----------|----------|
| Constructor | `@Inject()` на конструкторе | Автоматическая инъекция полей |
| Field | `@Inject()` на поле | Инъекция в поле |
| Method | `@Inject()` на методе | Вызов метода с внедрёнными параметрами |

## Сравнение с другими DI-решениями

| Фреймворк | Подход | Генерация кода | Сложность |
|-----------|--------|----------------|-----------|
| Inject | Аннотации + генерация | Да | Средняя |
| GetIt | Service Locator | Нет | Низкая |
| flutter_di | Аннотации | Да | Средняя |
| Конструктор | Ручной DI | Нет | Низкая |

## Лучшие практики

1. **Используйте аннотации `@Injectable`** для всех сервисов
2. **Группируйте зависимости по модулям**
3. **Используйте провайдеры** для конфигурационных данных
4. **Применяйте scopes** для временных зависимостей
5. **Регулярно запускайте `build_runner`** при изменении аннотаций
6. **Предпочитайте constructor injection** для явности
