---
tags:
  - platform-channels
  - native
  - plugins
chapter: 16
section: 2
title: Writing Native Plugins — создание кастомных плагинов
alias: 16 02 native plugins
status: complete
---

# Writing Native Plugins — создание кастомных плагинов

Создание собственных плагинов позволяет расширить возможности Flutter, интегрировав платформенно-зависимый код. Плагин — это пакет, который содержит как Dart-код, так и нативную реализацию для Android и iOS.

## Структура плагина

### Директория плагина

```
my_plugin/
├── lib/
│   ├── my_plugin.dart          # Основной Dart API
│   └── src/
│       └── platform_channel.dart
├── android/
│   ├── build.gradle
│   └── src/main/kotlin/com/example/my_plugin/
│       └── MyPlugin.kt
├── ios/
│   ├── Classes/
│   │   └── MyPlugin.swift
│   └── my_plugin.podspec
├── test/
│   └── my_plugin_test.dart
└── pubspec.yaml
```

### pubspec.yaml

```yaml
name: my_plugin
description: Кастомный плагин для получения информации о устройстве
version: 1.0.0
homepage: https://github.com/example/my_plugin

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  plugin:
    platforms:
      android:
        package: com.example.my_plugin
        pluginClass: MyPlugin
      ios:
        pluginClass: MyPlugin
```

## Создание плагина

### Шаг 1: Генерация шаблона

```bash
flutter create --template=plugin my_plugin
```

### Шаг 2: Dart API

```dart
// lib/my_plugin.dart
library my_plugin;

import 'src/platform_channel.dart';

/// Результат операции получения информации об устройстве
class DeviceInfo {
  final String model;
  final String osVersion;
  final String manufacturer;
  final bool isEmulator;

  DeviceInfo({
    required this.model,
    required this.osVersion,
    required this.manufacturer,
    required this.isEmulator,
  });

  @override
  String toString() =>
      'DeviceInfo(model: $model, os: $osVersion, mfr: $manufacturer)';
}

/// Основной класс плагина
class MyPlugin {
  static const MyPlugin _instance = MyPlugin._();

  factory MyPlugin() => _instance;

  MyPlugin._();

  /// Получение информации об устройстве
  Future<DeviceInfo> getDeviceInfo() async {
    return await _PlatformChannel().fetchDeviceInfo();
  }

  /// Проверка, работает ли эмулятор
  Future<bool> isRunningOnEmulator() async {
    return await _PlatformChannel().checkEmulator();
  }

  /// Получение свободного места на диске (в байтах)
  Future<int?> getFreeDiskSpace() async {
    return await _PlatformChannel().getFreeDiskSpace();
  }
}

export 'src/platform_channel.dart';
```

### Шаг 3: Платформенный канал

```dart
// lib/src/platform_channel.dart
import 'package:flutter/services.dart';

class _PlatformChannel {
  static const _methodChannel = MethodChannel('com.example/my_plugin');
  static const _errorPrefix = 'my_plugin';

  Future<DeviceInfo> fetchDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> raw =
          await _methodChannel.invokeMethod('getDeviceInfo');
      return DeviceInfo(
        model: raw['model'] as String? ?? 'Unknown',
        osVersion: raw['osVersion'] as String? ?? 'Unknown',
        manufacturer: raw['manufacturer'] as String? ?? 'Unknown',
        isEmulator: raw['isEmulator'] as bool? ?? false,
      );
    } on PlatformException catch (e) {
      throw Exception('${_errorPrefix}_FAILED: ${e.message}');
    }
  }

  Future<bool> checkEmulator() async {
    try {
      final bool result =
          await _methodChannel.invokeMethod('checkEmulator') as bool;
      return result;
    } on PlatformException catch (e) {
      print('${_errorPrefix}_CHECK_EMULATOR_ERROR: ${e.message}');
      return false;
    }
  }

  Future<int?> getFreeDiskSpace() async {
    try {
      final Object? result =
          await _methodChannel.invokeMethod('getFreeDiskSpace');
      if (result is int) return result;
      if (result is double) return result.toInt();
      return null;
    } on PlatformException catch (e) {
      print('${_errorPrefix}_DISK_SPACE_ERROR: ${e.message}');
      return null;
    }
  }
}
```

## Android-реализация плагина

### Kotlin-код

```kotlin
// android/src/main/kotlin/com/example/my_plugin/MyPlugin.kt
package com.example.my_plugin

import android.content.Context
import android.os.Build
import android.os.Environment
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Locale

/**
 * Плагин для получения информации об устройстве.
 * Реализует FlutterPlugin для работы с Flutter 1.12+ (Android embedding v2).
 */
class MyPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(
            binding.binaryMessenger,
            "com.example/my_plugin"
        )
        methodChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDeviceInfo" -> handleGetDeviceInfo(result)
            "checkEmulator" -> handleCheckEmulator(result)
            "getFreeDiskSpace" -> handleGetFreeDiskSpace(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Обработка запроса информации об устройстве.
     */
    private fun handleGetDeviceInfo(result: MethodChannel.Result) {
        val info = mapOf(
            "model" to Build.MODEL,
            "osVersion" to Build.VERSION.RELEASE,
            "manufacturer" to Build.MANUFACTURER,
            "brand" to Build.BRAND,
            "isEmulator" to isEmulator()
        )
        result.success(info)
    }

    /**
     * Проверка работы на эмуляторе.
     * Проверяет несколько признаков эмулятора.
     */
    private fun handleCheckEmulator(result: MethodChannel.Result) {
        result.success(isEmulator())
    }

    /**
     * Получение свободного места на основном хранилище.
     */
    private fun handleGetFreeDiskSpace(result: MethodChannel.Result) {
        val directory = Environment.getExternalStorageDirectory()
        val freeSpace = directory.freeSpace
        result.success(freeSpace)
    }

    /**
     * Определение эмулятора по нескольким критериям.
     */
    private fun isEmulator(): Boolean {
        return (
            Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.contains("vbox") ||
            Build.FINGERPRINT.contains("testbed") ||
            Build.FINGERPRINT.contains("generic_x86") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.contains("Android SDK") ||
            Build.HARDWARE.contains("goldfish") ||
            Build.HARDWARE.contains("ranchu") ||
            Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic") ||
            "google_sdk" == Build.PRODUCT
        )
    }
}
```

