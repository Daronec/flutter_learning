# Анимации переходов между страницами

Анимации переходов улучшают пользовательский опыт, создавая плавные визуальные связи между экранами. Flutter предоставляет гибкие инструменты для кастомизации переходов.

## Custom Page Transitions

### MaterialPageRoute с кастомной анимацией

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const NextScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Slide слева направо
      const begin = Offset(-1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  ),
);
```

### Slide Transition

```dart
// Slide снизу вверх (для диалогов)
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const BottomSheetScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  ),
);

// Slide справа налево (стандартный для Android)
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const DetailScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  ),
);
```

### Fade Transition

```dart
// Простое затухание
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const FadeScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
);

// Fade + Scale
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const FadeScaleScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        ),
      );
    },
  ),
);
```

### Scale Transition

```dart
// Масштабирование от центра
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const ScaleScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
        ),
        child: child,
      );
    },
  ),
);

// Scale с поворотом
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const ScaleRotateScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
        ),
        child: ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.elasticOut,
            ),
          ),
          child: child,
        ),
      );
    },
  ),
);
```

## Комбинированные анимации

### Slide + Fade

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const CombinedScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.3);
      const end = Offset.zero;
      const curve = Curves.easeOut;

      var tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  ),
);
```

### Reverse анимация

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return const ReversibleScreen();
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Анимация при переходе ВПЕРЁД
      var forwardTween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      // Анимация при возврате
      var reverseTween = Tween(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(
        position: animation.isForward
            ? animation.drive(forwardTween)
            : animation.drive(reverseTween),
        child: child,
      );
    },
  ),
);
```

## Анимация контента экрана

### AnimatedBuilder внутри экрана

```dart
class AnimatedScreen extends StatelessWidget {
  final Animation<double> animation;

  const AnimatedScreen({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Анимированный экран')),
      body: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Column(
            children: [
              // Заголовок появляется первым
              FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                  ),
                ),
                child: const Text(
                  'Заголовок',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 20),
              // Контент появляется вторым
              FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
                  ),
                ),
                child: const Text('Основной контент'),
              ),
              const SizedBox(height: 20),
              // Кнопка появляется последней
              FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Назад'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Использование
Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      return AnimatedScreen(animation: animation);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  ),
);
```

## Реusable анимации

### Миксин для анимированных переходов

```dart
mixin AnimatedTransitions {
  PageRoute<T> slideRoute<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(-1.0, 0.0),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(begin: begin, end: Offset.zero).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: duration,
    );
  }

  PageRoute<T> fadeRoute<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: duration,
    );
  }

  PageRoute<T> scaleRoute<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    double beginScale = 0.5,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween(begin: beginScale, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }
}

// Использование
class MyWidget with AnimatedTransitions {
  void _navigateToDetail() {
    Navigator.push(
      context,
      slideRoute(page: const DetailScreen()),
    );
  }
}
```

## Best Practices

1. **Сохраняйте консистентность** — используйте одинаковые анимации для похожих переходов.
2. **Не переусердствуйте** — простые анимации работают лучше сложных.
3. **Используйте `Interval`** для каскадных анимаций внутри экрана.
4. **Настройте длительность** — 200-400мс оптимально для большинства переходов.
5. **Используйте `Curves`** — `easeInOut` для плавности, `elasticOut` для акцента.
6. **Анимация контента** — элементы экрана должны появляться каскадом, а не все сразу.
7. **Учитывайте производительность** — избегайте сложных анимаций на слабых устройствах.
8. **Тестируйте на iOS** — анимации должны соответствовать гайдлайнам платформы.

## Сравнение кривых анимации

| Кривая | Описание | Применение |
|---|---|---|
| `easeInOut` | Плавное ускорение и замедление | Стандартные переходы |
| `easeOutCubic` | Быстрый старт, медленный конец | Slide снизу |
| `elasticOut` | Пружинящий эффект | Scale, появление |
| `decelerate` | Замедление в конце | Fade |
| `fastOutSlowIn` | Material Design стандарт | Android-переходы |
