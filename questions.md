# Flutter Interview Questions (1-100)

## General Flutter Concepts

### 1. What is Flutter?
Flutter is an open-source UI software development kit created by Google. It is used to develop cross-platform applications for Android, iOS, Linux, Mac, Windows, Web, and Google Fuchsia from a single codebase. It uses the Dart programming language.

### 2. What is Dart?
Dart is a client-optimized language for fast apps on any platform. It is developed by Google, designed for client-side development (UIs), and compiles to native machine code. It is used as the primary language for Flutter.

### 3. What is the difference between Flutter and React Native?
- **Rendering**: Flutter draws its own widgets on a canvas (Skia/Impeller), while React Native uses native platform widgets.
- **Language**: Flutter uses Dart; React Native uses JavaScript/TypeScript.
- **Performance**: Flutter generally offers more consistent performance across platforms as it doesn't rely on a bridge to native components (though RN has the New Architecture JSI).
- **UI**: Flutter allows full customization of every pixel; React Native is limited to available native components unless custom ones are built.

### 4. What is the difference between Flutter and Kotlin/Swift?
Flutter allows you to write one codebase for both Android and iOS. Kotlin is for Android, and Swift is for iOS. Using Flutter saves development and maintenance time compared to writing separate native apps.

### 5. What is the Flutter Engine?
The Flutter Engine is the core implementation written in C/C++. It provides low-level rendering, graphics, file/network I/O, and Dart runtime. It is embedded in every Flutter app.

### 6. What is Dart SDK?
The Dart SDK contains the Dart runtime, libraries, compiler (dart2js, dartdevc), and tools (dart, pub). It is required to compile and run Dart code.

### 7. What is the difference between Flutter and Xamarin?
Flutter draws its own UI using the Skia/Impeller engine, providing high performance and consistent UI. Xamarin uses native controls rendered by the platform, relying on C# and .NET.

### 8. What is Hot Reload?
Hot Reload injects updated source code files into a running Dart virtual machine. After compilation, it updates the widget tree in real-time, allowing developers to see changes instantly without losing state.

### 9. What is Hot Restart?
Hot Restart stops the running app, recompiles it, and restarts it from scratch. It is slower than Hot Reload but ensures a clean state (e.g., after changing app-level configuration or main function).

### 10. What is AOT and JIT compilation in Flutter?
- **JIT (Just-In-Time)**: Used in Debug mode. Allows Hot Reload and fast development cycles.
- **AOT (Ahead-Of-Time)**: Used in Release mode. Compiles Dart code to native ARM machine code for high performance and fast startup.

---

## Widgets & UI Basics

### 11. What is a Widget in Flutter?
Everything in Flutter is a widget. A widget is an immutable description of part of a user interface. Widgets are lightweight objects that describe what their view should look like given their current configuration and state.

### 12. What is the difference between StatelessWidget and StatefulWidget?
- **StatelessWidget**: Immutable widget that doesn't change during its lifetime. It only needs `build()` method. Example: `Text`, `Icon`.
- **StatefulWidget**: Mutable widget that maintains state which can change during the widget's lifecycle. It requires a `State` object and `setState()`. Example: `Checkbox`, `TextField`.

### 13. What is the difference between `const` and `final` in Dart?
- `final`: Value is set once at runtime and cannot be changed.
- `const`: Value is set at compile-time and is implicitly final. Preferred for widgets to enable Flutter's widget tree optimization (skipping rebuilds if the widget hasn't changed).

### 14. What is the difference between `main()` and `runApp()`?
- `main()`: The entry point of the Dart program. It initializes variables and starts the app.
- `runApp()`: A Flutter method that takes a widget (usually `MaterialApp`) and attaches it to the screen. It replaces the entire widget tree.

### 15. What is the purpose of `MaterialApp`?
`MaterialApp` is a convenience widget that wraps a number of widgets that are commonly required for Material Design applications. It sets up the navigator, theme, routes, and home screen.

### 16. What is the purpose of `WidgetsApp`?
`WidgetsApp` is a minimal set of widgets that implement basic application features like navigation, theme, and locale support. `MaterialApp` extends `WidgetsApp` with Material Design specific widgets.

