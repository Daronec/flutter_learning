# Constraints — как работают ограничения

Constraints (ограничения) — это фундаментальный механизм, на котором строится весь layout в Flutter. Понимание constraints критически важно для создания корректных и предсказуемых макетов.

## Основной принцип

> **Flutter — это фреймворк, основанный на ограничениях.** Каждый виджет получает ограничения от родителя и сообщает свой размер родителю.

## Три фазы layout-алгоритма

Layout в Flutter проходит через три последовательных фазы:

### 1. Top-down: передача ограничений

```
Родитель
  │
  │  отправляет Constraints
  ▼
Дочерний виджет
```

Родитель передаёт дочернему виджету `BoxConstraints`, которые определяют **минимальный** и **максимальный** размер по каждой оси.

### 2. Bottom-up: передача размеров

```
Дочерний виджет
  │
  │  отправляет свой Size
  ▼
Родитель
```

Дочерний виджет выбирает размер **в пределах** полученных ограничений и сообщает его родителю.

### 3. ParentData: передача позиционирования

```
Дочерний виджет
  │
  │  отправляет Offset (через ParentData)
  ▼
Родитель
```

Дочерний виджет сообщает родителю, где он расположен (для виджетов, которые могут содержать несколько детей).

## BoxConstraints — структура ограничений

`BoxConstraints` определяет допустимый диапазон размеров:

```dart
BoxConstraints({
  this.minWidth = 0.0,
  this.maxWidth = double.infinity,
  this.minHeight = 0.0,
  this.maxHeight = double.infinity,
})
```

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `minWidth` | Минимальная ширина | 0.0 |
| `maxWidth` | Максимальная ширина | ∞ (double.infinity) |
| `minHeight` | Минимальная высота | 0.0 |
| `maxHeight` | Максимальная высота | ∞ (double.infinity) |

### Типы ограничений

```dart
// Неограниченные ограничения (можно выбрать любой размер)
BoxConstraints.loose(Size(300, 200))
// minWidth: 0, maxWidth: 300, minHeight: 0, maxHeight: 200

// Жёсткие ограничения (размер фиксирован)
BoxConstraints.tight(Size(300, 200))
// minWidth: 300, maxWidth: 300, minHeight: 200, maxHeight: 200

// Ограничения только по ширине
BoxConstraints.tightForWidth(300)
// minWidth: 300, maxWidth: 300, minHeight: 0, maxHeight: ∞

// Ограничения только по высоте
BoxConstraints.tightForHeight(200)
// minWidth: 0, maxWidth: ∞, minHeight: 200, maxHeight: 200
```

## Визуализация потока ограничений

```
┌─────────────────────────────────────────────────────────┐
│                    Scaffold                               │
│  Constraints: 0 ≤ w ≤ ∞, 0 ≤ h ≤ ∞                     │
│  ┌───────────────────────────────────────────────────┐  │
│  │              Container                              │  │
│  │  Constraints: 0 ≤ w ≤ 400, 0 ≤ h ≤ 300            │  │
│  │  Size chosen: 300 × 200                            │  │
│  │  ┌─────────────────────────────────────────────┐  │  │
│  │  │            Text                               │  │  │
│  │  │  Constraints: 0 ≤ w ≤ 300, 0 ≤ h ≤ 200      │  │  │
│  │  │  Size chosen: 150 × 30 (естественный размер)  │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Подробный пример layout-процесса

```dart
Scaffold(
  body: Container(
    constraints: BoxConstraints(maxWidth: 400, maxHeight: 300),
    child: const Text('Hello'),
  ),
)
```

### Шаг 1: Scaffold → Container

```
Scaffold передаёт Container:
  minWidth: 0,  maxWidth: ∞
  minHeight: 0, maxHeight: ∞
