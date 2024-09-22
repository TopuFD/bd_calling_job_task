
import 'package:ddddd/controller/device_info_controller.dart';
import 'package:ddddd/controller/direction_controller.dart';
import 'package:ddddd/controller/google_map_controller.dart';
import 'package:ddddd/controller/user_current_location.dart';
import 'package:get/get.dart';

class DependancyInjection extends Bindings {
  @override
  void dependencies() {
    //================= google map controller ==================
    Get.lazyPut(() => GMapController());

    //================= user current location controller ==================
    Get.lazyPut(() => UserCurrentLocation());
    //================= get device uniq id controller ==================
    Get.lazyPut(() => DeviceInfoController());
    //================= direction api controller ==================
    Get.lazyPut(() => DirectionController());

  
  }
}
