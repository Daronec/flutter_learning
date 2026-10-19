# 3.2 Element и Tree — как работает widget-дерево

## Три дерева Flutter

Flutter использует три дерева для построения UI:

```
Widget Tree (конфигурация)
    ↓ создаёт/обновляет
Element Tree (управление)
    ↓ управляет
RenderObject Tree (layout + рисование)
```

## Widget — конфигурация

```dart
// Widget — лёгкий, неизменяемый, создаётся часто
Text('Hello')
  // Конфигурирует:
  // - текст: 'Hello'
  // - стиль: по умолчанию
  // - strut: true
```

**Характеристики Widget:**
- Лёгкий объект (несколько полей)
- Неизменяемый (все поля `final`)
- Создаётся при каждом `build()`
- Не содержит состояния
- Не кэшируется

## Element — управление

```dart
// Element — экземпляр виджета в дереве
// Кэшируется, управляет жизненным циклом
```

**Характеристики Element:**
- Средней тяжести объект
- Кэшируется в дереве
- Управляет жизненным циклом виджета
- Содержит BuildContext
- knows своих родителей и детей

### Типы Element

| Element | Описание |
|---|---|
| `ComponentElement` | Для ComponentWidget (Column, Row) |
| `StatefulElement` | Для StatefulWidget |
| `StatelessElement` | Для StatelessWidget |
| `ProxyElement` | Для ProxyWidget (Theme, InheritedWidget) |
| `RenderObjectElement` | Для RenderObjectWidget |

## RenderObject — рисование

```dart
// RenderObject — объект, отвечающий за layout и рисование
RenderParagraph — для текста
RenderFlex — для Row/Column
RenderStack — для Stack
```

**Характеристики RenderObject:**
- Тяжёлый объект
- Кэшируется
- Вычисляет layout (position + size)
- Рисует пиксели
- Обрабатывает жесты

## Жизненный цикл Element

```
1. createElement()
   ↓
2. mount(parent, initialIndex)
   ↓
3. insertRenderObjectChild(key, renderObject)
   ↓
4. build()
   ↓
5. updateChild(newWidget)
   ↓
6. deactivate() / unmount()
```

### Детальный жизненный цикл

```dart
// StatelessElement lifecycle
class StatelessElement extends ComponentElement {
  @override
  Widget build() {
    // Строим виджет
    return widget.build(this);
  }
  
  @override
  void unmount() {
    // Очистка ресурсов
    super.unmount();
  }
}

// StatefulElement lifecycle
class StatefulElement _buildStatefulWidget() {
  @override
  Widget build() {
    return _state.build(this);
  }
}
```

## Widget → Element → RenderObject

### Связь между деревьями

```dart
// Widget (конфигурация)
Text('Hello')
  // ↓ createElement()
Element (управление)
  // ↓ createRenderObject()
RenderObject (рисование)

// При изменении:
Widget (новый)
  // ↓ update()
Element (обновляется)
  // ↓ updateRenderObject()
RenderObject (перелayout/перерисовка)
```

### Пример

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello');
    // Создаёт:
    // 1. TextElement (Element)
    // 2. RenderParagraph (RenderObject)
  }
}
```

## Tree Diffing

### Как Flutter определяет изменения

```dart
// Старое дерево
Column(
  children: [
    Text('A'),
    Text('B'),
    Text('C'),
  ],
)

// Новое дерево
Column(
  children: [
    Text('A'),
    Text('B'),   // ← не изменился, Element кэширован
    Text('C'),
  ],
)

// Flutter сравнивает:
// 1. Тип виджета (Text → Text)
// 2. Key (если есть)
// 3. Параметры виджета
```

### Критерии обновления

| Критерий | Описание |
|---|---|
| **Тип** | Если тип разный — удаляем старый, создаём новый |
| **Key** | Если есть Key — используем для сопоставления |
| **Parameters** | Если параметры разные — обновляем конфигурацию |

## BuildContext

```dart
// BuildContext — ссылка на Element в дереве
// Предоставляет информацию о расположении виджета

@override
Widget build(BuildContext context) {
  // context указывает на Element этого виджета
  // Через context можно получить доступ к:
  // - Theme.of(context) — тема
  // - MediaQuery.of(context) — размеры экрана
  // - Navigator.of(context) — навигация
  // - Provider.of(context) — состояние
  return Text('Hello');
}
```

## Заключение

Понимание трёх деревьев Flutter критически важно для:
- Оптимизации производительности
- Правильного использования Key
- Отладки проблем с перестройкой
- Создания эффективных виджетов

Ключевое правило: **Widget — конфигурация, Element — управление, RenderObject — рисование**.
