# Тестирование BLoC и State-менеджеров

Тестирование BLoC и state-менеджеров — важная часть тестирования Flutter-приложений, использующих паттерн BLoC. Поскольку BLoC работает с потоками событий и состояний, для его тестирования используются специфические подходы.

## Основы тестирования BLoC

### Что тестировать в BLoC

| Что тестировать | Описание |
|----------------|----------|
| События | Корректная обработка входных событий |
| Состояния | Правильное переходы между состояниями |
| Ошибки | Обработка ошибок и их передача |
| Зависимости | Взаимодействие с внешними сервисами |

### Структура BLoC для тестирования

```dart
// События
abstract class UserEvent {}
class LoadUsers extends UserEvent {}
class LoadUserById extends UserEvent {
  final int id;
  LoadUserById(this.id);
}
class DeleteUser extends UserEvent {
  final int id;
  DeleteUser(this.id);
}

// Состояния
abstract class UserState {}
class UserInitial extends UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  final List<User> users;
  UserLoaded(this.users);
}
class UserError extends UserState {
  final String message;
  UserError(this.message);
}

// Модель
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

// Репозиторий
abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User> getUserById(int id);
  Future<void> deleteUser(int id);
}

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadUserById>(_onLoadUserById);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final users = await repository.getUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError('Ошибка загрузки: $e'));
    }
  }

  Future<void> _onLoadUserById(
    LoadUserById event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await repository.getUserById(event.id);
      emit(UserLoaded([user]));
    } catch (e) {
      emit(UserError('Ошибка загрузки: $e'));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      await repository.deleteUser(event.id);
      // После удаления — перезагружаем список
      final users = await repository.getUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError('Ошибка удаления: $e'));
    }
  }
}
```

## Тестирование с mocktail

### Настройка тестов

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

