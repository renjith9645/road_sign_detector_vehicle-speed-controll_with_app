// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'dart:convert';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'dart:math';

// class LocationPage extends StatefulWidget {
//   const LocationPage({super.key});

//   @override
//   State<LocationPage> createState() => _LocationPageState();
// }

// class _LocationPageState extends State<LocationPage> {
//   late final MapController _mapController;
//   final TextEditingController _searchController = TextEditingController();
//   List<LatLng> _routePoints = [];
//   LatLng? _currentLocation;
//   LatLng? _destinationLocation;
//   double? _distanceInMeters;
//   StreamSubscription<Position>? _positionStream;
//   bool _isLoading = true;
//   bool _mapReady = false;
//   String _errorMessage = '';
//   List<dynamic> _suggestions = [];
//   double _heading = 0;

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     _initLocation();
//   }

//   @override
//   void dispose() {
//     _positionStream?.cancel();
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _getRoute() async {
//     if (_currentLocation == null || _destinationLocation == null) {
//       return;
//     }

//     try {
//       final url =
//           'https://router.project-osrm.org/route/v1/driving/'
//           '${_currentLocation!.longitude},${_currentLocation!.latitude};'
//           '${_destinationLocation!.longitude},${_destinationLocation!.latitude}'
//           '?overview=full&geometries=geojson';

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         final coordinates = data['routes'][0]['geometry']['coordinates'];

//         List<LatLng> route = [];

//         for (var point in coordinates) {
//           route.add(LatLng(point[1].toDouble(), point[0].toDouble()));
//         }

//         setState(() {
//           _routePoints = route;
//         });
//       }
//     } catch (e) {
//       print("Route Error: $e");
//     }
//   }

//   Future<void> _initLocation() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

//       if (!serviceEnabled) {
//         setState(() {
//           _errorMessage = 'Location services are disabled';
//           _isLoading = false;
//         });
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();

//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();

//         if (permission == LocationPermission.denied) {
//           setState(() {
//             _errorMessage = 'Location permission denied';
//             _isLoading = false;
//           });
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         setState(() {
//           _errorMessage = 'Location permission permanently denied';
//           _isLoading = false;
//         });
//         return;
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       final current = LatLng(position.latitude, position.longitude);

//       setState(() {
//         _currentLocation = current;
//         _isLoading = false;
//       });

//       if (_mapReady) {
//         _mapController.move(current, 16);
//       }

//       _positionStream?.cancel();

//       _positionStream =
//           Geolocator.getPositionStream(
//             locationSettings: const LocationSettings(
//               accuracy: LocationAccuracy.best,
//               distanceFilter: 5,
//             ),
//           ).listen((Position position) async {
//             _heading = position.heading;
//             final newLocation = LatLng(position.latitude, position.longitude);

//             _currentLocation = newLocation;

//             if (_destinationLocation != null) {
//               _distanceInMeters = Geolocator.distanceBetween(
//                 _currentLocation!.latitude,
//                 _currentLocation!.longitude,
//                 _destinationLocation!.latitude,
//                 _destinationLocation!.longitude,
//               );

//               await _getRoute();
//             }

//             if (_mapReady) {
//               _mapController.move(newLocation, _mapController.camera.zoom);
//             }

//             if (mounted) {
//               setState(() {});
//             }
//           });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _getSuggestions(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _suggestions = [];
//       });
//       return;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse(
//           "https://nominatim.openstreetmap.org/search?q=$query&format=jsonv2&limit=5",
//         ),
//         headers: {"User-Agent": "CampusNavigationApp"},
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _suggestions = jsonDecode(response.body);
//         });
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _searchDestination() async {
//     final query = _searchController.text.trim();

//     if (query.isEmpty) return;

//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = '';
//       });

//       List<Location> locations = await locationFromAddress(query);

//       if (locations.isEmpty) {
//         setState(() {
//           _errorMessage = 'Location not found';
//           _isLoading = false;
//         });
//         return;
//       }

//       final loc = locations.first;

//       final destination = LatLng(loc.latitude, loc.longitude);

//       double? distance;

//       if (_currentLocation != null) {
//         distance = Geolocator.distanceBetween(
//           _currentLocation!.latitude,
//           _currentLocation!.longitude,
//           destination.latitude,
//           destination.longitude,
//         );
//       }

//       setState(() {
//         _destinationLocation = destination;
//         _distanceInMeters = distance;
//         _isLoading = false;
//       });
//       await _getRoute();

//       if (_mapReady) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             _mapController.move(destination, 12);
//           }
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Location not found';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Map & Distance"),
//         backgroundColor: const Color(0xFF101B3A),
//         foregroundColor: Colors.white,
//       ),
//       body: Stack(
//         children: [
//           _buildMap(),

//           if (_isLoading) const Center(child: CircularProgressIndicator()),

//           _buildSearchBar(),

//           if (_distanceInMeters != null) _buildDistanceCard(),

//           if (_errorMessage.isNotEmpty)
//             Positioned(
//               bottom: 20,
//               left: 20,
//               right: 20,
//               child: Card(
//                 color: Colors.red,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Text(
//                     _errorMessage,
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.cyanAccent,
//         onPressed: () {
//           if (_currentLocation != null && _mapReady) {
//             _mapController.move(_currentLocation!, 14);
//           }
//         },
//         child: const Icon(Icons.my_location, color: Colors.black),
//       ),
//     );
//   }

//   Widget _buildMap() {
//     if (_currentLocation == null) {
//       return const Center(child: Text("Getting location..."));
//     }

//     List<Marker> markers = [];

//     markers.add(
//       Marker(
//         point: _currentLocation!,
//         width: 40,
//         height: 40,
//         child: AnimatedRotation(
//           turns: _heading / 360,
//           duration: const Duration(milliseconds: 300),
//           child: Image.asset('assets/images/car.png', width: 40, height: 40),
//         ),
//       ),
//     );

//     return FlutterMap(
//       mapController: _mapController,
//       options: MapOptions(
//         initialCenter: _currentLocation!,
//         initialZoom: 14,
//         onMapReady: () {
//           _mapReady = true;
//         },
//       ),
//       children: [
//         TileLayer(
//           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//           userAgentPackageName: 'com.example.road_sign_detector',
//         ),

//         MarkerLayer(markers: markers),

//         if (_routePoints.isNotEmpty)
//           PolylineLayer(
//             polylines: [
//               Polyline(
//                 points: _routePoints,
//                 strokeWidth: 5,
//                 color: Colors.blue,
//               ),
//             ],
//           ),
//       ],
//     );
//   }

//   Widget _buildSearchBar() {
//     return Positioned(
//       top: 10,
//       left: 10,
//       right: 10,
//       child: Column(
//         children: [
//           Card(
//             color: const Color(0xFF101B3A),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     onChanged: _getSuggestions,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       hintText: "Search destination",
//                       hintStyle: TextStyle(color: Colors.white54),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.search, color: Colors.cyanAccent),
//                   onPressed: _searchDestination,
//                 ),
//               ],
//             ),
//           ),

//           if (_suggestions.isNotEmpty)
//             Container(
//               constraints: const BoxConstraints(maxHeight: 250),
//               child: Material(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: _suggestions.length,
//                   itemBuilder: (context, index) {
//                     final item = _suggestions[index];

//                     return ListTile(
//                       leading: const Icon(Icons.location_on),
//                       title: Text(
//                         item['display_name'],
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       onTap: () async {
//                         _searchController.text = item['display_name'];

//                         setState(() {
//                           _suggestions = [];
//                         });

//                         await _searchDestination();
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDistanceCard() {
//     return Positioned(
//       bottom: 20,
//       left: 20,
//       right: 90,
//       child: Card(
//         color: const Color(0xFF101B3A),
//         child: Padding(
//           padding: const EdgeInsets.all(15),
//           child: Text(
//             "Distance : ${(_distanceInMeters! / 1000).toStringAsFixed(2)} km",
//             style: const TextStyle(color: Colors.white, fontSize: 18),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  List<LatLng> _routePoints = [];
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  LatLng? _lastRoutedFrom;

  double? _distanceInMeters;
  double _heading = 0;

  StreamSubscription<Position>? _positionStream;
  Timer? _debounce;

  bool _isLoading = true;
  bool _mapReady = false;
  String _errorMessage = '';
  List<dynamic> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _positionStream?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission permanently denied';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final current = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = current;
        _isLoading = false;
      });

      if (_mapReady) {
        _mapController.move(current, 16);
      }

      _startLiveTracking();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startLiveTracking() {
    _positionStream?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) async {
            final newLocation = LatLng(position.latitude, position.longitude);
            final safeHeading = position.heading >= 0
                ? position.heading
                : _heading;

            double? distance;
            bool shouldRefreshRoute = false;

            if (_destinationLocation != null) {
              distance = Geolocator.distanceBetween(
                newLocation.latitude,
                newLocation.longitude,
                _destinationLocation!.latitude,
                _destinationLocation!.longitude,
              );

              if (_lastRoutedFrom == null) {
                shouldRefreshRoute = true;
              } else {
                final movedDistance = Geolocator.distanceBetween(
                  _lastRoutedFrom!.latitude,
                  _lastRoutedFrom!.longitude,
                  newLocation.latitude,
                  newLocation.longitude,
                );
                shouldRefreshRoute = movedDistance >= 30;
              }
            }

            if (!mounted) return;

            setState(() {
              _currentLocation = newLocation;
              _heading = safeHeading;
              _distanceInMeters = distance;
            });

            if (shouldRefreshRoute) {
              await _getRoute();
            }
          },
        );
  }

  Future<void> _getRoute() async {
    if (_currentLocation == null || _destinationLocation == null) return;

    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${_currentLocation!.longitude},${_currentLocation!.latitude};'
          '${_destinationLocation!.longitude},${_destinationLocation!.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['routes'] == null || (data['routes'] as List).isEmpty) {
          if (!mounted) return;
          setState(() {
            _routePoints = [];
            _errorMessage = 'No route found';
          });
          return;
        }

        final coordinates =
            data['routes'][0]['geometry']['coordinates'] as List;

        final route = coordinates.map<LatLng>((point) {
          return LatLng(
            (point[1] as num).toDouble(),
            (point[0] as num).toDouble(),
          );
        }).toList();

        if (!mounted) return;
        setState(() {
          _routePoints = route;
          _lastRoutedFrom = _currentLocation;
          _errorMessage = '';
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to fetch route';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Route Error: $e';
      });
    }
  }

  Future<void> _getSuggestions(String query) async {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final encodedQuery = Uri.encodeQueryComponent(query.trim());

        final response = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=jsonv2&limit=5',
          ),
          headers: {'User-Agent': 'CampusNavigationApp/1.0 (Flutter)'},
        );

        if (response.statusCode == 200 && mounted) {
          setState(() {
            _suggestions = jsonDecode(response.body);
          });
        }
      } catch (e) {
        debugPrint('Suggestion Error: $e');
      }
    });
  }

  Future<void> _searchDestination() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _suggestions = [];
      });

      final locations = await locationFromAddress(query);

      if (locations.isEmpty) {
        setState(() {
          _errorMessage = 'Location not found';
          _isLoading = false;
        });
        return;
      }

      final loc = locations.first;
      final destination = LatLng(loc.latitude, loc.longitude);

      double? distance;
      if (_currentLocation != null) {
        distance = Geolocator.distanceBetween(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          destination.latitude,
          destination.longitude,
        );
      }

      setState(() {
        _destinationLocation = destination;
        _distanceInMeters = distance;
        _routePoints = [];
        _lastRoutedFrom = null;
        _isLoading = false;
      });

      await _getRoute();
      _fitMapToRoute();
    } catch (e) {
      setState(() {
        _errorMessage = 'Location not found';
        _isLoading = false;
      });
    }
  }

  void _fitMapToRoute() {
    if (!_mapReady || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final points = <LatLng>[
        if (_currentLocation != null) _currentLocation!,
        if (_destinationLocation != null) _destinationLocation!,
        ..._routePoints,
      ];

      if (points.isEmpty) return;

      if (points.length == 1) {
        _mapController.move(points.first, 15);
        return;
      }

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(50),
        ),
      );
    });
  }

  void _goToCurrentLocation() {
    if (_currentLocation != null && _mapReady) {
      _mapController.move(_currentLocation!, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map & Distance'),
        backgroundColor: const Color(0xFF101B3A),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _buildMap(),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          _buildSearchBar(),
          if (_distanceInMeters != null) _buildDistanceCard(),
          if (_errorMessage.isNotEmpty) _buildErrorCard(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        onPressed: _goToCurrentLocation,
        child: const Icon(Icons.my_location, color: Colors.black),
      ),
    );
  }

  Widget _buildMap() {
    if (_currentLocation == null) {
      return const Center(child: Text('Getting location...'));
    }

    final markers = <Marker>[
      Marker(
        point: _currentLocation!,
        width: 40,
        height: 40,
        child: AnimatedRotation(
          turns: _heading / 360,
          duration: const Duration(milliseconds: 300),
          child: Image.asset('assets/images/car.png', width: 40, height: 40),
        ),
      ),
    ];

    if (_destinationLocation != null) {
      markers.add(
        Marker(
          point: _destinationLocation!,
          width: 45,
          height: 45,
          child: const Icon(Icons.location_pin, size: 45, color: Colors.red),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation!,
        initialZoom: 14,
        onMapReady: () {
          _mapReady = true;
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 16);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.road_sign_detector',
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 5,
                color: Colors.blue,
              ),
            ],
          ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Column(
        children: [
          Card(
            color: const Color(0xFF101B3A),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _getSuggestions,
                      onSubmitted: (_) => _searchDestination(),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search destination',
                        hintStyle: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.cyanAccent),
                    onPressed: _searchDestination,
                  ),
                ],
              ),
            ),
          ),
          if (_suggestions.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              margin: const EdgeInsets.only(top: 4),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                elevation: 6,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final item = _suggestions[index];
                    final displayName = item['display_name'] ?? 'Unknown';

                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      onTap: () async {
                        _searchController.text = displayName;
                        setState(() {
                          _suggestions = [];
                        });
                        await _searchDestination();
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDistanceCard() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 90,
      child: Card(
        color: const Color(0xFF101B3A),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            'Distance : ${(_distanceInMeters! / 1000).toStringAsFixed(2)} km',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Positioned(
      bottom: _distanceInMeters != null ? 90 : 20,
      left: 20,
      right: 20,
      child: Card(
        color: Colors.red,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
