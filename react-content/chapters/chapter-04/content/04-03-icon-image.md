# Icon, Image — иконки и изображения

## Введение

Иконки и изображения — неотъемлемая часть любого пользовательского интерфейса. Flutter предоставляет удобные виджеты для работы с обоими типами контента.

## Icon

Виджет `Icon` отображает иконки из заданного шрифта.

### Основные свойства Icon

| Свойство | Тип | Описание |
|----------|-----|----------|
| `icon` | `IconData` | Иконка для отображения |
| `size` | `double?` | Размер иконки |
| `color` | `Color?` | Цвет иконки |
| `semanticLabel` | `String?` | Метка для доступности |
| `textDirection` | `TextDirection?` | Направление текста |

### Класс Icons

Класс `Icons` содержит тысячи иконок из Google Material Icons:

```dart
// Основные иконки
Icon(Icons.home)
Icon(Icons.search)
Icon(Icons.settings)
Icon(Icons.favorite)
Icon(Icons.arrow_back)
Icon(Icons.add)
Icon(Icons.delete)
Icon(Icons.edit)
Icon(Icons.check)
Icon(Icons.close)
```

### Примеры использования Icon

```dart
// Простая иконка
const Icon(Icons.star, size: 32)

// Иконка с цветом
const Icon(Icons.favorite, color: Colors.red, size: 24)

// Иконка в строке заголовка
Row(
  children: [
    const Icon(Icons.menu),
    const SizedBox(width: 8),
    const Text('Меню'),
  ],
)

// Иконка с меткой для доступности
Icon(
  Icons.close,
  semanticLabel: 'Закрыть',
)
```

### Поиск иконок

Все иконки доступны через `Icons` класс. Список можно найти в [Material Icons](https://fonts.google.com/icons).

```dart
// Популярные группы иконок
// Навигация: menu, arrow_back, arrow_forward, chevron_left
// Действия: add, delete, edit, share, download, upload
// Сообщения: chat, mail, notification_important
// Соцсети: facebook, twitter, instagram, youtube
// Природа: nature, thunderstorm,wb_sunny
```

## Image

Виджет `Image` отображает изображения из различных источников.

### Источники изображений

| Конструктор | Источник |
|-------------|----------|
| `Image.asset()` | Ресурсы приложения |
| `Image.network()` | URL в интернете |
| `Image.memory()` | Байтовый массив |
| `Image.file()` | Файл на устройстве |

### Image.asset — Ресурсы приложения

Для использования изображений из ресурсов нужно:

1. Создать папку `assets/images/` в корне проекта
2. Добавить в `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```

```dart
// Базовое изображение из ресурсов
Image.asset('assets/images/logo.png')

// С размером
Image.asset(
  'assets/images/photo.jpg',
  width: 200,
  height: 200,
)

// С обработкой ошибок
Image.asset(
  'assets/images/logo.png',
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.broken_image, size: 48);
  },
)
```

### Image.network — Изображения из интернета

```dart
Image.network(
  'https://example.com/photo.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  // Заголовок для кэширования
  headers: {'Authorization': 'Bearer token'},
  // Обработчик ошибок
  errorBuilder: (context, error, stackTrace) {
    return const Icon(Icons.error, size: 48);
  },
  // Прогресс-бар
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
)
```

### Image.memory — Байтовый массив

```dart
// Загрузка изображения из Uint8List
FutureBuilder<Uint8List>(
  future: loadImageBytes(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return Image.memory(snapshot.data!);
    }
    return const CircularProgressIndicator();
  },
)
```

### Image.file — Файл на устройстве

```dart
// Загрузка изображения из файла
FutureBuilder<File?>(
  future: pickImageFile(),
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      return Image.file(snapshot.data!);
    }
    return const Text('Нет изображения');
  },
)
```

## BoxFit — Масштабирование изображений

Свойство `fit` определяет, как изображение вписывается в заданные размеры.

| Значение | Описание |
|----------|----------|
| `BoxFit.fill` | Растянуть на всю область |
| `BoxFit.contain` | Вписать целиком (с пустыми областями) |
| `BoxFit.cover` | Заполнить целиком (с обрезкой) |
| `BoxFit.fitWidth` | По ширине |
| `BoxFit.fitHeight` | По высоте |
| `BoxFit.none` | Без масштабирования |
| `BoxFit.scaleDown` | Уменьшить, если больше контейнера |

```dart
// Заполнение с обрезкой (для фоновых изображений)
Image.asset(
  'assets/images/hero.jpg',
  width: double.infinity,
  height: 200,
  fit: BoxFit.cover,
)

// Вписать целиком (для аватаров)
Image.asset(
  'assets/images/avatar.png',
  width: 80,
  height: 80,
  fit: BoxFit.contain,
)
```

## CachedNetworkImage

Для загрузки изображений из сети с кэшированием используется пакет `cached_network_image`:

```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.3.1
```

```dart
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: 'https://example.com/photo.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.cover,
  // Плейсхолдер при загрузке
  placeholder: (context, url) => const Center(
    child: CircularProgressIndicator(),
  ),
  // Обработчик ошибок
  errorWidget: (context, url, error) => const Icon(Icons.error),
  // Кэш мемори
  memCacheWidth: 400,
  memCacheHeight: 300,
)
```

### Преимущества CachedNetworkImage

- Автоматическое кэширование в память и на диск
- Управление размером кэша (`memCacheWidth/Height`)
- Простая настройка плейсхолдеров и ошибок
- Поддержка параллельных загрузок

## Best Practices

1. **Всегда указывайте размеры** для изображений, если это возможно — это помогает Flutter оптимизировать рендеринг:
   ```dart
   Image.asset(
     'assets/images/photo.jpg',
     width: 200,
     height: 150,
   )
   ```

2. **Используйте `BoxFit.cover`** для изображений, которые должны заполнить область, и `BoxFit.contain` — для тех, что должны быть видны целиком.

3. **Всегда добавляйте `errorBuilder`** для сетевых изображений:
   ```dart
   Image.network(
     url,
     errorBuilder: (context, error, stackTrace) {
       return const Icon(Icons.broken_image);
     },
   )
   ```

4. **Используйте `CachedNetworkImage`** для всех сетевых изображений в списках — это значительно улучшает производительность.

5. **Оптимизируйте размеры изображений** — используйте сжатые форматы (WebP) и соответствующее разрешение для целевых экранов.

6. **Используйте `preload`** для критически важных изображений:
   ```dart
   precacheImage(
     const AssetImage('assets/images/logo.png'),
     context,
   )
   ```

7. **Используйте `ImageFiltered`** для эффектов (размытие, инверсия и т.д.):
   ```dart
   ImageFiltered(
     imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
     child: Image.asset('assets/images/background.jpg'),
   )
   ```
