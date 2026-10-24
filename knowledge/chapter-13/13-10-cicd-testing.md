---
tags:
  - testing
  - unit-tests
  - widget-tests
chapter: 13
section: 10
title: CI/CD для Flutter — автоматизация тестирования
alias: 13 10 cicd testing
status: complete
---

# CI/CD для Flutter — автоматизация тестирования

CI/CD (Continuous Integration / Continuous Deployment) — это практика автоматизации сборки, тестирования и развертывания приложений. Для Flutter-проектов CI/CD позволяет автоматически запускать тесты при каждом коммите и пул-реквесте.

## Что такое CI/CD

| Термин | Описание |
|--------|----------|
| CI (Continuous Integration) | Автоматическая сборка и тестирование при каждом коммите |
| CD (Continuous Deployment) | Автоматическое развертывание на продакшен |
| CD (Continuous Delivery) | Автоматическая подготовка к релизу |

## GitHub Actions для Flutter

### Базовый workflow

```yaml
# .github/workflows/flutter-ci.yml
name: Flutter CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - run: flutter pub get

      - name: Run unit tests
        run: flutter test test/

      - name: Run widget tests
        run: flutter test test/widget_tests/

      - name: Run all tests
        run: flutter test
```

### Workflow с покрытием кода

```yaml
# .github/workflows/flutter-coverage.yml
name: Flutter Coverage

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  coverage:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - run: flutter pub get

      - name: Run tests with coverage
        run: flutter test --coverage

      - name: Upload coverage report
        uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info
          flags: unittests
          name: flutter-coverage
```

### Workflow с несколькими платформами

```yaml
# .github/workflows/flutter-multi-platform.yml
name: Flutter Multi-Platform

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - run: flutter pub get
      - run: flutter test
      - run: flutter test integration_test/

  test-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - run: flutter pub get
      - run: flutter test
      - run: flutter test integration_test/

  test-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - run: flutter pub get
      - run: flutter test
      - run: flutter build web --release
```

## GitLab CI

### Базовый .gitlab-ci.yml

```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy

flutter_test:
  stage: test
  image: cirrusci/flutter:stable
  script:
    - flutter pub get
    - flutter test
    - flutter test test/widget_tests/
  artifacts:
    when: always
    reports:
      junit: test_report.xml
    paths:
      - coverage/

flutter_build:
  stage: build
  image: cirrusci/flutter:stable
  script:
    - flutter pub get
    - flutter build apk --release
    - flutter build ios --release --no-codesign
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-release.apk
      - build/ios/iphoneos/

flutter_deploy:
  stage: deploy
  image: cirrusci/flutter:stable
  script:
    - flutter pub get
    - flutter build apk --release
  only:
    - main
```

### GitLab CI с покрытием

```yaml
# .gitlab-ci.yml
test:
  stage: test
  image: cirrusci/flutter:stable
  script:
    - flutter pub get
    - flutter test --coverage
  artifacts:
    when: always
    paths:
      - coverage/
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura.xml
  coverage: '/Total:.*?([0-9]{1,3})%/'
```

## CircleCI

### Базовая конфигурация

```yaml
# .circleci/config.yml
version: 2.1

executors:
  flutter-executor:
    docker:
      - image: cirrusci/flutter:stable
    working_directory: /app

jobs:
  test:
    executor: flutter-executor
    steps:
      - checkout
      - run:
          name: Get dependencies
          command: flutter pub get
      - run:
          name: Run tests
          command: flutter test
      - store_test_results:
          path: test_report.xml
      - store_artifacts:
          path: coverage/

workflows:
  test_workflow:
    jobs:
      - test
```

## Bitrise

### Базовая конфигурация

```yaml
# bitrise.yml
format_version: 11
default_step_lib_source: https://github.com/bitrise-io/bitrise-steplib.git
project_type: flutter

workflows:
  test:
    steps:
      - activate-ssh-key@4:
          run_if: '{{getenv "SSH_RSA_PRIVATE_KEY" | ne ""}}'
      - git-clone@6: {}
      - flutter-installer@0: {}
      - flutter-tester@0: {}
      - flutter-test@2:
          inputs:
            - flutter_test_args: "--coverage"
      - flutter-archive@1:
          inputs:
            - project_path: "."
            - build_targets: "APK"
```

## Codemagic

### Базовая конфигурация

```yaml
# codemagic.yaml
workflows:
  test-and-build:
    name: Test and Build
    max_build_time: 60
    environment:
      flutter: stable
      xcode: latest
      jdk: 17

    scripts:
      - name: Get dependencies
        script: flutter pub get
      - name: Run tests
        script: flutter test
      - name: Run widget tests
        script: flutter test test/widget_tests/
      - name: Build APK
        script: flutter build apk --release
      - name: Build iOS
        script: flutter build ios --release --no-codesign

    artifacts:
      - build/app/outputs/flutter-apk/app-release.apk
      - build/ios/iphoneos/*.ipa

    publishing:
      email:
        recipients:
          - dev@example.com
      slack:
        channel: '#releases'
```

