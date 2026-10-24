---
tags:
  - api
  - http
  - networking
chapter: 9
section: 6
title: Автоматизация сериализации: json_serializable и freezed
alias: 09 06 codegen
status: complete
---

# Автоматизация сериализации: json_serializable и freezed

Вместо ручной написания `fromJson` и `toJson` можно использовать инструменты автоматической генерации кода. Это экономит время и уменьшает количество ошибок.

## json_serializable

### Установка

```yaml
dependencies:
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
```

```bash
flutter pub get
flutter pub run build_runner build
```

### Базовое использование

```dart
import 'package:json_annotation/json_annotation.dart';

// Указываем файл, куда будет генерироваться код
part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  // Генерируется автоматически: factory User.fromJson(...)
  // Генерируется автоматически: Map<String, dynamic> toJson()

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

### Генерация кода

После запуска `build_runner` создаётся файл `user.g.dart`:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
```

### Аннотации

```dart
@JsonSerializable(explicitToJson: true)
class User {
  final int id;
  final String name;
  final Address? address; // Вложенный объект

  User({required this.id, required this.name, this.address});

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Address {
  final String city;
  final String street;

  Address({required this.city, required this.street});

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
```

### Переименование полей

```dart
@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final int userId;       // → userId в JSON
  final String firstName; // → first_name в JSON
  final String lastName;  // → last_name в JSON
}

// Или ручное переименование
@JsonSerializable()
class User {
  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'first_name')
  final String firstName;

  User({required this.userId, required this.firstName});

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

### Работа с null и значениями по умолчанию

```dart
@JsonSerializable()
class User {
  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(defaultValue: 0)
  final int age;

  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;

  @JsonKey(fromJson: _parseNullableInt, toJson: _serializeNullableInt)
  final int? optionalField;

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    return value as int;
  }

  static int? _serializeNullableInt(int? value) => value;
}
```

## freezed

freezed — это пакет для создания data-классов с поддержкой pattern matching, copyWith и автоматической генерации `==`, `hashCode` и `toString`.

### Установка

```yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
```

### Базовый data-класс

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
}
```

### Использование copyWith

```dart
// Создание объекта
const user = User(id: 1, name: 'Иван', email: 'ivan@example.com');

// Копирование с изменением одного поля
final updatedUser = user.copyWith(name: 'Иван Петров');

// Копирование с изменением нескольких полей
final updatedUser2 = user.copyWith(
  name: 'Новое имя',
  email: 'new@example.com',
);
```

### Union types (sealed classes)

```dart
@freezed
class NetworkState<T> with _$NetworkState<T> {
  const factory NetworkState.loading() = Loading;
  const factory NetworkState.success(T data) = Success;
  const factory NetworkState.error(String message) = Error;
}

// Pattern matching
networkState.when(
  loading: () => const CircularProgressIndicator(),
  success: (data) => Text(data.toString()),
  error: (message) => Text('Ошибка: $message'),
);

// Или через when
final result = networkState.when(
  loading: () => 'Загрузка...',
  success: (data) => 'Данные: $data',
  error: (message) => 'Ошибка: $message',
);
```

### Optional parameters с freezed

```dart
@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
    String? email,
    int? age,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
}

// Использование
const user = User(id: 1, name: 'Иван'); // email и age — null
const user2 = User(id: 2, name: 'Мария', email: 'maria@example.com');
```

### Inheritance (наследование)

```dart
@freezed
class ApiResponse with _$ApiResponse {
  const factory ApiResponse.success(Map<String, dynamic> data) = SuccessResponse;
  const factory ApiResponse.error({
    required int code,
    required String message,
  }) = ErrorResponse;

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);
}
```

## build_runner

### Команды

| Команда | Описание |
|---------|----------|
| `flutter pub run build_runner build` | Генерация кода для production |
| `flutter pub run build_runner watch` | Автоматическая генерация при изменении файлов |
| `flutter pub run build_runner clean` | Очистка сгенерированных файлов |
| `flutter pub run build_runner build --delete-conflicting-outputs` | Принудительная генерация |

### Типичный workflow

```bash
# 1. Установить зависимости
flutter pub get

# 2. Запустить генерацию кода
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Для разработки — запуск в режиме watch
flutter pub run build_runner watch
```

### Структура сгенерированных файлов

| Файл | Генерируется |
|------|-------------|
| `*.g.dart` | json_serializable (fromJson/toJson) |
| `*.freezed.dart` | freezed (copyWith, when, pattern matching) |

## Best Practices

- **Используйте `build_runner watch`** в разработке — код генерируется автоматически
- **Добавляйте `*.g.dart` и `*.freezed.dart` в `.gitignore`** — эти файлы генерируются
- **Используйте `freezed` для UI-состояний** — loading/success/error паттерн
- **Используйте `json_serializable` для моделей данных** — автоматическая сериализация
- **Используйте `fieldRename: FieldRename.snake`** — для соответствия snake_case API
- **Добавляйте `explicitToJson: true`** — для вложенных объектов
