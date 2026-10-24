---
tags:
  - layout
  - responsive
  - ui
chapter: 5
section: 6
title: AspectRatio, FittedBox, OverflowBox
alias: 05 06 aspectratio fittedbox
status: complete
---

# AspectRatio, FittedBox, OverflowBox

Эти три виджета управляют размерами и масштабированием дочерних элементов: `AspectRatio` поддерживает пропорции, `FittedBox` масштабирует содержимое, а `OverflowBox` позволяет выходить за пределы ограничений.

## AspectRatio — поддержание пропорций

`AspectRatio` принудительно задаёт соотношение ширины к высоте для child:

```dart
AspectRatio({
  required this.aspectRatio,      // ширина / высота
  double childAspectRatio = 1.0,  // альтернативный параметр
  required Widget child,
})
```

### aspectRatio — ширина к высоте

```dart
// Квадрат: ширина = высота
AspectRatio(
  aspectRatio: 1.0,
  child: Container(color: Colors.red),
)

// Широкий прямоугольник: ширина в 2 раза больше высоты
AspectRatio(
  aspectRatio: 2.0,
  child: Container(color: Colors.blue),
)

// Высокий прямоугольник: высота в 2 раза больше ширины
AspectRatio(
  aspectRatio: 0.5,
  child: Container(color: Colors.green),
)
```

### childAspectRatio — альтернативный параметр

```dart
// childAspectRatio = ширина / высота
// aspectRatio = высота / ширина (обратное значение)

AspectRatio(
  childAspectRatio: 16 / 9,
  child: Container(color: Colors.orange),
)
// То же самое, что aspectRatio: 9 / 16
```

### Практические примеры

#### Адаптивное изображение

```dart
AspectRatio(
  aspectRatio: 16 / 9,
  child: Image.network(
    'https://example.com/image.jpg',
    fit: BoxFit.cover,
  ),
)
```

#### Карточка с видео

```dart
AspectRatio(
  aspectRatio: 4 / 3,
  child: Card(
    child: Column(
      children: [
        Expanded(
          child: VideoPlayer(_controller),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Название видео'),
        ),
      ],
    ),
  ),
)
```

#### Сетка с одинаковыми пропорциями

```dart
Row(
  children: [
    Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(color: Colors.red),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(color: Colors.blue),
      ),
    ),
  ],
)
// Два квадрата одинакового размера
```

## FittedBox — масштабирование содержимого

`FittedBox` масштабирует child, чтобы он поместился в доступное пространство:

```dart
FittedBox({
  this.fit = BoxFit.scaleDown,
  this.alignment = Alignment.center,
  this.child,
})
```

### BoxFit — режимы масштабирования

| Режим | Описание | Поведение |
|-------|----------|-----------|
| `fill` | Заполнить | Растягивает child на весь доступный размер (искажает пропорции) |
| `fitWidth` | По ширине | Масштабирует по ширине, высота подстраивается (может выходить за пределы) |
| `fitHeight` | По высоте | Масштабирует по высоте, ширина подстраивается (может выходить за пределы) |
| `scaleDown` | Уменьшить | Масштабирует как `contain`, но если child меньше — не растягивает |
| `contain` | Содержать | Масштабирует так, чтобы child полностью поместился (сохраняет пропорции) |
| `cover` | Покрыть | Масштабирует так, чтобы child полностью покрыл (может обрезаться) |
| `none` | Без масштабирования | Child размещается без масштабирования |

### Примеры BoxFit

```dart
// BoxFit.fill — искажает пропорции
FittedBox(
  fit: BoxFit.fill,
  child: Container(
    width: 100,
    height: 200,
    color: Colors.red,
    child: const Center(child: Text('Искажён')),
  ),
)
// Контейнер растянется на всю доступную область

// BoxFit.contain — сохраняет пропорции, полностью помещается
FittedBox(
  fit: BoxFit.contain,
  child: Container(
    width: 100,
    height: 200,
    color: Colors.blue,
    child: const Center(child: Text('Вместится')),
  ),
)
// Контейнер уменьшится, чтобы полностью поместиться

// BoxFit.cover — сохраняет пропорции, может обрезаться
FittedBox(
  fit: BoxFit.cover,
  child: Container(
    width: 100,
    height: 200,
    color: Colors.green,
    child: const Center(child: Text('Может обрезаться')),
  ),
)
// Контейнер увеличится, чтобы покрыть всю область

// BoxFit.fitWidth — по ширине
FittedBox(
  fit: BoxFit.fitWidth,
  child: Container(
    width: 200,
    height: 100,
    color: Colors.orange,
    child: const Center(child: Text('По ширине')),
  ),
)
// Ширина = доступная, высота масштабируется

// BoxFit.fitHeight — по высоте
FittedBox(
  fit: BoxFit.fitHeight,
  child: Container(
    width: 200,
    height: 100,
    color: Colors.purple,
    child: const Center(child: Text('По высоте')),
  ),
)
// Высота = доступная, ширина масштабируется

// BoxFit.scaleDown — как contain, но без растягивания
FittedBox(
  fit: BoxFit.scaleDown,
  child: Container(
    width: 50,
    height: 50,
    color: Colors.teal,
    child: const Center(child: Text('Маленький')),
  ),
)
// Если child меньше доступного — остаётся без изменений

// BoxFit.none — без масштабирования
FittedBox(
  fit: BoxFit.none,
  child: Container(
    width: 300,
    height: 300,
    color: Colors.amber,
    child: const Center(child: Text('Без масштабирования')),
  ),
)
// Child размещается с естественным размером
```

