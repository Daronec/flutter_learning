---
tags:
  - storage
  - database
  - local
chapter: 10
section: 8
title: Кэширование — стратегии и реализация
alias: 10 08 caching
status: complete
---

# Кэширование — стратегии и реализация

Кэширование — это техника сохранения данных для быстрого повторного доступа. В мобильных приложениях кэширование улучшает производительность, снижает нагрузку на сеть и экономит трафик пользователя.

## Типы кэширования

| Тип | Описание | Пример |
|-----|----------|--------|
| Memory Cache | Данные в оперативной памяти | List\<T\> в памяти |
| Disk Cache | Данные на диске | SharedPreferences, файлы |
| Network Cache | Прокси-кэш | HTTP-кэш браузера |
| Image Cache | Кэш изображений | AssetImage, CachedNetworkImage |

## Стратегии кэширования

### Cache-First (сначала кэш)

```dart
class CacheFirstStrategy {
  final SharedPreferences _prefs;
  final Dio _dio;

  CacheFirstStrategy(this._prefs, this._dio);

  Future<dynamic> fetchData(String key, String url) async {
    // 1. Сначала проверяем кэш
    final cached = _prefs.getString(key);
    if (cached != null) {
      final data = jsonDecode(cached);
      // Можно добавить проверку актуальности кэша
      return data;
    }

    // 2. Если кэша нет — запрос к API
    try {
      final response = await _dio.get(url);
      // 3. Сохраняем в кэш
      _prefs.setString(key, jsonEncode(response.data));
      return response.data;
    } catch (e) {
      // 4. При ошибке возвращаем кэш или бросаем ошибку
      if (cached != null) {
        return jsonDecode(cached);
      }
      rethrow;
    }
  }
}
```

### Network-First (сначала сеть)

```dart
class NetworkFirstStrategy {
  final SharedPreferences _prefs;
  final Dio _dio;

  NetworkFirstStrategy(this._prefs, this._dio);

  Future<dynamic> fetchData(String key, String url) async {
    try {
      // 1. Сначала пробуем сеть
      final response = await _dio.get(url);
      // 2. Сохраняем в кэш
      _prefs.setString(key, jsonEncode(response.data));
      return response.data;
    } catch (e) {
      // 3. При ошибке — возвращаем кэш
      final cached = _prefs.getString(key);
      if (cached != null) {
        return jsonDecode(cached);
      }
      rethrow;
    }
  }
}
```

### Stale-While-Revalidate (устаревший + обновление)

```dart
class StaleWhileRevalidateStrategy {
  final SharedPreferences _prefs;
  final Dio _dio;

  StaleWhileRevalidateStrategy(this._prefs, this._dio);

  Future<dynamic> fetchData(String key, String url, {
    Duration maxAge = const Duration(minutes: 5),
  }) async {
    final cached = _prefs.getString(key);
    final timestamp = _prefs.getString('${key}_timestamp');

    // Если кэш есть и не истёк — возвращаем сразу
    if (cached != null && timestamp != null) {
      final age = DateTime.now().difference(DateTime.parse(timestamp));
      if (age < maxAge) {
        return jsonDecode(cached);
      }
    }

    // Фоновое обновление
    _fetchAndCache(key, url).catchError((_) {});

    // Возвращаем кэш (даже устаревший)
    if (cached != null) {
      return jsonDecode(cached);
    }

    // Если кэша нет — ждём сеть
    return await _fetchAndCache(key, url);
  }

  Future<dynamic> _fetchAndCache(String key, String url) async {
    final response = await _dio.get(url);
    _prefs.setString(key, jsonEncode(response.data));
    _prefs.setString('${key}_timestamp', DateTime.now().toIso8601String());
    return response.data;
  }
}
```

## Кэширование в Dio

### Встроенный HTTP-кэш

```dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

final dio = Dio();

dio.interceptors.add(
  DioCacheInterceptor(
    options: CacheOptions(
      store: MemCacheStore(), // Кэш в памяти
      policy: CachePolicy.forceCache, // Только кэш
      maxStale: const Duration(minutes: 5), // Макс. время хранения
      requestType: RequestType.cacheable, // Кэшировать GET
    ),
  ),
);

// Запрос будет кэшироваться автоматически
final response = await dio.get('/users');
```

### Различные политики кэширования

| Политика | Описание |
|----------|----------|
| `noCache` | Всегда запрос к серверу |
| `cacheFirst` | Сначала кэш, потом сервер |
| `serverFirst` | Сначала сервер, потом кэш |
| `forceCache` | Только кэш |
| `cacheOnly` | Только кэш (ошибка если нет) |
| `serverOnly` | Только сервер (ошибка если нет) |

