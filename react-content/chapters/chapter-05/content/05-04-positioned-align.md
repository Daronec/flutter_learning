# Positioned, Align, Center — абсолютное позиционирование

Абсолютное позиционирование позволяет размещать виджеты в конкретных координатах относительно родительского контейнера. В Flutter для этого используются виджеты `Stack`, `Positioned`, `Align` и `Center`.

## Stack — контейнер для наложения виджетов

`Stack` — это родительский виджет, который размещает дочерние элементы поверх друг друга. Первый элемент находится внизу, последний — наверху.

### Базовое использование

```dart
Stack(
  children: [
    Container(
      width: 200,
      height: 200,
      color: Colors.blue,
    ),
    Container(
      width: 100,
      height: 100,
      color: Colors.red,
    ),
    Container(
      width: 50,
      height: 50,
      color: Colors.green,
    ),
  ],
)
// Синий внизу, красный посередине, зелёный сверху
```

## Positioned — абсолютное позиционирование

`Positioned` размещает child в конкретных координатах относительно `Stack`:

```dart
Positioned({
  this.left,      // расстояние от левого края
  this.top,       // расстояние от верхнего края
  this.right,     // расстояние от правого края
  this.bottom,    // расстояние от нижнего края
  this.width,     // ширина child
  this.height,    // высота child
  required Widget child,
})
```

### Правила использования Positioned

| Правило | Описание |
|---------|----------|
| Можно задать **left + top** | Фиксирует позицию от левого верхнего угла |
| Можно задать **left + right + width** | Фиксирует горизонтальное положение и размер |
| Можно задать **top + bottom + height** | Фиксирует вертикальное положение и размер |
| Нельзя задать **left + right** без **width** | Flutter не может определить позицию |
| Нельзя задать **top + bottom** без **height** | Flutter не может определить позицию |

### Примеры позиционирования

```dart
Stack(
  children: [
    // Фоновый элемент
    Container(
      width: 300,
      height: 300,
      color: Colors.grey.shade300,
    ),

    // Позиционирование от верхнего левого угла
    Positioned(
      left: 20,
      top: 20,
      child: Container(
        width: 80,
        height: 80,
        color: Colors.red,
        child: const Center(child: Text('LT')),
      ),
    ),

    // Позиционирование от верхнего правого угла
    Positioned(
      right: 20,
      top: 20,
      child: Container(
        width: 80,
        height: 80,
        color: Colors.green,
        child: const Center(child: Text('RT')),
      ),
    ),

    // Позиционирование от нижнего левого угла
    Positioned(
      left: 20,
      bottom: 20,
      child: Container(
        width: 80,
        height: 80,
        color: Colors.blue,
        child: const Center(child: Text('LB')),
      ),
    ),

    // Позиционирование от нижнего правого угла
    Positioned(
      right: 20,
      bottom: 20,
      child: Container(
        width: 80,
        height: 80,
        color: Colors.orange,
        child: const Center(child: Text('RB')),
      ),
    ),

    // Центрирование через Positioned
    Positioned(
      left: 110,  // (300 - 80) / 2
      top: 110,   // (300 - 80) / 2
      child: Container(
        width: 80,
        height: 80,
        color: Colors.purple,
        child: const Center(child: Text('C')),
      ),
    ),
  ],
)
```

### Позиционирование с width/height

```dart
Stack(
  children: [
    Container(
      width: 300,
      height: 300,
      color: Colors.grey.shade300,
    ),

    // Растягивание на всю ширину
    Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 50,
      child: Container(color: Colors.red),
    ),

    // Растягивание на всю высоту
    Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      width: 50,
      child: Container(color: Colors.blue),
    ),
  ],
)
```

## Align — выравнивание внутри Stack

`Align` размещает child в определённой позиции внутри Stack без явного задания координат:

```dart
Align({
  this.alignment = Alignment.center,  // позиция child внутри Stack
  this.widthFactor,                   // ширина = child.width × factor
  this.heightFactor,                  // высота = child.height × factor
  required Widget child,
})
```

