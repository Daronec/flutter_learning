# AnimationConfig и CurvedAnimation

## Введение

`CurvedAnimation` — это один из самых часто используемых классов в анимационной системе Flutter. Он связывает `AnimationController` с `Curve`, позволяя управлять скоростью анимации.

## CurvedAnimation

### Базовое использование

```dart
class CurvedAnimationExample extends StatefulWidget {
  const CurvedAnimationExample({super.key});

  @override
  State<CurvedAnimationExample> createState() =>
      _CurvedAnimationExampleState();
}

class _CurvedAnimationExampleState
    extends State<CurvedAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // CurvedAnimation связывает контроллер с кривой
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Запуск
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller.isForwardAnimating) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  'Scale',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### Параметры CurvedAnimation

| Параметр | Тип | Описание |
|----------|-----|----------|
| `parent` | `Animation<double>` | Родительская анимация (контроллер) |
| `curve` | `Curve` | Кривая для прямого направления |
| `reverseCurve` | `Curve?` | Кривая для обратного направления |

## ReverseCurve

### Разные кривые для прямого и обратного направления

```dart
class ReverseCurveExample extends StatefulWidget {
  const ReverseCurveExample({super.key});

  @override
  State<ReverseCurveExample> createState() =>
      _ReverseCurveExampleState();
}

class _ReverseCurveExampleState
    extends State<ReverseCurveExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Разные кривые для forward и reverse
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,     // Ускорение при forward
      reverseCurve: Curves.easeOut, // Замедление при reverse
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller.isForwardAnimating) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value * 100, 0),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}
```

### Комбинация кривых

```dart
// Стандартные комбинации
CurvedAnimation(
  parent: _controller,
  curve: Curves.easeInOut,
  reverseCurve: Curves.easeInOut.flipped,
)

// Зеркальная кривая
CurvedAnimation(
  parent: _controller,
  curve: Curves.easeOutCubic,
  reverseCurve: Curves.easeInCubic,
)
```

## ReverseAnimation

### Обратная анимация

```dart
class ReverseAnimationExample extends StatefulWidget {
  const ReverseAnimationExample({super.key});

  @override
  State<ReverseAnimationExample> createState() =>
      _ReverseAnimationExampleState();
}

class _ReverseAnimationExampleState
    extends State<ReverseAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _forwardAnimation;
  late Animation<double> _reverseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Прямая анимация
    _forwardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Обратная анимация — значения инвертируются
    _reverseAnimation = ReverseAnimation(_forwardAnimation);

    // Запуск
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Прямая анимация
        AnimatedBuilder(
          animation: _forwardAnimation,
          builder: (context, child) {
            return ScaleTransition(
              scale: _forwardAnimation,
              child: Container(
                width: 80,
                height: 80,
                color: Colors.blue,
                child: const Center(
                  child: Text('Fwd',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          },
        ),
        // Обратная анимация
        AnimatedBuilder(
          animation: _reverseAnimation,
          builder: (context, child) {
            return ScaleTransition(
              scale: _reverseAnimation,
              child: Container(
                width: 80,
                height: 80,
                color: Colors.red,
                child: const Center(
                  child: Text('Rev',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
```

### Методы ReverseAnimation

| Метод | Описание |
|-------|----------|
| `value` | Инвертированное значение |
| `status` | Инвертированный статус |

## ChainAnimation (Цепочка анимаций)

### SequentialAnimation

```dart
class SequentialAnimationExample extends StatefulWidget {
  const SequentialAnimationExample({super.key});

  @override
  State<SequentialAnimationExample> createState() =>
      _SequentialAnimationExampleState();
}

class _SequentialAnimationExampleState
    extends State<SequentialAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _colorAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Каждая анимация на своём участке времени
    _sizeAnimation = Tween<double>(begin: 50, end: 200).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.33, curve: Curves.easeOut),
      ),
    );

    _colorAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 0.66, curve: Curves.easeInOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Масштаб
            Transform.scale(
              scale: _sizeAnimation.value / 50,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.primaries[
                    (_colorAnimation.value * 19).toInt() % 19],
              ),
            ),
            // Прозрачность
            Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }
}
```

## Interval

### Точный контроль над таймингом

```dart
// Interval определяет, на какой части анимации работает Tween
const Interval(
  start,       // Начало (0.0 — 1.0)
  end,         // Конец (0.0 — 1.0)
  curve,       // Кривая
  curveReverse, // Обратная кривая
)
```

### Примеры Interval

```dart
// Анимация на первой трети (0% — 33%)
final firstThird = Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.33, curve: Curves.easeOut),
  ),
);

// Анимация на второй трети (33% — 66%)
final secondThird = Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.33, 0.66, curve: Curves.easeInOut),
  ),
);

// Анимация на последней трети (66% — 100%)
final lastThird = Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.66, 1.0, curve: Curves.easeIn),
  ),
);

// Полная анимация (0% — 100%)
final fullAnimation = Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ),
);
```

## BlendAnimation (Смешивание анимаций)

### BlendAnimation

```dart
class BlendAnimationExample extends StatefulWidget {
  const BlendAnimationExample({super.key});

  @override
  State<BlendAnimationExample> createState() =>
      _BlendAnimationExampleState();
}

class _BlendAnimationExampleState
    extends State<BlendAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _blendAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Смешивание двух анимаций
    _blendAnimation = Tween<double>(begin: 0, end: 1).animate(
      _scaleAnimation.drive(
        CurveTween(curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.rotationZ(_rotationAnimation.value * 3.14),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
        );
      },
    );
  }
}
```

## Drive API

### Комбинирование Tween и Curve

```dart
// Drive API — цепочка трансформаций
final animation = controller.drive(
  Tween<double>(begin: 0, end: 100),
).drive(
  CurveTween(curve: Curves.easeInOut),
);

// Альтернативный синтаксис
final animation = Tween<double>(begin: 0, end: 100)
    .animate(CurvedAnimation(
  parent: _controller,
  curve: Curves.easeInOut,
));

// Drive с несколькими трансформациями
final animation = _controller.drive(
  Tween<double>(begin: 0, end: 1),
).drive(
  CurveTween(curve: Curves.easeInOut),
).drive(
  Tween<double>(begin: 50, end: 200),
);
```

## Лучшие практики

1. **Используйте `CurvedAnimation`** для всех анимаций
2. **Задавайте `reverseCurve`** для разных forward/reverse кривых
3. **Используйте `Interval`** для последовательных анимаций
4. **Используйте `ReverseAnimation`** для инвертированных анимаций
5. **Кэшируйте `CurvedAnimation`** как final поля
6. **Используйте Drive API** для цепочек трансформаций
