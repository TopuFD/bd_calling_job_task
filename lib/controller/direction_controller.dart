import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class DirectionController extends GetxController {
  var distanceText = ''.obs;
  var durationText = ''.obs;

  // ==========================================================> direction api calling method================>
  Future<List<LatLng>> fetchDirections(LatLng start, LatLng end) async {
    String apiKey = 'AIzaSyBzGbuM7guIo2LLK1KpOoOEufUId4h0dz4';
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<LatLng> points = [];

      // =================================================tracking distance and duration========================>
      if (data['routes'].isNotEmpty) {
        String encodedPoints = data['routes'][0]['overview_polyline']['points'];
        points = decodePolyline(encodedPoints);

        String distance = data['routes'][0]['legs'][0]['distance']['text'];
        String duration = data['routes'][0]['legs'][0]['duration']['text'];
        distanceText.value = distance;
        durationText.value = duration;
      } else {
        print('No routes found.');
        return [];
      }
      return points;
    } else {
      throw Exception('Failed to load directions');
    }
  }

  // ========================================================> dicode polyline points===============>
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result >> 1) ^ (-(result & 1)));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result >> 1) ^ (-(result & 1)));
      lng += dlng;

      LatLng point = LatLng((lat / 1E5), (lng / 1E5));
      points.add(point);
    }

    return points;
  }
}
