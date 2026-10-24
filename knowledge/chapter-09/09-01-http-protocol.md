---
tags:
  - api
  - http
  - networking
chapter: 9
section: 1
title: HTTP-протокол: основы и работа с сетью в Flutter
alias: 09 01 http protocol
status: complete
---

# HTTP-протокол: основы и работа с сетью в Flutter

HTTP (HyperText Transfer Protocol) — это прикладной протокол передачи данных, лежащий в основе обмена информацией между клиентом и сервером в вебе и мобильных приложениях.

## Что такое HTTP?

HTTP — это протокол «клиент-сервер», где клиент (Flutter-приложение) отправляет **запрос** (request), а сервер отвечает **ответом** (response). Протокол является без状态ным (stateless), то есть каждый запрос независим.

### Основные компоненты HTTP

| Компонент | Описание |
|-----------|----------|
| Request | Запрос от клиента к серверу |
| Response | Ответ от сервера клиенту |
| Method | Действие, которое нужно выполнить (GET, POST и т.д.) |
| Status Code | Код состояния ответа сервера |
| Headers | Метаданные запроса/ответа |
| Body | Тело запроса или ответа (данные) |
| URI/URL | Адрес ресурса на сервере |

## HTTP-методы (Methods)

HTTP-методы определяют действие, которое нужно выполнить над ресурсом.

### Безопасные методы

| Метод | Описание | Безопасный | Idempotent |
|-------|----------|------------|------------|
| GET | Получение ресурса | Да | Да |
| HEAD | Получение заголовков без тела | Да | Да |

### Методы с побочными эффектами

| Метод | Описание | Idempotent |
|-------|----------|------------|
| POST | Создание нового ресурса | Нет |
| PUT | Полное обновление ресурса | Да |
| PATCH | Частичное обновление ресурса | Нет |
| DELETE | Удаление ресурса | Да |

```dart
// Пример использования разных HTTP-методов
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://api.example.com';

  // GET — получение данных
  Future<http.Response> getUsers() async {
    return http.get(Uri.parse('$baseUrl/users'));
  }

  // POST — создание ресурса
  Future<http.Response> createUser(Map<String, dynamic> user) async {
    return http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user),
    );
  }

  // PUT — полное обновление
  Future<http.Response> updateUser(int id, Map<String, dynamic> user) async {
    return http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user),
    );
  }

  // PATCH — частичное обновление
  Future<http.Response> patchUser(int id, Map<String, dynamic> updates) async {
    return http.patch(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );
  }

  // DELETE — удаление ресурса
  Future<http.Response> deleteUser(int id) async {
    return http.delete(Uri.parse('$baseUrl/users/$id'));
  }
}
```

## Коды состояния HTTP

Коды состояния делятся на пять классов в зависимости от первой цифры.

### Классы кодов состояния

| Диапазон | Значение | Описание |
|----------|----------|----------|
| 2xx | Успех | Запрос выполнен успешно |
| 3xx | Перенаправление | Требуется дополнительное действие |
| 4xx | Ошибка клиента | Запрос содержит ошибку |
| 5xx | Ошибка сервера | Сервер не справился с запросом |

### Распространённые коды

| Код | Значение | Когда используется |
|-----|----------|-------------------|
| 200 | OK | Запрос GET/PUT/PATCH выполнен успешно |
| 201 | Created | Ресурс успешно создан (POST) |
| 204 | No Content | Успешно, но нет тела ответа |
| 301 | Moved Permanently | Ресурс перемещён навсегда |
| 304 | Not Modified | Кэшированная версия актуальна |
| 400 | Bad Request | Неверный формат запроса |
| 401 | Unauthorized | Требуется аутентификация |
| 403 | Forbidden | Нет прав доступа |
| 404 | Not Found | Ресурс не найден |
| 409 | Conflict | Конфликт данных (например, дубликат) |
| 422 | Unprocessable Entity | Данные валидны по формату, но не по смыслу |
| 429 | Too Many Requests | Превышен лимит запросов |
| 500 | Internal Server Error | Внутренняя ошибка сервера |
| 502 | Bad Gateway | Неверный ответ от промежуточного сервера |
| 503 | Service Unavailable | Сервис временно недоступен |

```dart
// Проверка кодов состояния
Future<void> handleResponse(http.Response response) async {
  switch (response.statusCode) {
    case 200:
      print('Успешный запрос: ${response.body}');
      break;
    case 201:
      print('Ресурс создан: ${response.body}');
      break;
    case 400:
      print('Ошибка клиента: ${response.body}');
      break;
    case 401:
      print('Не авторизован — перенаправить на вход');
      break;
    case 404:
      print('Ресурс не найден');
      break;
    case 500:
      print('Ошибка сервера — повторить позже');
      break;
    default:
      print('Неожиданный код: ${response.statusCode}');
  }
}
```

