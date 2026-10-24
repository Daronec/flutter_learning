---
tags:
  - animations
chapter: 12
section: 7
title: Lottie — анимации из After Effects
alias: 12 07 lottie
status: complete
---

# Lottie — анимации из After Effects

## Введение

Lottie — это библиотека для рендеринга анимаций, созданных в Adobe After Effects. Она экспортирует анимацию в JSON-формат, который можно воспроизводить на любой платформе.

## Преимущества Lottie

- **Кроссплатформенность** — одна анимация для всех платформ
- **Малый размер** — JSON-файл обычно меньше видео
- **Масштабируемость** — векторная графика без потери качества
- **Интерактивность** — можно управлять анимацией из кода
- **Быстрая разработка** — дизайнер создаёт в After Effects

## Установка

```yaml
dependencies:
  lottie: ^3.1.0
```

## Загрузка анимаций

### Из assets

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/animations/
```

```dart
// Загрузка из локального файла
Lottie.asset(
  'assets/animations/success.json',
  width: 200,
  height: 200,
  fit: BoxFit.contain,
  repeat: true,
  reverse: true,
  animate: true,
)
```

### Из network

```dart
// Загрузка из URL
Lottie.network(
  'https://assets2.lottiefiles.com/packages/lf20_wcavtq.json',
  width: 200,
  height: 200,
  fit: BoxFit.contain,
  repeat: true,
)
```

### Из bytes

```dart
// Загрузка из ByteData
final bytes = await rootBundle.load('assets/animations/success.json');
final lottieComposition = LottieCompositionFactory.fromBytes(
  bytes.buffer.asUint8List(),
);

Lottie.asset(
  'data', // special path for fromBytes
  width: 200,
  height: 200,
)
```

## Widget Lottie

### Базовое использование

```dart
class LottieExample extends StatelessWidget {
  const LottieExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/rocket.json',
      width: 300,
      height: 300,
      fit: BoxFit.contain,
      // Анимация воспроизводится
      repeat: true,
      // Обратное воспроизведение
      reverse: false,
      // Включена ли анимация
      animate: true,
      // Пакет анимации
      package: null,
      // Callback по завершении
      onLoaded: (composition) {
        print('Длительность: ${composition.duration}');
        print('Кадров: ${composition.totalFrames}');
        print('FPS: ${composition.fps}');
      },
      // Builder для кастомизации
      builder: (composition) {
        return Column(
          children: [
            Lottie.asset(
              'assets/animations/rocket.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            Text('Запуск ракеты!'),
          ],
        );
      },
    );
  }
}
```

### Параметры Lottie Widget

| Параметр | Тип | Описание |
|----------|-----|----------|
| `assetName` | `String` | Путь к JSON-файлу |
| `package` | `String?` | Пакет для package assets |
| `width` | `double?` | Ширина |
| `height` | `double?` | Высота |
| `fit` | `BoxFit?` | Метод заполнения |
| `repeat` | `bool` | Повторять анимацию |
| `reverse` | `bool` | Обратное воспроизведение |
| `animate` | `bool` | Включить анимацию |
| `frame` | `int?` | Начальный кадр |
| `onLoaded` | `CompositionCallback` | Callback при загрузке |
| `builder` | `LottieBuilder` | Кастомный builder |

## LottieController

### Управление анимацией

```dart
class LottieControllerExample extends StatefulWidget {
  const LottieControllerExample({super.key});

  @override
  State<LottieControllerExample> createState() =>
      _LottieControllerExampleState();
}

class _LottieControllerExampleState
    extends State<LottieControllerExample> {
  late LottieController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LottieController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset(
          'assets/animations/rocket.json',
          controller: _controller,
          width: 300,
          height: 300,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _controller.forward(),
              child: const Text('▶ Вперёд'),
            ),
            ElevatedButton(
              onPressed: () => _controller.reverse(),
              child: const Text('◀ Назад'),
            ),
            ElevatedButton(
              onPressed: () => _controller.stop(),
              child: const Text('⏹ Стоп'),
            ),
            ElevatedButton(
              onPressed: () => _controller.reset(),
              child: const Text('↺ Сброс'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Slider(
          value: _controller.value,
          onChanged: (value) {
            _controller.jumpTo(value);
          },
        ),
      ],
    );
  }
}
```

### Методы LottieController

| Метод | Описание |
|-------|----------|
| `forward()` | Воспроизведение вперёд |
| `reverse()` | Обратное воспроизведение |
| `stop()` | Остановка |
| `reset()` | Сброс к началу |
| `jumpTo(value)` | Переход к значению (0-1) |
| `jumpToFrame(frame)` | Переход к кадру |
| `play()` | Воспроизведение |
| `pause()` | Пауза |

## Анимация по скроллу

```dart
class ScrollLottieExample extends StatefulWidget {
  const ScrollLottieExample({super.key});

  @override
  State<ScrollLottieExample> createState() => _ScrollLottieExampleState();
}

class _ScrollLottieExampleState extends State<ScrollLottieExample> {
  late ScrollController _scrollController;
  late LottieController _lottieController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _lottieController = LottieController();

    _scrollController.addListener(() {
      // Вычисляем прогресс на основе скролла
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        final progress = _scrollController.offset / maxScroll;
        _lottieController.jumpTo(progress.clamp(0.0, 1.0));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      children: [
        SizedBox(
          height: 300,
          child: Center(
            child: Lottie.asset(
              'assets/animations/progress.json',
              controller: _lottieController,
              width: 200,
              height: 200,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Скролльте для управления анимацией'),
        const SizedBox(height: 1000), // Для скролла
      ],
    );
  }
}
```

## Анимация по жесту

```dart
class GestureLottieExample extends StatefulWidget {
  const GestureLottieExample({super.key});

  @override
  State<GestureLottieExample> createState() => _GestureLottieExampleState();
}

class _GestureLottieExampleState
    extends State<GestureLottieExample> {
  late LottieController _controller;
  double _dragProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = LottieController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragProgress += details.primaryDelta! / 300;
          _dragProgress = _dragProgress.clamp(0.0, 1.0);
          _controller.jumpTo(_dragProgress);
        });
      },
      child: Column(
        children: [
          Lottie.asset(
            'assets/animations/progress.json',
            controller: _controller,
            width: 200,
            height: 200,
          ),
          Slider(
            value: _dragProgress,
            onChanged: (value) {
              setState(() {
                _dragProgress = value;
                _controller.jumpTo(value);
              });
            },
          ),
        ],
      ),
    );
  }
}
```

## Поиск анимаций

- [LottieFiles](https://lottiefiles.com/) — крупнейшая библиотека
- [LottieCommunity](https://github.com/LottieFiles/lottie-community) — сообщество
- After Effects + [Bodymovin](https://github.com/bodymovin/bodymovin) — плагин для экспорта

## Лучшие практики

1. **Оптимизируйте анимации** — удаляйте неиспользуемые слои
2. **Используйте `repeat: false`** для одноразовых анимаций
3. **Кэшируйте анимации** — Lottie делает это автоматически
4. **Проверяйте `onLoaded`** для получения метаданных
5. **Используйте `LottieController`** для интерактивности
6. **Тестируйте на слабых устройствах** — сложные анимации могут тормозить
