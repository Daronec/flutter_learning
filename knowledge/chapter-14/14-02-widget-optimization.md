---
tags:
  - performance
  - optimization
chapter: 14
section: 2
title: 14-02. Widget Build-оптимизация: const-конструкторы и ключи
alias: 14 02 widget optimization
status: complete
---

# 14-02. Widget Build-оптимизация: const-конструкторы и ключи

## Введение

Оптимизация сборки виджетов — одна из самых эффективных техник повышения производительности Flutter. Правильное использование `const`-конструкторов и ключей (`Keys`) позволяет значительно сократить количество ненужных rebuild'ов и ускорить рендеринг.

## Как работает Build-фаза

### Жизненный цикл виджета

Каждый виджет в Flutter проходит через несколько этапов:

```
Создание виджета → Build → Layout → Paint → Composite
```

При изменении состояния (`setState`) весь поддерево виджетов перестраивается. Оптимизация заключается в том, чтобы минимизировать эту перестройку.

### Что происходит при rebuild

1. Flutter вызывает `build()` метод виджета
2. Создаётся новое дерево виджетов
3. Flutter сравнивает новое дерево со старым
4. Изменённые элементы перестраиваются
5. Новые элементы добавляются
6. Удалённые элементы удаляются

## Const-конструкторы

### Что такое const-конструктор

`const`-конструктор указывает Flutter, что экземпляр виджета не будет изменяться. Это позволяет Flutter переиспользовать один и тот же экземпляр виджета вместо создания нового.

### Преимущества const-конструкторов

| Преимущество | Описание |
|--------------|----------|
| Кэширование | Один и тот же const-виджет переиспользуется |
| Скорость сравнения | Ссылочное сравнение быстрее глубокого сравнения |
| Меньше памяти | Один экземпляр вместо множества копий |
| Меньше rebuild'ов | Flutter пропускает rebuild если const-виджет не изменился |

### Пример: без const

```dart
class BadWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Каждый раз создаётся новый экземпляр Container
    return Container(
      color: Colors.blue,
      child: Text('Hello'),
    );
  }
}
```

### Пример: с const

```dart
class GoodWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Flutter переиспользует один и тот же экземпляр
    return const Column(
      children: [
        SizedBox(height: 16),
        Text('Hello'),
        Divider(),
      ],
    );
  }
}
```

### Правила использования const

1. **Все дочерние виджеты тоже должны быть const**

```dart
// Правильно
const Row(
  children: [
    Text('Hello'),
    Icon(Icons.star),
  ],
);

// Неправильно — Text не является const
const Row(
  children: [
    Text('Hello'),  // Text не const
    Icon(Icons.star),
  ],
);
```

2. **Все аргументы конструктора должны быть константами**

```dart
// Правильно
const Text(
  'Static text',
  style: TextStyle(fontSize: 16),
);

// Неправильно — fontSize вычисляется динамически
const Text(
  'Dynamic text',
  style: TextStyle(fontSize: calculateFontSize()),
);
```

3. **Используйте const в StatelessWidget**

```dart
class OptimizedWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const OptimizedWidget({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }
}
```

### Const в StatefulWidget

В `StatefulWidget` const можно использовать для статических частей:

```dart
class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Const-часть — не перестраивается при изменении _counter
        const Text(
          'Counter:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // Динамическая часть — перестраивается
        Text('$_counter'),
      ],
    );
  }
}
```

## Keys для оптимизации

### Что такое Keys

`Key` — это идентификатор виджета, который помогает Flutter определить, как сопоставить элементы при перестройке дерева виджетов.

### Типы Keys

| Тип Key | Описание |
|---------|----------|
| `ValueKey` | Основан на значении (строка, число) |
| `ObjectKey` | Основан на объекте (сравнение через `==`) |
| `UniqueKey` | Уникальный для каждого экземпляра |
| `GlobalKey` | Уникальный в пределах всего приложения |

### ValueKey

```dart
// Использование ValueKey с индексом
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(index),
      title: Text(items[index]),
    );
  },
);

// Использование ValueKey с идентификатором
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),
      title: Text(items[index].name),
    );
  },
);
```

### ObjectKey

```dart
class Item {
  final int id;
  final String name;

  Item({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ObjectKey сравнивает объекты через ==
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: ObjectKey(items[index]),
      title: Text(items[index].name),
    );
  },
);
```

### UniqueKey

```dart
// НЕ рекомендуется для списков — создаёт новый ключ каждый раз
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(
      key: UniqueKey(),  // Плохо! Каждый rebuild создаёт новый ключ
      title: Text(items[index].name),
    );
  },
);

// Правильное использование UniqueKey
// Когда нужно каждый раз создавать новый виджет
class DynamicWidget extends StatefulWidget {
  const DynamicWidget({super.key});

  @override
  State<DynamicWidget> createState() => _DynamicWidgetState();
}

class _DynamicWidgetState extends State<DynamicWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      key: UniqueKey(),  // Гарантирует новый контроллер каждый раз
    );
  }
}
```

