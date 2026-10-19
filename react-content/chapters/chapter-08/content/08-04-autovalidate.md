# AutovalidateMode — когда валидировать

AutovalidateMode определяет, когда форма должна автоматически запускать валидацию полей. Правильный выбор режима влияет на UX и производительность.

## Значения AutovalidateMode

### Три режима валидации

| Режим | Описание | Когда валидирует |
|---|---|---|
| `never` | Никогда автоматически | Только при вызове `validate()` |
| `onUserInteraction` | При взаимодействии | При каждом `onChanged` |
| `always` | Всегда | При каждой перерисовке |

### Настройка на уровне Form

```dart
Form(
  autovalidateMode: AutovalidateMode.onUserInteraction,
  child: Column(
    children: [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Имя'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Введите имя';
          }
          return null;
        },
      ),
      // Остальные поля...
    ],
  ),
);
```

### Настройка на уровне TextFormField

```dart
TextFormField(
  autovalidateMode: AutovalidateMode.onUserInteraction,
  decoration: const InputDecoration(labelText: 'Имя'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя';
    }
    return null;
  },
);
```

## Подробный разбор каждого режима

### AutovalidateMode.never

```dart
// Ошибки показываются только при вызове validate()
Form(
  autovalidateMode: AutovalidateMode.never,
  child: Column(
    children: [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Имя'),
        validator: (value) =>
            value == null || value.isEmpty ? 'Введите имя' : null,
      ),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Email'),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Введите email';
          if (!value.contains('@')) return 'Некорректный email';
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          // Валидация происходит ТОЛЬКО здесь
          if (formKey.currentState!.validate()) {
            // Форма валидна
          }
        },
        child: const Text('Отправить'),
      ),
    ],
  ),
);
```

**Поведение:**
- Пользователь вводит данные — ошибок нет
- Пользователь нажимает «Отправить» — ошибки появляются
- Пользователь исправляет ошибки — ошибок нет (пока не нажмёт «Отправить» снова)

**Когда использовать:**
- Длинные формы с множеством полей
- Когда не хотите перегружать пользователя ошибками
- Для асинхронной валидации

### AutovalidateMode.onUserInteraction

```dart
Form(
  autovalidateMode: AutovalidateMode.onUserInteraction,
  child: Column(
    children: [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Имя'),
        validator: (value) =>
            value == null || value.isEmpty ? 'Введите имя' : null,
      ),
      // Ошибки появляются при первом вводе в поле
    ],
  ),
);
```

**Поведение:**
- Пользователь вводит данные — ошибок нет
- Пользователь начинает вводить в поле — ошибки появляются
- Пользователь исправляет ошибку — ошибка исчезает

**Когда использовать:**
- Большинство форм (рекомендуемый режим по умолчанию)
- Когда нужна мгновенная обратная связь
- Для коротких форм

### AutovalidateMode.always

```dart
Form(
  autovalidateMode: AutovalidateMode.always,
  child: Column(
    children: [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Имя'),
        validator: (value) =>
            value == null || value.isEmpty ? 'Введите имя' : null,
      ),
      // Ошибки появляются сразу при создании формы
    ],
  ),
);
```

**Поведение:**
- Форма загружается — ошибки видны сразу
- Пользователь вводит данные — ошибки исчезают

**Когда использовать:**
- Предзаполненные формы с ошибками
- Формы редактирования с невалидными данными
- Когда нужно показать все ошибки сразу

## Сравнение режимов

| Режим | Ошибки при загрузке | Ошибки при вводе | Ошибки при отправке | Производительность |
|---|---|---|---|---|
| `never` | Нет | Нет | Да | Лучшая |
| `onUserInteraction` | Нет | Да | Да | Хорошая |
| `always` | Да | Да | Да | Худшая |

## Практические примеры

### Форма регистрации с разными режимами

```dart
class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Режим валидации для всей формы
  AutovalidateMode _formAutovalidateMode =
      AutovalidateMode.onUserInteraction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: _formAutovalidateMode,
          child: Column(
            children: [
              // Поле с режимом onUserInteraction (по умолчанию)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Имя',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите имя' : null,
              ),
              const SizedBox(height: 16),

              // Поле с режимом always (мгновенная валидация)
              TextFormField(
                autovalidateMode: AutovalidateMode.always,
                decoration: const InputDecoration(
                  labelText: 'Email',
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
              ),
              const SizedBox(height: 16),

              // Поле с режимом never (только при отправке)
              TextFormField(
                autovalidateMode: AutovalidateMode.never,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
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
              ),
              const SizedBox(height: 24),

              // Переключатель режима валидации
              Row(
                children: [
                  const Text('Режим:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<AutovalidateMode>(
                      value: _formAutovalidateMode,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: AutovalidateMode.never,
                          child: Text('never'),
                        ),
                        DropdownMenuItem(
                          value: AutovalidateMode.onUserInteraction,
                          child: Text('onUserInteraction'),
                        ),
                        DropdownMenuItem(
                          value: AutovalidateMode.always,
                          child: Text('always'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _formAutovalidateMode = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Форма валидна!')),
                    );
                  }
                },
                child: const Text('Отправить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Форма с мгновенной валидацией email

```dart
class EmailFieldWithInstantValidation extends StatefulWidget {
  const EmailFieldWithInstantValidation({super.key});

  @override
  State<EmailFieldWithInstantValidation> createState() =>
      _EmailFieldWithInstantValidationState();
}

class _EmailFieldWithInstantValidationState
    extends State<EmailFieldWithInstantValidation> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Некорректный email';
    }
    return null;
  }

  void _onChanged(String value) {
    final error = _validateEmail(value);
    setState(() {
      _isValid = error == null && value.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: 'Email',
        border: const OutlineInputBorder(),
        suffixIcon: _controller.text.isNotEmpty
            ? Icon(
                _isValid ? Icons.check_circle : Icons.error,
                color: _isValid ? Colors.green : Colors.red,
              )
            : null,
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: _onChanged,
      validator: _validateEmail,
    );
  }
}
```

## Best Practices

1. **Используйте `onUserInteraction` по умолчанию** — баланс между UX и производительностью.
2. **Используйте `always`** для полей с простой синхронной валидацией (email, телефон).
3. **Используйте `never`** для полей с асинхронной валидацией.
4. **Не используйте `always` для сложных форм** — это влияет на производительность.
5. **Настройте валидацию на уровне Form** — это проще управлять.
6. **Используйте `onChanged`** для мгновенной визуальной обратной связи (иконки).
7. **Для предзаполненных форм** — используйте `always` для показа ошибок.
8. **Тестируйте на слабых устройствах** — частая валидация может замедлять работу.
