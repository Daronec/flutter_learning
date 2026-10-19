# Push-уведомления с Firebase Cloud Messaging

## Введение

Firebase Cloud Messaging (FCM) — это кроссплатформенный сервис от Google, позволяющий отправлять push-уведомления на мобильные устройства. В Flutter для работы с FCM используется пакет `firebase_messaging`.

## Установка и настройка

### 1. Создание проекта Firebase

1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Создайте новый проект
3. Добавьте приложение (Android/iOS)
4. Скачайте конфигурационные файлы:
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`

### 2. Установка пакета

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
```

### 3. Инициализация

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Запрос разрешений
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  runApp(const MyApp());
}
```

## Получение токена устройства

```dart
class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Получение токена устройства
  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    print('FCM Token: $token');
    return token;
  }

  /// Подписка на тему
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Отписка от темы
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
```

## Обработка входящих сообщений

### Foreground handler

```dart
/// Обработчик сообщений в foreground
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Processing background message: ${message.messageId}');
  print('Notification: ${message.notification?.title}');
  print('Data: ${message.data}');
}

void setupMessageHandlers() {
  // Foreground handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Notification: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Sound: ${message.notification?.sound}');
    }

    // Показываем локальное уведомление
    _showLocalNotification(message);
  });
}

void _showLocalNotification(RemoteMessage message) {
  // Интеграция с flutter_local_notifications
  const notification = AndroidNotification(
    channelId: 'high_importance_channel',
    title: 'Новое уведомление',
    body: 'Текст уведомления',
    icon: '@mipmap/ic_launcher',
  );

  const android = AndroidNotificationDetails(
    'high_importance_channel',
    'Важные уведомления',
    channelDescription: 'Канал для важных уведомлений',
    importance: Importance.max,
    priority: Priority.high,
  );

  const platform = NotificationDetails(android: android);

  FlutterLocalNotificationsPlugin().show(
    message.notification.hashCode,
    message.notification?.title,
    message.notification?.body,
    platform,
  );
}
```

### Background handler

```dart
/// Обработчик фоновых сообщений
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Обработка фонового сообщения
  final data = message.data;
  final type = data['type'];

  switch (type) {
    case 'order_update':
      await _handleOrderUpdate(data);
      break;
    case 'chat_message':
      await _handleChatMessage(data);
      break;
    default:
      print('Unhandled message type: $type');
  }
}

Future<void> _handleOrderUpdate(Map<String, dynamic> data) async {
  // Обновление статуса заказа
  final orderId = data['orderId'];
  final status = data['status'];
  print('Order $orderId updated to $status');
}

Future<void> _handleChatMessage(Map<String, dynamic> data) async {
  // Добавление сообщения в очередь
  final chatId = data['chatId'];
  final sender = data['sender'];
  final text = data['text'];
  print('New chat message from $sender in $chatId');
}
```

### Handler для нажатия на уведомление

```dart
/// Обработка нажатия на уведомление
void setupNotificationTapHandler() {
  // Приложение в фоне/закрыто
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final screen = data['screen'];

    switch (type) {
      case 'product':
        Navigator.pushNamed(context, '/product', arguments: data['productId']);
        break;
      case 'order':
        Navigator.pushNamed(context, '/order', arguments: data['orderId']);
        break;
      case 'chat':
        Navigator.pushNamed(context, '/chat', arguments: data['chatId']);
        break;
    }
  });

  // Приложение было закрыто
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      final data = message.data;
      // Навигация на нужный экран
      _navigateFromNotification(data);
    }
  });
}
```

## Типы уведомлений FCM

| Тип | Описание | Когда доставляется |
|-----|----------|-------------------|
| Notification | С визуальным оформлением | Foreground: callback; Background: системный трей |
| Data | Только данные | Всегда в `message.data` |
| Background | Обработка в фоне | При закрытом приложении |

### Отправка Data-сообщения

```dart
// Серверная часть (Node.js пример)
const admin = require('firebase-admin');

admin.messaging().send({
  token: deviceToken,
  data: {
    type: 'order_update',
    orderId: '12345',
    status: 'shipped',
    screen: 'order_detail',
  },
  notification: {
    title: 'Ваш заказ отправлен',
    body: 'Заказ #12345 передан в службу доставки',
  },
});
```

## Локальные уведомления

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
      onDidReceiveNotificationResponse: _onNotificationSelected,
    );

    // Создание канала для Android
    const androidChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'Важные уведомления',
      description: 'Канал для важных уведомлений',
      importance: Importance.max,
    );
    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? payload,
  }) async {
    const details = AndroidNotificationDetails(
      'high_importance_channel',
      'Важные уведомления',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platform = NotificationDetails(android: details);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platform,
      payload: JsonEncoder.convert(payload),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  void _onNotificationSelected(NotificationResponse response) {
    final payload = response.payload;
    // Обработка нажатия
  }
}
```

## Лучшие практики

1. **Запрашивайте разрешения явно** — с объяснением зачем нужны уведомления
2. **Используйте Data-сообщения** для гибкой обработки
3. **Обрабатывайте все три состояния** — foreground, background, terminated
4. **Кэшируйте токен** на сервере
5. **Подписывайте на темы** для сегментации пользователей
6. **Тестируйте на реальных устройствах** — эмуляторы могут не поддерживать FCM