### 17. What is `Scaffold`?
`Scaffold` provides a scaffold for Material Design applications. It implements the basic Material Design layout structure, including support for app bars, snackbars, drawers, bottom navigation bars, and floating action buttons.

### 18. What is the difference between `Row` and `Column`?
- `Row`: Arranges children horizontally.
- `Column`: Arranges children vertically.
Both are flexible layout widgets that can be combined to create complex layouts.

### 19. What is the difference between `Expanded` and `Flexible`?
- `Expanded`: Fills the remaining space of the parent. The child is forced to fill the available space.
- `Flexible`: Can shrink or expand to fill the space, but doesn't force the child to expand. The child can be smaller than the available space.

### 20. What is the purpose of `Container`?
`Container` is a convenience widget that combines common painting, positioning, and sizing widgets. It can have a color, decoration, padding, margin, constraints, and alignment.

---

## State & Lifecycle

### 21. What is `setState()`?
`setState()` is a method in `State` class that notifies the Flutter framework that the internal state of the object has changed. This triggers a rebuild of the widget, updating the UI.

### 22. What is the widget lifecycle?
1. `createState()`: Creates the State object.
2. `initState()`: Called once when the state is first created. Good for initialization.
3. `didChangeDependencies()`: Called when a dependency of this State object changes (e.g., InheritedWidget).
4. `build()`: Describes the part of the user interface built by this widget.
5. `didUpdateWidget()`: Called when the parent widget changes configuration.
6. `deactivate()`: Called when the State object is no longer in the tree.
7. `dispose()`: Called when the State is permanently removed. Good for cleanup (listeners, animations).

### 23. What is the difference between `initState` and `didChangeDependencies`?
- `initState`: Called first. Dependencies are not yet available (e.g., `Theme.of(context)` might throw).
- `didChangeDependencies`: Called after `initState` and whenever a dependency changes. Safe to use context-dependent widgets here.

### 24. What is the difference between `dispose` and `deactivate`?
- `deactivate`: Widget is temporarily removed from the tree (e.g., moving between tabs).
- `dispose`: Widget is permanently removed. Use `dispose` to close resources like streams or controllers.

### 25. What is `BuildContext`?
`BuildContext` represents the location of a widget in the widget tree. It is used to access ancestor widgets (like `Theme.of(context)`), navigate, and show dialogs.

### 26. What is the difference between `const` and empty constructor in widgets?
Using `const` allows Flutter to cache the widget instance and skip rebuilding it if the parent rebuilds, as long as the configuration hasn't changed. This improves performance.

---

## Navigation & Routing

### 27. What is Navigator?
`Navigator` is a widget that manages a stack of Route objects to navigate between screens. It uses `push` to add routes and `pop` to remove them.

### 28. What is the difference between `push` and `pushReplacement`?
- `push`: Adds a new route to the stack. User can navigate back to the previous screen.
- `pushReplacement`: Replaces the current route with a new one. The previous route is removed from the stack, so the user cannot navigate back to it.

### 29. How to pass data between screens?
Data can be passed via constructors of the target screen or via arguments in `Navigator.push`. Data can be returned using `await` on the `push` method.

### 30. What are named routes?
Named routes are routes that have a string identifier. This allows navigation without importing the screen's widget class, using `Navigator.pushNamed(context, 'route_name')`.

### 31. What is the difference between `MaterialPageRoute` and `CupertinoPageRoute`?
- `MaterialPageRoute`: Provides a platform-agnostic route that looks like Material Design on Android and Cupertino on iOS.
- `CupertinoPageRoute`: Provides an iOS-style transition and appearance (slide from right).

### 32. What is `onGenerateRoute`?
`onGenerateRoute` is a callback in `MaterialApp` that is called when a named route is requested but not found in the `routes` map. It allows dynamic route generation.

### 33. What is `Navigator.pop`?
`Navigator.pop` removes the topmost route from the navigator's stack, effectively going back to the previous screen.

### 34. What is `Navigator.canPop`?
Checks if the navigator can pop the current route (i.e., if there is a previous route to go back to).

### 35. What is `Navigator.pushNamedAndRemoveUntil`?
Pushes a named route and removes all previous routes until a predicate is met. Useful for logging out and removing all history.

---

## Layout & Styling

