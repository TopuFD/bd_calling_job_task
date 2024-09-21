// import 'package:firebase_database/firebase_database.dart';
// import 'package:ddddd/controller/device_info_controller.dart';
// import 'package:ddddd/controller/user_current_location.dart';
// import 'package:get/get.dart';
// import 'dart:async';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class GMapController extends GetxController {
//   final UserCurrentLocation currrentLocController =
//       Get.find<UserCurrentLocation>();
//   final DeviceInfoController deviceInfoController =
//       Get.find<DeviceInfoController>();

//   // Initial Camera Position
//   CameraPosition cameraPosition =
//       const CameraPosition(target: LatLng(70.8041, 90.4152), zoom: 14);

//   Completer<GoogleMapController> mapController = Completer();
//   var markers = <Marker>[].obs;

//   Timer? locationTimer;
//   String? savedUserId;
//   DatabaseReference?
//       userRef; // Firebase Realtime Database reference for the user

//   // Load saved userId from local storage (SharedPreferences)
//   Future<void> loadUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     savedUserId = prefs.getString('userId');

//     // If userId not found, save the deviceId as userId
//     if (savedUserId == null) {
//       savedUserId = deviceInfoController.deviceId; // Use deviceId as userId
//       await prefs.setString('userId', savedUserId!);
//     }

//     // Set up Firebase Realtime Database reference for this user
//     userRef = FirebaseDatabase.instance.ref('locations/$savedUserId');

//     // Set onDisconnect to delete the user's data when they disconnect
//     userRef!
//         .onDisconnect()
//         .remove(); // Only this user node will be deleted, not the whole collection
//   }

//   // Get current location every 5 seconds and update in Firebase
//   getCurrentLocation() {
//     locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
//       currrentLocController.getCurrentLocation().then((value) async {
//         print("user location: ${value.latitude}, ${value.longitude}");

//         // Update user location in Firebase Realtime Database
//         updateUserLocation(
//           savedUserId!,
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
//         controller
//             .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//       });
//     });
//   }

//   // Update or create user location in Firebase Realtime Database
//   void updateUserLocation(String userId, double latitude, double longitude) {
//     userRef!.set({
//       'latitude': latitude,
//       'longitude': longitude,
//       'timestamp': ServerValue.timestamp,
//     });
//   }

//   //======================================get user data real time
//   void getUserDataRealTime(String userId) {
//     DatabaseReference userRef =
//         FirebaseDatabase.instance.ref('locations/$userId');

//     userRef.onValue.listen((DatabaseEvent event) {
//       if (event.snapshot.exists) {
//         Map<String, dynamic> userData =
//             Map<String, dynamic>.from(event.snapshot.value as Map);
//         print(
//             "Real-time User Location: ${userData['latitude']}, ${userData['longitude']}");
//         markers.clear();
//         markers.add(Marker(
//             markerId: MarkerId(userId),
//             position: LatLng(userData['latitude'], userData['longitude']),
//             infoWindow: InfoWindow(
//               title: userId.toString(),
//             )));
//       } else {
//         print("No data available for user $userId");
//       }
//     });
//   }

//   // Clean up the timer when controller is destroyed
//   @override
//   void onClose() async {
//     locationTimer?.cancel(); // Stop the timer when controller is closed
//     super.onClose();
//   }

//   @override
//   void onInit() async {
//     getUserDataRealTime(savedUserId!);
//     await loadUserId(); // Load or create userId when controller initializes
//     getCurrentLocation(); // Start location updates
//     super.onInit();
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
  DatabaseReference? userRef;

  // Load saved userId from local storage (SharedPreferences)
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedUserId = prefs.getString('userId');

    // If userId not found, save the deviceId as userId
    if (savedUserId == null) {
      savedUserId = deviceInfoController.deviceId;
      await prefs.setString('userId', savedUserId!);
    }

    // Set up Firebase Realtime Database reference for this user
    userRef = FirebaseDatabase.instance.ref('locations/$savedUserId');

    // Set onDisconnect to delete the user's data when they disconnect
    userRef!.onDisconnect().remove();
  }

  // Get current location every 5 seconds and update in Firebase
  getCurrentLocation() {
    locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      currrentLocController.getCurrentLocation().then((value) async {
        print("user location: ${value.latitude}, ${value.longitude}");

        // Update user location in Firebase Realtime Database
        updateUserLocation(savedUserId!, value.latitude, value.longitude);

        // Update camera position
        cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 14,
        );

        // Update marker for current user
        updateMarkers(savedUserId!, LatLng(value.latitude, value.longitude), true);

        GoogleMapController controller = await mapController.future;
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

  //======================================get user data real time
  void getUserDataRealTime() {
    DatabaseReference allUsersRef = FirebaseDatabase.instance.ref('locations');

    allUsersRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> allUsersData = event.snapshot.value as Map<dynamic, dynamic>;
        markers.clear();

        allUsersData.forEach((userId, userData) {
          LatLng position = LatLng(userData['latitude'], userData['longitude']);
          bool isCurrentUser = (userId == savedUserId);

          // Add marker with different color for current user
          updateMarkers(userId, position, isCurrentUser);
        });
      } else {
        print("No data available");
      }
    });
  }

  // Add/update marker for a user
  void updateMarkers(String userId, LatLng position, bool isCurrentUser) {
    markers.add(Marker(
      markerId: MarkerId(userId),
      position: position,
      infoWindow: InfoWindow(title: isCurrentUser ? "Your Location" : "User $userId"),
      icon: isCurrentUser
          ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue) // Blue for current user
          : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Red for other users
    ));
  }

  // Clean up the timer when controller is destroyed
  @override
  void onClose() async {
    locationTimer?.cancel();
    super.onClose();
  }

  @override
  void onInit() async {
    await loadUserId();
    getCurrentLocation();
    getUserDataRealTime();
    super.onInit();
  }
}
