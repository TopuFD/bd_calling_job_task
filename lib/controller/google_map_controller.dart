// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ddddd/controller/device_info_controller.dart';
// import 'package:ddddd/controller/user_current_location.dart';
// import 'package:get/get.dart';
// import 'dart:async';

// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class GMapController extends GetxController {
//   final UserCurrentLocation currrentLocController =
//       Get.find<UserCurrentLocation>();
//   final DeviceInfoController deviceInfoController =
//       Get.find<DeviceInfoController>();
// //============================================camera position here
//   CameraPosition cameraPosition =
//       const CameraPosition(target: LatLng(70.8041, 90.4152), zoom: 14);

//   Completer<GoogleMapController> mapController = Completer();

//   var markers = <Marker>[].obs;
// //=====================================================user current location here ==============>
//   getCurrentLocation() {
//     currrentLocController.getCurrentLocation().then((value) async {
//       print("user location : ${value.latitude}, ${value.longitude}");

//       updateUserLocation(
//           deviceInfoController.deviceId!, value.latitude, value.longitude);
//       // ========================camera position update here
//       cameraPosition = CameraPosition(
//         target: LatLng(value.latitude, value.longitude),
//         zoom: 14,
//       );
//       //==========================================add marker
//       markers.clear();
//       markers.add(Marker(
//         markerId: MarkerId(DateTime.now().toString()),
//         position: LatLng(value.latitude, value.longitude),
//         infoWindow: const InfoWindow(title: "Your Location"),
//       ));

//       GoogleMapController controller = await mapController.future;

//       controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//     });
//   }
//   //================================updata user location in firebase

//   void updateUserLocation(String userId, double latitude, double longitude) {
//     FirebaseFirestore.instance.collection('locations').doc(userId).set({
//       'latitude': latitude,
//       'longitude': longitude,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   @override
//   void onInit() {
//     getCurrentLocation();
//     super.onInit();
//   }
// }




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ddddd/controller/device_info_controller.dart';
// import 'package:ddddd/controller/user_current_location.dart';
// import 'package:get/get.dart';
// import 'dart:async';

// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class GMapController extends GetxController {
//   final UserCurrentLocation currrentLocController = Get.find<UserCurrentLocation>();
//   final DeviceInfoController deviceInfoController = Get.find<DeviceInfoController>();

//   // Initial Camera Position
//   CameraPosition cameraPosition = const CameraPosition(target: LatLng(70.8041, 90.4152), zoom: 14);

//   Completer<GoogleMapController> mapController = Completer();
//   var markers = <Marker>[].obs;

//   Timer? locationTimer;

//   // Get current location every 5 seconds and update in Firebase
//   getCurrentLocation() {
//     locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
//       currrentLocController.getCurrentLocation().then((value) async {
//         print("user location: ${value.latitude}, ${value.longitude}");

//         // Update user location in Firebase
//         updateUserLocation(
//           deviceInfoController.deviceId!,
//           value.latitude,
//           value.longitude,
//         );

//         // Update camera position
//         cameraPosition = CameraPosition(
//           target: LatLng(value.latitude, value.longitude),
//           zoom: 14,
//         );

//         // Clear and add marker
//         markers.clear();
//         markers.add(Marker(
//           markerId: MarkerId(DateTime.now().toString()),
//           position: LatLng(value.latitude, value.longitude),
//           infoWindow: const InfoWindow(title: "Your Location"),
//         ));

//         GoogleMapController controller = await mapController.future;

//         // Animate camera to new position
//         controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//       });
//     });
//   }

//   // Update or create user location in Firebase
// void updateUserLocation(String userId, double latitude, double longitude) {
//   FirebaseFirestore.instance.collection('locations').doc(userId).set({
//     'latitude': latitude,
//     'longitude': longitude,
//     'timestamp': FieldValue.serverTimestamp(),
//   }, SetOptions(merge: true));  // If the document doesn't exist, this will create one
// }

//   // Clean up the timer when controller is destroyed
//   @override
//   void onClose() {
//     locationTimer?.cancel();  // Stop the timer when controller is closed
//     super.onClose();
//   }