```

### Шаг 2: Container обрабатывает ограничения

```dart
Container(
  constraints: BoxConstraints(maxWidth: 400, maxHeight: 300),
  child: Text('Hello'),
)
```

Container **пересекает** полученные ограничения со своими:

```
Полученные:     0 ≤ w ≤ ∞,  0 ≤ h ≤ ∞
Свои:           0 ≤ w ≤ 400, 0 ≤ h ≤ 300
───────────────────────────────────────
Пересечение:    0 ≤ w ≤ 400, 0 ≤ h ≤ 300
```

Container передаёт Text: `0 ≤ w ≤ 400, 0 ≤ h ≤ 300`

### Шаг 3: Text выбирает размер

```
Text получает: 0 ≤ w ≤ 400, 0 ≤ h ≤ 300
Text выбирает:  w = 150, h = 30 (естественный размер текста)
```

### Шаг 4: Text сообщает размер Container

```
Text сообщает Container: Size(150, 30)
```

### Шаг 5: Container сообщает размер Scaffold

```
Container сообщает Scaffold: Size(150, 30)
```

## Правила поведения виджетов с ограничениями

| Виджет | Поведение |
|--------|----------|
| **SizedBox** | Игнорирует ограничения, задаёт фиксированный размер |
| **Container** | Пересекает ограничения с собственными constraints |
| **Text** | Выбирает размер, достаточный для отображения текста (в пределах ограничений) |
| **Container с child** | Пересекает ограничения, child получает пересечённые |
| **Padding** | Уменьшает доступное пространство на величину отступов |
| **Center** | Выбирает естественный размер, центрирует child |
| **Expanded** | Занимает всё доступное свободное пространство |
| **ConstrainedBox** | Модифицирует ограничения, передаваемые child |

## Padding и ограничения

`Padding` уменьшает доступное пространство для child:

```dart
Container(
  constraints: BoxConstraints(maxWidth: 400, maxHeight: 300),
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: const Text('Hello'),
  ),
)
```

```
Container передаёт Padding:     0 ≤ w ≤ 400, 0 ≤ h ≤ 300
Padding вычитает отступы:       0 ≤ w ≤ 360, 0 ≤ h ≤ 260
Padding передаёт Text:          0 ≤ w ≤ 360, 0 ≤ h ≤ 260
```

## ConstrainedBox — модификация ограничений

`ConstrainedBox` позволяет изменить ограничения, передаваемые child:

```dart
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 200,
    maxWidth: 400,
    minHeight: 100,
    maxHeight: 300,
  ),
  child: const Text('Hello'),
)
```

### Как ConstrainedBox работает

```
Родитель передаёт ConstrainedBox:   0 ≤ w ≤ ∞,  0 ≤ h ≤ ∞
ConstrainedBox свои ограничения:    200 ≤ w ≤ 400, 100 ≤ h ≤ 300
─────────────────────────────────────────────────────────────
Пересечение (child получает):       200 ≤ w ≤ 400, 100 ≤ h ≤ 300
```

### ConstrainedBox vs Container с constraints

```dart
// ConstrainedBox — всегда пересекает ограничения
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 200),
  child: const Text('Текст'),
)

// Container с constraints — накладывает ограничения, но child может быть меньше
Container(
  constraints: const BoxConstraints(maxWidth: 200),
  child: const Text('Текст'),
)
```

Разница проявляется, когда child имеет собственные ограничения. `ConstrainedBox` **всегда** накладывает свои ограничения на child, а `Container` может вести себя иначе в зависимости от контекста.

## UnconstrainedBox — снятие ограничений

`UnconstrainedBox` позволяет child получить неограниченные размеры:

```dart
UnconstrainedBox(
  child: const Text('Текст'),
)
// Text получает неограниченные ограничения и выбирает свой естественный размер
```

## Best Practices

- Помните: **каждый виджет получает ограничения от родителя** и **выбирает размер в пределах этих ограничений**
- `BoxConstraints.tight` создаёт жёсткие ограничения — child обязан выбрать именно этот размер
- `BoxConstraints.loose` создаёт мягкие ограничения — child может выбрать любой размер до максимума
- Используйте `ConstrainedBox` для принудительного наложения ограничений на child
- Используйте `UnconstrainedBox` для получения естественного размера child
- `Padding` уменьшает доступное пространство — учитывайте это при расчётах
- `Expanded` работает только внутри `Flex` (Row/Column) и занимает **свободное** пространство
- Если child не может выбрать размер в пределах ограничений, появится предупреждение (overflow)
