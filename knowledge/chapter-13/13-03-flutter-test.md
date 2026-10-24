---
tags:
  - testing
  - unit-tests
  - widget-tests
chapter: 13
section: 3
title: Пакет flutter_test — тестирование виджетов
alias: 13 03 flutter test
status: complete
---

# Пакет flutter_test — тестирование виджетов

Пакет `flutter_test` — это специализированный фреймворк для тестирования виджетов в Flutter. Он предоставляет инструменты для создания, рендеринга и взаимодействия с виджетами в изолированной тестовой среде.

## Установка и настройка

### Зависимость

Пакет `flutter_test` идёт вместе с Flutter SDK, поэтому его не нужно добавлять отдельно в `pubspec.yaml`:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
```

### Импорт

```dart
import 'package:flutter_test/flutter_test.dart';
```

##_binding_ для тестирования

Перед написанием widget-тестов необходимо инициализировать binding:

```dart
void main() {
  // Инициализация binding для тестирования виджетов
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Пример теста', (WidgetTester tester) async {
    // Тестовый код
  });
}
```

В большинстве случаев `ensureInitialized()` вызывается автоматически, но для некоторых случаев (например, при использовании плагинов) может потребоваться явный вызов.

## pumpWidget — основа тестирования виджетов

Метод `pumpWidget` — это ключевой метод для запуска виджетов в тестовой среде:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class GreetingWidget extends StatelessWidget {
  final String name;

  const GreetingWidget({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Привет, $name!'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('GreetingWidget должен отображать приветствие',
      (WidgetTester tester) async {
    // Запускаем виджет в тестовой среде
    await tester.pumpWidget(const GreetingWidget(name: 'Иван'));

    // Проверяем, что текст отображается
    expect(find.text('Привет, Иван!'), findsOneWidget);
  });
}
```

## Работа с состоянием (StatefulWidget)

### Тестирование StatefulWidget

```dart
class PasswordField extends StatefulWidget {
  final String hintText;

  const PasswordField({super.key = const Key('password_field'), required this.hintText});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late TextEditingController _controller;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          obscureText: _isObscured,
          decoration: InputDecoration(hintText: widget.hintText),
        ),
        IconButton(
          key: const Key('toggle_visibility'),
          icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

void main() {
  group('PasswordField', () {
    testWidgets('должен скрывать пароль по умолчанию',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PasswordField(hintText: 'Введите пароль')),
        ),
      );

      // Поле должно быть obscured
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('должен показывать пароль при нажатии на иконку',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PasswordField(hintText: 'Введите пароль')),
        ),
      );

      // Нажимаем на кнопку видимости
      await tester.tap(find.byKey(const Key('toggle_visibility')));
      await tester.pump();

      // Поле должно быть не obscured
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isFalse);
    });
  });
}
```

## pump и pumpAndSettle

### Разница между pump методами

| Метод | Описание | Когда использовать |
|-------|----------|-------------------|
| `pump()` | Один кадр рендеринга | Простые изменения |
| `pump(Duration)` | Рендеринг с задержкой | Анимации, таймеры |
| `pumpAndSettle()` | До остановки всех анимаций | Сложные анимации, переходы |
| `pumpWidget()` | Запуск нового дерева виджетов | Инициализация виджета |

### Примеры использования

```dart
void main() {
  testWidgets('pump — простой тест', (WidgetTester tester) async {
    await tester.pumpWidget(const Text('Hello'));
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('pump с задержкой — таймер', (WidgetTester tester) async {
    await tester.pumpWidget(const Text('Hello'));
    expect(find.text('Hello'), findsOneWidget);

    // Переходим на 2 секунды вперёд
    await tester.pump(const Duration(seconds: 2));
    // Виджет всё ещё существует
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('pumpAndSettle — анимация', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedOpacity(
              opacity: 0.0,
              duration: Duration(seconds: 2),
              child: const Text('Появляюсь'),
            ),
          ),
        ),
      ),
    );

    // Анимация началась
    expect(find.text('Появляюсь'), findsOneWidget);

    // Ждём завершения анимации
    await tester.pumpAndSettle();

    // Анимация завершена
    final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(opacity.opacity, equals(1.0));
  });
}
```

## Работа с анимациями

### Тестирование AnimatedWidget

```dart
class AnimatedCounter extends StatefulWidget {
  final int targetValue;

  const AnimatedCounter({super.key, required this.targetValue});

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _animation = IntTween(begin: 0, end: widget.targetValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text('${_animation.value}');
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

void main() {
  testWidgets('AnimatedCounter должен анимировать счётчик',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AnimatedCounter(targetValue: 10));

    // Начальное значение
    expect(find.text('0'), findsOneWidget);

    // Половина анимации
    await tester.pump(Duration(milliseconds: 500));
    expect(find.textContaining('5'), findsOneWidget);

    // Завершение анимации
    await tester.pumpAndSettle();
    expect(find.text('10'), findsOneWidget);
  });
}
```

