---
tags:
  - widgets
  - architecture
chapter: 3
section: 9
title: RenderObject — связь между widget и пикселями
alias: 03 09 renderobject
status: complete
---

# 3.9 RenderObject — связь между widget и пикселями

## Что такое RenderObject?

RenderObject — это объект, который отвечает за **layout** (разметку) и **painting** (рисование) в Flutter. Это связующее звено между Widget (конфигурацией) и экраном (пикселями).

## Три дерева

```
Widget Tree          →  Конфигурация (лёгкие, immutable)
Element Tree         →  Управление (кэшированные, lifecycle)
RenderObject Tree    →  Layout + Painting (тяжёлые, кэшированные)
```

## Класс иерархия RenderObject

```
RenderObject
├── RenderBox (основной класс)
│   ├── RenderConstrainedBox
│   ├── RenderPadding
│   ├── RenderDecoratedBox
│   ├── RenderFlex (Row, Column)
│   ├── RenderStack
│   ├── RenderPositionedBox
│   ├── RenderText
│   ├── RenderParagraph
│   ├── RenderImage
│   └── ...
├── RenderView
└── RenderProxyBox
```

## RenderBox — основной класс

### Методы RenderBox

```dart
abstract class RenderBox extends RenderObject with RenderObjectWithChildMixin<RenderBox> {
  // Layout
  void layout(BoxConstraints constraints, {bool parentUsesSize = false});
  
  // Размеры
  Size get size;
  Offset get offset;
  double get width => size.width;
  double get height => size.height;
  
  // Координаты
  Offset localToGlobal(Offset point);
  Offset globalToLocal(Offset point);
  
  // Рисование
  void paint(PaintingContext context, Offset offset);
  
  // Жесты
  bool hitTest(BoxHitTestResult result, {required Offset position});
}
```

## Жизненный цикл RenderObject

```
Создание
    ↓
createRenderObject(context)
    ↓
attach(pipelineOwner)
    ↓
layout(constraints)
    ↓
paint(context, offset)
    ↓
composite (GPU)
    ↓
[Изменение]
    ↓
markNeedsLayout()
    ↓
layout() → paint() → composite
    ↓
[Удаление]
    ↓
detach()
    ↓
dispose()
```

## Layout процесс

### Constraints → Size → ParentData

```
1. Parent отправляет Constraints к Child
   "Ты можешь быть от min до max"
   
2. Child выбирает Size в пределах Constraints
   "Я буду такого размера"
   
3. Child отправляет ParentData к Parent
   "Я такого размера и здесь"
   
4. Parent позиционирует Child
   "Ты здесь"
```

### Top-down, Bottom-up

```
Top-down (Constraints):
Parent → Constraints → Child → Constraints → Grandchild

Bottom-up (Size):
Grandchild → Size → Child → Size → Parent → Size → Grandparent
```

## Пример: создание RenderObject

### Custom RenderObject

```dart
class CustomRenderObject extends RenderBox {
  final String text;
  final Color color;
  
  CustomRenderObject({required this.text, required this.color});
  
  @override
  void performLayout() {
    // Вычисляем размер
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 24)),
      maxLines: 1,
    );
    textPainter.layout(maxWidth: constraints.maxWidth);
    
    size = textPainter.size;
  }
  
  @override
  void paint(PaintingContext context, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 24)),
      maxLines: 1,
    );
    textPainter.layout(maxWidth: constraints.maxWidth);
    textPainter.paint(context.canvas, offset);
  }
  
  @override
  bool hitTestSelf(Offset position) => true;
}
```

### RenderObjectWidget

```dart
class CustomWidget extends RenderObjectWidget {
  final String text;
  final Color color;
  
  const CustomWidget({required this.text, required this.color, super.key});
  
  @override
  RenderObject createRenderObject(BuildContext context) {
    return CustomRenderObject(text: text, color: color);
  }
}
```

## Связь Widget → RenderObject

```dart
// Widget (конфигурация)
Text('Hello')
  ↓ createElement()
TextElement (Element)
  ↓ createRenderObject()
RenderParagraph (RenderObject)
  ↓ layout()
RenderParagraph layout(constraints)
  ↓ paint()
RenderParagraph paint(context, offset)
  ↓
Canvas (Skia/Impeller)
  ↓
Экран (60/120 FPS)
```

## markNeedsLayout / markNeedsPaint

```dart
// При изменении состояния:
setState(() {
  _count++;
});

// Что происходит:
// 1. Element помечается dirty
// 2. RenderObject помечается markNeedsLayout
// 3. В следующем кадре:
//    a. layout() — пересчёт размеров
//    b. paint() — перерисовка
//    c. composite() — отправка на GPU
```

## Отладка RenderObject

### Flutter Inspector

```
В DevTools можно увидеть:
- Дерево RenderObject
- Размеры каждого RenderObject
- Constraints каждого элемента
- Время layout и paint
```

### debugDumpRenderTree()

```dart
// Вывод дерева RenderObject в консоль
print(debugDumpRenderTree());
```

## Best Practices

### 1. Используйте готовые виджеты

```dart
// ✅ Используйте готовые виджеты
Container(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
)

// ❌ Не создавайте RenderObject для простых задач
```

### 2. Кэшируйте TextPainter

```dart
// ❌ Создаём TextPainter каждый кадр
@override
void paint(PaintingContext context, Offset offset) {
  final textPainter = TextPainter(...); // Дорого!
  textPainter.paint(context.canvas, offset);
}

// ✅ Кэшируем TextPainter
TextPainter? _cachedTextPainter;

@override
void performLayout() {
  _cachedTextPainter = TextPainter(...);
  _cachedTextPainter!.layout();
}

@override
void paint(PaintingContext context, Offset offset) {
  _cachedTextPainter!.paint(context.canvas, offset);
}
```

### 3. Избегайте глубоких деревьев

```dart
// ❌ Глубокое вложение
Container(
  padding: EdgeInsets.all(8),
  child: Container(
    padding: EdgeInsets.all(8),
    child: Container(
      padding: EdgeInsets.all(8),
      child: Text('Hello'),
    ),
  ),
)

// ✅ Flat структура
Padding(
  padding: EdgeInsets.all(24),
  child: Text('Hello'),
)
```

## Заключение

RenderObject — это мост между Widget и пикселями:
- **Widget** описывает *что* показать
- **Element** управляет жизненным циклом
- **RenderObject** вычисляет *где* и *как* рисовать
- **Engine** рисует пиксели через GPU

Для большинства задач достаточно использовать готовые виджеты. Custom RenderObject нужен только для специализированных задач (кастомное рисование, сложные анимации, производительность).
