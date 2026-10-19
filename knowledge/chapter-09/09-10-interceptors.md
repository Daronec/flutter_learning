# Interceptors и перехват запросов в Dio

Interceptors (интерсепторы) — это механизм перехвата HTTP-запросов и ответов на глобальном уровне. Они позволяют модифицировать запросы, ответы и ошибки до того, как они достигнут кода приложения.

## Что такое Interceptors?

Interceptors — это плагин-подобный механизм, который позволяет выполнять код:
- **До отправки запроса** — добавить заголовки, логирование
- **После получения ответа** — парсинг, трансформация данных
- **При возникновении ошибки** — обработка, retry-логика

## Базовый Interceptor

### Создание интерсептора

```dart
import 'package:dio/dio.dart';

// Простой интерсептор логирования
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('>>> ${options.method} ${options.uri}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Body: ${options.data}');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('<<< ${response.statusCode} ${response.requestOptions.uri}');
    print('Data: ${response.data}');
    return handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    print('!!! ERROR: ${error.type}');
    print('URL: ${error.requestOptions.uri}');
    print('Message: ${error.message}');
    if (error.response != null) {
      print('Response: ${error.response?.data}');
    }
    return handler.next(error);
  }
}

// Подключение
final dio = Dio();
dio.interceptors.add(LoggingInterceptor());
```

## Интерсептор авторизации

### Добавление токена

```dart
class AuthInterceptor extends Interceptor {
  final String Function() getToken;

  AuthInterceptor(this.getToken);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}

// Использование с сохранением токена
class TokenStorage {
  String? _token;

  void setToken(String token) => _token = token;
  String? getToken() => _token;
}

final tokenStorage = TokenStorage();
dio.interceptors.add(AuthInterceptor(tokenStorage.getToken));
```

### Обновление токена при 401

```dart
class RefreshTokenInterceptor extends Interceptor {
  final Dio dio;
  final String Function() getToken;
  final Future<String> Function() refreshToken;
  bool _isRefreshing = false;
  final List<RequestOptions> _failedRequests = [];

  RefreshTokenInterceptor({
    required this.dio,
    required this.getToken,
    required this.refreshToken,
  });

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    // Если 401 — пытаемся обновить токен
    if (error.response?.statusCode == 401 && !CancelToken.isCancel(error)) {
      _failedRequests.add(error.requestOptions);

      if (!_isRefreshing) {
        _isRefreshing = true;
        _refreshAndRetry().then((_) {
          _isRefreshing = false;
          // Повторяем все отложенные запросы
          for (final options in _failedRequests) {
            dio.request(options.path, options: options).then((response) {
              handler.resolve(response);
            }).catchError((e) {
              handler.reject(e as DioException, true);
            });
          }
          _failedRequests.clear();
        }).catchError((_) {
          _isRefreshing = false;
          _failedRequests.clear();
          handler.next(error);
        });
        return; // Ждём обновления токена
      } else {
        // Уже идёт обновление — откладываем запрос
        return;
      }
    }

    return handler.next(error);
  }

  Future<void> _refreshAndRetry() async {
    try {
      final newToken = await refreshToken();
      // Обновляем заголовок для отложенных запросов
      for (final options in _failedRequests) {
        options.headers['Authorization'] = 'Bearer $newToken';
      }
    } catch (e) {
      // Обновление не удалось — перенаправляем на вход
      print('Токен не удалось обновить');
    }
  }
}
```

## Интерсептор кэширования

### Кэширование GET-запросов

```dart
class CacheInterceptor extends Interceptor {
  final Map<String, CacheEntry> _cache = {};
  final Duration ttl;

  CacheInterceptor({this.ttl = const Duration(minutes: 5)});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Кэшируем только GET-запросы
    if (options.method != 'GET') {
      return handler.next(options);
    }

    final now = DateTime.now();
    final cached = _cache[options.uri.toString()];

    if (cached != null && now.difference(cached.timestamp) < ttl) {
      // Кэш актуален — возвращаем кэшированные данные
      final response = Response(
        requestOptions: options,
        data: cached.data,
        statusCode: 200,
      );
      return handler.resolve(response);
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Сохраняем ответ в кэш
    final options = response.requestOptions;
    if (options.method == 'GET') {
      _cache[options.uri.toString()] = CacheEntry(
        data: response.data,
        timestamp: DateTime.now(),
      );
    }
    return handler.next(response);
  }

  void clearCache() => _cache.clear();
}

class CacheEntry {
  final dynamic data;
  final DateTime timestamp;

  CacheEntry({required this.data, required this.timestamp});
}
```

