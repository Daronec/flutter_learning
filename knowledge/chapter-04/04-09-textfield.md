---
tags:
  - widgets
  - ui
  - basics
chapter: 4
section: 9
title: TextField, TextFormField — поля ввода
alias: 04 09 textfield
status: complete
---

# TextField, TextFormField — поля ввода

## Введение

`TextField` и `TextFormField` — основные виджеты для ввода текста в Flutter. `TextFormField` — это обёртка над `TextField` для использования в формах.

## TextField

Виджет `TextField` предоставляет поле для ввода текста.

### Основные свойства TextField

| Свойство | Тип | Описание |
|----------|-----|----------|
| `controller` | `TextEditingController?` | Контроллер для управления текстом |
| `focusNode` | `FocusNode?` | Узел фокуса |
| `decoration` | `InputDecoration?` | Декорация поля |
| `keyboardType` | `TextInputType?` | Тип клавиатуры |
| `obscureText` | `bool` | Скрытие текста (пароль) |
| `maxLines` | `int?` | Максимальное количество строк |
| `minLines` | `int?` | Минимальное количество строк |
| `readOnly` | `bool` | Только для чтения |
| `enabled` | `bool` | Включено/отключено |
| `onChanged` | `ValueChanged<String>?` | Callback при изменении |
| `onSubmitted` | `ValueChanged<String>?` | Callback при отправке |
| `inputFormatters` | `List<TextInputFormatter>?` | Форматеры ввода |
| `textCapitalization` | `TextCapitalization` | Регистр текста |

### Базовый TextField

```dart
TextField(
  decoration: const InputDecoration(
    labelText: 'Имя пользователя',
    hintText: 'Введите имя',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(),
  ),
)
```

## TextEditingController

`TextEditingController` управляет содержимым и позицией курсора в поле ввода.

### Базовое использование

```dart
class TextFieldExample extends StatefulWidget {
  @override
  _TextFieldExampleState createState() => _TextFieldExampleState();
}

class _TextFieldExampleState extends State<TextFieldExample> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Начальное значение
    _controller.text = 'Привет';
    // Слушатель изменений
    _controller.addListener(() {
      print('Текст: ${_controller.text}');
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Обязательно!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'Текст',
        border: OutlineInputBorder(),
      ),
    );
  }
}
```

### Очистка и установка текста

```dart
// Очистка поля
_controller.clear();

// Установка текста
_controller.text = 'Новый текст';

// Вставка текста в позицию курсора
_controller.insertText('Вставленный текст');

// Получение выделенного текста
TextSelection selection = _controller.selection;
String selectedText = _controller.text.substring(
  selection.start,
  selection.end,
);

// Установка позиции курсора
_controller.selection = TextSelection.fromPosition(
  TextPosition(offset: _controller.text.length),
);
```

## InputDecoration

`InputDecoration` определяет визуальное оформление поля ввода.

### Основные свойства InputDecoration

| Свойство | Тип | Описание |
|----------|-----|----------|
| `labelText` | `String?` | Метка, которая перемещается при вводе |
| `hintText` | `String?` | Подсказка, исчезает при вводе |
| `prefixText` | `String?` | Текст перед полем |
| `suffixText` | `String?` | Текст после поля |
| `prefixIcon` | `Widget?` | Иконка перед полем |
| `suffixIcon` | `Widget?` | Иконка после поля |
| `errorText` | `String?` | Текст ошибки |
| `helperText` | `String?` | Вспомогательный текст |
| `counterText` | `String?` | Счётчик символов |
| `border` | `InputBorder?` | Граница поля |
| `enabledBorder` | `InputBorder?` | Граница в активном состоянии |
| `focusedBorder` | `InputBorder?` | Граница в фокусе |
| `errorBorder` | `InputBorder?` | Граница в состоянии ошибки |
| `filled` | `bool` | Заполнен ли фон |
| `fillColor` | `Color?` | Цвет фона |

### Пример InputDecoration

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'user@example.com',
    prefixIcon: const Icon(Icons.email),
    suffixIcon: IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        _controller.clear();
      },
    ),
    helperText: 'Введите ваш email',
    errorText: _hasError ? 'Неверный формат email' : null,
    counterText: '${_controller.text.length} символов',
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
    filled: true,
    fillColor: Colors.grey[100],
  ),
)
```

### Кастомные границы

```dart
// Пунктирная граница
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        style: BorderStyle.solid,
        width: 2,
      ),
    ),
  ),
)

