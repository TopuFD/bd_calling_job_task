import 'dart:async';
import 'package:ddddd/controller/device_info_controller.dart';
import 'package:ddddd/controller/user_current_location.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'direction_controller.dart';

class GMapController extends GetxController {
  final UserCurrentLocation currrentLocController =
      Get.find<UserCurrentLocation>();
  final DeviceInfoController deviceInfoController =
      Get.find<DeviceInfoController>();
  final DirectionController directionController =
      Get.find<DirectionController>();

  // ============initial camera position=====================>
  CameraPosition cameraPosition =
      const CameraPosition(target: LatLng(23.777176, 90.399452), zoom: 14);

  Completer<GoogleMapController> mapController = Completer();
  var markers = <Marker>[].obs;
  var polylines = <Polyline>{}.obs;

  Timer? locationTimer;
  Timer? polylineUpdateTimer;
  String? savedUserId;
  DatabaseReference? userRef;

  // ==================================> load user id=============================>
  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedUserId = prefs.getString('userId');
    if (savedUserId == null) {
      savedUserId = deviceInfoController.deviceId;
      await prefs.setString('userId', savedUserId!);
    }

    // ==================================> firebase realtime ref =============================>
    userRef = FirebaseDatabase.instance.ref('locations/$savedUserId');

    // ==================================> delete ref if dissconnect =============================>
    userRef!.onDisconnect().remove();
  }

  // ==================================> corrent location every 5m =============================>
  getCurrentLocation() async {
    GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      currrentLocController.getCurrentLocation().then((value) async {
        //==============================> calling updateUserLocation method================>
        updateUserLocation(savedUserId!, value.latitude, value.longitude);

        //==================================> update cemera position===============>
        cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 14,
        );
      });
    });
  }

  // ==================================>updateUserLocation method=============================>
  void updateUserLocation(String userId, double latitude, double longitude) {
    userRef!.set({
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': ServerValue.timestamp,
    });
  }

  // ==================================>update polyline every 5m=============================>
  void startPolylineUpdate() {
    polylineUpdateTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      currrentLocController.getCurrentLocation().then((currentLocation) {
        DatabaseReference allUsersRef =
            FirebaseDatabase.instance.ref('locations');
        allUsersRef.once().then((event) {
          if (event.snapshot.exists) {
            Map<dynamic, dynamic> allUsersData =
                event.snapshot.value as Map<dynamic, dynamic>;
            LatLng currentUserPosition =
                LatLng(currentLocation.latitude, currentLocation.longitude);
            allUsersData.forEach((otherUserId, otherUserData) async {
              if (otherUserId != savedUserId) {
                LatLng otherUserPosition = LatLng(
                    otherUserData['latitude'], otherUserData['longitude']);

                //========================fetchDirections method calling====================>
                List<LatLng> routePoints = await directionController
                    .fetchDirections(currentUserPosition, otherUserPosition);

                // =================update polyline===============>
                if (routePoints.isNotEmpty) {
                  polylines.clear();
                  updateRoutePolyline(routePoints);
                }
              }
            });
          }
        });
      });
    });
  }

  // ============================>get user data form realtime database===========>
  void getUserDataRealTime() {
    DatabaseReference allUsersRef = FirebaseDatabase.instance.ref('locations');
    allUsersRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> allUsersData =
            event.snapshot.value as Map<dynamic, dynamic>;
        allUsersData.forEach((userId, userData) {
          LatLng position = LatLng(userData['latitude'], userData['longitude']);
          bool isCurrentUser = (userId == savedUserId);

          // ==============calling updateMarkers method===========>
          updateMarkers(userId, position, isCurrentUser);

          if (!isCurrentUser) {
            LatLng otherUserPosition = position;

            currrentLocController.getCurrentLocation().then((currentLocation) {
              LatLng currentUserPosition =
                  LatLng(currentLocation.latitude, currentLocation.longitude);
              addPolylineForRoute(currentUserPosition, otherUserPosition);
            });
          }
        });
      } else {
        print("No data available");
      }
    });
  }

  // ==================================> updateMarkers here=============================>
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
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    } else {
      Marker newMarker = Marker(
        markerId: MarkerId(userId),
        position: position,
        infoWindow:
            InfoWindow(title: isCurrentUser ? "Your Location" : "User $userId"),
        icon: isCurrentUser
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      markers.add(newMarker);
    }
  }

  // ===============================addPolylineForRoute method here=================>
  Future<void> addPolylineForRoute(LatLng start, LatLng end) async {
    List<LatLng> routePoints =
        await directionController.fetchDirections(start, end);
    if (routePoints.isNotEmpty) {
      updateRoutePolyline(routePoints);
    }
  }

  // ===========================update updateRoutePolyline method =============>
  void updateRoutePolyline(List<LatLng> routePoints) {
    String polylineId =
        "polyline_${routePoints.first.latitude}_${routePoints.first.longitude}_${routePoints.last.latitude}_${routePoints.last.longitude}";
    polylines.add(Polyline(
      polylineId: PolylineId(polylineId),
      points: routePoints,
      color: const Color(0xFF021FF9),
      width: 7,
    ));
  }

  // =====================================add polyline for other user================>
  void addPolylineForOtherUsers(double lat, double lng) {
    DatabaseReference allUsersRef = FirebaseDatabase.instance.ref('locations');
    allUsersRef.once().then((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> allUsersData =
            event.snapshot.value as Map<dynamic, dynamic>;
        LatLng currentUserPosition = LatLng(lat, lng);
        allUsersData.forEach((otherUserId, otherUserData) {
          if (otherUserId != savedUserId) {
            LatLng otherUserPosition =
                LatLng(otherUserData['latitude'], otherUserData['longitude']);
            addPolylineForRoute(currentUserPosition, otherUserPosition);
          }
        });
      }
    });
  }

  // ================onClose method here===========>
  @override
  void onClose() async {
    locationTimer?.cancel();
    polylineUpdateTimer?.cancel();
    super.onClose();
  }

  // =====================onInit method here===============>
  @override
  void onInit() async {
    await loadUserId();
    getCurrentLocation();
    getUserDataRealTime();
    startPolylineUpdate();
    super.onInit();
  }
}
