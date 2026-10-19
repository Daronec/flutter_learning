# Integration tests — end-to-end тестирование

Integration tests (интеграционные тесты) — это тесты, которые запускаются на реальном устройстве или эмуляторе и проверяют всё приложение целиком. Они тестируют пользовательские сценарии от начала до конца.

## Что такое integration tests

Integration tests запускают реальное приложение на эмуляторе или устройстве и взаимодействуют с ним так, как это делает пользователь: нажимает кнопки, вводит текст, скроллит экраны.

### Когда использовать

| Ситуация | Подходит |
|----------|----------|
| Ключевой пользовательский сценарий | Да |
| Навигация между экранами | Да |
| Работа с API | Да |
| Сложные анимации | Да |
| Простая бизнес-логика | Нет (unit-тест) |
| Отдельный виджет | Нет (widget-тест) |

## Установка и настройка

### Добавление зависимости

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

### Создание структуры тестов

```
test_driver/
  integration_test.dart
integration_test/
  app_test.dart
  login_test.dart
  checkout_test.dart
```

### Настройка integration_test

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart';

void main() {
  // Инициализация binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end тесты', () {
    testWidgets('Пользователь может войти в приложение',
        (WidgetTester tester) async {
      // Запускаем приложение
      pumpWidget(const MyApp());

      // Ждём полной инициализации
      await tester.pumpAndSettle();

      // Тестовый код...
    });
  });
}
```

## Запуск integration tests

### На эмуляторе

```bash
# Запуск на подключённом устройстве или эмуляторе
flutter test integration_test/app_test.dart

# Запуск на конкретном устройстве
flutter test integration_test/app_test.dart -d emulator-5554

# Запуск на iOS симуляторе
flutter test integration_test/app_test.dart -d iPhone

# Запуск на Android эмуляторе
flutter test integration_test/app_test.dart -d emulator
```

### На реальных устройствах

```bash
# На подключённом Android устройстве
flutter test integration_test/app_test.dart -d <device_id>

# На подключённом iOS устройстве
flutter test integration_test/app_test.dart -d <device_id>
```

## Базовый пример integration test

### Простой тест входа

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart';
import 'package:my_app/screens/login_screen.dart';
import 'package:my_app/screens/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Интеграционные тесты', () {
    testWidgets('Пользователь может войти в приложение',
        (WidgetTester tester) async {
      // Запускаем приложение
      await tester.pumpWidget(const MyApp());

      // Ждём полной загрузки
      await tester.pumpAndSettle();

      // Проверяем, что видим экран входа
      expect(find.text('Вход'), findsOneWidget);

      // Вводим email
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.pump();

      // Вводим пароль
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.pump();

      // Нажимаем кнопку входа
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      // Проверяем, что попали на главный экран
      expect(find.text('Главная'), findsOneWidget);
    });
  });
}
```

### Тест регистрации

```dart
void main() {
  group('Регистрация', () {
    testWidgets('Пользователь может зарегистрироваться',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Переходим на экран регистрации
      expect(find.text('Войти'), findsOneWidget);
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      expect(find.text('Зарегистрироваться'), findsOneWidget);

      // Заполняем форму регистрации
      await tester.enterText(
        find.byKey(const Key('name_field')),
        'Иван Иванов',
      );
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'ivan@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'password123',
      );
      await tester.pump();

      // Нажимаем кнопку регистрации
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();

      // Проверяем, что попали на главный экран
      expect(find.text('Главная'), findsOneWidget);
    });

    testWidgets('должна показывать ошибку при несовпадении паролей',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'different123',
      );
      await tester.pump();

      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();

      // Проверяем сообщение об ошибке
      expect(find.text('Пароли не совпадают'), findsOneWidget);
    });
  });
}
```

## Тестирование навигации

### Тест многостраничного сценария

```dart
void main() {
  group('Навигация', () {
    testWidgets('Полный путь: Вход → Главная → Профиль',
        (WidgetTester tester) async {
      // 1. Экран входа
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Вход'), findsOneWidget);

      // 2. Вход в приложение
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();

      // 3. Главный экран
      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
      expect(find.text('Настройки'), findsOneWidget);

      // 4. Переход на экран профиля
      await tester.tap(find.text('Профиль'));
      await tester.pumpAndSettle();

      // 5. Экран профиля
      expect(find.text('Мой профиль'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);

      // 6. Возврат на главный экран
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Главная'), findsOneWidget);
    });
  });
}
```

## Тестирование работы с API

### Тест с реальным API

```dart
void main() {
  group('Работа с API', () {
    testWidgets('Пользователь может загрузить список товаров',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Ждём загрузки товаров
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Проверяем, что товары отображаются
      expect(find.byType(ListTile), findsWidgets);
      expect(find.byType(ListTile), findsNWidgets(greaterThan(0)));

      // Проверяем, что есть хотя бы один товар
      final firstProduct = find.byType(ListTile).first;
      expect(firstProduct, findsOneWidget);
    });

    testWidgets('Пользователь может добавить товар в корзину',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Находим первую кнопку "В корзину"
      final addButton = find.text('В корзину').first;
      expect(addButton, findsOneWidget);

      // Нажимаем
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Проверяем, что счётчик корзины увеличился
      expect(find.textContaining('Корзина (1)'), findsOneWidget);
    });
  });
}
```

### Тест с обработкой ошибок

