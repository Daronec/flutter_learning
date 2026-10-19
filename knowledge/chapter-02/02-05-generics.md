# 2.5 Generics (обобщённое программирование)

## Что такое Generics?

Generics — это механизм создания классов, функций и методов, которые работают с любыми типами данных, обеспечивая при этом типобезопасность.

## Базовое использование

### Generics в классах

```dart
// Обобщённый класс
class Container<T> {
  T value;
  
  Container(this.value);
  
  T get() => value;
  void set(T newValue) => value = newValue;
}

// Использование
var intContainer = Container<int>(42);
var strContainer = Container<String>('Hello');

// Вывод типа (type inference)
var numberContainer = Container(42); // Container<int>
```

### Generics в функциях

```dart
// Обобщённая функция
T firstElement<T>(List<T> list) {
  return list.first;
}

// Использование
int first = firstElement<int>([1, 2, 3]); // 1
String first = firstElement(['a', 'b', 'c']); // 'a'

// Вывод типа
var first = firstElement([1, 2, 3]); // int
```

### Generics в колбэках

```dart
class Result<T> {
  final T? data;
  final String? error;
  
  Result.success(this.data) : error = null;
  Result.error(this.error) : data = null;
  
  bool get isSuccess => error == null;
  bool get isError => error != null;
}

// Использование
Result<User> result = Result.success(User('Alice'));
if (result.isSuccess) {
  print(result.data!.name);
}
```

## Ограничения Generics

### extends

```dart
// T должен быть subtype of num
class NumberContainer<T extends num> {
  T value;
  
  NumberContainer(this.value);
  
  bool isPositive() => value > 0;
}

// ✅
var nc = NumberContainer<int>(42);
var nc2 = NumberContainer<double>(3.14);

// ❌ Ошибка!
// var nc3 = NumberContainer<String>('text');
```

### with (mixins)

```dart
mixin Loggable {
  void log(String msg) => print(msg);
}

// T должен поддерживать миксин Loggable
class Observable<T extends Object with Loggable> {
  T value;
  
  Observable(this.value) {
    log('Created with: $value');
  }
}
```

### Multiple bounds

```dart
// Несколько ограничений
class BoundedContainer<T extends Comparable<T> & Cloneable> {
  T value;
  
  BoundedContainer(this.value);
  
  T clone() => value.clone();
}
```

## Generics в коллекциях

### List, Map, Set

```dart
// Типизированные коллекции
List<String> names = ['Alice', 'Bob'];
Map<String, int> ages = {'Alice': 25, 'Bob': 30};
Set<String> uniqueNames = {'Alice', 'Bob'};

// Методы коллекций с generics
names.map((name) => name.toUpperCase()).toList();
ages.entries.where((e) => e.value > 24).toList();
```

### whereType

```dart
var mixed = [1, 'hello', 2, 'world', 3];

// Фильтрация по типу
List<int> ints = mixed.whereType<int>().toList();    // [1, 2, 3]
List<String> strings = mixed.whereType<String>().toList(); // ['hello', 'world']
```

## Covariance и invariant

### List<E> — invariant

```dart
List<num> numbers = [1, 2, 3];
List<int> ints = [1, 2, 3];

// ❌ Ошибка! List<num> ≠ List<int>
// numbers = ints; 

// ✅ Безопасно — создаём новый список
List<num> fromInts = ints.cast<num>();
```

### cast и as

```dart
List<dynamic> mixed = [1, 'hello', 2.5];

// Приведение типа
List<int> asInts = mixed.cast<int>(); // Ошибка если есть не-int

// Безопасное приведение
List<int> safeInts = mixed.whereType<int>().toList();
```

## Generics и Flutter

### Generic виджеты

```dart
// Generic виджет
class CardWidget<T> extends StatelessWidget {
  final T data;
  final Widget Function(T data) builder;
  
  const CardWidget({
    required this.data,
    required this.builder,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: builder(data),
    );
  }
}

// Использование
CardWidget<User>(
  data: user,
  builder: (user) => Text(user.name),
)
```

### Generic State

```dart
class StatefulCard<T> extends StatefulWidget {
  final T initialData;
  
  const StatefulCard({required this.initialData, super.key});
  
  @override
  State<StatefulCard<T>> createState() => _StatefulCardState<T>();
}

class _StatefulCardState<T> extends State<StatefulCard<T>> {
  T? data;
  
  @override
  void initState() {
    super.initState();
    data = widget.initialData;
  }
}
```

## Null-safe Generics

```dart
// Nullable generic type
Container<String?>? nullableContainer;

// Non-nullable by default
Container<String> container = Container('Hello');

// Generic с nullable
Result<User?> result = Result.success(null);
```

## Итоговая таблица

| Синтаксис | Описание | Пример |
|---|---|---|
| `class C<T>` | Обобщённый класс | `Container<T>` |
| `T func<T>()` | Обобщённая функция | `firstElement<T>` |
| `T extends Type` | Ограничение | `T extends num` |
| `T with Mixin` | Ограничение миксином | `T with Loggable` |
| `cast<T>()` | Приведение коллекции | `list.cast<int>()` |

## Заключение

Generics обеспечивают типобезопасность и переиспользование кода. Понимание ограничений, covariance и null-safe generics — ключ к написанию качественного обобщённого кода в Dart.
