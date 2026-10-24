---
tags:
  - storage
  - database
  - local
chapter: 10
section: 6
title: SecureStorage — безопасное хранение данных
alias: 10 06 securestorage
status: complete
---

# SecureStorage — безопасное хранение данных

flutter_secure_storage — это пакет для безопасного хранения чувствительных данных. Он использует Keychain на iOS и Keystore/EncryptedSharedPreferences на Android.

## Установка

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```bash
flutter pub add flutter_secure_storage
```

## Требования к платформам

### Android

Добавьте в `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        // Для Android 6.0+
        minSdkVersion 20
    }
}
```

### iOS

Для iOS 12+ шифрование включено по умолчанию. Для более старых версий добавьте в `ios/Runner/Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Для доступа к данным</string>
```

## Базовое использование

### Инициализация

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = const FlutterSecureStorage();
```

### Запись данных

```dart
// Сохранить строку
await storage.write(key: 'auth_token', value: 'eyJhbGc...');

// Сохранить email
await storage.write(key: 'user_email', value: 'ivan@example.com');

// Сохранить JSON
await storage.write(
  key: 'user_data',
  value: '{"id":1,"name":"Иван","email":"ivan@example.com"}',
);
```

### Чтение данных

```dart
// Прочитать значение
String? token = await storage.read(key: 'auth_token');

// Прочитать email
String? email = await storage.read(key: 'user_email');

// Прочитать JSON
String? json = await storage.read(key: 'user_data');
if (json != null) {
  final userData = jsonDecode(json);
}
```

### Удаление данных

```dart
// Удалить конкретный ключ
await storage.delete(key: 'auth_token');

// Удалить все данные
await storage.deleteAll();
```

### Проверка наличия данных

```dart
// Проверить наличие ключа
bool hasToken = await storage.containsKey(key: 'auth_token');

if (hasToken) {
  final token = await storage.read(key: 'auth_token');
}
```

## Конфигурация хранилища

### iOS-специфичная конфигурация

```dart
const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    authenticationPolicy: AuthenticationPolicy.userPresence,
  ),
);
```

### Android-специцифичная конфигурация

```dart
const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
    // Аутентификация через биометрию
    authenticationCreds: AndroidCredentials.biometricPrompt(
      AndroidBiometricPrompt(
        title: 'Биометрическая аутентификация',
        subtitle: 'Для доступа к данным',
        description: 'Используйте отпечаток или Face ID',
        negativeButtonText: 'Отмена',
      ),
    ),
  ),
);
```

### Доступность данных (iOS)

| Доступность | Описание |
|-------------|----------|
| `always` | Данные доступны всегда (не рекомендуется) |
| `first_unlock` | Доступны после первой разблокировки устройства |
| `first_unlock_this_device` | Только после разблокировки на текущем устройстве |
| `unlock_this_device` | Только когда устройство разблокировано |
| `unlock_this_device_passcode` | Только с PIN-кодом (не биометрией) |
| `after_first_unlock` | Доступны после первой разблокировки |

```dart
const storage = FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.unlock_this_device,
  ),
);
```

## Практические примеры

### Хранение токенов аутентификации

```dart
class AuthStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';

  // Сохранить токены
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: userId.toString());
  }

  // Получить access токен
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Получить refresh токен
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Получить user ID
  Future<int?> getUserId() async {
    final id = await _storage.read(key: _userIdKey);
    return id != null ? int.tryParse(id) : null;
  }

  // Проверить авторизацию
  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  // Выйти из системы
  Future<void> logout() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
  }
}
```

### Хранение PIN-кода

```dart
class PinStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _pinKey = 'user_pin';

  Future<void> savePin(String pin) async {
    // Важно: НЕ храните PIN в открытом виде!
    // В реальном приложении используйте хеширование
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }
}
```

### Работа с JSON

```dart
class SecureJsonStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSecureData(String key, Map<String, dynamic> data) async {
    final json = jsonEncode(data);
    await _storage.write(key: key, value: json);
  }

  Map<String, dynamic>? getSecureData(String key) {
    final json = _storage.readSync(key: key);
    if (json != null) {
      return jsonDecode(json) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }
}
```

## Сравнение: SharedPreferences vs SecureStorage

| Характеристика | SharedPreferences | SecureStorage |
|----------------|-------------------|---------------|
| Безопасность | Низкая | Высокая |
| Шифрование | Нет | Да (Keychain/Keystore) |
| Производительность | Быстрее | Чуть медленнее |
| Объём данных | Неограничен | Небольшой |
| Использование | Настройки, данные | Токены, пароли |
| Биометрия | Нет | Да (Android) |

## Best Practices

- **Храните только чувствительные данные** — токены, пароли, ключи API
- **Не храните большие объёмы** — SecureStorage медленнее SharedPreferences
- **Используйте шифрование** — по умолчанию включено на обеих платформах
- **Очищайте данные при выходе** — вызывайте `delete()` при logout
- **Используйте биометрию** — на Android для дополнительного уровня защиты
- **Не логируйте данные** — не выводите токены в лог
