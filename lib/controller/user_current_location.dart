import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class UserCurrentLocation extends GetxController {
  // ======================================get user current location here==========>
  Future getCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError(
      (error, stackTrace) async {
        await Geolocator.requestPermission();
        print("geolocator error");
      },
    );
    return await Geolocator.getCurrentPosition();
  }

  @override
  void onInit() {
    getCurrentLocation();
    super.onInit();
  }
}
