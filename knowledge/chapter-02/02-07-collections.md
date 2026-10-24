---
tags:
  - dart
  - syntax
  - basics
chapter: 2
section: 7
title: Коллекции: List, Set, Map и их методы
alias: 02 07 collections
status: complete
---

# 2.7 Коллекции: List, Set, Map и их методы

## List

### Создание и инициализация

```dart
// Literal синтаксис
var fruits = ['Apple', 'Banana', 'Cherry'];
var numbers = [1, 2, 3, 4, 5];

// const list
const fruits = ['Apple', 'Banana'];

// List.from()
var fromIterable = List.from([1, 2, 3]);

// List.generate()
var squares = List.generate(5, (i) => i * i); // [0, 1, 4, 9, 16]

// List.fillRange()
var filled = List.filled(5, 0); // [0, 0, 0, 0, 0]

// Пустой List
var empty = <String>[];
```

### Основные методы

```dart
var numbers = [3, 1, 4, 1, 5, 9, 2, 6];

// Доступ
numbers[0];       // 3 (первый элемент)
numbers.last;     // 6 (последний элемент)
numbers.first;    // 3 (первый элемент)
numbers.length;   // 8

// Изменение
numbers.add(7);           // добавить в конец
numbers.insert(0, 0);     // вставить по индексу
numbers.remove(1);        // удалить по значению
numbers.removeAt(0);      // удалить по индексу
numbers.removeLast();     // удалить последний
numbers.clear();          // очистить

// Проверка
numbers.contains(3);      // true
numbers.indexOf(4);       // 2
```

### Методы трансформации

```dart
var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// map — трансформация каждого элемента
var doubled = numbers.map((n) => n * 2).toList();
// [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

// where — фильтрация
var even = numbers.where((n) => n % 2 == 0).toList();
// [2, 4, 6, 8, 10]

// whereType — фильтрация по типу
var mixed = [1, 'hello', 2, 'world', 3];
var ints = mixed.whereType<int>().toList(); // [1, 2, 3]

// take / skip
var first3 = numbers.take(3).toList();  // [1, 2, 3]
var withoutFirst3 = numbers.skip(3).toList(); // [4, 5, 6, ...]

// takeWhile / skipWhile
var whileLess10 = numbers.takeWhile((n) => n < 10).toList();

// sort — сортировка
numbers.sort();                      // возрастание
numbers.sort((a, b) => b.compareTo(a)); // убывание

// reversed
var reversed = numbers.reversed.toList();

// toSet
var unique = numbers.toSet();

// distinct
var uniqueList = numbers.toSet().toList();
```

### Reduce и fold

```dart
var numbers = [1, 2, 3, 4, 5];

// reduce — объединение элементов
var sum = numbers.reduce((a, b) => a + b); // 15
var max = numbers.reduce((a, b) => a > b ? a : b); // 5

// fold — объединение с начальным значением
var sumWithStart = numbers.fold(10, (a, b) => a + b); // 25 (10 + 15)
var concatenated = numbers.fold('', (a, b) => '$a$b'); // '12345'
```

## Set

### Создание

```dart
// Literal
var fruits = {'Apple', 'Banana', 'Cherry'};

// from
var fromList = Set.from(['Apple', 'Banana', 'Apple']);
// {'Apple', 'Banana'} — дубли удалены

// const
const fruits = {'Apple', 'Banana'};
```

### Основные методы

```dart
var numbers = {1, 2, 3, 4, 5};

// Добавление/удаление
numbers.add(6);
numbers.remove(3);
numbers.addAll({7, 8});
numbers.removeAll({1, 2});

// Проверка
numbers.contains(3);        // true
numbers.containsAll([1, 2]); // true

// Подмножество
{1, 2}.subsetOf(numbers);   // true

// Пересечение, объединение, разность
var a = {1, 2, 3, 4};
var b = {3, 4, 5, 6};

a.intersection(b); // {3, 4}
a.union(b);        // {1, 2, 3, 4, 5, 6}
a.difference(b);   // {1, 2}
```

## Map

### Создание

```dart
// Literal
var user = {
  'name': 'Alice',
  'age': 25,
  'email': 'alice@example.com',
};

// fromIterable
var names = ['Alice', 'Bob', 'Charlie'];
var nameMap = Map.fromIterable(names, key: (n) => n, value: (n) => n.length);
// {'Alice': 5, 'Bob': 3, 'Charlie': 7}

// const
const config = {'key': 'value', 'count': 42};
```

### Основные методы

```dart
var user = {
  'name': 'Alice',
  'age': 25,
};

// Доступ
user['name'];           // 'Alice'
user['nickname'] ??= 'Ali'; // null-aware присваивание

// Изменение
user['email'] = 'alice@example.com';
user.addAll({'city': 'Moscow'});

// Удаление
user.remove('age');
user.clear();

// Проверка
user.containsKey('name');   // true
user.containsValue('Alice'); // true

// keys и values
user.keys.toList();    // ['name', 'age']
user.values.toList();  // ['Alice', 25]

// Transform
var upperNames = user.keys.map((k) => k.toUpperCase()).toList();
```

### Map с типизацией

```dart
Map<String, dynamic> user = {
  'name': 'Alice',
  'age': 25,
};

// Приведение типов
String name = user['name'] as String;
int age = user['age'] as int;

// Safe cast
String? name = user['name'] as String?;
```

## Коллекции — сравнение

| Коллекция | Порядок | Дубли | Пример |
|---|---|---|---|
| `List` | Да | Да | `[1, 2, 2, 3]` |
| `Set` | Нет* | Нет | `{1, 2, 3}` |
| `Map` | Ключи уникальны | Нет | `{'a': 1, 'b': 2}` |

*Set сохраняет порядок вставки в Dart.

## Заключение

Коллекции Dart богаты методами для трансформации, фильтрации и агрегации. Понимание этих методов позволяет писать компактный и эффективный код без необходимости в циклах.
