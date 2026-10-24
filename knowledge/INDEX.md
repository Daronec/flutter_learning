---
tags:
  - index
  - flutter
  - knowledge-base
  - course
chapter: 0
---

# 📚 Flutter Knowledge Base

> Полная база знаний по Flutter и Dart — от основ до продвинутых тем.

## 📖 Содержание

### Глава 1: Введение в Flutter 🔰
- [[01-01-what-is-flutter|Что такое Flutter? История и философия Google]]
- [[01-02-architecture|Архитектура Flutter: Dart Framework, Engine, Platform]]
- [[01-03-dart-vs-flutter|Dart vs Flutter: чем отличаются]]
- [[01-04-installation|Установка Flutter SDK и настройка IDE]]
- [[01-05-project-structure|Структура Flutter-проекта]]
- [[01-06-first-run|Первый запуск: запуск приложения]]
- [[01-07-hot-reload|Hot Reload и Hot Restart]]

### Глава 2: Основы Dart 💻
- [[02-01-syntax-basics|Основы синтаксиса Dart]]
- [[02-02-functions|Функции и замыкания]]
- [[02-03-classes-objects|Классы и объекты]]
- [[02-04-mixins-interfaces|Mиксины и интерфейсы]]
- [[02-05-generics|Дженерики]]
- [[02-06-async-await|Асинхронность: async/await, Future, Stream]]
- [[02-07-collections|Коллекции: List, Set, Map]]
- [[02-08-extensions-operators|Расширения и операторы]]
- [[02-09-exceptions|Обработка исключений]]
- [[02-10-packages-pubspec|Пакеты и pubspec.yaml]]

### Глава 3: Виджеты 🧱
- [[03-01-what-is-widget|Что такое Widget?]]
- [[03-02-element-tree|Element Tree и RenderObject Tree]]
- [[03-03-stateless-vs-stateful|StatelessWidget vs StatefulWidget]]
- [[03-04-lifecycle|Жизненный цикл виджета]]
- [[03-05-buildcontext|BuildContext]]
- [[03-06-composition-vs-inheritance|Композиция vs Наследование]]
- [[03-07-custom-widgets|Создание кастомных виджетов]]
- [[03-08-keys|Keys в Flutter]]
- [[03-09-renderobject|RenderObject]]

### Глава 4: Основные виджеты 🎨
- [[04-01-container-padding|Container, Padding, SizedBox]]
- [[04-02-text-widget|Text и TextStyle]]
- [[04-03-icon-image|Icon и Image]]
- [[04-04-row-column-stack|Row, Column, Stack]]
- [[04-05-expanded-flexible|Expanded, Flexible, Flex]]
- [[04-06-listview-gridview|ListView, GridView]]
- [[04-07-single-child-scroll|SingleChildScrollView]]
- [[04-08-buttons|Кнопки: ElevatedButton, TextButton, etc.]]
- [[04-09-textfield|TextField]]
- [[04-10-checkbox-radio-switch|Checkbox, Radio, Switch]]

### Глава 5: Система лейаутов 📐
- [[05-01-flex-system|Flex-система: Constraints, ParentBox, ChildBox]]
- [[05-02-constraints|Constraints: правило передачи]]
- [[05-03-layoutbuilder|LayoutBuilder]]
- [[05-04-positioned-align|Positioned и Align]]
- [[05-05-custom-multichild|Кастомные мульти-детные виджеты]]
- [[05-06-aspectratio-fittedbox|AspectRatio, FittedBox]]
- [[05-07-responsive-design|Responsive Design]]
- [[05-08-orientation-mediaquery|OrientationBuilder, MediaQuery]]

### Глава 6: Управление состоянием ⚡
- [[06-01-state-management-intro|Введение в State Management]]
- [[06-02-setstate|setState]]
- [[06-03-provider|Provider]]
- [[06-04-valueprovider-listenableselector|ValueListenableBuilder, ListenableBuilder]]
- [[06-05-change-notifier|ChangeNotifier]]
- [[06-06-consumer-provider|Consumer, Selector]]
- [[06-07-getx|GetX]]
- [[06-08-bloc|BLoC Pattern]]
- [[06-09-riverpod|Riverpod]]
- [[06-10-comparison|Сравнение State Management подходов]]

### Глава 7: Навигация 🧭
- [[07-01-navigation-basics|Навигация: Navigator 1.0]]
- [[07-02-routing|Routing и Route Settings]]
- [[07-03-named-routes|Named Routes]]
- [[07-04-route-args|Передача аргументов между экранами]]
- [[07-05-navigator-2|Navigator 2.0: Router & Route]]
- [[07-06-auto-route|auto_route package]]
- [[07-07-deep-linking|Deep Linking]]

### Глава 8: Формы 📝
- [[08-01-form-basics|Form и TextFormField]]
- [[08-02-form-validation|Валидация форм]]
- [[08-03-form-state|FormState и GlobalKey]]
- [[08-04-custom-validators|Кастомные валидаторы]]
- [[08-05-form-arrays|Группы полей и динамические формы]]
- [[08-06-form-builder|form_builder package]]
- [[08-07-dynamic-forms|Динамические формы]]

