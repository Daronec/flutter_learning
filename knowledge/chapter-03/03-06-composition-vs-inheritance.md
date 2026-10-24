---
tags:
  - widgets
  - architecture
chapter: 3
section: 6
title: Composition vs Inheritance — паттерн компоновки
alias: 03 06 composition vs inheritance
status: complete
---

# 3.6 Composition vs Inheritance — паттерн компоновки

## Composition (компоновка) в Flutter

### Основной паттерн Flutter

Flutter построен на паттерне **Composition over Inheritance** — вместо наследования виджетов, мы комбинируем (compose) существующие виджеты.

### Принцип

```dart
// ❌ Наследование (не рекомендуется)
class MyButton extends Button {
  @override
  Widget build() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text('Click me'),
    );
  }
}

// ✅ Компоновка (рекомендуется)
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(16),
    child: ElevatedButton(
      onPressed: () {},
      child: Text('Click me'),
    ),
  );
}
```

## Почему Composition лучше?

### Преимущества Composition

| Aspect | Inheritance | Composition |
|---|---|---|
| **Гибкость** | Ограничено одним родителем | Неограниченная комбинация |
| **Переиспользование** | Дублирование кода | Компоненты вкладываются |
| **Тестирование** | Сложно | Легко (модульные компоненты) |
| **Изменение** | Риск сломать наследников | Безопасно |
| **Размер** | Раздувание класса | Компактные виджеты |

### Пример: кастомная кнопка

```dart
// Composition — создаём из готовых блоков
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const CustomButton({
    required this.label,
    required this.onPressed,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
```

## Паттерн обёртки (Wrapper Pattern)

### Обёртка виджетов

```dart
// Обёртка для добавления отступа
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(16),
    child: Card(
      child: Column(
        children: [
          Text('Header'),
          Divider(),
          Text('Content'),
        ],
      ),
    ),
  );
}
```

### Обёртка для обработки ошибок

```dart
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget Function(Exception error) errorBuilder;
  
  const ErrorBoundary({
    required this.child,
    required this.errorBuilder,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    try {
      return child;
    } catch (error) {
      return errorBuilder(error);
    }
  }
}
```

## Композиция с параметрами

### Передача параметров через обёртку

```dart
class SectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const SectionWidget({
    required this.title,
    required this.children,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

// Использование
SectionWidget(
  title: 'User Profile',
  children: [
    Text('Name: Alice'),
    Text('Email: alice@example.com'),
  ],
);
```

## Builder Pattern

### Builder для кастомизации

```dart
class LoadingWidget extends StatelessWidget {
  final Widget Function(BuildContext context, double progress) builder;
  final double progress;
  
  const LoadingWidget({
    required this.builder,
    this.progress = 0.5,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return builder(context, progress);
  }
}

// Использование
LoadingWidget(
  progress: 0.75,
  builder: (context, progress) {
    return Column(
      children: [
        CircularProgressIndicator(value: progress),
        Text('${(progress * 100).toInt()}%'),
      ],
    );
  },
);
```

## Composite Widget

### Виджет-контейнер

```dart
class ProfileCard extends StatelessWidget {
  final User user;
  
  const ProfileCard({required this.user, super.key});
  
  @override
  Widget build(BuildContext context) {
    // Композиция из нескольких виджетов
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(user.email),
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

## Composition vs Inheritance — примеры

### Сложный пример: карточка товара

```dart
// ❌ Наследование (плохо)
class ProductCardWithDiscount extends ProductCard {
  final double discount;
  
  @override
  Widget build() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.red)),
      child: super.build(),
    );
  }
}

// ✅ Composition (хорошо)
class ProductCard extends StatelessWidget {
  final Product product;
  final double? discount;
  
  const ProductCard({required this.product, this.discount, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          child: Column(
            children: [
              Image.network(product.imageUrl),
              Text(product.name),
              Text('\$${product.price}'),
            ],
          ),
        ),
        if (discount != null)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
              child: Text('-${(discount! * 100).toInt()}%'),
            ),
          ),
      ],
    );
  }
}
```

## Лучшие практики

### 1. Создавайте маленькие переиспользуемые виджеты

```dart
// Маленький, сфокусированный виджет
class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  
  const UserAvatar({required this.imageUrl, this.size = 40, super.key});
  
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: NetworkImage(imageUrl),
      radius: size / 2,
    );
  }
}
```

### 2. Используйте children для гибкости

```dart
class CollapsibleSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;
  
  // children позволяет вставлять любые виджеты
}
```

### 3. Выносите логику в отдельные виджеты

```dart
// Разделяйте на логические компоненты
class OrderSummary extends StatelessWidget {
  final Order order;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrderItems(items: order.items),
        OrderTotals(totals: order.totals),
        OrderActions(order: order),
      ],
    );
  }
}
```

## Заключение

Composition — основной паттерн в Flutter:
- **Комбинируйте** существующие виджеты вместо наследования
- **Создавайте** маленькие, переиспользуемые компоненты
- **Используйте** children и builder для гибкости
- **Разделяйте** сложную логику на отдельные виджеты

Помните: в Flutter виджеты — это конфигурации, а не UI-объекты. Компоновка — естественный способ создания UI.
