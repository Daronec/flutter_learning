# Golden tests — визульное регрессионное тестирование

Golden tests (золотые тесты) — это вид тестирования, который сравнивает рендеринг виджета с эталонным изображением. Это позволяет обнаруживать непреднамеренные визуальные изменения в UI.

## Что такое golden tests

Golden tests делают скриншот виджета и сравнивают его с сохранённым эталонным изображением. Если изображения отличаются — тест не проходит.

### Когда использовать

| Ситуация | Подходит |
|----------|----------|
| Сложный кастомный виджет | Да |
| Компоненты с анимацией | Да |
| Стандартные Material виджеты | Нет |
| Формы и списки | Иногда |
| Кастомные графики и диаграммы | Да |

## Установка golden_toolkit

### Добавление зависимостей

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  golden_toolkit: ^1.0.0
```

### Установка пакета

```bash
flutter pub get
```

## Базовое использование

### Настройка binding

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  // Загружаем шрифты перед тестами
  testWidgetsAllGoldens(
    'Golden test',
    (tester) async {
      // Тестовый код
    },
  );
}
```

### loadAppDefaults — загрузка настроек приложения

```dart
void main() {
  testWidgetsAllGoldens('Golden test с загрузкой настроек',
      (WidgetTester tester) async {
    // Загружаем шрифты и настройки приложения
    await loadAppDefaults();

    // Строим виджет
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Hello, Golden!'),
          ),
        ),
      ),
    );

    // Создаём золотой снимок
    await screenMatchesGolden(tester, 'basic_text');
  });
}
```

### loadGoldenFile — загрузка золотых файлов

```dart
void main() {
  testWidgetsAllGoldens('Golden test с кастомными шрифтами',
      (WidgetTester tester) async {
    // Загружаем шрифты из папки fonts
    await loadAppFonts();

    // Загружаем настройки
    await loadAppDefaults(
      builder: (widget) => MaterialApp(home: widget),
    );

    await tester.pumpWidget(const ProductCard(product: mockProduct));

    await screenMatchesGolden(tester, 'product_card');
  });
}
```

## Основные методы

### screenMatchesGolden

```dart
// Базовый синтаксис
await screenMatchesGolden(tester, 'имя_золотого_файла');

// С параметрами
await screenMatchesGolden(
  tester,
  'имя_файла',
  size: Size(375, 812), // Размер экрана
  device: Device.iphone12, // Устройство
  platform: TargetPlatform.iOS, // Платформа
);
```

### GoldenTester

```dart
void main() {
  testWidgetsAllGoldens('GoldenTester пример', (WidgetTester tester) async {
    await loadAppDefaults();

    // Создаём GoldenTester
    final goldenTester = GoldenTester(tester);

    // Тестируем виджет
    await goldenTester.test(
      widget: const Text('Hello'),
      name: 'hello_text',
    );
  });
}
```

## Примеры golden tests

### Тестирование карточки товара

```dart
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            child: Image.network(
              product.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  product.description,
                  style: TextStyle(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('В корзину'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

void main() {
  final mockProduct = Product(
    name: 'Смартфон',
    description: 'Современный смартфон с отличной камерой',
    price: 29999,
    imageUrl: 'https://example.com/phone.jpg',
  );

  group('ProductCard golden tests', () {
    testWidgetsAllGoldens('должен отображать карточку товара',
        (WidgetTester tester) async {
      await loadAppDefaults();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: ProductCard(product: mockProduct),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await screenMatchesGolden(tester, 'product_card');
    });

    testWidgetsAllGoldens('должен отображать карточку без изображения',
        (WidgetTester tester) async {
      await loadAppDefaults();

      final productWithoutImage = Product(
        name: 'Цифровой товар',
        description: 'Товар без изображения',
        price: 999,
        imageUrl: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: ProductCard(product: productWithoutImage),
              ),
            ),
          ),
        ),
      );

      await screenMatchesGolden(tester, 'product_card_no_image');
    });
  });
}
```

### Тестирование разных состояний

```dart
class LoginWidget extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;

  const LoginWidget({
    super.key,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasError)
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.red[100],
                child: Text(errorMessage),
              ),
            SizedBox(height: 16),
            TextFormField(decoration: InputDecoration(labelText: 'Email')),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            if (isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {},
                child: Text('Войти'),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('LoginWidget golden states', () {
    testWidgetsAllGoldens('нормальное состояние',
        (WidgetTester tester) async {
      await loadAppDefaults();
      await tester.pumpWidget(const MaterialApp(home: LoginWidget()));
      await screenMatchesGolden(tester, 'login_normal');
    });

    testWidgetsAllGoldens('состояние загрузки',
        (WidgetTester tester) async {
      await loadAppDefaults();
      await tester.pumpWidget(const MaterialApp(
        home: LoginWidget(isLoading: true),
      ));
      await screenMatchesGolden(tester, 'login_loading');
    });

    testWidgetsAllGoldens('состояние ошибки',
        (WidgetTester tester) async {
      await loadAppDefaults();
      await tester.pumpWidget(const MaterialApp(
        home: LoginWidget(
          hasError: true,
          errorMessage: 'Неверный email или пароль',
        ),
      ));
      await screenMatchesGolden(tester, 'login_error');
    });
  });
}
```