### build.gradle

```groovy
// android/build.gradle
plugins {
    id "com.android.library"
    id "org.jetbrains.kotlin.android"
}

android {
    namespace "com.example.my_plugin"
    compileSdk 34

    defaultConfig {
        minSdk 21
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.0"
}
```

## iOS-реализация плагина

### Swift-код

```swift
// ios/Classes/MyPlugin.swift
import Flutter
import UIKit
import Foundation

/**
 * Плагин для получения информации об устройстве iOS.
 */
public class MyPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.example/my_plugin",
            binaryMessenger: registrar.messenger()
        )
        let instance = MyPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getDeviceInfo":
            handleGetDeviceInfo(result: result)
        case "checkEmulator":
            handleCheckEmulator(result: result)
        case "getFreeDiskSpace":
            handleGetFreeDiskSpace(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleGetDeviceInfo(result: FlutterResult) {
        let device = UIDevice.current
        let info: [String: Any] = [
            "model": device.model,
            "osVersion": device.systemVersion,
            "manufacturer": "Apple",
            "brand": "Apple",
            "isEmulator": isSimulator()
        ]
        result(info)
    }

    /**
     * Проверка работы на симуляторе.
     */
    private func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    private func handleCheckEmulator(result: FlutterResult) {
        result(isSimulator())
    }

    private func handleGetFreeDiskSpace(result: FlutterResult) {
        do {
            let attributes = try FileManager.default
                .attributesOfFileSystem(forPath: NSHomeDirectory())
            if let freeSpace = attributes[.systemFreeSize] as? Int64 {
                result(freeSpace)
            } else {
                result(nil)
            }
        } catch {
            result(nil)
        }
    }
}
```

### Podspec

```ruby
# ios/my_plugin.podspec
Pod::Spec.new do |s|
  s.name             = 'my_plugin'
  s.version          = '1.0.0'
  s.summary          = 'Кастомный плагин для Flutter'
  s.description      = 'Плагин для получения информации об устройстве'
  s.homepage         = 'https://github.com/example/my_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Author' => 'author@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
```

## Тестирование плагина

### Unit-тесты

```dart
// test/my_plugin_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_plugin/my_plugin.dart';
import 'package:my_plugin/src/platform_channel.dart';

void main() {
  const MethodChannel channel = MethodChannel('com.example/my_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'getDeviceInfo':
          return {
            'model': 'Pixel 7',
            'osVersion': '14',
            'manufacturer': 'Google',
            'isEmulator': false,
          };
        case 'checkEmulator':
          return false;
        case 'getFreeDiskSpace':
          return 1073741824; // 1 GB
        default:
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('MyPlugin', () {
    test('getDeviceInfo возвращает корректные данные', () async {
      final plugin = MyPlugin();
      final info = await plugin.getDeviceInfo();

      expect(info.model, 'Pixel 7');
      expect(info.osVersion, '14');
      expect(info.manufacturer, 'Google');
      expect(info.isEmulator, false);
    });

    test('isRunningOnEmulator возвращает false', () async {
      final plugin = MyPlugin();
      final isEmulator = await plugin.isRunningOnEmulator();
      expect(isEmulator, false);
    });

    test('getFreeDiskSpace возвращает размер', () async {
      final plugin = MyPlugin();
      final freeSpace = await plugin.getFreeDiskSpace();
      expect(freeSpace, 1073741824);
    });
  });
}
```

## Best Practices

1. **Используйте `FlutterPlugin` интерфейс** — он поддерживает как v1, так и v2 embedding:
   ```kotlin
   class MyPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
       override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) { ... }
       override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) { ... }
   }
   ```

2. **Освобождайте ресурсы** — всегда убирайте обработчики при откреплении:
   ```kotlin
   override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
       methodChannel.setMethodCallHandler(null)
   }
   ```

3. **Используйте namespace в Android** — это современный подход:
   ```groovy
   android {
       namespace "com.example.my_plugin"
   }
   ```

4. **Поддерживайте минимальную версию SDK** — указывайте адекватные требования:
   ```groovy
   defaultConfig {
       minSdk 21  // Android 5.0+
   }
   ```

5. **Документируйте публичный API** — используйте KDoc/SwiftDoc:
   ```kotlin
   /**
    * Проверка работы на эмуляторе.
    * Проверяет несколько признаков эмулятора.
    */
   private fun isEmulator(): Boolean { ... }
   ```

6. **Обрабатывайте все ошибки** — никогда не бросайте необработанные исключения:
   ```dart
   try {
     // вызов
   } on PlatformException catch (e) {
     // обработка
   }
   ```

7. **Используйте синглтон для плагина** — если плагин не требует состояния:
   ```dart
   static const MyPlugin _instance = MyPlugin._();
   factory MyPlugin() => _instance;
   MyPlugin._();
   ```

8. **Тестируйте на реальных устройствах** — эмуляторы могут не воспроизводить все особенности.