## Заголовки HTTP

Заголовки передают дополнительную информацию о запросе или ответе.

### Основные заголовки запроса

| Заголовок | Описание | Пример |
|-----------|----------|--------|
| Content-Type | Тип тела запроса | `application/json` |
| Authorization | Токен авторизации | `Bearer eyJhbGc...` |
| Accept | Ожидаемый формат ответа | `application/json` |
| User-Agent | Информация о клиенте | `Flutter/3.0` |
| Cache-Control | Управление кэшированием | `no-cache` |
| X-Request-ID | Идентификатор запроса | `abc-123-def` |

### Основные заголовки ответа

| Заголовок | Описание | Пример |
|-----------|----------|--------|
| Content-Type | Тип содержимого ответа | `application/json; charset=utf-8` |
| Content-Length | Размер тела в байтах | `1234` |
| Set-Cookie | Установка cookie | `session=xyz; HttpOnly` |
| Cache-Control | Правила кэширования | `max-age=3600` |
| ETag | Контрольная сумма ресурса | `"abc123"` |
| X-RateLimit-Remaining | Оставшиеся запросы | `42` |

```dart
// Установка заголовков в запросе
final response = await http.get(
  Uri.parse('https://api.example.com/users'),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
    'X-Request-ID': 'req-001',
  },
);
```

## Тело запроса (Request Body)

Тело запроса содержит данные, отправляемые на сервер. Формат зависит от Content-Type.

### Форматы тела

| Content-Type | Формат | Пример |
|--------------|--------|--------|
| application/json | JSON | `{"name": "Иван"}` |
| application/x-www-form-urlencoded | Форма | `name=Иван&age=25` |
| multipart/form-data | Множественная форма | Файлы + данные |
| text/plain | Текстовый | `Простой текст` |
| application/xml | XML | `<user><name>Иван</name></user>` |

```dart
// Отправка JSON в теле запроса
final userData = {
  'name': 'Иван',
  'email': 'ivan@example.com',
  'age': 25,
};

final response = await http.post(
  Uri.parse('https://api.example.com/users'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(userData),
);

// Отправка формы
final response = await http.post(
  Uri.parse('https://api.example.com/login'),
  headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  body: {'username': 'ivan', 'password': 'secret123'},
);

// Загрузка файла (multipart)
final request = http.MultipartRequest(
  'POST',
  Uri.parse('https://api.example.com/upload'),
);
request.fields['title'] = 'Фото';
request.files.add(
  await http.MultipartFile.fromPath('file', 'assets/photo.jpg'),
);
final streamedResponse = await request.send();
final response = await http.Response.fromStream(streamedResponse);
```

## HTTP в контексте Flutter

При работе с HTTP в Flutter важно учитывать особенности платформы:

### Таймауты

```dart
// Установка таймаута для запроса
final client = http.Client();

Future<http.Response> fetchWithTimeout() async {
  try {
    final response = await client
        .get(Uri.parse('https://api.example.com/data'))
        .timeout(const Duration(seconds: 10));
    return response;
  } on TimeoutException {
    print('Запрос превысил лимит времени');
    rethrow;
  }
}
```

### Особенности на разных платформах

| Платформа | Особенности |
|-----------|------------|
| Android | Требуется разрешение `INTERNET` в AndroidManifest.xml |
| iOS | По умолчанию HTTPS, HTTP требует настройку App Transport Security |
| Web | Использует XMLHttpRequest / fetch API браузера |
| Desktop | Использует системный HTTP-стек |

### Безопасность (HTTPS)

- Всегда используйте HTTPS в production
- На iOS настройте `Info.plist` дл�� ограничения HTTP
- На Android убедитесь, что `android:usesCleartextTraffic="false"`

## Best Practices

- **Всегда используйте HTTPS** для передачи данных
- **Обрабатывайте все коды состояния** — не только 200
- **Устанавливайте таймауты** — не позволяйте запросам висеть вечно
- **Валидируйте входные данные** до отправки на сервер
- **Кэшируйте ответы** для часто запрашиваемых ресурсов
- **Используйте логирование** для отладки сетевых запросов
- **Обрабатывайте потерю соединения** — показывайте пользователю понятное сообщение
- **Используйте пагинацию** — не загружайте все данные сразу
## РЎРІСЏР·Р°РЅРЅС‹Рµ РіР»Р°РІС‹

[[SharedPreferences — простые пары ключ-значение]] [[Clean Architecture в Flutter]] 
