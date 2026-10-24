---
tags:
  - layout
  - responsive
  - ui
chapter: 5
section: 1
title: Flex-система: Row и Column в деталях
alias: 05 01 flex system
status: complete
---

# Flex-система: Row и Column в деталях

Flex-система Flutter — это основа всех макетов. Виджеты `Row` и `Column` используют механизм `Flex`, который распределяет пространство между дочерними элементами по главной оси (main axis) и выравнивает их по поперечной (cross axis).

## Что такое Flex-система

Flex-система — это алгоритм распределения пространства, который:

1. Определяет **главную ось** (main axis) — направление, вдоль которого располагаются дети
2. Определяет **поперечную ось** (cross axis) — перпендикулярное направление
3. Распределяет свободное пространство между детьми
4. Выравнивает детей вдоль обеих осей

| Виджет | Главная ось | Поперечная ось |
|--------|-------------|----------------|
| `Row` | Горизонтальная (← →) | Вертикальная (↑ ↓) |
| `Column` | Вертикальная (↑ ↓) | Горизонтальная (← →) |

## MainAxisAlignment — выравнивание по главной оси

`MainAxisAlignment` определяет, как свободное пространство распределяется между дочерними элементами **вдоль главной оси**.

### Доступные значения

| Значение | Описание | Поведение |
|----------|----------|-----------|
| `start` | Прижать к началу | Все дети в начале, свободное пространство — в конце |
| `end` | Прижать к концу | Все дети в конце, свободное пространство — в начале |
| `center` | По центру | Равное свободное пространство с обеих сторон |
| `spaceBetween` | Без отступов по краям | Равные промежутки между детьми, нет отступов по краям |
| `spaceAround` | Равные отступы вокруг | Каждый ребёнок имеет равные отступы слева и справа; отступы по краям — половина внутреннего |
| `spaceEvenly` | Равные отступы везде | Все промежутки (включая краевые) абсолютно равны |

### Примеры использования

```dart
// MainAxisAlignment.start — по умолчанию
Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: const [
    Text('A'),
    Text('B'),
    Text('C'),
  ],
)
// Результат: [A][B][C]        (свободное место справа)

// MainAxisAlignment.end
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: const [
    Text('A'),
    Text('B'),
    Text('C'),
  ],
)
// Результат:        [A][B][C] (свободное место слева)

// MainAxisAlignment.center
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: const [
    Text('A'),
    Text('B'),
    Text('C'),
  ],
)
// Результат:     [A][B][C]    (свободное место слева и справа поровну)

// MainAxisAlignment.spaceBetween
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: const [
    Text('A'),
    Text('B'),
    Text('C'),
  ],
)
// Результат: [A]    [B]    [C] (нет отступов по краям)

// MainAxisAlignment.spaceAround
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: const [
    Text('A'),
    Text('B'),
    Text('C'),
  ],
)
// Результат:  [A]   [B]   [C]  (краевые отступы = половина внутренних)

// MainAxisAlignment.spaceEvenly
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: const [
    Text('A'),
    Text('B'),
    Text('C'),
  ],
)
// Результат:  [A]   [B]   [C]  (все отступы абсолютно равны)
```

## CrossAxisAlignment — выравнивание по поперечной оси

`CrossAxisAlignment` определяет, как дети выравниваются **поперёк** главной оси.

### Доступные значения

| Значение | Описание | Поведение |
|----------|----------|-----------|
| `start` | Прижать к началу | Дети прижаты к началу поперечной оси |
| `end` | Прижать к концу | Дети прижаты к концу поперечной оси |
| `center` | По центру | Дети отцентрованы по поперечной оси |
| `stretch` | Растянуть | Дети растягиваются на всю высоту/ширину поперечной оси |
| `baseline` | По базовой линии | Дети выравниваются по базовой линии текста |

### Примеры для Row (поперечная ось — вертикальная)

```dart
// CrossAxisAlignment.center — по умолчанию для Row
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: const [
    Text('Короткий'),
    Text('Очень длинный текст, который занимает несколько строк'),
    Text('X'),
  ],
)
// Все три элемента отцентрованы по вертикали

// CrossAxisAlignment.start
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: const [
    Text('Короткий'),
    Text('Очень длинный текст, который занимает несколько строк'),
    Text('X'),
  ],
)
// Верхний край всех элементов выровнен по верху

// CrossAxisAlignment.end
Row(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: const [
    Text('Короткий'),
    Text('Очень длинный текст, который занимает несколько строк'),
    Text('X'),
  ],
)
// Нижний край всех элементов выровнен по низу

// CrossAxisAlignment.stretch
Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: const [
    Container(width: 50, color: Colors.red),
    Container(width: 50, color: Colors.green),
    Container(width: 50, color: Colors.blue),
  ],
)
// Все контейнеры растягиваются на полную высоту Row

// CrossAxisAlignment.baseline
Row(
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic,
  children: const [
    Text('Короткий'),
    Text('Очень длинный текст'),
  ],
)
// Текст выровнен по базовой линии (нижняя линия букв)
```

