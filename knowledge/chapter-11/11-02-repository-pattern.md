# Repository Pattern в Flutter

## Введение

Repository Pattern — это паттерн проектирования, который создаёт абстракцию над источниками данных. Он скрывает детали получения данных (сеть, локальное хранилище, кэш) и предоставляет единый интерфейс для бизнес-логики.

## Зачем нужен Repository Pattern

- **Единый интерфейс** для разных источников данных
- **Кэширование** — решение о том, откуда брать данные, внутри репозитория
- **Тестируемость** — можно мокать репозиторий в тестах
- **Разделение ответственности** — бизнес-логика не знает о сети или БД

## Базовая реализация

### Абстрактный репозиторий

```dart
// domain/repositories/product_repository.dart
import 'package:fpdart/fpdart.dart';
import '../../entities/product.dart';
import '../../failures/failure.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts();
  Future<Either<Failure, Product>> getProductById(String id);
  Future<Either<Failure, Unit>> createProduct(Product product);
  Future<Either<Failure, Unit>> updateProduct(Product product);
  Future<Either<Failure, Unit>> deleteProduct(String id);
}
```

### Реализация с кэшированием

```dart
// data/repositories/product_repository_impl.dart
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/failures/failure.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remote;
  final ProductLocalDatasource local;

  ProductRepositoryImpl({
    required this.remote,
    required this.local,
  });

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    // Сначала пробуем получить из кэша
    final cached = await local.getCachedProducts();
    if (cached.isNotEmpty) {
      return Right(cached);
    }

    // Если кэш пустой — загружаем из сети
    try {
      final products = await remote.fetchAllProducts();
      // Сохраняем в кэш
      await local.cacheProducts(products);
      return Right(products);
    } on ServerException catch (e) {
      // При ошибке сети возвращаем кэш
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    // Сначала проверяем кэш
    final cached = await local.getCachedProduct(id);
    if (cached != null) {
      return Right(cached);
    }

    try {
      final product = await remote.fetchProductById(id);
      await local.cacheProduct(product);
      return Right(product);
    } on ServerException catch (e) {
      if (cached != null) {
        return Right(cached);
      }
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> createProduct(Product product) async {
    try {
      await remote.createProduct(product);
      // Инвалидируем кэш после создания
      await local.invalidateCache();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProduct(Product product) async {
    try {
      await remote.updateProduct(product);
      // Обновляем кэш
      await local.cacheProduct(product);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(String id) async {
    try {
      await remote.deleteProduct(id);
      // Удаляем из кэша
      await local.removeCachedProduct(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

## DataSource Pattern

Репозиторий использует DataSource для работы с каждым источником:

```dart
// data/datasources/product_remote_datasource.dart
abstract class ProductRemoteDatasource {
  Future<List<Product>> fetchAllProducts();
  Future<Product> fetchProductById(String id);
  Future<void> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}

class ProductRemoteDatasourceImpl implements ProductRemoteDatasource {
  final Dio client;

  ProductRemoteDatasourceImpl({required this.client});

  @override
  Future<List<Product>> fetchAllProducts() async {
    final response = await client.get('/products');
    final List<dynamic> jsonList = response.data;
    return jsonList
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  @override
  Future<Product> fetchProductById(String id) async {
    final response = await client.get('/products/$id');
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<void> createProduct(Product product) async {
    await client.post('/products', data: (product as ProductModel).toJson());
  }

  @override
  Future<void> updateProduct(Product product) async {
    await client.put('/products/${product.id}',
        data: (product as ProductModel).toJson());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await client.delete('/products/$id');
  }
}
```

```dart
// data/datasources/product_local_datasource.dart
abstract class ProductLocalDatasource {
  Future<List<Product>> getCachedProducts();
  Future<Product?> getCachedProduct(String id);
  Future<void> cacheProduct(Product product);
  Future<void> cacheProducts(List<Product> products);
  Future<void> removeCachedProduct(String id);
  Future<void> invalidateCache();
}

class ProductLocalDatasourceImpl implements ProductLocalDatasource {
  final HiveService hive;

  ProductLocalDatasourceImpl({required this.hive});

  @override
  Future<List<Product>> getCachedProducts() async {
    final boxes = hive.getBox('products');
    final jsonList = boxes.values.cast<Map<String, dynamic>>().toList();
    return jsonList
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  @override
  Future<Product?> getCachedProduct(String id) async {
    final box = hive.getBox('products');
    final json = box.get(id);
    if (json != null) {
      return ProductModel.fromJson(json);
    }
    return null;
  }

  @override
  Future<void> cacheProduct(Product product) async {
    final box = hive.getBox('products');
    await box.put(product.id, (product as ProductModel).toJson());
  }

  @override
  Future<void> cacheProducts(List<Product> products) async {
    final box = hive.getBox('products');
    for (final product in products) {
      await box.put(product.id, (product as ProductModel).toJson());
    }
  }

  @override
  Future<void> removeCachedProduct(String id) async {
    final box = hive.getBox('products');
    await box.delete(id);
  }

  @override
  Future<void> invalidateCache() async {
    final box = hive.getBox('products');
    await box.clear();
  }
}
```

## Стратегии кэширования

| Стратегия | Описание | Когда использовать |
|-----------|----------|-------------------|
| Cache-first | Сначала кэш, потом сеть | Данные редко меняются |
| Network-first | Сначала сеть, потом кэш | Данные должны быть актуальными |
| Stale-while-revalidate | Показываем кэш, обновляем в фоне | Быстрый UI + актуальные данные |
| No cache | Только сеть | Чувствительные данные |

### Пример Cache-while-revalidate

```dart
Future<Either<Failure, List<Product>>> getAllProducts() async {
  // Всегда возвращаем кэш мгновенно
  final cached = await local.getCachedProducts();
  if (cached.isNotEmpty) {
    // Обновляем в фоне
    _refreshInBackground();
    return Right(cached);
  }

  // Если кэша нет — ждём сеть
  try {
    final products = await remote.fetchAllProducts();
    await local.cacheProducts(products);
    return Right(products);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}

void _refreshInBackground() async {
  try {
    final products = await remote.fetchAllProducts();
    await local.cacheProducts(products);
  } catch (_) {
    // Игнорируем ошибки фоновой синхронизации
  }
}
```

## Лучшие практики

1. **Абстрагируйте источники данных** — используйте DataSource
2. **Обрабатывайте ошибки на уровне репозитория** — возвращайте Failure
3. **Решайте стратегию кэширования внутри репозитория**
4. **Используйте Either/Result** вместо выбрасывания исключений
5. **Инвалидируйте кэш** при изменении данных
6. **Не возвращайте DTO из репозитория** — только доменные сущности
