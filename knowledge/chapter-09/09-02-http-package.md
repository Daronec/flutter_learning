---
tags:
  - api
  - http
  - networking
chapter: 9
section: 2
title: Пакет http — базовые запросы в Flutter
alias: 09 02 http package
status: complete
---

# Пакет http — базовые запросы в Flutter

Пакет `http` — это официальный пакет Dart для выполнения HTTP-запросов. Он является наиболее простым и широко используемым способом работы с сетью в Flutter.

## Установка

Добавьте зависимость в `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.0
```

Или установите через командную строку:

```bash
flutter pub add http
```

## Базовое использование

### Импортирование пакета

```dart
import 'package:http/http.dart' as http;
```

Используйте псевдоним `as http`, чтобы избежать конфликтов с типом `http` в других контекстах.

### GET-запрос

```dart
import 'package:http/http.dart' as http;

// Простой GET-запрос
Future<void> fetchUsers() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
  );

  if (response.statusCode == 200) {
    print('Успех: ${response.body}');
  } else {
    print('Ошибка: ${response.statusCode}');
  }
}
```

### GET-запрос с параметрами

```dart
// Параметры добавляются автоматически через Uri
Future<void> fetchUsersWithParams() async {
  final uri = Uri.parse('https://jsonplaceholder.typicode.com/users').replace(
    queryParameters: {
      '_page': '1',
      '_limit': '10',
    },
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> users = jsonDecode(response.body);
    for (var user in users) {
      print('${user['name']} — ${user['email']}');
    }
  }
}
```

### POST-запрос

```dart
// Создание нового ресурса через POST
Future<void> createUser() async {
  final Map<String, dynamic> newUser = {
    'name': 'Иван Петров',
    'email': 'ivan@example.com',
    'username': 'ivanp',
  };

  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(newUser),
  );

  if (response.statusCode == 201) {
    print('Пользователь создан: ${response.body}');
  } else {
    print('Ошибка создания: ${response.statusCode}');
  }
}
```

### PUT-запрос (полное обновление)

```dart
// Полное обновление ресурса
Future<void> updateUser(int userId) async {
  final Map<String, dynamic> updatedUser = {
    'id': userId,
    'name': 'Иван Петров',
    'email': 'ivan.updated@example.com',
    'username': 'ivanp_updated',
  };

  final response = await http.put(
    Uri.parse('https://jsonplaceholder.typicode.com/users/$userId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(updatedUser),
  );

  if (response.statusCode == 200) {
    print('Пользователь обновлён');
  }
}
```

### PATCH-запрос (частичное обновление)

```dart
// Частичное обновление — меняем только email
Future<void> patchUser(int userId) async {
  final Map<String, dynamic> updates = {
    'email': 'newemail@example.com',
  };

  final response = await http.patch(
    Uri.parse('https://jsonplaceholder.typicode.com/users/$userId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(updates),
  );

  if (response.statusCode == 200) {
    print('Email обновлён');
  }
}
```

### DELETE-запрос

```dart
// Удаление ресурса
Future<void> deleteUser(int userId) async {
  final response = await http.delete(
    Uri.parse('https://jsonplaceholder.typicode.com/users/$userId'),
  );

  if (response.statusCode == 200) {
    print('Пользователь удалён');
  } else {
    print('Ошибка удаления: ${response.statusCode}');
  }
}
```

## Обработка ответов

### Парсинг JSON

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

Future<List<User>> fetchUsers() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
  );

  if (response.statusCode != 200) {
    throw Exception('Не удалось загрузить пользователей');
  }

  final List<dynamic> data = jsonDecode(response.body);
  return data.map((json) => User.fromJson(json as Map<String, dynamic>)).toList();
}
```

### Работа с заголовками ответа

```dart
Future<void> inspectResponse() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/users'),
  );

  // Заголовки ответа
  print('Content-Type: ${response.headers['content-type']}');
  print('Content-Length: ${response.headers['content-length']}');
  print('Все заголовки: ${response.headers}');

  // Тело ответа как строка
  print('Body: ${response.body}');

  // Тело ответа как байты
  print('Body bytes length: ${response.bodyBytes.length}');
}
```

## Работа с Client

Для множества запросов рекомендуется использовать экземпляр `Client`, который переиспользует соединения:

```dart
class HttpService {
  final http.Client _client = http.Client();
  final String baseUrl;

  HttpService(this.baseUrl);

  // GET с клиентом
  Future<http.Response> getUsers() {
    return _client.get(Uri.parse('$baseUrl/users'));
  }

  // POST с клиентом
  Future<http.Response> createUser(Map<String, dynamic> data) {
    return _client.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }

  // Метод для закрытия клиента (вызывать при уничтожении сервиса)
  void dispose() {
    _client.close();
  }
}
```

## Загрузка файлов

### Загрузка одного файла

```dart
Future<void> uploadFile(String filePath) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://api.example.com/upload'),
  );

  // Добавляем поля формы
  request.fields['userId'] = '123';
  request.fields['description'] = 'Мой файл';

  // Добавляем файл
  request.files.add(
    await http.MultipartFile.fromPath(
      'file',           // имя поля в форме
      filePath,         // путь к файлу на устройстве
      filename: 'photo.jpg', // имя файла на сервере
    ),
  );

  // Отправляем и получаем ответ
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  print('Статус: ${response.statusCode}');
  print('Ответ: ${response.body}');
}
```

### Загрузка нескольких файлов

```dart
Future<void> uploadMultipleFiles(List<String> filePaths) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://api.example.com/upload-batch'),
  );

  for (int i = 0; i < filePaths.length; i++) {
    request.files.add(
      await http.MultipartFile.fromPath('files', filePaths[i]),
    );
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);
  print('Загружено файлов: ${response.body}');
}
```

### Скачивание файла

```dart
import 'dart:io';

Future<void> downloadFile(String url, String savePath) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final file = File(savePath);
    await file.writeAsBytes(response.bodyBytes);
    print('Файл сохранён: ${file.path}');
  } else {
    throw Exception('Не удалось скачать файл');
  }
}
```

## Таймауты и отмена запросов

### Таймаут

```dart
Future<void> fetchWithTimeout() async {
  try {
    final response = await http
        .get(Uri.parse('https://api.example.com/data'))
        .timeout(const Duration(seconds: 10));
    print(response.body);
  } on TimeoutException {
    print('Превышено время ожидания (10 секунд)');
  }
}
```

### Отмена запроса с CancelToken

```dart
Future<void> fetchWithCancellation() async {
  final cancelToken = http.CancelToken();

  // Запуск запроса
  final future = http.get(
    Uri.parse('https://api.example.com/data'),
    cancelToken: cancelToken,
  );

  // Отмена через 5 секунд
  Future.delayed(const Duration(seconds: 5), () {
    cancelToken.cancel('Пользователь ушёл со страницы');
  });

  try {
    final response = await future;
    print(response.body);
  } on http.CancelledException {
    print('Запрос отменён');
  }
}
```

## Best Practices

- **Используйте `http.Client()`** для множества запросов — он переиспользует TCP-соединения
- **Всегда обрабатывайте ошибки** — проверяйте `statusCode` и бросайте исключения
- **Устанавливайте таймауты** — используйте `.timeout()` для предотвращения зависаний
- **Отменяйте запросы** — используйте `CancelToken` при навигации со страниц
- **Парсите JSON в модели** — не работайте с сырым JSON в UI-слое
- **Изолируйте HTTP-логику** — создайте отдельный сервис для сетевых запросов
- **Добавляйте логирование** — выводите URL и статус для отладки
