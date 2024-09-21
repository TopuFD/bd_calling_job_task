import 'package:ddddd/controller/google_map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static const cameraPosition =
      CameraPosition(target: LatLng(70.8041, 90.4152), zoom: 14);

  final GMapController gMapController = Get.find<GMapController>();

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
      body: Obx(() => GoogleMap(
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: Set<Marker>.of(gMapController.markers),
          initialCameraPosition: cameraPosition,
          onMapCreated: (GoogleMapController controller) {
            gMapController.mapController.complete(controller);
          },
        ),
      ),
      floatingActionButton: InkWell(
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

// onTap: () async {
        //   getCurrentLocation().then((value) async {
        //     markerList.add(Marker(
        //         markerId: MarkerId("3"),
        //         position: LatLng(value.latitude, value.longitude),
        //         infoWindow: InfoWindow(title: "user current location")));

        //     GoogleMapController controller = await mapController.future;
        //     setState(() {
        //       controller.animateCamera(CameraUpdate.newCameraPosition(
        //           CameraPosition(
        //               target: LatLng(value.latitude, value.longitude),
        //               zoom: 14)));
        //     });
        //   });
        // },

        
  // ======================================get user current location here==========>
  // Future getCurrentLocation() async {
  //   await Geolocator.requestPermission().then((value) {}).onError(
  //     (error, stackTrace) async {
  //       await Geolocator.requestPermission();
  //       print("geolocator error");
  //     },
  //   );
  //   return await Geolocator.getCurrentPosition();
  // }