### Глава 9: Работа с API 🌐
- [[09-01-http-basics|HTTP-запросы: http package]]
- [[09-02-rest-api|REST API: GET, POST, PUT, DELETE]]
- [[09-03-json-serialization|JSON сериализация]]
- [[09-04-dio|Dio: продвинутый HTTP клиент]]
- [[09-05-error-handling|Обработка ошибок API]]
- [[09-06-interceptors|Interceptors в Dio]]
- [[09-07-multipart|Multipart загрузка файлов]]
- [[09-08-api-layer|Архитектура API слоя]]
- [[09-09-retry-mechanism|Retry механизмы]]
- [[09-10-caching|Кэширование API ответов]]

### Глава 10: Локальное хранение данных 💾
- [[10-01-storage-overview|Обзор локального хранения]]
- [[10-02-shared-preferences|SharedPreferences]]
- [[10-03-json-file|JSON файлы]]
- [[10-04-sqflite|SQLite: sqflite package]]
- [[10-05-hive|Hive NoSQL база данных]]
- [[10-06-isar|Isar: высокопроизводительная БД]]
- [[10-07-secure-storage|Secure Storage (keychain/keystore)]]
- [[10-08-storage-strategies|Стратегии выбора хранилища]]

### Глава 11: Чистая архитектура 🏗️
- [[11-01-clean-architecture-intro|Введение в Clean Architecture]]
- [[11-02-layers|Слои: Data, Domain, Presentation]]
- [[11-03-repository|Repository Pattern]]
- [[11-04-usecases|Use Cases]]
- [[11-05-dependency-injection|Dependency Injection]]
- [[11-06-di-get_it|get_it package]]
- [[11-07-di-injectable|injectable package]]
- [[11-08-layer-separation|Разделение слоёв на практике]]

### Глава 12: Анимации 🎬
- [[12-01-animation-basics|Основы анимаций]]
- [[12-02-animation-controller|AnimationController]]
- [[12-03-tween|Tween]]
- [[12-04-curves|Curves]]
- [[12-05-implicit-animations|Implicit Animations: AnimatedContainer, etc.]]
- [[12-06-explicit-animations|Explicit Animations]]
- [[12-07-staggered|Staggered анимации]]
- [[12-08-page-transitions|Page Transitions]]
- [[12-09-lottie|Lottie анимации]]
- [[12-10-custom-animations|Кастомные анимации]]

### Глава 13: Тестирование 🧪
- [[13-01-testing-intro|Введение в тестирование Flutter]]
- [[13-02-unit-tests|Unit Tests]]
- [[13-03-widget-tests|Widget Tests]]
- [[13-04-integration-tests|Integration Tests]]
- [[13-05-mocking|Mocking: mockito, mocktail]]
- [[13-06-testing-services|Тестирование сервисов и репозиториев]]
- [[13-07-testing-bloc|Тестирование BLoC]]
- [[13-08-test-structure|Структура тестов]]
- [[13-09-ci-testing|CI/CD и тестирование]]
- [[13-10-golden-tests|Golden Tests]]

### Глава 14: Производительность 🚀
- [[14-01-performance-intro|Введение в производительность]]
- [[14-02-devtools|Flutter DevTools]]
- [[14-03-widget-optimization|Оптимизация виджетов]]
- [[14-04-build-method|Оптимизация build метода]]
- [[14-05-list-optimization|Оптимизация списков]]
- [[14-06-memory-leaks|Утечки памяти]]
- [[14-07-image-optimization|Оптимизация изображений]]
- [[14-08-benchmarking|Бенчмаркинг]]
- [[14-09-size-optimization|Оптимизация размера APK/IPA]]
- [[14-10-jank-detection|Детекция дёрганий (jank)]]

### Глава 15: Сборка приложения 📦
- [[15-01-build-overview|Обзор сборки приложения]]
- [[15-02-debug-vs-release|Debug vs Release vs Profile]]
- [[15-03-android-build|Сборка Android APK/AAB]]
- [[15-04-ios-build|Сборка iOS IPA]]
- [[15-05-versioning|Версионирование приложения]]
- [[15-06-flavors|Flavors (staging, production)]]
- [[15-07-signing|Подпись приложения]]
- [[15-08-ci-cd|CI/CD пайплайн]]
- [[15-09-firebase-deploy|Deploy на Firebase]]
- [[15-10-store-publishing|Публикация в Store]]

### Глава 16: Platform Channels 🔌
- [[16-01-platform-channels-intro|Введение в Platform Channels]]
- [[16-02-method-channels|Method Channels]]
- [[16-03-event-channels|Event Channels]]
- [[16-04-binary-messenger|Binary Messenger]]
- [[16-05-android-native|Android native (Kotlin/Java)]]
- [[16-06-ios-native|iOS native (Swift/ObjC)]]
- [[16-07-platform-interface|Platform Interface pattern]]
- [[16-08-custom-plugin|Создание собственного плагина]]
- [[16-09-firebase-plugins|Работа с Firebase плагинами]]
- [[16-10-device-apis|Device APIs: камера, GPS, датчики]]

---

## 🎯 Путь обучения

```
📖 Глава 1-2    → Основы Flutter и Dart
📖 Глава 3-5    → Виджеты и лейауты
📖 Глава 6      → Управление состоянием
📖 Глава 7-8    → Навигация и формы
📖 Глава 9-10   → Работа с данными
📖 Глава 11     → Архитектура
📖 Глава 12     → Анимации
📖 Глава 13-14  → Тестирование и производительность
📖 Глава 15-16  → Сборка и Platform Channels
```

## 🔗 Ссылки

- [Официальная документация Flutter](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Widget Catalog](https://flutter.dev/docs/development/ui/widgets/catalog)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
