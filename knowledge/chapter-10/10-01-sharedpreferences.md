# SharedPreferences — простые пары ключ-значение

SharedPreferences — это простой способ хранения небольших объёмов данных в виде пар ключ-значение. Идеально подходит для сохранения настроек пользователя, флагов и небольших данных.

## Установка

```yaml
dependencies:
  shared_preferences: ^2.2.2
```

```bash
flutter pub add shared_preferences
```

## Базовое использование

### Получение экземпляра

```dart
import 'package:shared_preferences/shared_preferences.dart';

// Асинхронное получение экземпляра
Future<SharedPreferences> getInstance() async {
  return await SharedPreferences.getInstance();
}
```

### Сохранение данных

```dart
Future<void> saveUserData() async {
  final prefs = await SharedPreferences.getInstance();

  // String
  await prefs.setString('username', 'ivanpetrov');

  // Integer
  await prefs.setInt('age', 25);

  // Double
  await prefs.setDouble('balance', 1500.50);

  // Boolean
  await prefs.setBool('isPremium', true);

  // List<String>
  await prefs.setStringList('favorites', ['flutter', 'dart', 'android']);
}
```

### Чтение данных

```dart
Future<void> loadUserData() async {
  final prefs = await SharedPreferences.getInstance();

  // Чтение с значением по умолчанию
  String username = prefs.getString('username') ?? '';
  int age = prefs.getInt('age') ?? 0;
  double balance = prefs.getDouble('balance') ?? 0.0;
  bool isPremium = prefs.getBool('isPremium') ?? false;
  List<String> favorites = prefs.getStringList('favorites') ?? [];

  print('Пользователь: $username');
  print('Возраст: $age');
  print('Баланс: $balance');
  print('Премиум: $isPremium');
  print('Избранное: $favorites');
}
```

### Удаление данных

```dart
Future<void> removeData() async {
  final prefs = await SharedPreferences.getInstance();

  // Удалить конкретный ключ
  await prefs.remove('username');

  // Удалить все данные
  await prefs.clear();
}
```

### Проверка наличия ключа

```dart
Future<void> checkKey() async {
  final prefs = await SharedPreferences.getInstance();

  if (prefs.containsKey('username')) {
    print('Ключ username существует');
  } else {
    print('Ключ username не найден');
  }
}
```

## Практические примеры

### Сохранение настроек пользователя

```dart
class UserSettings {
  static const String _themeKey = 'theme';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications';
  static const String _fontSizeKey = 'fontSize';

  Future<void> saveTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
  }

  Future<ThemeMode> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? 'light';
    return ThemeMode.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => ThemeMode.light,
    );
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'ru';
  }

  Future<void> setNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<bool> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }
}
```

### Сохранение состояния приложения

```dart
class AppState {
  static const String _lastVisitKey = 'lastVisit';
  static const String _onboardedKey = 'onboarded';
  static const String _loginCountKey = 'loginCount';

  Future<void> updateLastVisit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastVisitKey, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastVisit() async {
    final prefs = await SharedPreferences.getInstance();
    final string = prefs.getString(_lastVisitKey);
    return string != null ? DateTime.parse(string) : null;
  }

  Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardedKey, value);
  }

  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  Future<void> incrementLoginCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_loginCountKey) ?? 0;
    await prefs.setInt(_loginCountKey, count + 1);
  }

  Future<int> getLoginCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_loginCountKey) ?? 0;
  }
}
```

### Работа с JSON в SharedPreferences

```dart
import 'dart:convert';

class UserPreferences {
  static const String _userKey = 'user';

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(user);
    await prefs.setString(_userKey, json);
  }

  Map<String, dynamic>? getUser() {
    final prefs = SharedPreferences.getInstanceSync();
    final json = prefs.getString(_userKey);
    if (json != null) {
      return jsonDecode(json) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}

// Использование
final prefs = UserPreferences();
await prefs.saveUser({
  'id': 1,
  'name': 'Иван',
  'email': 'ivan@example.com',
});

final user = prefs.getUser();
print(user?['name']); // Иван
```

## SharedPreferencesSync — синхронный доступ

```dart
// Синхронный доступ (не рекомендуется для тяжёлых операций)
final prefs = SharedPreferences.getInstanceSync();

prefs.setString('key', 'value');
final value = prefs.getString('key');
prefs.remove('key');
```

## Ограничения SharedPreferences

| Параметр | Значение |
|----------|----------|
| Тип данных | String, int, double, bool, List\<String\> |
| Объём данных | Не более нескольких мегабайт |
| Сложность данных | Только плоские структуры |
| Производительность | Хорошая для небольших данных |
| Безопасность | Данные не зашифрованы |

## Best Practices

- **Используйте для простых данных** — настройки, флаги, небольшие объекты
- **Не храните чувствительные данные** — пароли, токены используйте SecureStorage
- **Не храните большие объёмы** — для больших данных используйте базу данных
- **Не храните вложенные объекты** — используйте JSON-строки или другую БД
- **Используйте константы для ключей** — избегайте магических строк
- **Инициализируйте один раз** — кэшируйте экземпляр SharedPreferences
