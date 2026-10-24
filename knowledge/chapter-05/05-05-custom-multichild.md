---
tags:
  - layout
  - responsive
  - ui
chapter: 5
section: 5
title: CustomMultiChildLayout — кастомные лейауты
alias: 05 05 custom multichild
status: complete
---

# CustomMultiChildLayout — кастомные лейауты

`CustomMultiChildLayout` позволяет создавать полностью кастомные макеты с помощью `LayoutDelegate`. Это самый гибкий инструмент для управления расположением дочерних элементов в Flutter.

## Что такое CustomMultiChildLayout

`CustomMultiChildLayout` — это виджет, который размещает нескольких дочерних элементов, используя пользовательскую логику позиционирования, определяемую `LayoutDelegate`.

```dart
CustomMultiChildLayout(
  delegate: MyLayoutDelegate(),
  children: [
    LayoutId(id: 'header', child: Container(color: Colors.red)),
    LayoutId(id: 'body', child: Container(color: Colors.green)),
    LayoutId(id: 'footer', child: Container(color: Colors.blue)),
  ],
)
```

## LayoutId — идентификация дочерних элементов

Каждый child в `CustomMultiChildLayout` должен быть обернут в `LayoutId`, который присваивает ему уникальный идентификатор:

```dart
LayoutId({
  required this.id,
  required Widget child,
  this.optional = false,
})
```

| Параметр | Описание |
|----------|----------|
| `id` | Уникальный идентификатор для поиска в `LayoutDelegate` |
| `child` | Размещаемый виджет |
| `optional` | Если true, child не вызовет ошибку при отсутствии в delegate |

```dart
CustomMultiChildLayout(
  delegate: MyLayoutDelegate(),
  children: [
    LayoutId(
      id: 'background',
      child: Container(color: Colors.grey.shade200),
    ),
    LayoutId(
      id: 'title',
      child: const Text('Заголовок'),
    ),
    LayoutId(
      id: 'content',
      child: const Text('Содержимое'),
    ),
  ],
)
```

## LayoutDelegate — логика размещения

`LayoutDelegate` — это абстрактный класс, который определяет, как размещаются дочерние элементы:

```dart
class MyLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    // size — доступный размер для всего макета
    // LayoutId('id') — получение child по идентификатору
    // childSize['id'] — размер child после layout
    // placeChild('id', Offset(x, y)) — размещение child
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    // Возвращает true, если delegate изменился и layout нужно пересчитать
    return false;
  }
}
```

### Методы LayoutDelegate

| Метод | Описание |
|-------|----------|
| `hasChild(String id)` | Проверка наличия child с данным id |
| `childSize(String id)` | Получение размера child |
| `placeChild(String id, Offset location)` | Размещение child в точке location |
| `size` | Доступный размер для layout |

### Пример: простой delegate

```dart
class SimpleLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    // Размещаем child 'top' вверху по центру
    if (hasChild('top')) {
      final topSize = layoutChild(
        'top',
        BoxConstraints.loose(size),
      );
      placeChild(
        'top',
        Offset(
          (size.width - topSize.width) / 2,
          0,
        ),
      );
    }

    // Размещаем child 'bottom' внизу по центру
    if (hasChild('bottom')) {
      final bottomSize = layoutChild(
        'bottom',
        BoxConstraints.loose(size),
      );
      placeChild(
        'bottom',
        Offset(
          (size.width - bottomSize.width) / 2,
          size.height - bottomSize.height,
        ),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}
```

## Практический пример: карточка с заголовком и контентом

```dart
class CardLayoutDelegate extends MultiChildLayoutDelegate {
  final double headerHeight;
  final double padding;

  CardLayoutDelegate({
    this.headerHeight = 60,
    this.padding = 16,
  });

  @override
  void performLayout(Size size) {
    // Layout заголовка
    if (hasChild('header')) {
      final headerSize = layoutChild(
        'header',
        BoxConstraints(
          maxWidth: size.width,
          maxHeight: headerHeight,
        ),
      );
      placeChild('header', Offset.zero);
    }

    // Layout контента
    if (hasChild('content')) {
      final contentSize = layoutChild(
        'content',
        BoxConstraints(
          maxWidth: size.width - padding * 2,
          maxHeight: size.height - headerHeight - padding,
        ),
      );
      placeChild(
        'content',
        Offset(
          padding,
          headerHeight + padding,
        ),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return oldDelegate is! CardLayoutDelegate ||
        oldDelegate.headerHeight != headerHeight ||
        oldDelegate.padding != padding;
  }
}
```

