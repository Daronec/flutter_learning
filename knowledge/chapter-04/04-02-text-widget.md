---
tags:
  - widgets
  - ui
  - basics
chapter: 4
section: 2
title: Text, RichText, TextSpan — работа с текстом
alias: 04 02 text widget
status: complete
---

# Text, RichText, TextSpan — работа с текстом

## Введение

Текст — один из самых распространённых элементов в мобильных приложениях. Flutter предоставляет несколько виджетов для работы с текстом: `Text`, `RichText` и `TextSpan`.

## Text

Виджет `Text` — основной виджет для отображения строки с единообразным стилем.

### Основные свойства Text

| Свойство | Тип | Описание |
|----------|-----|----------|
| `data` | `String?` | Отображаемый текст |
| `style` | `TextStyle?` | Стиль текста |
| `textAlign` | `TextAlign?` | Выравнивание текста |
| `textDirection` | `TextDirection?` | Направление текста (LTR/RTL) |
| `maxLines` | `int?` | Максимальное количество строк |
| `overflow` | `TextOverflow?` | Поведение при переполнении |
| `softWrap` | `bool?` | Перенос по словам |
| `textScaler` | `TextScaler?` | Масштабирование шрифта |
| `semanticsLabel` | `String?` | Метка для доступности |

### Пример использования

```dart
const Text(
  'Привет, мир!',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

## TextStyle

`TextStyle` определяет визуальное оформление текста.

### Основные свойства TextStyle

| Свойство | Тип | Описание |
|----------|-----|----------|
| `fontSize` | `double?` | Размер шрифта (в пикселях) |
| `fontWeight` | `FontWeight?` | Жирность шрифта |
| `fontStyle` | `FontStyle?` | Обычный или курсив |
| `color` | `Color?` | Цвет текста |
| `fontFamily` | `String?` | Имя шрифта |
| `letterSpacing` | `double?` | Межбуквенный интервал |
| `wordSpacing` | `double?` | Межсловный интервал |
| `height` | `double?` | Межстрочный интервал (множитель) |
| `decoration` | `TextDecoration?` | Подчёркивание, перечёркивание |
| `decorationColor` | `Color?` | Цвет декорации |
| `decorationStyle` | `TextDecorationStyle?` | Стиль декорации |
| `background` | `Paint?` | Фон текста |
| `shadows` | `List<Shadow>?` | Тени текста |

### FontWeight

```dart
FontWeight.w100  // Thin
FontWeight.w200  // ExtraLight
FontWeight.w300  // Light
FontWeight.w400  // Normal (regular)
FontWeight.w500  // Medium
FontWeight.w600  // SemiBold
FontWeight.w700  // Bold
FontWeight.w800  // ExtraBold
FontWeight.w900  // Black
```

### Примеры TextStyle

```dart
// Обычный текст
const Text(
  'Обычный текст',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
)

// Курсив
const Text(
  'Курсив',
  style: TextStyle(
    fontStyle: FontStyle.italic,
    fontSize: 16,
  ),
)

// Подчёркнутый текст
const Text(
  'Подчёркнутый',
  style: TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: Colors.blue,
    decorationStyle: TextDecorationStyle.dashed,
  ),
)

// Перечёркнутый текст
const Text(
  'Удалённый',
  style: TextStyle(
    decoration: TextDecoration.lineThrough,
    color: Colors.grey,
  ),
)

