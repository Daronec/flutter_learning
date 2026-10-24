---
tags:
  - forms
  - validation
chapter: 8
section: 1
title: Form и FormKey — основы работы с формами
alias: 08 01 form formkey
status: complete
---

# Form и FormKey — основы работы с формами

Form — это виджет-контейнер, который управляет набором полей ввода (FormField). Он предоставляет методы для валидации, сохранения и сброса данных формы.

## Widget Form

### Базовая структура формы

```dart
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // FormKey для управления состоянием формы
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  if (!value.contains('@')) {
                    return 'Некорректный email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Форма валидна — обрабатываем данные
      _formKey.currentState!.save();
    }
  }
}
```

## FormKey — важность использования

### Что такое FormKey

`FormKey` — это уникальный идентификатор формы, который позволяет получить доступ к `FormState` — объекту, управляющему всеми полями формы.

```dart
// Правильное использование FormKey
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: ...,
);

// Доступ к FormState
final formState = _formKey.currentState;
formState?.validate();  // Валидация
formState?.save();      // Сохранение
formState?.reset();     // Сброс
```

### Что будет без FormKey

```dart
// БЕЗ FormKey — невозможно получить FormState
Form(
  child: TextFormField(
    // Нет доступа к валидации всей формы
    // Нет доступа к save() и reset()
  ),
);

// С FormKey — полный контроль
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: TextFormField(
    // Можно валидировать, сохранять, сбрасывать
  ),
);
```

### Multiple Forms — разные FormKey

```dart
class MultiFormScreen extends StatelessWidget {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Форма 1: Логин
        Form(
          key: _formKey1,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Логин'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите логин' : null,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey1.currentState!.validate()) {
                    _formKey1.currentState!.save();
                  }
                },
                child: const Text('Отправить логин'),
              ),
            ],
          ),
        ),
        const Divider(),
        // Форма 2: Регистрация
        Form(
          key: _formKey2,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите email' : null,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey2.currentState!.validate()) {
                    _formKey2.currentState!.save();
                  }
                },
                child: const Text('Отправить email'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

## AutomaticFormState

### Как работает AutomaticFormState

Когда `Form` обнаруживает `FormField` внутри себя, автоматически создаётся связь между полем и формой. `FormState` отслеживает все вложенные поля.

```dart
// Структура:
Form                          // FormState управляет полями
├── FormField<String>         // Автоматически подключён к FormState
│   └── TextFormField         // Виджет ввода
├── FormField<bool>           // Автоматически подключён
│   └── Checkbox              // Виджет чекбокса
└── FormField<String?>        // Автоматически подключён
    └── DropdownButtonFormField // Виджет выпадающего списка
```

### Ручное подключение FormField

```dart
class CustomFormField extends FormField<String> {
  final String labelText;

  CustomFormField({
    super.key,
    required this.labelText,
    super.validator,
    super.onSaved,
  }) : super(
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: labelText,
                    errorText: state.errorText,
                    border: const OutlineInputBorder(),
                  ),
                  // Автоматически подключается к FormField
                  validator: state.validate,
                  onSaved: state.save,
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            );
          },
        );
}

// Использование
Form(
  key: _formKey,
  child: Column(
    children: [
      CustomFormField(
        labelText: 'Имя',
        validator: (value) =>
            value == null || value.isEmpty ? 'Введите имя' : null,
      ),
      CustomFormField(
        labelText: 'Email',
        validator: (value) {
          if (value == null || value.isEmpty) return 'Введите email';
          if (!value.contains('@')) return 'Некорректный email';
          return null;
        },
      ),
    ],
  ),
);
```

## Методы FormState

| Метод | Описание | Пример |
|---|---|---|
| `validate()` | Валидирует все поля | `formState.validate()` |
| `save()` | Сохраняет значения всех полей | `formState.save()` |
| `reset()` | Сбрасывает все поля | `formState.reset()` |
| `restore()` | Восстанавливает предыдущие значения | `formState.restore()` |
| `hasError` | Есть ли ошибки валидации | `formState.hasError` |

## Полный пример формы регистрации

```dart
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _password;
  bool? _agreeTerms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Поле: Имя
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите имя';
                  }
                  if (value.length < 2) {
                    return 'Минимум 2 символа';
                  }
                  return null;
                },
                onSaved: (value) => _name = value,
              ),
              const SizedBox(height: 16),

              // Поле: Email
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Некорректный email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value,
              ),
              const SizedBox(height: 16),

              // Поле: Пароль
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 8) {
                    return 'Минимум 8 символов';
                  }
                  return null;
                },
                onSaved: (value) => _password = value,
              ),
              const SizedBox(height: 16),

              // Чекбокс
              CheckboxListTile(
                title: const Text('Согласен с условиями'),
                value: _agreeTerms,
                onChanged: (value) => setState(() => _agreeTerms = value),
              ),

              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                      },
                      child: const Text('Очистить'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Зарегистрироваться'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Данные доступны
      print('Имя: $_name');
      print('Email: $_email');
      print('Пароль: $_password');
      print('Согласие: $_agreeTerms');

      // Отправка на сервер
      _registerUser(_name!, _email!, _password!);
    }
  }

  Future<void> _registerUser(String name, String email, String password) async {
    // Логика регистрации
    print('Регистрация: $name, $email');
  }
}
```

## Best Practices

1. **Всегда используйте FormKey** — без него невозможно управлять формой.
2. **Используйте `GlobalKey<FormState>`** — не `Key` или `UniqueKey`.
3. **Используйте `onSaved`** для сохранения данных в переменные.
4. **Вызывайте `validate()` перед `save()`** — чтобы убедиться, что данные корректны.
5. **Используйте `reset()`** для очистки формы после успешной отправки.
6. **Не храните данные формы внутри TextFormField** — используйте переменные в State.
7. **Используйте `onChanged`** для мгновенного обновления UI (например, счётчик символов).
8. **Для сложных форм** — разделяйте на несколько Form виджетов.
## РЎРІСЏР·Р°РЅРЅС‹Рµ РіР»Р°РІС‹

[[HTTP-протокол: основы и работа с сетью в Flutter]] [[SharedPreferences — простые пары ключ-значение]] 
