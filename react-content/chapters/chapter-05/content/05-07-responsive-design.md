# Responsive-дизайн: адаптация под разные экраны

Responsive-дизайн — это подход к созданию интерфейсов, которые адаптируются к различным размерам экранов, ориентациям и устройствам. Flutter предоставляет несколько инструментов для реализации адаптивного дизайна.

## Стратегия брейкпоинтов

Брейкпоинты — это пороги ширины экрана, при которых макет изменяет свою структуру:

| Брейкпоинт | Ширина | Устройство |
|------------|--------|------------|
| `mobile` | < 600px | Смартфоны (портрет) |
| `tablet` | 600–1000px | Планшеты, смартфоны (альбом) |
| `desktop` | > 1000px | Десктопы, ноутбуки |

### Определение брейкпоинтов

```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1000;
  static const double desktop = 1400;

  static String getBreakpoint(double width) {
    if (width < mobile) return 'mobile';
    if (width < tablet) return 'tablet';
    if (width < desktop) return 'desktop';
    return 'desktop';
  }
}
```

## LayoutBuilder для responsive-дизайна

`LayoutBuilder` — основной инструмент для создания адаптивных макетов:

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobile;
        } else if (constraints.maxWidth < 1000) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}
```

### Использование

```dart
ResponsiveLayout(
  mobile: const MobileLayout(),
  tablet: const TabletLayout(),
  desktop: const DesktopLayout(),
)
```

## Полноценный пример адаптивного приложения

```dart
class AdaptiveApp extends StatelessWidget {
  const AdaptiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Адаптивное приложение')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _MobileBody();
          } else if (constraints.maxWidth < 1000) {
            return _TabletBody();
          } else {
            return _DesktopBody();
          }
        },
      ),
    );
  }
}

class _MobileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _AdaptiveCard('Карточка 1'),
        _AdaptiveCard('Карточка 2'),
        _AdaptiveCard('Карточка 3'),
      ],
    );
  }
}

class _TabletBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.home), label: Text('Главная')),
            NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Настройки')),
          ],
          selectedIndex: 0,
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisAxis(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 2,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _AdaptiveCard('Карточка $index');
            },
          ),
        ),
      ],
    );
  }
}

class _DesktopBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          extended: true,
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.home), label: Text('Главная')),
            NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Настройки')),
          ],
          selectedIndex: 0,
        ),
        Expanded(
          flex: 2,
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisAxis(
              crossAxisCount: 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 4 / 3,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              return _AdaptiveCard('Карточка $index');
            },
          ),
        ),
        const Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Детали'),
          ),
        ),
      ],
    );
  }
}
```

## Адаптивные компоненты

### Адаптивная типографика

```dart
class AdaptiveText extends StatelessWidget {
  final String data;

  const AdaptiveText(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = constraints.maxWidth > 600 ? 24.0 : 16.0;
        final fontWeight = constraints.maxWidth > 600
            ? FontWeight.bold
            : FontWeight.normal;

        return Text(
          data,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        );
      },
    );
  }
}
```

### Адаптивная навигация

```dart
class AdaptiveNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AdaptiveNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Мобильная навигация — BottomNavigationBar
          return BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: onSelected,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
            ],
          );
        } else {
          // Десктопная навигация — Drawer или NavigationRail
          return NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.home), label: Text('Главная')),
              NavigationRailDestination(icon: Icon(Icons.search), label: Text('Поиск')),
              NavigationRailDestination(icon: Icon(Icons.person), label: Text('Профиль')),
            ],
          );
        }
      },
    );
  }
}
```

### Адаптивная сетка

```dart
class AdaptiveGrid extends StatelessWidget {
  final int itemCount;

  const AdaptiveGrid({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Определяем количество колонок
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1000) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisAxis(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3 / 2,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            return Card(
              child: Center(child: Text('Карточка $index')),
            );
          },
        );
      },
    );
  }
}
```

## Best Practices

- Используйте `LayoutBuilder` для адаптивных макетов — он получает доступное пространство, а не размер экрана
- Определяйте брейкпоинты на основе контента, а не конкретных устройств
- Избегайте слишком большого количества брейкпоинтов — 2–3 обычно достаточно
- Адаптируйте не только расположение, но и размер шрифтов, отступы, количество колонок
- Тестируйте на разных размерах экрана — используйте Flutter DevTools
- Используйте `MediaQuery` для получения реальных размеров экрана с учётом safe area
- Для сложных адаптивных интерфейсов рассмотрите `OrientationBuilder` в сочетании с `LayoutBuilder`
- Делайте навигацию адаптивной: BottomNavigationBar для мобильных, NavigationRail для планшетов, Drawer для десктопов
