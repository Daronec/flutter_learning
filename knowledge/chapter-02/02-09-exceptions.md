---
tags:
  - dart
  - syntax
  - basics
chapter: 2
section: 9
title: Исключения и обработка ошибок
alias: 02 09 exceptions
status: complete
---

# 2.9 Исключения и обработка ошибок

## Типы ошибок

### Ошибки компиляции

```dart
// Ошибки, обнаруживаемые на этапе компиляции
int x = 'string'; // ❌ Error: A value of type 'String' cannot be assigned

// Missing return
int compute() {
  // ❌ Error: A function which returns data must return a value
}

// Unhandled exception in async
Future<void> badAsync() async {
  throw Exception('Error');
  // Без try/catch в вызывающем коде
}
```

### Ошибки выполнения (Runtime Errors)

```dart
// Null pointer
String? name;
print(name.length); // ❌ Null check operator used on a null value

// Division by zero
int result = 10 ~/ 0; // ❌ IntegerDivisionByZeroException

// Index out of range
var list = [1, 2, 3];
print(list[10]); // ❌ RangeError

// Type cast error
dynamic value = 'text';
int num = value as int; // ❌ TypeError
```

## Try/Catch

### Базовая обработка

```dart
try {
  // Код, который может вызвать исключение
  int result = int.parse('not-a-number');
} catch (e) {
  // Обработка исключения
  print('Ошибка: $e');
}
```

### Catch с двумя параметрами

```dart
try {
  int result = int.parse('not-a-number');
} catch (e, stackTrace) {
  print('Ошибка: $e');
  print('Стек: $stackTrace');
}
```

### Catch с типом

```dart
try {
  int result = int.parse('not-a-number');
} on FormatException {
  // Только FormatException
  print('Неверный формат числа');
} on ArgumentError {
  // Только ArgumentError
  print('Неверный аргумент');
} catch (e) {
  // Все остальные исключения
  print('Неизвестная ошибка: $e');
}
```

### Finally

```dart
try {
  var data = await fetchData();
  print(data);
} catch (e) {
  print('Ошибка: $e');
} finally {
  // Выполняется всегда, даже при исключении
  print('Завершено');
  cleanup();
}
```

## Throw

### Бросание исключений

```dart
// Бросок Exception
void validateAge(int age) {
  if (age < 0) {
    throw ArgumentError('Age cannot be negative');
  }
  if (age > 150) {
    throw ArgumentError('Age is too high');
  }
}

// Бросок Error (фатальные ошибки)
void checkNotNull(dynamic value) {
  if (value == null) {
    throw Error();
  }
}
```

### Custom Exceptions

```dart
// Собственное исключение
class DatabaseException implements Exception {
  final String message;
  final int? code;
  
  DatabaseException(this.message, [this.code]);
  
  @override
  String toString() => 'DatabaseException: $message (code: $code)';
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  NetworkException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'NetworkException: $message (status: $statusCode)';
}

// Использование
Future<void> fetchData() async {
  try {
    // ...
    throw DatabaseException('Connection timeout', 504);
  } catch (e) {
    rethrow; // Перебросить то же исключение
  }
}
```

### Rethrow

```dart
Future<void> loadData() async {
  try {
    await fetchData();
  } catch (e) {
    // Логирование
    print('Load failed: $e');
    // Переброс
    rethrow;
  }
}
```

## Result Pattern

### Result monad

```dart
/// Result — паттерн для обработки ошибок без исключений
class Result<T> {
  final T? data;
  final String? error;
  
  Result._(this.data, this.error);
  
  factory Result.success(T data) => Result._(data, null);
  factory Result.failure(String error) => Result._(null, error);
  
  bool get isSuccess => error == null;
  bool get isError => error != null;
  
  R map<R>(R Function(T data) success, R Function(String error) failure) {
    return isSuccess ? success(data!) : failure(error!);
  }
  
  Result<R> then<R>(Result<R> Function(T data) transformer) {
    return isSuccess ? transformer(data!) : Result.failure(error!);
  }
}

// Использование
Result<User> result = await fetchUser();

result.map(
  (user) => print('User: ${user.name}'),
  (error) => print('Error: $error'),
);
```

## Async Error Handling

### Future error handling

```dart
// try/catch с async/await
Future<void> loadData() async {
  try {
    String data = await fetchData();
    print(data);
  } catch (e) {
    print('Ошибка загрузки: $e');
  }
}

// .catchError
fetchData().catchError((e) {
  print('Ошибка: $e');
});

// .whenComplete (аналог finally)
fetchData().whenComplete(() {
  print('Завершено, независимо от результата');
});
```

### Stream error handling

```dart
stream.listen(
  (data) => print('Data: $data'),
  onError: (error) => print('Error: $error'),
  onDone: () => print('Stream closed'),
  cancelOnError: true, // остановить при первой ошибке
);
```

## Best Practices

### Правила обработки ошибок

1. **Ловите только то, что можете обработать**
```dart
// ❌ Не рекомендуется
try {
  doSomething();
} catch (e) {
  // Пустой catch — скрывает ошибки
}

// ✅ Рекомендуется
try {
  int num = int.parse(text);
} on FormatException {
  print('Неверный формат числа');
}
```

2. **Используйте rethrow вместо throw**
```dart
try {
  // ...
} catch (e, stack) {
  logError(e, stack);
  rethrow; // Сохраняет оригинальный стек
}
```

3. **Создавайте кастомные исключения**
```dart
class BusinessException implements Exception {
  final String message;
  BusinessException(this.message);
}
```

4. **Используйте Result pattern для бизнес-логики**
```dart
Result<User> result = await registerUser(data);
if (result.isSuccess) {
  navigateToHome(result.data!);
} else {
  showError(result.error!);
}
```

## Иерархия исключений

```
Object
├── Exception
│   ├── ArgumentError
│   ├── FormatException
│   ├── IOException
│   ├── StateError
│   └── [Custom Exceptions]
├── Error
│   ├── ArgumentError
│   ├── AssertionError
│   └── [System Errors]
└── TypeError
```

## Заключение

Правильная обработка ошибок — критически важная часть написания надёжного кода. Используйте try/catch для непредсказуемых операций, кастомные исключения для бизнес-логики и Result pattern для явной обработки ошибок.