### Alignment — точки позиционирования

| Значение | Описание | Координаты |
|----------|----------|------------|
| `topLeft` | Верхний левый угол | (-1, -1) |
| `topCenter` | Верхний центр | (0, -1) |
| `topRight` | Верхний правый угол | (1, -1) |
| `centerLeft` | Левый центр | (-1, 0) |
| `center` | Центр | (0, 0) |
| `centerRight` | Правый центр | (1, 0) |
| `bottomLeft` | Нижний левый угол | (-1, -1) |
| `bottomCenter` | Нижний центр | (0, 1) |
| `bottomRight` | Нижний правый угол | (1, 1) |

### Примеры Align

```dart
Stack(
  children: [
    Container(
      width: 300,
      height: 300,
      color: Colors.grey.shade300,
    ),

    // По центру (по умолчанию)
    Align(
      alignment: Alignment.center,
      child: Container(
        width: 100,
        height: 100,
        color: Colors.red,
        child: const Center(child: Text('Center')),
      ),
    ),

    // Вверху слева
    Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: 80,
        height: 80,
        color: Colors.green,
        child: const Center(child: Text('TL')),
      ),
    ),

    // Внизу справа
    Align(
      alignment: Alignment.bottomRight,
      child: Container(
        width: 80,
        height: 80,
        color: Colors.blue,
        child: const Center(child: Text('BR')),
      ),
    ),
  ],
)
```

### WidthFactor и HeightFactor

```dart
Stack(
  children: [
    Container(
      width: 300,
      height: 300,
      color: Colors.grey.shade300,
    ),

    // Ширина = ширина child × 2
    Align(
      widthFactor: 2,
      child: Container(
        width: 50,
        height: 50,
        color: Colors.red,
      ),
    ),
    // Результат: контейнер шириной 100px, отцентрованный

    // Высота = высота child × 2
    Align(
      heightFactor: 2,
      child: Container(
        width: 50,
        height: 50,
        color: Colors.blue,
      ),
    ),
    // Результат: контейнер высотой 100px, отцентрованный
  ],
)
```

## Center — упрощённое центрирование

`Center` — это частный случай `Align` с `alignment: Alignment.center`:

```dart
Center(
  child: Container(
    width: 100,
    height: 100,
    color: Colors.red,
    child: const Text('По центру'),
  ),
)
// Эквивалентно:
// Align(
//   alignment: Alignment.center,
//   child: Container(...),
// )
```

## Stack + Positioned — реальные примеры

### Бейдж с количеством

```dart
Stack(
  clipBehavior: Clip.none,
  children: [
    Icon(Icons.notifications, size: 40, color: Colors.grey),
    Positioned(
      right: -5,
      top: -5,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        child: const Text(
          '3',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ],
)
```

### Карточка с изображением и текстом поверх

```dart
Stack(
  children: [
    // Изображение
    Image.asset(
      'assets/hero.jpg',
      width: 300,
      height: 200,
      fit: BoxFit.cover,
    ),

    // Градиент снизу
    Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
      ),
    ),

    // Текст поверх изображения
    Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Заголовок',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'Описание',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    ),
  ],
)
```

### Кнопка с иконкой

```dart
Stack(
  alignment: Alignment.center,
  children: [
    Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
    ),
    const Icon(Icons.add, color: Colors.white, size: 30),
  ],
)
```

## Best Practices

- Используйте `Stack` для наложения элементов друг на друга
- `Positioned` — для точного позиционирования с координатами
- `Align` — для выравнивания по точкам (углы, центр)
- `Center` — для простого центрирования
- `clipBehavior: Clip.none` — если child должен выходить за пределы Stack
- Используйте `widthFactor`/`heightFactor` в `Align` для масштабирования child
- Избегайте жёстких координат в `Positioned` — используйте `LayoutBuilder` для адаптивности
- Комбинируйте `Stack` с `Container` для создания сложных визуальных эффектов
