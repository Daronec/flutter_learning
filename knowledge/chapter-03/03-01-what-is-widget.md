# 3.1 Что такое Widget? Философия «всё — виджет»

## Что такое Widget?

Widget — это неизменяемый описательный объект, который определяет часть UI и её поведение. В Flutter **всё является виджетом**: от текстовых надписей и кнопок до отступов, выравнивания и даже самого приложения.

## Философия «всё — виджет»

### Концепция

```
Текстовая надпись  → Text widget
Кнопка            → ElevatedButton widget
Отступ            → Padding widget
Выравнивание       → Center widget
Скролл            → SingleChildScrollView widget
Тема              → MaterialApp widget
Приложение         → MyApp widget
```

Каждый элемент интерфейса — это виджет, который описывает *как должен выглядеть UI* при данном состоянии.

### Неизменяемость (Immutability)

```dart
// Widget — неизменяемый объект
class MyWidget extends StatelessWidget {
  final String text;  // final — нельзя изменить
  
  const MyWidget({required this.text, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

// При изменении состояния создаётся НОВЫЙ виджет
// Старый виджет не изменяется
```

### Декларативный подход

```dart
// Декларативный стиль (Flutter, React, SwiftUI)
// Описываем ЧТО показать
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Hello'),
      IconButton(icon: Icon(Icons.refresh), onPressed: () {}),
    ],
  );
}

// Императивный стиль (старый Android, UIKit)
// Описываем КАК показать
// textView.setText('Hello');
// button.setOnClickListener(...);
```

## Типы виджетов

### StatelessWidget — виджет без состояния

```dart
class GreetingWidget extends StatelessWidget {
  final String name;
  
  const GreetingWidget({required this.name, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Text('Hello, $name!');
  }
}
```

### StatefulWidget — виджет с изменяемым состоянием

```dart
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});
  
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;
  
  @override
  Widget build(BuildContext context) {
    return Text('Count: $_count');
  }
}
```

### ComponentWidget — виджет без собственного UI

```dart
// ComponentWidget — виджет, который содержит другие виджеты
// но сам не рисует ничего
class MyComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Header'),
        Divider(),
        Text('Content'),
      ],
    );
  }
}
```

## Иерархия виджетов

```
Object
└── Diagnosticable
    └── DiagnosticableTree
        └── Widget
            ├── StatelessWidget
            ├── StatefulWidget
            ├── ProxyWidget
            │   ├── Theme
            │   ├── MediaQuery
            │   └── InheritedWidget
            └── RenderObjectWidget
                ├── Container
                ├── Text
                ├── Row
                └── Column
```

## Виджеты как конфигурации

```dart
// Widget — это КОНФИГУРАЦИЯ для RenderObject
// Сам виджет ничего не рисует!

Text('Hello') 
  // ↓ создаёт/конфигурирует
TextElement 
  // ↓ управляет
TextRenderObject 
  // ↓ рисует
Canvas (Skia/Impeller)
```

### Почему это важно?

1. **Лёгкость создания** — виджеты дешевы в создании
2. **Перестройка дерева** — при изменении состояния создаётся новое дерево
3. **Diffing** — Framework сравнивает старое и новое дерево
4. **Инкрементальное обновление** — обновляются только изменившиеся части

## Composition — паттерн компоновки

```dart
// Композиция вместо наследования
// Вместо: class MyButton extends Button {...}
// Используем: Container + ElevatedButton + Padding

Widget build(BuildContext context) {
  return Padding(                    // Обёртка с отступом
    padding: EdgeInsets.all(16),
    child: ElevatedButton(           // Основная кнопка
      onPressed: () {},
      child: Text('Click me'),
    ),
  );
}
```

## Заключение

Философия «всё — виджет» означает, что каждый элемент UI описывается как виджет. Это делает Flutter:
- **Предсказуемым** — неизменяемые виджеты
- **Композируемым** — виджеты вкладываются друг в друга
- **Эффективным** — лёгкие виджеты, инкрементальные обновления
- **Декларативным** — описываем что, а не как
