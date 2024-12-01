import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsV1Page extends StatefulWidget {
  const MapsV1Page({super.key});

  @override
  State<MapsV1Page> createState() => _MapsV1PageState();
}

class _MapsV1PageState extends State<MapsV1Page> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  double latitude = -6.195175999638034;
  double longitude = 106.7948939107734;

  var mapType = MapType.hybrid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps App V1'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case MapType.none:
                    mapType = MapType.none;
                    break;
                  case MapType.normal:
                    mapType = MapType.normal;
                    break;
                  case MapType.satellite:
                    mapType = MapType.satellite;
                    break;
                  case MapType.terrain:
                    mapType = MapType.terrain;
                    break;
                  case MapType.hybrid:
                    mapType = MapType.hybrid;
                    break;
                  default:
                }
              });
            },
            itemBuilder: (context) => MapType.values
                .map(
                  (type) => PopupMenuItem(value: type, child: Text(type.name)),
                )
                .toList(),
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: mapType,
            initialCameraPosition:
                CameraPosition(target: LatLng(latitude, longitude), zoom: 17),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: {
              Marker(
                  markerId: const MarkerId('IDN'),
                  position: LatLng(latitude, longitude),
                  infoWindow: const InfoWindow(title: 'IDN.ID'))
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton(
                onPressed: () {
                  _controller.future.then((controller){
                    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(latitude, longitude), zoom: 17)));
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.place),
                )),
          )
        ],
      ),
    );
  }
}
