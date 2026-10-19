# Работа с камерой и галереей в Flutter

## Введение

Работа с медиафайлами (камера, галерея) — частая задача в мобильных приложениях. В Flutter для этого используются пакеты `camera` и `image_picker`.

## Image Picker — выбор из галереи

### Установка

```yaml
dependencies:
  image_picker: ^1.0.5
```

### Настройка разрешений

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Приложению нужен доступ к галерее для выбора фото</string>
<key>NSCameraUsageDescription</key>
<string>Приложению нужен доступ к камере для съёмки фото</string>
<key>NSMicrophoneUsageDescription</key>
<string>Приложению нужен доступ к микрофону для записи видео</string>
```

### Выбор изображения

```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MediaPickerService {
  final ImagePicker _picker = ImagePicker();

  /// Выбор изображения из галереи
  Future<XFile?> pickImageFromGallery({
    ImageSource source = ImageSource.gallery,
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
  }) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    return image;
  }

  /// Выбор видео из галереи
  Future<XFile?> pickVideoFromGallery({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
    Duration? maxDuration,
  }) async {
    final XFile? video = await _picker.pickVideoSource(
      maxDuration: maxDuration ?? const Duration(minutes: 10),
    );
    return video;
  }

  /// Запись фото через камеру
  Future<XFile?> captureImage({
    double? maxWidth,
    double? maxHeight,
    int imageQuality = 85,
    CameraLensDirection lensDirection = CameraLensDirection.back,
  }) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: lensDirection,
    );
    return image;
  }

  /// Запись видео через камеру
  Future<XFile?> recordVideo({
    Duration maxDuration = const Duration(minutes: 10),
    CameraLensDirection lensDirection = CameraLensDirection.back,
  }) async {
    final XFile? video = await _picker.pickVideoSource(
      maxDuration: maxDuration,
    );
    return video;
  }
}
```

### Использование в виджете

```dart
class MediaPickerScreen extends StatefulWidget {
  const MediaPickerScreen({super.key});

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> {
  File? _imageFile;
  File? _videoFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    setState(() => _isLoading = true);
    try {
      final file = await MediaPickerService().pickImageFromGallery();
      if (file != null) {
        setState(() => _imageFile = File(file.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _captureImage() async {
    setState(() => _isLoading = true);
    try {
      final file = await MediaPickerService().captureImage();
      if (file != null) {
        setState(() => _imageFile = File(file.path));
      }
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Превью изображения
          _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _imageFile!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : const Center(
                  child: Text('Изображение не выбрано'),
                ),

          const SizedBox(height: 20),

          // Кнопки
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Галерея'),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _captureImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Камера'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

## Camera — полноценная камера

### Установка

```yaml
dependencies:
  camera: ^0.10.5
```

### Настройка камеры

```dart
import 'package:camera/camera.dart';

class CameraService {
  late CameraController _controller;
  late List<CameraDescription> _cameras;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    // Выбираем заднюю камеру
    _controller = CameraController(
      _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      ),
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller.initialize();
  }

  CameraController get controller => _controller;
  bool get isInitialized => _controller.isInitialized;
  List<CameraDescription> get cameras => _cameras;

  Future<void> dispose() async {
    await _controller.dispose();
  }
}
```

### Виджет камеры

```dart
class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  CameraLensDirection _direction = CameraLensDirection.back;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      cameras.firstWhere(
        (c) => c.lensDirection == _direction,
        orElse: () => cameras.first,
      ),
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchCamera() {
    setState(() {
      _direction = _direction == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;
    });
    _controller = CameraController(
      cameras.firstWhere(
        (c) => c.lensDirection == _direction,
        orElse: () => cameras.first,
      ),
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  Future<void> _takePicture() async {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (_controller.value.isTakingPicture) {
      return;
    }
    try {
      await _initializeControllerFuture;
      final XFile file = await _controller.takePicture();
      // Обработка сохранённого файла
      Navigator.pop(context, file.path);
    } on CameraException catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: _switchCamera,
          ),
        ],
      ),
    );
  }
}
```

### Запись видео

```dart
Future<void> _startRecording() async {
  if (!_controller.value.isInitialized) return;
  try {
    await _controller.startVideoRecording();
  } on CameraException catch (e) {
    print('Error starting recording: $e');
  }
}

Future<void> _stopRecording() async {
  if (!_controller.value.isRecordingVideo) return;
  try {
    final XFile videoFile = await _controller.stopVideoRecording();
    // Обработка сохранённого видео
    print('Video saved: ${videoFile.path}');
  } on CameraException catch (e) {
    print('Error stopping recording: $e');
  }
}
```

## Обработка и оптимизация изображений

### Сжатие изображений

```dart
import 'package:image/image.dart' as img;

class ImageProcessor {
  /// Сжатие изображения
  Future<File> compressImage(File file, {int quality = 80}) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return file;

    final compressed = img.encodeJpg(image, quality: quality);
    return File(file.path).writeAsBytes(compressed);
  }

  /// Изменение размера изображения
  Future<File> resizeImage(File file, {int width = 1920, int height = 1080}) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return file;

    final resized = img.copyResize(image, width: width, height: height);
    final compressed = img.encodeJpg(resized);
    return File(file.path).writeAsBytes(compressed);
  }

  /// Получение метаданных
  Future<ImageMetadata> getImageMetadata(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    return ImageMetadata(
      width: image?.width ?? 0,
      height: image?.height ?? 0,
      size: bytes.length,
    );
  }
}

class ImageMetadata {
  final int width;
  final int height;
  final int size;

  double get aspectRatio => width / height;
  String get formattedSize => _formatBytes(size);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}
```

## Сравнение подходов

| Подход | Пакет | Возможности | Сложность |
|--------|-------|------------|----------|
| Image Picker | `image_picker` | Выбор из галереи, простая камера | Низкая |
| Camera | `camera` | Полная камера, видео, настройки | Высокая |
| Custom | `camera` + обработка | Полный контроль | Очень высокая |

## Лучшие практики

1. **Сжимайте изображения** перед загрузкой на сервер
2. **Обрабатывайте ошибки** (отказ в разрешении, нет памяти)
3. **Используйте `image_picker`** для простых задач
4. **Используйте `camera`** для сложных сценариев
5. **Показывайте превью** перед отправкой
6. **Ограничивайте размер файлов** для экономии трафика
