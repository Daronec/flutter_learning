---
tags:
  - layout
  - responsive
  - ui
chapter: 5
section: 8
title: OrientationBuilder и MediaQuery
alias: 05 08 orientation mediaquery
status: complete
---

# OrientationBuilder и MediaQuery

`MediaQuery` и `OrientationBuilder` — ключевые инструменты для получения информации о экране и адаптации интерфейса к изменениям ориентации.

## MediaQuery — информация о экране

`MediaQuery` предоставляет данные о среде отображения приложения: размер экрана, плотность пикселей, safe area и т.д.

### Получение MediaQuery

```dart
// В build-методе
final mediaQuery = MediaQuery.of(context);

// Или через MediaQuery.data
final data = MediaQuery.of(context).data;
```

### Основные свойства MediaQuery

| Свойство | Тип | Описание |
|----------|-----|----------|
| `size` | `Size` | Размер экрана в логических пикселях |
| `width` | `double` | Ширина экрана |
| `height` | `double` | Высота экрана |
| `padding` | `EdgeInsets` | Системные отступы (челка, нижняя панель) |
| `viewPadding` | `EdgeInsets` | Полные системные отступы |
| `viewInsets` | `EdgeInsets` | Виртуальная клавиатура, системные панели |
| `devicePixelRatio` | `double` | Плотность пикселей устройства |
| `orientation` | `Orientation` | Ориентация (портрет/альбом) |
| `platformBrightness` | `Brightness` | Тема системы (светлая/тёмная) |

### Размер экрана

```dart
class ScreenInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Column(
      children: [
        Text('Ширина: ${width.toStringAsFixed(0)}px'),
        Text('Высота: ${height.toStringAsFixed(0)}px'),
      ],
    );
  }
}
```

### Safe Area — учёт системных отступов

```dart
// Padding — отступы от системных элементов
final padding = MediaQuery.of(context).padding;
print(padding.top);    // Челка, статус-бар
print(padding.bottom); // Нижняя панель
print(padding.left);   // Левый отступ
print(padding.right);  // Правый отступ

// viewPadding — полные отступы (включая невидимые)
final viewPadding = MediaQuery.of(context).viewPadding;

// viewInsets — видимые системные элементы (клавиатура)
final viewInsets = MediaQuery.of(context).viewInsets;
```

### SafeArea — виджет для safe area

```dart
// Автоматический учёт safe area
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        Container(
          height: 200,
          color: Colors.red,
          child: const Center(child: Text('Safe Area')),
        ),
      ],
    ),
  ),
)

// Тонкая настройка
SafeArea(
  top: true,       // Учитывать верхний отступ (по умолчанию true)
  bottom: false,   // Не учитывать нижний отступ
  left: true,
  right: true,
  minimum: EdgeInsets.all(8), // Дополнительные отступы
  child: Container(
    color: Colors.blue,
    child: const Text('Настройка safe area'),
  ),
)
```

### Ориентация экрана

```dart
final orientation = MediaQuery.of(context).orientation;

if (orientation == Orientation.portrait) {
  return Text('Портретная ориентация');
} else {
  return Text('Альбомная ориентация');
}
```

### Тёмная тема

```dart
final brightness = MediaQuery.of(context).platformBrightness;

if (brightness == Brightness.dark) {
  // Тёмная тема
  return Container(color: Colors.black, child: Text('Тёмная тема'));
} else {
  // Светлая тема
  return Container(color: Colors.white, child: Text('Светлая тема'));
}
```

### Плотность пикселей

```dart
final pixelRatio = MediaQuery.of(context).devicePixelRatio;
// Обычно 1.0, 2.0 или 3.0
// Используется для рендеринга графики с учётом плотности пикселей
```

## OrientationBuilder — реакция на изменение ориентации

`OrientationBuilder` перестраивает child при изменении ориентации экрана:

```dart
OrientationBuilder(
  builder: (context, orientation) {
    if (orientation == Orientation.portrait) {
      return Text('Портрет');
    } else {
      return Text('Альбом');
    }
  },
)
```

### Пример: адаптивная сетка

```dart
class AdaptiveGridWithOrientation extends StatelessWidget {
  const AdaptiveGridWithOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisAxis(
            crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 2,
          ),
          itemCount: 20,
          itemBuilder: (context, index) {
            return Card(
              child: Center(child: Text('$index')),
            );
          },
        );
      },
    );
  }
}
```

### Пример: адаптивный список

```dart
class AdaptiveListWithOrientation extends StatelessWidget {
  const AdaptiveListWithOrientation({super.key});

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          // Портрет — один столбец
          return ListView(
            children: [
              ListTile(title: const Text('Пункт 1')),
              ListTile(title: const Text('Пункт 2')),
              ListTile(title: const Text('Пункт 3')),
            ],
          );
        } else {
          // Альбом — два столбца
          return Row(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ListTile(title: const Text('Пункт 1')),
                    ListTile(title: const Text('Пункт 2')),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(title: const Text('Пункт 3')),
                    ListTile(title: const Text('Пункт 4')),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
```

## Комбинация MediaQuery и OrientationBuilder

```dart
class CombinedExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return OrientationBuilder(
      builder: (context, orientation) {
        return Padding(
          padding: EdgeInsets.only(
            top: padding.top,
            left: 16,
            right: 16,
            bottom: padding.bottom,
          ),
          child: orientation == Orientation.portrait
              ? _PortraitView(size)
              : _LandscapeView(size),
        );
      },
    );
  }
}

class _PortraitView extends StatelessWidget {
  final Size size;

  const _PortraitView(this.size);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: size.height * 0.4,
          color: Colors.blue,
          child: const Center(child: Text('Верхняя часть')),
        ),
        Expanded(
          child: Container(
            color: Colors.green,
            child: const Center(child: Text('Нижняя часть')),
          ),
        ),
      ],
    );
  }
}

class _LandscapeView extends StatelessWidget {
  final Size size;

  const _LandscapeView(this.size);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            color: Colors.blue,
            child: const Center(child: Text('Левая часть')),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.green,
            child: const Center(child: Text('Правая часть')),
          ),
        ),
      ],
    );
  }
}
```

## Практические примеры

### Адаптивный размер шрифта

```dart
class AdaptiveFontSize extends StatelessWidget {
  final String text;

  const AdaptiveFontSize(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width > 600 ? 24.0 : 16.0;

    return Text(
      text,
      style: TextStyle(fontSize: fontSize),
    );
  }
}
```

### Адаптивные отступы

```dart
class AdaptivePadding extends StatelessWidget {
  final Widget child;

  const AdaptivePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width > 600 ? 48.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: child,
    );
  }
}
```

### Адаптивная карточка

```dart
class AdaptiveCard extends StatelessWidget {
  final String title;
  final String description;

  const AdaptiveCard({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Card(
          child: orientation == Orientation.portrait
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(description),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(description),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
```

## Best Practices

- Используйте `MediaQuery.of(context)` для получения размеров экрана и safe area
- `SafeArea` — предпочтительный способ учёта системных отступов вместо ручных расчётов
- `OrientationBuilder` — для перестройки макета при смене ориентации
- Комбинируйте `MediaQuery` и `OrientationBuilder` для полной адаптивности
- Учитывайте `viewInsets` при работе с клавиатурой
- Избегайте жёстких размеров — используйте относительные значения от `MediaQuery.size`
- `MediaQuery` перестраивает виджет при изменении ориентации или размера окна
- Для тёмной темы используйте `platformBrightness` из `MediaQuery`
