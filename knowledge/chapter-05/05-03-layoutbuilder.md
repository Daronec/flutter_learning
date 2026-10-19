# LayoutBuilder и ConstrainedBox

`LayoutBuilder` и `ConstrainedBox` — мощные инструменты для создания адаптивных и кастомных макетов. Они позволяют виджетам реагировать на доступное пространство и модифицировать ограничения для дочерних элементов.

## LayoutBuilder — построение макета на основе доступного пространства

`LayoutBuilder` — это виджет, который получает доступное пространство на этапе build и позволяет создавать макеты, адаптированные к этому пространству.

### Как работает LayoutBuilder

```dart
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) {
    // constraints.maxWidth — максимальная доступная ширина
    // constraints.maxHeight — максимальная доступная высота
    // constraints.minWidth — минимальная доступная ширина
    // constraints.minHeight — минимальная доступная высота
    return Container();
  },
)
```

### Пример: адаптивный макет

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      // Узкий экран — вертикальный макет
      return Column(
        children: [
          Container(height: 200, color: Colors.red),
          Container(height: 200, color: Colors.green),
          Container(height: 200, color: Colors.blue),
        ],
      );
    } else {
      // Широкий экран — горизонтальный макет
      return Row(
        children: [
          Expanded(child: Container(height: 200, color: Colors.red)),
          Expanded(child: Container(height: 200, color: Colors.green)),
          Expanded(child: Container(height: 200, color: Colors.blue)),
        ],
      );
    }
  },
)
```

### BoxConstraints в LayoutBuilder

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // Доступные ограничения зависят от родителя
    print('maxWidth: ${constraints.maxWidth}');
    print('maxHeight: ${constraints.maxHeight}');
    print('minWidth: ${constraints.minWidth}');
    print('minHeight: ${constraints.minHeight}');

    // Пример: адаптивная сетка
    final itemWidth = 150.0;
    final crossAxisSpacing = 16.0;
    final itemCount = (constraints.maxWidth / (itemWidth + crossAxisSpacing)).floor();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisAxis(
        crossAxisCount: itemCount > 0 ? itemCount : 1,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: crossAxisSpacing,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.primaries[index % Colors.primaries.length].shade200,
          child: Center(child: Text('$index')),
        );
      },
    );
  },
)
```

## ConstrainedBox — модификация ограничений для child

`ConstrainedBox` накладывает дополнительные ограничения на дочерний виджет:

```dart
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 100,
    maxWidth: 300,
    minHeight: 50,
    maxHeight: 200,
  ),
  child: const Text('Текст с ограниченными размерами'),
)
```

### Как ConstrainedBox модифицирует ограничения

```
Родитель передаёт ConstrainedBox:
  minWidth: 0,    maxWidth: 500
  minHeight: 0,   maxHeight: 400
───────────────────────────────────────
ConstrainedBox накладывает свои ограничения:
  minWidth: 100,  maxWidth: 300
  minHeight: 50,  maxHeight: 200
───────────────────────────────────────
Child получает (пересечение):
  minWidth: 100,  maxWidth: 300
  minHeight: 50,  maxHeight: 200
```

### ConstrainedBox для принудительного размера

```dart
// Принудительный размер — min и max одинаковы
ConstrainedBox(
  constraints: const BoxConstraints.tightFor(width: 200, height: 100),
  child: const Text('Фиксированный размер'),
)
// Child получит: 200 ≤ w ≤ 200, 100 ≤ h ≤ 100
// Child обязан выбрать именно 200 × 100
```

### ConstrainedBox для минимального размера

```dart
// Гарантирует, что child не будет меньше заданных размеров
ConstrainedBox(
  constraints: const BoxConstraints(minWidth: 200, minHeight: 100),
  child: const Text('Минимум 200×100'),
)
// Если родитель даёт 0 ≤ w ≤ 100, child получит 0 ≤ w ≤ 100
// Но если child хочет быть 300px, он будет ограничен 200px минимум
```

## Combinations — LayoutBuilder + ConstrainedBox

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // Адаптивные ограничения на основе доступного пространства
    final maxWidth = constraints.maxWidth.clamp(200, 600);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minHeight: 100,
      ),
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Адаптивная карточка'),
        ),
      ),
    );
  },
)
```

## LayoutBuilder для условного рендеринга

```dart
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Определяем брейкпоинты
        const mobileBreakpoint = 600.0;
        const tabletBreakpoint = 1000.0;

        if (constraints.maxWidth < mobileBreakpoint) {
          return _MobileLayout();
        } else if (constraints.maxWidth < tabletBreakpoint) {
          return _TabletLayout();
        } else {
          return _DesktopLayout();
        }
      },
    );
  }
}

class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text('Пункт 1')),
        ListTile(title: Text('Пункт 2')),
        ListTile(title: Text('Пункт 3')),
      ],
    );
  }
}

class _TabletLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 200, child: _Sidebar()),
        Expanded(child: _Content()),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 250, child: _Sidebar()),
        Expanded(flex: 2, child: _Content()),
        SizedBox(width: 200, child: _Details()),
      ],
    );
  }
}
```

## Практические примеры

### Адаптивная типографика

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final fontSize = constraints.maxWidth > 600 ? 24.0 : 18.0;

    return Text(
      'Адаптивный текст',
      style: TextStyle(fontSize: fontSize),
    );
  },
)
```

### Адаптивная сетка карточек

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final cardWidth = 200.0;
    final spacing = 16.0;
    final crossAxisCount = (constraints.maxWidth / (cardWidth + spacing)).floor().clamp(1, 5);

    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisAxis(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 3 / 4,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          child: Center(child: Text('Карточка $index')),
        );
      },
    );
  },
)
```

### Контекст в LayoutBuilder

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // Важно: context внутри LayoutBuilder — это контекст build-метода
    // Он находится "внутри" LayoutBuilder, поэтому можно использовать
    // MediaQuery.of(context), Theme.of(context) и т.д.

    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
      child: Text(
        'Доступная ширина: ${constraints.maxWidth.toStringAsFixed(0)}',
        style: theme.textTheme.headlineSmall,
      ),
    );
  },
},
```

## Best Practices

- `LayoutBuilder` — лучший выбор для адаптивных макетов, реагирующих на доступное пространство
- Используйте `constraints.maxWidth` для определения брейкпоинтов, а не фиксированные значения экрана
- `ConstrainedBox` полезен для принудительного задания минимальных/максимальных размеров
- Комбинируйте `LayoutBuilder` и `ConstrainedBox` для создания адаптивных ограничений
- `LayoutBuilder` перестраивается при изменении доступного пространства (например, при повороте экрана)
- Избегайте глубокой вложенности `LayoutBuilder` — это может ухудшить производительность
- Используйте `clamp()` для ограничения значений в разумных пределах
