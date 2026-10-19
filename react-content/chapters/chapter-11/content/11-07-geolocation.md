# Геолокация и работа с картами в Flutter

## Введение

Геолокация — одна из ключевых функций мобильных приложений. В Flutter для работы с геолокацией и картами используются несколько пакетов.

## Геолокация

### Установка

```yaml
dependencies:
  geolocator: ^10.1.0
  permission_handler: ^11.1.0
```

### Настройка разрешений

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Приложению нужен доступ к местоположению для...</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Приложению нужен постоянный доступ к местоположению...</string>
```

### Базовое определение местоположения

```dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GeolocationService {
  /// Проверка и запрос разрешений
  Future<bool> _checkPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // Перенаправляем в настройки
      await openAppSettings();
      return false;
    }
    return false;
  }

  /// Получение текущего местоположения
  Future<Position?> getCurrentPosition({
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    ),
  }) async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) return null;

    // Проверка включённого GPS
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // GPS выключен
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  /// Постоянное отслеживание местоположения
  Stream<Position> positionStream() async* {
    final hasPermission = await _checkPermission();
    if (!hasPermission) return;

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    );
  }

  /// Определение высоты над уровнем моря
  Future<double?> getAltitude(Position position) async {
    return position.altitude;
  }

  /// Определение скорости движения
  Future<double?> getSpeed(Position position) async {
    return position.speed; // м/с
  }
}
```

### Отслеживание местоположения

```dart
class LocationTracker extends ChangeNotifier {
  Position? _currentPosition;
  bool _isTracking = false;
  List<Position> _path = [];

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  List<Position> get path => _path;

  Future<void> startTracking() async {
    _isTracking = true;
    notifyListeners();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      _path.add(position);
      notifyListeners();
    });
  }

  void stopTracking() {
    _isTracking = false;
    notifyListeners();
  }

  double calculateDistance(Position from, Position to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  double calculateTotalDistance() {
    if (_path.length < 2) return 0;
    double total = 0;
    for (int i = 1; i < _path.length; i++) {
      total += Geolocator.distanceBetween(
        _path[i - 1].latitude,
        _path[i - 1].longitude,
        _path[i].latitude,
        _path[i].longitude,
      );
    }
    return total;
  }
}
```

### Обратное геокодирование

```dart
/// Преобразование координат в адрес
Future<Address?> reverseGeocode(double latitude, double longitude) async {
  try {
    final positions = await Geolocator.placemarkFromCoordinates(
      latitude,
      longitude,
    );
    if (positions.isNotEmpty) {
      final placemark = positions.first;
      return Address(
        street: placemark.thoroughfare,
        city: placemark.locality,
        state: placemark.administrativeArea,
        country: placemark.country,
        postalCode: placemark.postalCode,
      );
    }
  } catch (e) {
    print('Reverse geocoding error: $e');
  }
  return null;
}

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  String get fullAddress => [
        street,
        city,
        state,
        country,
        postalCode,
      ].where((s) => s != null).join(', ');
}
```

## Google Maps

### Установка

```yaml
dependencies:
  google_maps_flutter: ^2.5.0
```

### Настройка API ключа

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY" />
```

**iOS** (`ios/Runner/AppDelegate.swift`):
```swift
import GoogleMaps
GMSServices.provideAPIKey("YOUR_API_KEY")
```

### Отображение карты

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng _center = const LatLng(55.7558, 37.6173); // Москва

  @override
  void initState() {
    super.initState();
    _addCurrentLocationMarker();
  }

  void _addCurrentLocationMarker() {
    _markers.add(Marker(
      markerId: const MarkerId('current'),
      position: _center,
      infoWindow: const InfoWindow(title: 'Вы здесь'),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      ),
    ));
  }

  void _addRouteMarker(LatLng position, String title) {
    _markers.add(Marker(
      markerId: MarkerId(title),
      position: position,
      infoWindow: InfoWindow(title: title),
    ));
    setState(() {});
  }

  void _drawRoute(List<LatLng> points) {
    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: points,
      color: Colors.blue,
      width: 5,
      jointsVisible: true,
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      onMapCreated: (controller) {
        _controller = controller;
      },
      onCameraMove: (position) {
        _center = position.target;
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
```

### Поиск мест

```dart
class PlaceSearchService {
  final String apiKey;

  PlaceSearchService({required this.apiKey});

  Future<List<Place>> searchPlaces({
    required String query,
    required LatLng location,
    double radius = 5000,
  }) async {
    final url = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/textsearch/json',
      {
        'query': query,
        'location': '${location.latitude},${location.longitude}',
        'radius': radius.toString(),
        'key': apiKey,
      },
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['status'] != 'OK') return [];

    return (data['results'] as List)
        .map((json) => Place.fromJson(json))
        .toList();
  }
}

class Place {
  final String name;
  final LatLng location;
  final String? formattedAddress;
  final double? rating;

  Place({
    required this.name,
    required this.location,
    this.formattedAddress,
    this.rating,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    final loc = json['geometry']['location'];
    return Place(
      name: json['name'],
      location: LatLng(loc['lat'], loc['lng']),
      formattedAddress: json['formatted_address'],
      rating: json['rating']?.toDouble(),
    );
  }
}
```

## Лучшие практики

1. **Всегда проверяйте разрешения** перед запросом геолокации
2. **Используйте `LocationAccuracy`** в зависимости от задачи
3. **Обрабатывайте случай выключенного GPS**
4. **Кэшируйте результаты геокодирования**
5. **Ограничивайте частоту обновлений** для экономии батареи
6. **Используйте background mode** для длительных трекингов
