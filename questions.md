
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
Riverpod is a reactive caching and state management library that generates code using uild_runner. It is considered an improvement over Provider, offering better type safety, testability, and no dependency on BuildContext.

### 58. What is GetX?
GetX is an open-source framework for Flutter that provides lightweight and scalable state management, dependency injection, and route management in a single package.

### 59. What is the difference between local state and global state?
- **Local state**: Owned by a single widget (e.g., TextEditingController). Limited scope.
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

### 64. What is sync and wait?
- sync: Marks a function as asynchronous, allowing it to use wait.
- wait: Pauses execution until the Future completes, then returns the value.

### 65. What is StreamBuilder?
StreamBuilder is a widget that builds itself based on the latest snapshot of interaction with a Stream. It is commonly used to display real-time data or Bloc state changes.

### 66. What is FutureBuilder?
FutureBuilder is a widget that builds itself based on the latest snapshot of interaction with a Future. It is used to handle async operations that complete once, like API calls.

### 67. What is the difference between StreamBuilder and FutureBuilder?
- **StreamBuilder**: For streams (multiple values over time).
- **FutureBuilder**: For futures (single value).

### 68. What is a StreamController?
StreamController is used to create and control streams. You can add events to the stream using .add(), handle errors with .addError(), and listen using .stream.

### 69. What is StreamGroup?
StreamGroup allows you to combine multiple streams into a single stream. All streams must complete before the group completes.

### 70. What is the difference between Stream and StreamController?
- **Stream**: Read-only; you listen to it.
- **StreamController**: Write-only; you add events to it and expose the stream for listening.

---

## Testing

### 71. What types of tests are available in Flutter?
- **Unit Tests**: Test individual functions or classes in isolation.
- **Widget Tests**: Test individual widgets in isolation.
- **Integration Tests**: Test the entire app or multiple screens together.

### 72. What is the difference between 	estWidgets and 	est?
- **test**: For unit tests, no widget/buildContext needed.
- **testWidgets**: For widget tests, allows building and interacting with widgets.

### 73. What is pumpWidget?
pumpWidget is used in widget tests to build a widget tree and trigger a frame. It is equivalent to running unApp() in a test environment.

### 74. What is 	ester.pump()?
	ester.pump() triggers a build frame. It is used in widget tests to simulate time passing (e.g., waiting for animations or async operations).

### 75. What is ind in Flutter testing?
ind provides matchers to locate widgets in the widget tree during testing, such as ind.byType(), ind.text(), ind.byKey().

### 76. What is expect in Flutter testing?
expect is used to assert conditions in tests. It compares the actual value with the expected value using matchers like equals(), contains(), isNull().

### 77. What is WidgetTester?
WidgetTester is a class that provides methods to build, interact with, and test widgets, such as 	ap(), enterText(), pump(), and pumpAndSettle().

### 78. What is pumpAndSettle()?
pumpAndSettle() keeps pumping frames until no more frames are scheduled (e.g., animations complete, all Futures resolve).

### 79. What is Mocking in Flutter?
Mocking creates fake objects that simulate real behavior during testing. Commonly used for dependencies like API services or databases using packages like mockito or mocktail.

### 80. What is the golden test?
A golden test (screenshot test) compares the rendered widget against a reference image (golden file). It helps detect unintended visual changes.

---

## Performance & Optimization

### 81. How to optimize Flutter app performance?
- Use const constructors wherever possible.
- Avoid heavy computations in the uild() method.
- Use ListView.builder for long lists instead of ListView().
- Use const widgets to skip rebuilds.
- Profile using Flutter DevTools.
- Avoid nesting widgets too deeply.
- Use AutomaticKeepAliveClientMixin to preserve state.

### 82. What is the difference between ListView and ListView.builder?
- **ListView**: Builds all children at once. Not suitable for long lists.
- **ListView.builder**: Lazily builds items as they scroll into view. More memory-efficient.

### 83. What is the Flutter DevTools?
Flutter DevTools is a suite of performance and debugging tools. It allows you to inspect the widget tree, profile performance, monitor memory, and debug network calls.

### 84. What is the importance of const in performance?
Using const widgets allows Flutter to cache widget instances and skip rebuilding them when the parent rebuilds, reducing unnecessary work and improving performance.

### 85. What is the RenderTree?
The RenderTree is the tree of RenderObjects that handles layout, painting, and hit testing. It is generated from the Widget tree and Element tree.

### 86. What causes a widget to rebuild?
- setState() is called.
- A parent widget rebuilds and the widget's configuration changes.
- An InheritedWidget dependency changes (e.g., Theme, Provider).

### 87. How to debug performance issues in Flutter?
- Use Flutter DevTools Performance tab.
- Enable performance overlay (Alt + P).
- Use debugRepaintRainbowEnabled to spot repaints.
- Check for unnecessary rebuilds using lutter_log or logging.

### 88. What is the importance of keepAlive in ListView?
Using AutomaticKeepAliveClientMixin keeps the widget's state alive when it scrolls off-screen, preventing rebuilds when scrolling back.

### 89. What is RepaintBoundary?
RepaintBoundary isolates repaints to a specific portion of the UI. Content inside a RepaintBoundary only repaints when something inside it changes.

### 90. What is the difference between Layout, Paint, and Compositing?
- **Layout**: Determines the size and position of widgets.
- **Paint**: Draws pixels on the screen.
- **Compositing**: Manages the order in which layers are drawn.

---

## Platform & Advanced Topics

### 91. What is Platform Channel?
Platform Channels allow Flutter code to communicate with native platform code (Java/Kotlin for Android, Objective-C/Swift for iOS). Used for platform-specific APIs.

### 92. What is the difference between MethodChannel and EventChannel?
- **MethodChannel**: For one-way method calls (Flutter - Native).
- **EventChannel**: For streams of events from native to Flutter.

### 93. What is Isolate in Flutter?
An Isolate is a separate execution thread with its own memory space. Used for CPU-intensive tasks to avoid blocking the UI thread. Communication is done via messages.

### 94. What is the difference between Isolate and compute()?
- **Isolate**: Low-level, manual message passing.
- **compute()**: A high-level helper that runs a top-level function in a background Isolate with simplified messaging.

### 95. What is Firebase in Flutter?
Firebase is Google's backend-as-a-service platform. In Flutter, it is commonly used for authentication, cloud messaging, real-time database, analytics, and crash reporting via packages like irebase_core and cloud_firestore.

### 96. What is the difference between inheritedWidget and Provider?
- **InheritedWidget**: Low-level Flutter widget for sharing data down the tree.
- **Provider**: A wrapper around InheritedWidget that makes it easier to read, listen to, and update shared data.

### 97. What is the Flutter Web?
Flutter Web allows Flutter apps to run on web browsers. It compiles to HTML/JavaScript/Canvas. There are two renderers: CanvasKit (high quality) and HTML renderer (smaller size).

### 98. What is the difference between CanvasKit and HTML renderer in Flutter Web?
- **CanvasKit**: Uses WebGL for high-quality rendering, better performance, but larger download size (~2MB).
- **HTML Renderer**: Uses standard HTML/CSS/Canvas, smaller size, but less consistent across browsers.

### 99. What is the importance of pubspec.yaml?
pubspec.yaml defines the project's metadata, dependencies, assets, fonts, and plugins. It is essential for managing packages and resources.

### 100. What is the difference between dependencies and dev_dependencies in pubspec.yaml?
- **dependencies**: Packages required for the app to run in production (e.g., http, provider).
- **dev_dependencies**: Packages only needed during development/testing (e.g., lutter_test, lint, mocktail).
