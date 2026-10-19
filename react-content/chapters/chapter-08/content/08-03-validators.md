# Валидаторы: встроенные и кастомные

Валидация — это проверка корректности данных, введённых пользователем. Flutter предоставляет встроенные и кастомные валидаторы для различных сценариев.

## Встроенные валидаторы

### Базовый validator

Валидатор — это функция, которая принимает значение и возвращает строку ошибки или null:

```dart
TextFormField(
  validator: (value) {
    // Если значение некорректно — возвращаем строку ошибки
    // Если значение корректно — возвращаем null
    if (value == null || value.isEmpty) {
      return 'Поле обязательно для заполнения';
    }
    return null;
  },
);
```

### Валидация email

```dart
TextFormField(
  decoration: const InputDecoration(labelText: 'Email'),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }

    // Регулярное выражение для email
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Некорректный email';
    }

    return null;
  },
);
```

### Валидация пароля

```dart
TextFormField(
  decoration: const InputDecoration(labelText: 'Пароль'),
  obscureText: true,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }

    if (value.length < 8) {
      return 'Минимум 8 символов';
    }

    // Проверка на наличие заглавной буквы
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Должна быть заглавная буква';
    }

    // Проверка на наличие цифры
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Должна быть цифра';
    }

    // Проверка на наличие спецсимвола
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Должен быть спецсимвол';
    }

    return null;
  },
);
```

### Валидация номера телефона

```dart
TextFormField(
  decoration: const InputDecoration(labelText: 'Телефон'),
  keyboardType: TextInputType.phone,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Введите номер телефона';
    }

    // Убираем все нецифровые символы
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 10) {
      return 'Некорректный номер телефона';
    }

    return null;
  },
);
```

### Валидация URL

```dart
TextFormField(
  decoration: const InputDecoration(labelText: 'URL'),
  keyboardType: TextInputType.url,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Введите URL';
    }

    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasHost) {
        return 'Некорректный URL';
      }
    } catch (e) {
      return 'Некорректный URL';
    }

    return null;
  },
);
```

## Кастомные валидаторы

### Переиспользуемые валидаторы

```dart
class Validators {
  // Обязательное поле
  static String? required(String? value, {String? fieldName}) {
    final name = fieldName ?? 'Поле';
    if (value == null || value.isEmpty) {
      return '$name обязательно для заполнения';
    }
    return null;
  }

  // Минимальная длина
  static String? minLength(String? value, int minLength,
      {String? fieldName}) {
    final name = fieldName ?? 'Поле';
    if (value != null && value.length < minLength) {
      return '$name: минимум $minLength символов';
    }
    return null;
  }

  // Максимальная длина
  static String? maxLength(String? value, int maxLength,
      {String? fieldName}) {
    final name = fieldName ?? 'Поле';
    if (value != null && value.length > maxLength) {
      return '$name: максимум $maxLength символов';
    }
    return null;
  }

  // Email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Некорректный email';
    }
    return null;
  }

  // Пароль
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    if (value.length < 8) {
      return 'Минимум 8 символов';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Должна быть заглавная буква';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Должна быть цифра';
    }
    return null;
  }

  // Число в диапазоне
  static String? range(int? value, int min, int max,
      {String? fieldName}) {
    final name = fieldName ?? 'Значение';
    if (value == null) {
      return '$name обязательно';
    }
    if (value < min || value > max) {
      return '$name: от $min до $max';
    }
    return null;
  }

  // Комбинированный валидатор
  static String? requiredAndMinLength(
      String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return required(value, fieldName: fieldName);
    }
    return minLength(value, minLength, fieldName: fieldName);
  }
}

// Использование
TextFormField(
  validator: Validators.requiredAndMinLength,
);
```

### Комбинирование валидаторов

```dart
class CompositeValidator {
  final List<String? Function(String?)> validators;

  const CompositeValidator(this.validators);

  String? call(String? value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}

// Использование
TextFormField(
  validator: CompositeValidator([
    Validators.required,
    (value) => Validators.minLength(value, 3),
    (value) => Validators.maxLength(value, 50),
  ]).call,
);
```

### Асинхронная валидация

```dart
class AsyncValidators {
  // Проверка уникальности email
  static Future<String?> uniqueEmail(String? value) async {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }

    try {
      // Имитация запроса к серверу
      final exists = await _checkEmailExists(value);
      if (exists) {
        return 'Этот email уже зарегистрирован';
      }
    } catch (e) {
      return 'Ошибка проверки email';
    }

    return null;
  }

  // Проверка уникальности username
  static Future<String?> uniqueUsername(String? value) async {
    if (value == null || value.isEmpty) {
      return 'Введите имя пользователя';
    }

    try {
      final exists = await _checkUsernameExists(value);
      if (exists) {
        return 'Это имя пользователя занято';
      }
    } catch (e) {
      return 'Ошибка проверки имени';
    }

    return null;
  }

  static Future<bool> _checkEmailExists(String email) async {
    // Имитация HTTP-запроса
    await Future.delayed(const Duration(milliseconds: 500));
    return ['admin@example.com', 'test@example.com']
        .contains(email);
  }

  static Future<bool> _checkUsernameExists(String username) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['admin', 'user', 'test'].contains(username);
  }
}

// Использование асинхронного валидатора
TextFormField(
  decoration: const InputDecoration(labelText: 'Email'),
  validator: AsyncValidators.uniqueEmail,
);
```

### Валидатор с debounce (задержкой)

```dart
class DebounceValidator {
  final Future<String?> Function(String?) _validator;
  final Duration delay;
  Timer? _timer;

  DebounceValidator(
    this._validator, {
    this.delay = const Duration(milliseconds: 500),
  });

  String? Function(String?) get validator {
    return (value) {
      _timer?.cancel();
      _timer = Timer(delay, () async {
        final error = await _validator(value);
        // Обновляем состояние валидации
        // Это требует доступа к FormFieldState
      });
      return null; // Не блокируем синхронную валидацию
    };
  }
}

// Использование с FormFieldState
class EmailField extends StatefulWidget {
  const EmailField({super.key});

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  String? _asyncError;

  Future<void> _validateEmail(String? value) async {
    if (value == null || value.isEmpty) return;

    final exists = await AsyncValidators._checkEmailExists(value);
    if (mounted) {
      setState(() {
        _asyncError = exists ? 'Email уже используется' : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: _asyncError,
        border: const OutlineInputBorder(),
      ),
      onChanged: _validateEmail,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите email';
        }
        if (!value.contains('@')) {
          return 'Некорректный email';
        }
        return _asyncError;
      },
    );
  }
}
```

## Сравнение валидаторов

| Тип | Когда вызывается | Синхронный | Пример |
|---|---|---|---|
| `validator` | При вызове `validate()` | Да | Проверка пустоты |
| `autovalidateMode` | При каждом изменении | Да | Мгновенная валидация |
| Кастомный | По требованию | Да | Регулярные выражения |
| Асинхронный | По требованию | Нет | Проверка на сервере |

## Best Practices

1. **Валидируйте на клиенте** — быстрая обратная связь для пользователя.
2. **Валидируйте на сервере** — безопасность данных.
3. **Используйте регулярные выражения** — для проверки email, телефона, URL.
4. **Делайте сообщения об ошибках понятными** — пользователь должен знать, что исправить.
5. **Используйте debounce для асинхронной валидации** — чтобы не перегружать сервер.
6. **Создавайте переиспользуемые валидаторы** — для консистентности.
7. **Валидируйте только после ввода** — не показывайте ошибки до первого взаимодействия.
8. **Используйте `autovalidateMode`** для мгновенной обратной связи.
