---
tags:
  - widgets
  - ui
  - basics
chapter: 4
section: 4
title: Row, Column, Stack — основные лейауты
alias: 04 04 row column stack
status: complete
---

# Row, Column, Stack — основные лейауты

## Введение

`Row`, `Column` и `Stack` — три основных виджета-лейаута в Flutter. Понимание их работы — основа для создания любого пользовательского интерфейса.

## Row

Виджет `Row` размещает дочерние виджеты горизонтально (слева направо).

### Основные свойства Row

| Свойство | Тип | Описание |
|----------|-----|----------|
| `mainAxisAlignment` | `MainAxisAlignment` | Распределение по главной оси (горизонталь) |
| `crossAxisAlignment` | `CrossAxisAlignment` | Распределение по поперечной оси (вертикаль) |
| `mainAxisSize` | `MainAxisSize` | Размер по главной оси |
| `textDirection` | `TextDirection?` | Направление текста |
| `verticalDirection` | `VerticalDirection` | Порядок размещения по вертикали |

### MainAxisAlignment

| Значение | Описание |
|----------|----------|
| `start` | Все элементы в начале |
| `end` | Все элементы в конце |
| `center` | Центрирование |
| `spaceBetween` | Равные промежутки между элементами |
| `spaceAround` | Равные промежутки вокруг элементов |
| `spaceEvenly` | Равные промежутки везде |

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: const [
    Text('Левый'),
    Text('Правый'),
  ],
)

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: const [
    Text('Центр'),
  ],
)
```

### CrossAxisAlignment

| Значение | Описание |
|----------|----------|
| `start` | Выравнивание по началу (сверху) |
| `end` | Выравнивание по концу (снизу) |
| `center` | Центрирование по вертикали |
| `stretch` | Растянуть на всю высоту |
| `baseline` | Выравнивание по базовой линии текста |

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: const [
    Icon(Icons.star, size: 40),
    SizedBox(width: 8),
    Text('Большая иконка'),
  ],
)

Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: const [
    Icon(Icons.star),
    Text('Растянутый'),
  ],
)
```

### MainAxisSize

| Значение | Описание |
|----------|----------|
| `max` | Row занимает всю доступную ширину (по умолчанию) |
| `min` | Row занимает только пространство, необходимое детям |

```dart
// Row занимает всю ширину (children выровнены по центру)
Row(
  mainAxisSize: MainAxisSize.max,
  mainAxisAlignment: MainAxisAlignment.center,
  children: const [Text('Центр')],
)

// Row занимает только пространство детей
Row(
  mainAxisSize: MainAxisSize.min,
  children: const [Text('Минимальная ширина')],
)
```

## Column

Виджет `Column` размещает дочерние виджеты вертикально (сверху вниз). Использует те же свойства, что и `Row`, но оси поменяны местами.

### Основные свойства Column

| Свойство | Тип | Описание |
|----------|-----|----------|
| `mainAxisAlignment` | `MainAxisAlignment` | Распределение по главной оси (вертикаль) |
| `crossAxisAlignment` | `CrossAxisAlignment` | Распределение по поперечной оси (горизонталь) |
| `mainAxisSize` | `MainAxisSize` | Размер по главной оси |

### Пример Column

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: const [
    Icon(Icons.home, size: 48),
    SizedBox(height: 8),
    Text('Главная страница', style: TextStyle(fontSize: 18)),
    SizedBox(height: 4),
    Text('Добро пожаловать', style: TextStyle(color: Colors.grey)),
  ],
)
```

### VerticalDirection

| Значение | Описание |
|----------|----------|
| `down` | Размещение сверху вниз (по умолчанию) |
| `up` | Размещение снизу вверх |

```dart
Column(
  verticalDirection: VerticalDirection.up,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: const [
    Text('Первый внизу'),
    Text('Второй выше'),
    Text('Третий наверху'),
  ],
)
```

## Stack

Виджет `Stack` размещает дочерние виджеты друг поверх друга (слоями).

### Основные свойства Stack

| Свойство | Тип | Описание |
|----------|-----|----------|
| `alignment` | `AlignmentGeometry` | Выравнивание дочерних виджетов |
| `textDirection` | `TextDirection?` | Направление текста |
| `fit` | `StackFit` | Размер дочерних виджетов |
| `overflow` | `StackOverflow` | Поведение при переполнении |

### StackFit

| Значение | Описание |
|----------|----------|
| `loose` | Дочерние виджеты сохраняют свои размеры |
| `expand` | Дочерние виджеты растягиваются до размера Stack |
| `passthrough` | Размер Stack определяется детьми |

```dart
Stack(
  fit: StackFit.loose,
  children: const [
    Text('Первый слой'),
    Text('Второй слой'),
  ],
)
```

### Alignment в Stack

```dart
// Выравнивание по левому верхнему углу (по умолчанию)
Stack(
  alignment: Alignment.topLeft,
  children: [
    Container(width: 200, height: 200, color: Colors.blue),
    const Icon(Icons.star, size: 32, color: Colors.yellow),
  ],
)

// Выравнивание по центру
Stack(
  alignment: Alignment.center,
  children: [
    Container(width: 200, height: 200, color: Colors.blue),
    const Icon(Icons.star, size: 32, color: Colors.yellow),
  ],
)

// Выравнивание по правому нижнему углу
Stack(
  alignment: Alignment.bottomRight,
  children: [
    Container(width: 200, height: 200, color: Colors.blue),
    const Icon(Icons.favorite, size: 24, color: Colors.red),
  ],
)
```

### Positioned — позиционирование в Stack

Виджет `Positioned` позволяет точно разместить дочерний элемент внутри `Stack`:

```dart
Stack(
  children: [
    Container(
      width: 200,
      height: 200,
      color: Colors.blue,
    ),
    Positioned(
      top: 10,
      left: 10,
      child: const Icon(Icons.star, size: 32, color: Colors.yellow),
    ),
    Positioned(
      bottom: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '3',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    ),
  ],
)
```

## Примеры комбинирования

### Карточка товара

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        children: [
          Image.asset(
            'assets/images/product.jpg',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '-20%',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Название товара',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '1 200 ₽',
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
                const Icon(Icons.favorite_border, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
)
```

## Best Practices

1. **Используйте `Expanded` внутри `Row`/`Column`** для распределения свободного пространства.

2. **Используйте `mainAxisSize: MainAxisSize.min`** для `Row`/`Column`, когда хотите, чтобы они занимали только пространство детей.

3. **Используйте `Stack` с `Positioned`** для точного позиционирования элементов поверх друг друга.

4. **Избегайте вложенных `Row`/`Column`** — используйте `Stack` или `CustomMultiChildLayout` для сложных лейаутов.

5. **Используйте `wrap`-виджеты** (`Wrap`, `FlexWrap`) для автоматического переноса элементов:
   ```dart
   Wrap(
     spacing: 8,
     runSpacing: 4,
     children: List.generate(20, (i) => Chip(label: Text('$i'))),
   )
   ```

6. **Используйте `LayoutBuilder`** для адаптивных лейаутов:
   ```dart
   LayoutBuilder(
     builder: (context, constraints) {
       if (constraints.maxWidth > 600) {
         return Row(children: [...]);
       }
       return Column(children: [...]);
     },
   )
   ```