## Jenkins

### Базовый Jenkinsfile

```groovy
// Jenkinsfile
pipeline {
    agent any

    environment {
        FLUTTER_VERSION = '3.24.0'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Setup Flutter') {
            steps {
                script {
                    sh '''
                        git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
                        export PATH=$PATH:$HOME/flutter/bin
                        flutter doctor
                    '''
                }
            }
        }

        stage('Get Dependencies') {
            steps {
                sh 'flutter pub get'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'flutter test --reporter expanded'
            }
            post {
                always {
                    junit 'test_report.xml'
                }
            }
        }

        stage('Build APK') {
            steps {
                sh 'flutter build apk --release'
            }
        }
    }

    post {
        failure {
            mail to: 'dev@example.com',
                 subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                 body: "Check ${env.BUILD_URL}"
        }
    }
}
```

## Тестирование в CI/CD

### Запуск всех типов тестов

```yaml
# .github/workflows/flutter-full.yml
name: Flutter Full CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  unit-tests:
    name: Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter test test/

  widget-tests:
    name: Widget Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter test test/widget_tests/

  golden-tests:
    name: Golden Tests
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter test test/golden_tests/

  integration-tests:
    name: Integration Tests
    runs-on: macos-latest
    needs: [unit-tests, widget-tests]
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - name: Start iOS Simulator
        run: |
          xcrun simctl boot "iPhone 15"
      - name: Run integration tests
        run: flutter test integration_test/

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [unit-tests, widget-tests, golden-tests]
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build apk --release
      - run: flutter build ios --release --no-codesign
      - uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/ios/iphoneos/
```

### Параллельное выполнение тестов

```yaml
# .github/workflows/flutter-parallel.yml
name: Flutter Parallel Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test-group: [unit, widget, golden]
      fail-fast: false

    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - name: Run ${{ matrix.test-group }} tests
        run: |
          if [ "${{ matrix.test-group }}" == "unit" ]; then
            flutter test test/
          elif [ "${{ matrix.test-group }}" == "widget" ]; then
            flutter test test/widget_tests/
          else
            flutter test test/golden_tests/
          fi
```

## Настройка отчётов

### JUnit отчёты

```yaml
# .github/workflows/flutter-junit.yml
name: Flutter with JUnit

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - name: Run tests with JUnit report
        run: |
          flutter test --reporter expanded > test_report.txt
          flutter test --reporter json > test_report.json
      - uses: dorny/test-reporter@v1
        if: always()
        with:
          name: Flutter Tests
          path: test_report.json
          reporter: flutter-json
```

### Codecov интеграция

```yaml
# .github/workflows/flutter-codecov.yml
name: Flutter Codecov

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - name: Run tests with coverage
        run: flutter test --coverage
      - name: Upload to Codecov
        uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info
          fail_ci_if_error: true
```

## Превью-сборки для PR

### GitHub Actions с артефактами

```yaml
# .github/workflows/flutter-pr-preview.yml
name: Flutter PR Preview

on:
  pull_request:
    branches: [main]

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: app-android
          path: build/app/outputs/flutter-apk/app-release.apk
          retention-days: 7

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
      - uses: actions/upload-artifact@v4
        with:
          name: app-ios
          path: build/ios/iphoneos/
          retention-days: 7
```

## Лучшие практики

1. **Запускайте все тесты в CI** — unit, widget, golden, integration
2. **Используйте кэширование** — для `flutter pub get` и зависимостей
3. **Параллельное выполнение** — разбивайте тесты на группы
4. **Настройте уведомления** — email, Slack, Telegram
5. **Используйте стабильный Flutter** — фиксируйте версию в CI
6. **Кэшируйте зависимости** — ускоряет сборку в 3-5 раз
7. **Ограничивайте время выполнения** — таймауты для long-running jobs
8. **Тестируйте на разных платформах** — Android, iOS, Web
9. **Автоматизируйте релизы** — после прохождения всех тестов
10. **Отслеживайте покрытие кода** — стремитесь к 70%+

## Кэширование в GitHub Actions

```yaml
# .github/workflows/flutter-cached.yml
name: Flutter with Cache

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Cache Flutter dependencies
        uses: actions/cache@v4
        with:
          path: ~/.pub-cache
          key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
          restore-keys: |
            ${{ runner.os }}-pub-

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'

      - run: flutter pub get
      - run: flutter test
```

## Заключение

CI/CD для Flutter — это мощный инструмент для автоматизации тестирования и развертывания. Правильная настройка позволяет catching bugs до попадания в продакшен и ускоряет процесс разработки. Начните с простых workflow и постепенно усложняйте по мере роста проекта.
