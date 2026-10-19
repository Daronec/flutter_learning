# Clean Architecture в Flutter

## Введение

Clean Architecture — это концепция проектирования приложений, предложенная Робертом Мартином (Uncle Bob). Она разделяет приложение на слои, каждый из которых отвечает за свою зону ответственности, и строго контролирует направление зависимостей.

## Принципы Clean Architecture

### Правило зависимости

> Источники изменений должны зависеть от абстракций, а не наоборот.

В Clean Architecture зависимости направлены **внутрь**, к доменной логике. Внешние слои зависят от внутренних, но не наоборот.

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │  ← UI, виджеты
│  (Widgets, Screens, State Management)   │
├─────────────────────────────────────────┤
│           Domain Layer                  │  ← Бизнес-логика
│  (Entities, Use Cases, Repositories)    │
├─────────────────────────────────────────┤
│           Data Layer                    │  ← Источники данных
│  (Repositories, DTOs, Network, Storage) │
├─────────────────────────────────────────┤
│      External Frameworks & Services     │  ← API, БД, Файлы
└─────────────────────────────────────────┘
```

## Слой Domain (Доменная модель)

Слой domain содержит чистую бизнес-логику. Он **не зависит** ни от одного из внешних слоёв.

### Entities

Сущности — это основные объекты предметной области:

```dart
// domain/entities/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### Use Cases (Сценарии использования)

Каждый use case инкапсулирует одну бизнес-операцию:

```dart
// domain/use_cases/get_user_by_id.dart
import 'package:fpdart/fpdart.dart';
import '../../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUserById {
  final UserRepository repository;

  GetUserById(this.repository);

  Future<Either<Failure, User>> call(String userId) async {
    return await repository.getUserById(userId);
  }
}
```

### Repository Interfaces

Интерфейсы репозиториев объявляются в domain-слое:

```dart
// domain/repositories/user_repository.dart
import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUserById(String id);
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, Unit>> createUser(User user);
}
```

## Слой Data (Данные)

Слой data реализует интерфейсы репозиториев и управляет источниками данных.

### DTO (Data Transfer Object)

```dart
// data/models/user_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      createdAt: entity.createdAt,
    );
  }
}
```

### Реализация репозитория

```dart
// data/repositories/user_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/failures/failure.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource datasource;

  UserRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, User>> getUserById(String id) async {
    try {
      final userModel = await datasource.fetchUserById(id);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      final users = await datasource.fetchAllUsers();
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> createUser(User user) async {
    try {
      await datasource.createUser(user);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

## Слой Presentation (Презентация)

Слой presentation содержит виджеты и управляет состоянием UI.

### Блок (Bloc)

```dart
// presentation/blocs/user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/use_cases/get_user_by_id.dart';
import '../../domain/failures/failure.dart';

// Events
abstract class UserEvent {}
class LoadUserById extends UserEvent {
  final String userId;
  LoadUserById(this.userId);
}

// States
abstract class UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  final User user;
  UserLoaded(this.user);
}
class UserError extends UserState {
  final Failure failure;
  UserError(this.failure);
}

// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserById getUserById;

  UserBloc({required this.getUserById}) : super(UserLoading()) {
    on<LoadUserById>(_onLoadUser);
  }

  Future<void> _onLoadUser(
    LoadUserById event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await getUserById(event.userId);
    emit(result.fold(
      (failure) => UserError(failure),
      (user) => UserLoaded(user),
    ));
  }
}
```

### Виджет

```dart
// presentation/widgets/user_card.dart
class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(user.email),
          ],
        ),
      ),
    );
  }
}
```

## Сравнение слоёв

| Слой | Зависит от | Содержит | Зависимости от внешних |
|------|-----------|----------|----------------------|
| Domain | Ничего | Entities, Use Cases, Interfaces | Нет |
| Data | Domain | Реализации репозиториев, DTO, DataSource | Да (API, БД) |
| Presentation | Domain | Виджеты, BLoCs, State | Да (UI-фреймворки) |

## Преимущества Clean Architecture

- **Тестируемость** — доменный слой тестируется без UI и зависимостей
- **Независимость от фреймворков** — бизнес-логика не привязана к Flutter
- **Независимость от UI** — UI можно заменить без изменения логики
- **Независимость от баз данных** — можно менять БД без изменения domain
- **Независимость от внешних сервисов** — API можно заменить изолированно

## Недостатки

- Высокий порог входа для новых разработчиков
- Большое количество файлов и классов
- Избыточность для небольших проектов

## Лучшие практики

1. **Начинайте с domain-слоя** — определите сущности и use cases
2. **Используйте Either/Result** для обработки ошибок
3. **Один use case — одна операция**
4. **Не допускайте утечки DTO в domain**
5. **Используйте генерацию кода** для DTO (json_serializable, freezed)
6. **Регулярно проверяйте направление зависимостей**
