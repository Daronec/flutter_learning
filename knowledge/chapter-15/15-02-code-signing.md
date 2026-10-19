# Подписание приложения (Code Signing)

## Введение

Подписание кода (code signing) — это процесс цифровой подписи приложения, который подтверждает авторство и гарантирует целостность кода. Без правильной подписи приложение не может быть установлено на устройство или опубликовано в магазине.

## Зачем нужно подписание

- **Идентификация разработчика** — подтверждает, кто создал приложение
- **Целостность кода** — гарантирует, что код не был изменён после подписания
- **Требование платформ** — Android и iOS требуют подписи для установки
- **Доверие пользователей** — пользователи видят имя разработчика при установке

## Android — подписание приложения

### Создание Keystore

Keystore — это защищённый хранилище ключей, содержащий пары открытых и закрытых ключей.

```bash
# Создание keystore через keytool (входит в JDK)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload

# Параметры:
# -genkey -v : генерация нового ключа с подробным выводом
# -keystore : путь к файлу хранилища
# -storetype JKS : тип хранилища (JKS или PKCS12)
# -keyalg RSA : алгоритм ключа
# -keysize 2048 : размер ключа (минимум 2048 бит)
# -validity 10000 : срок действия в днях (~27 лет)
# -alias upload : псевдоним ключа
```

### Создание Keystore через Flutter

```bash
# Flutter может создать keystore автоматически
flutter build apk --release --flavor production

# При первом запуске Flutter предложит создать keystore
# Введите:
# 1. Путь к keystore файлу (или оставьте для авто-создания)
# 2. Пароль хранилища
# 3. Псевдоним ключа
# 4. Пароль ключа
# 5. Срок действия (дни)
```

### Настройка Gradle для подписания

**Файл: `android/key.properties`**

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

> **Важно:** Добавьте `key.properties` в `.gitignore` для защиты паролей!

**Файл: `android/app/build.gradle`**

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    defaultConfig {
        // ...
    }

    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
                storePassword keystoreProperties['storePassword']
            }
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Подписание через командную строку

```bash
# Подписание APK вручную
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore upload-keystore.jks \
  -storepass your_store_password \
  -keypass your_key_password \
  app-release-unsigned.apk \
  upload

# Выравнивание APK (обязательный шаг)
zipalign -v 4 app-release-unsigned.apk app-release.apk

# Проверка подписи
apksigner verify --verbose app-release.apk
```

## iOS — подписание приложения

### Требования для iOS подписания

Для подписания iOS-приложения необходимы:

1. **Apple Developer Program** — подписка за $99/год
2. **Developer Identity** — сертификат разработчика
3. **App ID** — уникальный идентификатор приложения
4. **Provisioning Profile** — профиль распределения
5. **Distribution Certificate** — сертификат для публикации

### Создание сертификатов

**Через Xcode:**

1. Откройте Xcode → Preferences → Accounts
2. Войдите в Apple ID
3. Выберите team и нажмите **Download Manual Signing Profiles**

**Через командную строку:**

```bash
# Список доступных сертификатов
security find-identity -v -p codesigning

# Создание запроса на подпись (CSR)
openssl req -newkey rsa:2048 -nodes \
  -keyout private.key \
  -out CertificateSigningRequest.certSigningRequest \
  -subj "/emailAddress=you@example.com,CN=YourName,C=US"

# Проверка подписи кода
codesign -dvvv YourApp.app
```

### Provisioning Profile

Provisioning Profile связывает сертификат, App ID и устройства.

**Типы provisioning profile:**

| Тип | Назначение |
|-----|-----------|
| Development | Тестирование на зарегистрированных устройствах |
| Distribution (App Store) | Публикация в App Store |
| Distribution (Ad Hoc) | Распространение до 100 устройств |
| Distribution (Enterprise) | Внутреннее использование в компании |

**Управление через xcodebuild:**

```bash
# Список provisioning profiles
security cms -D -i YourApp.mobileprovision

# Автоматическое управление подписью в Xcode
xcodebuild archive \
  -scheme YourApp \
  -archivePath build/YourApp.xcarchive \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build/derivedData

# Архивирование
xcodebuild archive \
  -workspace YourApp.xcworkspace \
  -scheme YourApp \
  -configuration Release \
  -archivePath build/YourApp.xcarchive \
  -sdk iphoneos

# Экспорт архива
xcodebuild -exportArchive \
  -archivePath build/YourApp.xcarchive \
  -exportPath build/exported \
  -exportOptionsPlist exportOptions.plist
```

### exportOptions.plist

**Файл: `exportOptions.plist`**

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
        <key>com.yourcompany.yourapp</key>
        <string>YourApp Distribution</string>
    </dict>
</dict>
</plist>
```

## Сравнение подходов к подписанию

| Параметр | Android | iOS |
|----------|---------|-----|
| Формат ключа | JKS / PKCS12 | P12 / CER |
| Хранилище | Keystore файл | Keychain (macOS) |
| Срок действия | Настраиваемый | 1 год (сертификат) |
| Стоимость | Бесплатно | $99/год |
| Автоматизация | Gradle | Xcode / Fastlane |

## Best Practices

- **Безопасное хранение keystore** — используйте защищённое хранилище, не коммитьте в Git
- **Резервные копии** — храните копии keystore и provisioning profile в безопасном месте
- **Срок действия** — обновляйте ключи до истечения срока
- **CI/CD** — используйте секреты для хранения паролей в пайплайнах
- **Разделение ключей** — используйте разные ключи для development и release
- **Документирование** — ведите учёт всех сертификатов и их сроков действия