### Alignment в FittedBox

```dart
FittedBox(
  fit: BoxFit.contain,
  alignment: Alignment.topLeft,
  child: Container(
    width: 50,
    height: 50,
    color: Colors.red,
  ),
)
// Контейнер 50×50 будет размещён в верхнем левом углу
```

## OverflowBox — выход за пределы ограничений

`OverflowBox` позволяет child выйти за пределы доступных ограничений:

```dart
OverflowBox({
  this.minWidth,
  this.maxWidth,
  this.minHeight,
  this.maxHeight,
  required Widget child,
})
```

### Как работает OverflowBox

```
Родитель даёт OverflowBox:
  minWidth: 0,  maxWidth: 100
  minHeight: 0, maxHeight: 100
───────────────────────────────────────
OverflowBox накладывает свои ограничения:
  minWidth: null,  maxWidth: 200
  minHeight: null, maxHeight: 200
───────────────────────────────────────
Child получает:
  minWidth: 0,  maxWidth: 200
  minHeight: 0, maxHeight: 200
```

### Примеры использования

#### Горизонтальная прокрутка контента

```dart
OverflowBox(
  maxWidth: double.infinity,
  child: Row(
    children: [
      Container(width: 200, color: Colors.red),
      Container(width: 200, color: Colors.green),
      Container(width: 200, color: Colors.blue),
    ],
  ),
)
// Row может быть шире родителя
```

#### Анимация выхода за границы

```dart
class OverflowAnimation extends StatefulWidget {
  @override
  _OverflowAnimationState createState() => _OverflowAnimationState();
}

class _OverflowAnimationState extends State<OverflowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 50).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxHeight: 200 + _animation.value,
      child: Container(
        color: Colors.blue.shade100,
        child: const Center(
          child: Text('Растягивающийся контейнер'),
        ),
      ),
    );
  }
}
```

#### Бесконечная прокрутка

```dart
OverflowBox(
  minWidth: double.infinity,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(
        10,
        (index) => Container(
          width: 150,
          height: 200,
          margin: const EdgeInsets.all(8),
          color: Colors.primaries[index % Colors.primaries.length].shade200,
          child: Center(child: Text('$index')),
        ),
      ),
    ),
  ),
)
```

## Combinations — совместное использование

```dart
// AspectRatio + FittedBox — изображение с пропорциями и масштабированием
AspectRatio(
  aspectRatio: 16 / 9,
  child: FittedBox(
    fit: BoxFit.cover,
    child: Container(
      width: 800,
      height: 450,
      color: Colors.blue,
      child: const Center(child: Text('Изображение')),
    ),
  ),
)
```

```dart
// OverflowBox + FittedBox — масштабирование с выходом за границы
OverflowBox(
  maxWidth: double.infinity,
  maxHeight: double.infinity,
  child: FittedBox(
    fit: BoxFit.contain,
    child: Container(
      width: 500,
      height: 500,
      color: Colors.red,
      child: const Center(child: Text('Масштабированный')),
    ),
  ),
)
```

## Best Practices

- Используйте `AspectRatio` для изображений, видео и карточек с фиксированными пропорциями
- `BoxFit.contain` — когда важно видеть весь контент без обрезки
- `BoxFit.cover` — для фоновых изображений, где важно заполнить всю область
- `BoxFit.fill` — когда искажение пропорций допустимо
- `FittedBox` с `BoxFit.scaleDown` — когда child может быть как больше, так и меньше
- `OverflowBox` — для горизонтальной прокрутки и анимаций
- `OverflowBox` не создаёт прокрутку — используйте с `SingleChildScrollView` для скролла
- Комбинируйте `AspectRatio` и `FittedBox` для адаптивных изображений
