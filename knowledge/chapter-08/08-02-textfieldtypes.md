# TextFormField и типы полей ввода

TextFormField — это виджет для ввода текста, интегрированный с Form. Он поддерживает различные типы клавиатур, автозаполнение и форматирование ввода.

## TextInputType значения

### Основные типы ввода

| Тип | Описание | Клавиатура |
|---|---|---|
| `text` | Обычный текст | Полная клавиатура |
| `multiline` | Многострочный текст | Полная + Enter |
| `number` | Числа | Цифры + символы |
| `email` | Email адрес | С символом @ |
| `url` | URL адрес | С символом / |
| `phone` | Номер телефона | Цифры + * # |
| `datetime` | Дата и время | Цифры |
| `name` | Имя пользователя | Полная клавиатура |
| `streetAddress` | Адрес | Полная клавиатура |
| `none` | Без клавиатуры | Закрытая |

### Примеры использования

```dart
// Обычный текст
TextFormField(
  decoration: const InputDecoration(labelText: 'Имя'),
  keyboardType: TextInputType.text,
);

// Многострочный текст
TextFormField(
  decoration: const InputDecoration(labelText: 'Комментарий'),
  keyboardType: TextInputType.multiline,
  maxLines: null, // Разрешить неограниченное количество строк
);

// Числовой ввод
TextFormField(
  decoration: const InputDecoration(labelText: 'Возраст'),
  keyboardType: TextInputType.number,
);

// Email
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Email',
    prefixIcon: Icon(Icons.email),
  ),
  keyboardType: TextInputType.emailAddress,
);

// URL
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Веб-сайт',
    prefixIcon: Icon(Icons.link),
  ),
  keyboardType: TextInputType.url,
);

// Телефон
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Телефон',
    prefixIcon: Icon(Icons.phone),
  ),
  keyboardType: TextInputType.phone,
);
```

## Типы клавиатуры (KeyboardType)

### Enhanced Keyboard Types

| Тип | Описание | Платформа |
|---|---|---|
| `visiblePassword` | Пароль с видимыми символами | iOS 14+ |
| `visiblePassword` | Пароль (обычный) | Android |
| `text` с `obscureText` | Скрытый пароль | Обе |

### Парольные поля

```dart
// Обычный пароль (скрытый)
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Пароль',
    prefixIcon: Icon(Icons.lock),
    border: OutlineInputBorder(),
  ),
  obscureText: true,
  keyboardType: TextInputType.visiblePassword,
);

// Пароль с переключением видимости
class PasswordField extends StatefulWidget {
  const PasswordField({super.key});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Пароль',
        prefixIcon: const Icon(Icons.lock),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Введите пароль';
        }
        if (value.length < 8) {
          return 'Минимум 8 символов';
        }
        return null;
      },
    );
  }
}
```

## AutoFill — автозаполнение

### Настройка AutoFill

AutoFill использует системные данные пользователя для автоматического заполнения полей:

```dart
TextFormField(
  decoration: const InputDecoration(
    labelText: 'Имя',
    border: OutlineInputBorder(),
  ),
  autofillHints: const [AutofillHints.name],
  keyboardType: TextInputType.name,
);

TextFormField(
  decoration: const InputDecoration(
    labelText: 'Email',
    border: OutlineInputBorder(),
  ),
  autofillHints: const [AutofillHints.email],
  keyboardType: TextInputType.emailAddress,
);

TextFormField(
  decoration: const InputDecoration(
    labelText: 'Пароль',
    border: OutlineInputBorder(),
  ),
  autofillHints: const [AutofillHints.password],
  obscureText: true,
  keyboardType: TextInputType.visiblePassword,
);

TextFormField(
  decoration: const InputDecoration(
    labelText: 'Телефон',
    border: OutlineInputBorder(),
  ),
  autofillHints: const [AutofillHints.telephoneNumber],
  keyboardType: TextInputType.phone,
);
```

### Группы автозаполнения

```dart
// Форма с группой автозаполнения
class AutofillForm extends StatelessWidget {
  const AutofillForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: AutofillGroup(
        child: Column(
          children: [
            TextFormField(
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: const InputDecoration(
                labelText: 'Телефон',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              autofillHints: const [AutofillHints.postalCode],
              decoration: const InputDecoration(
                labelText: 'Почтовый индекс',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Доступные AutofillHints

| Hint | Описание |
|---|---|
| `name` | Имя пользователя |
| `email` | Email адрес |
| `password` | Пароль |
| `telephoneNumber` | Номер телефона |
| `postalCode` | Почтовый индекс |
| `streetAddress` | Полный адрес |
| `username` | Имя пользователя (логин) |
| `newPassword` | Новый пароль |
| `oneTimeCode` | Код подтверждения (SMS) |
| `ccName` | Имя на карте |
| `ccNumber` | Номер карты |
| `ccExpiration` | Срок действия карты |
| `ccCSC` | CVV код карты |

## Пример: Полная форма с различными типами полей

```dart
class CompleteForm extends StatefulWidget {
  const CompleteForm({super.key});

  @override
  State<CompleteForm> createState() => _CompleteFormState();
}

class _CompleteFormState extends State<CompleteForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Полная форма')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                // Имя
                TextFormField(
                  autofillHints: const [AutofillHints.name],
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'Полное имя',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Введите имя' : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  autofillHints: const [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
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
                const SizedBox(height: 16),

                // Телефон
                TextFormField(
                  autofillHints: const [AutofillHints.telephoneNumber],
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Телефон',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите телефон';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Пароль
                TextFormField(
                  autofillHints: const [AutofillHints.newPassword],
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
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
                const SizedBox(height: 16),

                // Комментарий (многострочный)
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Комментарий',
                    prefixIcon: Icon(Icons.comment),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
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
      ),
    );
  }
}
```

## Best Practices

1. **Используйте `autofillHints`** — это улучшает UX и ускоряет заполнение форм.
2. **Выбирайте правильный `keyboardType`** ��� это уменьшает количество ошибок ввода.
3. **Используйте `obscureText: true`** для полей пароля.
4. **Используйте `prefixIcon` и `suffixIcon`** для визуальных подсказок.
5. **Используйте `alignLabelWithHint: true`** для многострочных полей.
6. **Используйте `maxLines: null`** для неограниченного многострочного ввода.
7. **Группируйте поля в `AutofillGroup`** — это помогает системе автозаполнения.
8. **Для числового ввода** — рассмотрите использование `TextInputFormatter` для форматирования.
