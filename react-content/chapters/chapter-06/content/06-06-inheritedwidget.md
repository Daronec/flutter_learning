# InheritedWidget — механизм распространения данных

## Введение

`InheritedWidget` — это фундаментальный механизм Flutter для распространения данных вниз по дереву виджетов. Он является основой для многих абстракций фреймворка, включая `Theme`, `MediaQuery`, `Navigator` и `Provider`.

> **Ключевая идея:** InheritedWidget позволяет дочерним виджетам читать данные из родительского виджета без передачи через конструкторы.

## Как работает InheritedWidget

### Принцип работы

```
InheritedWidget (родитель)
    ↓
    данные доступны всем потомкам
    ↓
    ↓
    ↓
Дочерний виджет вызывает dependOnInheritedWidgetOfExactType<T>()
    ↓
Flutter автоматически перестраивает виджет при изменении InheritedWidget
```

### Базовый пример

```dart
import 'package:flutter/material.dart';

// Модель данных
class CounterData {
  final int count;
  final VoidCallback increment;

  CounterData({required this.count, required this.increment});
}

// InheritedWidget
class CounterInherited extends InheritedWidget {
  final CounterData data;

  const CounterInherited({
    super.key,
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(CounterInherited oldWidget) {
    return data.count != oldWidget.data.count;
  }

  // Статический метод для удобного получения данных
  static CounterData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterInherited>()!.data;
  }
}

// Родительский виджет
class CounterParent extends StatefulWidget {
  const CounterParent({super.key});

  @override
  State<CounterParent> createState() => _CounterParentState();
}

class _CounterParentState extends State<CounterParent> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CounterInherited(
      data: CounterData(count: _count, increment: _increment),
      child: const CounterChild(),
    );
  }
}

// Дочерний виджет — получает данные из InheritedWidget
class CounterChild extends StatelessWidget {
  const CounterChild({super.key});

  @override
  Widget build(BuildContext context) {
    final counterData = CounterInherited.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Счётчик: ${counterData.count}'),
        ElevatedButton(
          onPressed: counterData.increment,
          child: const Text('Увеличить'),
        ),
      ],
    );
  }
}
```

## dependOnInheritedWidgetOfExactType

### Как это работает

```dart
// Внутри дочернего виджета
@override
Widget build(BuildContext context) {
  // Зависимость от InheritedWidget
  final data = context.dependOnInheritedWidgetOfExactType<MyInherited>()?.data;

  if (data == null) {
    return const Text('Данные не найдены');
  }

  return Text('Значение: ${data.value}');
}
```

### Механизм перестройки

```
1. Виджет вызывает dependOnInheritedWidgetOfExactType<T>()
    ↓
2. Flutter регистрирует зависимость виджета от InheritedWidget
    ↓
3. InheritedWidget обновляется (build() вызывается заново)
    ↓
4. updateShouldNotify() возвращает true
    ↓
5. Все зарегистрированные зависимые виджеты перестраиваются
```

## Theme и MediaQuery как InheritedWidget

### Theme

```dart
// Theme — это InheritedWidget
Theme.of(context).textTheme.headlineLarge
Theme.of(context).colorScheme.primary

// Внутренне это работает так:
// Theme.of(context) = context.dependOnInheritedWidgetOfExactType<Theme>()
```

### MediaQuery

```dart
// MediaQuery — это InheritedWidget
MediaQuery.of(context).size.width
MediaQuery.of(context).padding.top

// Использование для адаптивного дизайна
@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  return screenWidth > 600
      ? Row(children: [LeftPanel(), RightPanel()])
      : Column(children: [TopPanel(), BottomPanel()]);
}
```

## Создание пользовательского InheritedWidget

### Простой пример

```dart
// 1. Создаём класс данных
class AppSettings {
  final String appName;
  final bool isDarkMode;
  final String language;

  const AppSettings({
    required this.appName,
    required this.isDarkMode,
    required this.language,
  });
}

// 2. Создаём InheritedWidget
class AppSettingsProvider extends InheritedWidget {
  final AppSettings settings;

  const AppSettingsProvider({
    super.key,
    required this.settings,
    required super.child,
  });

  // Определяем, когда нужно уведомлять зависимые виджеты
  @override
  bool updateShouldNotify(AppSettingsProvider oldWidget) {
    return settings.isDarkMode != oldWidget.settings.isDarkMode ||
        settings.language != oldWidget.settings.language;
  }

  // Статический метод для удобного доступа
  static AppSettings of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppSettingsProvider>()!
        .settings;
  }
}

// 3. Используем в приложении
void main() {
  runApp(
    const AppSettingsProvider(
      settings: AppSettings(
        appName: 'Мое приложение',
        isDarkMode: false,
        language: 'ru',
      ),
      child: MyApp(),
    ),
  );
}
```

### Продвинутый пример с методом обновления

```dart
class ThemeProvider extends InheritedWidget {
  final ThemeData theme;
  final Function(ThemeMode) onThemeChanged;

  const ThemeProvider({
    super.key,
    required this.theme,
    required this.onThemeChanged,
    required super.child,
  });

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return theme.brightness != oldWidget.theme.brightness;
  }

  static ThemeProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>()!;
  }

  void toggleTheme() {
    onThemeChanged(
      theme.brightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark,
    );
  }
}

// Использование
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = ThemeProvider.of(context);

    return IconButton(
      icon: Icon(
        provider.theme.brightness == Brightness.dark
            ? Icons.light_mode
            : Icons.dark_mode,
      ),
      onPressed: provider.toggleTheme,
    );
  }
}
```

## Сравнение InheritedWidget и Provider

| Характеристика | InheritedWidget | Provider |
|---|---|---|
| **Сложность** | Низкая (базовый уровень) | Высокая (абстракция) |
| **Читаемость** | Требует статических методов | Интуитивный API |
| **Безопасность типов** | compile-time | compile-time |
| **Зависимости** | Нет | `provider` пакет |
| **Использование** | Редко напрямую | Часто |
| **Основа** | Фундамент | Обёртка над InheritedWidget |

## Best Practices

### ✅ Делайте

- Создавайте статические методы `of()` для удобного доступа
- Реализуйте `updateShouldNotify()` для оптимизации
- Используйте `dependOnInheritedWidgetOfExactType()` для подписки
- Храните данные в отдельном классе

### ❌ Не делайте

- Не создавайте InheritedWidget внутри `build()` без необходимости
- Не возвращайте `true` из `updateShouldNotify()` всегда
- Не передавайте виджеты через InheritedWidget
- Не создавайте глубокие цепочки InheritedWidget

## Заключение

`InheritedWidget` — это фундаментальный механизм Flutter для распространения данных. Хотя вы редко будете использовать его напрямую (вместо него используют Provider), понимание его работы помогает лучше понимать, как устроен Flutter.

> **Правило:** Используйте Provider или Riverpod для управления состоянием. Понимайте InheritedWidget, чтобы понимать, как работает фреймворк.
