---
tags:
  - widgets
  - architecture
chapter: 3
section: 4
title: Жизненный цикл виджета (lifecycle)
alias: 03 04 lifecycle
status: complete
---

# 3.4 Жизненный цикл виджета (lifecycle)

## Lifecycle Stateless Widget

```
Создание
    ↓
createElement()
    ↓
mount()
    ↓
build()
    ↓
[Изменение виджета]
    ↓
update() → build()
    ↓
unmount() → dispose()
```

### Методы StatelessWidget

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    // build() вызывается:
    // 1. При первом отображении
    // 2. При каждом перестроении
    // 3. Когда родитель перестраивается
    return Text('Hello');
  }
}
```

## Lifecycle Stateful Widget

```
Создание
    ↓
StatefulWidget.createElement()
    ↓
State.initState()
    ↓
State.didChangeDependencies()
    ↓
build()
    ↓
[Пользовательское действие]
    ↓
setState() → build()
    ↓
[Виджет обновлён]
    ↓
State.didUpdateWidget()
    ↓
build()
    ↓
[Удаление виджета]
    ↓
State.dispose()
```

### Методы State

```dart
class _MyWidgetState extends State<MyWidget> {
  
  // 1. Инициализация (вызывается один раз)
  @override
  void initState() {
    super.initState();
    // Создание контроллеров, подписок, анимаций
    _controller = AnimationController(...);
    _subscription = stream.listen(...);
  }
  
  // 2. Изменение зависимостей
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Theme, MediaQuery могут измениться
  }
  
  // 3. Перестроение UI
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 4. Обновление виджета
  @override
  void didUpdateWidget(MyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // oldWidget — старый виджет
    // widget — новый виджет
  }
  
  // 5. Очистка (вызывается один раз)
  @override
  void dispose() {
    // Уничтожение контроллеров, отписка
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }
}
```

## Детальный разбор методов

### initState()

```dart
@override
void initState() {
  super.initState();
  
  // ✅ Создание:
  // - TextEditingController
  // - AnimationController
  // - StreamSubscription
  // - PageController
  
  _nameController = TextEditingController();
  _animationController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 1),
  );
  
  // ❌ НЕ делать в initState:
  // - async/await (используйте Future.microtask)
  // - Navigator.push (используйте Future.microtask)
  
  // ✅ Правильный async в initState
  Future.microtask(() async {
    var data = await fetchData();
    setState(() {
      _data = data;
    });
  });
}
```

### didChangeDependencies()

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  // Вызывается:
  // 1. Сразу после initState()
  // 2. Когда InheritedWidget выше в дереве изменился
  // 3. Когда MediaQuery, Theme и т.д. изменились
  
  // Пример: получение данных из InheritedWidget
  var theme = Theme.of(context);
  var media = MediaQuery.of(context);
}
```

### didUpdateWidget()

```dart
@override
void didUpdateWidget(OldWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  // Вызывается когда виджет обновляется
  // oldWidget — предыдущая конфигурация
  // widget — новая конфигурация
  
  if (oldWidget.userId != widget.userId) {
    // Загрузить данные для нового пользователя
    _loadUser(widget.userId);
  }
  
  // Обновить контроллер если текст изменился
  if (oldWidget.text != widget.text) {
    _controller.text = widget.text;
  }
}
```

### dispose()

```dart
@override
void dispose() {
  // ОБЯЗАТЕЛЬНО освобождать ресурсы:
  
  // Контроллеры
  _nameController.dispose();
  _animationController.dispose();
  _pageController.dispose();
  
  // Подписки
  _subscription.cancel();
  
  // Таймеры
  _timer?.cancel();
  
  super.dispose();
}
```

## Build Trigger

### Что вызывает build()?

| Триггер | Описание |
|---|---|
| `setState()` | Явное обновление состояния |
| Родительский `setState()` | Перестройка родителя |
| `didChangeDependencies()` | Изменение InheritedWidget |
| `didUpdateWidget()` | Обновление конфигурации |
| Вставка/удаление виджета | Изменение дерева |

### Оптимизация build()

```dart
// ❌ Плохо: build() вызывается при каждом setState родителя
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Static text'),  // Перестраивается каждый раз
      CounterWidget(),       // Перестраивается каждый раз
      Text('More static'),   // Перестраивается каждый раз
    ],
  );
}

// ✅ Хорошо: const виджеты не перестраиваются
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      const Text('Static text'),  // Кэшируется
      CounterWidget(),             // Только этот перестраивается
      const Text('More static'),   // Кэшируется
    ],
  );
}
```

## Flutter Inspector — отладка lifecycle

```
В DevTools можно увидеть:
- Сколько раз был вызван build()
- Какие виджеты перестраиваются
- Время перестройки каждого виджета
- Причины перестройки
```

## Best Practices

1. **initState**: создавайте ресурсы, не делайте async
2. **dispose**: всегда освобождайте ресурсы
3. **const**: используйте const виджеты где возможно
4. **разделение**: выносите сложные виджеты в отдельные классы
5. **isCompleted**: проверяйте `mounted` перед setState после async

```dart
// Проверка mounted
Future.microtask(() async {
  var data = await fetchData();
  if (mounted) {
    setState(() {
      _data = data;
    });
  }
});
```

## Заключение

Понимание жизненного цикла виджетов критически важно для:
- Правильной инициализации и очистки
- Избежания утечек памяти
- Оптимизации производительности
- Предсказуемого поведения приложения
