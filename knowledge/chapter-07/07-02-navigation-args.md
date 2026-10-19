# Аргументы навигации: передача данных между экранами

Передача данных между экранами — одна из ключевых задач при навигации в Flutter. Различают передачу аргументов при переходе (push) и возврат значений при возврате (pop).

## Передача аргументов через push

### Простая передача через arguments

Свойство `arguments` маршрута позволяет передать данные любому типу:

```dart
// Отправка аргумента
Navigator.pushNamed(
  context,
  '/product',
  arguments: 'product-123',
);

// Получение аргумента на целевом экране
class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Извлекаем аргументы из контекста
    final String productId =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text('Product: $productId')),
      body: Center(child: Text('ID товара: $productId')),
    );
  }
}
```

### Передача через MaterialPageRoute

```dart
// Отправка аргументов
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ProductScreen(),
    settings: RouteSettings(
      arguments: ProductModel(id: 1, name: 'Laptop'),
    ),
  ),
);

// Получение аргументов
class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProductModel? product =
        ModalRoute.of(context)?.settings.arguments as ProductModel?;

    if (product == null) {
      return const Scaffold(body: Text('Товар не найден'));
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Center(child: Text('ID: ${product.id}')),
    );
  }
}
```

### Передача через onGenerateRoute

```dart
MaterialApp(
  onGenerateRoute: (settings) {
    switch (settings.name) {
      case '/product':
        final ProductModel product =
            settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        );
      case '/user':
        final UserModel user = settings.arguments as UserModel;
        return MaterialPageRoute(
          builder: (_) => UserDetailScreen(user: user),
        );
      default:
        return null;
    }
  },
);
```

## Generic аргументы

### Типизированная передача аргументов

Navigator поддерживает дженерики для безопасной передачи данных:

```dart
// Отправка аргумента с типом
final result = await Navigator.push<ProductModel>(
  context,
  MaterialPageRoute(
    builder: (context) => const ProductSelectorScreen(),
  ),
);

// result имеет тип ProductModel?
if (result != null) {
  print('Выбран: ${result.name}');
}
```

### Передача сложных объектов

```dart
// Модель данных
class ProductModel {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  // Сериализация в JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
      };

  // Десериализация из JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

// Отправка через JSON
Navigator.pushNamed(
  context,
  '/product',
  arguments: ProductModel(
    id: 1,
    name: 'Laptop',
    price: 999.99,
  ).toJson(),
);

// Получение и десериализация
class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> json =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final product = ProductModel.fromJson(json);

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Text('Цена: \$${product.price}'),
    );
  }
}
```

## Возврат значений через pop

### Возврат примитивных типов

```dart
// Экран, который возвращает значение
class ColorPickerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выберите цвет')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, Colors.red);
              },
              child: const Text('Красный'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, Colors.green);
              },
              child: const Text('Зелёный'),
            ),
            ElevatedButton(##
              onPressed: () {
                // Отмена — возврат без значения
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
          ],
        ),
      ),
    );
  }
}

// Экран, который получает значение
class ColorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Цветной экран')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Ожидаем результат от ColorPickerScreen
            final Color? selectedColor = await Navigator.push<Color?>(
              context,
              MaterialPageRoute(
                builder: (context) => const ColorPickerScreen(),
              ),
            );

            if (selectedColor != null) {
              // Используем выбранный цвет
              print('Выбран цвет: $selectedColor');
            }
          },
          child: const Text('Выбрать цвет'),
        ),
      ),
    );
  }
}
```

### Возврат сложных объектов

```dart
// Возврат модели данных
class EditUserScreen extends StatelessWidget {
  final UserModel user;

  const EditUserScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController),
            const SizedBox(height: 8),
            TextField(controller: emailController),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Создаём обновлённый объект
                final updatedUser = UserModel(
                  id: user.id,
                  name: nameController.text,
                  email: emailController.text,
                );
                // Возвращаем обновлённый объект
                Navigator.pop(context, updatedUser);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}

// Использование результата
final UserModel? updatedUser = await Navigator.push<UserModel?>(
  context,
  MaterialPageRoute(
    builder: (context) => EditUserScreen(user: currentUser),
  ),
);

if (updatedUser != null) {
  // Обновляем данные
  currentUser = updatedUser;
}
```

## Сравнение подходов

| Подход | Тип данных | Безопасность | Сложность |
|---|---|---|---|
| `arguments` (строка) | String | Низкая | Низкая |
| `arguments` (JSON) | Map<String, dynamic> | Средняя | Средняя |
| `arguments` (объект) | Любой тип | Высокая | Средняя |
| Generic `push<T>` | Типизированный | Высокая | Низкая |
| `onGenerateRoute` | Любой тип | Высокая | Высокая |

## Best Practices

1. **Используйте JSON-сериализацию** для сложных объектов — это упрощает передачу через `arguments`.
2. **Всегда проверяйте null** при получении аргументов — аргументы могут отсутствовать.
3. **Используйте дженерики** `push<T>` для типизированной передачи возвращаемых значений.
4. **Избегайте передачи больших объектов** — предпочтительнее передавать идентификаторы и загружать данные по запросу.
5. **Создавайте модели данных** с методами `toJson()` и `fromJson()` для удобной сериализации.
6. **Используйте `ModalRoute.of(context)!.settings.arguments`** для получения аргументов в любом месте экрана.
7. **Не передавайте через аргументы** объекты с контроллерами, контекстами или ресурсами.
8. **Для передачи множества параметров** создайте отдельный класс-обёртку:

```dart
class ProductNavigationArgs {
  final String productId;
  final bool showReviews;
  final bool showRecommendations;

  const ProductNavigationArgs({
    required this.productId,
    this.showReviews = false,
    this.showRecommendations = false,
  });
}
```
