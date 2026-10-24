---
tags:
  - storage
  - database
  - local
chapter: 10
section: 3
title: Drift (formerly Moor) — типобезопасная работа с БД
alias: 10 03 drift
status: complete
---

# Drift (formerly Moor) — типобезопасная работа с БД

Drift (ранее известный как Moor) — это типобезопасная библиотека для работы с SQLite в Dart/Flutter. Она генерирует код на основе объявлений таблиц и предоставляет удобный API для запросов.

## Установка

```yaml
dependencies:
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0

dev_dependencies:
  drift_dev: ^2.14.0
  build_runner: ^2.4.8
```

```bash
flutter pub add drift sqlite3_flutter_libs
flutter pub add --dev drift_dev build_runner
```

## Инициализация базы данных

### Создание подключения

```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'database.g.dart';

// Определение подключения
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          // Миграции при необходимости
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
```

## Определение таблиц

### Таблица с данными

```dart
// Определение таблицы
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().unique()();
  IntColumn get age => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Таблица задач
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get userId => integer().references(Users, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Регистрация таблиц в базе данных
@DriftDatabase(tables: [Users, Tasks])
class $AppDatabase {
  $AppDatabase(super.e);
}
```

### Генерация кода

```bash
flutter pub run build_runner build
```

После генерации будет создан файл `database.g.dart` с реализацией базы данных.

## CRUD-операции

### Создание записей

```dart
// Вставка одной записи
final db = AppDatabase();

final userId = await db.into(db.users).insert(
  UsersCompanion.insert(
    name: 'Иван Петров',
    email: 'ivan@example.com',
    age: const Value(25),
  ),
);

// Вставка с nullable полем
final userId2 = await db.into(db.users).insert(
  UsersCompanion.insert(
    name: 'Мария',
    email: 'maria@example.com',
    // age не указан — будет NULL
  ),
);
```

### Чтение записей

```dart
// Получить все записи
final allUsers = await db.select(db.users).get();

// Получить одну запись
final user = await (db.select(db.users)
  ..where((u) => u.id.equals(userId)))
  .getSingle();

// Запрос с условием
final adults = await (db.select(db.users)
  ..where((u) => u.age!.isBiggerOrEqualValue(18)))
  .orderBy([(u) => OrderingTerm.desc(u.name)])
  .get();

// Запрос с пагинацией
final paginatedUsers = await (db.select(db.users)
  ..limit(20, offset: 40))
  .get();

// Запрос с JOIN
final usersWithTasks = await db.select(db.users).join([
  leftOuterJoin(db.tasks, db.tasks.userId.equalsExp(db.users.id)),
]).get();

// Результат JOIN
for (final row in usersWithTasks) {
  final user = row.readTable(db.users);
  final task = row.readTableOrNull(db.tasks);
  print('${user.name}: ${task?.title ?? "Нет задач"}');
}
```

### Обновление записей

```dart
// Обновить запись
await (db.update(db.users)
  ..where((u) => u.id.equals(userId)))
  .write(
    UsersCompanion(
      name: Value('Новое имя'),
      age: const Value(26),
    ),
  );

// Обновить одно поле
await (db.update(db.users)
  ..where((u) => u.id.equals(userId)))
  .write(
    UsersCompanion(name: Value('Обновлённое имя')),
  );
```

### Удаление записей

```dart
// Удалить по ID
await (db.delete(db.users)
  ..where((u) => u.id.equals(userId)))
  .go();

// Удалить все записи
await db.delete(db.users).go();

// Удалить с условием
await (db.delete(db.tasks)
  ..where((t) => t.isDone.equals(true)))
  .go();
```

## Продвинутые запросы

### Raw SQL запросы

```dart
// Raw SQL
final results = await db.customSelect(
  'SELECT * FROM users WHERE age > ?',
  variables: [Variable.withInt(18)],
  reads: {db.users},
);

for (final row in results.rows) {
  final user = db.users.map(row.data);
  print(user.name);
}
```

### Агрегации

```dart
// Подсчёт записей
final count = await (db.select(db.users)
  ..select([db.users.name]))
  .map((row) => row.read(db.users.name))
  .get()
  .then((rows) => rows.length);

// AVG, SUM, MAX
final result = await db.select(db.users).map(
  (row) => {
    'avgAge': db.users.age.avg(),
    'maxAge': db.users.age.max(),
  },
).getSingle();
```

### Транзакции

```dart
await db.transaction(() async {
  final userId = await db.into(db.users).insert(
    UsersCompanion.insert(
      name: 'Алексей',
      email: 'alex@example.com',
    ),
  );

  await db.into(db.tasks).insertAll([
    TasksCompanion.insert(
      title: 'Задача 1',
      userId: Value(userId),
    ),
    TasksCompanion.insert(
      title: 'Задача 2',
      userId: Value(userId),
    ),
  ]);
});
```

## Работа с моделями

### Использование с моделями

```dart
class User {
  final int id;
  final String name;
  final String email;
  final int? age;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    required this.createdAt,
  });

  factory User.fromDb(UsersData data) {
    return User(
      id: data.id,
      name: data.name,
      email: data.email,
      age: data.age,
      createdAt: data.createdAt,
    );
  }
}

// Запрос с преобразованием
final users = await db.select(db.users).map(
  (row) => User.fromDb(row.readTable(db.users)),
).get();
```

## Best Practices

- **Используйте `Companion`** для вставки и обновления — это типобезопасно
- **Используйте `Value()`** для явного указания nullable полей
- **Используйте `LazyDatabase`** для ленивой загрузки БД
- **Генерируйте код через `build_runner`** — не редактируйте `.g.dart` вручную
- **Используйте `join()`** для сложных запросов вместо raw SQL
- **Версионируйте схему** — используйте `schemaVersion` и `MigrationStrategy`
