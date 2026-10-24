---
tags:
  - build
  - deployment
  - ci-cd
chapter: 15
section: 8
title: Versioning и релизные ветки
alias: 15 08 versioning
status: complete
---

# Versioning и релизные ветки

## Введение

Правильная стратегия версионирования и управления ветками — основа успешного процесса разработки. Она обеспечивает предсказуемость релизов, упрощает отладку и помогает команде координировать работу.

## Семантическое версионирование (Semantic Versioning)

### Формат версии

```
MAJOR.MINOR.PATCH
 1.0.0

MAJOR — incompatible API changes (несовместимые изменения)
MINOR — backwards-compatible functionality (новые функции)
PATCH — backwards-compatible bug fixes (исправления багов)
```

### Правила увеличения версии

| Изменение | Тип | Пример |
|-----------|-----|--------|
| Удаление публичного API | MAJOR | 1.0.0 → 2.0.0 |
| Несоответствующее изменение API | MAJOR | 1.0.0 → 2.0.0 |
| Новая обратносвязная функция | MINOR | 1.0.0 → 1.1.0 |
| Обратносвязное исправление бага | PATCH | 1.0.0 → 1.0.1 |
| Предварительный релиз | Pre-release | 1.0.0-alpha.1 |
| Сборка (build metadata) | Build | 1.0.0+20231015 |

### Предварительные версии

```
Формат: MAJOR.MINOR.PATCH-prerelease+build

Примеры:
1.0.0-alpha.1      — первая альфа-версия
1.0.0-beta.2       — вторая бета-версия
1.0.0-rc.1         — первая версия для релиз-кандидата
1.0.0-rc.1+20231015 — с метаданными сборки
1.0.0              — финальная версия
```

**Порядок предварительных версий:**

```
alpha < beta < rc < release
```

## Версионирование в Flutter

### pubspec.yaml

```yaml
name: my_app
description: Описание приложения
version: 1.2.3+42    # version+build_number

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.1.0
```

**Формат: `version+build_number`**

| Часть | Описание | Пример |
|-------|----------|--------|
| version | Семантическая версия | 1.2.3 |
| build_number | Уникальный номер сборки | 42 |

### Автоматическое управление версиями

**Пакет: `auto_version`**

```yaml
# pubspec.yaml
dev_dependencies:
  auto_version: ^1.0.0
```

```dart
// lib/version.dart
class AppVersion {
  static const String version = '1.2.3';
  static const String buildNumber = '42';
  static const String fullVersion = '1.2.3+42';
}
```

**Пакет: `flutter_version_name`**

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_version_name: ^1.0.0
```

### Автоматизация через CI/CD

```yaml
# .github/workflows/version-bump.yml
name: Bump Version

on:
  push:
    branches: [main]
    paths:
      - 'lib/**'

jobs:
  bump-version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Bump patch version
        id: bump
        run: |
          # Чтение текущей версии
          VERSION=$(grep '^version:' pubspec.yaml | head -1 | awk '{print $2}')
          MAJOR=$(echo $VERSION | cut -d. -f1)
          MINOR=$(echo $VERSION | cut -d. -f2)
          PATCH=$(echo $VERSION | cut -d. -f3 | cut -d+ -f1)
          BUILD=$(echo $VERSION | cut -d+ -f2)

          # Увеличение patch
          NEW_PATCH=$((PATCH + 1))
          NEW_BUILD=$((BUILD + 1))
          NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}+${NEW_BUILD}"

          # Обновление pubspec.yaml
          sed -i "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml

          # Коммит
          git config user.name "CI Bot"
          git config user.email "ci@bot.com"
          git add pubspec.yaml
          git commit -m "Bump version to ${NEW_VERSION}"
          git push
```

## Стратегии управления ветками

### Git Flow

```
main (master)
  │
  ├── develop
  │   │
  │   ├── feature/login-screen
  │   ├── feature/dashboard
  │   ├── bugfix/fix-crash-123
  │   └── release/1.2.0
  │       │
  │       └── hotfix/fix-critical-bug
  │
  └── release/1.1.0
      │
      └── hotfix/fix-security-issue
