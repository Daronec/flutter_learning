---
tags:
  - animations
chapter: 12
section: 4
title: Explicit Animations: AnimationController и Tween
alias: 12 04 explicit animations
status: complete
---

# Explicit Animations: AnimationController и Tween

## Введение

Explicit Animations (явные анимации) дают полный контроль над процессом анимации. Вы управляете каждым кадром, что позволяет создавать сложные последовательности и синхронизированные анимации.

## AnimationController Lifecycle

### Создание и управление

```dart
class ExplicitAnimationExample extends StatefulWidget {
  const ExplicitAnimationExample({super.key});

  @override
  State<ExplicitAnimationExample> createState() =>
      _ExplicitAnimationExampleState();
}

class _ExplicitAnimationExampleState
    extends State<ExplicitAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Создание контроллера
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
      // Можно задать начальный и конечный значения
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    // Привязка анимации к контроллеру
    _animation = _controller;

    // Слушатели
    _controller.addListener(() {
      // Вызывается каждый кадр
      // print('Value: ${_animation.value}');
    });

    _controller.addStatusListener((status) {
      // Статусы: dismissed, forward, reverse, completed
      if (status == AnimationStatus.completed) {
        print('Анимация завершена!');
      }
    });

    // Запуск анимации
    _controller.forward();
  }

  @override
  void dispose() {
    // Обязательно освобождаем ресурсы
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _controller.value,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _controller.forward(),
            child: const Icon(Icons.play_arrow),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _controller.reverse(),
            child: const Icon(Icons.replay),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _controller.reset(),
            child: const Icon(Icons.replay_all),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _controller.forward(from: 0.5),
            child: const Icon(Icons.fast_forward),
          ),
        ],
      ),
    );
  }
}
```

### Методы AnimationController

| Метод | Описание |
|-------|----------|
| `forward({from})` | Проигрывание вперёд |
| `reverse({from})` | Проигрывание назад |
| `forward(from: 0.5)` | Начать с середины |
| `reset()` | Сброс к начальному значению |
| `animateTo(target, ...)` | Анимация к конкретному значению |
| `animateBack(target, ...)` | Анимация обратно |
| `fling({velocity})` | Резкий "взмах" |
| `stop([cancel])` | Остановка анимации |
| `status` | Текущий статус |
| `value` | Текущее значение |

## Tween класс

### Базовый Tween

```dart
// Переход от begin до end
final tween = Tween<double>(begin: 0, end: 100);

// Анимация с кривой
final animation = tween.animate(
  CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ),
);

// Анимация без кривой (линейная)
final linearAnimation = tween.animate(_controller);
```

### Tween.animate

```dart
// Простая анимация
Animation<double> animation = tween.animate(_controller);

// Анимация с кривой
Animation<double> curvedAnimation = tween.animate(
  CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ),
);

// Анимация с кривой и обратной кривой
Animation<double> bidirectionalAnimation = tween.animate(
  CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
    reverseCurve: Curves.easeOut,
  ),
);
```

### Типы Tween

| Tween | Типы значений |
|-------|--------------|
| `Tween<T>` | Любые значения |
| `ColorTween` | Color |
| `SizeTween` | Size |
| `RectTween` | Rect |
| `OffsetTween` | Offset |
| `VectorTween` | Vector3 |
| `QuaternionTween` | Quaternion |
| `BoolTween` | bool |
| `IntTween` | int |
| `DoubleTween` | double |

### Примеры различных Tween

```dart
// Цвет
final colorTween = ColorTween(
  begin: Colors.blue,
  end: Colors.red,
);

// Размер
final sizeTween = SizeTween(
  begin: const Size(100, 100),
  end: const Size(200, 200),
);

// Позиция
final offsetTween = OffsetTween(
  begin: Offset.zero,
  end: const Offset(100, 50),
);

// Прямоугольник
final rectTween = RectTween(
  begin: const Rect.fromLTWH(0, 0, 100, 100),
  end: const Rect.fromLTWH(50, 50, 200, 200),
);

// Интеграция с виджетами
Container(
  width: sizeTween.evaluate(_controller).width,
  height: sizeTween.evaluate(_controller).height,
  color: colorTween.evaluate(_controller),
  child: Transform.translate(
    offset: offsetTween.evaluate(_controller),
    child: const Text('Hello'),
  ),
)
```

## Sequence Animation (Последовательные анимации)

### StepByStep

```dart
class SequenceAnimationExample extends StatefulWidget {
  const SequenceAnimationExample({super.key});

  @override
  State<SequenceAnimationExample> createState() =>
      _SequenceAnimationExampleState();
}

class _SequenceAnimationExampleState
    extends State<SequenceAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Каждый Tween занимает часть времени
    _sizeAnimation = Tween<double>(begin: 50, end: 200).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.33, curve: Curves.easeOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 0.66, curve: Curves.easeIn),
      ),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 1.0, curve: Curves.easeInOut),
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
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _sizeAnimation.value / 50,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  color: _colorAnimation.value,
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

### Interval

```dart
// Interval определяет, на какой части анимации работает Tween
const Interval(
  start,    // Начало (0.0 - 1.0)
  end,      // Конец (0.0 - 1.0)
  curve,    // Кривая
  curveReverse, // Обратная кривая
)
```

## Staggered Animation (Рассинхронизированные анимации)

```dart
class StaggeredAnimationExample extends StatefulWidget {
  const StaggeredAnimationExample({super.key});

  @override
  State<StaggeredAnimationExample> createState() =>
      _StaggeredAnimationExampleState();
}

class _StaggeredAnimationExampleState
    extends State<StaggeredAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Каждая анимация начинается с задержкой
    _animations = List.generate(
      5,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            (index * 0.15) + 0.3,
            curve: Curves.easeOut,
          ),
        ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return AnimatedContainer(
              duration: Duration.zero,
              width: 20,
              height: 20 + (_animations[index].value * 80),
              color: Colors.primaries[index],
              margin: const EdgeInsets.symmetric(horizontal: 4),
            );
          },
        ),
      ),
    );
  }
}
```

## Лучшие практики

1. **Всегда вызывайте `dispose()`** у AnimationController
2. **Используйте `Interval`** для последовательных анимаций
3. **Кэшируйте Animation-объекты** как final поля
4. **Используйте `SingleTickerProviderStateMixin`** для одного контроллера
5. **Используйте `MultiTickerProviderStateMixin`** для нескольких
6. **Избегайте создания Tween в `build()`**
