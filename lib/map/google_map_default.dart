//   for custom marker code and own location adding
// -- geolocator for ios -----//
// ----- add a marker to own location current ----//
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMap1Screen extends StatefulWidget {
  const GoogleMap1Screen({super.key});

  @override
  State<GoogleMap1Screen> createState() => _GoogleMap1ScreenState();
}

class _GoogleMap1ScreenState extends State<GoogleMap1Screen> {
  //------initial camera position for marker---//
  LatLng myCurrentLocation = LatLng(
    29.0635492,
    80.1312196,
  ); 

  late GoogleMapController googleMapController;
  Set<Marker> marker = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        //-------adding marker ----//
        markers: marker,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },

        initialCameraPosition: CameraPosition(
          // Use CameraPosition from google_maps_flutter
          target: myCurrentLocation,
          // zoom: 15,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          Position position = await currentPosition();
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
              ),
            ),
          );
          marker.clear();
          marker.add(
            Marker(
              markerId: MarkerId("This is my locatioin"),
              position: LatLng(position.latitude, position.longitude),
            ),
          );
          setState(() {
            
          });
        },
        child: const Icon(Icons.my_location, size: 30),
      ),
    );
  }

  // ------implementing geolocator------------//

  // ----this will be for IOS ----------------//
  //---------since android has automatic for this -----//
  Future<Position> currentPosition() async {
    bool serviceEnable;
    LocationPermission permission;

    // check if the location service are enabled or not
    serviceEnable = await Geolocator.isLocationServiceEnabled();

    permission = await Geolocator.checkPermission();
    if (!serviceEnable) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
