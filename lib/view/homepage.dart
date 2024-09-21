import 'package:ddddd/controller/google_map_controller.dart';
import 'package:ddddd/controller/user_current_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GMapController gMapController = Get.find<GMapController>();
  final UserCurrentLocation currrentLocController =
      Get.find<UserCurrentLocation>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Live Locator",
          style: TextStyle(
              fontSize: 20.sp, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () => GoogleMap(
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set<Marker>.of(gMapController.markers),
          polylines: Set<Polyline>.of(gMapController.polylines),
          initialCameraPosition: gMapController.cameraPosition,
          onMapCreated: (GoogleMapController controller) {
            gMapController.mapController.complete(controller);
          },
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          gMapController.getCurrentLocation();
        },
        child: Container(
          height: 60.h,
          width: 60.w,
          decoration:
              const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          child: const Center(
              child: Icon(
            Icons.location_searching,
            color: Colors.white,
          )),
        ),
      ),
    );
  }
}
