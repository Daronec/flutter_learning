# 2.2 Функции: параметры, стрелочный синтаксис, async/await

## Объявление функций

### Базовый синтаксис

```dart
// Полное объявление
int add(int a, int b) {
  return a + b;
}

// Стрелочный синтаксис (для однострочных функций)
int add(int a, int b) => a + b;

// Без возвращаемого значения
void greet(String name) {
  print('Hello, $name!');
}

// Стрелочный вариант
void greet(String name) => print('Hello, $name!');
```

## Параметры функций

### Обязательные параметры

```dart
// Позиционные параметры
int multiply(int a, int b) {
  return a * b;
}

// Вызов
multiply(3, 4); // 12
```

### Именованные параметры

```dart
// С фигурными скобками — именованные параметры
String greet({String name = 'World', String greeting = 'Hello'}) {
  return '$greeting, $name!';
}

// Вызов с именованными параметрами
greet(name: 'Alice');                    // 'Hello, Alice!'
greet(greeting: 'Hi', name: 'Bob');      // 'Hi, Bob!'
greet();                                  // 'Hello, World!'
```

### Опциональные параметры

```dart
// Позиционные опциональные (в квадратных скобках)
String greet([String name = 'World']) {
  return 'Hello, $name!';
}

// Именованные опциональные (в фигурных скобках)
String greet2({String name = 'World', String greeting = 'Hello'}) {
  return '$greeting, $name!';
}
```

### @required аннотация

```dart
// Именованный обязательный параметр
void sendEmail({required String to, required String subject, String? body}) {
  // ...
}

// Вызов — обязательно указать required параметры
sendEmail(to: 'user@example.com', subject: 'Hello');
```

## Функции как объекты

### Function type

```dart
// Функция как переменная
int add(int a, int b) => a + b;
var func = add;
func(3, 4); // 12

// Анонимные функции
var numbers = [1, 2, 3, 4, 5];
var doubled = numbers.map((n) => n * 2).toList();
// [2, 4, 6, 8, 10]
```

### Closure (замыкание)

```dart
// Closure — функция запоминает окружение
Function makeAdder(int amount) {
  return (int number) => number + amount;
}

var add5 = makeAdder(5);
add5(10); // 15
```

## Асинхронное программирование

### Future

```dart
// Future — результат асинхронной операции
Future<String> fetchData() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Data loaded';
}

// Использование
void main() {
  fetchData().then((data) {
    print(data); // 'Data loaded'
  });
}
```

### async/await

```dart
// async — функция возвращает Future
// await — ожидание завершения Future

Future<void> loadData() async {
  try {
    String data = await fetchData();
    print(data);
  } catch (e) {
    print('Ошибка: $e');
  }
}

// Несколько последовательных async вызовов
Future<void> loadAllData() async {
  String users = await fetchUsers();
  String posts = await fetchPosts();
  String comments = await fetchComments();
  
  print('Loaded: $users, $posts, $comments');
}
```

### async* и Stream

```dart
// async* — генерирует Stream
Stream<int> countUpTo(int max) async* {
  for (int i = 1; i <= max; i++) {
    yield i; // отправляет значение в Stream
  }
}

// Использование
void main() {
  countUpTo(5).forEach((num) {
    print(num); // 1, 2, 3, 4, 5
  });
}
```

### sync* и yield (устаревший, вместо — Stream.fromIterable)

```dart
// sync* — синхронный генератор (устаревший в новых версиях Dart)
// Рекомендуется использовать Iterable вместо
Iterable<int> countSync(int max) sync* {
  for (int i = 1; i <= max; i++) {
    yield i;
  }
}
```

## Error handling в async

```dart
// try/catch с async/await
Future<void> safeFetch() async {
  try {
    String data = await fetchData();
    print(data);
  } catch (e, stackTrace) {
    print('Ошибка: $e');
    print('Стек: $stackTrace');
  } finally {
    print('Завершено');
  }
}

// .catchError для Future
fetchData().catchError((e) {
  print('Ошибка: $e');
});
```

## Замыкания и контекст

### this в closures

```dart
class Counter {
  int count = 0;
  
  void increment() {
    // this.count доступен
    Future.delayed(Duration(seconds: 1), () {
      // В обычном closure: this НЕ доступен
      // В arrow function: this доступен
      count++;
      print(count);
    });
  }
}
```

## Заключение

Функции в Dart — это полноценные объекты первого класса. Понимание параметров, стрелочного синтаксиса и async/await — основа написания эффективного Dart-кода.
