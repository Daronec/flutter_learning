# ListView, GridView — списки и сетки

## Введение

`ListView` и `GridView` — одни из самых используемых виджетов в Flutter. Они предназначены для отображения списков и сеток данных, часто больших объёмов.

## ListView

Виджет `ListView` отображает линейный список дочерних виджетов.

### Конструкторы ListView

| Конструктор | Когда использовать |
|-------------|-------------------|
| `ListView()` | Когда детей немного и они уже созданы |
| `ListView.builder()` | Когда детей много или бесконечно |
| `ListView.separated()` | Когда нужны разделители между элементами |
| `ListView.custom()` | Для полностью кастомного поведения |

### ListView — с детьми

```dart
// ❌ Не используйте для больших списков
ListView(
  children: const [
    ListTile(title: Text('Первый')),
    ListTile(title: Text('Второй')),
    ListTile(title: Text('Третий')),
  ],
)

// ✅ Используйте для маленьких списков
const ListView(
  children: [
    Text('Элемент 1'),
    Text('Элемент 2'),
    Text('Элемент 3'),
  ],
)
```

### ListView.builder — ленивая загрузка

```dart
ListView.builder(
  // Количество элементов
  itemCount: items.length,
  // Создание элемента
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index]),
      onTap: () {
        print('Нажат элемент: ${items[index]}');
      },
    );
  },
)
```

### ListView.builder с параметрами

```dart
ListView.builder(
  itemCount: items.length,
  padding: const EdgeInsets.symmetric(vertical: 8),
  // Направление прокрутки
  scrollDirection: Axis.vertical, // или Axis.horizontal
  // Физика прокрутки
  physics: const BouncingScrollPhysics(),
  // Кастомизация
  itemBuilder: (context, index) {
    final item = items[index];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(item.title),
        subtitle: Text(item.description),
        trailing: Icon(Icons.chevron_right),
        onTap: () => navigateToDetail(item),
      ),
    );
  },
)
```

### ListView.separated — с разделителями

```dart
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (context, index) => const Divider(height: 1),
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(items[index]),
    );
  },
)
```

### ListView с горизонтальной прокруткой

```dart
ListView(
  scrollDirection: Axis.horizontal,
  children: const [
    Card(child: SizedBox(width: 150, height: 200, child: Text('1'))),
    SizedBox(width: 8),
    Card(child: SizedBox(width: 150, height: 200, child: Text('2'))),
    SizedBox(width: 8),
    Card(child: SizedBox(width: 150, height: 200, child: Text('3'))),
  ],
)
```

### ListView с контроллером прокрутки

```dart
class ScrollableList extends StatefulWidget {
  @override
  _ScrollableListState createState() => _ScrollableListState();
}

class _ScrollableListState extends State<ScrollableList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // Слушатель прокрутки
    _controller.addListener(() {
      print('Позиция: ${_controller.position.pixels}');
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Важно!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Плавная прокрутка к началу
            _controller.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: const Text('Наверх'),
        ),
        Expanded(
          child: ListView.builder(
            controller: _controller,
            itemCount: 100,
            itemBuilder: (context, index) {
              return ListTile(title: Text('Элемент $index'));
            },
          ),
        ),
      ],
    );
  }
}
```

## GridView

Виджет `GridView` отображает элементы в двумерной сетке.

### Конструкторы GridView

| Конструктор | Описание |
|-------------|----------|
| `GridView.builder()` | Ленивая загрузка элементов |
| `GridView.count()` | Фиксированное количество столбцов |
| `GridView.extent()` | Максимальная ширина столбца |
| `GridView.custom()` | Полностью кастомный |

### GridView.count — фиксированные столбцы

```dart
GridView.count(
  crossAxisCount: 2, // Количество столбцов
  mainAxisSpacing: 8, // Расстояние по вертикали
  crossAxisSpacing: 8, // Расстояние по горизонтали
  padding: const EdgeInsets.all(8),
  // Aspect ratio для высоты элементов
  childAspectRatio: 1.0,
  children: const [
    Card(child: Center(child: Text('1'))),
    Card(child: Center(child: Text('2'))),
    Card(child: Center(child: Text('3'))),
    Card(child: Center(child: Text('4'))),
  ],
)
```

