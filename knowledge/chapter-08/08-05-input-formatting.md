---
tags:
  - forms
  - validation
chapter: 8
section: 5
title: Форматирование и маски ввода
alias: 08 05 input formatting
status: complete
---

# Форматирование и маски ввода

TextInputFormatter позволяет форматировать вводимый текст в реальном времени: добавлять разделители, ограничивать длину, фильтровать символы и применять маски ввода.

## TextInputFormatter

### Базовый Formatter

```dart
class CustomFormatter extends TextInputFormatter {
  final String? Function(String?) validator;

  CustomFormatter({required this.validator});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Валидация нового значения
    final error = validator(newValue.text);
    if (error != null) {
      return oldValue; // Отклоняем изменение
    }
    return newValue; // Принимаем изменение
  }
}

// Использование
TextFormField(
  inputFormatters: [
    CustomFormatter(
      validator: (value) {
        if (value != null && value.length > 10) {
          return 'Максимум 10 символов';
        }
        return null;
      },
    ),
  ],
);
```

## FilteringTextInputFormatter

### Разрешение/запрет символоов

```dart
// Разрешить только цифры
TextFormField(
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
);

// Разрешить только буквы
TextFormField(
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-ЯёЁ ]')),
  ],
);

// Запретить определённые символы
TextFormField(
  inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r'[<>]')),
  ],
);

// Разрешить только заглавные буквы
TextFormField(
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
  ],
);

// Разрешить буквы, цифры и пробелы
TextFormField(
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
  ],
);
```

### Доступные фильтры

| Фильтр | Описание | Пример |
|---|---|---|
| `digitsOnly` | Только цифры | `123456` |
| `allow(pattern)` | Разрешить по паттерну | `[a-zA-Z]` |
| `deny(pattern)` | Запретить по паттерну | `[<>]` |
| `SingleLineFormatter` | Только одна строка | Без `\n` |

## NumericFormatter — форматирование чисел

### Форматирование целых чисел

```dart
class IntegerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Разрешаем только цифры и backspace
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text;

    // Проверяем, что все символы — цифры
    if (!RegExp(r'^[0-9]*$').hasMatch(text)) {
      return oldValue;
    }

    // Ограничиваем длину
    if (text.length > 10) {
      return oldValue;
    }

    return newValue;
  }
}

// Использование
TextFormField(
  inputFormatters: [IntegerInputFormatter()],
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: 'Количество',
    suffixText: 'шт.',
  ),
);
```

### Форматирование десятичных чисел

```dart
class DecimalInputFormatter extends TextInputFormatter {
  final int decimals;

  DecimalInputFormatter({this.decimals = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text;

    // Разрешаем цифры и одну точку
    if (!RegExp(r'^[0-9]*\.?[0-9]*$').hasMatch(text)) {
      return oldValue;
    }

    // Ограничиваем количество знаков после запятой
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts.length == 2 && parts[1].length > decimals) {
        return oldValue;
      }
    }

    return newValue;
  }
}

// Использование
TextFormField(
  inputFormatters: [DecimalInputFormatter(decimals: 2)],
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  decoration: const InputDecoration(
    labelText: 'Цена',
    suffixText: '₽',
  ),
);
```

### Форматирование с разделителями тысяч

```dart
class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text;

    // Разрешаем только цифры
    if (!RegExp(r'^[0-9]*$').hasMatch(text)) {
      return oldValue;
    }

    // Форматируем с разделителями
    final number = int.tryParse(text);
    if (number == null) {
      return oldValue;
    }

    // Форматируем число с разделителями
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );

    // Возвращаем отформатированное значение
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Использование
TextFormField(
  inputFormatters: [ThousandsSeparatorFormatter()],
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
    labelText: 'Сумма',
    suffixText: '₽',
  ),
);
```

## Masked Input — маски ввода

### Простая маска для телефона

