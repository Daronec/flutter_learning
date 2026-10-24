---
tags:
  - performance
  - optimization
chapter: 14
section: 6
title: 14-06. Isolates и многопоточность
alias: 14 06 isolates
status: complete
---

# 14-06. Isolates и многопоточность

## Введение

Flutter работает в одном потоке (main thread), что означает, что длительные операции блокируют интерфейс. Isolates — это механизм многопоточности в Dart, который позволяет выполнять код параллельно, не блокируя основной поток.

## Основы Dart

### Single-threaded модель

Dart использует single-threaded модель выполнения с event loop:

```
┌─────────────────────────────────────────────┐
│                  Event Loop                  │
│                                              │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐  │
│  │ Microtask│    │  Timer   │    │  IO     │  │
│  │ Queue    │    │ Queue    │    │ Queue   │  │
│  └─────────┘    └─────────┘    └─────────┘  │
│                                              │
│  Microtasks > Timers > I/O                   │
└─────────────────────────────────────────────┘
```

### Проблема блокировки UI

```dart
class BlockingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Эта операция блокирует UI на 5 секунд!
    final result = heavyComputation();
    return Text(result);
  }

  String heavyComputation() {
    // Симуляция тяжёлой вычислительной операции
    var sum = 0;
    for (var i = 0; i < 1000000000; i++) {
      sum += i;
    }
    return 'Result: $sum';
  }
}
```

## Isolates

### Что такое Isolate

Isolate — это независимый поток выполнения с собственной памятью. В отличие от потоков (threads), Isolates не разделяют память — они обмениваются данными через сообщения.

### Сравнение: Thread vs Isolate

| Характеристика | Thread | Isolate |
|---------------|--------|---------|
| Память | Общая | Изолированная |
| Синхронизация | Нужна (mutex, lock) | Не нужна |
| Безопасность | Нужно careful coding | По умолчанию безопасно |
| Обмен данными | Переменные | Сообщения (ports) |
| GIL | Нет | Нет |

### Types of Isolates

| Тип | Описание |
|-----|----------|
| Main Isolate | Основной поток приложения |
| Worker Isolate | Фоновый поток для вычислений |
| Dart Isolate | Новый Isolate через `Isolate.spawn` |

## Isolate Basics

### Создание Isolate

```dart
import 'dart:isolate';

// Функция, которая будет выполняться в Isolate
// Должна быть top-level или static функцией
void workerFunction(SendPort sendPort) {
  // Получаем порт для отправки сообщений
  final receivePort = ReceivePort();

  // Отправляем порт обратно
  sendPort.send(receivePort.sendPort);

  // Слушаем входящие сообщения
  receivePort.listen((message) {
    if (message is List) {
      final data = message[0] as List<int>;
      final result = processData(data);

      // Отправляем результат обратно
      sendPort.send(result);
    }
  });
}

// Обработка данных
List<int> processData(List<int> data) {
  // Тяжёлые вычисления
  return data.map((e) => e * 2).toList();
}

// Использование
Future<void> useIsolate() async {
  final receivePort = ReceivePort();

  // Создаём Isolate
  await Isolate.spawn(workerFunction, receivePort.sendPort);

  // Получаем порт для отправки сообщений в Isolate
  final sendPort = await receivePort.first;

  // Отправляем данные
  sendPort.send([1, 2, 3, 4, 5]);

  // Получаем результат
  receivePort.listen((message) {
    print('Результат: $message'); // [2, 4, 6, 8, 10]
  });

  // Закрываем порт
  receivePort.close();
}
```

### Isolate с ReceivePort для двунаправленной связи

```dart
class IsolateWorker {
  late ReceivePort _receivePort;
  late SendPort _sendPort;
  bool _isRunning = false;

  Future<void> start() async {
    _receivePort = ReceivePort();

    await Isolate.spawn(_workerEntry, _receivePort.sendPort);

    // Ждём, пока Isolate отправит свой SendPort
    _sendPort = await _receivePort.first;
    _isRunning = true;
  }

  static void _workerEntry(SendPort mainSendPort) {
    final workerReceivePort = ReceivePort();

    // Отправляем свой порт главному Isolate
    mainSendPort.send(workerReceivePort.sendPort);

    // Обрабатываем сообщения
    workerReceivePort.listen((dynamic message) {
      switch (message.runtimeType) {
        case SendPort:
          // Инициализация завершена
          break;
        case List<int>:
          final data = message as List<int>;
          final result = _processData(data);
          // Отправляем результат
          mainSendPort.send(result);
          break;
        case String:
          if (message == 'stop') {
            workerReceivePort.close();
          }
          break;
      }
    });
  }

  static List<int> _processData(List<int> data) {
    return data.map((e) => e * 2).toList();
  }

  Future<List<int>> process(List<int> data) async {
    if (!_isRunning) {
      throw StateError('Worker not started');
    }
    _sendPort.send(data);
    return _receivePort.first as Future<List<int>>;
  }

  void stop() {
    _sendPort.send('stop');
    _receivePort.close();
    _isRunning = false;
  }
}
```

