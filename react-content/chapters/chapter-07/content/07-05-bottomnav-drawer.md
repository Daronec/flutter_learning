# BottomNavigationBar, Drawer, FloatingActionButton

Нижняя навигация, боковые панели и плавающие кнопки действий — основные паттерны UI навигации в мобильных приложениях.

## BottomNavigationBar

### Базовое использование

```dart
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Поиск',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
```

### Типы BottomNavigationBar

| Тип | Описание | Количество элементов |
|---|---|---|
| `shifting` | Каждый элемент имеет свой цвет | 3-5 |
| `fixed` | Единый цвет для всех элементов | 2-5 |
| `linear` | Плоский дизайн, без эффектов | 2-5 |

```dart
// Shifting — каждый элемент с собственным цветом
BottomNavigationBar(
  type: BottomNavigationBarType.shifting,
  items: [
    BottomNavigationBarItem(
      icon: const Icon(Icons.home),
      label: 'Home',
      activeIcon: const Icon(Icons.home_filled),
    ),
    BottomNavigationBarItem(
      icon: const Icon(Icons.search),
      label: 'Search',
      activeIcon: const Icon(Icons.search_rounded),
    ),
  ],
  backgroundColor: Colors.blue,
  selectedItemColor: Colors.white,
  unselectedItemColor: Colors.grey,
);

// Fixed — единый стиль
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ],
);
```

### BottomNavigationBar с go_router

```dart
class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const RouterOutlet(), // go_router
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _navigate(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    final routes = ['/', '/search', '/profile'];
    context.go(routes[index]);
  }
}
```

## Drawer и Scaffold

### Базовый Drawer

```dart
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      drawer: const AppDrawer(),
      body: const Center(child: Text('Контент')),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                SizedBox(height: 8),
                Text(
                  'Иван Иванов',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  'ivan@example.com',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          // Пункты меню
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Главная'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Профиль'),
            onTap: () {
              Navigator.pop(context);
              context.go('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Настройки'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Выйти', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Логика выхода
              Navigator.pop(context);
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
```

### EndDrawer (правый Drawer)

```dart
Scaffold(
  endDrawer: Drawer(
    child: ListView(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text('Меню'),
        ),
        ListTile(
          leading: const Icon(Icons.bookmark),
          title: const Text('Закладки'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('История'),
          onTap: () {},
        ),
      ],
    ),
  ),
  // Открывается свайпом справа
  body: const Center(child: Text('Контент')),
);
```

### DrawerController

```dart
class DrawerController extends StatelessWidget {
  final GlobalKey<DrawerState> drawerKey = GlobalKey();

  void openDrawer() {
    drawerKey.currentState?.open();
  }

  void closeDrawer() {
    drawerKey.currentState?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(key: drawerKey, child: const AppDrawer()),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: openDrawer,
        ),
      ),
      body: const Center(child: Text('Контент')),
    );
  }
}
```

## FloatingActionButton (FAB)

### Базовый FAB

```dart
Scaffold(
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      // Действие по нажатию
    },
    child: const Icon(Icons.add),
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
  body: const Center(child: Text('Контент')),
);
```

### Extended FAB

```dart
Scaffold(
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () {},
    icon: const Icon(Icons.add),
    label: const Text('Добавить'),
    backgroundColor: Colors.blue,
  ),
  body: const Center(child: Text('Контент')),
);
```

### FAB с меню (Extended с actions)

```dart
Scaffold(
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () {},
    icon: const Icon(Icons.add),
    label: const Text('Добавить'),
    extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
    extendedBuilder: (context, animation) {
      return Row(
        children: [
          Icon(Icons.add, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Добавить',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.arrow_drop_down),
            onSelected: (value) {
              switch (value) {
                case 'product':
                  // Добавить товар
                  break;
                case 'category':
                  // Добавить категорию
                  break;
                case 'tag':
                  // Добавить тег
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'product',
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag, size: 20),
                    SizedBox(width: 8),
                    Text('Товар'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'category',
                child: Row(
                  children: [
                    Icon(Icons.category, size: 20),
                    SizedBox(width: 8),
                    Text('Категория'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'tag',
                child: Row(
                  children: [
                    Icon(Icons.tag, size: 20),
                    SizedBox(width: 8),
                    Text('Тег'),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    },
  ),
  body: const Center(child: Text('Контент')),
);
```

### Multiple FABs с FloatingActionButtonAnimator

```dart
Scaffold(
  floatingActionButton: FloatingActionButtonAnimator.animated(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.photo_camera),
          backgroundColor: Colors.green,
          heroTag: 'camera',
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.videocam),
          backgroundColor: Colors.purple,
          heroTag: 'video',
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.mic),
          backgroundColor: Colors.orange,
          heroTag: 'mic',
        ),
      ],
    ),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  body: const Center(child: Text('Контент')),
);
```

### Расположения FAB

| Позиция | Описание |
|---|---|
| `endFloat` | Справа внизу, над BottomAppBar |
| `endDocked` | Справа внизу, на BottomAppBar |
| `centerFloat` | По центру внизу |
| `centerDocked` | По центру внизу, на BottomAppBar |
| `startFloat` | Слева внизу |
| `startDocked` | Слева внизу, на BottomAppBar |

## Best Practices

1. **BottomNavigationBar** — используйте для 3-5 основных разделов приложения.
2. **Drawer** — используйте для вторичной навигации и дополнительных действий.
3. **FAB** — используйте для основного действия на экране (создание, добавление).
4. **Не комбинируйте Drawer и BottomNavigationBar** для одной навигации — это путает пользователей.
5. **Drawer** — закрывайте автоматически при навигации на другой экран.
6. **FAB** — используйте `heroTag` для анимации при навигации между экранами.
7. **BottomNavigationBar** — используйте `type: fixed` для 3 и менее элементов.
8. **FAB location** — выбирайте позицию в зависимости от контекста и доступного пространства.