### 36. What is `SafeArea`?
`SafeArea` ensures that its content is not obscured by the device's system UI (like status bar or notch).

### 37. What is `MediaQuery`?
`MediaQuery` provides information about the size of the screen, padding, and orientation. It is used to create responsive layouts.

### 38. What is `LayoutBuilder`?
`LayoutBuilder` provides a builder function that receives constraints from the parent widget. It allows building widgets dynamically based on available space.

### 39. What is the difference between `Padding` and `Margin`?
- `Padding`: Adds space inside the widget, between the widget's content and its border.
- `Margin`: Adds space outside the widget, pushing other widgets away.

### 40. What is `IntrinsicWidth`/`IntrinsicHeight`?
These widgets force their children to match the intrinsic width/height of the children. Useful for buttons that should match the width of the widest button in a row.

### 41. What is `ConstrainedBox`?
`ConstrainedBox` adds constraints to its child. It can enforce minimum or maximum width/height.

### 42. What is `FittedBox`?
`FittedBox` scales or positions its child to fit the parent box. Similar to CSS `object-fit`.

### 43. What is `AspectRatio`?
`AspectRatio` forces its child to have a specific aspect ratio.

### 44. What is `ClipRRect`?
`ClipRRect` clips its child to a rounded rectangle shape.

### 45. What is `Wrap`?
`Wrap` arranges children in horizontal or vertical runs, wrapping to the next line when space is exhausted. Useful for chips or tags.

---

## Advanced Widgets & Concepts

### 46. What is `Stack`?
`Stack` allows children to be stacked on top of each other. Children can be positioned absolutely using `Positioned`.

### 47. What is `Positioned`?
`Positioned` is used inside a `Stack` to position a child at a specific offset (top, bottom, left, right).

### 48. What is `Hero`?
`Hero` creates an animation where a widget flies from one screen to another. Both screens must have a `Hero` with the same tag.

### 49. What is `Transform`?
`Transform` applies a transformation (scale, rotation, translation) to its child.

### 50. What is `CustomPainter`?
`CustomPainter` allows drawing custom graphics on the canvas. It is used to create unique shapes or animations not supported by standard widgets.

---

## State Management

### 51. What is State Management in Flutter?
State management refers to the practice of managing data that changes over time within an application. It involves keeping track of data (state) and updating the UI when that data changes.

### 52. What are the common state management approaches in Flutter?
- **setState()**: For small apps or local state.
- **Provider**: A wrapper around InheritedWidget, easy to learn and widely used.
- **Riverpod**: A more type-safe and testable evolution of Provider.
- **Bloc/Cubit**: Event-driven state management using streams and reactive programming.
- **GetX**: All-in-one solution with routing, state management, and dependency injection.
- **ValueNotifier/ChangeNotifier**: Simple notification-based approach.
- **Redux**: Centralized state management inspired by Redux pattern.

### 53. What is Provider?
Provider is a state management package that wraps InheritedWidget to make data available throughout the widget tree. It allows widgets to listen to changes and rebuild when the provided data changes.

### 54. What is the difference between ChangeNotifierProvider and MultiProvider?
- **ChangeNotifierProvider**: Provides a single ChangeNotifier instance to the tree.
- **MultiProvider**: Wraps multiple providers together, allowing you to provide several dependencies at once.

### 55. What is Bloc (Business Logic Component)?
Bloc is a state management pattern that uses streams to separate business logic from UI. It converts input events (actions) into output states using Streams, making it predictable and testable.

### 56. What is the difference between Cubit and Bloc?
- **Cubit**: Uses methods to emit states (synchronous). Simpler API, no streams needed.
- **Bloc**: Uses events to emit states (asynchronous). More complex but better for complex event handling.

### 57. What is Riverpod?
Riverpod is a reactive caching and state management library that generates code using `build_runner`. It is considered an improvement over Provider, offering better type safety, testability, and no dependency on `BuildContext`.

### 58. What is GetX?
GetX is an open-source framework for Flutter that provides lightweight and scalable state management, dependency injection, and route management in a single package.

### 59. What is the difference between local state and global state?
- **Local state**: Owned by a single widget (e.g., `TextEditingController`). Limited scope.
- **Global state**: Shared across multiple widgets/screens (e.g., user authentication, theme). Managed by Provider, Bloc, etc.

