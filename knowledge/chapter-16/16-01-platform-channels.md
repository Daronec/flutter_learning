# Platform Channels — взаимодействие с нативным кодом

Platform Channels — это основной механизм коммуникации между Dart-кодом Flutter-приложения и нативным кодом на Android (Kotlin/Java) и iOS (Swift/Objective-C). Через Platform Channels Flutter получает доступ к платформенным API, которые не доступны на уровне Dart.

## Архитектура Platform Channels

Platform Channels работают по принципу клиент-сервер:

| Компонент | Описание |
|-----------|----------|
| Dart-сторона | Отправляет сообщения через `MethodChannel`, `EventChannel` или `BasicMessageChannel` |
| BinaryMessenger | Транслирует байтовые сообщения между сторонами |
| Нативная сторона | Получает и обрабатывает сообщения через соответствующий API |

### Типы каналов

| Тип канала | Назначение | Направление |
|------------|-----------|-------------|
| `MethodChannel` | Вызов методов (синхронные/асинхронные) | Двусторонний |
| `EventChannel` | Потоки событий | От нативного к Dart |
| `BasicMessageChannel` | Обмен сообщениями с обработкой | Двусторонний |

## MethodChannel

`MethodChannel` — самый распространённый тип канала. Используется для вызова методов на нативной стороне из Dart и наоборот.

### Dart-код

```dart
import 'package:flutter/services.dart';

class DeviceInfoService {
  static const _channel = MethodChannel('com.example/device_info');

  /// Получение модели устройства
  Future<String> getDeviceModel() async {
    try {
      final String model = await _channel.invokeMethod('getDeviceModel');
      return model;
    } on PlatformException catch (e) {
      throw Exception('Ошибка получения модели: ${e.message}');
    }
  }

  /// Получение версии ОС
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('getSystemInfo');
      return Map<String, dynamic>.from(result as Map);
    } on PlatformException catch (e) {
      throw Exception('Ошибка получения системной информации: ${e.message}');
    }
  }

  /// Вызов метода с параметрами
  Future<bool> setBrightness(double brightness) async {
    assert(brightness >= 0.0 && brightness <= 1.0);
    try {
      final bool result = await _channel.invokeMethod(
        'setBrightness',
        {'brightness': brightness},
      );
      return result;
    } on PlatformException catch (e) {
      throw Exception('Ошибка установки яркости: ${e.message}');
    }
  }
}
```

### Android (Kotlin)

```kotlin
package com.example.myapp

import android.content.Context
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class DeviceInfoPlugin(
    private val context: Context
) : MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.example/device_info"

        fun registerWith(registrar: io.flutter.plugin.common.PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            val plugin = DeviceInfoPlugin(registrar.context())
            channel.setMethodCallHandler(plugin)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getDeviceModel" -> {
                val model = Build.MODEL
                result.success(model)
            }
            "getSystemInfo" -> {
                val info = mapOf(
                    "osVersion" to Build.VERSION.RELEASE,
                    "apiLevel" to Build.VERSION.SDK_INT,
                    "manufacturer" to Build.MANUFACTURER,
                    "brand" to Build.BRAND,
                    "device" to Build.DEVICE
                )
                result.success(info)
            }
            "setBrightness" -> {
                val brightness = call.argument<Double>("brightness")
                if (brightness != null) {
                    // Логика установки яркости
                    result.success(true)
                } else {
                    result.error("INVALID_ARGUMENT", "brightness не указан", null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
```

### iOS (Swift)

```swift
import Flutter
import UIKit

class DeviceInfoPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.example/device_info",
            binaryMessenger: registrar.messenger()
        )
        let instance = DeviceInfoPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getDeviceModel":
            result(UIDevice.current.model)

        case "getSystemInfo":
            let info: [String: Any] = [
                "osVersion": UIDevice.current.systemVersion,
                "osName": UIDevice.current.systemName,
                "model": UIDevice.current.model,
                "batteryLevel": UIDevice.current.batteryLevel
            ]
            result(info)

        case "setBrightness":
            if let args = call.arguments as? [String: Any],
               let brightness = args["brightness"] as? Double {
                // Логика установки яркости
                result(true)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "brightness не указан",
                    details: nil
                ))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
```