//   @override
//   void onInit() {
//     getCurrentLocation();  // Start location updates on initialization
//     super.onInit();
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ddddd/controller/device_info_controller.dart';
// import 'package:ddddd/controller/user_current_location.dart';
// import 'package:get/get.dart';
// import 'dart:async';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class GMapController extends GetxController {
//   final UserCurrentLocation currrentLocController = Get.find<UserCurrentLocation>();
//   final DeviceInfoController deviceInfoController = Get.find<DeviceInfoController>();

//   // Initial Camera Position
//   CameraPosition cameraPosition = const CameraPosition(target: LatLng(70.8041, 90.4152), zoom: 14);

//   Completer<GoogleMapController> mapController = Completer();
//   var markers = <Marker>[].obs;

//   Timer? locationTimer;
//   String? savedUserId;

//   // Load saved userId from local storage (SharedPreferences)
//   Future<void> loadUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     savedUserId = prefs.getString('userId');

//     // If userId not found, save the deviceId as userId
//     if (savedUserId == null) {
//       savedUserId = deviceInfoController.deviceId; // Use deviceId as userId
//       await prefs.setString('userId', savedUserId!);
//     }
//   }

//   // Get current location every 5 seconds and update in Firebase
//   getCurrentLocation() {
//     locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
//       currrentLocController.getCurrentLocation().then((value) async {
//         print("user location: ${value.latitude}, ${value.longitude}");

//         // Update user location in Firebase
//         updateUserLocation(
//           savedUserId!,  // Use the saved userId
//           value.latitude,
//           value.longitude,
//         );

//         // Update camera position
//         cameraPosition = CameraPosition(
//           target: LatLng(value.latitude, value.longitude),
//           zoom: 14,
//         );

//         // Clear and add marker
//         markers.clear();
//         markers.add(Marker(
//           markerId: MarkerId(DateTime.now().toString()),
//           position: LatLng(value.latitude, value.longitude),
//           infoWindow: const InfoWindow(title: "Your Location"),
//         ));

//         GoogleMapController controller = await mapController.future;

//         // Animate camera to new position
//         controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//       });
//     });
//   }

//   // Update or create user location in Firebase
//   void updateUserLocation(String userId, double latitude, double longitude) {
//     FirebaseFirestore.instance.collection('locations').doc(userId).set({
//       'latitude': latitude,
//       'longitude': longitude,
//       'timestamp': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));  // If the document doesn't exist, this will create one
//   }

//   // Clean up the timer when controller is destroyed
//   @override
//   void onClose() {
//     locationTimer?.cancel();  // Stop the timer when controller is closed
//     super.onClose();
//   }

//   @override
//   void onInit() async {
//     await loadUserId();  // Load or create userId when controller initializes
//     getCurrentLocation();  // Start location updates
//     super.onInit();
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ddddd/controller/device_info_controller.dart';
// import 'package:ddddd/controller/user_current_location.dart';
// import 'package:get/get.dart';
// import 'dart:async';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';

// class GMapController extends GetxController with WidgetsBindingObserver {
//   final UserCurrentLocation currrentLocController = Get.find<UserCurrentLocation>();
//   final DeviceInfoController deviceInfoController = Get.find<DeviceInfoController>();

//   // Initial Camera Position
//   CameraPosition cameraPosition = const CameraPosition(target: LatLng(70.8041, 90.4152), zoom: 14);

//   Completer<GoogleMapController> mapController = Completer();
//   var markers = <Marker>[].obs;

//   Timer? locationTimer;
//   String? savedUserId;

//   // Load saved userId from local storage (SharedPreferences)
//   Future<void> loadUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     savedUserId = prefs.getString('userId');

//     // If userId not found, save the deviceId as userId
//     if (savedUserId == null) {
//       savedUserId = deviceInfoController.deviceId; // Use deviceId as userId
//       await prefs.setString('userId', savedUserId!);
//     }
//   }

//   // Get current location every 5 seconds and update in Firebase
//   getCurrentLocation() {
//     locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
//       currrentLocController.getCurrentLocation().then((value) async {
//         print("user location: ${value.latitude}, ${value.longitude}");

//         // Update user location in Firebase
//         updateUserLocation(
//           savedUserId!,  // Use the saved userId
//           value.latitude,
//           value.longitude,
//         );

//         // Update camera position
//         cameraPosition = CameraPosition(
//           target: LatLng(value.latitude, value.longitude),
//           zoom: 14,
//         );