### 60. When should you use setState vs Provider vs Bloc?
- **setState**: For small, local UI state (e.g., toggle, counter).
- **Provider**: For medium apps with shared state across a few screens.
- **Bloc**: For large, complex apps with complex business logic and multiple teams.

---

## Streams & Asynchronous Programming

### 61. What is a Stream in Dart?
A Stream delivers a sequence of values over time, similar to an asynchronous sequence. It can emit data, errors, or completion events. Commonly used for real-time data, user input, and Bloc state changes.

### 62. What is a Future?
A Future represents a single asynchronous operation. It will complete with either a value or an error. Used for one-time async operations like API calls or file reads.

### 63. What is the difference between Stream and Future?
- **Future**: Single asynchronous value/error.
- **Stream**: Multiple asynchronous values/errors over time (a sequence of Futures).

### 64. What is `async` and `await`?
- `async`: Marks a function as asynchronous, allowing it to use `await`.
- `await`: Pauses execution until the Future completes, then returns the value.

### 65. What is StreamBuilder?
`StreamBuilder` is a widget that builds itself based on the latest snapshot of interaction with a Stream. It is commonly used to display real-time data or Bloc state changes.

### 66. What is FutureBuilder?
`FutureBuilder` is a widget that builds itself based on the latest snapshot of interaction with a Future. It is used to handle async operations that complete once, like API calls.

### 67. What is the difference between StreamBuilder and FutureBuilder?
- **StreamBuilder**: For streams (multiple values over time).
- **FutureBuilder**: For futures (single value).

### 68. What is a StreamController?
`StreamController` is used to create and control streams. You can add events to the stream using `.add()`, handle errors with `.addError()`, and listen using `.stream`.

### 69. What is `StreamGroup`?
`StreamGroup` allows you to combine multiple streams into a single stream. All streams must complete before the group completes.

### 70. What is the difference between `Stream` and `StreamController`?
- **Stream**: Read-only; you listen to it.
- **StreamController**: Write-only; you add events to it and expose the stream for listening.

---

## Testing

### 71. What types of tests are available in Flutter?
- **Unit Tests**: Test individual functions or classes in isolation.
- **Widget Tests**: Test individual widgets in isolation.
- **Integration Tests**: Test the entire app or multiple screens together.

### 72. What is the difference between `testWidgets` and `test`?
- **test**: For unit tests, no widget/buildContext needed.
- **testWidgets**: For widget tests, allows building and interacting with widgets.

### 73. What is `pumpWidget`?
`pumpWidget` is used in widget tests to build a widget tree and trigger a frame. It is equivalent to running `runApp()` in a test environment.

### 74. What is `tester.pump()`?
`tester.pump()` triggers a build frame. It is used in widget tests to simulate time passing (e.g., waiting for animations or async operations).

### 75. What is `find` in Flutter testing?
`find` provides matchers to locate widgets in the widget tree during testing, such as `find.byType()`, `find.text()`, `find.byKey()`.

### 76. What is `expect` in Flutter testing?
`expect` is used to assert conditions in tests. It compares the actual value with the expected value using matchers like `equals()`, `contains()`, `isNull()`.

### 77. What is `WidgetTester`?
`WidgetTester` is a class that provides methods to build, interact with, and test widgets, such as `tap()`, `enterText()`, `pump()`, and `pumpAndSettle()`.

### 78. What is `pumpAndSettle()`?
`pumpAndSettle()` keeps pumping frames until no more frames are scheduled (e.g., animations complete, all Futures resolve).

### 79. What is Mocking in Flutter?
Mocking creates fake objects that simulate real behavior during testing. Commonly used for dependencies like API services or databases using packages like `mockito` or `mocktail`.

### 80. What is the golden test?
A golden test (screenshot test) compares the rendered widget against a reference image (golden file). It helps detect unintended visual changes.

---

## Performance & Optimization

### 81. How to optimize Flutter app performance?
- Use `const` constructors wherever possible.
- Avoid heavy computations in the `build()` method.
- Use `ListView.builder` for long lists instead of `ListView()`.
- Use `const` widgets to skip rebuilds.
- Profile using Flutter DevTools.
- Avoid nesting widgets too deeply.
- Use `AutomaticKeepAliveClientMixin` to preserve state.

