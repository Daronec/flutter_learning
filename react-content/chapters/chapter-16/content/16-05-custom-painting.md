# Custom Painting — рисование на Canvas

Custom Painting — это механизм Flutter для рисования произвольной графики на Canvas. Через классы `CustomPaint`, `CustomPainter` и `Paint` можно создавать уникальные визуальные элементы, диаграммы, анимации и сложные UI-компоненты.

## Основы Custom Paint

### Архитектура рисования

```
┌─────────────────────────────────────────┐
│            CustomPaint                  │
│  (Widget — контейнер для рисования)     │
├─────────────────────────────────────────┤
│         CustomPainter                   │
│  (Логика рисования)                     │
│  paint() → Canvas + Paint              │
│  shouldRepaint() → bool                │
├─────────────────────────────────────────┤
│           Canvas                        │
│  (API рисования: drawLine, drawCircle)  │
├─────────────────────────────────────────┤
│            Paint                        │
│  (Стиль: color, stroke, shadow)         │
└─────────────────────────────────────────┘
```

### Базовый пример

```dart
import 'package:flutter/material.dart';

class BasicPaint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: BasicPainter(),
        size: Size(300, 300),
      ),
    );
  }
}

class BasicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Создаём Paint для заливки
    final fillPaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.fill;

    // 2. Создаём Paint для обводки
    final strokePaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 3. Рисуем круг
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      80,
      fillPaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      80,
      strokePaint,
    );

    // 4. Рисуем линию
    canvas.drawLine(
      Offset(50, size.height / 2),
      Offset(size.width - 50, size.height / 2),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant BasicPainter oldDelegate) => false;
}
```

## Класс Paint

### Свойства Paint

| Свойство | Тип | Описание |
|----------|-----|----------|
| `color` | `Color` | Цвет рисования |
| `style` | `PaintingStyle` | Fill или Stroke |
| `strokeWidth` | `double` | Толщина линии |
| `strokeCap` | `StrokeCap` | Форма конца линии |
| `strokeJoin` | `StrokeJoin` | Форма соединения линий |
| `shader` | `Shader?` | Шейдер (градиент/паттерн) |
| `maskFilter` | `MaskFilter?` | Размытие (blur) |
| `filterQuality` | `FilterQuality` | Качество фильтрации |
| `blendMode` | `BlendMode` | Режим наложения |
| `antiAlias` | `bool` | Сглаживание |

### Примеры использования Paint

```dart
class PaintExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(400, 600),
      painter: PaintExamplesPainter(),
    );
  }
}

class PaintExamplesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double y = 50;
    final centerX = size.width / 2;

    // 1. Градиент
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.red, Colors.orange, Colors.yellow],
      ).createShader(Rect.fromLTWH(0, y - 30, 300, 40));
    canvas.drawRect(Rect.fromLTWH(50, y, 300, 40), gradientPaint);
    y += 60;

    // 2. Blur (тень)
    final blurPaint = Paint()
      ..color = Colors.blue
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(centerX, y + 20), 25, blurPaint);
    y += 70;

    // 3. Blend Mode (Screen)
    final basePaint = Paint()..color = Colors.blue;
    canvas.drawRect(Rect.fromLTWH(50, y, 100, 80), basePaint);
    final blendPaint = Paint()
      ..color = Colors.yellow
      ..blendMode = BlendMode.screen;
    canvas.drawCircle(Offset(120, y + 40), 50, blendPaint);
    y += 110;

    // 4. Stroke Cap (Round)
    final roundPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(50, y), Offset(350, y), roundPaint);
    y += 40;

    // 5. Stroke Cap (Square)
    final squarePaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset(50, y), Offset(350, y), squarePaint);
    y += 40;

    // 6. Stroke Cap (Butt)
    final buttPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(Offset(50, y), Offset(350, y), buttPaint);
  }

  @override
  bool shouldRepaint(covariant PaintExamplesPainter oldDelegate) => false;
}
```

## Класс Path

### Создание путей

