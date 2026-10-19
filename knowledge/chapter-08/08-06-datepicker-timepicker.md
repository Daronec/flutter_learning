# Работа с DatePicker и TimePicker

Flutter предоставляет встроенные виджеты для выбора даты и времени: `showDatePicker` и `showTimePicker`. Они адаптируются под платформу и поддерживают кастомизацию.

## showDatePicker

### Базовое использование

```dart
class DateSelectionScreen extends StatefulWidget {
  const DateSelectionScreen({super.key});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор даты')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                _selectedDate == null
                    ? 'Выбрать дату'
                    : 'Выбрана: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Настройки DatePicker

```dart
final DateTime? picked = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  // Настройки отображения
  builder: (context, child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          onPrimary: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      child: child!,
    );
  },
  // Локализация
  locale: const Locale('ru', 'RU'),
  // Формат даты
  datePickerModeFirstDay: DatePickerMode.day,
  // Минимальное/максимальное количество дней
  selectableDayPredicate: (DateTime date) {
    // Разрешаем выбирать только будние дни
    return date.weekday != DateTime.saturday &&
        date.weekday != DateTime.sunday;
  },
  // Help text
  helpText: 'Выберите дату',
  // Cancel/Confirm text
  cancelText: 'Отмена',
  confirmText: 'Выбрать',
  // Error text
  errorFormatText: 'Неверный формат',
  errorInvalidText: 'Неверная дата',
  // Initial entry mode
  initialEntryMode: DatePickerEntryMode.calendar, // calendar, input, dropdown
  // Show help text
  showHelpText: true,
  // Show clear button
  showCurrentDate: true,
);
```

### Доступные настройки

| Параметр | Тип | Описание |
|---|---|---|
| `initialDate` | DateTime | Начальная дата |
| `firstDate` | DateTime | Минимальная дата |
| `lastDate` | DateTime | Максимальная дата |
| `locale` | Locale | Локализация |
| `builder` | WidgetBuilder | Кастомизация темы |
| `selectableDayPredicate` | Function | Фильтр доступных дней |
| `initialEntryMode` | DatePickerEntryMode | Режим ввода |
| `helpText` | String | Текст помощи |
| `cancelText` | String | Текст кнопки отмены |
| `confirmText` | String | Текст кнопки подтверждения |

### Фильтрация доступных дат

```dart
// Только будущие даты
final DateTime? picked = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime.now(),
  lastDate: DateTime(2100),
);

// Только будние дни
final DateTime? picked = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  selectableDayPredicate: (DateTime date) {
    return date.weekday >= DateTime.monday &&
        date.weekday <= DateTime.friday;
  },
);

// Только определённые дни месяца
final DateTime? picked = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  selectableDayPredicate: (DateTime date) {
    // Разрешаем только 1-е и 15-е число
    return date.day == 1 || date.day == 15;
  },
);

// Исключение праздничных дней
class HolidayCalendar {
  static final Set<DateTime> _holidays = {
    DateTime(2024, 1, 1),
    DateTime(2024, 1, 2),
    DateTime(2024, 1, 3),
    DateTime(2024, 1, 4),
    DateTime(2024, 1, 5),
    DateTime(2024, 1, 6),
    DateTime(2024, 1, 7),
    DateTime(2024, 1, 8),
    DateTime(2024, 2, 23),
    DateTime(2024, 3, 8),
    DateTime(2024, 5, 1),
    DateTime(2024, 5, 9),
    DateTime(2024, 6, 12),
    DateTime(2024, 11, 4),
  };

  static bool isHoliday(DateTime date) {
    return _holidays.any(
      (holiday) =>
          holiday.year == date.year &&
          holiday.month == date.month &&
          holiday.day == date.day,
    );
  }
}

// Использование
final DateTime? picked = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2000),
  lastDate: DateTime(2100),
  selectableDayPredicate: (DateTime date) {
    return !HolidayCalendar.isHoliday(date);
  },
);
```

## showTimePicker

### Базовое использование

```dart
class TimeSelectionScreen extends StatefulWidget {
  const TimeSelectionScreen({super.key});

  @override
  State<TimeSelectionScreen> createState() => _TimeSelectionScreenState();
}