```dart
// Использование разных политик
await dio.get(
  '/users',
  options: Options(
    extra: {
      'cache': CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.cacheFirst,
        maxStale: const Duration(hours: 1),
      ),
    },
  ),
);
```

## Кэширование изображений

### CachedNetworkImage

```yaml
dependencies:
  cached_network_image: ^3.3.0
```

```dart
import 'package:cached_network_image/cached_network_image.dart';

// Базовое использование
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
);

// С кастомным плейсхолдером
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  fit: BoxFit.cover,
  width: double.infinity,
  height: 200,
  placeholder: (context, url) => Container(
    color: Colors.grey[200],
    child: const Center(child: Text('Загрузка...')),
  ),
  errorWidget: (context, url, error) => Container(
    color: Colors.grey[200],
    child: const Center(child: Icon(Icons.broken_image)),
  ),
);

// Настройка кэша
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  cacheManager: CustomCacheManager(),
  fadeInDuration: const Duration(milliseconds: 300),
  fadeOutDuration: const Duration(milliseconds: 300),
);
```

### Кастомный CacheManager

```dart
class CustomCacheManager extends CacheManager {
  static const key = 'custom_cache';

  static final CustomCacheManager _instance =
      CustomCacheManager._internal();

  factory CustomCacheManager() => _instance;

  CustomCacheManager._internal()
      : super(CacheConfig(key, stalePeriod: const Duration(days: 7)));
}
```

## Память vs Диск

### Сравнение стратегий

| Характеристика | Memory Cache | Disk Cache |
|----------------|-------------|------------|
| Скорость | Мгновенная | Медленнее |
| Объём | Ограничен RAM | Ограничен хранилищем |
| Сохранение | Теряется при закрытии | Сохраняется |
| Использование | Активные данные | Часто используемые |
| Пример | List\<T\> | SharedPreferences, файлы |

### Гибридное кэширование

```dart
class HybridCache<T> {
  final Map<String, CacheEntry<T>> _memoryCache = {};
  final SharedPreferences _prefs;

  HybridCache(this._prefs);

  // Запись в кэш
  void put(String key, T data, {Duration ttl = const Duration(hours: 1)}) {
    // Memory cache
    _memoryCache[key] = CacheEntry(data: data, timestamp: DateTime.now(), ttl: ttl);

    // Disk cache
    _prefs.setString(key, jsonEncode(data));
  }

  // Чтение из кэша
  T? get(String key) {
    // Сначала memory cache
    final memory = _memoryCache[key];
    if (memory != null && !memory.isExpired) {
      return memory.data;
    }

    // Затем disk cache
    final disk = _prefs.getString(key);
    if (disk != null) {
      final data = jsonDecode(disk) as T;
      // Восстанавливаем в memory cache
      _memoryCache[key] = CacheEntry(
        data: data,
        timestamp: DateTime.now(),
        ttl: const Duration(hours: 1),
      );
      return data;
    }

    return null;
  }

  // Очистка
  void remove(String key) {
    _memoryCache.remove(key);
    _prefs.remove(key);
  }
}

class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired =>
      DateTime.now().difference(timestamp) > ttl;
}
```

## Инвалидация кэша

### По времени

```dart
// Кэш с временем жизни
class TimeBasedCache {
  final Map<String, CacheEntry> _cache = {};

  void put(String key, dynamic data, {Duration ttl = const Duration(minutes: 5)}) {
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
  }

  dynamic get(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data;
  }
}
```

### По событию

```dart
// Инвалидация при изменении данных
class EventBasedCache {
  final Map<String, dynamic> _cache = {};

  void put(String key, dynamic data) {
    _cache[key] = data;
  }

  dynamic get(String key) => _cache[key];

  // Инвалидация конкретного ключа
  void invalidate(String key) {
    _cache.remove(key);
  }

  // Инвалидация по префиксу
  void invalidatePrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  // Полная очистка
  void clear() => _cache.clear();
}
```

## Best Practices

- **Используйте cache-first для чтения** — быстрее, экономит трафик
- **Используйте network-first для записи** — актуальные данные
- **Устанавливайте TTL** — кэш должен инвалидироваться
- **Кэшируйте изображения** — используйте `cached_network_image`
- **Очищайте кэш** — не позволяйте ему расти бесконечно
- **Показывайте кэшированные данные** — пока идёт загрузка с сервера
- **Используйте гибридный подход** — memory + disk для максимальной скорости