## compute() function

### Что такое compute

`compute()` — это встроенная функция Flutter, которая упрощает работу с Isolates. Она автоматически создаёт Isolate, выполняет функцию и возвращает результат.

### Базовое использование

```dart
// Вычисление в Isolate
final result = await compute(_heavyComputation, inputData);

// Функция должна быть top-level или static
int _heavyComputation(int data) {
  var sum = 0;
  for (var i = 0; i < data; i++) {
    sum += i;
  }
  return sum;
}

// Использование в виджете
class ComputeExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final result = await compute(_heavyComputation, 1000000000);
        print('Результат: $result');
      },
      child: const Text('Вычислить'),
    );
  }
}
```

### Вычисление с объектами

```dart
class User {
  final String name;
  final List<int> scores;

  const User({required this.name, required this.scores});
}

// Вычисление среднего балла в Isolate
double _calculateAverage(List<User> users) {
  double total = 0;
  int count = 0;
  for (final user in users) {
    for (final score in user.scores) {
      total += score;
      count++;
    }
  }
  return count > 0 ? total / count : 0;
}

// Использование
Future<void> calculateAverage() async {
  final users = await fetchUsers();
  final average = await compute(_calculateAverage, users);
  print('Средний балл: $average');
}
```

### Вычисление с парсингом JSON

```dart
// Парсинг большого JSON в Isolate
class JsonParser {
  static List<Product> parseProducts(String jsonString) {
    final jsonData = jsonDecode(jsonString) as List;
    return jsonData.map((item) {
      return Product(
        id: item['id'] as int,
        name: item['name'] as String,
        price: (item['price'] as num).toDouble(),
        description: item['description'] as String,
      );
    }).toList();
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });
}

// Использование
Future<void> loadProducts() async {
  final jsonString = await fetchJsonData();

  // Парсинг в Isolate — не блокирует UI
  final products = await compute(
    JsonParser.parseProducts,
    jsonString,
  );

  setState(() {
    _products = products;
  });
}
```

### Вычисление с шифрованием

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoHelper {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static List<String> hashPasswords(List<String> passwords) {
    return passwords.map(hashPassword).toList();
  }
}

// Использование
Future<void> hashPasswords() async {
  final passwords = await fetchPasswords();
  final hashed = await compute(
    CryptoHelper.hashPasswords,
    passwords,
  );
  // Сохраняем хешированные пароли
}
```

## Когда использовать Isolate

### Когда стоит использовать

| Сценарий | Рекомендуется |
|----------|--------------|
| Тяжёлые вычисления (JSON, CSV) | Да |
| Шифрование/хеширование | Да |
| Обработка изображений | Да |
| Сортировка больших списков | Да |
| Парсинг больших файлов | Да |
| Простые операции | Нет |
| Работа с UI | Нет |
| Сетевые запросы | Нет (используйте Future) |

### Когда НЕ использовать

```dart
// НЕ нужно использовать Isolate для:

// 1. Простых вычислений
int simpleCalculation(int a, int b) => a + b;
// Достаточно вызвать напрямую

// 2. Сетевых запросов
Future<String> fetchData() async {
  // HTTP-запрос уже асинхронный
  final response = await http.get(Uri.parse('https://api.example.com'));
  return response.body;
}

// 3. Работы с UI
void updateUI() {
  // UI-операции должны быть в main thread
  setState(() {
    _text = 'Updated';
  });
}
```

## Best Practices

### Рекомендации по использованию Isolates

1. **Используйте `compute()` для простых задач** — это самый простой способ
2. **Функции для `compute()` должны быть top-level или static** — не методы класса
3. **Избегайте создания Isolate для каждой операции** — переиспользуйте Worker
4. **Передавайте только сериализуемые данные** — Isolate обмениваются сообщениями
5. **Закрывайте ReceivePort после использования** — избегайте утечек памяти
6. **Проверяйте, действительно ли задача тяжёлая** — накладные расходы на создание Isolate

### Сравнение подходов

| Подход | Сложность | Гибкость | Производительность |
|--------|-----------|----------|-------------------|
| `compute()` | Низкая | Средняя | Хорошая |
| `Isolate.spawn` | Высокая | Высокая | Отличная |
| `IsolateRunner` | Средняя | Высокая | Отличная |

### Чек-лист использования Isolates

- [ ] Задача действительно тяжёлая (> 50ms)
- [ ] Функция является top-level или static
- [ ] Данные для передачи сериализуемы
- [ ] ReceivePort закрывается после использования
- [ ] Нет работы с UI в Isolate
- [ ] Результаты тестированы на разных устройствах

## Заключение

Isolates — это мощный инструмент для выполнения тяжёлых вычислений без блокировки UI. Функция `compute()` предоставляет простой способ использования Isolates для типичных задач, в то время как `Isolate.spawn` даёт полный контроль для сложных сценариев.