```dart
class PathExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(400, 500),
      painter: PathExamplesPainter(),
    );
  }
}

class PathExamplesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    double startX = 50;

    // 1. Прямоугольник
    canvas.drawRect(
      Rect.fromLTWH(startX, 30, 100, 80),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(startX, 30, 100, 80),
      strokePaint,
    );

    // 2. Овал
    canvas.drawOval(
      Rect.fromLTWH(startX, 150, 120, 60),
      paint,
    );

    // 3. Дуга (Arc)
    canvas.drawArc(
      Rect.fromLTWH(startX, 260, 100, 100),
      0,
      Math.PI / 2,
      false,
      paint,
    );

    // 4. Сложный Path
    final path = Path();
    path.moveTo(startX, 420);
    path.lineTo(startX + 150, 420);
    path.quadraticBezierTo(
      startX + 75, 350,
      startX + 150, 420,
    );
    path.quadraticBezierTo(
      startX + 225, 490,
      startX + 300, 420,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PathExamplesPainter oldDelegate) => false;
}

// Примечание: Math.PI — это dart:math
import 'dart:math' as Math;
```

### Методы Path

| Метод | Описание |
|-------|----------|
| `moveTo(x, y)` | Переместить курсор |
| `lineTo(x, y)` | Линия от курсора |
| `arcTo(rect, startAngle, sweepAngle, forceMoveTo)` | Дуга |
| `quadraticBezierTo(x1, y1, x2, y2)` | Квадратичная кривая Безье |
| `cubicTo(x1, y1, x2, y2, x3, y3)` | Кубическая кривая Безье |
| `close()` | Закрыть путь |
| `addRect(rect)` | Добавить прямоугольник |
| `addOval(rect)` | Добавить овал |
| `addCircle(offset, radius)` | Добавить круг |
| `addPath(path, offset)` | Добавить другой путь |
| `transform(matrix4)` | Трансформация пути |

### Кривые Безье

```dart
class BezierPainter extends CustomPainter {
  final double progress; // 0.0 — 1.0

  BezierPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final controlPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 1;

    final startX = 50.0;
    final startY = size.height / 2;
    final endX = size.width - 50.0;
    final endY = size.height / 2;

    final cp1x = startX + (endX - startX) * 0.25;
    final cp1y = startY - 150;
    final cp2x = startX + (endX - startX) * 0.75;
    final cp2y = endY + 150;

    // Рисуем контрольные точки
    canvas.drawLine(
      Offset(startX, startY),
      Offset(cp1x, cp1y),
      controlPaint,
    );
    canvas.drawLine(
      Offset(endX, endY),
      Offset(cp2x, cp2y),
      controlPaint,
    );

    // Рисуем кривую
    final path = Path();
    path.moveTo(startX, startY);
    path.cubicTo(cp1x, cp1y, cp2x, cp2y, endX, endY);
    canvas.drawPath(path, paint);

    // Точка анимации по кривой
    final t = progress;
    final x = (1 - t) * (1 - t) * (1 - t) * startX +
              3 * (1 - t) * (1 - t) * t * cp1x +
              3 * (1 - t) * t * t * cp2x +
              t * t * t * endX;
    final y = (1 - t) * (1 - t) * (1 - t) * startY +
              3 * (1 - t) * (1 - t) * t * cp1y +
              3 * (1 - t) * t * t * cp2y +
              t * t * t * endY;

    canvas.drawCircle(Offset(x, y), 8, Paint()..color = Colors.amber);
  }

  @override
  bool shouldRepaint(covariant BezierPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
```

## Canvas API

### Основные методы Canvas

| Метод | Описание |
|-------|----------|
| `drawColor(Color, BlendMode)` | Закрасить фон |
| `drawRect(Rect, Paint)` | Прямоугольник |
| `drawCircle(Offset, double, Paint)` | Круг |
| `drawOval(Rect, Paint)` | Овал |
| `drawLine(Offset, Offset, Paint)` | Линия |
| `drawPath(Path, Paint)` | Произвольный путь |
| `drawArc(Rect, double, double, bool, Paint)` | Дуга |
| `drawText(String, Offset, TextStyle)` | Текст |
| `save()` | Сохранить состояние |
| `restore()` | Восстановить состояние |
| `translate(double, double)` | Сдвиг |
| `rotate(double)` | Поворот |
| `scale(double, double)` | Масштабирование |
| `clipRect(Rect)` | Обрезка |
| `clipPath(Path)` | Обрезка по пути |

### Трансформации Canvas

