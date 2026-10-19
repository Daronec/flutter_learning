# 2.4 Миксины, интерфейсы, абстрактные классы

## Абстрактные классы

### Объявление

```dart
// Абстрактный класс — нельзя создать экземпляр
abstract class Shape {
  double area();
  double perimeter();
}

// Конкретный子类
class Circle extends Shape {
  final double radius;
  
  Circle(this.radius);
  
  @override
  double area() => 3.14159 * radius * radius;
  
  @override
  double perimeter() => 2 * 3.14159 * radius;
}

class Rectangle extends Shape {
  final double width;
  final double height;
  
  Rectangle(this.width, this.height);
  
  @override
  double area() => width * height;
  
  @override
  double perimeter() => 2 * (width + height);
}
```

### Абстрактные методы

```dart
abstract class Database {
  // Абстрактный метод — нет реализации
  void connect();
  
  // Абстрактный метод с типом возвращаемого значения
  List<Map<String, dynamic>> query(String sql);
  
  // Конкретный метод в абстрактном классе
  void disconnect() {
    print('Disconnected');
  }
}
```

## Интерфейсы

### Интерфейсы через abstract class

```dart
// В Dart нет ключевого слова interface
// abstract class автоматически является интерфейсом
abstract class Storage {
  void save(String key, dynamic value);
  dynamic load(String key);
  void delete(String key);
}

// Реализация
class SharedPreferencesStorage implements Storage {
  final Map<String, dynamic> _data = {};
  
  @override
  void save(String key, dynamic value) => _data[key] = value;
  
  @override
  dynamic load(String key) => _data[key];
  
  @override
  void delete(String key) => _data.remove(key);
}
```

### Реализация нескольких интерфейсов

```dart
abstract class Serializable {
  String toJson();
  factory Serializable.fromJson(Map<String, dynamic> json);
}

abstract class Cloneable {
  Object clone();
}

// Несколько интерфейсов
class User implements Serializable, Cloneable {
  final String name;
  
  User(this.name);
  
  @override
  String toJson() => '{"name": "$name"}';
  
  @override
  factory User.fromJson(Map<String, dynamic> json) => User(json['name']);
  
  @override
  User clone() => User(name);
}
```

## Миксины

### Объявление миксина

```dart
// Миксин — способ повторного использования кода
mixin Loggable {
  void log(String message) {
    print('[LOG ${DateTime.now()}] $message');
  }
}

mixin Cacheable {
  final Map<String, dynamic> _cache = {};
  
  void cache(String key, dynamic value) => _cache[key] = value;
  dynamic getCached(String key) => _cache[key];
}
```

### Использование миксинов

```dart
// Один миксин
class UserService with Loggable {
  void createUser(String name) {
    log('Creating user: $name');
  }
}

// Несколько миксинов
class AdvancedService with Loggable, Cacheable {
  void process(String data) {
    log('Processing: $data');
    cache('lastData', data);
  }
}
```

### mixin vs class

| mixin | class |
|---|---|
| `mixin Loggable` | `class Logger` |
| Нельзя создать экземпляр | Можно создать экземпляр |
| `class Service with Loggable` | `class Service extends Logger` |
| Можно использовать с любым классом | Ограничение: один родитель |
| `on SuperClass` — ограничение | Наследование от одного класса |

### mixin с ограничениями

```dart
// Миксин, доступный только для классов с определённым интерфейсом
mixin Cacheable on Serializable {
  void cache(String key, dynamic value);
}

class UserService implements Serializable {
  @override
  void cache(String key, dynamic value) {
    // ...
  }
}
```

## Отличия и когда использовать

### Abstract class vs Interface

В Dart это одно и то же:
```dart
// Это интерфейс
abstract class IStorage {
  void save(String key, dynamic value);
}

// Это абстрактный класс (с реализацией)
abstract class BaseStorage {
  void save(String key, dynamic value);
  
  void close() {
    print('Closing storage'); // Конкретная реализация
  }
}
```

### Когда что использовать

| Ситуация | Используйте |
|---|---|
| Общий интерфейс без реализации | `abstract class` |
| Общий интерфейс с частичной реализацией | `abstract class` |
| Повторное использование поведения | `mixin` |
| Наследование + реализация | `class` |

## Пример: паттерн Repository

```dart
abstract class Repository {
  Future<List<T>> findAll<T>();
  Future<T?> findById<T>(String id);
  Future<void> save<T>(T entity);
}

mixin CacheMixin {
  final Map<String, dynamic> _cache = {};
  
  T? cached<T>(String key, T Function() fetch) {
    return _cache[key] ??= fetch();
  }
}

class UserRepository extends Repository with CacheMixin {
  @override
  Future<List<User>> findAll<User>() async {
    return cached('users', () => _fetchUsers());
  }
}
```

## Заключение

- **Абстрактные классы** — для определения контрактов с возможной реализацией
- **Интерфейсы** — в Dart это `abstract class` без реализации
- **Миксины** — для повторного использования поведения без наследования
- Dart поддерживает множественную реализацию интерфейсов, но только одно наследование