//         // Clear and add marker
//         markers.clear();
//         markers.add(Marker(
//           markerId: MarkerId(DateTime.now().toString()),
//           position: LatLng(value.latitude, value.longitude),
//           infoWindow: const InfoWindow(title: "Your Location"),
//         ));

//         GoogleMapController controller = await mapController.future;

//         // Animate camera to new position
//         controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//       });
//     });
//   }

//   // Update or create user location in Firebase
//   void updateUserLocation(String userId, double latitude, double longitude) {
//     FirebaseFirestore.instance.collection('locations').doc(userId).set({
//       'latitude': latitude,
//       'longitude': longitude,
//       'timestamp': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));  // If the document doesn't exist, this will create one
//   }

//   // Delete user location from Firebase
//   Future<void> deleteUserLocation(String userId) async {
//     await FirebaseFirestore.instance.collection('locations').doc(userId).delete();
//     print("User location deleted from Firebase for userId: $userId");
//   }

//   // App Lifecycle events handling
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     print("AppLifecycleState changed: $state");
    
//     if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
//       // User exits or pauses the app, delete the user location from Firebase
//       if (savedUserId != null) {
//         deleteUserLocation(savedUserId!);
//       }
//     }
//   }

//   // Clean up the timer when controller is destroyed
//   @override
//   void onClose() async {
//     locationTimer?.cancel();  // Stop the timer when controller is closed
//     super.onClose();
//   }

//   @override
//   void onInit() async {
//     WidgetsBinding.instance.addObserver(this);  // Observe app lifecycle
//     await loadUserId();  // Load or create userId when controller initializes
//     getCurrentLocation();  // Start location updates
//     super.onInit();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);  // Remove observer when disposing
//     super.dispose();
//   }
// }

import 'package:firebase_database/firebase_database.dart';
import 'package:ddddd/controller/device_info_controller.dart';
import 'package:ddddd/controller/user_current_location.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GMapController extends GetxController {
  final UserCurrentLocation currrentLocController = Get.find<UserCurrentLocation>();
  final DeviceInfoController deviceInfoController = Get.find<DeviceInfoController>();

  // Initial Camera Position
  CameraPosition cameraPosition = const CameraPosition(target: LatLng(70.8041, 90.4152), zoom: 14);

  Completer<GoogleMapController> mapController = Completer();
  var markers = <Marker>[].obs;

  Timer? locationTimer;
  String? savedUserId;
  DatabaseReference? userRef; // Firebase Realtime Database reference for the user

  // Load saved userId from local storage (SharedPreferences)
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedUserId = prefs.getString('userId');

    // If userId not found, save the deviceId as userId
    if (savedUserId == null) {
      savedUserId = deviceInfoController.deviceId; // Use deviceId as userId
      await prefs.setString('userId', savedUserId!);
    }
    
    // Set up Firebase Realtime Database reference for this user
    userRef = FirebaseDatabase.instance.ref('locations/$savedUserId');

    // Set onDisconnect to delete the user's data when they disconnect
    userRef!.onDisconnect().remove();  // Only this user node will be deleted, not the whole collection
  }

  // Get current location every 5 seconds and update in Firebase
  getCurrentLocation() {
    locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      currrentLocController.getCurrentLocation().then((value) async {
        print("user location: ${value.latitude}, ${value.longitude}");

        // Update user location in Firebase Realtime Database
        updateUserLocation(
          savedUserId!,
          value.latitude,
          value.longitude,
        );

        // Update camera position
        cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 14,
        );

        // Clear and add marker
        markers.clear();
        markers.add(Marker(
          markerId: MarkerId(DateTime.now().toString()),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: const InfoWindow(title: "Your Location"),
        ));

        GoogleMapController controller = await mapController.future;

        // Animate camera to new position
        controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      });
    });
  }

  // Update or create user location in Firebase Realtime Database
  void updateUserLocation(String userId, double latitude, double longitude) {
    userRef!.set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': ServerValue.timestamp,
    });
  }

  // Clean up the timer when controller is destroyed
  @override
  void onClose() async {
    locationTimer?.cancel();  // Stop the timer when controller is closed
    super.onClose();
  }

  @override
  void onInit() async {
    await loadUserId();  // Load or create userId when controller initializes
    getCurrentLocation();  // Start location updates
    super.onInit();
  }
}