```dart
class TransformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Сохраняем состояние
    canvas.save();

    // 2. Сдвигаем в центр
    canvas.translate(size.width / 2, size.height / 2);

    // 3. Поворачиваем
    canvas.rotate(Math.PI / 6); // 30 градусов

    // 4. Рисуем
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(-50, -50, 100, 100), paint);

    // 5. Восстанавливаем состояние
    canvas.restore();

    // 6. Масштабирование
    canvas.save();
    canvas.translate(size.width * 0.75, size.height * 0.25);
    canvas.scale(0.5, 0.5);
    canvas.drawRect(Rect.fromLTWH(-50, -50, 100, 100), paint);
    canvas.restore();

    // 7. Комбинированные трансформации
    canvas.save();
    canvas.translate(size.width * 0.75, size.height * 0.75);
    canvas.scale(0.5);
    canvas.rotate(Math.PI / 4);
    canvas.drawRect(Rect.fromLTWH(-50, -50, 100, 100), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TransformPainter oldDelegate) => false;
}
```

### Clip и SaveLayer

```dart
class ClipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. ClipRect — обрезка по прямоугольнику
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width / 2, size.height));
    canvas.drawColor(Colors.blue, BlendMode.src);
    canvas.restore();

    // 2. ClipPath — обрезка по пути
    canvas.save();
    final circlePath = Path();
    circlePath.addCircle(size.width * 0.75, size.height / 2, 80);
    canvas.clipPath(circlePath);
    canvas.drawColor(Colors.red, BlendMode.src);
    canvas.restore();

    // 3. SaveLayer — изолированный слой с эффектами
    canvas.saveLayer(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      Paint()..colorFilter = ColorFilter.mode(
        Colors.green.withOpacity(0.5),
        BlendMode.multiply,
      ),
    );
    canvas.drawColor(Colors.yellow, BlendMode.src);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ClipPainter oldDelegate) => false;
}
```

## Практические примеры

### Градиентная кнопка

```dart
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        size: const Size(200, 50),
        painter: _GradientButtonPainter(label),
      ),
    );
  }
}

class _GradientButtonPainter extends CustomPainter {
  final String label;

  _GradientButtonPainter(this.label);

  @override
  void paint(Canvas canvas, Size size) {
    // Градиент
    final gradient = LinearGradient(
      colors: [Colors.blue.shade400, Colors.purple.shade400],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    // Скруглённый прямоугольник
    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(25),
      ),
    );

    // Заливка градиентом
    final paint = Paint()..shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    canvas.drawPath(path, paint);

    // Текст
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
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
  bool shouldRepaint(covariant _GradientButtonPainter oldDelegate) =>
      oldDelegate.label != label;
}
```

### Круговой прогресс-бар

```dart
class CircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 — 1.0
  final Color? backgroundColor;
  final Color? progressColor;
  final double strokeWidth;

  const CircularProgressPainter({
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.strokeWidth = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Фоновый круг
    final bgPaint = Paint()
      ..color = backgroundColor ?? Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Прогресс
    final progressPaint = Paint()
      ..color = progressColor ?? Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -Math.PI / 2,
      2 * Math.PI * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
```

## Best Practices

1. **Возвращайте правильный `shouldRepaint`** — избегайте лишних перерисовок:
   ```dart
   @override
   bool shouldRepaint(covariant OldPainter oldDelegate) {
     return oldDelegate.data != data;
   }
   ```

2. **Используйте `RepaintBoundary`** — изолируйте перерисовку сложных элементов:
   ```dart
   RepaintBoundary(
     child: CustomPaint(painter: ComplexPainter()),
   )
   ```

3. **Кэшируйте Paint-объекты** — не создавайте их в `paint()` каждый кадр:
   ```dart
   class CachedPainter extends CustomPainter {
     final Paint _cachedPaint = Paint()..color = Colors.blue;

     @override
     void paint(Canvas canvas, Size size) {
       canvas.drawRect(Rect.largest, _cachedPaint);
     }
   }
   ```

4. **Используйте `saveLayer` для сложных эффектов** — но помните о производительности:
   ```dart
   canvas.saveLayer(bounds, Paint()..maskFilter = blur);
   // рисование
   canvas.restore();
   ```

5. **Избегайте создания объектов в `paint()`** — это создаёт нагрузку на GC:
   ```dart
   // Плохо
   @override
   void paint(Canvas canvas, Size size) {
     final paint = Paint()..color = Colors.blue; // каждый кадр!
   }

   // Хорошо
   final Paint _paint = Paint()..color = Colors.blue;
   @override
   void paint(Canvas canvas, Size size) {
     canvas.drawRect(rect, _paint);
   }
   ```

6. **Используйте `canvas.save()` / `restore()`** — для изоляции трансформаций.

7. **Профилируйте перерисовки** — используйте `debugRepaintRainbowEnabled = true`.
