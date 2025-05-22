// //-----------add custom marker function added---------//

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _initialPosition = LatLng(29.0635492, 80.1312196);
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  bool _isLoading = true;
  final Set<Marker> _markers = {};
  bool _canAddMarkers = false;

  final _mapZoom = 15.0;
  BitmapDescriptor _customMarkerIcon = BitmapDescriptor.defaultMarker;

  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addSampleMarkers();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        return;
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, _mapZoom),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: ${e.toString()}')),
      );
    }
  }

  void _addSampleMarkers() {
    setState(() {
      _markers.addAll([
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation ?? _initialPosition,
          icon: _customMarkerIcon,
          infoWindow: const InfoWindow(
            title: 'Marker',
            snippet: 'Current location',
          ),
        ),
        Marker(
          markerId: const MarkerId('initial_position'),
          position: _initialPosition,
          icon: _customMarkerIcon,
          infoWindow: const InfoWindow(
            title: 'Initial Position',
            snippet: 'This is the default marker position',
          ),
        ),
      ]);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _goToCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, _mapZoom),
      );
    } else {
      await _getCurrentLocation();
    }
  }

  void _addMarkerAtTapPosition(LatLng position) async {
    final TextEditingController _controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Marker'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Enter marker name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    _markers.add(
                      Marker(
                        markerId: MarkerId(
                          'marker_${position.latitude}_${position.longitude}',
                        ),
                        position: position,
                        icon: _customMarkerIcon,
                        infoWindow: InfoWindow(
                          title: _controller.text,
                          snippet:
                              '${position.latitude.toStringAsFixed(6)}, '
                              '${position.longitude.toStringAsFixed(6)}',
                        ),
                      ),
                    );
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simplified Google Map'),
        actions: [
          IconButton(
            icon: Icon(
              _mapType == MapType.normal ? Icons.satellite : Icons.map,
            ),
            onPressed: () {
              setState(() {
                _mapType =
                    _mapType == MapType.normal
                        ? MapType.hybrid
                        : MapType.normal;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _canAddMarkers ? Icons.location_on : Icons.location_off,
              color: _canAddMarkers ? Colors.green : Colors.grey,
            ),
            tooltip:
                _canAddMarkers ? 'Disable Marker Mode' : 'Enable Marker Mode',
            onPressed: () {
              setState(() {
                _canAddMarkers = !_canAddMarkers;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _canAddMarkers
                        ? 'Tap on the map to add markers'
                        : 'Marker-adding disabled',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    mapType: _mapType,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation ?? _initialPosition,
                      zoom: _mapZoom,
                    ),
                    markers: _markers,
                    onTap: (LatLng position) {
                      if (_canAddMarkers) {
                        _addMarkerAtTapPosition(position);
                      }
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    compassEnabled: true,
                  ),
                  Positioned(
                    bottom: 20,
                    right: 60,
                    child: IconButton(
                      icon: const Icon(Icons.my_location_outlined, size: 45),
                      onPressed: _goToCurrentLocation,
                    ),
                  ),
                ],
              ),
    );
  }
}
