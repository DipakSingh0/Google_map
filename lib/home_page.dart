import 'package:flutter/material.dart';
import 'package:map/map/google_map2.dart';
import 'package:map/map/google_map_default.dart';
import 'package:map/map/google_map3.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // -------SImple map type --------//
            Text('Defalult Map ', style: TextStyle(fontSize: 25)),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoogleMap1Screen(),
                  ),
                );
              },
              child: const Text('Map 1 Page'),
            ),
            const SizedBox(height: 20),
            Text(
              'Map with toggle betn map type function',
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoogleMap2Screen(),
                  ),
                );
              },
              child: const Text('Map 2 Page'),
            ),

            Text(
              'Map with custom marker adding to new location ',
              style: TextStyle(fontSize: 25),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
              child: const Text('Map 3'),
            ),
          ],
        ),
      ),
    );
  }
}
