---
tags:
  - dart
  - syntax
  - basics
chapter: 2
section: 8
title: Расширения (extension methods) и операторы
alias: 02 08 extensions operators
status: complete
---

# 2.8 Расширения (extension methods) и операторы

## Extension Methods

### Что такое Extensions?

Extensions позволяют добавлять методы к существующим классам без наследования или изменения исходного кода.

### Базовое использование

```dart
// Расширение для String
extension StringExtension on String {
  bool get isEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  bool get isNumeric {
    return double.tryParse(this) != null;
  }
  
  String reverse() {
    return split('').reversed.join('');
  }
  
  String capitalize() {
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}

// Использование
'hello'.reverse();        // 'olleh'
'hello'.capitalize();     // 'Hello'
'test@example.com'.isEmail; // true
```

### Расширения для числовых типов

```dart
extension IntExtension on int {
  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;
  
  List<int> get times => List.generate(this, (i) => i);
}

// Использование
5.times;        // [0, 1, 2, 3, 4]
4.isEven;       // true
7.isOdd;        // true
```

### Расширения для List

```dart
extension ListExtension<T> on List<T> {
  T? get safe {
    return isEmpty ? null : first;
  }
  
  List<T> get unique => toSet().toList();
  
  List<List<T>> chunked(int size) {
    return List.generate(
      (length / size).ceil(),
      (i) => getRange(i * size, (i + 1) * length.clamp(0, length)).toList(),
    );
  }
}

// Использование
[1, 2, 3, 4, 5].safe;        // 1
[1, 2, 2, 3].unique;         // [1, 2, 3]
[1, 2, 3, 4, 5].chunked(2);  // [[1, 2], [3, 4], [5]]
```

### Conditional Extensions

```dart
// Расширение доступно только для типов с определённым интерфейсом
extension NullableStringExtension on String? {
  String get orEmpty => this ?? '';
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

// Использование
String? name;
name.orEmpty;           // ''
name.isNullOrEmpty;     // true
```

### Static Extensions

```dart
extension DateHelpers on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  String get relative {
    final now = DateTime.now();
    final diff = now.difference(this).inDays;
    
    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Вчера';
    if (diff < 7) return '$diff дней назад';
    return toLocal().toString().split(' ')[0];
  }
}

// Использование
DateTime.now().relative; // 'Сегодня'
```

## Операторы

### Арифметические операторы

```dart
int a = 10, b = 3;

a + b;   // 13 (сложение)
a - b;   // 7  (вычитание)
a * b;   // 30 (умножение)
a / b;   // 3.333... (деление)
a ~/ b;  // 3  (целочисленное деление)
a % b;   // 1  (остаток)
-a;      // -10 (унарный минус)
```

### Операторы сравнения

```dart
a == b;   // false (равенство)
a != b;   // true  (неравенство)
a > b;    // true
a < b;    // false
a >= b;   // true
a <= b;   // false
```

### Логические операторы

```dart
bool x = true, y = false;

!x;    // false (NOT)
x && y; // false (AND)
x || y; // true  (OR)
```

### Присваивание

```dart
int a = 10;

a += 5;   // a = 15
a -= 3;   // a = 12
a *= 2;   // a = 24
a /= 4;   // a = 6.0
a ~/= 2;  // a = 3
a %= 4;   // a = 3

// Cascade operator (>>)
var builder = StringBuffer()
  ..write('Hello')
  ..write(' ')
  ..write('World');
// 'Hello World'
```

### Null-aware операторы

```dart
String? name;

// Null-coalescing
String displayName = name ?? 'Anonymous';

// Null-aware assignment
name ??= 'Default';  // присвоить только если null

// Null-aware access
int? length = name?.length;

// Null-aware cascade
obj?.method();  // вызвать только если obj != null
```

### Оператор приведения типов

```dart
// as — приведение типа
String name = user['name'] as String;

// is — проверка типа
if (user['name'] is String) {
  print('Name is a string');
}

// is! — отрицание проверки
if (user['name'] is! int) {
  print('Name is not an int');
}

// as? (альтернативный синтаксис)
String? name = user['name'] as String?;
```

### Оператор вызова

```dart
// () — вызов функции
var func = () => 42;
func(); // 42

// Function reference
int add(int a, int b) => a + b;
var funcRef = add;
funcRef(3, 4); // 7
```

### Оператор точечной нотации

```dart
// . — доступ к членам
var str = 'Hello';
str.length;       // 5
str.toUpperCase(); // 'HELLO'

// .. — cascade
var sb = StringBuffer()
  ..write('Hello')
  ..write(' World');

// ?. — null-aware доступ
String? name;
int? len = name?.length;
```

## Пользовательские операторы

```dart
class Vector2D {
  final double x;
  final double y;
  
  Vector2D(this.x, this.y);
  
  // Переопределение оператора +
  Vector2D operator +(Vector2D other) {
    return Vector2D(x + other.x, y + other.y);
  }
  
  // Переопределение оператора ==
  @override
  bool operator ==(Object other) {
    return other is Vector2D && x == other.x && y == other.y;
  }
  
  @override
  int get hashCode => Object.hash(x, y);
}

// Использование
var v1 = Vector2D(1, 2);
var v2 = Vector2D(3, 4);
var v3 = v1 + v2; // Vector2D(4, 6)
```

## Заключение

Extensions и операторы — мощные инструменты Dart для расширения функциональности без наследования. Они позволяют писать более читаемый и выразительный код.
