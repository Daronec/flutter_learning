# Expanded, Flexible — распределение пространства

## Введение

`Expanded` и `Flexible` — виджеты для управления распределением свободного пространства в `Row`, `Column` и `Flex`. Они позволяют создавать адаптивные интерфейсы, которые подстраиваются под размер экрана.

## Flex

Перед изучением `Expanded` и `Flexible` нужно понять базовый виджет `Flex`.

### Flex — базовый класс

`Row` и `Column` являются сокращениями для `Flex`:

```dart
// Эти эквивалентны:
Row(children: [...])
// равносильно:
Flex(direction: Axis.horizontal, children: [...])

Column(children: [...])
// равносильно:
Flex(direction: Axis.vertical, children: [...])
```

## Expanded

Виджет `Expanded` заставляет дочерний виджет занимать всё доступное свободное пространство.

### Основные свойства Expanded

| Свойство | Тип | Описание |
|----------|-----|----------|
| `flex` | `int` | Коэффициент гибкости (по умолчанию 1) |
| `child` | `Widget?` | Дочерний виджет |

### Пример использования Expanded

```dart
Row(
  children: [
    const Text('Фиксированный'),
    const SizedBox(width: 8),
    Expanded(
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Введите текст',
        ),
      ),
    ),
    const SizedBox(width: 8),
    const Icon(Icons.search),
  ],
)
```

### Flex-коэффициенты

```dart
Row(
  children: [
    // Занимает 1/4 пространства
    Expanded(flex: 1, child: Container(color: Colors.red, height: 50)),
    // Занимает 2/4 (1/2) пространства
    Expanded(flex: 2, child: Container(color: Colors.green, height: 50)),
    // Занимает 1/4 пространства
    Expanded(flex: 1, child: Container(color: Colors.blue, height: 50)),
  ],
)
```

## Flexible

Виджет `Flexible` позволяет дочернему виджету сжиматься и расширяться, но не обязывает его занимать всё пространство.

### Основные свойства Flexible

| Свойство | Тип | Описание |
|----------|-----|----------|
| `flex` | `int` | Коэффициент гибкости (по умолчанию 1) |
| `fit` | `FlexFit` | Режим заполнения пространства |
| `child` | `Widget?` | Дочерний виджет |

### FlexFit

| Значение | Описание |
|----------|----------|
| `loose` | Виджет может быть любого размера в пределах доступного |
| `tight` | Виджет должен занять всё доступное пространство (как `Expanded`) |

### Flexible с loose

```dart
Row(
  children: [
    const Text('Текст'),
    Flexible(
      fit: FlexFit.loose,
      child: Container(
        color: Colors.blue,
        // Может быть любого размера, не растягивается
        child: const Text('Гибкий блок'),
      ),
    ),
  ],
)
```

### Flexible с tight

```dart
Row(
  children: [
    const Text('Текст'),
    Flexible(
      fit: FlexFit.tight,
      child: Container(
        color: Colors.blue,
        // Растягивается как Expanded
        child: const Text('Гибкий блок'),
      ),
    ),
  ],
)
```

## Expanded vs Flexible

| Характеристика | Expanded | Flexible |
|----------------|----------|----------|
| Занимает пространство | Обязательно | По желанию |
| Эквивалент | `Flexible(fit: FlexFit.tight)` | `Flexible(fit: FlexFit.loose)` |
| Минимальный размер | Растягивается до максимума | Может сжиматься до intrinsic размера |
| Когда использовать | Когда нужно заполнить пространство | Когда нужно гибкое поведение |

### Наглядный пример различий

```dart
// Expanded — всегда растягивается
Row(
  children: [
    const Text('Фикс: '),
    Expanded(
      child: Container(
        color: Colors.blue,
        child: const Text('Мини'), // Растянется на всю ширину
      ),
    ),
  ],
)

// Flexible — может быть минимального размера
Row(
  children: [
    const Text('Фикс: '),
    Flexible(
      child: Container(
        color: Colors.blue,
        child: const Text('Мини'), // Останется компактным
      ),
    ),
  ],
)
```

