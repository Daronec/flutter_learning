# Flutter Web — деплой веб-версии

## Введение

Flutter позволяет создавать веб-приложения, которые работают в любом современном браузере. Деплой веб-версии значительно проще, чем мобильных приложений, так как не требует审核 или подписания кода.

## Сборка веб-версии

### Команды сборки

```bash
# Включение поддержки Web
flutter create . --platforms=web

# Сборка в режиме Release
flutter build web --release

# Сборка с оптимизацией размера
flutter build web --release --web-renderer canvaskit

# Сборка с HTML renderer (меньший размер)
flutter build web --release --web-renderer html

# Сборка в специфическую директорию
flutter build web --release --output ./build/web

# Сборка с минификацией и tree shaking
flutter build web --release --dart-define=ENV=production
```

### Сравнение рендереров

| Рендерер | Размер | Совместимость | Качество |
|----------|--------|---------------|----------|
| HTML | ~500 КБ | Все браузеры | Стандартное |
| Canvaskas | ~2 МБ | Современные | Высокое (Canvas 2D) |
| CanvasKit | ~6 МБ | Все браузеры | Максимальное (GPU) |

### Настройка рендерера по умолчанию

**Файл: `web/index.html`**

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Flutter Web App</title>
    <script>
        // Выбор рендерера
        window.flutterWebRenderer = 'html'; // 'html' | 'canvaskit'
    </script>
</head>
<body>
    <script src="flutter.js" defer></script>
</body>
</html>
```

## Структура сборки

```
build/web/
├── assets/
│   ├── assets/
│   │   ├── images/
│   │   ├── fonts/
│   │   └── ...
│   ├── fonts/
│   │   ├── MaterialIcons-Regular.otf
│   │   └── ...
│   ├── FlutterAssetManifest.bin
│   └── FlutterAssetManifest.json
├── canvaskit/
│   ├── canvaskit.js
│   ├── canvaskit.wasm
│   └── skwasm.js
├── favicon.png
├── icons/
│   ├── icon-128.png
│   ├── icon-192.png
│   ├── icon-512.png
│   └── ...
├── index.html
├── main.dart.js
├── main.dart.js.map
├── manifest.json
└── version.json
```

## Варианты хостинга

### Firebase Hosting

**Настройка:**

```bash
# Установка Firebase CLI
npm install -g firebase-tools

# Инициализация Firebase
firebase login
firebase init hosting

# Выбор проекта
? Please select an option: Use an existing project
? Select default project: your-project-id

# Директория для деплоя
? What do you want to use as your public directory? build/web

# Конфигурация SPA
? Configure as a single-page app (rewrite all urls to /index.html)? Yes

# Деплой
firebase deploy --only hosting
```

**Файл: `firebase.json`**

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "**/*.@(png|gif|jpg|jpeg|webp|svg|otf)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=604800"
          }
        ]
      }
    ]
  }
}
```

**Деплой через CI/CD:**

```yaml
# .github/workflows/firebase-deploy.yml
name: Deploy to Firebase Hosting

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x.x'

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Firebase CLI
        run: npm install -g firebase-tools

      - name: Build Flutter Web
        run: |
          flutter pub get
          flutter build web --release

      - name: Deploy to Firebase
        run: firebase deploy --only hosting --token ${{ secrets.FIREBASE_TOKEN }}
```

### Netlify

**Настройка:**

```bash
# Установка Netlify CLI
npm install -g netlify-cli

# Деплой
netlify deploy --prod --dir=build/web

# С помощью netlify.toml
```

**Файл: `netlify.toml`**

```toml
[build]
  command = "flutter build web --release"
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/*.css"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

### Vercel

**Настройка:**

```bash
# Установка Vercel CLI
npm install -g vercel

# Деплой
vercel --prod

# С помощью vercel.json
```

**Файл: `vercel.json`**

```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ],
  "headers": [
    {
      "source": "/assets/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    }
  ]
}
```

### GitHub Pages

**Настройка:**

```yaml
# .github/workflows/github-pages.yml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Build Flutter Web
        run: |
          flutter pub get
          flutter build web --release

      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

### AWS S3 + CloudFront

**Настройка:**

```bash
# Создание S3 bucket
aws s3 mb s3://my-flutter-web-app

# Синхронизация файлов
aws s3 sync build/web/ s3://my-flutter-web-app/ --delete

# Настройка как статического сайта
aws s3 website s3://my-flutter-web-app/ \
  --index-document index.html \
  --error-document index.html

# Очистка кэша CloudFront
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*"
```

## PWA (Progressive Web App)

### Файл: `web/manifest.json`

```json
{
  "name": "My Flutter Web App",
  "short_name": "MyApp",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#2196f3",
  "description": "Flutter Web PWA",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### Service Worker

```dart
// Использование пакета flutter_service_worker
import 'package:flutter_service_worker/service_worker.dart';

final serviceWorker = ServiceWorker.instance;

await serviceWorker.initialize(
  'flutter_service_worker.js',
  distDir: 'build/web',
);

// Проверка обновлений
serviceWorker.addEventListener('updated', (event) {
  // Показать пользователю уведомление об обновлении
});
```

## Best Practices

- **Используйте `--web-renderer html`** для минимального размера
- **Настройте кэширование** статических ресурсов
- **Включите PWA** для офлайн-доступа
- **Используйте CDN** для глобальной доставки контента
- **Мониторьте производительность** через Lighthouse
- **Тестируйте на разных браузерах** перед деплоем
