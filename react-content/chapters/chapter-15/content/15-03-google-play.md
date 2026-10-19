# Публикация в Google Play Store

## Введение

Google Play Store — крупнейший магазин приложений для Android. Публикация приложения требует подготовки, соблюдения правил платформы и правильного следования процессу релиза.

## Подготовка аккаунта

### Регистрация разработчика

1. Перейдите на [Google Play Console](https://play.google.com/console)
2. Зарегистрируйте аккаунт разработчика ($25 — единовременный платёж)
3. Заполните профиль разработчика (название, email, адрес)
4. Подтвердите личность

### Создание приложения

1. Нажмите **Создать приложение**
2. Укажите название приложения
3. Выберите язык
4. Укажите категорию приложения
5. Выберите тип монетизации (с рекламой / без рекламы / платное)
6. Примите условия распределения

## Настройка приложения в Play Console

### Основная информация

**Файл: `android/app/src/main/AndroidManifest.xml`**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="YourApp"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

**Файл: `pubspec.yaml`**

```yaml
name: your_app
description: Описание вашего приложения
version: 1.0.0+1    # version+build_number

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
```

### Скриншоты и графические материалы

| Элемент | Размер | Количество |
|---------|--------|------------|
| Иконка приложения | 512×512 px | 1 |
| Скриншот телефона (большие) | 1080×1920 px | 2–8 |
| Скриншот телефона (маленькие) | 400×800 px | 2–8 |
| Скриншот планшета | 1280×800 px | 2 |
| Промо-баннер | 1024×500 px | 1 |
| Видео-трейлер | до 30 секунд | 1 |

### Классификация контента

Заполните анкету классификации:
- Возрастная категория
- Тип собираемых данных
- Наличие рекламы
- Типы разрешений
- Целевая аудитория

## Процесс релиза

### Типы релизов

| Тип | Описание | Доступ |
|-----|----------|--------|
| Production | Основной релиз для всех пользователей | Открытый доступ |
| Internal | Внутреннее тестирование | До 100 тестировщиков |
| Closed | Закрытое тестирование | Зарегистрированные тестировщики |
| Open | Открытое тестирование | Любой пользователь |
| Beta | Бета-версия | Любой пользователь |

### Создание релиза

```bash
# 1. Сборка AAB
flutter build appbundle --release

# 2. Проверка подписи
apksigner verify --verbose \
  build/app/outputs/bundle/release/app-release.aab

# 3. Загрузка в Play Console
# - Перейдите в Release → Production (или Testing)
# - Создайте новый релиз
# - Загрузите AAB файл
# - Заполните примечания к релизу
```

### Примечания к релизу (Release Notes)

```
Версия 1.0.0:
• Начальная публикация приложения
• Основной функционал:
  - Регистрация и авторизация
  - Просмотр каталога
  - Оформление заказов
• Исправления ошибок из бета-версии
```

## Каналы доставки (Release Tracks)

### Настройка каналов

```
Production (основной канал)
├── 1.0.0+10 — стабильная версия
├── 1.0.1+11 — исправления
└── 1.1.0+12 — новые функции

Beta (бета-канал)
├── 1.2.0+13 — новые функции для тестирования
└── 1.2.1+14 — исправления багов

Internal (внутренний канал)
├── 1.3.0+15 — экспериментальные функции
└── 1.3.1+16 — горячие исправления
```

### Автоматизация релизов

```yaml
# .github/workflows/play-store-release.yml
name: Release to Google Play

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x.x'

      - name: Build AAB
        run: |
          flutter pub get
          flutter build appbundle --release

      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT }}
          packageName: com.yourcompany.yourapp
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: production
          status: completed
```

## Best Practices

- **Используйте AAB**, а не APK для Google Play
- **Тестируйте в Internal Testing** перед production релизом
- **Пишите понятные release notes** для пользователей
- **Используйте feature flags** для постепенного включения функций
- **Мониторьте метрики** после публикации (краши, отзывы, рейтинги)
- **Следите за политикой** Google Play — правила регулярно обновляются
