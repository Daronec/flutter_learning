---
tags:
  - api
  - http
  - networking
chapter: 9
section: 9
title: Обработка ошибок и retry-логика
alias: 09 09 error handling
status: complete
---

# Обработка ошибок и retry-логика

Надёжная обработка ошибок — критически важная часть сетевого взаимодействия. Пользователь должен получать понятные сообщения, а приложение — корректно восстанавливаться после сбоев.

## Типы сетевых ошибок

| Тип ошибки | Описание | Пример |
|------------|----------|--------|
| ConnectionError | Нет подключения к интернету | Wi-Fi выключен |
| TimeoutError | Запрос превысил время ожидания | Сервер не отвечает |
| BadRequest (400) | Неверный формат запроса | Пропущено обязательное поле |
| Unauthorized (401) | Нет авторизации | Истёк токен |
| Forbidden (403) | Нет прав доступа | Недостаточно прав |
| NotFound (404) | Ресурс не найден | ID не существует |
| ServerError (5xx) | Ошибка на сервере | Внутренняя ошибка |
| RateLimit (429) | Превышен лимит запросов | Слишком много запросов |

## Базовая обработка ошибок

### Обработка с try-catch

```dart
import 'package:dio/dio.dart';

Future<void> fetchUserData() async {
  try {
    final response = await dio.get('/users/1');
    print('Данные: ${response.data}');
  } on DioException catch (e) {
    // Сетевая ошибка
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        print('Сервер не отвечает. Проверьте соединение.');
        break;
      case DioExceptionType.connectionError:
        print('Нет подключения к интернету.');
        break;
      case DioExceptionType.badResponse:
        _handleHttpError(e.response!.statusCode!);
        break;
      case DioExceptionType.cancel:
        print('Запрос отменён');
        break;
      default:
        print('Неизвестная ошибка: ${e.message}');
    }
  } catch (e) {
    print('Неожиданная ошибка: $e');
  }
}

void _handleHttpError(int statusCode) {
  switch (statusCode) {
    case 400:
      print('Неверный запрос');
      break;
    case 401:
      print('Необходима авторизация');
      break;
    case 403:
      print('Доступ запрещён');
      break;
    case 404:
      print('Ресурс не найден');
      break;
    case 429:
      print('Слишком много запросов. Подождите.');
      break;
    case 500:
    case 502:
    case 503:
      print('Ошибка сервера. Попробуйте позже.');
      break;
    default:
      print('Ошибка: $statusCode');
  }
}
```

## User-friendly сообщения

### Карта сообщений об ошибках

```dart
class ErrorMessages {
  static String getMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Сервер не отвечает. Проверьте соединение.';
      case DioExceptionType.sendTimeout:
        return 'Превышено время отправки запроса.';
      case DioExceptionType.receiveTimeout:
        return 'Сервер не отвечает. Попробуйте позже.';
      case DioExceptionType.connectionError:
        return 'Нет подключения к интернету.';
      case DioExceptionType.badResponse:
        return _getHttpErrorMessage(error.response!.statusCode!);
      case DioExceptionType.cancel:
        return 'Запрос отменён.';
      case DioExceptionType.unknown:
        return 'Произошла неизвестная ошибка.';
    }
  }

  static String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Неверный формат запроса.';
      case 401:
        return 'Сессия истекла. Войдите снова.';
      case 403:
        return 'У вас нет доступа к этому ресурсу.';
      case 404:
        return 'Запрашиваемые данные не найдены.';
      case 422:
        return 'Данные не прошли валидацию.';
      case 429:
        return 'Слишком много запросов. Подождите.';
      case 500:
        return 'Внутренняя ошибка сервера.';
      case 502:
        return 'Сервер временно недоступен.';
      case 503:
        return 'Сервис временно недоступен.';
      default:
        return 'Произошла ошибка. Попробуйте позже.';
    }
  }
}
```

## Retry-логика

### Базовый retry

