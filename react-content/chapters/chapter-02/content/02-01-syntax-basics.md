# 2.1 Основы синтаксиса Dart: переменные, типы данных

## Основы синтаксиса

### Точка входа

```dart
void main() {
  print('Hello, Dart!');
}
```

### Комментарии

```dart
// Однострочный комментарий

/* Многострочный
   комментарий */

/// Документирующий комментарий (для dartdoc)
/// Описание метода
int calculate(int a, int b) => a + b;

/** Документирующий многострочный */
```

## Переменные

### Объявление переменных

```dart
// var — вывод типа из значения
var name = 'Flutter';        // String
var age = 25;                 // int
var height = 1.75;            // double
var isActive = true;          // bool

// Явное указание типа
String name = 'Flutter';
int age = 25;
double height = 1.75;
bool isActive = true;

// final — значение вычисляется один раз при инициализации
final String appName = 'MyApp';
final DateTime now = DateTime.now();

// const — компиляционная константа (подтип final)
const String appName = 'MyApp';
const List<int> numbers = [1, 2, 3];
const Map<String, dynamic> config = {'key': 'value'};
```

### var vs final vs const

| Ключевое слово | Когда вычисляется | Можно ли изменить |
|---|---|---|
| `var` | При первом присваивании | Да (если не immutable тип) |
| `final` | При первом присваивании (run-time) | Нет |
| `const` | При компиляции (compile-time) | Нет |

```dart
// final вычисляется в run-time
final String greeting = 'Hello, ' + DateTime.now().year.toString();

// const вычисляется в compile-time
const String greeting = 'Hello';
const int year = 2024;
```

> **Правило**: `const` объект — это `final`, `final` объект — не обязательно `const`.

## Базовые типы данных

### Числа

```dart
// int — целые числа
int age = 25;
int hex = 0xFF;

// double — числа с плавающей точкой
double pi = 3.14159;
double scientific = 1.5e3; // 1500.0

// Преобразование
String numStr = '123';
int num = int.parse(numStr);    // 123
double numD = double.parse('3.14'); // 3.14

int fromDouble = 42.99.toInt(); // 42 (обрезание)
```

### Строки

```dart
// Объявление
String name = 'Flutter';
String greeting = "Hello, World!";

// Интерполяция (вставка выражений)
String user = 'Alice';
int age = 25;
String info = 'User: $user, Age: $age';
String info2 = 'User: ${user.toUpperCase()}, Age: ${age + 1}';

// Многострочные строки
String multiLine = '''
Первая строка
Вторая строка
Третья строка
''';

// Raw strings (без обработки escape-последовательностей)
String raw = r'Не обрабатывать \n \t';
```

### Булев тип

```dart
bool isActive = true;
bool isComplete = false;

// Условные выражения
if (isActive) {
  print('Активно');
}
```

## Коллекции

### List (упорядоченная коллекция)

```dart
// Объявление
List<String> fruits = ['Apple', 'Banana', 'Cherry'];
var numbers = [1, 2, 3]; // Вывод типа: List<int>

// const list
const fruits = ['Apple', 'Banana']; // const List

// Доступ
fruits[0];        // 'Apple'
fruits.length;    // 3
fruits.add('Date');
fruits.remove('Apple');
```

### Set (коллекция уникальных элементов)

```dart
// Объявление
Set<String> fruits = {'Apple', 'Banana', 'Cherry'};
var numbers = {1, 2, 3}; // Вывод типа: Set<int>

// Уникальность
fruits.add('Apple'); // Не добавится, уже существует
fruits.add('Date');  // Добавится
```

### Map (словарь, ключ-значение)

```dart
// Объявление
Map<String, dynamic> user = {
  'name': 'Alice',
  'age': 25,
  'isActive': true,
};

var config = {'key': 'value'}; // Вывод типа: Map<String, dynamic>

// Доступ
user['name'];           // 'Alice'
user['age'] = 26;       // Изменение
user['email'] = 'a@b';  // Добавление
```

## Null Safety

Dart поддерживает null safety с Dart 2.12:

```dart
// Не-null по умолчанию
String name = 'Flutter';   // ✅
String name2;              // ❌ Ошибка! Нужно инициализировать

// Nullable типы (добавляем ?)
String? name = null;       // ✅
String? name = 'Flutter';  // ✅

// Null-assertion (!) — говорим, что точно не null
String? maybeName = getName();
String sureName = maybeName!; // Если null — будет ошибка

// Null-coalescing (??)
String displayName = name ?? 'Anonymous';

// Null-aware operator (?.)
int? length = name?.length; // null если name == null
```

## Типы данных — итоговая таблица

| Тип | Пример | Описание |
|---|---|---|
| `int` | `42`, `-7` | Целые числа 64-бит |
| `double` | `3.14`, `1.5e3` | Числа с плавающей точкой 64-бит |
| `String` | `'Hello'` | UTF-16 строки |
| `bool` | `true`, `false` | Логический тип |
| `List` | `[1, 2, 3]` | Упорядоченная коллекция |
| `Set` | `{1, 2, 3}` | Уникальные элементы |
| `Map` | `{'key': 'val'}` | Пары ключ-значение |
| `dynamic` | `dynamic x = 42;` | Отключение проверки типов |

## Заключение

Dart — строго типизированный язык с null safety, который обеспечивает безопасность и надёжность кода. Понимание базовых типов и переменных — фундамент для работы с Flutter.
