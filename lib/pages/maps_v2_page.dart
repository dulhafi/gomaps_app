import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsV2Page extends StatefulWidget {
  const MapsV2Page({super.key});

  @override
  State<MapsV2Page> createState() => _MapsV2PageState();
}

class _MapsV2PageState extends State<MapsV2Page> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  double latitude = -6.195175999638034;
  double longitude = 106.7948939107734;

  var mapType = MapType.hybrid;

  String address = '';

  Position? devicePosition;

  Set<Marker> markers = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Geolocator.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps App V2'),
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
            myLocationEnabled: true,
            markers: markers,
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //TextField Search
                  TextField(
                    decoration: InputDecoration(
                        hintText: 'Masukan Alamat',
                        suffixIcon: IconButton(
                            onPressed: () async {
                              try {
                                markers.removeAll(markers);
                                final result = await GeocodingPlatform.instance
                                    ?.locationFromAddress(address);
                                _controller.future.then(
                                  (controller) {
                                    controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                      target: LatLng(result!.first.latitude,
                                          result.first.longitude),
                                      zoom: 17.0,
                                    )));
                                  },
                                );
                                markers.add(Marker(
                                    markerId: MarkerId(
                                      result.hashCode.toString(),
                                    ),
                                    position: LatLng(result!.first.latitude,
                                        result.first.longitude)));
                                setState(() {});
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Alamat tidak ditemukan')));
                              }
                            },
                            icon: const Icon(Icons.search))),
                    onChanged: (value) {
                      address = value;
                    },
                  ),
                  //Button Get Location
                  ElevatedButton(
                      onPressed: () async {
                        Geolocator.getCurrentPosition().then(
                          (value) {
                            _controller.future.then((controller) {
                              controller.animateCamera(
                                  CameraUpdate.newCameraPosition(CameraPosition(
                                target: LatLng(value.latitude, value.longitude),
                                zoom: 17.0,
                              )));
                            });
                            setState(() {
                              devicePosition = value;
                            });
                          },
                        );
                      },
                      child: const Text('Dapatkan Lokasi Saat Ini')),

                  //Text LAT LANG

                  devicePosition != null
                      ? Text(
                          "Lokasi Saat Ini : ${devicePosition?.latitude} ${devicePosition?.longitude}")
                      : const Text("Lokasi belum terdeteksi")
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
