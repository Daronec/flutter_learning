---
tags:
  - widgets
  - ui
  - basics
chapter: 4
section: 1
title: Container, Padding, SizedBox — отступы и размеры
alias: 04 01 container padding
status: complete
---

# Container, Padding, SizedBox — отступы и размеры

## Введение

В Flutter существует несколько виджетов для управления отступами и размерами элементов интерфейса. Понимание различий между ними — ключ к созданию чистого и предсказуемого кода.

## Container

`Container` — это универсальный комбинированный виджет, который объединяет несколько функций: позиционирование, декорирование, выравнивание и ограничение размеров.

### Основные свойства Container

| Свойство | Тип | Описание |
|----------|-----|----------|
| `alignment` | `AlignmentGeometry` | Выравнивание дочернего виджета |
| `padding` | `EdgeInsetsGeometry` | Внутренние отступы |
| `margin` | `EdgeInsetsGeometry` | Внешние отступы |
| `decoration` | `BoxDecoration` | Декор (фон, граница, тень, скругление) |
| `width` | `double?` | Фиксированная ширина |
| `height` | `double?` | Фиксированная высота |
| `constraints` | `BoxConstraints?` | Дополнительные ограничения размеров |
| `transform` | `Matrix4?` | Матрица трансформации |
| `color` | `Color?` | Цвет фона (альтернатива decoration) |
| `child` | `Widget?` | Вложенный виджет |

### Пример использования Container

```dart
Container(
  width: 200,
  height: 100,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.symmetric(horizontal: 8),
  decoration: BoxDecoration(
    color: Colors.blue,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  alignment: Alignment.center,
  child: const Text(
    'Привет, Flutter!',
    style: TextStyle(color: Colors.white, fontSize: 18),
  ),
)
```

### Padding в Container

`padding` в Container использует `EdgeInsetsGeometry`, который поддерживает разные типы:

```dart
// Равномерные отступы со всех сторон
padding: const EdgeInsets.all(16)

// Только горизонтальные и вертикальные
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)

// Индивидуальные отступы
padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8, left: 24)

// Отступы для логических сторон (учитывает RTL)
padding: const EdgeInsetsDirectional.only(start: 16, end: 8)
```

### Margin vs Padding

| Характеристика | Padding | Margin |
|----------------|---------|--------|
| Расположение | Внутренние отступы | Внешние отступы |
| Фон виджета | Включает padding | Не включает margin |
| Клик-зона | Включает padding | Не включает padding |
| Декор | Распространяется на padding | Не распространяется |

```dart
// Margin не входит в область клика и декор
Container(
  margin: const EdgeInsets.all(16),
  color: Colors.blue,
  child: const Text('Клик сюда'),
)

// Padding входит в область клика и декор
Container(
  padding: const EdgeInsets.all(16),
  color: Colors.blue,
  child: const Text('Клик сюда'),
)
```

### Constraints в Container

`constraints` позволяет задать минимальные и максимальные размеры:

```dart
Container(
  constraints: const BoxConstraints(
    minWidth: 100,
    maxWidth: 300,
    minHeight: 50,
    maxHeight: 200,
  ),
  child: const Text('Ограниченный размер'),
)
```

## Padding

Виджет `Padding` — это лёгкая обёртка, которая добавляет только отступы вокруг дочернего виджета. Используйте его, когда не нужны другие функции Container.

### Пример использования Padding

```dart
const Padding(
  padding: EdgeInsets.all(16),
  child: Text(
    'Текст с отступами',
    style: TextStyle(fontSize: 16),
  ),
)
```

### Почему не всегда Container?

```dart
// ❌ Тяжёлый Container для одной задачи
Container(
  padding: const EdgeInsets.all(8),
  child: const Text('Текст'),
)

// ✅ Лёгкий Padding — только то, что нужно
const Padding(
  padding: EdgeInsets.all(8),
  child: Text('Текст'),
)
```

`Padding` легче для рендеринга, так как не создаёт дополнительные объекты `RenderDecoratedBox` и `RenderConstrainedBox`.

## SizedBox

`SizedBox` — виджет для задания фиксированных размеров или пустого пространства (gap).

### Фиксированный размер

```dart
const SizedBox(
  width: 100,
  height: 50,
  child: Text('Фиксированный размер'),
)
```

### Пустое пространство (Gap)

```dart
// Вертикальный отступ
const SizedBox(height: 16)

// Горизонтальный отступ
const SizedBox(width: 8)

// Квадратный отступ
const SizedBox.square(dimension: 12)

// Альтернатива: SizedBox.shrink() — нулевой размер
SizedBox.shrink(child: someWidget) // Если someWidget == null, размер 0
```

### Пример: разделение элементов

```dart
const Column(
  children: [
    Text('Заголовок'),
    SizedBox(height: 8),
    Text('Подзаголовок'),
    SizedBox(height: 16),
    Text('Основной текст'),
  ],
)
```

## Сравнение виджетов

| Виджет | Когда использовать |
|--------|-------------------|
| `Container` | Когда нужны декор, выравнивание, ограничения + отступы |
| `Padding` | Только для добавления отступов |
| `SizedBox` | Фиксированный размер или пустое пространство |

## Best Practices

1. **Используйте `Padding` вместо `Container`** для простых отступов — это легче для рендеринга.

2. **Используйте `SizedBox`** для создания отступов между элементами — это более читаемо, чем `Container` с `height`/`width`.

3. **Не вкладывайте `Padding` в `Padding`** — объединяйте отступы в один виджет:
   ```dart
   // ❌
   Padding(
     padding: const EdgeInsets.all(8),
     child: Padding(
       padding: const EdgeInsets.all(8),
       child: Text('Текст'),
     ),
   )
   
   // ✅
   Padding(
     padding: const EdgeInsets.all(16),
     child: Text('Текст'),
   )
   ```

4. **Используйте `EdgeInsets.symmetric`** для повторяющихся паттернов отступов:
   ```dart
   // Вместо EdgeInsets.only(top: 8, bottom: 8)
   const EdgeInsets.symmetric(vertical: 8)
   ```

5. **Избегайте `Container` только для цвета** — используйте `ColoredBox` или `DecoratedBox` как более лёгкие альтернативы.

6. **Используйте `BoxConstraints`** вместо `width`/`height` в `Container`, когда нужны гибкие ограничения:
   ```dart
   Container(
     constraints: const BoxConstraints(maxWidth: 400),
     child: child,
   )
   ```
## РЎРІСЏР·Р°РЅРЅС‹Рµ РіР»Р°РІС‹

[[Flex-система: Row и Column в деталях]] [[Form и FormKey — основы работы с формами]] 
