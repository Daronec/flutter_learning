---
tags:
  - performance
  - optimization
chapter: 14
section: 5
title: 14-05. Image Optimization — Сжатие и формат изображений
alias: 14 05 image optimization
status: complete
---

# 14-05. Image Optimization — Сжатие и формат изображений

## Введение

Изображения часто являются основным потребителем памяти и полосы пропускания в мобильных приложениях. Оптимизация изображений — это один из самых эффективных способов улучшить производительность и уменьшить размер приложения.

## Форматы изображений

### Сравнение форматов

| Формат | Сжатие | Прозрачность | Анимация | Поддержка |
|--------|--------|-------------|----------|-----------|
| PNG | Без потерь | Да | Нет | Все платформы |
| JPEG | С потерями | Нет | Нет | Все платформы |
| WebP | Без/с потерями | Да | Да | Android 4.2+, iOS 14.2+, macOS 10.14.4+ |
| AVIF | Без/с потерями | Да | Да | Android 11+, iOS 16.4+ |
| GIF | С потерями | Да | Да | Все платформы |

### WebP — рекомендуемый формат

WebP — это современный формат от Google, который обеспечивает лучшее сжатие при том же качестве:

```
JPEG:   100 KB
WebP:   65 KB  (на 35% меньше)
PNG:    200 KB
WebP:   80 KB  (на 60% меньше)
```

### Конвертация изображений в WebP

```bash
# Использование cwebp (инструмент от Google)
cwebp -q 80 input.png -o output.webp

# batch конвертация
for f in *.png; do cwebp -q 80 "$f" -o "${f%.png}.webp"; done
```

## BoxFit — управление размерами изображений

### Что такое BoxFit

`BoxFit` определяет, как изображение заполняет контейнер:

| Значение | Описание |
|----------|----------|
| `fill` | Растягивает изображение на весь контейнер (искажает пропорции) |
| `contain` | Показывает всё изображение в контейнере (может быть пустое пространство) |
| `cover` | Заполняет контейнер, сохраняя пропорции (может обрезать) |
| `fitWidth` | Растягивает по ширине, пропорционально по высоте |
| `fitHeight` | Растягивает по высоте, пропорционально по ширине |
| `none` | Изображение без изменений |
| `scaleDown` | Как `contain`, но может уменьшить изображение |

### Примеры использования

```dart
// contain — всё изображение видно
Image.asset(
  'assets/images/photo.png',
  fit: BoxFit.contain,
  width: 200,
  height: 200,
);

// cover — заполняет контейнер, обрезая лишнее
Image.asset(
  'assets/images/photo.png',
  fit: BoxFit.cover,
  width: 200,
  height: 200,
);

// fitWidth — по ширине контейнера
Image.asset(
  'assets/images/photo.png',
  fit: BoxFit.fitWidth,
  width: 200,
  height: 100,
);

// fitHeight — по высоте контейнера
Image.asset(
  'assets/images/photo.png',
  fit: BoxFit.fitHeight,
  width: 200,
  height: 100,
);

// none — оригинальный размер
Image.asset(
  'assets/images/photo.png',
  fit: BoxFit.none,
);
```

### CachedNetworkImage с BoxFit

```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  fit: BoxFit.cover,
  width: double.infinity,
  height: 200,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
);
```

## CachedNetworkImage

### Установка

```yaml
dependencies:
  cached_network_image: ^3.3.1
```

### Базовое использование

```dart
class NetworkImageExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: 'https://example.com/image.jpg',
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      fit: BoxFit.cover,
    );
  }
}
```

### Настройка кэширования

```dart
void main() {
  // Глобальная настройка кэша
  CachedNetworkImage.logLevel = Log.error;
  CachedNetworkImage.log = (message) {
    debugPrint(message);
  };

  runApp(const MyApp());
}

// Настройка кэша для конкретного изображения
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  cacheManager: CustomCacheManager(),
  fadeInDuration: const Duration(milliseconds: 300),
  fadeOutDuration: const Duration(milliseconds: 300),
  maxWidthDiskCache: 1000,
  maxHeightDiskCache: 1000,
);
```

### Кастомный CacheManager