## Тестирование навигации

### Тестирование Navigator

```dart
class LoginPage extends StatelessWidget {
  final VoidCallback onLogin;

  const LoginPage({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Center(
        child: ElevatedButton(
          onPressed: onLogin,
          child: const Text('Войти'),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: const Center(child: Text('Добро пожаловать!')),
    );
  }
}

void main() {
  testWidgets('LoginPage должен переходить на HomePage',
      (WidgetTester tester) async {
    // Запускаем приложение с LoginPage
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          onLogin: () {
            Navigator.of(tester.element(find.byType(LoginPage))).push(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
      ),
    );

    // Проверяем LoginPage
    expect(find.text('Вход'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);

    // Нажимаем кнопку
    await tester.tap(find.text('Войти'));
    await tester.pumpAndSettle();

    // Проверяем HomePage
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Добро пожаловать!'), findsOneWidget);
  });
}
```

## Тестирование форм

### Тестирование TextFormField

```dart
class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool get _isValid {
    return _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  if (!value.contains('@')) {
                    return 'Неверный email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 6) {
                    return 'Минимум 6 символов';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _isValid ? () {} : null,
                child: const Text('Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

void main() {
  group('RegistrationForm', () {
    testWidgets('должен показывать валидацию email',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RegistrationForm());

      // Вводим невалидный email
      await tester.enterText(find.byType(TextFormField).first, 'не_email');
      await tester.pump();

      // Нажимаем кнопку (неактивна из-за валидации)
      final button = find.text('Зарегистрироваться');
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
    });

    testWidgets('должен принимать валидные данные',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RegistrationForm());

      // Вводим валидные данные
      await tester.enterText(find.byType(TextFormField).first, 'test@mail.com');
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.pump();

      // Кнопка должна быть активной
      final button = find.text('Зарегистрироваться');
      expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
    });
  });
}
```

## Тестирование диалогов

```dart
void main() {
  testWidgets('должен показывать диалог подтверждения',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: tester.element(find.byType(Scaffold)),
                  builder: (context) => AlertDialog(
                    title: const Text('Подтверждение'),
                    content: const Text('Вы уверены?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Показать диалог'),
            ),
          ),
        ),
      ),
    );

    // Открываем диалог
    await tester.tap(find.text('Показать диалог'));
    await tester.pumpAndSettle();

    // Проверяем содержимое диалога
    expect(find.text('Подтверждение'), findsOneWidget);
    expect(find.text('Вы уверены?'), findsOneWidget);
    expect(find.text('Отмена'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);

    // Нажимаем OK
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Диалог закрыт
    expect(find.text('Подтверждение'), findsNothing);
  });
}
```

## Тестирование списков

### Тестирование ListView

```dart
void main() {
  testWidgets('ListView должен отображать элементы',
      (WidgetTester tester) async {
    final items = ['Яблоко', 'Банан', 'Апельсин'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(items[index]));
            },
          ),
        ),
      ),
    );

    // Проверяем все элементы
    for (final item in items) {
      expect(find.text(item), findsOneWidget);
    }
  });

  testWidgets('ListView должен поддерживать скроллинг',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) {
              return ListTile(title: Text('Элемент $index'));
            },
          ),
        ),
      ),
    );

    // Скроллим вниз
    await tester.drag(
      find.byType(ListView),
      const Offset(0, -500),
    );
    await tester.pump();

    // Проверяем, что элемент появился
    expect(find.text('Элемент 50'), findsOneWidget);
  });
}
```

## Лучшие практики

1. **Всегда используйте pumpWidget для инициализации** — запускайте виджет перед каждым тестом
2. **Используйте pumpAndSettle для анимаций** — дожидайтесь завершения всех анимаций
3. **Используйте ключи (Keys)** — для надёжного поиска виджетов
4. **Тестируйте поведение, а не реализацию** — проверяйте результат, а не внутренние детали
5. **Изолируйте тесты** — каждый тест должен быть независимым
6. **Используйте find.byKey вместо find.byType** — это надёжнее
7. **Проверяйте наличие/отсутствие виджетов** — используйте `findsOneWidget`, `findsNothing`, `findsNWidgets`

## Заключение

Пакет `flutter_test` предоставляет все необходимые инструменты для тестирования виджетов Flutter. Ключевые методы `pumpWidget`, `pump`, `pumpAndSettle` позволяют управлять рендерингом и анимациями, а мощная система поиска `find` обеспечивает надёжную работу с виджетами.
