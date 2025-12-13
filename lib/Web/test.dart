//create empyt statefull widget
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class TestPage_web extends StatefulWidget {
  const TestPage_web({Key? key}) : super(key: key);

  @override
  State<TestPage_web> createState() => _TestPage_webState();
}

class _TestPage_webState extends State<TestPage_web> {
  final MapController mapController = MapController(
    initPosition: GeoPoint(latitude: 6.7056, longitude: 80.3847),
  );
  

  @override
  void initState() {
    
     MapController controller = MapController(
                            initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
                            areaLimit: BoundingBox( 
                                east: 10.4922941, 
                                north: 47.8084648, 
                                south: 45.817995, 
                                west:  5.9559113,
                      ),
            );
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Page'),actions: [
        IconButton(
          icon: Icon(Icons.my_location),
          onPressed: () async {
            // await mapController.currentLocation();
            await mapController.addMarker(GeoPoint (latitude: 47.3768866, longitude: 8.541694),
      markerIcon: const MarkerIcon(
        icon: Icon(
          Icons.location_on,
          color: Colors.red,
          size: 48,
        ),
      ),
      angle:5/3,
      
);
          },
        )
      ],),
      body: 
      OSMFlutter(
        controller: mapController,
        osmOption: OSMOption(zoomOption: ZoomOption(initZoom: 12)),
        onGeoPointLongPress: (point) {
          print("long press on $point");
        },
        onGeoPointClicked: (point) {
          // When a marker is clicked, show a popup with PointerInterceptor
          // showDialog(
          //   context: context,
          //   builder: (context) => PointerInterceptor(
          //     // The PointerInterceptor is crucial here for web platforms
          //     child: AlertDialog(
          //       title: Text('Marker Clicked'),
          //       content: Text('Location: ${point.latitude}, ${point.longitude}'),
          //       actions: [
          //         TextButton(
          //           // This button will work on web thanks to PointerInterceptor
          //           onPressed: () => Navigator.pop(context),
          //           child: Text('Close'),
          //         ),
          //       ],
          //     ),
          //   ),
          // );
        },
      ),
    );
  }
}