```dart
Future<T> retry<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  late Exception lastException;

  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await action();
    } on DioException catch (e) {
      lastException = e;

      // Не повторяем при клиентских ошибках (4xx)
      if (e.response?.statusCode != null && e.response!.statusCode! < 500) {
        rethrow;
      }

      if (attempt < maxAttempts) {
        await Future.delayed(initialDelay * attempt);
      }
    }
  }

  throw lastException!;
}

// Использование
final user = await retry<User>(
  () => dio.get('/users/1').then((r) => User.fromJson(r.data)),
  maxAttempts: 3,
);
```

### Exponential Backoff (экспоненциальная задержка)

```dart
Future<T> retryWithBackoff<T>(
  Future<T> Function() action, {
  int maxAttempts = 5,
  Duration baseDelay = const Duration(seconds: 1),
  Duration maxDelay = const Duration(minutes: 1),
  double multiplier = 2.0,
}) async {
  late Exception lastException;

  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await action();
    } on DioException catch (e) {
      lastException = e;

      // Не повторяем при клиентских ошибках
      if (e.response?.statusCode != null && e.response!.statusCode! < 500) {
        rethrow;
      }

      // Не повторяем при отмене
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }

      if (attempt < maxAttempts - 1) {
        // Экспоненциальная задержка: 1s, 2s, 4s, 8s, 16s
        final delay = Duration(
          milliseconds: (baseDelay.inMilliseconds *
                  pow(multiplier, attempt))
              .toInt()
              .clamp(0, maxDelay.inMilliseconds),
        );
        await Future.delayed(delay);
      }
    }
  }

  throw lastException!;
}

// Утилита для pow
double pow(double base, int exp) {
  return (1.0 ... base).fold(1.0, (acc, _) => acc * base);
}
```

### Retry через интерсептор Dio

```dart
class RetryInterceptor extends Interceptor {
  final int maxRetries;

  RetryInterceptor({this.maxRetries = 3});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    int attempts = 0;
    DioException? lastError;

    while (attempts < maxRetries) {
      try {
        final response = await super.dio.request(options.path, options: options);
        return handler.next(response);
      } on DioException catch (e) {
        lastError = e;

        // Не retry при клиентских ошибках
        if (e.response?.statusCode != null && e.response!.statusCode! < 500) {
          return handler.reject(e, true);
        }

        attempts++;
        if (attempts < maxRetries) {
          final delay = Duration(
            milliseconds: (1000 * pow(2, attempts - 1)).toInt(),
          );
          await Future.delayed(delay);
        }
      }
    }

    handler.reject(lastError!, true);
  }
}

// Использование
dio.interceptors.add(RetryInterceptor(maxRetries: 3));
```

## Обработка ошибок в UI

### Widget для отображения ошибок

```dart
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorWidget({
    required this.message,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}
```

### Обёртка для загрузки и ошибок

```dart
class AsyncWidgetBuilder<T> extends StatelessWidget {
  final Future<T> Function() futureBuilder;
  final Widget Function(T data) builder;
  final Widget Function(String error)? errorBuilder;
  final Widget Function()? loadingBuilder;

  const AsyncWidgetBuilder({
    required this.futureBuilder,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: futureBuilder(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingBuilder?.call() ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return errorBuilder?.call(snapshot.error.toString()) ??
              ErrorWidget(
                message: snapshot.error.toString(),
                onRetry: () => setState(() {}),
              );
        }

        if (snapshot.hasData) {
          return builder(snapshot.data!);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
```

## Best Practices

- **Всегда обрабатывайте ошибки** — не оставляйте запросы без обработчиков
- **Показывайте понятные сообщения** — не выводите технические детали пользователю
- **Используйте retry для transient-ошибок** — таймауты, 500-е коды
- **Не retry клиентские ошибки** — 400, 401, 404 не исправятся повторным запросом
- **Используйте exponential backoff** — не спамьте сервер запросами
- **Показывайте индикатор загрузки** — пользователь должен знать, что что-то происходит
- **Предлагайте retry в UI** — кнопка «Повторить» при ошибке