```dart
void main() {
  group('Обработка ошибок API', () {
    testWidgets('должен показывать ошибку при отсутствии сети',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Имитируем отсутствие сети (через эмулятор)
      // Или ждём таймаута
      await tester.pumpAndSettle(Duration(seconds: 10));

      // Проверяем сообщение об ошибке
      expect(
        find.textContaining('Ошибка'),
        findsOneWidget,
      );
    });
  });
}
```

## Тестирование форм

### Тест многоступенчатой формы

```dart
void main() {
  group('Многоступенчатая форма', () {
    testWidgets('Пользователь может заполнить форму заказа',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Шаг 1: Данные доставки
      expect(find.text('Данные доставки'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('address_field')),
        'ул. Пушкина, д. 10',
      );
      await tester.enterText(
        find.byKey(const Key('city_field')),
        'Москва',
      );
      await tester.enterText(
        find.byKey(const Key('zip_field')),
        '101000',
      );
      await tester.tap(find.text('Далее'));
      await tester.pumpAndSettle();

      // Шаг 2: Способ оплаты
      expect(find.text('Способ оплаты'), findsOneWidget);
      await tester.tap(find.text('Банковская карта'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('card_number_field')),
        '4111111111111111',
      );
      await tester.enterText(
        find.byKey(const Key('expiry_field')),
        '12/25',
      );
      await tester.enterText(
        find.byKey(const Key('cvv_field')),
        '123',
      );
      await tester.tap(find.text('Оплатить'));
      await tester.pumpAndSettle();

      // Шаг 3: Подтверждение
      expect(find.text('Заказ оформлен'), findsOneWidget);
    });
  });
}
```

## Тестирование анимаций

### Тест с анимациями

```dart
void main() {
  group('Анимации', () {
    testWidgets('Анимация перехода между экранами',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Нажимаем кнопку перехода
      await tester.tap(find.text('Перейти'));
      await tester.pump();

      // Во время анимации оба экрана видны
      expect(find.text('Старый экран'), findsOneWidget);
      expect(find.text('Новый экран'), findsOneWidget);

      // После анимации
      await tester.pumpAndSettle();
      expect(find.text('Старый экран'), findsNothing);
      expect(find.text('Новый экран'), findsOneWidget);
    });
  });
}
```

## Использование драйверов

### Custom driver

```dart
// integration_test/driver.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/main.dart';

/// Расширение для удобного взаимодействия с приложением
extension AppDriver on WidgetTester {
  /// Войти в приложение
  Future<void> login(String email, String password) async {
    await enterText(
      find.byKey(const Key('email_field')),
      email,
    );
    await enterText(
      find.byKey(const Key('password_field')),
      password,
    );
    await tap(find.text('Войти'));
    await pumpAndSettle();
  }

  /// Перейти на экран профиля
  Future<void> goToProfile() async {
    await tap(find.text('Профиль'));
    await pumpAndSettle();
  }

  /// Перейти на экран настроек
  Future<void> goToSettings() async {
    await tap(find.text('Настройки'));
    await pumpAndSettle();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Тесты с драйвером', () {
    testWidgets('Полный пользовательский сценарий',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Используем драйвер
      await tester.login('test@example.com', 'password123');
      expect(find.text('Главная'), findsOneWidget);

      await tester.goToProfile();
      expect(find.text('Мой профиль'), findsOneWidget);

      await tester.goToSettings();
      expect(find.text('Настройки'), findsOneWidget);
    });
  });
}
```

## Тестирование pull-to-refresh

```dart
void main() {
  group('Pull-to-refresh', () {
    testWidgets('Пользователь может обновить список',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Находим список
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Свайпаем вниз для обновления
      await tester.drag(
        listView,
        const Offset(0, 200),
      );
      await tester.pumpAndSettle();

      // Проверяем, что список обновился
      expect(find.byType(ListTile), findsWidgets);
    });
  });
}
```

## Тестирование диалогов

```dart
void main() {
  group('Диалоги', () {
    testWidgets('Пользователь может подтвердить удаление',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Нажимаем кнопку удаления
      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();

      // Проверяем диалог подтверждения
      expect(find.text('Подтверждение'), findsOneWidget);
      expect(find.text('Вы уверены?'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);

      // Подтверждаем
      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();

      // Проверяем, что элемент удалён
      expect(find.text('Элемент'), findsNothing);
    });
  });
}
```

## Лучшие практики

1. **Тестируйте пользовательские сценарии** — то, что делает реальный пользователь
2. **Используйте pumpAndSettle** — дожидайтесь завершения всех анимаций
3. **Используйте Key для поиска** — это надёжнее, чем поиск по тексту
4. **Изолируйте тесты** — каждый тест должен быть независимым
5. **Не тестируйте то, что уже протестировано** — unit и widget тесты
6. **Добавляйте таймауты** — для медленных операций (API запросы)
7. **Используйте драйверы** — для переиспользуемого кода взаимодействия
8. **Тестируйте на эмуляторе** — для стабильности результатов

## Структура integration tests

```
integration_test/
  app_test.dart           # Главный тест приложения
  login_test.dart         # Тесты входа
  registration_test.dart  # Тесты регистрации
  checkout_test.dart      # Тесты оформления заказа
  profile_test.dart       # Тесты профиля
  settings_test.dart      # Тесты настроек
```

## Заключение

Integration tests — это последний уровень в пирамиде тестирования. Они медленные, но проверяют всё приложение целиком на реальном устройстве. Используйте их для критических пользовательских сценариев и не переусердствуйте — их должно быть мало, но они должны быть надёжными.
