# 1.4 Установка и настройка окружения (Flutter SDK, IDE, эмулятор)

## Системные требования

### Windows
- **ОС**: Windows 10 или новее (64-bit)
- **Диск**: 2.82 ГБ (плюс место для IDE и эмуляторов)
- **RAM**: 8 ГБ минимум
- **PowerShell**: версия 5.0+

### macOS
- **ОС**: macOS 10.15 или новее
- **Диск**: 3.0 ГБ
- **RAM**: 8 ГБ минимум
- **Xcode**: для iOS-разработки

### Linux
- **ОС**: Ubuntu 20.04 или новее (другие дистрибутивы тоже поддерживаются)
- **Диск**: 2.8 ГБ
- **RAM**: 8 ГБ минимум

## Шаг 1: Установка Flutter SDK

### Скачивание

1. Перейти на [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. Скачать архив для вашей платформы
3. Распаковать в предпочитаемую директорию

### Настройка PATH

**Windows (PowerShell):**
```powershell
# Добавить Flutter в PATH
$env:Path += ";C:\src\flutter\bin"

# Для постоянной настройки:
# Settings → System → About → Advanced system settings → Environment Variables
# Добавить системную переменную FLUTTER_ROOT = C:\src\flutter
# Добавить в Path: %FLUTTER_ROOT%\bin
```

**macOS/Linux (bash/zsh):**
```bash
# Добавить в ~/.bashrc или ~/.zshrc
export PATH="$PATH:`pwd`/flutter/bin"
source ~/.bashrc  # или ~/.zshrc
```

### Проверка установки

```bash
flutter doctor
```

Эта команда проверяет окружение и показывает, что нужно установить/настроить.

## Шаг 2: Установка IDE

### Android Studio (рекомендуется)

1. Скачать с [androidstudio.google.com](https://developer.android.com/studio)
2. Установить плагины:
   - **Flutter** — основная поддержка фреймворка
   - **Dart** — поддержка языка
3. Плагины устанавливаются через:
   - `File → Settings → Plugins → Marketplace`
   - Поиск: «Flutter» и «Dart»
   - Установка и перезапуск IDE

### VS Code

1. Скачать с [code.visualstudio.com](https://code.visualstudio.com)
2. Установить расширения:
   - **Flutter** (от Dart Code)
   - **Dart** (от Dart Code)

### IntelliJ IDEA / PyCharm Pro

- Поддержка Flutter встроена в Professional версии
- Установить плагины Flutter и Dart через Settings → Plugins

## Шаг 3: Настройка эмулятора

### Android Emulator

1. Открыть Android Studio
2. `Tools → Device Manager`
3. `Create Device` — выбрать виртуальное устройство (Pixel 5, Nexus 6P и т.д.)
4. Скачать системный образ (рекомендуется API 33+)
5. Запустить эмулятор

### iOS Simulator (только macOS)

1. Установить Xcode из App Store
2. Симулятор доступен через:
   - Android Studio → Device Manager
   - Терминал: `open -a Simulator`
   - Xcode → Window → Devices and Simulators

### Desktop эмуляторы

- **Windows/macOS/Linux** — приложения запускаются нативно на десктоп-платформе
- Дополнительная настройка не требуется

## Шаг 4: Flutter doctor — проверка

```bash
flutter doctor
```

**Пример вывода:**
```
Doctor summary (to see all details, run flutter doctor -v):
 
[√] Flutter (Channel stable, 3.x.x, on Microsoft Windows)
[√] Windows version (installed)
[√] Android toolchain - develop for Android devices
[√] Chrome - develop for the web
[!] Android Studio (not configured)
[√] VS Code
[!] Connected device
    ! No issues found!
```

**Красные/восклицательные знаки** означают, что нужно что-то доустановить или настроить.

## Шаг 5: Создание первого проекта

```bash
flutter create my_app
cd my_app
flutter run
```

## Распространённые проблемы

### `flutter doctor` показывает ошибки

- **Android SDK**: установить через Android Studio SDK Manager
- **Java/SDK**: установить JDK через Android Studio
- **Android License**: `flutter doctor --android-licenses`
- **Chrome**: установить Chrome для веб-разработки

### Эмулятор не запускается

- Включить виртуализацию в BIOS (Intel VT-x / AMD-V)
- Проверить свободное место на диске
- Обновить HAXM (Windows) или Hyper-V

### Медленная загрузка эмулятора

- Использовать эмулятор с **Google Play** образом (оптимизирован)
- Включить **Hardware Acceleration**
- Использовать **snapshot** эмулятора

## Заключение

Правильная настройка окружения — основа продуктивной разработки. Регулярно запускайте `flutter doctor` для контроля состояния окружения.
