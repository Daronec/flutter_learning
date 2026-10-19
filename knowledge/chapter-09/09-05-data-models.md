# Модель данных: создание DTO и моделей

Модели данных — это классы, представляющие структуру данных вашего приложения. Правильная организация моделей упрощает работу с данными, улучшает читаемость и облегчает тестирование.

## Зачем нужны модели данных?

| Без моделей | С моделями |
|-------------|-----------|
| Сырой JSON повсюду | Структурированные объекты |
| Нет проверки типов | Статическая типизация |
| Сложно поддерживать | Легко расширять |
| Ошибки обнаруживаются поздно | Ошибки на этапе компиляции |

## DTO (Data Transfer Object)

DTO — это объект, предназначенный для передачи данных между слоями приложения или между клиентом и сервером.

### Простой DTO

```dart
class UserDto {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Сравнение объектов
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Строковое представление
  @override
  String toString() => 'UserDto(id: $id, name: $name, email: $email)';
}
```

### DTO с вложенными данными

```dart
class CommentDto {
  final int id;
  final String text;
  final DateTime createdAt;

  CommentDto({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      id: json['id'] as int,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'created_at': createdAt.toIso8601String(),
      };
}

class PostDto {
  final int id;
  final String title;
  final String content;
  final List<CommentDto> comments;

  PostDto({
    required this.id,
    required this.title,
    required this.content,
    required this.comments,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) {
    return PostDto(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      comments: (json['comments'] as List<dynamic>)
          .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'comments': comments.map((c) => c.toJson()).toList(),
      };
}
```

## DTO vs Domain Models

DTO — это объекты для передачи данных (обычно соответствуют структуре API). Domain Model — это объекты бизнес-логики приложения.

### Разделение DTO и Domain моделей

```dart
// DTO — соответствует структуре API
class UserApiResponse {
  final int id;
  final String name;
  final String email;
  final String role; // «admin», «user»
  final List<String> permissions;

  UserApiResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
  });

  factory UserApiResponse.fromJson(Map<String, dynamic> json) {
    return UserApiResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      permissions: List<String>.from(json['permissions'] as List),
    );
  }
}

// Domain Model — объекты бизнес-логики
class User {
  final int id;
  final String name;
  final String email;
  final bool isAdmin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
  });

  // Преобразование из DTO в Domain модель
  factory User.fromApiResponse(UserApiResponse apiResponse) {
    return User(
      id: apiResponse.id,
      name: apiResponse.name,
      email: apiResponse.email,
      isAdmin: apiResponse.role == 'admin',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

### Слой преобразования

```dart
class UserMapper {
  // API → Domain
  static User fromApiResponse(UserApiResponse api) {
    return User(
      id: api.id,
      name: api.name,
      email: api.email,
      isAdmin: api.role == 'admin',
    );
  }

  // Domain → DTO для отправки на сервер
  static UserApiResponse toApiResponse(User user) {
    return UserApiResponse(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.isAdmin ? 'admin' : 'user',
      permissions: user.isAdmin ? ['all'] : ['read'],
    );
  }
}
```

## Паттерны для моделей данных

### Неизменяемые модели

```dart
// Все поля final — модель нельзя изменить после создания
class Product {
  final int id;
  final String name;
  final double price;
  final String currency;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.currency = 'RUB',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'RUB',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'currency': currency,
      };
}
```

### Модели с методами

```dart
class Order {
  final int id;
  final List<OrderItem> items;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.createdAt,
  });

  double get total => items.fold(0, (sum, item) => sum + item.total);

  int get itemCount => items.length;

  bool get isEmpty => items.isEmpty;

  bool get isExpensive => total > 10000;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
}
```

## Best Practices

- **Делайте модели неизменяемыми** — используйте `final` для всех полей
- **Разделяйте DTO и Domain модели** — не смешивайте структуру API с бизнес-логикой
- **Добавляйте `==` и `hashCode`** — для корректного сравнения объектов
- **Используйте `from*` factory-конструкторы** — для преобразования из JSON
- **Добавляйте методы вычисления** — `total`, `isEmpty` и т.д. прямо в модели
- **Используйте mapper-классы** — для преобразования между DTO и Domain моделями
