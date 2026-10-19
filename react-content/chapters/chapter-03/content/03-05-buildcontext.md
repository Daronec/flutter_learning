# 3.5 Контекст (BuildContext) и его роль

## Что такое BuildContext?

BuildContext — это объект, представляющий позицию виджета в дереве виджетов. Технически, это ссылка на `Element`, который управляет виджетом.

### Определение

```dart
abstract class BuildContext {
  T? dependOnInheritedWidget<T extends InheritedWidget>({Object? aspect});
  T? findAncestorWidgetOfExactType<T>();
  T? findAncestorStateOfType<T>();
  T? findAncestorRenderObjectOfType<T>();
  Element? findAncestorStateElement<T>();
  // ... и другие методы
}
```

## BuildContext в build()

```dart
@override
Widget build(BuildContext context) {
  // context — это BuildContext текущего виджета
  // Указывает на Element этого виджета в дереве
  
  // Через context можно:
  // 1. Получить данные из InheritedWidget
  // 2. Найти родительские элементы
  // 3. Получить RenderObject
  // 4. Получить State родительского виджета
  
  var theme = Theme.of(context);
  var media = MediaQuery.of(context);
  
  return Container();
}
```

## Работа с InheritedWidget

### Получение данных из контекста

```dart
// Theme.of(context) — находит InheritedWidget Theme
var theme = Theme.of(context);
var color = theme.primaryColor;

// MediaQuery.of(context) — находит InheritedWidget MediaQuery
var size = MediaQuery.of(context).size;

// Navigator.of(context) — находит Navigator
Navigator.of(context).push(...);

// Provider.of(context) — находит Provider
var store = Provider.of<Store>(context);
```

### Как это работает

```
Widget A (использует Theme.of(context))
    ↓
InheritedWidget Theme (выше в дереве)
    ↓
Theme предоставляет данные всем descendants
```

## Поиск элементов в дереве

### findAncestorWidgetOfExactType

```dart
// Найти ближайшего родителя с точным типом
AppBar? appBar = context.findAncestorWidgetOfExactType<AppBar>();

// С обобщённым типом
AppBar? appBar = context.findAncestorWidgetOfExactType<AppBar>();
```

### findAncestorStateOfType

```dart
// Найти State родителя определённого типа
// Важно: используется для доступа к State родителя

class ChildWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Найти State ближайшего родителя StatefulWidget
    var state = context.findAncestorStateOfType<_ParentState>();
    state?.doSomething();
    return Container();
  }
}
```

### findAncestorRenderObjectOfType

```dart
// Найти RenderObject родителя
// Используется для получения размеров, позиций

RenderBox? renderBox = context.findAncestorRenderObjectOfType();
Rect rect = renderBox!.localToGlobal(Offset.zero) & renderBox.paintBounds.size;
```

## Ограничения BuildContext

### Context после dispose

```dart
// ❌ ОШИБКА: использование context после dispose
@override
void dispose() {
  Navigator.of(context).pop(); // Ошибка!
}

// ✅ Правильно: проверять mounted
@override
void dispose() {
  if (mounted) {
    Navigator.of(context).pop();
  }
}
```

### Context после async операции

```dart
// ❌ ОШИБКА
Future.microtask(() async {
  Navigator.of(context).push(...); // Может быть после dispose
});

// ✅ Правильно
Future.microtask(() async {
  var data = await fetchData();
  if (mounted) {
    Navigator.of(context).push(...);
  }
});
```

## BuildContext как фильтр

### dependOnInheritedWidget

```dart
// Зарегистрировать зависимость от InheritedWidget
@override
Widget build(BuildContext context) {
  // При изменении Theme, этот виджет перестроится
  var theme = Theme.of(context);
  
  // Эквивалент:
  context.dependOnInheritedWidget(of: () => Theme.of);
  
  return Text('Hello', style: theme.textTheme.bodyLarge);
}
```

## Scoped BuildContext

### Передача контекста

```dart
// Context можно передавать между виджетами
class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // context здесь — контекст ParentWidget
        ChildWidget(context: context),
      ],
    );
  }
}

class ChildWidget extends StatelessWidget {
  final BuildContext parentContext;
  
  const ChildWidget({required this.parentContext, super.key});
  
  @override
  Widget build(BuildContext context) {
    // parentContext — контекст родителя
    // context — контекст этого виджета
    return Text('Hello');
  }
}
```

## Context и навигация

```dart
// Навигация требует BuildContext
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => SecondPage()),
);

// ScaffoldMessenger
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Saved')),
);

// Show dialog
showDialog(
  context: context,  // Требует BuildContext
  builder: (context) => AlertDialog(...),
);
```

## Best Practices

### 1. Используйте context текущего build()

```dart
// ✅ Хорошо
@override
Widget build(BuildContext context) {
  return Text('Hello');
}

// ❌ Не рекомендуется: захват context в замыкание
void _onPressed(BuildContext capturedContext) {
  Navigator.of(capturedContext).pop();
}
```

### 2. Проверяйте mounted после async

```dart
Future.microtask(() async {
  var data = await fetchData();
  if (mounted) {
    setState(() => _data = data);
  }
});
```

### 3. Используйте Consumer/Selector для оптимизации

```dart
// Вместо захвата context
Provider.of<Store>(context, listen: true)

// Используйте Consumer
Consumer<Store>(
  builder: (context, store, child) => Text(store.name),
)
```

## Заключение

BuildContext — это мост между виджетом и деревом. Он позволяет:
- Получать данные из InheritedWidget (Theme, MediaQuery, Provider)
- Находить родительские элементы
- Вызывать навигацию, диалоги, snackbar
- Получать размеры и позиции

**Правило**: всегда используйте context из `build()` и проверяйте `mounted` после async операций.