### Использование

```dart
CustomMultiChildLayout(
  delegate: CardLayoutDelegate(headerHeight: 80, padding: 20),
  children: [
    LayoutId(
      id: 'header',
      child: Container(
        color: Colors.blue,
        child: const Center(
          child: Text(
            'Заголовок карточки',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    ),
    LayoutId(
      id: 'content',
      child: Container(
        color: Colors.white,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Основной контент карточки...'),
        ),
      ),
    ),
  ],
)
```

## Пример: кастомная сетка

```dart
class GridLayoutDelegate extends MultiChildLayoutDelegate {
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  GridLayoutDelegate({
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
  });

  @override
  void performLayout(Size size) {
    // Вычисляем размер одной ячейки
    final cellWidth = (size.width - (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
    final cellConstraints = BoxConstraints(maxWidth: cellWidth);

    int index = 0;
    int row = 0;
    int col = 0;

    for (final childId in _childIds) {
      final childSize = layoutChild(childId, cellConstraints);

      final x = col * (cellWidth + crossAxisSpacing);
      final y = row * (childSize.height + mainAxisSpacing);

      placeChild(childId, Offset(x, y));

      col++;
      if (col >= crossAxisCount) {
        col = 0;
        row++;
      }
      index++;
    }
  }

  List<String> get _childIds => [
        for (int i = 0; i < 6; i++) 'item_$i',
      ];

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return oldDelegate is! GridLayoutDelegate ||
        oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing;
  }
}
```

## Пример: диаграмма с линиями (Canvas)

```dart
class DiagramLayoutDelegate extends MultiChildLayoutDelegate {
  final Size canvasSize;

  DiagramLayoutDelegate(this.canvasSize);

  @override
  void performLayout(Size size) {
    // Layout элементов диаграммы
    if (hasChild('node1')) {
      layoutChild('node1', BoxConstraints.tight(const Size(80, 40)));
      placeChild('node1', Offset(10, 10));
    }

    if (hasChild('node2')) {
      layoutChild('node2', BoxConstraints.tight(const Size(80, 40)));
      placeChild('node2', Offset(200, 10));
    }

    if (hasChild('node3')) {
      layoutChild('node3', BoxConstraints.tight(const Size(80, 40)));
      placeChild('node3', Offset(100, 100));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}
```

## LayoutStrategy — упрощённые стратегии

Для простых случаев можно использовать готовые стратегии через `CustomMultiChildLayout` с `ListBody`:

```dart
// Вертикальный список
ListBody(
  children: [
    Text('Первый'),
    Text('Второй'),
    Text('Третий'),
  ],
)

// Горизонтальный список
ListBody(
  direction: Axis.horizontal,
  children: [
    Text('Первый'),
    Text('Второй'),
    Text('Третий'),
  ],
)
```

## Best Practices

- `CustomMultiChildLayout` — мощный, но сложный инструмент; используйте его только когда стандартные виджеты не подходят
- Всегда реализуйте `shouldRelayout` корректно — возвращайте `true` при изменении параметров delegate
- Используйте `hasChild()` для проверки наличия child перед его layout
- `layoutChild()` возвращает размер child — используйте его для расчёта позиций
- Храните параметры delegate в полях класса для корректной реализации `shouldRelayout`
- Для простых макетов предпочитайте `Stack`, `Row`, `Column` вместо `CustomMultiChildLayout`
- Комбинируйте `CustomMultiChildLayout` с `LayoutBuilder` для адаптивных кастомных макетов
- Используйте `ClipRect` для предотвращения выхода child за пределы layout
