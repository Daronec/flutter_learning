# Checkbox, Radio, Switch — элементы выбора

## Введение

`Checkbox`, `Radio` и `Switch` — стандартные элементы пользовательского интерфейса для выбора вариантов. Каждый из них предназначен для определённого типа выбора.

## Checkbox

`Checkbox` — элемент для множественного выбора (вкл/выкл).

### Основные свойства Checkbox

| Свойство | Тип | Описание |
|----------|-----|----------|
| `value` | `bool?` | Текущее состояние (true/false/null) |
| ` onChanged` | `ValueChange<bool?>?` | Callback при изменении |
| `activeColor` | `Color?` | Цвет в активном состоянии |
| `checkColor` | `Color?` | Цвет галочки |
| `shape` | `MaterialStateProperty<OutlinedBorder?>?` | Форма чекбокса |
| `side` | `MaterialSide?` | Боковая сторона |
| `tristate` | `bool` | Третье состояние (null) |

### Базовое использование

```dart
bool _isChecked = false;

Checkbox(
  value: _isChecked,
  onChanged: (value) {
    setState(() {
      _isChecked = value ?? false;
    });
  },
  activeColor: Colors.blue,
)
```

### Три-состояние (Tristate)

```dart
bool? _isPartial = null; // null, true, false

Checkbox(
  value: _isPartial,
  tristate: true,
  onChanged: (value) {
    setState(() {
      _isPartial = value;
    });
  },
)
```

### CheckboxListTile

Для отображения чекбокса с текстом используется `CheckboxListTile`:

```dart
CheckboxListTile(
  value: _isChecked,
  onChanged: (value) {
    setState(() {
      _isChecked = value ?? false;
    });
  },
  title: const Text('Принимаю условия'),
  subtitle: const Text('Политика конфиденциальности'),
  secondary: const Icon(Icons.info_outline),
  dense: false,
  controlAffinity: ListTileControlAffinity.trailing,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
)
```

### Множественный выбор

```dart
class MultiSelectExample extends StatefulWidget {
  @override
  _MultiSelectExampleState createState() => _MultiSelectExampleState();
}

class _MultiSelectExampleState extends State<MultiSelectExample> {
  final Map<String, bool> _selectedItems = {
    'Flutter': false,
    'Dart': false,
    'React': false,
    'Vue': false,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _selectedItems.entries.map((entry) {
        return CheckboxListTile(
          value: entry.value,
          title: Text(entry.key),
          onChanged: (value) {
            setState(() {
              _selectedItems[entry.key] = value ?? false;
            });
          },
        );
      }).toList(),
    );
  }
}
```

## Radio

`Radio` — элемент для одиночного выбора из группы вариантов.

### Основные свойства Radio

| Свойство | Тип | Описание |
|----------|-----|----------|
| `value` | `T` | Значение этого радио-кнопки |
| `groupValue` | `T?` | Текущее выбранное значение группы |
| `onChanged` | `ValueChange<T>?` | Callback при изменении |
| `activeColor` | `Color?` | Цвет в активном состоянии |

### Базовое использование

```dart
String _selectedOption = 'option1';

Radio<String>(
  value: 'option1',
  groupValue: _selectedOption,
  onChanged: (value) {
    setState(() {
      _selectedOption = value!;
    });
  },
  activeColor: Colors.blue,
)
```

### RadioListTile

```dart
RadioListTile<String>(
  value: 'option1',
  groupValue: _selectedOption,
  onChanged: (value) {
    setState(() {
      _selectedOption = value!;
    });
  },
  title: const Text('Вариант 1'),
  subtitle: const Text('Описание варианта 1'),
  secondary: const Icon(Icons.star),
  dense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
)
```

### Группа Radio кнопок

```dart
class RadioGroupExample extends StatefulWidget {
  @override
  _RadioGroupExampleState createState() => _RadioGroupExampleState();
}

class _RadioGroupExampleState extends State<RadioGroupExample> {
  String _gender = 'male';
  String _size = 'm';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Группа: Пол
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Пол',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        RadioListTile<String>(
          value: 'male',
          groupValue: _gender,
          onChanged: (value) {
            setState(() => _gender = value!);
          },
          title: const Text('Мужской'),
          secondary: const Icon(Icons.male),
        ),
        RadioListTile<String>(
          value: 'female',
          groupValue: _gender,
          onChanged: (value) {
            setState(() => _gender = value!);
          },
          title: const Text('Женский'),
          secondary: const Icon(Icons.female),
        ),
        const Divider(),
        // Группа: Размер
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Размер',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        RadioListTile<String>(
          value: 's',
          groupValue: _size,
          onChanged: (value) {
            setState(() => _size = value!);
          },
          title: const Text('Маленький (S)'),
        ),
        RadioListTile<String>(
          value: 'm',
          groupValue: _size,
          onChanged: (value) {
            setState(() => _size = value!);
          },
          title: const Text('Средний (M)'),
        ),
        RadioListTile<String>(
          value: 'l',
          groupValue: _size,
          onChanged: (value) {
            setState(() => _size = value!);
          },
          title: const Text('Большой (L)'),
        ),
      ],
    );
  }
}
```

