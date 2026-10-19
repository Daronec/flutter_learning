# Flutter Desktop — Windows, macOS, Linux

## Введение

Flutter поддерживает десктопные приложения для Windows, macOS и Linux. Деплой десктопных приложений имеет свои особенности по сравнению с мобильными платформами.

## Включение поддержки Desktop

### Инициализация проектов

```bash
# Создание нового проекта с поддержкой desktop
flutter create my_app --platforms=windows,macos,linux

# Добавление desktop в существующий проект
flutter create . --platforms=windows,macos,linux

# Проверка поддерживаемых платформ
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

### Требования по платформам

| Платформа | Требования |
|-----------|-----------|
| Windows | Windows 10+, Visual Studio 2019+ |
| macOS | macOS 10.15+, Xcode 12+, Flutter SDK |
| Linux | Ubuntu 20.04+, GTK3, CMake 3.10+ |

## Сборка десктопных приложений

### Windows

```bash
# Сборка Windows приложения
flutter build windows --release

# Сборка с указанием конфигурации
flutter build windows --release --dart-define=ENV=production

# Результат:
# build/windows/x64/runner/Release/
# ├── MyApp.exe
# ├── MyApp.pdb
# ├── data/
# │   ├── flutter_assets/
# │   └── icudtl.dat
# └── lib/
```

**Создание установщика (Inno Setup):**

```ini
; setup.iss — Inno Setup скрипт
[Setup]
AppName=MyApp
AppVersion=1.0.0
AppPublisher=MyCompany
AppSupportURL=https://example.com
DefaultDirName={autopf}\MyApp
OutputDir=build\windows\installer
OutputBaseFilename=MyApp-Setup

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{userdesktop}\MyApp"; Filename: "{app}\MyApp.exe"

[Run]
Filename: "{app}\MyApp.exe"; Description: "Launch MyApp"; Flags: nowait postinstall skipifsilent
```

**Сборка установщика:**

```bash
# Установка Inno Setup: https://jrsoftware.org/isinfo.php
# Компиляция скрипта
iscc setup.iss

# Результат: build/windows/installer/MyApp-Setup.exe
```

### macOS

```bash
# Сборка macOS приложения
flutter build macos --release

# Результат:
# build/macos/Build/Products/Release/
# ├── MyApp.app
# │   ├── Contents/
# │   │   ├── Info.plist
# │   │   ├── MacOS/
# │   │   │   └── MyApp
# │   │   ├── Resources/
# │   │   └── Flutter/
# │   │       ├── App.framework
# │   │       └── flutter_assets/
# └── MyApp.app.zip
```

**Подписание и notarization:**

```bash
# Подписание приложения
codesign --deep --force --sign "Developer ID Application: Your Name" \
  build/macos/Build/Products/Release/MyApp.app

# Проверка подписи
codesign --verify --deep --strict --verbose=2 MyApp.app

# Создание архива
ditto -c -k --keepParent build/macos/Build/Products/Release/MyApp.app MyApp.zip

# Notarization (отправка на проверку Apple)
xcrun notarytool submit MyApp.zip \
  --keychain-profile "notary" \
  --wait

# Stapling (прикрепление ticket к приложению)
xcrun stapler staple MyApp.app
```

### Linux

```bash
# Установка зависимостей для Linux
sudo apt-get install -y \
  cmake \
  ninja-build \
  libgtk-3-dev \
  libwlroots-dev \
  libwayland-dev \
  libxkbcommon-dev \
  libasound2-dev \
  libdbus-1-dev

# Сборка Linux приложения
flutter build linux --release

# Результат:
# build/linux/x64/release/bundle/
# ├── MyApp
# ├── MyApp.desktop
# ├── icons/
# │   ├── 128x128.png
# │   ├── 256x256.png
# │   └── ...
# └── data/
#     └── flutter_assets/
```

**Создание deb пакета:**

```bash
# Создание структуры пакета
mkdir -p build/linux/deb/myapp/DEBIAN
mkdir -p build/linux/deb/myapp/usr/share/applications
mkdir -p build/linux/deb/myapp/usr/share/icons/hicolor/256x256/apps
mkdir -p build/linux/deb/myapp/usr/bin

# Копирование файлов
cp build/linux/x64/release/bundle/MyApp build/linux/deb/myapp/usr/bin/
cp build/linux/x64/release/bundle/MyApp.desktop \
  build/linux/deb/myapp/usr/share/applications/
cp build/linux/x64/release/bundle/icons/256x256.png \
  build/linux/deb/myapp/usr/share/icons/hicolor/256x256/apps/myapp.png

# Создание control файла
cat > build/linux/deb/myapp/DEBIAN/control << EOF
Package: myapp
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Maintainer: Your Name <you@example.com>
Description: Flutter Desktop Application
 Depends: libgtk-3-0, libwayland-client0, libxkbcommon0
EOF

# Сборка deb пакета
dpkg-deb --build build/linux/deb/myapp/
# Результат: myapp.deb
```

**Создание AppImage:**

```bash
# Установка linuxdeploy
wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage

# Создание AppImage
./linuxdeploy-x86_64.AppImage \
  --appdir AppDir \
  --executable build/linux/x64/release/bundle/MyApp \
  --desktop-file build/linux/x64/release/bundle/MyApp.desktop \
  --icon-file build/linux/x64/release/bundle/icons/256x256.png \
  --output appimage
```

## Дистрибуция

### Способы распространения

| Платформа | Формат | Описание |
|-----------|--------|----------|
| Windows | .exe (установщик) | Inno Setup, NSIS, WiX |
| Windows | .zip (portable) | Простая архивация |
| macOS | .dmg | Дисковый образ |
| macOS | .app | Приложение для drag-and-drop |
| Linux | .deb | Debian/Ubuntu пакеты |
| Linux | .rpm | Fedora/RHEL пакеты |
| Linux | .AppImage | Универсальный формат |
| Linux | .snap | Snap пакет |
| Linux | .flatpak | Flatpak пакет |

### GitHub Releases

```yaml
# .github/workflows/desktop-release.yml
name: Desktop Release

on:
  push:
    tags:
      - 'v*'

jobs:
  windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - name: Build Windows
        run: flutter build windows --release
      - name: Create Installer
        run: iscc setup.iss
      - uses: softprops/action-gh-release@v1
        with:
          files: build/windows/installer/*.exe

  macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - name: Build macOS
        run: flutter build macos --release
      - uses: softprops/action-gh-release@v1
        with:
          files: build/macos/Build/Products/Release/*.app.zip

  linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - name: Build Linux
        run: flutter build linux --release
      - uses: softprops/action-gh-release@v1
        with:
          files: build/linux/x64/release/bundle/*.AppImage
```

## Best Practices

- **Тестируйте на каждой платформе** отдельно
- **Используйте нативные диалоги** для каждой ОС
- **Настройте автообновление** для десктопных приложений
- **Следите за размерами** — десктопные приложения могут быть большими
- **Используйте нативные иконки** и заголовки окон
- **Проверяйте права доступа** (macOS sandbox, Windows UAC)