## Комбинирование с фиксированными элементами

```dart
Row(
  children: [
    // Фиксированная ширина
    const SizedBox(width: 80, child: Text('Лейбл')),
    // Гибкая часть
    Expanded(
      child: TextField(
        decoration: const InputDecoration(hintText: 'Значение'),
      ),
    ),
    // Фиксированная кнопка
    const SizedBox(
      width: 100,
      child: ElevatedButton(
        onPressed: () {},
        child: Text('OK'),
      ),
    ),
  ],
)
```

## Вложенные Flex-виджеты

```dart
Column(
  children: [
    // Заголовок занимает 1 часть
    Expanded(
      flex: 1,
      child: Container(color: Colors.blue, child: const Text('Header')),
    ),
    // Контент занимает 3 части
    Expanded(
      flex: 3,
      child: Container(color: Colors.green, child: const Text('Content')),
    ),
    // Футер занимает 1 часть
    Expanded(
      flex: 1,
      child: Container(color: Colors.red, child: const Text('Footer')),
    ),
  ],
)
```

## Common Pitfalls (Распространённые ошибки)

### 1. Expanded внутри Scrollable без ограничений

```dart
// ❌ Ошибка: Expanded внутри SingleChildScrollView
SingleChildScrollView(
  child: Column(
    children: [
      const Text('Заголовок'),
      Expanded(
        child: Text('Контент'), // Ошибка: нет ограничений
      ),
    ],
  ),
)

// ✅ Правильно: используйте Flexible
SingleChildScrollView(
  child: Column(
    children: [
      const Text('Заголовок'),
      Flexible(
        child: Text('Контент'),
      ),
    ],
  ),
)
```

### 2. Несколько Expanded с разными требованиями

```dart
// ❌ Ошибка: два Expanded с разными ограничениями
Row(
  children: [
    Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 100),
        child: Container(color: Colors.blue),
      ),
    ),
    Expanded(
      child: Container(color: Colors.red),
    ),
  ],
)

// ✅ Правильно: используйте Flexible для ограниченного
Row(
  children: [
    Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 100),
        child: Container(color: Colors.blue),
      ),
    ),
    Expanded(
      child: Container(color: Colors.red),
    ),
  ],
)
```

### 3. Expanded внутри Column без SingleChildScrollView

```dart
// ❌ Ошибка: Column с Expanded внутри Column (неограниченная высота)
Column(
  children: [
    const Text('Заголовок'),
    Expanded(
      child: Text('Контент'), // Ошибка: Column не имеет ограничений
    ),
  ],
)

// ✅ Правильно: оберните в SingleChildScrollView или используйте SizedBox
Column(
  children: [
    const Text('Заголовок'),
    Expanded(
      child: SingleChildScrollView(
        child: Text('Контент'),
      ),
    ),
  ],
)
```

## Best Practices

1. **Используйте `Expanded`**, когда дочерний виджет должен заполнить всё доступное пространство.

2. **Используйте `Flexible`**, когда дочерний виджет может быть меньше доступного пространства.

3. **Используйте `Flexible(fit: FlexFit.tight)`** вместо `Expanded` для более явного кода.

4. **Не используйте `Expanded` внутри `SingleChildScrollView`** — используйте `Flexible` или `SizedBox`.

5. **Используйте flex-коэффициенты** для пропорционального распределения пространства:
   ```dart
   Row(
     children: [
       Expanded(flex: 2, child: LeftPanel()),
       Expanded(flex: 1, child: RightPanel()),
     ],
   )
   ```

6. **Комбинируйте фиксированные и гибкие виджеты** для создания адаптивных лейаутов:
   ```dart
   Row(
     children: [
       SizedBox(width: 50, child: Icon(Icons.menu)),
       Expanded(child: TextField()),
       SizedBox(width: 50, child: Icon(Icons.search)),
     ],
   )
   ```
