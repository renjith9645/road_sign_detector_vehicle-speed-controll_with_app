import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  double? _distanceInMeters;

  bool _isLoading = true;
  bool _mapReady = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

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
          _errorMessage =
              'Location permission permanently denied';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final current =
          LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = current;
        _isLoading = false;
      });

      if (_mapReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(current, 14);
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchDestination() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      List<Location> locations =
          await locationFromAddress(query);

      if (locations.isEmpty) {
        setState(() {
          _errorMessage = 'Location not found';
          _isLoading = false;
        });
        return;
      }

      final loc = locations.first;

      final destination =
          LatLng(loc.latitude, loc.longitude);

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
        _isLoading = false;
      });

      if (_mapReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(destination, 12);
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Location not found';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map & Distance"),
        backgroundColor: const Color(0xFF101B3A),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _buildMap(),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          _buildSearchBar(),

          if (_distanceInMeters != null)
            _buildDistanceCard(),

          if (_errorMessage.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _errorMessage,
                    style:
                        const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        onPressed: () {
          if (_currentLocation != null && _mapReady) {
            _mapController.move(
              _currentLocation!,
              14,
            );
          }
        },
        child: const Icon(
          Icons.my_location,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (_currentLocation == null) {
      return const Center(
        child: Text("Getting location..."),
      );
    }

    List<Marker> markers = [];

    markers.add(
      Marker(
        point: _currentLocation!,
        width: 50,
        height: 50,
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 40,
        ),
      ),
    );

    if (_destinationLocation != null) {
      markers.add(
        Marker(
          point: _destinationLocation!,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
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
        },
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName:
              'com.example.road_sign_detector',
        ),

        MarkerLayer(markers: markers),

        if (_currentLocation != null &&
            _destinationLocation != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  _currentLocation!,
                  _destinationLocation!,
                ],
                strokeWidth: 4,
                color: Colors.blue,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Card(
        color: const Color(0xFF101B3A),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style:
                      const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search destination',
                    hintStyle:
                        TextStyle(color: Colors.white54),
                  ),
                  onSubmitted: (_) =>
                      _searchDestination(),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Colors.cyanAccent,
                ),
                onPressed: _searchDestination,
              ),
            ],
          ),
        ),
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
            "Distance : ${(_distanceInMeters! / 1000).toStringAsFixed(2)} km",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}