import 'package:get/get.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class GMapController extends GetxController {
  Completer<GoogleMapController> mapController = Completer();

  var markers = <Marker>[].obs;

  List<Marker> markerList = const [
    Marker(
        markerId: MarkerId("1"),
        position: LatLng(23.777176, 90.399452),
        infoWindow: InfoWindow(title: "My Location")),
  ];

  @override
  void onInit() {
    super.onInit();
    markers.addAll(markerList);
  }
}
