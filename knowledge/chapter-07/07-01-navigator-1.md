---
tags:
  - navigation
  - routing
chapter: 7
section: 1
title: Navigator 1.0: push, pop, named routes
alias: 07 01 navigator 1
status: complete
---

# Navigator 1.0: push, pop, named routes

Navigator 1.0 — это императивная система навигации в Flutter, основанная на стеке маршрутов (route stack). Это базовый и наиболее часто используемый подход к навигации в Flutter-приложениях.

## Как работает стек маршрутов

Flutter управляет навигацией с помощью стека. Каждый новый экран добавляется в верхнюю часть стека, а при возврате — удаляется.

```
┌─────────────────────┐
│  Screen C (top)     │  ← Видимый экран
├─────────────────────┤
│  Screen B           │
├─────────────────────┤
│  Screen A (bottom)  │  ← Начальный экран
└─────────────────────┘
```

## Navigator.push и pop

### Navigator.push

Метод `push` добавляет новый маршрут в верхнюю часть стека навигации:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SecondScreen(),
  ),
);
```

### Navigator.pop

Метод `pop` удаляет верхний маршрут из стека, возвращая пользователя на предыдущий экран:

```dart
Navigator.pop(context);

// С возвратом значения
Navigator.pop(context, {'status': 'saved'});
```

### MaterialPageRoute

`MaterialPageRoute` создаёт маршрут, соответствующий Material Design стандартам:

```dart
// Базовый push
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DetailScreen(),
  ),
);

// С настройкой анимации
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const DetailScreen(),
    fullscreenDialog: true, // Полноэкранный диалог (iOS-стиль)
  ),
);
```

### CupertinoPageRoute

`CupertinoPageRoute` создаёт маршрут в стиле iOS:

```dart
Navigator.push(
  context,
  CupertinoPageRoute(
    builder: (context) => const IosDetailScreen(),
    settings: const RouteSettings(name: '/ios-detail'),
  ),
);
```

## Сравнение типов маршрутов

| Характеристика | MaterialPageRoute | CupertinoPageRoute |
|---|---|---|
| Стиль анимации | Material (сдвиг справа) | iOS (сдвиг справа, fade) |
| Кнопка «Назад» | Системная стрелка | Системная стрелка |
| Адаптация | Android | iOS |
| fullscreenDialog | Да | Да |
| Настройка transition | Ограниченная | Ограниченная |

## Named Routes

Named routes позволяют определять маршруты по строковым именам, что упрощает навигацию и делает код более читаемым.

### Объявление маршрутов

```dart
void main() {
  runApp(
    MaterialApp(
      // Определяем маршруты
      routes: {
        '/': (context) => const HomeScreen(),
        '/about': (context) => const AboutScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      initialRoute: '/',
    ),
  );
}
```

### Навигация по именам

```dart
// Простая навигация по имени
Navigator.pushNamed(context, '/about');

// Навигация с заменой текущего экрана
Navigator.pushReplacementNamed(context, '/settings');

// Навигация с очисткой стека и переходом на начальный экран
Navigator.pushNamedAndRemoveUntil(
  context,
  '/',
  (route) => false, // Удаляем все предыдущие маршруты
);

// Возврат к предыдущему экрану
Navigator.pop(context);

// Закрытие диалога
Navigator.of(context).pop();
```

### onGenerateRoute и onUnknownRoute

Для динамической генерации маршрутов используются колбэки `onGenerateRoute` и `onUnknownRoute`:

```dart
MaterialApp(
  initialRoute: '/',
  onGenerateRoute: (settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case '/product':
        return MaterialPageRoute(
          builder: (_) => ProductScreen(
            productId: settings.arguments as String,
          ),
        );
      default:
        return null; // Передать onUnknownRoute
    }
  },
  onUnknownRoute: (settings) {
    return MaterialPageRoute(
      builder: (_) => const NotFoundScreen(),
    );
  },
);
```

## Основные методы Navigator

| Метод | Описание | Возвращаемое значение |
|---|---|---|
| `push` | Добавляет маршрут в стек | `Future<T?>` |
| `pushNamed` | Добавляет именованный маршрут | `Future<T?>` |
| `pushReplacement` | Заменяет текущий маршрут | `Future<T?>` |
| `pushReplacementNamed` | Заменяет именованный маршрут | `Future<T?>` |
| `pop` | Удаляет верхний маршрут | void |
| `popUntil` | Возвращает до условия | void |
| `removeRouteBelow` | Удаляет маршрут под указанным | void |
| `pushNamedAndRemoveUntil` | Push + очистка стека | `Future<T?>` |

## Пример: Полная навигация между экранами

```dart
// Главный экран приложения
void main() {
  runApp(
    MaterialApp(
      title: 'Navigation Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/details': (context) => const DetailsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    ),
  );
}

// Экран 1: Домашний экран
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/details');
              },
              child: const Text('Перейти к деталям'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: const Text('Настройки'),
            ),
          ],
        ),
      ),
    );
  }
}

// Экран 2: Детальный экран
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Возврат на предыдущий экран
            Navigator.pop(context);
          },
          child: const Text('Назад'),
        ),
      ),
    );
  }
}

// Экран 3: Настройки
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Возврат на главный экран с очисткой стека
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
          },
          child: const Text('На главную'),
        ),
      ),
    );
  }
}
```

## Best Practices

1. **Используйте named routes** для статических маршрутов — это упрощает тестирование и читаемость.
2. **Используйте `pushNamedAndRemoveUntil`** при авторизации — чтобы пользователь не мог вернуться на экран логина после входа.
3. **Устанавливайте `fullscreenDialog: true`** для полноэкранных диалогов — это изменяет анимацию и поведение кнопки «Назад» на iOS.
4. **Обрабатывайте `onUnknownRoute`** — для отображения экранов 404 при переходе по несуществующим маршрутам.
5. **Не используйте `Navigator.push` напрямую** в крупных проектах — создайте обёртки (navigation helpers) для централизации логики.
6. **Избегайте глубокой вложенности стека** — если стек становится слишком глубоким, используйте `pushReplacement` для удаления старых маршрутов.
7. **Используйте `popUntil`** для возврата к конкретному экрану в стеке:

```dart
// Возврат к экрану HomeScreen
Navigator.popUntil(context, (route) => route.isFirst);
```

## Когда использовать Navigator 1.0

Navigator 1.0 подходит для большинства приложений:
- Простая навигация между экранами
- Не требуется синхронизация с URL
- Нет необходимости в глубоких ссылках (deep links)
- Приложение не требует сложной маршрутизации

Для более сложных сценариев (deep links, URL-синхронизация) рассмотрите Navigator 2.0 или go_router.
## РЎРІСЏР·Р°РЅРЅС‹Рµ РіР»Р°РІС‹

[[Form и FormKey — основы работы с формами]] [[HTTP-протокол: основы и работа с сетью в Flutter]] 
