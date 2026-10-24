---
tags:
  - platform-channels
  - native
  - plugins
chapter: 16
section: 6
title: Shader (Shaders) — GPU-ускоренная графика
alias: 16 06 shaders
status: complete
---

# Shader (Shaders) — GPU-ускоренная графика

Shaders — это программы, выполняемые на GPU для обработки пикселей и вершин. В Flutter шейдеры позволяют создавать сложные визуальные эффекты с высокой производительностью, используя мощь графического процессора.

## Основы Shaders

### Что такое Shader

| Компонент | Описание |
|-----------|----------|
| Vertex Shader | Обрабатывает вершины (позиции) |
| Fragment/Pixel Shader | Вычисляет цвет каждого пикселя |
| Shader | Общий термин для GPU-программы |

### Pipeline рендеринга

```
┌─────────────┐    ┌──────────────┐    ┌──────────────┐
│   Geometry   │───→│  Vertex      │───→│  Fragment    │
│   (Vertices) │    │  Shader      │    │  Shader      │
│              │    │  (позиции)   │    │  (цвета)     │
└─────────────┘    └──────────────┘    └──────────────┘
```

## ShaderBuilder

### Использование ShaderBuilder

```dart
import 'package:flutter/material.dart';

class ShaderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: const Text(
        'Shader Text',
        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
      ),
    );
  }
}
```

### ShaderMask vs ColorFiltered

| Widget | Назначение | Пример |
|--------|-----------|--------|
| `ShaderMask` | Применение шейдера | Градиент на текст |
| `ColorFiltered` | Цветовая фильтрация | Чёрно-белый эффект |
| `CustomPaint` с `Shader` | Полный контроль | Кастомные эффекты |

### Градиентные эффекты

```dart
class GradientEffects extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Радиальный градиент
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5,
              colors: [
                Colors.orange,
                Colors.red.shade900,
                Colors.black,
              ],
            ).createShader(bounds);
          },
          child: const Text(
            'Radial',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),

        // 2. Линейный градиент
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.teal,
                Colors.cyan,
                Colors.lightBlue,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: const Text(
            'Linear',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),

        // 3. Свёртка с изображением
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return SweepGradient(
              center: Alignment.center,
              colors: [
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.red,
              ],
            ).createShader(bounds);
          },
          child: const Text(
            'Sweep',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
```

## Custom Shaders (Flutter Shader)

### Поддержка шейдеров в Flutter

Flutter поддерживает шейдеры через пакет `flutter_shader` или встроенный `Shader` API. Начиная с Flutter 3.10, поддержка улучшена благодаря Impeller.

### Создание шейдера

```dart
import 'package:flutter/material.dart';

class CustomShaderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(300, 300),
      painter: ShaderPainter(),
    );
  }
}

class ShaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Создаём шейдер через ShaderClass
    final shader = LinearGradient(
      colors: [Colors.blue, Colors.purple, Colors.pink],
      stops: const [0.0, 0.5, 1.0],
      transform: const _RepeatingGradientShaderTransform(),
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPaint(Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) => false;
}

class _RepeatingGradientShaderTransform extends GradientTransform {
  @override
  Gradient transform(Rect fromScreenSpace, Matrix4? matrix) {
    return super.transform(fromScreenSpace, matrix) ??
        const LinearGradient(colors: []);
  }
}
```

### Shader с анимацией

```dart
class AnimatedShaderPainter extends CustomPainter {
  final Animation<double> animation;

  AnimatedShaderPainter({required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final time = animation.value;

    // Анимированный градиент
    final shader = LinearGradient(
      colors: [
        HSLColor.fromAHSL(1, (time * 360) % 360, 0.6, 0.5)
            .toColor(),
        HSLColor.fromAHSL(1, (time * 360 + 120) % 360, 0.6, 0.5)
            .toColor(),
        HSLColor.fromAHSL(1, (time * 360 + 240) % 360, 0.6, 0.5)
            .toColor(),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPaint(Paint()..shader = shader);

    // Рисуем волнистую линию поверх
    final path = Path();
    for (double x = 0; x <= size.width; x += 2) {
      final y = size.height / 2 +
          sin((x / size.width) * 4 * 3.14159 + time * 5) * 50;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant AnimatedShaderPainter oldDelegate) => false;
}
```

## Shader Language

### GLSL-подобный синтаксис

