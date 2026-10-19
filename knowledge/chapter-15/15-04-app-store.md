# Публикация в Apple App Store

## Введение

Apple App Store — официальный магазин приложений для iOS. Публикация требует аккаунта разработчика Apple, соблюдения строгих правил审核 и использования инструментов Xcode.

## Подготовка аккаунта

### Apple Developer Program

1. **Регистрация** — $99/год на [developer.apple.com](https://developer.apple.com/program/)
2. **Аккаунт организации** — требуется DUNS номер для корпоративных аккаунтов
3. **Вход в App Store Connect** — https://appstoreconnect.apple.com

### Создание App ID

1. Перейдите в **Certificates, Identifiers & Profiles**
2. Выберите **Identifiers** → **+**
3. Выберите тип **App IDs**
4. Укажите описание и Bundle ID
5. Включите необходимые сервисы (Push Notifications, In-App Purchase и т.д.)

```
Bundle ID формат: com.companyname.appname
Пример: com.mycompany.weatherapp
```

## Настройка Flutter проекта для iOS

### Файл: `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>YourApp</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>your_app</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>NSCameraUsageDescription</key>
    <string>Нужно для сканирования QR-кодов</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Нужно для определения местоположения</string>
</dict>
</plist>
```

### Файл: `ios/Runner.xcodeproj/project.pbxproj`

```
// Bundle version
PRODUCT_BUNDLE_IDENTIFIER = com.mycompany.weatherapp;

// Deployment target
IPHONEOS_DEPLOYMENT_TARGET = 13.0;

// Code signing
CODE_SIGN_STYLE = Automatic;
DEVELOPMENT_TEAM = YOUR_TEAM_ID;
```

## Архивирование через Xcode

### Ручное архивирование

1. Откройте проект в Xcode: `ios/Runner.xcworkspace`
2. Выберите устройство **Any iOS Device (arm64)**
3. Меню: **Product → Archive**
4. После завершения откроется Organizer
5. Нажмите **Distribute App**

### Распределение (Distribute App)

**Этапы распределения:**

```
1. Выбор метода:
   ├── App Store Connect (для публикации)
   ├── Ad Hoc (для тестирования)
   ├── Development (для разработки)
   └── Enterprise (для корпоративного использования)

2. Проверка экспорта:
   └── Xcode автоматически проверит проблемы

3. Загрузка:
   └── Xcode загрузит архив в App Store Connect
```

### Архивирование через командную строку

```bash
# Установка Flutter и настройка
flutter build ios --release --no-codesign

# Архивирование через xcodebuild
xcodebuild archive \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -sdk iphoneos \
  -archivePath build/Runner.xcarchive \
  ONLY_ACTIVE_ARCH=NO

# Экспорт для App Store
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build/ipa \
  -exportOptionsPlist ios/exportOptions.plist

# Загрузка в App Store через altool
xcrun altool --upload-app \
  -f build/ipa/YourApp.ipa \
  -t ios \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

**Файл: `ios/exportOptions.plist`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.mycompany.weatherapp</key>
        <string>com.mycompany.weatherapp</string>
    </dict>
</dict>
</plist>
```

## App Store Connect — настройка релиза

### Создание версии релиза

1. Откройте приложение в App Store Connect
2. Перейдите в **App Store** вкладку
3. Выберите **iOS App**
4. Нажмите **+ Версия** для создания новой версии

### Метаданные приложения

| Поле | Описание |
|------|----------|
| Название | До 30 символов |
| Подзаголовок | До 30 символов |
| Описание | До 4000 символов |
| Ключевые слова | До 100 символов (без запятых) |
| Категория | Основная и дополнительная |
| Возрастной рейтинг | Определяется автоматически или вручную |

### Скриншоты для App Store

| Устройство | Размер | Минимум |
|------------|--------|---------|
| iPhone 6.7" | 1290×2796 px | 1 |
| iPhone 6.5" | 1242×2208 px | 1 |
| iPhone 5.5" | 1242×2208 px | 1 |
| iPad 12.9" | 2048×2732 px | 1 |
| iPad 10.9" | 1640×2360 px | 1 |

### Настройка прайсинга и доступности

```
Доступность:
├── Выберите страны/регионы
├── Установите прайс-лист (бесплатно / платно)
├── Укажите возрастную классификацию
└── Настройте подписки (если есть)

Субтитры:
├── До 10 языков для описания
└── До 45 символов на подзаголовок
```

## Процесс审核 (Review)

### Типы审核

| Тип | Время审核 | Описание |
|-----|-----------|----------|
| Standard | 24–48 часов | Стандартный审核 |
| Priority | Несколько часов | Для критических исправлений |
| App Preview | 24–48 часов | Включает видео и screenshots |

### Частые причины отклонения

1. **Баги и крэши** — приложение должно быть стабильным
2. **Неполная информация** — заполните все поля
3. **Нарушение гайдлайнов** — изучите Human Interface Guidelines
4. **Проблемы с учётной записью** — обновите информацию
5. **Внешние ссылки** — не должны вести на другие магазины

### Ответ на审核

```
Если审核 получил замечания:
1. Исправьте указанные проблемы
2. Обновите build в App Store Connect
3. Ответьте на каждый пункт审核
4. Отправьте на повторный审核
```

## Автоматизация с Fastlane

### Файл: `Fastfile`

```ruby
default_platform(:ios)

platform :ios do
  desc "Submit a new build to App Store Connect"
  lane :release do
    # Сборка проекта
    flutter_build(
      target: "lib/main.dart",
      release: true,
      build_name: "1.0.0",
      build_number: "1"
    )

    # Архивирование
    archive(
      workspace: "ios/Runner.xcworkspace",
      scheme: "Runner",
      configuration: "Release",
      export_options: {
        method: "app-store",
        uploadSymbols: true
      }
    )

    # Загрузка в App Store Connect
    upload_to_app_store(
      skip_metadata: false,
      skip_screenshots: true,
      force: true
    )

    # Отправка на审核
    submit_to_app_store(
      force: true
    )
  end

  desc "Build and upload TestFlight build"
  lane :beta do
    flutter_build(
      target: "lib/main.dart",
      release: true
    )

    build_app(
      workspace: "ios/Runner.xcworkspace",
      scheme: "Runner",
      configuration: "Release",
      export_options: {
        method: "app-store",
        uploadSymbols: true
      }
    )

    upload_to_testflight(
      skip_waiting_for_build_size: true
    )
  end
end
```

### Запуск Fastlane

```bash
# Установка
bundle install

# Релиз в App Store
bundle exec fastlane release

# Бета-версия в TestFlight
bundle exec fastlane beta
```

## Best Practices

- **Используйте Xcode Archive** — это надёжный способ подготовки
- **Тестируйте в TestFlight** перед отправкой на审核
- **Подготавливайте метаданные заранее** — это ускоря审核
- **Следите за гайдлайнами** — правила审核 регулярно обновляются
- **Используйте Fastlane** для автоматизации релизов
- **Мониторьте отзывы и рейтинги** после публикации
