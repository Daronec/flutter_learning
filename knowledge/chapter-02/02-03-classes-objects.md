---
tags:
  - dart
  - syntax
  - basics
chapter: 2
section: 3
title: Классы и объекты: конструкторы, фабрики, инициализация
alias: 02 03 classes objects
status: complete
---

# 2.3 Классы и объекты: конструкторы, фабрики, инициализация

## Базовые классы

### Объявление класса

```dart
class Person {
  // Поля (instance variables)
  String name;
  int age;
  
  // Конструктор
  Person(this.name, this.age);
  
  // Метод
  String greet() {
    return 'Hello, my name is $name and I am $age years old';
  }
}

// Создание объекта
var person = Person('Alice', 25);
print(person.greet());
```

### Инициализация полей

```dart
class Person {
  String name;
  int age;
  
  // Способ 1: this. синтаксис
  Person(this.name, this.age);
  
  // Способ 2: присваивание в теле
  Person(String name, int age) {
    this.name = name;
    this.age = age;
  }
  
  // Способ 3: инициализация по умолчанию
  String country = 'Russia'; // inline initialization
}
```

## Конструкторы

### Именованные конструкторы

```dart
class Person {
  String name;
  int age;
  
  // Основной конструктор
  Person(this.name, this.age);
  
  // Именованный конструктор
  Person.elder(String name, int age) 
    : this(name, age);
  
  // Конструктор по умолчанию
  Person.defaultName() 
    : name = 'Unknown', age = 0;
}
```

### Конструкторы с именованными параметрами

```dart
class Person {
  String name;
  int age;
  
  Person({required this.name, required this.age});
}

// Вызов
var person = Person(name: 'Alice', age: 25);
```

### Константные конструкторы (const)

```dart
class Point {
  final double x;
  final double y;
  
  const Point(this.x, this.y);
}

// Использование
const origin = Point(0, 0);
const point = Point(1, 1);
```

> **Важно**: Для использования `const` все поля класса должны быть `final`.

### Перенаправление конструктора (redirecting)

```dart
class Person {
  String name;
  int age;
  
  // Основной
  Person(this.name, this.age);
  
  // Перенаправление
  Person.child(String name) : this(name, 5);
  Person.adult(String name) : this(name, 18);
}
```

### Фабричные конструкторы (factory)

```dart
class Logger {
  final String name;
  
  factory Logger(String name) => _cache[name] ??= Logger._internal(name);
  
  Logger._internal(this.name);
  
  static final Map<String, Logger> _cache = {};
}

// Factory возвращает кэшированный экземпляр
var logger1 = Logger('app');
var logger2 = Logger('app');
// logger1 == logger2 → true
```

## Инициализация

### Инициализационный список

```dart
class Person {
  final String name;
  final int age;
  final String description;
  
  Person(this.name, this.age)
    : description = '$name is $age years old',
      assert(age >= 0); // проверка перед инициализацией
}
```

### InitState (в Flutter)

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState(); // всегда вызывать super
    // Инициализация после создания объекта
    _initializeData();
  }
  
  void _initializeData() {
    // ...
  }
}
```

## Getters и Setters

```dart
class Person {
  String _name; // приватное поле (префикс _)
  
  Person(this._name);
  
  // Getter
  String get name => _name.toUpperCase();
  
  // Setter
  set name(String value) => _name = value.trim();
  
  // Вычисляемое свойство
  String get greeting => 'Hello, I am $name';
}
```

## Методы

### Instance методы

```dart
class Calculator {
  int add(int a, int b) => a + b;
  int multiply(int a, int b) => a * b;
}
```

### Static методы

```dart
class MathUtils {
  static int add(int a, int b) => a + b;
  static double pi = 3.14159;
}

// Вызов без экземпляра
MathUtils.add(3, 4); // 7
```

### Async методы

```dart
class DataService {
  Future<String> fetchData() async {
    await Future.delayed(Duration(seconds: 1));
    return 'Data';
  }
}
```

## Миксины (кратко)

```dart
mixin Loggable {
  void log(String message) {
    print('[LOG] $message');
  }
}

class Person with Loggable {
  String name;
  Person(this.name);
  
  void introduce() {
    log('Person introduced: $name');
  }
}
```

## Итоговая таблица

| Элемент | Синтаксис | Описание |
|---|---|---|
| Поле | `String name;` | Instance variable |
| Конструктор | `Person(this.name);` | Основной |
| Именованный | `Person.child()` | Альтернативный |
| Factory | `factory Logger()` | Возвращает кэшированный |
| const | `const Point()` | Compile-time константа |
| Getter | `get name => _name;` | Читаемое свойство |
| Setter | `set name(v) => _name = v;` | Записываемое свойство |

## Заключение

Классы в Dart — полноценные объектно-ориентированные структуры с поддержкой конструкторов, фабрик, геттеров/сеттеров и миксинов. Понимание инициализации и типов конструкторов — ключ к правильному проектированию классов.