```glsl
// Пример шейдерного кода (для понимания концепции)

// Vertex Shader
attribute vec2 position;
attribute vec2 uv;
varying vec2 v_uv;

void main() {
    v_uv = uv;
    gl_Position = vec4(position, 0.0, 1.0);
}

// Fragment Shader
varying vec2 v_uv;
uniform float u_time;
uniform vec2 u_resolution;

void main() {
    vec2 uv = v_uv;

    // Создаём волновой эффект
    float wave = sin(uv.x * 10.0 + u_time) * 0.5 + 0.5;

    // Цветовая палитра
    vec3 color = vec3(
        sin(uv.x * 3.14 + u_time),
        sin(uv.y * 3.14 + u_time * 0.7),
        sin((uv.x + uv.y) * 3.14 + u_time * 0.5)
    ) * 0.5 + 0.5;

    // Применяем волну
    color *= wave;

    gl_FragColor = vec4(color, 1.0);
}
```

### Shader в Flutter через CustomShader

```dart
// Использование пакета flutter_shader для кастомных шейдеров
// pubspec.yaml:
// dependencies:
//   flutter_shader: ^0.4.0

import 'package:flutter/material.dart';
// import 'package:flutter_shader/flutter_shader.dart';

class FlutterShaderExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShaderWidget(
      shaderCode: '''
        shader main : ImpellerDSL {
          input vertex {
            @location(0) vec2 position;
            @location(1) vec2 uv;
          };
          output fragment {
            @location(0) vec4 color;
          };
          uniform float time;
          void main() {
            vec2 uv = position * 0.5 + 0.5;
            float wave = sin(uv.x * 10.0 + time) * 0.5 + 0.5;
            color = vec4(vec3(wave), 1.0);
          }
        }
      ''',
      uniforms: {'time': 0.0},
      child: Container(
        width: 300,
        height: 300,
        color: Colors.black,
      ),
    );
  }
}
```

## Эффекты с Shader

### Эффект размытия

```dart
class BlurEffect extends StatelessWidget {
  final Widget child;
  final double blurRadius;

  const BlurEffect({
    super.key,
    required this.child,
    required this.blurRadius,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: blurRadius,
        sigmaY: blurRadius,
      ),
      child: child,
    );
  }
}

// Использование
Stack(
  children: [
    Image.asset('background.jpg'),
    BlurEffect(
      blurRadius: 10,
      child: Container(
        color: Colors.white.withOpacity(0.1),
      ),
    ),
  ],
);
```

### Эффект неонового свечения

```dart
class NeonGlowPainter extends CustomPainter {
  final String text;
  final Color glowColor;
  final double blurRadius;

  const NeonGlowPainter({
    required this.text,
    this.glowColor = Colors.cyan,
    this.blurRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Свечение (несколько слоёв размытия)
    for (int i = 3; i >= 1; i--) {
      final glowPaint = Paint()
        ..color = glowColor.withOpacity(0.1 * i)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius * i)
        ..style = PaintingStyle.fill;

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: glowColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
    }

    // Основной текст
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant NeonGlowPainter oldDelegate) =>
      oldDelegate.text != text || oldDelegate.glowColor != glowColor;
}
```

### Эффект искажения (Displacement)

```dart
class DisplacementEffect extends StatefulWidget {
  final Widget child;

  const DisplacementEffect({super.key, required this.child});

  @override
  State<DisplacementEffect> createState() => _DisplacementEffectState();
}

class _DisplacementEffectState extends State<DisplacementEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
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
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.blue,
                Colors.purple,
                Colors.pink,
              ],
              stops: [
                0.0,
                _animation.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
```

## Best Practices

1. **Кэшируйте шейдеры** — избегайте создания новых шейдеров в `build()`:
   ```dart
   class _MyState extends State<MyWidget> {
     Shader? _cachedShader;

     @override
     Widget build(BuildContext context) {
       // Переиспользуем шейдер
       return ShaderMask(
         shaderCallback: (Rect bounds) => _cachedShader ??=
             LinearGradient(...).createShader(bounds),
         child: ...,
       );
     }
   }
   ```

2. **Используйте `shouldRebuild`** — для `ShaderBuilder` контролируйте пересоздание:
   ```dart
   class _ShaderBuilder extends SingleChildRenderObjectWidget {
     @override
     bool shouldRebuild(covariant SingleChildRenderObjectWidget old) {
       return false; // Кэшируем
     }
   }
   ```

3. **Минимизируйте количество шейдеров** — каждый шейдер требует GPU-контекста.

4. **Используйте `RepaintBoundary`** — изолируйте области с шейдерами:
   ```dart
   RepaintBoundary(
     child: ShaderMask(...),
   )
   ```

5. **Тестируйте на разных GPU** — производительность шейдеров зависит от GPU.

6. **Используйте Impeller** — обеспечивает предсказуемую производительность шейдеров.

7. **Избегайте сложных вычислений в шейдере** — держите логику простой.