// Без границы
TextField(
  decoration: const InputDecoration(
    border: InputBorder.none,
  ),
)

// Линия снизу
TextField(
  decoration: const InputDecoration(
    border: UnderlineInputBorder(),
  ),
)
```

## TextInputType — типы клавиатуры

| Значение | Описание |
|----------|----------|
| `text` | Обычная клавиатура |
| `emailAddress` | Клавиатура с @ |
| `number` | Цифровая клавиатура |
| `phone` | Телефонная клавиатура |
| `datetime` | Клавиатура для даты/времени |
| `url` | Клавиатура для URL |
| `visiblePassword` | Клавиатура с видимым паролем |
| `multiline` | Многострочный ввод |

```dart
// Email
TextField(
  keyboardType: TextInputType.emailAddress,
  decoration: const InputDecoration(labelText: 'Email'),
)

// Число
TextField(
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(labelText: 'Возраст'),
)

// Телефон
TextField(
  keyboardType: TextInputType.phone,
  decoration: const InputDecoration(labelText: 'Телефон'),
)

// Пароль
TextField(
  keyboardType: TextInputType.visiblePassword,
  obscureText: true,
  decoration: const InputDecoration(labelText: 'Пароль'),
)

// Многострочный
TextField(
  maxLines: null, // null = неограниченное количество строк
  keyboardType: TextInputType.multiline,
  decoration: const InputDecoration(labelText: 'Комментарий'),
)
```

## InputFormatters — форматеры ввода

`TextInputFormatter` ограничивает и форматирует вводимый текст.

### Основные форматеры

```dart
// Только цифры
TextField(
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  decoration: const InputDecoration(labelText: 'Номер'),
)

// Только буквы
TextField(
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-Я ]'))],
  decoration: const InputDecoration(labelText: 'Имя'),
)

// Только разрешённые символы
TextField(
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
  decoration: const InputDecoration(labelText: 'Цена'),
)

// Запрет символов
TextField(
  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[<>]'))],
  decoration: const InputDecoration(labelText: 'Без спецсимволов'),
)
```

### LengthLimitingTextInputFormatter

```dart
// Ограничение длины
TextField(
  inputFormatters: [LengthLimitingTextInputFormatter(50)],
  decoration: const InputDecoration(
    labelText: 'Комментарий',
    counterText: '', // Скрыть стандартный счётчик
  ),
)
```

### CustomTextInputFormatter

```dart
// Форматирование телефона: +7 (999) 123-45-67
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Простая реализация
    return newValue;
  }
}

TextField(
  inputFormatters: [PhoneInputFormatter()],
  decoration: const InputDecoration(labelText: 'Телефон'),
)
```

## TextFormField

`TextFormField` — обёртка над `TextField` для использования в `Form`.

### Основные отличия

| Характеристика | TextField | TextFormField |
|----------------|-----------|---------------|
| Форма | Нет | Да (validация) |
| `validator` | Нет | Да |
| `autovalidateMode` | Нет | Да |
| `onSaved` | Нет | Да |

### Пример с валидацией

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _validateEmail(String value) {
    return value.contains('@') && value.contains('.');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
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
              if (!_validateEmail(value)) {
                return 'Неверный формат';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Пароль',
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Форма валидна
                print('Email: ${_emailController.text}');
                print('Пароль: ${_passwordController.text}');
              }
            },
            child: const Text('Войти'),
          ),
        ],
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
```

## Best Practices

1. **Всегда вызывайте `dispose()`** для `TextEditingController` и `FocusNode`.

2. **Используйте `TextFormField`** для полей в формах с валидацией.

3. **Используйте подходящий `keyboardType`** для каждого поля ввода.

4. **Используйте `inputFormatters`** для ограничения ввода (только цифры, ограничение длины).

5. **Используйте `autovalidateMode`** для автоматической валидации:
   ```dart
   TextFormField(
     autovalidateMode: AutovalidateMode.onUserInteraction,
     validator: (value) => value!.isEmpty ? 'Обязательное поле' : null,
   )
   ```

6. **Используйте `suffixIcon`** для кнопки очистки поля ввода.

7. **Используйте `maxLines: null`** для многострочного ввода с автоматическим расширением.

8. **Используйте `textCapitalization`** для управления регистром:
   ```dart
   TextField(
     textCapitalization: TextCapitalization.sentences,
   )
   ```
