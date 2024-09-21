import 'package:firebase_database/firebase_database.dart';
import 'package:ddddd/controller/device_info_controller.dart';
import 'package:ddddd/controller/user_current_location.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GMapController extends GetxController {
  final UserCurrentLocation currrentLocController =
      Get.find<UserCurrentLocation>();
  final DeviceInfoController deviceInfoController =
      Get.find<DeviceInfoController>();

  //======================================init camera position
  CameraPosition cameraPosition =
      const CameraPosition(target: LatLng(23.777176, 90.399452), zoom: 14);

  Completer<GoogleMapController> mapController = Completer();
  var markers = <Marker>[].obs;
  var polylines = <Polyline>{}.obs;

  Timer? locationTimer;
  String? savedUserId;
  DatabaseReference? userRef;

  // ====================================load user id from sharedpreferance
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedUserId = prefs.getString('userId');
    if (savedUserId == null) {
      savedUserId = deviceInfoController.deviceId;
      await prefs.setString('userId', savedUserId!);
    }

    // ==============================Firebase Realtime Database reference
    userRef = FirebaseDatabase.instance.ref('locations/$savedUserId');

    // ===============================delete user if the user disconnect
    userRef!.onDisconnect().remove();
  }

  // ================================current every 5 seconds and update in Firebase
  getCurrentLocation() async {
    GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      currrentLocController.getCurrentLocation().then((value) async {
        print("User location: ${value.latitude}, ${value.longitude}");

        //================================= calling updateUserLocation method
        updateUserLocation(savedUserId!, value.latitude, value.longitude);

        // ================================update camera position
        cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 14,
        );
      });
    });
  }

  // ===========================================Update or create database
  void updateUserLocation(String userId, double latitude, double longitude) {
    userRef!.set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': ServerValue.timestamp,
    });
  }

  // ========================================================get user data
  void getUserDataRealTime() {
    DatabaseReference allUsersRef = FirebaseDatabase.instance.ref('locations');

    allUsersRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> allUsersData =
            event.snapshot.value as Map<dynamic, dynamic>;
        allUsersData.forEach((userId, userData) {
          LatLng position = LatLng(userData['latitude'], userData['longitude']);
          bool isCurrentUser = (userId == savedUserId);

          // ==========================================calling updateMarkers method
          updateMarkers(userId, position, isCurrentUser);

          // =================================================update polylines
          if (isCurrentUser) {
            LatLng currentUserPosition = position;

            allUsersData.forEach((otherUserId, otherUserData) {
              if (otherUserId != savedUserId) {
                LatLng otherUserPosition = LatLng(
                    otherUserData['latitude'], otherUserData['longitude']);
                updatePolylines(currentUserPosition, otherUserPosition);
              }
            });
          }
        });
      } else {
        print("No data available");
      }
    });
  }

  // ========================================== updateMarkers method here
  void updateMarkers(String userId, LatLng position, bool isCurrentUser) {
    int existingMarkerIndex =
        markers.indexWhere((marker) => marker.markerId.value == userId);

    if (existingMarkerIndex != -1) {
      markers[existingMarkerIndex] = Marker(
        markerId: MarkerId(userId),
        position: position,
        infoWindow:
            InfoWindow(title: isCurrentUser ? "Your Location" : "User $userId"),
        icon: isCurrentUser
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      print("Updated marker for $userId: ${markers[existingMarkerIndex]}");
    } else {
      Marker newMarker = Marker(
        markerId: MarkerId(userId),
        position: position,
        infoWindow:
            InfoWindow(title: isCurrentUser ? "Your Location" : "User $userId"),
        icon: isCurrentUser
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      markers.add(newMarker);
      print("Added new marker for $userId: $newMarker");
    }

    print("Current markers: $markers");
  }

  //=============================================poly line method

  void updatePolylines(LatLng start, LatLng end) {
    String polylineId =
        "polyline_${start.latitude}_${start.longitude}_${end.latitude}_${end.longitude}";

    polylines.add(Polyline(
      polylineId: PolylineId(polylineId),
      points: [start, end],
      color: const Color(0xFF021FF9),
      width: 5,
    ));

    print("Current polylines: $polylines");
  }

  // ====================================clean timer
  @override
  void onClose() async {
    locationTimer?.cancel();
    super.onClose();
  }

  // ================================== oninit mehtod
  @override
  void onInit() async {
    await loadUserId();
    getCurrentLocation();
    getUserDataRealTime();
    super.onInit();
  }
}