### GlobalKey

```dart
// GlobalKey позволяет получить доступ к State из любого места
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите значение';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Форма валидна
              }
            },
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
  }
}
```

## Когда использовать Keys

### Случаи использования Keys

| Случай | Рекомендация |
|--------|-------------|
| Статический список виджетов | `const` без Keys |
| Динамический список с неизменными элементами | `ValueKey` с индексом |
| Список с изменяемыми элементами | `ValueKey` с уникальным ID |
| Перемещение элементов в списке | `ValueKey` с ID |
| Вставка/удаление элементов | `ValueKey` с ID |
| Каждый элемент должен сохранять состояние | `UniqueKey` или `ValueKey` |

### Пример: список с перемещением элементов

```dart
class DraggableList extends StatefulWidget {
  const DraggableList({super.key});

  @override
  State<DraggableList> createState() => _DraggableListState();
}

class _DraggableListState extends State<DraggableList> {
  List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];

  void _moveItem(int fromIndex, int toIndex) {
    setState(() {
      final item = items.removeAt(fromIndex);
      items.insert(toIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: items.length,
      onReorder: _moveItem,
      itemBuilder: (context, index) {
        return ListTile(
          key: ValueKey(items[index]),  // Key по значению элемента
          title: Text(items[index]),
          trailing: const Icon(Icons.drag_handle),
        );
      },
    );
  }
}
```

## Оптимизация вложенных виджетов

### Разделение на мелкие виджеты

Разделение больших виджетов на мелкие помогает Flutter более точно определить, какие части нужно перестроить:

```dart
// Плохо — весь виджет перестраивается при изменении любого состояния
class BadWidget extends StatefulWidget {
  @override
  State<BadWidget> createState() => _BadWidgetState();
}

class _BadWidgetState extends State<BadWidget> {
  int _counter = 0;
  String _text = 'Hello';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Изменение _counter перестраивает всё дерево
        Text('$_counter'),
        Text(_text),
        ElevatedButton(
          onPressed: () => setState(() => _counter++),
          child: const Text('Increment'),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _text = 'World'),
          child: const Text('Change Text'),
        ),
      ],
    );
  }
}

// Хорошо — каждый виджет перестраивается независимо
class GoodWidget extends StatefulWidget {
  @override
  State<GoodWidget> createState() => _GoodWidgetState();
}

class _GoodWidgetState extends State<GoodWidget> {
  int _counter = 0;
  String _text = 'Hello';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CounterWidget(counter: _counter),
        _TextWidget(text: _text),
        _IncrementButton(onIncrement: () => setState(() => _counter++)),
        _TextChangeButton(onChange: () => setState(() => _text = 'World')),
      ],
    );
  }
}

class _CounterWidget extends StatelessWidget {
  final int counter;
  const _CounterWidget({required this.counter});

  @override
  Widget build(BuildContext context) {
    return Text('$counter');
  }
}

class _TextWidget extends StatelessWidget {
  final String text;
  const _TextWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

class _IncrementButton extends StatelessWidget {
  final VoidCallback onIncrement;
  const _IncrementButton({required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onIncrement,
      child: const Text('Increment'),
    );
  }
}

class _TextChangeButton extends StatelessWidget {
  final VoidCallback onChange;
  const _TextChangeButton({required this.onChange});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onChange,
      child: const Text('Change Text'),
    );
  }
}
```

## Best Practices

### Рекомендации по оптимизации виджетов

1. **Используйте `const` везде, где возможно** — это самая простая и эффективная оптимизация
2. **Разделяйте виджеты на мелкие компоненты** — это уменьшает область перестройки
3. **Используйте `ValueKey` с уникальными ID** для динамических списков
4. **Избегайте `UniqueKey` в списках** — он ломает сопоставление элементов
5. **Используйте `GlobalKey` только когда необходимо** — он имеет накладные расходы
6. **Проверяйте Performance Overlay** — убедитесь, что const-оптимизация работает

### Чек-лист оптимизации

- [ ] Все статические виджеты помечены как `const`
- [ ] Все дочерние виджеты в `const`-конструкциях тоже `const`
- [ ] Динамические списки используют `ValueKey` с ID
- [ ] Большие виджеты разделены на мелкие компоненты
- [ ] Нет `UniqueKey` в списках
- [ ] FPS стабильно 55-60 на Performance Overlay

## Заключение

Правильное использование `const`-конструкторов и `Keys` — это фундамент оптимизации виджетов в Flutter. Эти техники просты в применении и дают значительный прирост производительности. В следующих разделах мы рассмотрим более продвинутые техники: избегание лишних rebuild'ов и ленивую загрузку.
