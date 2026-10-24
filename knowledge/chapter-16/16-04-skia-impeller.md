---
tags:
  - platform-channels
  - native
  - plugins
chapter: 16
section: 4
title: Skia и Impeller — графические рендереры
alias: 16 04 skia impeller
status: complete
---

# Skia и Impeller — графические рендереры

Flutter использует графические рендереры для отрисовки UI. Исторически основным рендерером была Skia, но начиная с Flutter 3.10 Google представила Impeller — новый рендерер для предсказуемой производительности.

## Обзор графических рендереров

### Сравнение рендереров

| Характеристика | Skia | Impeller |
|---------------|------|----------|
| Статус | Основной (legacy) | Новый (по умолчанию на iOS, бета на Android) |
| Компиляция шейдеров | Runtime (JIT) | Precompile (AOT) |
| Производительность | Переменная | Предсказуемая |
| Платформы | Все | iOS (stable), Android (beta) |
| Шейдерный язык | GLSL-like | Vulkan/MTL DSL |
| Задержка первого кадра | Выше (компиляция) | Ниже (предкомпиляция) |

## Skia Rendering

### Архитектура Skia

```
┌─────────────────────────────────────────┐
│         Flutter Framework               │
│         (Painting commands)             │
├─────────────────────────────────────────┤
│           Skia Backend                  │
│  ┌───────────┐ ┌──────────┐ ┌────────┐ │
│  │  Canvas   │ │  Picture │ │  Layer │ │
│  │  Commands │ │  Recorder│ │  Tree  │ │
│  └───────────┘ └──────────┘ └────────┘ │
│  ┌──────────────────────────────────┐  │
│  │     Shader Compilation (JIT)     │  │
│  │     (при первом использовании)    │  │
│  └──────────────────────────────────┘  │
├─────────────────────────────────────────┤
│       GPU API (OpenGL/Vulkan)           │
└─────────────────────────────────────────┘
```

### Skia Pipeline

```dart
import 'package:flutter/material.dart';

/// Пример использования Skia-рендерера через CustomPaint
class SkiaExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: SkiaPainter(),
    );
  }
}

class SkiaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Рисуем градиентный фон
    final gradient = LinearGradient(
      colors: [Colors.blue.shade300, Colors.purple.shade300],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 2. Рисуем круг с тенью
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      50,
      circlePaint,
    );

    // 3. Рисуем текст
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Skia',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(70, 90));
  }

  @override
  bool shouldRepaint(covariant SkiaPainter oldDelegate) => false;
}
```

### Оптимизация Skia

```dart
/// Техника Picture caching для оптимизации Skia
class OptimizedSkiaWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      // Изолируем перерисовку
      child: CustomPaint(
        size: const Size(300, 300),
        painter: ComplexSkiaPainter(),
      ),
    );
  }
}

class ComplexSkiaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Сохраняем контекст для оптимизации
    canvas.save();

    // Рисуем сложные элементы
    for (int i = 0; i < 100; i++) {
      final angle = (i * 3.6) * (3.14159 / 180);
      final x = size.width / 2 + cos(angle) * 100;
      final y = size.height / 2 + sin(angle) * 100;
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.blue);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ComplexSkiaPainter oldDelegate) => false;
}
```

### Skia Tracing

```dart
// Включение trace для анализа Skia
void enableSkiaTracing() {
  // Запуск с флагами Skia
  // flutter run --trace-skia
  // Или программно:
  debugProfilePaintsEnabled = true;
  debugRepaintRainbowEnabled = true;
}

// Repaint Rainbow — каждая перерисовка получает случайный цвет
// Позволяет визуально определить лишние перерисовки
```

## Impeller Rendering

### Архитектура Impeller

```
┌─────────────────────────────────────────┐
│         Flutter Framework               │
│         (Painting commands)             │
├─────────────────────────────────────────┤
│          Impeller Backend               │
│  ┌──────────────────────────────────┐   │
│  │  Precompiled Shader Cache        │   │
│  │  (AOT-компиляция при сборке)     │   │
│  └──────────────────────────────────┘   │
│  ┌───────────┐ ┌──────────┐ ┌────────┐ │
│  │  Pipeline │ │  Surface │ │  Atlas │ │
│  │  Builder  │ │  Manager │ │  (GPU) │ │
│  └───────────┘ └──────────┘ └────────┘ │
├─────────────────────────────────────────┤
│    Vulkan (Android) / Metal (iOS)       │
└─────────────────────────────────────────┘
```

### Ключевое отличие: Precompiled Shaders

```
Skia (JIT Compilation):
┌──────────────────────────────────┐
│  Первый кадр:                    │
│  1. Нарисовать → 2. Найти шейдер │
│  3. Компилировать шейдер (JIT)   │
│  4. Нарисовать с шейдером        │
│                                  │
│  → Задержка первого кадра        │
│  → Переменная производительность │
└──────────────────────────────────┘

Impeller (Precompiled):
┌──────────────────────────────────┐
│  При сборке:                     │
│  1. Скомпилировать все шейдеры   │
│  2. Сохранить в бинарный файл    │
│                                  │
│  При запуске:                    │
│  1. Загрузить предкомпилированные │
│  2. Нарисовать сразу             │
│                                  │
│  → Стабильный FPS                │
│  → Мгновенный первый кадр        │
└──────────────────────────────────┘
```

