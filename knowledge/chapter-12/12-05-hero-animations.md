# Hero-анимации в Flutter

## Введение

Hero-анимации создают эффект "полёта" элемента между двумя экранами. Один и тот же виджет плавно трансформируется при навигации.

## Widget Hero

### Базовое использование

```dart
// Экран 1: Список с Hero-элементами
class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Список товаров')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Hero(
              tag: 'product-image-$index',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://picsum.photos/80/80?random=$index',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text('Товар $index'),
            subtitle: const Text('Нажмите для подробностей'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetailScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

```dart
// Экран 2: Детали с Hero-элементом
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали товара')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Hero(
              tag: 'product-image-0',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://picsum.photos/400/400?random=0',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Название товара',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Описание товара...',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Ключевые требования Hero

| Требование | Описание |
|------------|----------|
| `tag` | Уникальный идентификатор между двумя экранами |
| Один виджет | Hero должен быть на обоих экранах |
| Разные размеры | Hero автоматически анимирует размер |

## Custom Hero Transitions

### HeroFlightShuttleBuilder

```dart
// Кастомный внешний вид во время анимации
class CustomHeroScreen extends StatelessWidget {
  const CustomHeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: 'custom-hero',
        flightShuttleBuilder: (
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          // Определяем, летим ли мы от или к
          final isPop = flightDirection == HeroFlightDirection.pop;

          // Получаем размеры из контекста
          final fromSize = (fromHeroContext.widget as Container).constraints?.maxWidth ?? 200;
          final toSize = MediaQuery.of(context).size.width;

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: animation.value,
                child: Opacity(
                  opacity: animation.value,
                  child: (flightDirection == HeroFlightDirection.push)
                      ? toHeroContext.widget
                      : fromHeroContext.widget,
                ),
              );
            },
          );
        },
        child: Container(
          width: 200,
          height: 200,
          color: Colors.blue,
          child: const Center(
            child: Text('Hero', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
```

### Hero createBoxShuttleBuilder

```dart
// Альтернативный метод для создания анимированного контейнера
flightShuttleBuilder: (
  flightContext,
  animation,
  flightDirection,
  fromHeroContext,
  toHeroContext,
) {
  final isPop = flightDirection == HeroFlightDirection.pop;

  // Получаем цвета и размеры
  final fromBox = fromHeroContext.findRenderObject() as RenderBox;
  final toBox = toHeroContext.findRenderObject() as RenderBox;

  final fromSize = fromBox.size;
  final toSize = toBox.size;

  return HeroFlightShuttleBox(
    animation: animation,
    fromSize: fromSize,
    toSize: toSize,
    flightDirection: flightDirection,
    child: fromHeroContext.widget,
  );
},
```

## Shared Axis Transitions

### Hero с Material 3 Shared Axis

```dart
// Использование SharedAxisTransition
import 'package:flutter/material.dart';

class SharedAxisHeroScreen extends StatelessWidget {
  const SharedAxisHeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared Axis Hero')),
      body: Center(
        child: Hero(
          tag: 'shared-hero',
          transitionOnUserGestures: true, // Разрешить свайп назад
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Hero',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SharedAxisDetailScreen(),
            ),
          );
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class SharedAxisDetailScreen extends StatelessWidget {
  const SharedAxisDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали')),
      body: Center(
        child: Hero(
          tag: 'shared-hero',
          transitionOnUserGestures: true,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text(
                'Hero',
                style: TextStyle(color: Colors.white, fontSize: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Параметры Hero

| Параметр | Тип | Описание |
|----------|-----|----------|
| `tag` | `Object` | Уникальный идентификатор |
| `flightShuttleBuilder` | `WidgetBuilder` | Кастомный shuttle |
| `builder` | `WidgetBuilder` | Кастомный builder |
| `transitionOnUserGestures` | `bool` | Разрешить свайп |
| `captureIn` | `Rect?` | Область захвата |
| `coverChild` | `Widget?` | Виджет-заглушка |
| `onEnd` | `VoidCallback?` | Callback по завершении |

## Best Practices для Hero

1. **Используйте уникальные `tag`** — без конфликтов между экранами
2. **Сохраняйте тип виджета** — Hero должен быть того же типа на обоих экранах
3. **Используйте `ClipRRect`** для плавных скруглений
4. **Добавляйте `transitionOnUserGestures: true`** для свайпа назад
5. **Избегайте вложенных Hero** — это может вызвать проблемы с производительностью
6. **Используйте `HeroFlightShuttleBox`** для простых кастомных анимаций

## Общие сценарии использования

| Сценарий | Tag |
|----------|-----|
| Аватар пользователя | `avatar-${userId}` |
| Карточка товара | `product-${productId}` |
| Изображение галереи | `gallery-${imageId}` |
| Иконка кнопки | `fab-${action}` |
| Логотип | `app-logo` |

## Лучшие практики

1. **Используйте осмысленные `tag`** — например, `product-${product.id}`
2. **Проверяйте существование Hero** на обоих экранах
3. **Используйте `ClipRRect`** для предотвращения артефактов
4. **Тестируйте на разных устройствах** — размеры могут отличаться
5. **Не анимируйте слишком сложные виджеты** — это может быть дорого