### 82. What is the difference between `ListView` and `ListView.builder`?
- **ListView**: Builds all children at once. Not suitable for long lists.
- **ListView.builder**: Lazily builds items as they scroll into view. More memory-efficient.

### 83. What is the Flutter DevTools?
Flutter DevTools is a suite of performance and debugging tools. It allows you to inspect the widget tree, profile performance, monitor memory, and debug network calls.

### 84. What is the importance of `const` in performance?
Using `const` widgets allows Flutter to cache widget instances and skip rebuilding them when the parent rebuilds, reducing unnecessary work and improving performance.

### 85. What is the RenderTree?
The RenderTree is the tree of RenderObjects that handles layout, painting, and hit testing. It is generated from the Widget tree and Element tree.

### 86. What causes a widget to rebuild?
- `setState()` is called.
- A parent widget rebuilds and the widget's configuration changes.
- An InheritedWidget dependency changes (e.g., Theme, Provider).

### 87. How to debug performance issues in Flutter?
- Use Flutter DevTools Performance tab.
- Enable performance overlay (`Alt + P`).
- Use `debugRepaintRainbowEnabled` to spot repaints.
- Check for unnecessary rebuilds using `flutter_log` or logging.

### 88. What is the importance of `keepAlive` in ListView?
Using `AutomaticKeepAliveClientMixin` keeps the widget's state alive when it scrolls off-screen, preventing rebuilds when scrolling back.

### 89. What is RepaintBoundary?
`RepaintBoundary` isolates repaints to a specific portion of the UI. Content inside a RepaintBoundary only repaints when something inside it changes.

### 90. What is the difference between Layout, Paint, and Compositing?
- **Layout**: Determines the size and position of widgets.
- **Paint**: Draws pixels on the screen.
- **Compositing**: Manages the order in which layers are drawn.

---

## Platform & Advanced Topics

### 91. What is Platform Channel?
Platform Channels allow Flutter code to communicate with native platform code (Java/Kotlin for Android, Objective-C/Swift for iOS). Used for platform-specific APIs.

### 92. What is the difference between MethodChannel and EventChannel?
- **MethodChannel**: For one-way method calls (Flutter ↔ Native).
- **EventChannel**: For streams of events from native to Flutter.

### 93. What is Isolate in Flutter?
An Isolate is a separate execution thread with its own memory space. Used for CPU-intensive tasks to avoid blocking the UI thread. Communication is done via messages.

### 94. What is the difference between `Isolate` and `compute()`?
- **Isolate**: Low-level, manual message passing.
- **compute()**: A high-level helper that runs a top-level function in a background Isolate with simplified messaging.

### 95. What is Firebase in Flutter?
Firebase is Google's backend-as-a-service platform. In Flutter, it is commonly used for authentication, cloud messaging, real-time database, analytics, and crash reporting via packages like `firebase_core` and `cloud_firestore`.

### 96. What is the difference between `inheritedWidget` and `Provider`?
- **InheritedWidget**: Low-level Flutter widget for sharing data down the tree.
- **Provider**: A wrapper around InheritedWidget that makes it easier to read, listen to, and update shared data.

### 97. What is the Flutter Web?
Flutter Web allows Flutter apps to run on web browsers. It compiles to HTML/JavaScript/Canvas. There are two renderers: CanvasKit (high quality) and HTML renderer (smaller size).

### 98. What is the difference between CanvasKit and HTML renderer in Flutter Web?
- **CanvasKit**: Uses WebGL for high-quality rendering, better performance, but larger download size (~2MB).
- **HTML Renderer**: Uses standard HTML/CSS/Canvas, smaller size, but less consistent across browsers.

### 99. What is the importance of `pubspec.yaml`?
`pubspec.yaml` defines the project's metadata, dependencies, assets, fonts, and plugins. It is essential for managing packages and resources.

### 100. What is the difference between `dependencies` and `dev_dependencies` in pubspec.yaml?
- **dependencies**: Packages required for the app to run in production (e.g., `http`, `provider`).
- **dev_dependencies**: Packages only needed during development/testing (e.g., `flutter_test`, `lint`, `mocktail`).