### Impeller в Flutter

```dart
// Проверка используемого рендерера
void checkRenderer() {
  // Flutter 3.10+: Impeller по умолчанию на iOS
  // Android: можно включить через флаг

  // Программная проверка (через Platform Channel)
  // или через DevTools → Renderer info
}

// Настройка Impeller через аргументы запуска
// flutter run --dart-define=FLUTTER_ENGINE_IMPELLER_RENDERER=impeller
```

### Impeller Shader DSL

```dart
// Impeller использует собственный DSL для шейдеров
// Пример шейдерного кода (в формате Impeller DSL):

/*
shader main : ImpellerDSL {
  input vertex {
    @location(0) vec2 position;
    @location(1) vec2 uv;
  };

  output fragment {
    @location(0) vec4 color;
  };

  uniform sampler2D texture;
  uniform vec4 tint;

  void main() {
    vec4 texColor = texture2D(texture, uv);
    color = texColor * tint;
  }
}
*/
```

## Сравнение производительности

### Метрики производительности

| Метрика | Skia | Impeller |
|---------|------|----------|
| FPS стабильность | ~85-95% | ~98-100% |
| Задержка первого кадра | 50-200ms | 5-20ms |
| Пиковый CPU при рендере | Высокий | Низкий |
| Потребление памяти GPU | Среднее | Ниже |
| Поддержка Android | Полная | Beta (3.16+) |
| Поддержка iOS | Полная | Stable (3.10+) |

### Бенчмарк-пример

```dart
// Пример бенчмарка производительности рендерера
class RendererBenchmark extends StatefulWidget {
  @override
  _RendererBenchmarkState createState() => _RendererBenchmarkState();
}

class _RendererBenchmarkState extends State<RendererBenchmark> {
  int _frameCount = 0;
  Duration _totalFrameTime = Duration.zero;
  List<double> _frameTimes = [];

  void _onFrame(Duration timestamp) {
    setState(() {
      _frameCount++;
      final frameTime = timestamp - _lastTimestamp;
      _totalFrameTime += frameTime;
      _frameTimes.add(frameTime.inMilliseconds.toDouble());

      if (_frameTimes.length > 100) {
        _frameTimes.removeAt(0);
      }
    });
    _lastTimestamp = timestamp;
  }

  double get _avgFrameTime {
    if (_frameTimes.isEmpty) return 0;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }

  double get _p95FrameTime {
    if (_frameTimes.isEmpty) return 0;
    final sorted = List<double>.from(_frameTimes)..sort();
    return sorted[(sorted.length * 0.95).toInt()];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Кадров: $_frameCount'),
        Text('Среднее: ${_avgFrameTime.toStringAsFixed(1)}ms'),
        Text('P95: ${_p95FrameTime.toStringAsFixed(1)}ms'),
        // 16.67ms = 60 FPS
      ],
    );
  }
}
```

## Выбор рендерера

### Когда использовать Skia

- Android < 3.16 (Impeller в бета)
- Необходимость максимальной совместимости
- Работа со сложной анимацией, где JIT-компиляция приемлема

### Когда использовать Impeller

- iOS (по умолчанию с Flutter 3.10)
- Android 12+ с включённым Impeller
- Приложения с интенсивной графикой
- Когда важна предсказуемая производительность

### Включение Impeller на Android

```yaml
# android/app/src/main/AndroidManifest.xml
<application
    android:label="my_app"
    android:icon="@mipmap/ic_launcher">
    <meta-data
        android:name="io.flutter.embedding.android.EnableImpeller"
        android:value="true" />
</application>
```

```bash
# Или через аргументы запуска
flutter run --dart-define=FLUTTER_ENGINE_IMPELLER_RENDERER=impeller
```

## Best Practices

1. **Используйте RepaintBoundary** — минимизируйте перерисовки:
   ```dart
   RepaintBoundary(
     child: AnimatedContainer(...), // изолированная перерисовка
   )
   ```

2. **Избегайте сложных градиентов в анимациях** — они требуют пересчёта шейдера каждый кадр:
   ```dart
   // Плохо — градиент в анимации
   AnimatedContainer(
     decoration: BoxDecoration(
       gradient: LinearGradient(colors: [color1, color2]),
     ),
   )

   // Хорошо — кэшированный градиент
   CustomPaint(
     painter: CachedGradientPainter(),
   )
   ```

3. **Кэшируйте CustomPaint** — используйте `shouldRepaint` правильно:
   ```dart
   @override
   bool shouldRepaint(covariant OldPainter oldDelegate) {
     return oldDelegate.data != data; // Только при изменении данных
   }
   ```

4. **Мониторьте FPS** — используйте DevTools для анализа:
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

5. **Проверяйте рендерер в DevTools** — вкладка «Renderer» показывает Skia или Impeller.

6. **Тестируйте на реальных устройствах** — эмуляторы не воспроизводят GPU-производительность.

7. **Используйте `allowHitTesting`** — оптимизируйте hit-testing для CustomPaint:
   ```dart
   CustomPaint(
     size: Size(100, 100),
     painter: MyPainter(),
     child: Container(), // Реальный child для hit-testing
   )
   ```