### GridView.builder — ленивая загрузка

```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 0.75,
  ),
  itemCount: images.length,
  padding: const EdgeInsets.all(8),
  itemBuilder: (context, index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        images[index],
        fit: BoxFit.cover,
      ),
    );
  },
)
```

### SliverGridDelegateWithMaxCrossAxisExtent

```dart
// Максимальная ширина столбца
GridView.builder(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200, // Максимальная ширина
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 1,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(child: Center(child: Text(items[index])));
  },
)
```

### SliverGridDelegateWithFixedCrossAxisCount

```dart
// Фиксированное количество столбцов
const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 4,      // 4 столбца
  mainAxisSpacing: 10,    // Вертикальный отступ
  crossAxisSpacing: 10,   // Горизонтальный отступ
  childAspectRatio: 1,    // Соотношение сторон
)
```

## SliverList и SliverGrid

Для кастомной прокрутки (например, с `CustomScrollView`) используются sliver-виджеты.

### SliverList

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Список'),
      ),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ListTile(title: Text('Элемент $index'));
        },
        childCount: 100,
      ),
    ),
  ],
)
```

### SliverGrid

```dart
CustomScrollView(
  slivers: [
    SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Container(
            color: Colors.primaries[index % Colors.primaries.length],
          );
        },
        childCount: 20,
      ),
    ),
  ],
)
```

## Performance Considerations

### Правила производительности

| Ситуация | Решение |
|----------|---------|
| Маленький список (< 20 элементов) | `ListView(children: [...])` |
| Большой список | `ListView.builder()` |
| Бесконечный список | `ListView.builder()` с большим itemCount |
| Сетка с фиксированными столбцами | `GridView.count()` |
| Сетка с адаптивной шириной | `GridView.builder()` + `SliverGridDelegateWithMaxCrossAxisExtent` |
| Кастомный скролл | `CustomScrollView` + `Sliver*` |

### Ключевые рекомендации

1. **Всегда используйте `builder` для больших списков** — это создаёт виджеты лениво.

2. **Избегайте `ListView` с большим списком `children`** — все виджеты создаются сразу.

3. **Используйте `const` конструкторы** для элементов списка, чтобы Flutter мог кэшировать виджеты.

4. **Используйте `key` для уникальных элементов**:
   ```dart
   ListView.builder(
     itemBuilder: (context, index) {
       return ListTile(
         key: ValueKey(items[index].id),
         title: Text(items[index].title),
       );
     },
   )
   ```

5. **Используйте `ListView` внутри `Column`** через `Expanded`:
   ```dart
   Column(
     children: [
       const Text('Заголовок'),
       Expanded(
         child: ListView.builder(
           itemCount: items.length,
           itemBuilder: (context, index) {
             return ListTile(title: Text(items[index]));
           },
         ),
       ),
     ],
   )
   ```

## Best Practices

1. **Используйте `ListView.builder()`** для всех списков с более чем 20 элементами.

2. **Используйте `separated`**, когда нужны разделители — это эффективнее, чем добавлять пустые виджеты.

3. **Используйте `SliverAppBar`** с `CustomScrollView` для эффектов параллакса.

4. **Используйте `cacheExtent`** для предварительной загрузки элементов:
   ```dart
   ListView.builder(
     cacheExtent: 500, // Загружать элементы за пределами видимости
     itemCount: items.length,
     itemBuilder: (context, index) => ListTile(title: Text(items[index])),
   )
   ```

5. **Избегайте сложных виджетов** внутри `ListView.builder` — это замедляет прокрутку.

6. **Используйте `shrinkWrap: true`** только когда `ListView` помещается в ограниченный контейнер — это отключает оптимизации прокрутки.
