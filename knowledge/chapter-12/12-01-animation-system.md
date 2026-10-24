---
tags:
  - animations
chapter: 12
section: 1
title: Анимационная система Flutter
alias: 12 01 animation system
status: complete
---

# Анимационная система Flutter

## Введение

Анимации в Flutter построены на основе системы `Animation` и `Controller`. Понимание этой системы — ключ к созданию плавных и производительных анимаций.

## Основные компоненты

| Компонент | Назначение |
|-----------|-----------|
| `Animation<double>` | Объект, генерирующий значения |
| `AnimationController` | Управляет анимацией (вперёд/назад) |
| `Curve` | Определяет траекторию изменения |
| `Tween` | Преобразует диапазон значений |

## Animation

`Animation<T>` — это абстрактный класс, который генерирует значения во время анимации:

```dart
class Animation<T> {
  T get value;              // Текущее значение
  AnimationStatus get status; // Статус анимации
  void addListener(VoidCallback listener);  // Слушатель значений
  void addStatusListener(StatusListener listener); // Слушатель статуса
}
```

Статусы анимации:

| Статус | Описание |
|--------|----------|
| `dismissed` | Анимация в начальном положении |
| `forward` | Анимация проигрывается вперёд |
| `reverse` | Анимация проигрывается назад |
| `completed` | Анимация завершена |

## AnimationController

`AnimationController` — главный управляющий класс анимаций:

```dart
class MyAnimation extends StatefulWidget {
  const MyAnimation({super.key});

  @override
  State<MyAnimation> createState() => _MyAnimationState();
}

class _MyAnimationState extends State<MyAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Создаём контроллер с длительностью
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this, // Требуется TickerProvider
    );

    // Анимация от 0.0 до 1.0
    _animation = _controller;

    // Запуск анимации
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Обязательно!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Переключение направления
        if (_controller.isForwardAnimating) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
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

### Параметры AnimationController

| Параметр | Описание | Значение по умолчанию |
|----------|----------|----------------------|
| `duration` | Длительность анимации | Обязательный |
| `lowerBound` | Нижняя граница | 0.0 |
| `upperBound` | Верхняя граница | 1.0 |
| `value` | Текущее значение | 0.0 |
| `velocity` | Скорость анимации | 1.0 |

## Curves (Кривые)

Curves определяют скорость изменения анимации во времени:

```dart
// Стандартные кривые
Curves.ease        // Плавное замедление
Curves.easeIn      // Ускорение
Curves.easeOut     // Замедление
Curves.easeInOut   // Ускорение + замедление
Curves.fastOutSlowIn // Material Design по умолчанию
Curves.linear      // Линейная (без изменений скорости)

// Экстремальные кривые
Curves.bounceIn    // Отскок при входе
Curves.bounceOut   // Отскок при выходе
Curves.bounceInOut // Отскод при входе и выходе
Curves.elasticIn   // Пружина при входе
Curves.elasticOut  // Пружина при выходе

// Пользовательская кривая
Curves.decelerate  // Замедление в конце
Curves.accelerate  // Ускорение в конце
```

### Использование кривых

```dart
_animation = CurvedAnimation(
  parent: _controller,
  curve: Curves.easeInOut,
);

// Множественные кривые
_animation = CurvedAnimation(
  parent: _controller,
  curves: [
    Curves.easeIn,    // Первые 50%
    Curves.bounceOut, // Последние 50%
  ],
);
```

## Tween (Переход значений)

Tween преобразует один диапазон значений в другой:

```dart
// Переход от 0 до 100
final tween = Tween<double>(begin: 0, end: 100);

// Использование
final animation = tween.animate(_controller);

// Анимация цвета
final colorTween = ColorTween(
  begin: Colors.blue,
  end: Colors.red,
);
final colorAnimation = colorTween.animate(_controller);

// Анимация размера
final sizeTween = Tween<double>(begin: 50, end: 200);
final sizeAnimation = sizeTween.animate(_controller);

// Анимация позиции
final offsetTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(100, 0),
);
final offsetAnimation = offsetTween.animate(_controller);
```

### CompositeTween

```dart
// Комбинирование нескольких Tween
final tween = TweenSequence<double>([
  TweenSequenceItem(
    tween: Tween<double>(begin: 0, end: 100),
    weight: 50, // 50% времени
  ),
  TweenSequenceItem(
    tween: Tween<double>(begin: 100, end: 50),
    weight: 50, // 50% времени
  ),
]);

final animation = tween.animate(_controller);
```

## Полный пример анимации

```dart
class FullAnimationExample extends StatefulWidget {
  const FullAnimationExample({super.key});

  @override
  State<FullAnimationExample> createState() => _FullAnimationExampleState();
}

class _FullAnimationExampleState extends State<FullAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Масштаб с отскоком
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    // Прозрачность
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    // Сдвиг
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Цвет
    _colorAnimation = ColorTween(
      begin: Colors.blue,
      end: Colors.purple,
    ).animate(_controller);

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
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Animated!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Лучшие практики

1. **Всегда вызывайте `dispose()`** у AnimationController
2. **Используйте `SingleTickerProviderStateMixin`** для одного контроллера
3. **Используйте `MultiTickerProviderStateMixin`** для нескольких контроллеров
4. **Избегайте создания анимаций в `build()`** — создавайте в `initState()`
5. **Используйте `CurvedAnimation`** для плавных анимаций
6. **Кэшируйте Tween-объекты** как final поля
## РЎРІСЏР·Р°РЅРЅС‹Рµ РіР»Р°РІС‹

[[Что такое Widget? Философия «всё — виджет»]] [[Container, Padding, SizedBox — отступы и размеры]] 
