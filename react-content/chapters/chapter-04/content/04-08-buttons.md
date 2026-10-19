# TextButton, ElevatedButton, OutlinedButton — кнопки

## Введение

Кнопки — основной элемент взаимодействия с приложением. Начиная с Material 3, Flutter предоставляет три основных типа кнопок: `ElevatedButton`, `TextButton` и `OutlinedButton`.

## ElevatedButton

Кнопка с тенью и фоном. Используется для основных действий на экране.

### Основные свойства

| Свойство | Тип | Описание |
|----------|-----|----------|
| `onPressed` | `VoidCallback?` | Callback при нажатии |
| `child` | `Widget?` | Содержимое кнопки |
| `style` | `ButtonStyle?` | Стилизация кнопки |
| `focusNode` | `FocusNode?` | Узел фокуса |
| `autofocus` | `bool` | Автофокус |

### Пример использования

```dart
ElevatedButton(
  onPressed: () {
    print('Кнопка нажата');
  },
  child: const Text('Основное действие'),
)
```

### Стилизация ElevatedButton

```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    // Цвета
    foregroundColor: Colors.white,
    backgroundColor: Colors.blue,
    disabledForegroundColor: Colors.grey,
    disabledBackgroundColor: Colors.grey[300],
    // Размеры
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    minimumSize: const Size(88, 36),
    // Скругление
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    // Тень
    elevation: 4,
    // Переходы
    animationDuration: const Duration(milliseconds: 200),
  ),
  child: const Text('Стильная кнопка'),
)
```

## TextButton

Кнопка только с текстом (без фона и тени). Используется для второстепенных действий.

### Пример использования

```dart
TextButton(
  onPressed: () {
    print('Текстовая кнопка');
  },
  child: const Text('Подробнее'),
)
```

### Стилизация TextButton

```dart
TextButton(
  onPressed: () {},
  style: TextButton.styleFrom(
    foregroundColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  ),
  child: const Text('Отмена'),
)
```

## OutlinedButton

Кнопка с рамкой (outline). Используется для действий, которые не являются основными.

### Пример использования

```dart
OutlinedButton(
  onPressed: () {
    print('Кнопка с рамкой');
  },
  child: const Text('Отменить'),
)
```

### Стилизация OutlinedButton

```dart
OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.blue,
    side: const BorderSide(width: 2, color: Colors.blue),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: const Text('Настроить'),
)
```

## ButtonStyle

`ButtonStyle` определяет визуальное состояние кнопки.

### Свойства ButtonStyle

| Свойство | Тип | Описание |
|----------|-----|----------|
| `backgroundColor` | `MaterialStateProperty<Color?>` | Цвет фона |
| `foregroundColor` | `MaterialStateProperty<Color?>` | Цвет переднего плана |
| `elevation` | `MaterialStateProperty<double?>` | Высота тени |
| `padding` | `MaterialStateProperty<EdgeInsets?>` | Внутренние отступы |
| `minimumSize` | `MaterialStateProperty<Size?>` | Минимальный размер |
| `shape` | `MaterialStateProperty<OutlinedBorder?>` | Форма кнопки |
| `overlayColor` | `MaterialStateProperty<Color?>` | Цвет оверлея |
| `shadowColor` | `MaterialStateProperty<Color?>` | Цвет тени |
| `surfaceTintColor` | `MaterialStateProperty<Color?>` | Цвет тени поверхности |

### MaterialStateProperty

```dart
// Кастомный цвет в зависимости от состояния
ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith((states) {
    if (states.contains(MaterialState.pressed)) {
      return Colors.blue.shade700;
    }
    if (states.contains(MaterialState.disabled)) {
      return Colors.grey[300];
    }
    return Colors.blue;
  }),
)
```

### MaterialState состояния

| Состояние | Описание |
|-----------|----------|
| `pressed` | Кнопка нажата |
| `hovered` | Курсор над кнопкой |
| `focused` | Кнопка в фокусе |
| `disabled` | Кнопка отключена |
| `selected` | Кнопка выбрана |
| `error` | Кнопка в состоянии ошибки |

## IconButton и FloatingActionButton

### IconButton

```dart
IconButton(
  onPressed: () {
    print('Иконка нажата');
  },
  icon: const Icon(Icons.favorite),
  color: Colors.red,
  hoverColor: Colors.redAccent,
  splashRadius: 24,
)
```

### FloatingActionButton

```dart
FloatingActionButton(
  onPressed: () {},
  child: const Icon(Icons.add),
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  elevation: 4,
  tooltip: 'Добавить',
)
```

### FloatingActionButton.extended

```dart
FloatingActionButton.extended(
  onPressed: () {},
  label: const Text('Добавить'),
  icon: const Icon(Icons.add),
  backgroundColor: Colors.blue,
)
```

## Кнопки в разных состояниях

```dart
// Активная кнопка
ElevatedButton(
  onPressed: () {},
  child: const Text('Активна'),
)

// Отключённая кнопка
ElevatedButton(
  onPressed: null, // null = отключено
  child: const Text('Отключена'),
)

// Кнопка с индикатором загрузки
ElevatedButton(
  onPressed: isLoading ? null : () => submitForm(),
  child: isLoading
      ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : const Text('Отправить'),
)
```

## Best Practices

1. **Используйте `ElevatedButton`** для основных действий на экране (например, «Отправить форму»).

2. **Используйте `TextButton`** для второстепенных действий (например, «Отмена», «Подробнее»).

3. **Используйте `OutlinedButton`** для действий, которые не являются основными, но важными.

4. **Всегда обрабатывайте состояние disabled** — отключайте кнопки при невалидных данных формы.

5. **Используйте `ButtonStyle`** для единообразного стилирования кнопок во всём приложении.

6. **Используйте `MaterialStateProperty.resolveWith`** для кастомизации цветов в зависимости от состояния.

7. **Показывайте индикатор загрузки** при длительных операциях:
   ```dart
   ElevatedButton(
     onPressed: isLoading ? null : submit,
     child: isLoading
         ? const SizedBox(
             height: 20,
             width: 20,
             child: CircularProgressIndicator(strokeWidth: 2),
           )
         : const Text('Отправить'),
   )
   ```

8. **Используйте `tooltip`** для `IconButton` и `FloatingActionButton` для улучшения доступности.