### Тестирование тёмной и светлой темы

```dart
class ThemeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Светлая тема'),
              ElevatedButton(onPressed: () {}, child: Text('Действие')),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('ThemeWidget golden tests', () {
    testWidgetsAllGoldens('светлая тема',
        (WidgetTester tester) async {
      await loadAppDefaults();
      await tester.pumpWidget(const MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: Text('Светлая тема'),
          ),
        ),
      ));
      await screenMatchesGolden(tester, 'theme_light');
    });

    testWidgetsAllGoldens('тёмная тема',
        (WidgetTester tester) async {
      await loadAppDefaults();
      await tester.pumpWidget(const MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Center(
            child: Text('Тёмная тема'),
          ),
        ),
      ));
      await screenMatchesGolden(tester, 'theme_dark');
    });
  });
}
```

## Обновление золотых файлов

### Команда для обновления

```bash
# Обновление всех золотых файлов
flutter test --update-goldens

# Обновление конкретного теста
flutter test test/golden/product_card_test.dart --update-goldens
```

### Когда обновлять

| Ситуация | Действие |
|----------|----------|
| Намеренное изменение UI | Обновить золотые файлы |
| Сбой теста без изменений | Проверить и обновить |
| Изменение шрифтов | Обновить золотые файлы |
| Изменение размеров экрана | Обновить золотые файлы |
| Неожиданное изм��нение | Исправить баг, не обновлять |

### Автоматическое обновление в CI

```yaml
# .github/workflows/golden-update.yml
name: Update Golden Files
on:
  push:
    branches: [main]

jobs:
  update-goldens:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --update-goldens
      - uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "chore: update golden files"
```

## Настройка размеров и устройств

### Разные размеры экранов

```dart
void main() {
  testWidgetsAllGoldens('разные размеры экранов',
      (WidgetTester tester) async {
    await loadAppDefaults();

    // Маленький экран
    await tester.binding.setSurfaceSize(Size(320, 480));
    await tester.pumpWidget(const Text('Маленький'));
    await screenMatchesGolden(tester, 'small_screen');
    await tester.binding.setSurfaceSize(null);

    // Средний экран
    await tester.binding.setSurfaceSize(Size(375, 812));
    await tester.pumpWidget(const Text('Средний'));
    await screenMatchesGolden(tester, 'medium_screen');
    await tester.binding.setSurfaceSize(null);

    // Большой экран
    await tester.binding.setSurfaceSize(Size(768, 1024));
    await tester.pumpWidget(const Text('Большой'));
    await screenMatchesGolden(tester, 'large_screen');
    await tester.binding.setSurfaceSize(null);
  });
}
```

### Разные устройства

```dart
void main() {
  testWidgetsAllGoldens('разные устройства',
      (WidgetTester tester) async {
    await loadAppDefaults();

    // iPhone
    await tester.binding.setSurfaceSize(Device.iphone12.size);
    await tester.pumpWidget(const Text('iPhone'));
    await screenMatchesGolden(tester, 'device_iphone12');
    await tester.binding.setSurfaceSize(null);

    // Pixel
    await tester.binding.setSurfaceSize(Device.pixel5.size);
    await tester.pumpWidget(const Text('Pixel'));
    await screenMatchesGolden(tester, 'device_pixel5');
    await tester.binding.setSurfaceSize(null);

    // iPad
    await tester.binding.setSurfaceSize(Device.ipadAir.size);
    await tester.pumpWidget(const Text('iPad'));
    await screenMatchesGolden(tester, 'device_ipad');
    await tester.binding.setSurfaceSize(null);
  });
}
```

## Golden test для списков

```dart
void main() {
  testWidgetsAllGoldens('ListView golden test',
      (WidgetTester tester) async {
    await loadAppDefaults();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('Элемент $index'),
                subtitle: Text('Описание элемента $index'),
              );
            },
          ),
        ),
      ),
    );

    await screenMatchesGolden(tester, 'list_view');
  });
}
```

## Лучшие практики

1. **Тестируйте только кастомные виджеты** — не тестируйте стандартные Material виджеты
2. **Фиксируйте размер экрана** — используйте `ConstrainedBox` или `SizedBox`
3. **Используйте mock-данные** — стабильные данные для воспроизводимых тестов
4. **Обновляйте золотые файлы намеренно** — не обновляйте при каждом сбое
5. **Проверяйте изменения вручную** — перед коммитом обновлённых золотых файлов
6. **Тестируйте разные темы** — светлая и тёмная тема
7. **Тестируйте разные языки** — если приложение мультиязычное
8. **Используйте комментарии** — объясняйте, что тестирует каждый тест

## Структура golden файлов

```
test/
  goldens/
    product_card.png
    product_card_no_image.png
    login_normal.png
    login_loading.png
    login_error.png
    theme_light.png
    theme_dark.png
```

## Заключение

Golden tests — мощный инструмент для визуального регрессионного тестирования. Они помогают обнаруживать непреднамеренные изменения в UI и обеспечивают визуальную стабильность приложения. Однако их следует использовать с умом — только для кастомных виджетов и сложных компонентов.