### Примеры для Column (поперечная ось — горизонтальная)

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: const [
    Text('Короткий'),
    Text('Очень длинный текст, который занимает много символов'),
    Text('X'),
  ],
)
// Все элементы отцентрованы по горизонтали
```

## MainAxisSize — размер по главной оси

`MainAxisSize` определяет, как Row/Column рассчитывают свой размер по главной оси.

| Значение | Описание | Поведение |
|----------|----------|-----------|
| `max` | Максимальный размер (по умолчанию) | Row/Column занимает всё доступное пространство |
| `min` | Минимальный размер | Row/Column занимает только столько, сколько нужно детям |

### Примеры

```dart
// MainAxisSize.max — по умолчанию
Scaffold(
  body: Row(
    mainAxisSize: MainAxisSize.max,
    children: const [
      Text('A'),
      Text('B'),
    ],
  ),
)
// Row занимает всю ширину экрана, дети прижаты к началу (start)

// MainAxisSize.min
Scaffold(
  body: Row(
    mainAxisSize: MainAxisSize.min,
    children: const [
      Text('A'),
      Text('B'),
    ],
  ),
)
// Row занимает только ширину текста «A» + «B» + отступы
```

## Expanded и Flexible — растягивание детей

Когда `MainAxisSize` равен `max`, свободное пространство можно распределить между детьми с помощью `Expanded` и `Flexible`.

### Expanded

Заставляет ребёнка занять всё доступное свободное пространство. Если несколько детей имеют `Expanded`, пространство делится пропорционально `flex`.

```dart
Row(
  children: const [
    Text('Фиксированный'),
    Expanded(
      child: Text('Растягивается на всё оставшееся пространство'),
    ),
    Text('Фиксированный'),
  ],
)
// [Фиксированный] [Растягивается на всё оставшееся пространство] [Фиксированный]
```

### Flexible

Позволяет ребёнку растягиваться, но не принуждает его. Ребёнок может быть меньше доступного пространства.

```dart
Row(
  children: const [
    Text('Фиксированный'),
    Flexible(
      child: Text('Может растягиваться, но не обязан'),
    ),
    Text('Фиксированный'),
  ],
)
```

### Flex-коэффициенты

```dart
Row(
  children: [
    Expanded(
      flex: 1,
      child: Container(color: Colors.red, height: 50),
    ),
    Expanded(
      flex: 2,
      child: Container(color: Colors.green, height: 50),
    ),
    Expanded(
      flex: 1,
      child: Container(color: Colors.blue, height: 50),
    ),
  ],
)
// Красный: 25% ширины, Зелёный: 50%, Синий: 25%
```

## Combinations — комбинирование свойств

```dart
// Пример: карточки в ряд с равными отступами
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Card(child: Text('Карточка 1')),
    Card(child: Text('Карточка 2')),
    Card(child: Text('Карточка 3')),
  ],
)
```

```dart
// Пример: список с растянутыми элементами
Column(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Expanded(child: ListTile(title: const Text('Пункт 1'))),
    Expanded(child: ListTile(title: const Text('Пункт 2'))),
    Expanded(child: ListTile(title: const Text('Пункт 3'))),
  ],
)
```

## Best Practices

- Используйте `mainAxisSize: MainAxisSize.min` для компактных Row/Column внутри других виджетов
- `Expanded` — когда элемент **должен** занять пространство; `Flexible` — когда может
- `CrossAxisAlignment.stretch` полезен для карточек одинаковой высоты
- `baseline` работает только с текстовыми детьми или контейнерами с текстом
- Для `spaceBetween`/`spaceAround`/`spaceEvenly` убедитесь, что у Row/Column достаточно пространства по главной оси
- Комбинируйте `mainAxisSize: MainAxisSize.min` с `CrossAxisAlignment.stretch` для компактных растянутых карточек
## РЎРІСЏР·Р°РЅРЅС‹Рµ РіР»Р°РІС‹

[[Container, Padding, SizedBox — отступы и размеры]] [[Navigator 1.0: push, pop, named routes]] 
