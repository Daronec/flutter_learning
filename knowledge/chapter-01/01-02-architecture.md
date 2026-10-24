---
tags:
  - flutter
  - intro
  - basics
chapter: 1
section: 2
title: Архитектура Flutter: Engine, Framework, Embedder
alias: 01 02 architecture
status: complete
---

# 1.2 Архитектура Flutter: Engine, Framework, Embedder

## Обзор архитектуры

Flutter состоит из трёх основных слоёв, каждый из которых отвечает за свою задачу:

```
┌─────────────────────────────────────────────────┐
│              Flutter Framework                  │
│  (Dart-код, виджеты, анимации, рисование)       │
├─────────────────────────────────────────────────┤
│              Flutter Engine                     │
│  (Core — C++, Dart Runtime, Skia/Impeller)      │
├─────────────────────────────────────────────────┤
│              Embedder                           │
│  (Платформо-зависимый код, интеграция с ОС)     │
└─────────────────────────────────────────────────┘
```

## 1. Flutter Framework

Framework — это слой на языке Dart, который разработчики используют ежедневно.

**Основные библиотеки:**
- **widgets** — базовые виджеты (Container, Text, Row, Column и т.д.)
- **animation** — система анимаций
- **painting** — примитивы рисования (Canvas, Paint, Path)
- **gestures** — обработка жестов
- **rendering** — слой рендеринга (layout, paint, composite)
- **services** — сервисы платформы (навигация, клавиатура, статус-бар)
- **foundation** — базовые утилиты и примитивы

**Компоненты Framework:**
- **Widget** — конфигурационный объект, описывающий UI
- **Element** — экземпляр в дереве элементов, управляет жизненным циклом виджета
- **RenderObject** — объект, отвечающий за layout и рисование

## 2. Flutter Engine

Engine — это ядро Flutter, написанное на C/C++. Он обеспечивает:

- **Dart Runtime** — выполнение Dart-кода (JIT для разработки, AOT для релиза)
- **Core библиотеки** — dart:core, dart:async, dart:collection
- **Graphics Library** — Skia (рендеринг 2D) или Impeller (новый рендерер)
- **Text Engine** — рендеринг текста, шрифты, Unicode
- **Animation & Gesture System** — обработка жестов и анимаций на низком уровне
- **Plugin Layer** — взаимодействие с нативным кодом через Platform Channels
- **Embedder API** — точка входа для интеграции с платформой

## 3. Embedder

Embedder — это платформо-зависимый слой, который «встраивает» Flutter в приложение:

**Платформы:**
- **Android** — `FlutterActivity`, `FlutterView` (Java/Kotlin)
- **iOS** — `FlutterViewController` (Objective-C/Swift)
- **macOS** — `FlutterViewController` (Swift/Objective-C)
- **Windows** — `FlutterWindow` (C++)
- **Linux** — `FlutterDesktopRunner` (C++)
- **Web** — JavaScript interop (через `flutter.js`)

**Обязанности Embedder:**
- Создание и управление окном/вью
- Подключение к графическому API (OpenGL, Vulkan, Metal, Skia)
- Обработка событий платформы (клавиатура, поворот экрана)
- Управление потоками (UI thread, GPU thread, IO thread)
- Регистрация плагинов

## Слои рендеринга

Внутри Framework работает **render tree**:

1. **Widget Tree** — конфигурационные объекты (лёгкие, создаются часто)
2. **Element Tree** — кэшированные экземпляры, управляют жизненным циклом
3. **RenderObject Tree** — объекты layout и рисования (тяжёлые, кэшируются)

```
Widget (конфигурация)
  ↓ создаёт/обновляет
Element (управление)
  ↓ управляет
RenderObject (layout + paint)
  ↓ отправляет команды
Engine (Skia/Impeller)
  ↓ рисует
Экран
```

## Жизненный цикл

1. Embedder создаёт окно и запускает Dart VM
2. Engine инициализирует Dart Runtime и загружает framework
3. Вызывается `main()` — создаётся Widget Tree
4. Framework создаёт Element Tree и RenderObject Tree
5. RenderObjects проходят layout → paint → composite
6. Engine рисует кадры через графический API (60/120 FPS)
7. При изменении состояния — перестройка виджетов → обновление render tree

## Заключение

Понимание архитектуры Flutter помогает:
- Оптимизировать производительность
- Правильно использовать виджеты
- Отлаживать проблемы рендеринга
- Создавать кастомные плагины и рендереры