// Текст с тенью
const Text(
  'Тень',
  style: TextStyle(
    fontSize: 24,
    shadows: [
      Shadow(
        offset: Offset(2, 2),
        blurRadius: 4,
        color: Colors.black26,
      ),
    ],
  ),
)
```

## Выравнивание текста (TextAlign)

| Значение | Описание |
|----------|----------|
| `TextAlign.start` | Выравнивание по началу строки |
| `TextAlign.end` | Выравнивание по концу строки |
| `TextAlign.left` | Выравнивание по левому краю |
| `TextAlign.right` | Выравнивание по правому краю |
| `TextAlign.center` | Центрирование |
| `TextAlign.justify` | Выравнивание по ширине |

```dart
Text(
  'Этот текст выровнен по ширине. Flutter поддерживает выравнивание по ширине для многострочного текста.',
  textAlign: TextAlign.justify,
)
```

## Переполнение текста (TextOverflow)

| Значение | Описание |
|----------|----------|
| `TextOverflow.clip` | Обрезка текста |
| `TextOverflow.fade` | Плавное затухание |
| `TextOverflow.ellipsis` | Многоточие в конце |

```dart
// Обрезка
Text(
  'Очень длинный текст, который не помещается',
  maxLines: 1,
  overflow: TextOverflow.clip,
)

// Затухание
Text(
  'Очень длинный текст, который не помещается',
  maxLines: 1,
  overflow: TextOverflow.fade,
)

// Многоточие
Text(
  'Очень длинный текст, который не помещается',
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

## RichText и TextSpan

Для отображения текста с разными стилями в одной строке используется `RichText` с `TextSpan`.

### Основы RichText

```dart
RichText(
  text: const TextSpan(
    text: 'Жирный и обычный',
    style: TextStyle(fontSize: 18, color: Colors.black),
    children: [
      TextSpan(
        text: ' Жирный',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(
        text: ' и обычный',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ],
  ),
)
```

### Вложенные TextSpan

```dart
RichText(
  text: const TextSpan(
    text: 'Нажмите ',
    style: TextStyle(fontSize: 16, color: Colors.black54),
    children: [
      TextSpan(
        text: 'сюда',
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            print('Нажат!');
          },
      ),
      TextSpan(text: ' для перехода'),
    ],
  ),
)
```

### HTML-подобное форматирование

```dart
RichText(
  text: TextSpan(
    children: [
      TextSpan(text: 'Красный: ', style: TextStyle(color: Colors.black)),
      TextSpan(text: 'красный', style: TextStyle(color: Colors.red)),
      TextSpan(text: ', ', style: TextStyle(color: Colors.black)),
      TextSpan(text: 'зелёный', style: TextStyle(color: Colors.green)),
      TextSpan(text: ', ', style: TextStyle(color: Colors.black)),
      TextSpan(text: 'синий', style: TextStyle(color: Colors.blue)),
    ],
  ),
)
```

## Использование Google Fonts

Для подключения пользовательских шрифтов используйте пакет `google_fonts`:

```yaml
# pubspec.yaml
dependencies:
  google_fonts: ^6.1.0
```

```dart
Text(
  'Кастомный шрифт',
  style: GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.deepPurple,
  ),
)
```

## Best Practices

1. **Используйте `maxLines` и `overflow`** для предотвращения неограниченного роста текста:
   ```dart
   Text(
     userBio,
     maxLines: 3,
     overflow: TextOverflow.ellipsis,
   )
   ```

2. **Используйте `RichText`** только когда нужны разные стили в одном тексте. Для простых случаев используйте `Text`.

3. **Устанавливайте `textDirection`** явно, если приложение поддерживает RTL-языки:
   ```dart
   Text(
     'Текст',
     textDirection: TextDirection.ltr,
   )
   ```

4. **Используйте `softWrap: false`** для отключения переноса строк:
   ```dart
   Text(
     'Одна длинная строка без переносов',
     softWrap: false,
     overflow: TextOverflow.ellipsis,
   )
   ```

5. **Используйте `TextScaler.maxScaleFactor`** для ограничения масштабирования шрифта:
   ```dart
   Text(
     'Текст',
     textScaler: TextScaler.linear(2.0), // Максимум 2x масштаб
   )
   ```

6. **Избегайте жёстко заданных размеров шрифтов** — используйте `Theme.of(context).textTheme` для соответствия системным настройкам:
   ```dart
   Text(
     'Текст',
     style: Theme.of(context).textTheme.headlineMedium,
   )
   ```