class _TimeSelectionScreenState extends State<TimeSelectionScreen> {
  TimeOfDay? _selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор времени')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text(
                _selectedTime == null
                    ? 'Выбрать время'
                    : 'Выбрано: ${_selectedTime!.format(context)}',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTime == null
                  ? 'Время не выбрано'
                  : '24ч: ${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      ),
    );
  }
}
```

### Настройки TimePicker

```dart
final TimeOfDay? picked = await showTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
  builder: (context, child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.green,
          onPrimary: Colors.white,
        ),
      ),
      child: child!,
    );
  },
  // Режим ввода
  initialEntryMode: TimePickerEntryMode.dial, // dial, input
  // Показать секунды
  helpText: 'Выберите время',
  cancelText: 'Отмена',
  confirmText: 'Выбрать',
  // Формат 24 часа
  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyAlways(
        alwaysUse24HourFormat: true,
      ),
      child: child!,
    );
  },
);
```

## Комбинированный выбор даты и времени

### DateTime Picker

```dart
class DateTimeSelectionScreen extends StatefulWidget {
  const DateTimeSelectionScreen({super.key});

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState
    extends State<DateTimeSelectionScreen> {
  DateTime? _selectedDateTime;

  Future<void> _selectDateTime(BuildContext context) async {
    // Сначала выбираем дату
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    // Затем выбираем время
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedDateTime ?? DateTime.now(),
      ),
    );

    if (pickedTime == null) return;

    // Комбинируем дату и время
    final DateTime pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedDateTime = pickedDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выбор даты и времени')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _selectDateTime(context),
              child: Text(
                _selectedDateTime == null
                    ? 'Выбрать дату и время'
                    : 'Выбрано: ${_selectedDateTime!.toLocal().toString().replaceAll('.0', '')}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Кастомный DateTime Picker с календарём

```dart
class CustomDateTimePicker extends StatelessWidget {
  final DateTime? selectedDateTime;
  final Function(DateTime) onDateTimeChanged;

  const CustomDateTimePicker({
    super.key,
    this.selectedDateTime,
    required this.onDateTimeChanged,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final existingDateTime = selectedDateTime ?? DateTime.now();
      onDateTimeChanged(DateTime(
        picked.year,
        picked.month,
        picked.day,
        existingDateTime.hour,
        existingDateTime.minute,
      ));
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        selectedDateTime ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      final existingDateTime = selectedDateTime ?? DateTime.now();
      onDateTimeChanged(DateTime(
        existingDateTime.year,
        existingDateTime.month,
        existingDateTime.day,
        picked.hour,
        picked.minute,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Кнопка выбора даты
        ElevatedButton.icon(
          onPressed: () => _selectDate(context),
          icon: const Icon(Icons.calendar_today),
          label: Text(
            selectedDateTime == null
                ? 'Выбрать дату'
                : selectedDateTime!
                    .toLocal()
                    .toString()
                    .split(' ')[0],
          ),
        ),
        const SizedBox(width: 16),
        // Кнопка выбора времени
        ElevatedButton.icon(
          onPressed: () => _selectTime(context),
          icon: const Icon(Icons.access_time),
          label: Text(
            selectedDateTime == null
                ? 'Выбрать время'
                : TimeOfDay.fromDateTime(selectedDateTime!).format(context),
          ),
        ),
      ],
    );
  }
}

// Использование
CustomDateTimePicker(
  selectedDateTime: _selectedDateTime,
  onDateTimeChanged: (dateTime) {
    setState(() => _selectedDateTime = dateTime);
  },
);
```

## Best Practices

1. **Используйте `selectableDayPredicate`** — для ограничения доступных дат.
2. **Настройте `firstDate` и `lastDate`** — чтобы избежать некорректных выборов.
3. **Используйте `builder`** — для кастомизации темы под дизайн-систему.
4. **Используйте `initialEntryMode`** — для выбора режима ввода по умолчанию.
5. **Комбинируйте DatePicker и TimePicker** — для выбора полной даты и времени.
6. **Обрабатывайте null** — пользователь может отменить выбор.
7. **Показывайте форматированную дату** — используйте `toLocal().toString().split(' ')[0]`.
8. **Для 24-часового формата** — используйте `alwaysUse24HourFormat: true`.

## Сравнение DateTime и TimeOfDay

| Характеристика | DateTime | TimeOfDay |
|---|---|---|
| Тип данных | Полный datetime | Только время |
| Часовой пояс | Учитывает | Не учитывает |
| Формат | ISO 8601 | 12/24 часа |
| Форматирование | `toString()` | `format(context)` |
| Сравнение | `isBefore`, `isAfter` | `compareTo` |
| Преобразование | `TimeOfDay.fromDateTime()` | `DateTime(...)` |
