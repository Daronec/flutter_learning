---
tags:
  - animations
chapter: 12
section: 3
title: AnimatedBuilder и AnimatedCrossFade
alias: 12 03 animatedbuilder
status: complete
---

# AnimatedBuilder и AnimatedCrossFade

## Введение

`AnimatedBuilder` — это универсальный виджет для создания кастомных анимаций. Он позволяет переопределять метод `build` и анимировать любые свойства.

## AnimatedBuilder

### Базовое использование

```dart
class CustomAnimatedBuilder extends StatefulWidget {
  const CustomAnimatedBuilder({super.key});

  @override
  State<CustomAnimatedBuilder> createState() =>
      _CustomAnimatedBuilderState();
}

class _CustomAnimatedBuilderState
    extends State<CustomAnimatedBuilder>
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
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
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
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value * 100, 0),
          child: Transform.rotate(
            angle: _animation.value * 3.14,
            child: child,
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        color: Colors.blue,
      ),
    );
  }
}
```

### AnimatedBuilder с Tween

```dart
class TweenAnimatedBuilderExample extends StatefulWidget {
  const TweenAnimatedBuilderExample({super.key});

  @override
  State<TweenAnimatedBuilderExample> createState() =>
      _TweenAnimatedBuilderExampleState();
}

class _TweenAnimatedBuilderExampleState
    extends State<TweenAnimatedBuilderExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
      reverseDuration: const Duration(seconds: 2),
    );

    _sizeAnimation = Tween<double>(begin: 50, end: 200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.purple,
    ).animate(_controller);

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -50),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    );

    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _sizeAnimation,
        _colorAnimation,
        _offsetAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: _offsetAnimation.value,
          child: ScaleTransition(
            scale: _sizeAnimation.value / 50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(
                  _sizeAnimation.value / 5,
                ),
              ),
              child: child,
            ),
          ),
        );
      },
      child: const Center(
        child: Text('Hello', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
```

### AnimatedBuilder с Notifier

```dart
class ValueNotifierBuilderExample extends StatefulWidget {
  const ValueNotifierBuilderExample({super.key});

  @override
  State<ValueNotifierBuilderExample> createState() =>
      _ValueNotifierBuilderExampleState();
}

class _ValueNotifierBuilderExampleState
    extends State<ValueNotifierBuilderExample> {
  final ValueNotifier<double> _opacity = ValueNotifier(0.0);
  final ValueNotifier<double> _scale = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    // Анимация через Tween + AnimationController
    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    Tween<double>(begin: 0, end: 1).animate(controller).addListener(() {
      _opacity.value = controller.value;
      _scale.value = controller.value;
    });

    controller.forward();
  }

  @override
  void dispose() {
    _opacity.dispose();
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_opacity, _scale]),
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 200,
        height: 200,
        color: Colors.blue,
        child: const Center(
          child: Text(
            'Animated!',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
```

## AnimatedCrossFade

### Базовое использование

```dart
class AnimatedCrossFadeDetailed extends StatefulWidget {
  const AnimatedCrossFadeDetailed({super.key});

  @override
  State<AnimatedCrossFadeDetailed> createState() =>
      _AnimatedCrossFadeDetailedState();
}

class _AnimatedCrossFadeDetailedState
    extends State<AnimatedCrossFadeDetailed> {
  CrossFadeState _crossFadeState = CrossFadeState.showFirst;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedCrossFade(
          firstChild: _buildFirstView(),
          secondChild: _buildSecondView(),
          crossFadeState: _crossFadeState,
          duration: const Duration(milliseconds: 300),
          firstCurve: Curves.easeIn,
          secondCurve: Curves.easeOut,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _crossFadeState = _crossFadeState == CrossFadeState.showFirst
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst;
            });
          },
          child: Text(_crossFadeState == CrossFadeState.showFirst
              ? 'Показать второй'
              : 'Показать первый'),
        ),
      ],
    );
  }

  Widget _buildFirstView() {
    return Container(
      width: 200,
      height: 200,
      color: Colors.blue,
      child: const Center(
        child: Text('Первый экран', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSecondView() {
    return Container(
      width: 200,
      height: 200,
      color: Colors.red,
      child: const Center(
        child: Text('Второй экран', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
```

### AnimatedCrossFade с анимированными виджетами

```dart
class AnimatedCrossFadeWithWidgets extends StatefulWidget {
  const AnimatedCrossFadeWithWidgets({super.key});

  @override
  State<AnimatedCrossFadeWithWidgets> createState() =>
      _AnimatedCrossFadeWithWidgetsState();
}

class _AnimatedCrossFadeWithWidgetsState
    extends State<AnimatedCrossFadeWithWidgets> {
  CrossFadeState _state = CrossFadeState.showFirst;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: _AnimatedView(
        title: 'Данные A',
        color: Colors.blue,
        itemCount: 10,
      ),
      secondChild: _AnimatedView(
        title: 'Данные B',
        color: Colors.green,
        itemCount: 5,
      ),
      crossFadeState: _state,
      duration: const Duration(milliseconds: 400),
    );
  }
}

class _AnimatedView extends StatelessWidget {
  final String title;
  final Color color;
  final int itemCount;

  const _AnimatedView({
    required this.title,
    required this.color,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 300,
      color: color.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(title,
                style: TextStyle(color: color, fontSize: 18)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: itemCount,
              itemBuilder: (context, index) => ListTile(
                title: Text('Элемент $index'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Параметры AnimatedCrossFade

| Параметр | Тип | Описание |
|----------|-----|----------|
| `firstChild` | `Widget` | Первый виджет |
| `secondChild` | `Widget` | Второй виджет |
| `crossFadeState` | `CrossFadeState` | Текущее состояние |
| `duration` | `Duration` | Длительность |
| `firstCurve` | `Curve` | Кривая первого виджета |
| `secondCurve` | `Curve` | Кривая второго виджета |

## Когда использовать что

| Сценарий | Решение |
|----------|---------|
| Анимация одного свойства | `AnimatedContainer`, `AnimatedOpacity` |
| Кастомная анимация | `AnimatedBuilder` |
| Переключение двух виджетов | `AnimatedCrossFade` |
| Несколько анимаций | `AnimatedBuilder` с `Listenable.merge` |

## Лучшие практики

1. **Используйте `AnimatedBuilder`** для сложных кастомных анимаций
2. **Мержите анимации** через `Listenable.merge`
3. **Используйте `AnimatedCrossFade`** для переключения экранов
4. **Устанавливайте кривые** для каждого виджета отдельно
5. **Избегайте вложенных AnimatedBuilder** — это может быть дорого
6. **Используйте `child` параметр** для статического контента