// Mock для репозитория
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;
  late UserBloc userBloc;

  setUp(() {
    mockRepository = MockUserRepository();
    userBloc = UserBloc(repository: mockRepository);
  });

  tearDown(() {
    userBloc.close();
  });
}
```

### Тестирование начального состояния

```dart
void main() {
  test('UserBloc должен иметь начальное состояние UserInitial', () {
    expect(userBloc.state, isA<UserInitial>());
  });
}
```

### Тестирование событий с bloc_test

Пакет `bloc_test` предоставляет удобный синтаксис для тестирования BLoC:

```dart
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('UserBloc', () {
    late MockUserRepository mockRepository;
    late UserBloc userBloc;

    setUp(() {
      mockRepository = MockUserRepository();
      userBloc = UserBloc(repository: mockRepository);
    });

    tearDown(() {
      userBloc.close();
    });

    // Тестирование события LoadUsers
    blocTest<UserBloc, UserState>(
      'должен загружать пользователей',
      build: () => userBloc,
      setUp: () {
        when(
          () => mockRepository.getUsers(),
        ).thenAnswer((_) async => [
          User(id: 1, name: 'Иван', email: 'ivan@example.com'),
          User(id: 2, name: 'Мария', email: 'maria@example.com'),
        ]);
      },
      act: (bloc) => bloc.add(LoadUsers()),
      verify: (_) {
        verify(() => mockRepository.getUsers()).called(1);
      },
      expect: () => [
        UserLoading(),
        UserLoaded([
          User(id: 1, name: 'Иван', email: 'ivan@example.com'),
          User(id: 2, name: 'Мария', email: 'maria@example.com'),
        ]),
      ],
    );

    // Тестирование события LoadUserById
    blocTest<UserBloc, UserState>(
      'должен загружать пользователя по ID',
      build: () => userBloc,
      setUp: () {
        when(
          () => mockRepository.getUserById(42),
        ).thenAnswer(
          (_) async => User(id: 42, name: 'Пётр', email: 'petr@example.com'),
        );
      },
      act: (bloc) => bloc.add(LoadUserById(42)),
      expect: () => [
        UserLoading(),
        UserLoaded([
          User(id: 42, name: 'Пётр', email: 'petr@example.com'),
        ]),
      ],
    );
  });
}
```

### Тестирование обработки ошибок

```dart
void main() {
  group('UserBloc — обработка ошибок', () {
    late MockUserRepository mockRepository;
    late UserBloc userBloc;

    setUp(() {
      mockRepository = MockUserRepository();
      userBloc = UserBloc(repository: mockRepository);
    });

    tearDown(() {
      userBloc.close();
    });

    blocTest<UserBloc, UserState>(
      'должен обрабатывать ошибку загрузки',
      build: () => userBloc,
      setUp: () {
        when(
          () => mockRepository.getUsers(),
        ).thenThrow(Exception('Ошибка сети'));
      },
      act: (bloc) => bloc.add(LoadUsers()),
      expect: () => [
        UserLoading(),
        UserError('Ошибка загрузки: Exception: Ошибка сети'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'должен обрабатывать ошибку удаления',
      build: () => userBloc,
      setUp: () {
        when(
          () => mockRepository.deleteUser(any()),
        ).thenThrow(Exception('Не удалось удалить'));
      },
      act: (bloc) => bloc.add(DeleteUser(1)),
      expect: () => [
        UserError('Ошибка удаления: Exception: Не удалось удалить'),
      ],
    );
  });
}
```

## Тестирование с потоками (Streams)

### Ручное тестирование через Stream

```dart
void main() {
  group('UserBloc — ручное тестирование через Stream', () {
    late MockUserRepository mockRepository;
    late UserBloc userBloc;

    setUp(() {
      mockRepository = MockUserRepository();
      userBloc = UserBloc(repository: mockRepository);
    });

    tearDown(() {
      userBloc.close();
    });

    test('должен переходить от Initial к Loaded', () async {
      when(
        () => mockRepository.getUsers(),
      ).thenAnswer((_) async => [
        User(id: 1, name: 'Иван', email: 'ivan@example.com'),
      ]);

      final states = <UserState>[];
      final subscription = userBloc.listen(states.add);

      userBloc.add(LoadUsers());

      // Ждём завершения
      await Future.delayed(Duration(milliseconds: 100));
      await subscription.cancel();

      // Проверяем последовательность состояний
      expect(states, hasLength(2));
      expect(states[0], isA<UserLoading>());
      expect(states[1], isA<UserLoaded>());
    });

    test('должен переходить от Initial к Error', () async {
      when(
        () => mockRepository.getUsers(),
      ).thenThrow(Exception('Ошибка'));

      final states = <UserState>[];
      final subscription = userBloc.listen(states.add);

      userBloc.add(LoadUsers());

      await Future.delayed(Duration(milliseconds: 100));
      await subscription.cancel();

      expect(states, hasLength(2));
      expect(states[0], isA<UserLoading>());
      expect(states[1], isA<UserError>());
    });
  });
}
```

### Тестирование с expectLater

```dart
void main() {
  test('должен ожидать определённое состояние', () async {
    when(
      () => mockRepository.getUsers(),
    ).thenAnswer((_) async => [
      User(id: 1, name: 'Иван', email: 'ivan@example.com'),
    ]);

    userBloc.add(LoadUsers());

    // Ожидаем UserLoading
    await expectLater(
      userBloc,
      emits(isA<UserLoading>()),
    );

    // Ожидаем UserLoaded
    await expectLater(
      userBloc,
      emits(isA<UserLoaded>()),
    );

    // Ожидаем завершение потока
    await expectLater(
      userBloc,
      emitsDone,
    );
  });
}
```

### Тестирование multiple emits

```dart
void main() {
  test('должен emit несколько состояний', () async {
    when(
      () => mockRepository.getUsers(),
    ).thenAnswer((_) async => [
      User(id: 1, name: 'Иван', email: 'ivan@example.com'),
    ]);

    userBloc.add(LoadUsers());

    // Ожидаем последовательность
    await expectLater(
      userBloc,
      emitsInOrder([
        isA<UserLoading>(),
        emitsDone,
      ]),
    );
  });
}
```

## Тестирование State-менеджеров (Provider)

### Тестирование ChangeNotifier

```dart
class CartNotifier extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  double get total => _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  void addItem(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final String name;
  final double price;
  final int quantity;

  CartItem({required this.name, required this.price, required this.quantity});
}
```

### Unit-тесты для ChangeNotifier

```dart
import 'package:test/test.dart';

void main() {
  group('CartNotifier', () {
    late CartNotifier notifier;

    setUp(() {
      notifier = CartNotifier();
    });

    test('должен начинаться с пустой корзины', () {
      expect(notifier.items, isEmpty);
      expect(notifier.total, equals(0.0));
    });

    test('должен добавлять элементы', () {
      notifier.addItem(CartItem(name: 'Яблоко', price: 10.0, quantity: 2));

      expect(notifier.items.length, equals(1));
      expect(notifier.total, equals(20.0));
      expect(notifier.items[0].name, equals('Яблоко'));
    });

    test('должен удалять элементы', () {
      notifier.addItem(CartItem(name: 'Яблоко', price: 10.0, quantity: 2));
      notifier.addItem(CartItem(name: 'Банан', price: 5.0, quantity: 3));

      notifier.removeItem(0);

      expect(notifier.items.length, equals(1));
      expect(notifier.items[0].name, equals('Банан'));
      expect(notifier.total, equals(15.0));
    });

    test('должен очищать корзину', () {
      notifier.addItem(CartItem(name: 'Яблоко', price: 10.0, quantity: 2));
      notifier.clear();

      expect(notifier.items, isEmpty);
      expect(notifier.total, equals(0.0));
    });
  });
}
```

### Widget-тест с ChangeNotifier

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class CartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartNotifier>();

    return Scaffold(
      appBar: AppBar(title: Text('Корзина (${cart.items.length})')),
      body: ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('${item.price} x ${item.quantity}'),
            trailing: Text('${item.price * item.quantity}'),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Итого: ${cart.total}'),
            ElevatedButton(
              onPressed: () {
                context.read<CartNotifier>().clear();
              },
              child: Text('Очистить'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('CartWidget должен отображать корзину',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartNotifier()),
        ],
        child: MaterialApp(home: CartWidget()),
      ),
    );

    // Проверяем начальное состояние
    expect(find.text('Корзина (0)'), findsOneWidget);
    expect(find.text('Итого: 0.0'), findsOneWidget);
  });
}
```

## Тестирование Riverpod

### Тестирование с testing package

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.3
```

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return MockUserRepository();
});

final userProvider = FutureProvider.autoDispose.family<List<User>, int>((ref, id) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUserById(id);
});

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  test('userProvider должен возвращать пользователя', () async {
    final container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWith((ref) => MockUserRepository()),
      ],
    );

    // Настройка mock
    when(
      () => (container.read(userRepositoryProvider) as MockUserRepository)
          .getUserById(any()),
    ).thenAnswer((_) async => [
      User(id: 1, name: 'Иван', email: 'ivan@example.com'),
    ]);

    // Чтение провайдера
    final asyncValue = container.read(userProvider(1));

    expect(asyncValue.hasValue, isTrue);
    expect(asyncValue.valueOrNull!.length, equals(1));

    container.dispose();
  });
}
```

## Лучшие практики

1. **Тестируйте каждый обработчик событий** — отдельный тест на каждое событие
2. **Проверяйте последовательность состояний** — используйте `emitsInOrder`
3. **Моките зависимости** — используйте mock для репозиториев и сервисов
4. **Закрывайте BLoC после тестов** — используйте tearDown для очистки
5. **Тестируйте обработку ошибок** — отдельный тест на каждый сценарий ошибки
6. **Используйте bloc_test** — для более читаемых тестов
7. **Не тестируйте UI в BLoC-тестах** — это задача widget-тестов

## Заключение

Тестирование BLoC требует понимания потоков событий и состояний. Пакет `bloc_test` значительно упрощает написание тестов, предоставляя удобный DSL для проверки событий и состояний. Ручное тестирование через `expectLater` и `emitsInOrder` даёт больше контроля и гибкости.