```dart
class PhoneMaskFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Разрешаем только цифры
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Форматируем номер телефона: +7 (XXX) XXX-XX-XX
    String formatted = '+7';

    if (digits.length > 1) {
      formatted += ' (${digits.substring(1, digits.length > 4 ? 4 : digits.length)}';
    }

    if (digits.length > 4) {
      formatted += ') ${digits.substring(4, digits.length > 7 ? 7 : digits.length)}';
    }

    if (digits.length > 7) {
      formatted += '-${digits.substring(7, digits.length > 9 ? 9 : digits.length)}';
    }

    if (digits.length > 9) {
      formatted += '-${digits.substring(9, digits.length > 11 ? 11 : digits.length)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Использование
TextFormField(
  inputFormatters: [PhoneMaskFormatter()],
  keyboardType: TextInputType.phone,
  decoration: const InputDecoration(
    labelText: 'Телефон',
    prefixText: '+7 ',
  ),
  validator: (value) {
    if (value == null || value.length < 16) {
      return 'Введите полный номер';
    }
    return null;
  },
);
```

### Универсальный MaskFormatter

```dart
class MaskFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  const MaskFormatter({
    required this.mask,
    this.separator = '',
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Собираем только значимые символы
    final significantChars = mask
        .split('')
        .where((c) => c != separator)
        .join('');

    final significantText = text
        .split('')
        .where((c) => significantChars.contains(c))
        .join('');

    if (significantText.length > significantChars.length) {
      return oldValue;
    }

    // Формируем строку с маской
    String result = '';
    int textIndex = 0;

    for (int i = 0; i < mask.length && textIndex < significantText.length; i++) {
      final maskChar = mask[i];
      if (maskChar == separator) {
        result += separator;
      } else {
        result += significantText[textIndex];
        textIndex++;
      }
    }

    // Добавляем оставшиеся символы
    if (textIndex < significantText.length) {
      result += significantText.substring(textIndex);
    }

    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// Использование
// Маска для даты: DD.MM.YYYY
TextFormField(
  inputFormatters: [MaskFormatter(mask: '99.99.9999', separator: '.')],
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(labelText: 'Дата'),
);

// Маска для карты: XXXX-XXXX-XXXX-XXXX
TextFormField(
  inputFormatters: [
    MaskFormatter(mask: '9999-9999-9999-9999', separator: '-')
  ],
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(labelText: 'Номер карты'),
);

// Маска для VIN: XXX-XXXXX-XXXXXXX
TextFormField(
  inputFormatters: [
    MaskFormatter(mask: 'XXXXXXXXXXXXXXXXX', separator: '-')
  ],
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(labelText: 'VIN'),
);
```

## Валидация + Форматирование

### Комбинирование Formatter и Validator

```dart
class CreditCardField extends StatefulWidget {
  const CreditCardField({super.key});

  @override
  State<CreditCardField> createState() => _CreditCardFieldState();
}

class _CreditCardFieldState extends State<CreditCardField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      inputFormatters: [
        // Форматирование: XXXX-XXXX-XXXX-XXXX
        LengthLimitingTextInputFormatter(19),
        FilteringTextInputFormatter.digitsOnly,
        _CardNumberFormatter(),
      ],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Номер карты',
        border: const OutlineInputBorder(),
        suffixIcon: _controller.text.replaceAll('-', '').length == 16
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.credit_card),
      ),
      validator: (value) {
        final digits = value?.replaceAll('-', '') ?? '';
        if (digits.isEmpty) {
          return 'Введите номер карты';
        }
        if (digits.length != 16) {
          return 'Введите 16 цифр';
        }
        return null;
      },
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += '-';
      }
      formatted += digits[i];
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
```

## Best Practices

1. **Используйте `FilteringTextInputFormatter`** для простой фильтрации символов.
2. **Создавайте кастомные Formatters** для сложных масок ввода.
3. **Используйте `LengthLimitingTextInputFormatter`** для ограничения длины.
4. **Форматируйте в реальном времени** — пользователь видит результат сразу.
5. **Сохраняйте позицию курсора** — используйте `selection` в `formatEditUpdate`.
6. **Валидируйте отформатированное значение** — проверяйте без разделителей.
7. **Используйте `digitsOnly`** для числовых полей.
8. **Тестируйте на всех платформах** — поведение может отличаться.

## Сводка TextInputFormatter

| Класс | Назначение | Пример |
|---|---|---|
| `FilteringTextInputFormatter` | Фильтрация символов | `digitsOnly` |
| `LengthLimitingTextInputFormatter` | Ограничение длины | `LengthLimitingTextInputFormatter(10)` |
| `TextInputFormatter` (базовый) | Кастомное форматирование | Кастомный Formatter |
| `UpperFilteringTextInputFormatter` | Заглавные буквы | `UpperFilteringTextInputFormatter()` |
