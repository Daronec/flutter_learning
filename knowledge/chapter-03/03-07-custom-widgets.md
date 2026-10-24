---
tags:
  - widgets
  - architecture
chapter: 3
section: 7
title: Кастомные виджеты: создание и переиспользование
alias: 03 07 custom widgets
status: complete
---

# 3.7 Кастомные виджеты: создание и переиспользование

## Создание кастомного виджета

### StatelessWidget

```dart
class ProfileHeader extends StatelessWidget {
  final String name;
  final String bio;
  final String avatarUrl;
  
  const ProfileHeader({
    required this.name,
    required this.bio,
    required this.avatarUrl,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(avatarUrl),
          radius: 50,
        ),
        SizedBox(height: 8),
        Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(bio, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
```

### StatefulWidget

```dart
class RatingWidget extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onRatingChanged;
  
  const RatingWidget({
    required this.initialRating,
    required this.onRatingChanged,
    super.key,
  });
  
  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int _rating = 0;
  
  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() => _rating = index + 1);
            widget.onRatingChanged(_rating);
          },
        );
      }),
    );
  }
}
```

## Паттерны создания кастомных виджетов

### 1. Parameterized Widget

```dart
class BadgeWidget extends StatelessWidget {
  final String label;
  final Color color;
  
  const BadgeWidget({
    required this.label,
    this.color = Colors.red,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
```

### 2. Composite Widget

```dart
class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final VoidCallback onTap;
  
  const ProductCard({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.onTap,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(imageUrl, height: 150, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('\$$price', style: TextStyle(color: Colors.green)),
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

### 3. Builder Widget

```dart
class LoadingContainer extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  
  const LoadingContainer({
    required this.child,
    required this.isLoading,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return child;
  }
}

// Использование
LoadingContainer(
  isLoading: _isLoading,
  child: ListView(...),
);
```

## Переиспользование виджетов

### Организация кода

```
lib/
├── widgets/
│   ├── buttons/
│   │   ├── primary_button.dart
│   │   └── secondary_button.dart
│   ├── forms/
│   │   ├── text_field.dart
│   │   └── dropdown.dart
│   ├── cards/
│   │   ├── product_card.dart
│   │   └── user_card.dart
│   └── shared/
│       ├── loading_indicator.dart
│       └── error_view.dart
└── main.dart
```

### Export файл

```dart
// widgets/widgets.dart
export 'buttons/primary_button.dart';
export 'buttons/secondary_button.dart';
export 'forms/text_field.dart';
export 'cards/product_card.dart';
export 'shared/loading_indicator.dart';
```

### Импорт

```dart
import 'package:my_app/widgets/widgets.dart';

// Использование
PrimaryButton(onPressed: () {}, label: 'Submit');
```

## Best Practices

### 1. Используйте const конструкторы

```dart
class MyWidget extends StatelessWidget {
  final String text;
  
  const MyWidget({required this.text, super.key}); // const
  
  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
```

### 2. Именованные именованные параметры

```dart
const MyWidget({
  required this.text,
  this.color = Colors.black,
  this.fontSize = 16.0,
  super.key,
});
```

### 3. Документируйте виджеты

```dart
/// Кастомная кнопка с поддержкой иконок.
///
/// [label] — текст кнопки (обязательно).
/// [onPressed] — колбэк при нажатии (обязательно).
/// [icon] — опциональная иконка.
class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  
  const ActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: icon != null
          ? Row(children: [Icon(icon), SizedBox(width: 8), Text(label)])
          : Text(label),
    );
  }
}
```

### 4. Разделяйте сложную логику

```dart
// ❌ Слишком большой виджет
class TooBigWidget extends StatelessWidget {
  // 20 параметров, 200 строк build()
}

// ✅ Разделённые виджеты
class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OrderHeader(order: order),
        OrderItems(items: order.items),
        OrderSummary(summary: order.summary),
        OrderActions(order: order),
      ],
    );
  }
}
```

### 5. Используйте ключи (Keys)

```dart
// Для динамических списков
ListView.builder(
  itemBuilder: (context, index) {
    return Dismissible(
      key: Key('item-$index'), // ключ для идентификации
      onDismissed: (direction) => removeItem(index),
      child: ItemWidget(item: items[index]),
    );
  },
)
```

## Заключение

Создание кастомных виджетов — основа разработки в Flutter:
- **Компонуруйте** из существующих виджетов
- **Используйте** const конструкторы
- **Документируйте** публичные API
- **Разделяйте** сложную логику на мелкие виджеты
- **Организуйте** виджеты по папкам

Хороший кастомный виджет — это маленький, сфокусированный, переиспользуемый компонент с чётким API.
