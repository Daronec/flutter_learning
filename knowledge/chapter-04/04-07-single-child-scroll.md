---
tags:
  - widgets
  - ui
  - basics
chapter: 4
section: 7
title: SingleChildScrollView — скроллинг контента
alias: 04 07 single child scroll
status: complete
---

# SingleChildScrollView — скроллинг контента

## Введение

`SingleChildScrollView` — это виджет, который позволяет прокручивать содержимое, которое не помещается на экране. В отличие от `ListView`, он создаёт все дочерние виджеты сразу, поэтому подходит для небольших объёмов контента.

## Когда использовать SingleChildScrollView

| Виджет | Когда использовать |
|--------|-------------------|
| `SingleChildScrollView` | Небольшой контент, который всегда известен |
| `ListView` | Большой или динамический контент |
| `CustomScrollView` | Сложная прокрутка с несколькими областями |

### Пример: форма с прокруткой

```dart
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      const Text(
        'Регистрация',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 24),
      TextField(
        decoration: const InputDecoration(
          labelText: 'Имя',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {},
        child: const Text('Зарегистрироваться'),
      ),
    ],
  ),
)
```

## Направление прокрутки

### Вертикальная прокрутка (по умолчанию)

```dart
SingleChildScrollView(
  scrollDirection: Axis.vertical,
  child: Column(
    children: List.generate(
      50,
      (index) => ListTile(title: Text('Элемент $index')),
    ),
  ),
)
```

### Горизонтальная прокрутка

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    children: List.generate(
      10,
      (index) => Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.primaries[index % Colors.primaries.length],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text('$index')),
      ),
    ),
  ),
)
```

## ScrollController

`ScrollController` позволяет управлять прокруткой программно.

### Базовое использование

```dart
class ScrollExample extends StatefulWidget {
  @override
  _ScrollExampleState createState() => _ScrollExampleState();
}

class _ScrollExampleState extends State<ScrollExample> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // Слушатель позиции прокрутки
    _controller.addListener(() {
      print('Позиция: ${_controller.offset}');
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Обязательно освободите контроллер!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Прокрутка к началу
            _controller.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: const Text('Наверх'),
        ),
        ElevatedButton(
          onPressed: () {
            // Прокрутка к концу
            _controller.animateTo(
              _controller.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: const Text('Вниз'),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _controller,
            child: Column(
              children: List.generate(
                100,
                (index) => ListTile(title: Text('Элемент $index')),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### AutoScrollController для автопрокрутки

```dart
// Прокрутка к конкретному элементу
void scrollToIndex(int index) {
  // Нужно найти ключ элемента и прокрутить к нему
  _controller.jumpTo(_controller.position.minScrollExtent);
}

// Прокрутка при фокусе TextField
FocusNode _focusNode = FocusNode();

@override
void initState() {
  super.initState();
  _focusNode.addListener(() {
    if (_focusNode.hasFocus) {
      // Автопрокрутка к полю ввода
      Future.delayed(const Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          _focusNode.context!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  });
}
```

## ScrollPhysics — физика прокрутки

Физика определяет поведение прокрутки при достижении границ.

### Виды ScrollPhysics

| Класс | Описание |
|-------|----------|
| `ClampingScrollPhysics` | Ограничение без отскока (Android по умолчанию) |
| `BouncingScrollPhysics` | Отскок за пределами границ (iOS по умолчанию) |
| `NeverScrollableScrollPhysics` | Отключение прокрутки |
| `PageScrollPhysics` | Постраничная прокрутка |

### ClampingScrollPhysics

```dart
// Ограничение без отскока (Android-стиль)
SingleChildScrollView(
  physics: const ClampingScrollPhysics(),
  child: Column(
    children: List.generate(50, (i) => ListTile(title: Text('$i'))),
  ),
)
```

### BouncingScrollPhysics

```dart
// Отскок за пределами границ (iOS-стиль)
SingleChildScrollView(
  physics: const BouncingScrollPhysics(),
  child: Column(
    children: List.generate(50, (i) => ListTile(title: Text('$i'))),
  ),
)

// С кастомной жёсткостью
SingleChildScrollView(
  physics: const BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
    stiffness: 0.8, // Жёсткость отскока (0-1)
  ),
  child: Column(
    children: List.generate(50, (i) => ListTile(title: Text('$i'))),
  ),
)
```

### NeverScrollableScrollPhysics

```dart
// Отключение прокрутки (когда контент помещается)
SingleChildScrollView(
  physics: const NeverScrollableScrollPhysics(),
  child: Column(
    children: [
      const Text('Небольшой контент'),
      // Остальной контент вне SingleChildScrollView
    ],
  ),
)
```

### PageScrollPhysics

```dart
// Постраничная прокрутка
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  physics: const PageScrollPhysics(),
  child: Row(
    children: [
      Container(width: 300, color: Colors.red),
      Container(width: 300, color: Colors.green),
      Container(width: 300, color: Colors.blue),
    ],
  ),
)
```

## Комбинирование с другими виджетами

### SingleChildScrollView + Column + Expanded

```dart
Scaffold(
  appBar: AppBar(title: const Text('Форма')),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const Text('Заголовок', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 16),
        // TextField без ограничений
        TextField(
          decoration: const InputDecoration(
            labelText: 'Имя',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        // Кнопка внизу
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Отправить'),
          ),
        ),
      ],
    ),
  ),
)
```

### SingleChildScrollView + ListView

```dart
SingleChildScrollView(
  child: Column(
    children: [
      // Статический контент
      const Text('Описание'),
      const SizedBox(height: 16),
      // Прокручиваемый список
      SizedBox(
        height: 300,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(items[index]));
          },
        ),
      ),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: () {}, child: const Text('OK')),
    ],
  ),
)
```

## Best Practices

1. **Используйте `SingleChildScrollView`** только для небольшого контента — он создаёт все виджеты сразу.

2. **Всегда используйте `padding`** в `SingleChildScrollView` для отступов по краям.

3. **Используйте `BouncingScrollPhysics`** для iOS-стиля и `ClampingScrollPhysics` для Android.

4. **Используйте `ScrollController`** для программной прокрутки, но не забывайте вызывать `dispose()`.

5. **Избегайте вложенных прокручиваемых виджетов** — это вызывает конфликты прокрутки.

6. **Используйте `NeverScrollableScrollPhysics`** для отключения прокрутки, когда родительский виджет уже прокручивается.

7. **Используйте `Scrollable.ensureVisible()`** для прокрутки к конкретному виджету:
   ```dart
   Scrollable.ensureVisible(
     targetWidgetKey.currentContext!,
     duration: const Duration(milliseconds: 300),
     curve: Curves.easeInOut,
   )
   ```
