---
tags:
  - platform-channels
  - native
  - plugins
chapter: 16
section: 8
title: Flutter для Desktop — особенности платформ
alias: 16 08 flutter desktop advanced
status: complete
---

# Flutter для Desktop — особенности платформ

Flutter поддерживает десктопные платформы: Windows, macOS и Linux. Каждая платформа имеет свои особенности, требования и возможности интеграции с нативными API.

## Поддерживаемые десктоп платформы

| Платформа | ОС | Статус | Язык нативного кода | Фреймворк |
|-----------|-----|--------|---------------------|-----------|
| Windows | Windows 10+ | Stable | C++/C# | Win32 API |
| macOS | macOS 10.14+ | Stable | C++/Swift | Cocoa/AppKit |
| Linux | Ubuntu 20.04+ | Stable | C++ | GTK |

### Системные требования

| Платформа | Минимальная версия | Архитектура |
|-----------|-------------------|-------------|
| Windows | Windows 10 (1607+) | x64, ARM64 |
| macOS | macOS 10.14 (Mojave) | x64, ARM64 (Apple Silicon) |
| Linux | Ubuntu 20.04 LTS | x64, ARM64 |

## Desktop specifics

### Инициализация Desktop-приложения

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка системного бара (только macOS)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Настройка ориентации (для desktop — обычно landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const DesktopApp());
}
```

### Window Management

```dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowManagerService {
  /// Инициализация окна
  static Future<void> init() async {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      maximumSize: Size(1920, 1080),
      center: true,
      title: 'My Desktop App',
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// Получить размер окна
  static Future<Size> getSize() async {
    return await windowManager.getSize();
  }

  /// Установить размер окна
  static Future<void> setSize(Size size) async {
    await windowManager.setSize(size);
  }

  /// Получить позицию окна
  static Future<Offset> getPosition() async {
    return await windowManager.getPosition();
  }

  /// Установить позицию окна
  static Future<void> setPosition(Offset position) async {
    await windowManager.setPosition(position);
  }

  /// Максимизировать окно
  static Future<void> maximize() async {
    await windowManager.maximize();
  }

  /// Минимизировать окно
  static Future<void> minimize() async {
    await windowManager.minimize();
  }

  /// Восстановить окно
  static Future<void> restore() async {
    await windowManager.restore();
  }

  /// Закрыть окно
  static Future<void> close() async {
    await windowManager.close();
  }

  /// Всегда сверху
  static Future<void> setAlwaysOnTop(bool alwaysOnTop) async {
    await windowManager.setAlwaysOnTop(alwaysOnTop);
  }

  /// Полноэкранный режим
  static Future<void> fullscreen(bool fullscreen) async {
    await windowManager.setFullScreen(fullscreen);
  }

  /// Получить состояние fullscreen
  static Future<bool> isFullScreen() async {
    return await windowManager.isFullScreen();
  }
}
```

### Использование в приложении

```dart
class DesktopApp extends StatefulWidget {
  const DesktopApp({super.key});

  @override
  State<DesktopApp> createState() => _DesktopAppState();
}

class _DesktopAppState extends State<DesktopApp>
    with WindowListener {

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    WindowManagerService.init();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // Обработка закрытия окна
  @override
  void onWindowClose() async {
    // Запрос подтверждения закрытия
    bool close = await _showCloseConfirmation();
    if (close) {
      await windowManager.close();
    }
  }

  // Обработка восстановления после минимизации
  @override
  void onWindowRestore() {
    setState(() {});
  }

  // Обработка сворачивания
  @override
  void onWindowMinimize() {
    // Обработка сворачивания
  }

  Future<bool> _showCloseConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Закрыть приложение?'),
            content: const Text('Вы уверены, что хотите закрыть приложение?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desktop App',
      theme: ThemeData.dark(),
      home: const DesktopHome(),
    );
  }
}
```

## Platform-specific code

### Определение платформы

```dart
import 'package:flutter/foundation.dart';

class PlatformInfo {
  bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  bool get isDesktop => isWindows || isMacOS || isLinux;

  String get platformName {
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }

  String get osVersion {
    // Для получения версии ОС используйте Platform Channel
    return 'N/A';
  }
}
```

### Platform-specific настройки

```dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class PlatformSpecificConfig {
  /// Настройки для macOS (TitleBarStyle)
  static Future<void> configureForMacOS() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      // macOS Traffic Lights (кнопки закрыть/свернуть/развернуть)
    }
  }

  /// Настройки для Windows (Acrylic/Fluent)
  static Future<void> configureForWindows() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      // Windows 11: Mica/Acrylic эффект
      // Требует нативной интеграции через Platform Channel
    }
  }

  /// Настройки для Linux (GTK)
  static Future<void> configureForLinux() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      // Linux: интеграция с GTK theme
    }
  }
}
```

## Desktop-specific UI patterns

### Menu Bar

```dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class DesktopMenuBar extends StatelessWidget {
  const DesktopMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // File Menu
        _MenuButton(
          label: 'File',
          items: [
            _MenuItem(label: 'New', shortcut: 'ctrl+n', onTap: () {}),
            _MenuItem(label: 'Open...', shortcut: 'ctrl+o', onTap: () {}),
            _MenuDivider(),
            _MenuItem(label: 'Save', shortcut: 'ctrl+s', onTap: () {}),
            _MenuItem(label: 'Save As...', shortcut: 'ctrl+shift+s', onTap: () {}),
            _MenuDivider(),
            _MenuItem(label: 'Exit', shortcut: 'alt+f4', onTap: () async {
              await windowManager.close();
            }),
          ],
        ),
        // Edit Menu
        _MenuButton(
          label: 'Edit',
          items: [
            _MenuItem(label: 'Undo', shortcut: 'ctrl+z', onTap: () {}),
            _MenuItem(label: 'Redo', shortcut: 'ctrl+y', onTap: () {}),
            _MenuDivider(),
            _MenuItem(label: 'Cut', shortcut: 'ctrl+x', onTap: () {}),
            _MenuItem(label: 'Copy', shortcut: 'ctrl+c', onTap: () {}),
            _MenuItem(label: 'Paste', shortcut: 'ctrl+v', onTap: () {}),
          ],
        ),
        const Spacer(),
        // Window controls (macOS style)
        if (defaultTargetPlatform == TargetPlatform.macOS)
          Row(
            children: [
              _WindowButton(color: Colors.red, onTap: () async {
                await windowManager.close();
              }),
              const SizedBox(width: 8),
              _WindowButton(color: Colors.orange, onTap: () async {
                final isMinimized = await windowManager.isMinimized();
                if (isMinimized) {
                  await windowManager.restore();
                } else {
                  await windowManager.minimize();
                }
              }),
              const SizedBox(width: 8),
              _WindowButton(color: Colors.green, onTap: () async {
                final isMaximized = await windowManager.isMaximized();
                if (isMaximized) {
                  await windowManager.restore();
                } else {
                  await windowManager.maximize();
                }
              }),
            ],
          ),
      ],
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final List<Widget> items;

  const _MenuButton({required this.label, required this.items});

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {},
            child: Text(widget.label),
          ),
          if (_isHovered)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.items,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final String? shortcut;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    this.shortcut,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Row(
        children: [
          Expanded(child: Text(label)),
          if (shortcut != null)
            Text(
              shortcut!,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: Colors.grey.shade300);
  }
}

class _WindowButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _WindowButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
```

### System Tray

```dart
// Для System Tray используйте пакет: system_tray
// pubspec.yaml:
// dependencies:
//   system_tray: ^2.0.0

// Пример использования:
/*
import 'package:system_tray/system_tray.dart';

class SystemTrayService {
  SystemTray? _systemTray;

  Future<void> init() async {
    _systemTray = SystemTray();

    await _systemTray?.init(
      menu: await MenuBuilder().build(),
      iconPath: 'assets/icon.ico',
    );

    _systemTray?.setToolTip('My Desktop App');
  }

  Future<void> showNotification(String title, String message) async {
    await _systemTray?.showNotification(title, message);
  }
}
*/
```

## Desktop Deployment

### Сборка для разных платформ

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release

# Все платформы
flutter build windows --release && \
flutter build macos --release && \
flutter build linux --release
```

### Артефакты сборки

| Платформа | Путь | Формат |
|-----------|------|--------|
| Windows | `build/windows/x64/runner/Release/` | .exe |
| macOS | `build/macos/Build/Products/Release/` | .app |
| Linux | `build/linux/x64/release/bundle/` | .deb, .tar.gz |

## Best Practices

1. **Используйте `window_manager`** — для управления окном:
   ```dart
   await windowManager.ensureInitialized();
   await windowManager.setSize(const Size(1200, 800));
   ```

2. **Обрабатывайте события окна** — используйте `WindowListener`:
   ```dart
   class _MyState extends State<MyApp> with WindowListener {
     @override
     void onWindowClose() async { /* обработка */ }
   }
   ```

3. **Настройте минимальный размер** — для удобства использования:
   ```dart
   await windowManager.setMinimumSize(const Size(800, 600));
   ```

4. **Используйте нативные меню** — для десктопного UX:
   ```dart
   // File, Edit, View, Help — стандартные десктопные меню
   ```

5. **Поддерживайте тёмную/светлую тему** — следуйте системной теме:
   ```dart
   @override
   void didChangePlatformBrightness() {
     setState(() {});
   }
   ```

6. **Тестируйте на всех десктоп платформах** — поведение может отличаться.

7. **Используйте `defaultTargetPlatform`** — для платформенного кода:
   ```dart
   if (defaultTargetPlatform == TargetPlatform.macOS) {
     // macOS-specific
   }
   ```

8. **Оптимизируйте производительность** — desktop-приложения могут быть ресурсоёмкими.

9. **Добавьте автообновление** — для десктопных приложений это важно.

10. **Следуйте гайдлайнам каждой платформы** — Human Interface Guidelines (macOS), Fluent Design (Windows), HIG (Linux).