## EventChannel

`EventChannel` используется для получения потоков данных от нативной платформы. Например, для отслеживания уровня заряда батареи, геолокации или датчиков.

### Dart-код

```dart
import 'package:flutter/services.dart';

class SensorStreamService {
  static const _eventChannel = EventChannel('com.example/sensors');

  /// Подписка на поток данных датчиков
  Stream<SensorData> getSensorStream() {
    return _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
          if (event is Map) {
            return SensorData(
              accelerometer: List<double>.from(event['accelerometer'] ?? []),
              gyroscope: List<double>.from(event['gyroscope'] ?? []),
              timestamp: event['timestamp'] as int? ?? 0,
            );
          }
          return SensorData();
        })
        .handleError((error) {
          print('Ошибка потока датчиков: $error');
        });
  }
}

class SensorData {
  final List<double> accelerometer;
  final List<double> gyroscope;
  final int timestamp;

  SensorData({
    this.accelerometer = const [],
    this.gyroscope = const [],
    this.timestamp = 0,
  });

  @override
  String toString() =>
      'SensorData(acc: $accelerometer, gyro: $gyroscope, ts: $timestamp)';
}
```

### Android (Kotlin)

```kotlin
class SensorEventPlugin(
    private val context: Context
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        private const val CHANNEL_NAME = "com.example/sensors"

        fun registerWith(registrar: io.flutter.plugin.common.PluginRegistry.Registrar) {
            val channel = EventChannel(registrar.messenger(), CHANNEL_NAME)
            channel.setStreamHandler(object : EventChannel.StreamHandler {
                private var sensorManager: SensorManager? = null
                private var accelerometer: Sensor? = null

                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    sensorManager =
                        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
                    accelerometer = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

                    val listener = SensorEventListener { sensor, accuracy, timestamp ->
                        val values = FloatArray(3)
                        // Отправка данных в Dart
                        val data = mapOf(
                            "accelerometer" to values.toList(),
                            "timestamp" to timestamp
                        )
                        events.success(data)
                    }

                    accelerometer?.let {
                        sensorManager?.registerListener(
                            listener, it,
                            SensorManager.SENSOR_DELAY_NORMAL
                        )
                    }
                }

                override fun onCancel(arguments: Any?) {
                    sensorManager?.unregisterListener(SensorEventListener {})
                    sensorManager = null
                }
            })
        }
    }
}
```

## BasicMessageChannel

`BasicMessageChannel` позволяет отправлять и получать сообщения с обработкой. Подходит для обмена данными, когда не требуется вызов методов или потоки событий.

### Dart-код

```dart
import 'package:flutter/services.dart';

class MessageBus {
  static const _channel = BasicMessageChannel<String>(
    'com.example/message_bus',
    StringCodec(),
  );

  /// Отправка сообщения
  Future<String?> sendMessage(String message) async {
    try {
      final String? response = await _channel.send(message);
      return response;
    } on PlatformException catch (e) {
      print('Ошибка отправки: ${e.message}');
      return null;
    }
  }

  /// Регистрация обработчика входящих сообщений
  void registerHandler(void Function(String) onMessage) {
    _channel.setMessageHandler((String? message) async {
      if (message != null) {
        onMessage(message);
        return 'Получено: $message';
      }
      return null;
    });
  }

  /// Отправка сообщения с объектом (через кодирование)
  Future<String?> sendStructuredMessage(Map<String, dynamic> data) async {
    try {
      final String? response = await _channel.send(data);
      return response;
    } on PlatformException catch (e) {
      print('Ошибка структурированного сообщения: ${e.message}');
      return null;
    }
  }
}
```