## Интерсептор трансформации данных

### Преобразование структуры ответа

```dart
class ApiResponseTransformer extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Преобразуем стандартный формат ответа API
    if (response.data is Map) {
      final Map<String, dynamic> data = response.data;

      if (data.containsKey('data')) {
        // Извлекаем данные из обёртки API
        response.data = data['data'];
      }

      if (data.containsKey('meta')) {
        // Сохраняем метаданные отдельно
        response.headers.add(
          Headers.linkHeader,
          data['meta'].toString(),
        );
      }
    }

    return handler.next(response);
  }
}

// Пример преобразования
// Входной JSON: {"data": {...}, "meta": {"page": 1}}
// После интерсептора: response.data = {...}
```

### Преобразование ключей (snake_case → camelCase)

```dart
class KeyTransformerInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    response.data = _transformKeys(response.data);
    return handler.next(response);
  }

  dynamic _transformKeys(dynamic data) {
    if (data is Map<String, dynamic>) {
      return {
        for (final entry in data.entries)
          _toCamelCase(entry.key): _transformKeys(entry.value),
      };
    } else if (data is List) {
      return data.map(_transformKeys).toList();
    }
    return data;
  }

  String _toCamelCase(String key) {
    final parts = key.split('_');
    if (parts.length == 1) return key;
    return parts[0] +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }
}

// "user_id" → "userId"
// "first_name" → "firstName"
```

## Интерсептор с условиями

### Conditional Interceptor

```dart
class ConditionalInterceptor extends Interceptor {
  final bool Function(RequestOptions) condition;
  final void Function(RequestOptions, RequestInterceptorHandler) onRequest;
  final void Function(Response, ResponseInterceptorHandler)? onResponse;
  final void Function(DioException, ErrorInterceptorHandler)? onError;

  ConditionalInterceptor({
    required this.condition,
    required this.onRequest,
    this.onResponse,
    this.onError,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (condition(options)) {
      onRequest(options, handler);
    } else {
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (onResponse != null && condition(response.requestOptions)) {
      onResponse!(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    if (onError != null && condition(error.requestOptions)) {
      onError!(error, handler);
    } else {
      handler.next(error);
    }
  }
}

// Использование
dio.interceptors.add(
  ConditionalInterceptor(
    condition: (options) => options.path!.startsWith('/api/v2'),
    onRequest: (options, handler) {
      options.headers['X-API-Version'] = '2';
      handler.next(options);
    },
  ),
);
```

## Порядок выполнения Interceptors

Interceptors выполняются в порядке добавления:

```
Request Flow:
Interceptor 1 (onRequest) → Interceptor 2 (onRequest) → ... → API Call

Response Flow:
API Call → Interceptor N (onResponse) → ... → Interceptor 2 (onResponse) → Interceptor 1 (onResponse)

Error Flow:
API Error → Interceptor N (onError) → ... → Interceptor 2 (onError) → Interceptor 1 (onError)
```

```dart
// Порядок выполнения
dio.interceptors.add(InterceptorA()); // Шаг 1 → Шаг N
dio.interceptors.add(InterceptorB()); // Шаг 2 → Шаг N-1
dio.interceptors.add(InterceptorC()); // Шаг 3 → Шаг N-2

// Request: A → B → C → API
// Response: API → C → B → A
// Error: API → C → B → A
```

## Best Practices

- **Делайте интерсепторы маленькими** — каждый интерсептор делает одну вещь
- **Всегда вызывайте `handler.next()`** — иначе запрос не будет выполнен
- **Используйте `handler.resolve()`** для кэширования — чтобы пропустить API
- **Используйте `handler.reject()`** для принудительного завершения
- **Не делайте интерсепторы зависимыми** от порядка — каждый должен быть автономным
- **Логгируйте только в debug** — не отправляйте логи в production
