---
tags:
  - dart
  - syntax
  - basics
chapter: 2
section: 6
title: Асинхронность: Future, Stream, isolate
alias: 02 06 async await
status: complete
---

# 2.6 Асинхронность: Future, Stream, isolate

## Future

### Основы

```dart
// Future представляет отложенный результат
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Data loaded';
}

// Использование с await
void main() async {
  String result = await fetchData();
  print(result);
}

// Использование с .then()
fetchData().then((data) {
  print(data);
}).catchError((error) {
  print('Error: $error');
});
```

### Создание Future

```dart
// Из значения
Future<int> fromValue() => Future.value(42);

// Из исключения
Future<int> fromError() => Future.error('Something went wrong');

// Задержка
Future<void> delayed() => Future.delayed(Duration(seconds: 1));

// Синхронный Future
Future<int> syncFuture() => Future.sync(() => 42);
```

### Параллельное выполнение

```dart
// Несколько Future параллельно
Future<void> parallel() async {
  var results = await Future.wait([
    fetchUsers(),
    fetchPosts(),
    fetchComments(),
  ]);
  
  var users = results[0] as List<User>;
  var posts = results[1] as List<Post>;
  var comments = results[2] as List<Comment>;
}

// Первый завершившийся
Future<void> fastest() async {
  var result = await Future.any([
    fetchFromApi1(),
    fetchFromApi2(),
    fetchFromApi3(),
  ]);
}
```

## Stream

### Основы

```dart
// Stream — последовательность асинхронных событий
Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    yield i;
  }
}

// Подписка на Stream
void main() {
  countStream(5).listen(
    (data) => print('Data: $data'),
    onError: (error) => print('Error: $error'),
    onDone: () => print('Stream completed'),
  );
}
```

### Типы Stream

| Тип | Описание |
|---|---|
| **Single-subscription** | Одна подписка, последовательная доставка |
| **Broadcast** | Множественные подписки, события дублируются |

```dart
// Single-subscription (по умолчанию)
Stream<int> single = countStream(5);

// Broadcast
Stream<int> broadcast = countStream(5).asBroadcastStream();
```

### Stream методы

```dart
Stream<int> numbers = Stream.fromIterable([1, 2, 3, 4, 5, 6]);

// Transform
var even = numbers.where((n) => n % 2 == 0); // [2, 4, 6]
var doubled = numbers.map((n) => n * 2);      // [2, 4, 6, 8, 10, 12]

// Aggregate
var sum = numbers.reduce((a, b) => a + b);     // 21
var first = numbers.first;                      // 1
var last = numbers.last;                        // 6
var any = numbers.any((n) => n > 3);            // true
var all = numbers.every((n) => n > 0);          // true

// Conversion
var list = numbers.toList();    // [1, 2, 3, 4, 5, 6]
var set = numbers.toSet();      // {1, 2, 3, 4, 5, 6}
var string = numbers.join(', '); // '1, 2, 3, 4, 5, 6'
```

### StreamController

```dart
// Создание Stream вручную
class Counter {
  final _controller = StreamController<int>();
  
  Stream<int> get stream => _controller.stream;
  
  void increment() {
    _controller.add(_controller.hasListener 
        ? _controller.stream.toList().then((l) => l.last + 1) 
        : 1);
  }
  
  void dispose() {
    _controller.close();
  }
}
```

## Isolate

### Что такое Isolate?

Isolate — это отдельный поток выполнения с собственной памятью. В отличие от threads, изоляты не разделяют память.

### Создание Isolate

```dart
// Worker функция (должна быть top-level или static)
void workerFunction(SendPort sendPort) {
  // Тяжёлые вычисления
  int result = 0;
  for (int i = 0; i < 1000000; i++) {
    result += i;
  }
  
  // Отправка результата обратно
  sendPort.send(result);
}

// Запуск Isolate
void main() async {
  final receivePort = ReceivePort();
  
  await Isolate.spawn(workerFunction, receivePort.sendPort);
  
  receivePort.listen((message) {
    print('Result: $message');
    receivePort.close();
  });
}
```

### Isolate с ReceivePort

```dart
Future<int> heavyComputation() async {
  final receivePort = ReceivePort();
  
  await Isolate.spawn(_worker, receivePort.sendPort);
  
  final response = await receivePort.first;
  
  await (response[0] as Isolate).kill();
  return response[1] as int;
}

static void _worker(SendPort sendPort) {
  int result = 0;
  for (int i = 0; i < 1000000; i++) {
    result += i;
  }
  
  sendPort.send([Isolate.current, result]);
}
```

### compute() — утилита Flutter

```dart
// Встроенная утилита Flutter для простых вычислений
import 'package:flutter/foundation.dart';

// Простая функция
int computeFactorial(int n) {
  int result = 1;
  for (int i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

// Использование
void main() async {
  int result = await compute(computeFactorial, 20);
  print(result);
}
```

## Сравнение: Future vs Stream vs Isolate

| | Future | Stream | Isolate |
|---|---|---|---|
| **Значения** | Одно | Множество | Одно |
| **Асинхронность** | Да | Да | Да |
| **Память** | Общий heap | Общий heap | Свой heap |
| **Использование** | Один запрос | Последовательность | Тяжёлые вычисления |
| **Пример** | HTTP запрос | Клик пользователя | Обработка изображения |

## Заключение

Асинхронность в Dart строится на трёх столпах:
- **Future** — для одиночных отложенных операций
- **Stream** — для последовательностей событий
- **Isolate** — для тяжёлых вычислений без блокировки UI потока