### Android (Kotlin)

```kotlin
class MessageBusPlugin(
    private val context: Context
) : MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "com.example/message_bus"
        private lateinit var messageChannel: BasicMessageChannel<String>
        private var messageHandler: ((String) -> String)? = null

        fun registerWith(registrar: io.flutter.plugin.common.PluginRegistry.Registrar) {
            messageChannel = BasicMessageChannel(
                registrar.messenger(),
                CHANNEL_NAME,
                StringCodec.INSTANCE
            )

            messageChannel.setMessageHandler { message, reply ->
                if (message != null) {
                    val response = messageHandler?.invoke(message)
                        ?: "Получено: $message"
                    reply.reply(response)
                } else {
                    reply.reply(null)
                }
            }
        }

        fun setHandler(handler: (String) -> String) {
            messageHandler = handler
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        result.notImplemented()
    }
}
```

## Кодирование данных

### Стандартные кодировщики

| Кодировщик | Тип данных | Использование |
|------------|-----------|---------------|
| `StandardMessageCodec` | Стандартные типы Dart | По умолчанию для MethodChannel |
| `StringCodec` | Строки | Для текстовых данных |
| `JSONMessageCodec` | JSON-совместимые объекты | Для сложных структур |
| `BinaryCodec` | Бинарные данные | Для байтовых массивов |

### Стандартные типы данных

```
Дарт            →   Android        →   iOS
─────────────────────────────────────────────────
null            →   null           →   NSNull
bool            →   Boolean        →   NSNumber
int (32-bit)    →   Integer        →   NSNumber
int (64-bit)    →   Long           →   NSNumber
double          →   Double         →   NSNumber
String          →   String         →   NSString
Uint8List       →   byte[]         →   NSData
Int32List       →   int[]          →   NSData
Int64List       →   long[]         →   NSData
Float64List     →   double[]       →   NSData
List            →   ArrayList      →   NSArray
Map             →   HashMap        →   NSDictionary
```

## Best Practices

1. **Используйте уникальные имена каналов** — избегайте конфликтов, используя префикс домена:
   ```dart
   // Плохо
   MethodChannel('my_channel');

   // Хорошо
   MethodChannel('com.mycompany.myapp/device_info');
   ```

2. **Обрабатывайте ошибки** — всегда оборачивайте вызовы в try-catch:
   ```dart
   try {
     final result = await channel.invokeMethod('someMethod');
   } on PlatformException catch (e) {
     // Обработка ошибки
   }
   ```

3. **Избегайте блокирующих вызовов** — нативные методы должны выполняться асинхронно:
   ```kotlin
   // Плохо — блокирует поток
   result.success(expensiveSyncOperation())

   // Хорошо — в отдельном потоке
   executor.execute {
       result.success(expensiveAsyncOperation())
   }
   ```

4. **Кэшируйте результаты** — не вызывайте нативный код без необходимости:
   ```dart
   String? _cachedModel;
   Future<String> getDeviceModel() async {
     if (_cachedModel != null) return _cachedModel!;
     _cachedModel = await _channel.invokeMethod('getDeviceModel');
     return _cachedModel!;
   }
   ```

5. **Документируйте API** — ведите список всех каналов и методов:
   ```
   Channel: com.example/device_info
   Methods:
     - getDeviceModel() → String
     - getSystemInfo() → Map<String, dynamic>
     - setBrightness(double) → bool
   ```

6. **Тестируйте на обеих платформах** — всегда проверяйте поведение на Android и iOS.

7. **Используйте `MethodChannel.setMethodCallHandler`** для вызова Dart из нативного кода:
   ```dart
   static const _replyChannel = MethodChannel('com.example/reply');
   _replyChannel.setMethodCallHandler((call) async {
     if (call.method == 'onNativeEvent') {
       print('Получено событие: ${call.arguments}');
       return 'Обработано';
     }
     return null;
   });
   ```
