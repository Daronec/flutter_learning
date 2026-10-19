# PageTransitions — анимации навигации

## Введение

PageTransitions определяют, как экраны появляются и исчезают при навигации. Flutter предоставляет стандартные переходы, но также позволяет создавать полностью кастомные.

## Стандартные PageTransitions

### Material PageTransitions

Material Design предоставляет несколько стандартных переходов:

| Переход | Описание |
|---------|----------|
| `FadeUpwardsPageTransition` | Появление снизу с затуханием |
| `PlatformDefaultPageTransition` | Зависит от платформы |
| `SharedAxisPageTransition` | Общая ось (Material 3) |

### Cupertino PageTransitions

iOS-стиль переходов:

```dart
// Cupertino-стиль (по умолчанию на iOS)
Navigator.push(
  context,
  CupertinoPageRoute(
    builder: (context) => const NextScreen(),
  ),
);
```

## Custom Page Route

### Базовый кастомный переход

```dart
class CustomPageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;

  CustomPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  bool get maintainState => true;

  @override
  bool get opaque => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Анимация появления слева
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }

  @override
  Widget buildContent(BuildContext context) => child;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      child;
}

// Использование
Navigator.push(
  context,
  CustomPageRoute(child: const NextScreen()),
);
```

### PageRouteBuilder

Более простой способ создания кастомных переходов:

```dart
class RouteBuilderExample extends StatelessWidget {
  const RouteBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route Builder')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const NextScreen();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  // Комбинированные анимации
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
                reverseTransitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          child: const Text('Перейти'),
        ),
      ),
    );
  }
}
```

## Популярные типы переходов

### Slide Transitions

```dart
// Справа налево (Material стандарт)
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  )),
  child: child,
)

// Снизу вверх
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  )),
  child: child,
)

// Сверху вниз
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  )),
  child: child,
)

// Сверху вниз (pop)
SlideTransition(
  position: Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, -1),
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  )),
  child: child,
)
```

### Scale Transition

```dart
ScaleTransition(
  scale: Tween<double>(
    begin: 0.8,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutBack,
  )),
  child: child,
)
```

### Rotate Transition

```dart
RotateTransition(
  turns: Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  )),
  child: child,
)
```

### Combined Transitions

```dart
// Комбинация нескольких анимаций
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(0, 0.1),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  )),
  child: FadeTransition(
    opacity: Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    )),
    child: ScaleTransition(
      scale: Tween<double>(
        begin: 0.95,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    ),
  ),
)
```

## Shared Axis Transitions (Material 3)

### Horizontal Shared Axis

```dart
class SharedAxisTransition extends PageTransitionsTheme {
  @override
  Widget build(
    BuildContext context,
    double animation,
    double secondaryAnimation,
    Directionality textDirection,
    Widget child,
  ) {
    final offsetTween = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    );

    return SlideTransition(
      position: offsetTween.animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: child,
    );
  }
}
```

### Vertical Shared Axis

```dart
class VerticalSharedAxisTransition extends PageTransitionsTheme {
  @override
  Widget build(
    BuildContext context,
    double animation,
    double secondaryAnimation,
    Directionality textDirection,
    Widget child,
  ) {
    final offsetTween = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    );

    return SlideTransition(
      position: offsetTween.animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: child,
    );
  }
}
```

## Применение к MaterialApp

```dart
void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: SharedAxisTransition(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeScreen(),
    ),
  );
}
```

## Сравнение подходов

| Подход | Сложность | Гибкость | Когда использовать |
|--------|----------|----------|-------------------|
| `PageRouteBuilder` | Низкая | Средняя | Быстрые кастомные переходы |
| `PageRoute` | Высокая | Полная | Сложные переходы |
| `SharedAxis` | Средняя | Средняя | Material 3 стиль |
| Стандартные | Низкая | Низкая | Стандартный Material/iOS |

## Лучшие практики

1. **Используйте `PageRouteBuilder`** для простых кастомных переходов
2. **Применяйте `CurvedAnimation`** для естественных движений
3. **Сохраняйте консистентность** — используйте одинаковые переходы в приложении
4. **Учитывайте платформу** — Android и iOS имеют разные стандарты
5. **Добавляйте `reverseTransitionDuration`** для плавного возврата
6. **Тестируйте на реальных устройствах** — эмуляторы могут не показывать полную картину
