# 3.3 StatelessWidget vs StatefulWidget

## StatelessWidget

### Описание

StatelessWidget — виджет без изменяемого состояния. Конфигурация виджета фиксирована после создания.

### Когда использовать

- UI не изменяется динамически
- Зависит только от конфигурации (параметров)
- Не реагирует на события пользователя
- Отображает статические данные

### Пример

```dart
class GreetingWidget extends StatelessWidget {
  final String name;
  final Color color;
  
  const GreetingWidget({
    required this.name,
    this.color = Colors.black,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello, $name!',
      style: TextStyle(color: color, fontSize: 24),
    );
  }
}

// Использование
GreetingWidget(name: 'Alice', color: Colors.blue);
```

### Особенности

- Все поля должны быть `final`
- Конструктор обычно `const`
- Один метод `build()`
- Не может изменять себя после создания

## StatefulWidget

### Описание

StatefulWidget — виджет с изменяемым состоянием. Содержит `State` объект, который хранит и управляет состоянием.

### Когда использовать

- UI изменяется динамически
- Реагирует на события пользователя
- Анимации
- Данные загружаются асинхронно
- Форма с вводом

### Пример

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
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _count++;
        });
      },
      child: Text('Count: $_count'),
    );
  }
}
```

### Структура StatefulWidget

```
StatefulWidget (конфигурация, immutable)
    ↓ создаёт
State (состояние, mutable)
    ↓ хранит
int _count, String _text, List<Data> _items
    ↓ вызывает
setState(() => ...)
    ↓ перестраивает
build()
```

## Сравнение

| | StatelessWidget | StatefulWidget |
|---|---|---|
| **Состояние** | Нет | Да (через State) |
| **Изменяемость** | Immutable | Mutable State |
| **Методы** | build() | build(), initState(), dispose() |
| **Конструктор** | Обычно const | Не может быть const |
| **Производительность** | Быстрее (const) | Чуть медленнее |
| **Использование** | Статический UI | Динамический UI |

## State класс

### Жизненный цикл State

```dart
class _MyWidgetState extends State<MyWidget> {
  // 1. initState() — вызывается один раз при создании
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  // 2. didUpdateWidget() — при изменении виджета
  @override
  void didUpdateWidget(MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleWidgetUpdate(oldWidget);
  }
  
  // 3. build() — отрисовка UI
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 4. dispose() — очистка ресурсов
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Методы State

| Метод | Когда вызывается |
|---|---|
| `initState()` | Один раз при создании |
| `didChangeDependencies()` | При изменении зависимостей |
| `didUpdateWidget()` | При обновлении виджета |
| `build()` | Каждый раз при перестройке |
| `dispose()` | При удалении виджета |

## setState

### Механизм

```dart
setState(() {
  _count++;  // Изменение состояния
});

// Что происходит:
// 1. Флаг dirty = true
// 2. Element помечается как needing build
// 3. Framework вызывает build() в следующем кадре
// 4. Widget Tree перестраивается
// 5. RenderObject обновляется
```

### Правила setState

```dart
// ✅ Правильно
setState(() {
  _count++;
  _text = 'Updated';
});

// ❌ Нельзя вызывать build() вручную
// build() вызывается автоматически framework'ом

// ❌ Нельзя изменять widget (он immutable)
// widget.name = 'New'; // Ошибка!

// ✅ Можно изменять State
_count = 10;
```

## Когда использовать что?

### Используйте StatelessWidget когда:

```dart
// Виджет зависит только от входных данных
class ProfileCard extends StatelessWidget {
  final User user;
  
  ProfileCard({required this.user, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(user.name),
          Text(user.email),
        ],
      ),
    );
  }
}
```

### Используйте StatefulWidget когда:

```dart
// Виджет должен реагировать на события
class ProfileEditor extends StatefulWidget {
  final User user;
  
  ProfileEditor({required this.user, super.key});
  
  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  late TextEditingController _nameController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(controller: _nameController);
  }
}
```

## Заключение

- **StatelessWidget** — для статического UI, быстрее, можно использовать `const`
- **StatefulWidget** — для динамического UI, с изменяемым состоянием
- **Правило**: всегда используйте StatelessWidget, если возможно
- **State** хранится в отдельном классе, отделённом от конфигурации