```

**Описание веток:**

| Ветка | Назначение | Длительность |
|-------|-----------|-------------|
| main | Стабильный код, релизы | Постоянная |
| develop | Интеграция фич | Постоянная |
| feature/* | Новая функциональность | Дни–недели |
| release/* | Подготовка к релизу | Неделя |
| hotfix/* | Срочные исправления | Часы–дни |

**Пример работы с Git Flow:**

```bash
# Создание фичи
git checkout -b feature/user-profile develop

# Завершение фичи
git checkout develop
git merge --no-ff feature/user-profile
git branch -d feature/user-profile

# Начало релиза
git checkout -b release/1.2.0 develop

# Исправление в релизе
git checkout release/1.2.0
# ... исправления ...
git commit -m "Fix login validation"

# Завершение релиза
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Release 1.2.0"
git checkout develop
git merge --no-ff release/1.2.0

# Hotfix
git checkout main
git checkout -b hotfix/fix-login-crash
# ... исправление ...
git checkout main
git merge --no-ff hotfix/fix-login-crash
git tag -a v1.2.1 -m "Hotfix 1.2.1"
git checkout develop
git merge --no-ff hotfix/fix-login-crash
```

### GitHub Flow

```
main
  │
  ├── feature/add-search
  ├── feature/improve-performance
  └── hotfix/fix-memory-leak
```

**Описание:**
- Простая стратегия: только `main` + функциональные ветки
- Каждая ветка деплоится на staging
- После code review — мерж в main
- Идеально для веб-приложений и continuous deployment

### Trunk-Based Development

```
trunk (main)
  │
  ├── feature-branch (краткоживущая)
  ├── feature-branch (краткоживущая)
  └── feature-branch (краткоживущая)
```

**Принципы:**
- Короткоживущие ветки (1–2 дня)
- Частые мерджи в trunk
- Feature flags для скрытия незавершённого кода
- Непрерывная интеграция

## Релизная стратегия

### Типы релизов

| Тип | Частота | Стабильность | Пример |
|-----|---------|-------------|--------|
| Hotfix | По мере необходимости | Высокая | Исправление критического бага |
| Patch | Еженедельно | Высокая | Небольшие исправления |
| Minor | Ежемесячно | Средняя | Новые функции |
| Major | Ежеквартально | Средняя | Значительные изменения |

### Чеклист релиза

```
Подготовка к релизу:
□ Все фичи из milestone завершены
□ Код-ревью выполнены
□ Все тесты проходят
□ Документация обновлена
□ Release notes подготовлены
□ Версия увеличена в pubspec.yaml
□ Сборка протестирована на реальных устройствах
□ Performance проверена
□ Accessibility проверена

Публикация:
□ Сборка создана (APK/AAB для Android, Archive для iOS)
□ Подписание выполнено
□ Загрузка в магазин
□ Метаданные заполнены
□ Отправка на审核 (iOS)

После релиза:
□ Мониторинг крашей (Crashlytics)
□ Сбор обратной связи
□ Обновление документации
□ Планирование следующего спринта
```

## Управление зависимостями

### pubspec.yaml — правила версионирования

```yaml
# Тильда (~) — совместимость с minor
dependencies:
  http: ^1.1.0    # >=1.1.0 <2.0.0
  provider: ^6.1.0  # >=6.1.0 <7.0.0

# Карет (^) — совместимость с major
dependencies:
  flutter_svg: ^2.0.0  # >=2.0.0 <3.0.0

# Точная версия
dependencies:
  some_package: 1.2.3

# Путь к локальному пакету
dependencies:
  my_utils:
    path: ../my_utils

# Git
dependencies:
  my_package:
    git:
      url: https://github.com/user/package.git
      ref: main
```

### Обновление зависимостей

```bash
# Проверка устаревших пакетов
flutter pub outdated

# Обновление до последней совместимой версии
flutter pub upgrade --major-versions

# Обновление конкретного пакета
flutter pub upgrade http

# Lock-файл (не изменять вручную)
# pubspec.lock — автоматически генерируется
```

## Best Practices

- **Следуйте SemVer** для консистентности
- **Используйте теги Git** для каждой версии
- **Автоматизируйте версионирование** в CI/CD
- **Ведите CHANGELOG.md** с описанием изменений
- **Тестируйте в изолированных ветках** перед мержем
- **Используйте feature flags** для управления кодом
