# Implicit Animations в Flutter

## Введение

Implicit Animations (неявные анимации) — это упрощённый подход к анимациям, при котором Flutter автоматически анимирует изменения свойств виджетов. Вам нужно только изменить значение — анимация создаётся автоматически.

## Когда использовать Implicit Animations

- Простые переходы между состояниями
- Анимация одного-двух свойств
- Не нужна точная настройка таймингов
- Быстрое прототипирование

## AnimatedContainer

Автоматически анимирует изменения свойств Container:

```dart
class AnimatedContainerExample extends StatefulWidget {
  const AnimatedContainerExample({super.key});

  @override
  State<AnimatedContainerExample> createState() =>
      _AnimatedContainerExampleState();
}

class _AnimatedContainerExampleState
    extends State<AnimatedContainerExample> {
  bool _isExpanded = false;
  Color _color = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
          _color = _color == Colors.blue ? Colors.red : Colors.blue;
        });
      },
      child: AnimatedContainer(
        // Длительность анимации
        duration: const Duration(milliseconds: 300),
        // Кривая анимации
        curve: Curves.easeInOut,
        // Анимируемые свойства
        width: _isExpanded ? 200 : 100,
        height: _isExpanded ? 200 : 100,
        decoration: BoxDecoration(
          color: _color,
          borderRadius: _isExpanded
              ? BorderRadius.circular(50)
              : BorderRadius.zero,
          boxShadow: _isExpanded
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            _isExpanded ? 'Большой' : 'Маленький',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
```

### Анимируемые свойства AnimatedContainer

| Свойство | Тип | Описание |
|----------|-----|----------|
| `width` | `double?` | Ширина |
| `height` | `double?` | Высота |
| `decoration` | `BoxDecoration?` | Декорация |
| `foregroundDecoration` | `BoxDecoration?` | Передний план |
| `constraints` | `BoxConstraints?` | Ограничения |
| `padding` | `EdgeInsets?` | Внутренний отступ |
| `margin` | `EdgeInsets?` | Внешний отступ |
| `transform` | `Matrix4?` | Трансформация |
| `alignment` | `AlignmentGeometry?` | Выравнивание |

## AnimatedOpacity

Анимация изменения прозрачности:

```dart
class AnimatedOpacityExample extends StatefulWidget {
  const AnimatedOpacityExample({super.key});

  @override
  State<AnimatedOpacityExample> createState() =>
      _AnimatedOpacityExampleState();
}

class _AnimatedOpacityExampleState
    extends State<AnimatedOpacityExample> {
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: Container(
            width: 200,
            height: 200,
            color: Colors.blue,
            child: const Center(
              child: Text(
                'Я меняю прозрачность',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => setState(() => _opacity = 0.0),
              child: const Text('Скрыть'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => setState(() => _opacity = 1.0),
              child: const Text('Показать'),
            ),
          ],
        ),
      ],
    );
  }
}
```

## AnimatedSize

Анимация изменения размера:

```dart
class AnimatedSizeExample extends StatefulWidget {
  const AnimatedSizeExample({super.key});

  @override
  State<AnimatedSizeExample> createState() => _AnimatedSizeExampleState();
}

class _AnimatedSizeExampleState extends State<AnimatedSizeExample> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Container(
          width: 200,
          height: _isExpanded ? 200 : 60,
          color: Colors.blue,
          child: Center(
            child: Text(
              _isExpanded ? 'Расширенный' : 'Свёрнутый',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
```

## AnimatedCrossFade

Анимация переключения между двумя виджетами:

```dart
class AnimatedCrossFadeExample extends StatefulWidget {
  const AnimatedCrossFadeExample({super.key});

  @override
  State<AnimatedCrossFadeExample> createState() =>
      _AnimatedCrossFadeExampleState();
}

class _AnimatedCrossFadeExampleState
    extends State<AnimatedCrossFadeExample> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: Container(
        width: 200,
        height: 200,
        color: Colors.blue,
        child: const Center(
          child: Text('Первый', style: TextStyle(color: Colors.white)),
        ),
      ),
      secondChild: Container(
        width: 200,
        height: 200,
        color: Colors.red,
        child: const Center(
          child: Text('Второй', style: TextStyle(color: Colors.white)),
        ),
      ),
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeOut,
      crossFadeState: _currentIndex == 0
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 300),
    );
  }
}
```

## Другие Implicit Animations

### AnimatedPadding

```dart
AnimatedPadding(
  padding: _isExpanded ? const EdgeInsets.all(20) : EdgeInsets.zero,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  child: Container(
    color: Colors.blue,
    width: 100,
    height: 100,
  ),
)
```

### AnimatedPhysicalModel

```dart
AnimatedPhysicalModel(
  duration: const Duration(milliseconds: 300),
  elevation: _isElevated ? 8 : 0,
  shape: BoxShape.rectangle,
  color: Colors.blue,
  borderRadius: BorderRadius.circular(_isElevated ? 16 : 0),
  child: Container(width: 100, height: 100),
)
```

### AnimatedDefaultTextStyle

```dart
AnimatedDefaultTextStyle(
  duration: const Duration(milliseconds: 300),
  style: TextStyle(
    fontSize: _isLarge ? 24 : 16,
    fontWeight: _isLarge ? FontWeight.bold : FontWeight.normal,
    color: _isLarge ? Colors.red : Colors.blue,
  ),
  child: const Text('Привет, мир!'),
)
```

## Сравнение Implicit и Explicit анимаций

| Характеристика | Implicit | Explicit |
|---------------|----------|----------|
| Сложность | Низкая | Высокая |
| Контроль | Ограниченный | Полный |
| Производительность | Хорошая | Отличная |
| Сценарии | Простые переходы | Сложные последовательности |
| Настройка кривых | Одна на всю анимацию | Разные для каждого свойства |

## Лучшие практики

1. **Используйте Implicit для простых анимаций** — меньше кода
2. **Устанавливайте `duration` и `curve`** явно
3. **Избегайте вложенных AnimatedContainer** — это может быть дорого
4. **Используйте `AnimatedBuilder`** для сложных случаев
5. **Не анимируйте слишком много свойств одновременно**
6. **Предпочитайте `AnimatedSize` для изменения размеров** вместо AnimatedContainer
