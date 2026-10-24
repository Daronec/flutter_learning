---
tags:
  - api
  - http
  - networking
chapter: 9
section: 4
title: JSON: сериализация и десериализация в Dart
alias: 09 04 json serialization
status: complete
---

# JSON: сериализация и десериализация в Dart

JSON (JavaScript Object Notation) — это текстовый формат обмена данными. В Flutter мы постоянно работаем с JSON при обмене данными с сервером.

## Основы работы с JSON

### Импорт

```dart
import 'dart:convert';
```

### jsonDecode и jsonEncode

```dart
// Десериализация JSON (строка → объект)
String jsonString = '{"name": "Иван", "age": 25}';
Map<String, dynamic> data = jsonDecode(jsonString);
print(data['name']); // Иван

// Сериализация объекта в JSON (объект → строка)
Map<String, dynamic> user = {'name': 'Иван', 'age': 25};
String output = jsonEncode(user);
print(output); // {"name":"Иван","age":25}
```

### Работа со списками

```dart
// JSON-массив → List
String jsonList = '[{"name":"Иван"},{"name":"Мария"}]';
List<dynamic> users = jsonDecode(jsonList);

for (var user in users) {
  print(user['name']);
}

// List → JSON-массив
List<Map<String, dynamic>> userList = [
  {'name': 'Иван', 'age': 25},
  {'name': 'Мария', 'age': 30},
];
String jsonOutput = jsonEncode(userList);
```

## Ручная сериализация

### Парсинг JSON в объект

```dart
Map<String, dynamic> json = {
  'id': 1,
  'name': 'Иван Петров',
  'email': 'ivan@example.com',
  'isActive': true,
  'age': 25,
  'address': {
    'city': 'Москва',
    'street': 'ул. Ленина',
    'zipCode': '101000',
  },
  'tags': ['flutter', 'dart'],
};

// Извлечение данных
int id = json['id'] as int;
String name = json['name'] as String;
String email = json['email'] as String;
bool isActive = json['isActive'] as bool;
int? age = json['age'] as int?; // Может быть null

// Вложенный объект
Map<String, dynamic> address = json['address'] as Map<String, dynamic>;
String city = address['city'] as String;

// Список
List<dynamic> tags = json['tags'] as List<dynamic>;
List<String> stringTags = tags.map((e) => e as String).toList();
```

### Создание JSON из объекта

```dart
Map<String, dynamic> userMap = {
  'id': 1,
  'name': 'Иван Петров',
  'email': 'ivan@example.com',
  'isActive': true,
  'age': 25,
  'address': {
    'city': 'Москва',
    'street': 'ул. Ленина',
  },
  'tags': ['flutter', 'dart'],
};

String json = jsonEncode(userMap);
```

## Классы для работы с JSON

### Класс с методом fromJson

```dart
class User {
  final int id;
  final String name;
  final String email;
  final bool isActive;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    this.createdAt,
  });

  // Создание объекта из JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  // Преобразование объекта в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

// Использование
String json = '{"id":1,"name":"Иван","email":"ivan@example.com","isActive":true,"createdAt":"2024-01-15T10:30:00Z"}';
User user = User.fromJson(jsonDecode(json));
String output = jsonEncode(user.toJson());
```

### Работа с вложенными объектами

```dart
class Address {
  final String city;
  final String street;
  final String zipCode;

  Address({required this.city, required this.street, required this.zipCode});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      city: json['city'] as String,
      street: json['street'] as String,
      zipCode: json['zipCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'street': street,
      'zipCode': zipCode,
    };
  }
}

class User {
  final int id;
  final String name;
  final Address? address;

  User({required this.id, required this.name, this.address});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] != null
          ? Address.fromJson(json['address'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address?.toJson(),
    };
  }
}
```

### Работа со списками в классах

```dart
class Post {
  final int id;
  final String title;
  final List<String> tags;
  final List<Map<String, dynamic>> comments;

  Post({
    required this.id,
    required this.title,
    required this.tags,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      tags: (json['tags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tags': tags,
      'comments': comments,
    };
  }
}
```

## Обработка null и типов

### Безопасное извлечение данных

```dart
// Использование as? для безопасного приведения типа
factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as int? ?? 0,           // Значение по умолчанию
    name: json['name'] as String? ?? '',    // Пустая строка
    email: json['email'] as String,         // Обязательное поле
    age: json['age'] as int?,               // Может быть null
    nickname: json['nickname'] as String?,  // Может отсутствовать
  );
}

// Проверка наличия ключа
if (json.containsKey('optionalField')) {
  final value = json['optionalField'];
}

// Проверка типа
if (json['data'] is Map<String, dynamic>) {
  // обрабатываем как Map
}
```

### Преобразование типов

```dart
// String → int
int number = int.parse(json['count'] as String);

// String → double
double price = double.parse(json['price'] as String);

// String → DateTime
DateTime date = DateTime.parse(json['date'] as String);

// String → bool (JSON boolean)
bool active = json['active'] as bool;

// String → bool (из строки "true"/"false")
bool active = json['active'] == 'true';
```

## Best Practices

- **Использайте `as Type`** для приведения типов — это безопаснее, чем приведение через `as`
- **Обрабатывайте null** — проверяйте наличие ключей и значений
- **Создавайте классы-модели** — не работайте с сырым JSON в UI-слое
- **Используйте `toIso8601String()`** для сериализации DateTime
- **Делайте поля `final`** — модели данных должны быть неизменяемыми
- **Добавляйте `fromJson` и `toJson`** — это стандартный паттерн в Dart
