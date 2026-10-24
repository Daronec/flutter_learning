---
tags:
  - animations
chapter: 12
section: 8
title: Physics — Scroll Physics в Flutter
alias: 12 08 physics
status: complete
---

# Physics — Scroll Physics в Flutter

## Введение

Scroll Physics определяет, как скролл-виджеты ведут себя при прокрутке: инерция, отскоки, ограничение. Flutter предоставляет несколько встроенных физик и позволяет создавать собственные.

## Базовые Scroll Physics

### ClampingScrollPhysics

Поведение по умолчанию для Android — скролл останавливается на границах без отскока:

```dart
ListView(
  physics: const ClampingScrollPhysics(),
  children: List.generate(
    50,
    (index) => ListTile(title: Text('Item $index')),
  ),
)
```

| Характеристика | Значение |
|----------------|----------|
| Платформа | Android |
| Отскок | Нет |
| Инерция | Есть |
| Поведение на границах | Жёсткая остановка |

### BouncingScrollPhysics

Поведение по умолчанию для iOS — скролл с отскоком за пределы контента:

```dart
ListView(
  physics: const BouncingScrollPhysics(),
  children: List.generate(
    50,
    (index) => ListTile(title: Text('Item $index')),
  ),
)
```

| Характеристика | Значение |
|----------------|----------|
| Платформа | iOS |
| Отскок | Да |
| Инерция | Есть |
| Поведение на границах | Отскок с затуханием |

### Custom Scroll Physics

```dart
// Пользовательская физика с настройкой
ListView(
  physics: const BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
    dampingRatio: 0.8,   // Коэффициент затухания (0.0 - 1.0)
    stiffness: 400,      // Жёсткость пружины
  ),
  children: List.generate(
    50,
    (index) => ListTile(title: Text('Item $index')),
  ),
)
```

### AlwaysScrollableScrollPhysics

Принудительная прокрутка даже при малом контенте:

```dart
// Всегда показывает скроллбар
ListView(
  physics: const AlwaysScrollableScrollPhysics(),
  children: const [
    Text('Мало контента'),
  ],
)
```

## Parameters Scroll Physics

| Параметр | Тип | Описание | Значение по умолчанию |
|----------|-----|----------|---------------------|
| `dampingRatio` | `double` | Затухание отскока | 0.8 (Bouncing) / 1.0 (Clamping) |
| `stiffness` | `double` | Жёсткость пружины | 400 |
| `parent` | `ScrollPhysics?` | Родительская физика | null |

## Создание кастомной ScrollPhysics

### Базовая структура

```dart
class CustomScrollPhysics extends ScrollPhysics {
  final double stiffness;
  final double dampingRatio;

  const CustomScrollPhysics({
    super.parent,
    this.stiffness = 400,
    this.dampingRatio = 0.8,
  });

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(
      parent: buildParent(ancestor),
      stiffness: stiffness,
      dampingRatio: dampingRatio,
    );
  }

  @override
  double get inertiaWeight => 0.5;

  @override
  double resolve(ScrollPhysics? parent) {
    return super.resolve(parent) ?? this;
  }
}
```

### Реализация get frictionFactor

```dart
class CustomScrollPhysics extends ScrollPhysics {
  final double stiffness;
  final double dampingRatio;

  const CustomScrollPhysics({
    super.parent,
    this.stiffness = 400,
    this.dampingRatio = 0.8,
  });

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(
      parent: buildParent(ancestor),
      stiffness: stiffness,
      dampingRatio: dampingRatio,
    );
  }

  @override
  double get frictionFactor => dampingRatio;

  @override
  double resolve(ScrollPhysics? parent) {
    return super.resolve(parent) ?? this;
  }
}
```

### Полная реализация с spring

```dart
class ElasticScrollPhysics extends ScrollPhysics {
  final double stiffness;

  const ElasticScrollPhysics({
    super.parent,
    this.stiffness = 100,
  });

  @override
  ElasticScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ElasticScrollPhysics(
      parent: buildParent(ancestor),
      stiffness: stiffness,
    );
  }

  @override
  SpringDescription get spring {
    return SpringDescription(
      mass: 30,
      stiffness: stiffness,
      damping: 1,
    );
  }

  @override
  double resolve(ScrollPhysics? parent) {
    return super.resolve(parent) ?? this;
  }
}
```

## Использование в виджетах

### ListView с кастомной физикой

```dart
ListView(
  physics: const ElasticScrollPhysics(stiffness: 200),
  children: List.generate(
    100,
    (index) => ListTile(
      title: Text('Item $index'),
      subtitle: Text('Описание элемента $index'),
    ),
  ),
)
```

### SingleChildScrollView

```dart
SingleChildScrollView(
  physics: const BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
    dampingRatio: 0.7,
  ),
  child: Column(
    children: [
      Container(height: 200, color: Colors.blue),
      Container(height: 200, color: Colors.red),
      Container(height: 200, color: Colors.green),
    ],
  ),
)
```

### PageView

```dart
PageView(
  physics: const ClampingScrollPhysics(), // Без отскока для страниц
  children: [
    Container(color: Colors.blue, child: const Center(child: Text('1'))),
    Container(color: Colors.red, child: const Center(child: Text('2'))),
    Container(color: Colors.green, child: const Center(child: Text('3'))),
  ],
)
```

### NestedScrollView

```dart
NestedScrollView(
  physics: const BouncingScrollPhysics(),
  headerSliverBuilder: (context, innerBoxIsScrolled) {
    return [
      SliverAppBar(
        expandedHeight: 200,
        flexibleSpace: FlexibleSpaceBar(
          title: const Text('Nested Scroll'),
        ),
      ),
    ];
  },
  body: ListView.builder(
    itemCount: 50,
    itemBuilder: (context, index) {
      return ListTile(title: Text('Item $index'));
    },
  ),
)
```

## Сравнение Scroll Physics

| Физика | Отскок | Инерция | Платформа | Когда использовать |
|--------|--------|---------|-----------|-------------------|
| `ClampingScrollPhysics` | Нет | Да | Android | Стандартный Android |
| `BouncingScrollPhysics` | Да | Да | iOS | Стандартный iOS |
| `NeverScrollableScrollPhysics` | Нет | Нет | — | Отключить скролл |
| `AlwaysScrollableScrollPhysics` | Да | Да | — | Всегда показывать скролл |
| `PageScrollPhysics` | Нет | Да | — | PageView |
| `Custom` | Настраиваемая | Настраиваемая | — | Специальное поведение |

## PageScrollPhysics

Используется для PageView — прокрутка по одной странице за раз:

```dart
PageView(
  physics: const PageScrollPhysics().applyTo(
    const BouncingScrollPhysics(),
  ),
  children: [
    const Center(child: Text('Страница 1')),
    const Center(child: Text('Страница 2')),
    const Center(child: Text('Страница 3')),
  ],
)
```

## Лучшие практики

1. **Используйте `ClampingScrollPhysics`** для PageView
2. **Используйте `BouncingScrollPhysics`** для ListView на iOS
3. **Используйте `AlwaysScrollableScrollPhysics`** для показа скроллбара
4. **Создавайте кастомную физику** через наследование `ScrollPhysics`
5. **Комбинируйте физику** через параметр `parent`
6. **Тестируйте на обеих платформах** — поведение может отличаться