```dart
class CustomCacheManager extends CacheManager {
  static const key = 'custom_cache';

  static final CustomCacheManager _instance = CustomCacheManager._();

  factory CustomCacheManager() => _instance;

  CustomCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 7),
            maxNrOfCacheObjects: 200,
            repo: JsonCacheInfoRepository(databaseName: key),
            fileService: HttpFileService(),
          ),
        );
}

// Использование кастомного CacheManager
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  cacheManager: CustomCacheManager(),
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
);
```

### FadeIn анимация

```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  fadeInDuration: const Duration(milliseconds: 500),
  fadeOutDuration: const Duration(milliseconds: 300),
  fadeInCurve: Curves.easeIn,
  fadeOutCurve: Curves.easeOut,
  placeholder: (context, url) => Container(
    color: Colors.grey[200],
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  ),
  errorWidget: (context, url, error) => Container(
    color: Colors.grey[200],
    child: const Center(
      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
    ),
  ),
);
```

### ImageProvider для кастомной логики

```dart
class ResizedNetworkImage extends ImageProvider<ResizedNetworkImage> {
  final String url;
  final int width;
  final int height;

  const ResizedNetworkImage({
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  Future<ResizedNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ResizedNetworkImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    ResizedNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>(
          'ResizedNetworkImage: $url ($width x $height)',
          this,
        );
      },
    );
  }

  Future<Codec> _loadAsync(
    ResizedNetworkImage key,
    ImageDecoderCallback decode,
  ) async {
    final bytes = await NetworkAssetBundle(Uri.parse(url)).load('');
    // Здесь можно добавить логику ресайза
    return decode(await instantiateImageCodec(bytes.buffer.asUint8List()));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResizedNetworkImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(url, width, height);
}
```

## Оптимизация загрузки изображений

### Загрузка изображений нужного размера

```dart
// Загрузка изображения нужного размера с сервера
class OptimizedImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double? scale;

  const OptimizedImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.scale,
  });

  String get _optimizedUrl {
    final devicePixelRatio = scale ?? MediaQuery.of(context).devicePixelRatio;
    final intWidth = (width * devicePixelRatio).toInt();
    final intHeight = (height * devicePixelRatio).toInt();
    // Добавляем параметры для серверной оптимизации
    return '$url?width=$intWidth&height=$intHeight&quality=80';
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: _optimizedUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.error)),
      ),
    );
  }
}
```

### Превью изображений

```dart
class ThumbnailGrid extends StatelessWidget {
  final List<String> imageUrls;

  const ThumbnailGrid({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: imageUrls[index],
          fit: BoxFit.cover,
          // Маленькие размеры для превью
          maxWidthDiskCache: 200,
          maxHeightDiskCache: 200,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image),
          ),
        );
      },
    );
  }
}
```

## Best Practices

### Рекомендации по оптимизации изображений

1. **Используйте WebP вместо PNG/JPEG** — на 25-35% меньше размер
2. **Загружайте изображения нужного размера** — не загружайте 4K для превью
3. **Используйте CachedNetworkImage** — кэширование значительно ускоряет повторную загрузку
4. **Устанавливайте `maxWidthDiskCache` и `maxHeightDiskCache`** — ограничивает размер кэша
5. **Используйте `fit` правильно** — избегайте `fill`, который искажает пропорции
6. **Добавляйте placeholder и errorWidget** — улучшает UX
7. **Сжимайте изображения перед загрузкой** — используйте инструменты сжатия

### Инструменты для оптимизации изображений

| Инструмент | Назначение |
|------------|-----------|
| Squoosh | Онлайн-оптимизация изображений |
| ImageOptim | macOS-приложение для сжатия |
| TinyPNG | Сжатие PNG и JPEG |
| cwebp | Конвертация в WebP |
| Sharp | Node.js библиотека для обработки |

### Чек-лист оптимизации изображений

- [ ] Все изображения в формате WebP
- [ ] Изображения загружаются нужного размера
- [ ] Используется CachedNetworkImage
- [ ] Установлены ограничения кэша (maxWidthDiskCache, maxHeightDiskCache)
- [ ] Есть placeholder и errorWidget
- [ ] Используется правильный BoxFit
- [ ] Изображения сжаты перед загрузкой

## Заключение

Оптимизация изображений — это критически важная часть производительности Flutter-приложений. Правильный выбор формата, размера и кэширования позволяет значительно улучшить как скорость загрузки, так и потребление памяти.