## Switch

`Switch` — элемент для переключения между двумя состояниями (вкл/выкл). Визуально отличается от `Checkbox` — используется для быстрых переключений.

### Основные свойства Switch

| Свойство | Тип | Описание |
|----------|-----|----------|
| `value` | `bool` | Текущее состояние |
| `onChanged` | `ValueChange<bool>?` | Callback при изменении |
| `activeColor` | `Color?` | Цвет в активном состоянии |
| `activeTrackColor` | `Color?` | Цвет дорожки в активном состоянии |
| `inactiveThumbColor` | `Color?` | Цвет ползунка в неактивном состоянии |
| `inactiveTrackColor` | `Color?` | Цвет дорожки в неактивном состоянии |
| `thumbColor` | `MaterialStateProperty<Color?>?` | Цвет ползунка (состояния) |
| `trackColor` | `MaterialStateProperty<Color?>?` | Цвет дорожки (состояния) |

### Базовое использование

```dart
bool _notificationsEnabled = true;

Switch(
  value: _notificationsEnabled,
  onChanged: (value) {
    setState(() {
      _notificationsEnabled = value;
    });
  },
)
```

### SwitchListTile

```dart
SwitchListTile(
  value: _notificationsEnabled,
  onChanged: (value) {
    setState(() {
      _notificationsEnabled = value;
    });
  },
  title: const Text('Уведомления'),
  subtitle: const Text('Получать push-уведомления'),
  secondary: const Icon(Icons.notifications),
  activeColor: Colors.blue,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
)
```

### Кастомный Switch

```dart
Switch(
  value: _darkMode,
  onChanged: (value) {
    setState(() => _darkMode = value);
  },
  // Кастомные цвета
  activeColor: Colors.purple,
  activeTrackColor: Colors.purple.withOpacity(0.4),
  inactiveThumbColor: Colors.grey[400],
  inactiveTrackColor: Colors.grey[200],
  // Кастомный цвет ползунка по состояниям
  thumbColor: MaterialStateProperty.resolveWith((states) {
    if (states.contains(MaterialState.selected)) {
      return Colors.purple;
    }
    return Colors.grey[400];
  }),
  // Кастомный цвет дорожки по состояниям
  trackColor: MaterialStateProperty.resolveWith((states) {
    if (states.contains(MaterialState.selected)) {
      return Colors.purple.withOpacity(0.4);
    }
    return Colors.grey[200];
  }),
)
```

## Сравнение элементов выбора

| Элемент | Тип выбора | Визуал | Когда использовать |
|---------|-----------|--------|-------------------|
| `Checkbox` | Множественный | Квадрат с галочкой | Несколько независимых опций |
| `Radio` | Одиночный | Круг с точкой | Выбор одного из группы |
| `Switch` | Двоичный | Ползунок | Быстрое переключение вкл/выкл |

## Best Practices

1. **Используйте `CheckboxListTile`** для отображения чекбоксов с текстом — это обеспечивает правильное выравнивание и отступы.

2. **Используйте `RadioListTile`** для групп радио-кнопок — это упрощает разметку и обеспечивает визуальную согласованность.

3. **Используйте `SwitchListTile`** для переключателей с описанием — это стандартный паттерн в настройках.

4. **Используйте `tristate: true`** для чекбоксов, когда нужно состояние «не определено» (например, для чекбокса «выбрать все»).

5. **Группируйте связанные Radio-кнопки** — все кнопки с одинаковым `groupValue` образуют группу.

6. **Используйте `Switch`** для быстрых переключений, а `Checkbox` — для подтверждения выбора.

7. **Добавляйте `secondary` иконки** для улучшения визуального восприятия.

8. **Используйте `contentPadding`** для согласованных отступов во всех элементах выбора.
