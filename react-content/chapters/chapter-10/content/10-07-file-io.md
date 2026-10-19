# File I/O — работа с файлами в Flutter

dart:io предоставляет API для работы с файловой системой. В Flutter это позволяет читать и записывать файлы, работать с директориями и управлять файловыми операциями.

## Установка дополнительных пакетов

```yaml
dependencies:
  path_provider: ^2.1.1
  file_picker: ^6.1.1
  permission_handler: ^11.2.0
```

## Получение путей

### Стандартные директории

```dart
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Директория приложения (sandbox)
Future<String> getApplicationDocumentsPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

// Временная директория
Future<String> getTemporaryPath() async {
  final directory = await getTemporaryDirectory();
  return directory.path;
}

// Путь для внешних файлов (Android)
Future<String?> getExternalPath() async {
  final directory = await getExternalStorageDirectory();
  return directory?.path;
}
```

### Создание пути к файлу

```dart
import 'package:path/path.dart' as path;

Future<String> getFilePath(String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  return path.join(directory.path, filename);
}

// Пример: /data/user/0/com.example.app/files/data.json
```

## Чтение файлов

### Чтение текста

```dart
import 'dart:io';

Future<String> readTextFile(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    return await file.readAsString();
  }
  throw Exception('Файл не найден: $filePath');
}

// Использование
final content = await readTextFile('/path/to/file.txt');
print(content);
```

### Чтение как байты

```dart
Future<Uint8List> readBytesFile(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    return await file.readAsBytes();
  }
  throw Exception('Файл не найден: $filePath');
}

// Использование (для изображений)
final bytes = await readBytesFile('/path/to/image.png');
```

### Чтение построчно

```dart
Future<List<String>> readLines(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    return await file.readAsLines();
  }
  return [];
}

// Использование
final lines = await readLines('/path/to/log.txt');
for (final line in lines) {
  print(line);
}
```

## Запись файлов

### Запись текста

```dart
Future<void> writeTextFile(String filePath, String content) async {
  final file = File(filePath);
  await file.writeAsString(content);
}

// Использование
await writeTextFile(
  await getFilePath('data.json'),
  '{"name": "Иван", "age": 25}',
);
```

### Запись байтов

```dart
Future<void> writeBytesFile(String filePath, Uint8List bytes) async {
  final file = File(filePath);
  await file.writeAsBytes(bytes);
}

// Использование
await writeBytesFile(
  await getFilePath('image.png'),
  imageBytes,
);
```

### Дописывание в файл

```dart
Future<void> appendToFile(String filePath, String content) async {
  final file = File(filePath);
  await file.writeAsString(content, mode: FileMode.append);
}

// Использование
await appendToFile(
  await getFilePath('log.txt'),
  '${DateTime.now()}: Запись в лог\n',
);
```

## Управление файлами

### Создание директории

```dart
Future<void> createDirectory(String dirPath) async {
  final directory = Directory(dirPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
}

// Использование
await createDirectory(await getFilePath('subfolder'));
```

### Копирование файла

```dart
Future<void> copyFile(String sourcePath, String destPath) async {
  final source = File(sourcePath);
  if (await source.exists()) {
    await source.copy(destPath);
  }
}
```

### Перемещение файла

```dart
Future<void> moveFile(String sourcePath, String destPath) async {
  final file = File(sourcePath);
  if (await file.exists()) {
    await file.rename(destPath);
  }
}
```

### Удаление файла

```dart
Future<void> deleteFile(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    await file.delete();
  }
}
```

### Проверка существования

```dart
Future<bool> fileExists(String filePath) async {
  return await File(filePath).exists();
}

Future<bool> directoryExists(String dirPath) async {
  return await Directory(dirPath).exists();
}
```

### Получение информации о файле

```dart
Future<Map<String, dynamic>> getFileInfo(String filePath) async {
  final file = File(filePath);
  if (await file.exists()) {
    return {
      'path': file.path,
      'size': await file.length(),
      'lastModified': await file.lastModified().then(
        (date) => date.toIso8601String(),
      ),
      'isDirectory': await file.isDirectory(),
    };
  }
  return {};
}
```

## Работа с директориями

### Список файлов

```dart
Future<List<String>> listFiles(String dirPath) async {
  final directory = Directory(dirPath);
  if (await directory.exists()) {
    return directory
        .listSync()
        .whereType<File>()
        .map((file) => file.path)
        .toList();
  }
  return [];
}

// Использование
final files = await listFiles(await getFilePath(''));
for (final file in files) {
  print(file);
}
```

### Поиск файлов

```dart
Future<List<String>> searchFiles(
  String dirPath,
  String extension,
) async {
  final directory = Directory(dirPath);
  if (await directory.exists()) {
    return directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith(extension))
        .map((file) => file.path)
        .toList();
  }
  return [];
}

// Поиск всех JSON файлов
final jsonFiles = await searchFiles(
  await getFilePath(''),
  '.json',
);
```

## Практический пример: менеджер файлов

```dart
class FileManager {
  final String _baseDir;

  FileManager(this._baseDir);

  Future<String> getFilePath(String filename) async {
    return path.join(_baseDir, filename);
  }

  // Сохранить JSON-файл
  Future<void> saveJson(String filename, Map<String, dynamic> data) async {
    final filePath = await getFilePath(filename);
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(data));
  }

  // Загрузить JSON-файл
  Future<Map<String, dynamic>?> loadJson(String filename) async {
    final filePath = await getFilePath(filename);
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    }
    return null;
  }

  // Сохранить текстовый файл
  Future<void> saveText(String filename, String content) async {
    final filePath = await getFilePath(filename);
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  // Загрузить текстовый файл
  Future<String?> loadText(String filename) async {
    final filePath = await getFilePath(filename);
    final file = File(filePath);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }

  // Удалить файл
  Future<void> deleteFile(String filename) async {
    final filePath = await getFilePath(filename);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Проверить существование
  Future<bool> exists(String filename) async {
    final filePath = await getFilePath(filename);
    return await File(filePath).exists();
  }

  // Размер файла
  Future<int?> size(String filename) async {
    final filePath = await getFilePath(filename);
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return null;
  }
}

// Использование
final fm = FileManager(await getApplicationDocumentsDirectory().then(
  (dir) => dir.path,
));

await fm.saveJson('user.json', {'name': 'Иван', 'age': 25});
final user = await fm.loadJson('user.json');
final exists = await fm.exists('user.json');
```

## Best Practices

- **Используйте `path_provider`** — для получения стандартных директорий
- **Используйте `path`** — для безопасного объединения путей
- **Создавайте директории рекурсивно** — `create(recursive: true)`
- **Обрабатывайте ошибки** — проверяйте существование файлов
- **Используйте async/await** — все файловые операции асинхронные
- **Очищайте временные файлы** — удаляйте файлы из `getTemporaryDirectory()`
- **Не храните файлы в assets** — они встроены в APK/IPA
