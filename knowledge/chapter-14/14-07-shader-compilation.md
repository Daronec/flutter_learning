---
tags:
  - performance
  - optimization
chapter: 14
section: 7
title: 14-07. Shader Compilation и Precompilation
alias: 14 07 shader compilation
status: complete
---

# 14-07. Shader Compilation и Precompilation

## Введение

Shader compilation — это процесс компиляции графических шейдеров, которые отвечают за рендеринг на GPU. В Flutter это может вызывать задержки (jank), особенно на первых запусках или при появлении новых визуальных эффектов.

## Что такое Shaders

### Графический стек Flutter

```
┌─────────────────────────────────────────────┐
│              Flutter Framework               │
│  (Dart code, Widget tree, RenderObject tree)│
├─────────────────────────────────────────────┤
│             Skia / Impeller                  │
│  (Rendering engine, 2D graphics)            │
├─────────────────────────────────────────────┤
│              GPU Driver                      │
│  (OpenGL, Vulkan, Metal)                    │
├─────────────────────────────────────────────┤
│              Hardware GPU                    │
└─────────────────────────────────────────────┘
```

### Что такое Shader

Shader — это программа, выполняемая на GPU. Она определяет, как пиксели на экране должны быть окрашены:

```glsl
// Пример простого fragment shader
precision mediump float;
uniform vec4 u_color;

void main() {
    gl_FragColor = u_color;
}
```

### Когда происходит Shader Compilation

| Эффект | Тип шейдера |
|--------|------------|
| Blur (размытие) | Gaussian blur shader |
| ClipRRect | Clip shader |
| Gradient | Gradient shader |
| Shadow (тени) | Shadow shader |
| Opacity | Blend shader |
| CustomPainter | Custom shader |
| BackdropFilter | Backdrop shader |

## Shader Compilation Issues

### Проблема: задержка при первом рендеринге

Когда Flutter встречает новый визуальный эффект, он должен скомпилировать соответствующий шейдер. Этот процесс может занять от нескольких миллисекунд до сотен миллисекунд, что вызывает заметный jank:

```
┌──────────────────────────────────────────────────────┐
│  Frame 1: Widget с Blur появляется                    │
│  ┌─────────────────────────────────────────────────┐  │
│  │ Build: 2ms                                      │  │
│  │ Layout: 1ms                                     │  │
│  │ Paint: 3ms                                      │  │
│  │ Shader Compilation: 50ms ⚠️                     │  │
│  │ GPU: 8ms                                        │  │
│  │ Итого: 64ms (пропущенный кадр!)                 │  │
│  └─────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### Визуальная индикация

При shader compilation в DevTools можно увидеть:

```
Performance overlay показывает:
┌──────────────────┐
│  FPS: 28         │  ← Падение FPS
│  Jank: 1         │  ← Пропущенный кадр
│  Build: 2.1ms    │
│  Layout: 0.8ms   │
│  Paint: 3.4ms    │
│  Raster: 58.7ms  │  ← Высокое время raster (shader compilation)
└──────────────────┘
```

### Типичные причины

| Причина | Решение |
|---------|---------|
| Blur эффекты | Precompile shaders |
| ClipRRect с радиусом | Precompile shaders |
| Gradient | Precompile shaders |
| CustomPainter | Precompile shaders |
| BackdropFilter | Precompile shaders |

## Pre-warming Shaders

### Что такое Pre-warming

Pre-warming shaders — это процесс компиляции шейдеров заранее, до того как они понадобятся пользователю. Это позволяет избежать задержек при первом рендеринге.

### Включение Pre-warming

```dart
void main() {
  // Включение pre-warming шейдеров
  WidgetsFlutterBinding.ensureInitialized();

  // Запуск приложения
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shader Precompilation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
```

### Precompilation через build-конфигурацию

```bash
# Precompile shaders при сборке
flutter precache

# Для конкретного устройства
flutter precache --android

# Для iOS
flutter precache --ios

# Для всех устройств
flutter precache
```

### Ручная компиляция шейдеров

```dart
import 'package:flutter/material.dart';

class ShaderPrecompilationPage extends StatelessWidget {
  const ShaderPrecompilationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shader Precompilation')),
      body: FutureBuilder<void>(
        future: _precompileShaders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return const SingleChildScrollView(
            child: Column(
              children: [
                // Эти эффекты теперь будут рендериться плавно
                _BlurEffect(),
                _GradientEffect(),
                _ShadowEffect(),
                _ClipRRectEffect(),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _precompileShaders() async {
    // Принудительная компиляция шейдеров
    await Future.wait([
      // Blur
      _compileBlurShader(),
      // Gradient
      _compileGradientShader(),
      // Shadow
      _compileShadowShader(),
    ]);
  }

  Future<void> _compileBlurShader() async {
    // Создаём временный виджет с blur
    final renderBox = RenderPointerListener();
    // Flutter автоматически компилирует шейдеры при рендеринге
  }

  Future<void> _compileGradientShader() async {
    // Создаём временный виджет с gradient
  }

  Future<void> _compileShadowShader() async {
    // Создаём временный виджет с shadow
  }
}
```

### Precompilation через Asset

```yaml
# pubspec.yaml
flutter:
  shaders:
    - assets/shaders/blur.frag
    - assets/shaders/gradient.frag
```

```glsl
// assets/shaders/blur.frag
#version 460 core
#extension GL_EXT_nonuniform_qualifier : require

in vec2 v_uv;
out vec4 fragColor;

uniform sampler2D u_texture;
uniform float u_radius;

void main() {
    vec4 sum = vec4(0.0);
    float total = 0.0;

    for (float x = -4.0; x <= 4.0; x += 1.0) {
        for (float y = -4.0; y <= 4.0; y += 1.0) {
            float weight = exp(-(x*x + y*y) / (2.0 * u_radius * u_radius));
            sum += texture(u_texture, v_uv + vec2(x, y) * 0.002) * weight;
            total += weight;
        }
    }

    fragColor = sum / total;
}
```

## Impeller Renderer

### Что такое Impeller

Impeller — это новый графический рендерер от Flutter, который решает проблему shader compilation:

| Характеристика | Skia | Impeller |
|---------------|------|----------|
| Shader Compilation | Runtime | Precompiled |
| Jank при новых эффектах | Да | Нет |
| Поддержка Android | Да | Да |
| Поддержка iOS | Да | Да |
| Поддержка Web | Нет | Нет |
| Поддержка macOS | Нет | Да |

### Включение Impeller

```dart
void main() {
  // Включение Impeller для iOS/macOS
  // Для Android Impeller доступен в beta
  FlutterBinding.ensureInitialized();

  // Проверка поддерживаемого рендерера
  debugRenderer = RendererType.impeller;

  runApp(const MyApp());
}
```

### Impeller в Android

```bash
# Включение Impeller для Android (beta)
flutter run --dart-define=FLUTTER_ENGINE=impeller
```

## Best Practices

### Рекомендации по работе с шейдерами

1. **Используйте `flutter precache` при сборке** — это компилирует шейдеры заранее
2. **Избегайте избыточных blur и clip эффектов** — каждый создаёт новый шейдер
3. **Используйте Impeller** — он решает проблему shader compilation
4. **Тестируйте на реальных устройствах** — эмуляторы могут не показывать проблемы
5. **Используйте Performance Overlay** — отслеживайте время raster

### Сравнение подходов

| Подход | Эффективность | Сложность |
|--------|--------------|-----------|
| `flutter precache` | Средняя | Низкая |
| Impeller | Высокая | Низкая |
| Ручная компиляция | Средняя | Высокая |
| Asset shaders | Высокая | Средняя |

### Чек-лист оптимизации шейдеров

- [ ] Используется `flutter precache` при сборке
- [ ] Impeller включён (если поддерживается)
- [ ] Избыточные blur/clip эффекты удалены
- [ ] Тестирование на реальных устройствах
- [ ] Performance Overlay показывает стабильный FPS
- [ ] Нет красных кадров на Timeline

## Заключение

Shader compilation — это одна из основных причин jank в Flutter-приложениях. Использование `flutter precache`, Impeller и правильное управление визуальными эффектами позволяет обеспечить плавный пользовательский опыт.
