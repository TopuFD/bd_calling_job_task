
import 'package:ddddd/controller/device_info_controller.dart';
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
    //================= get device uniq id ==================
    Get.lazyPut(() => DeviceInfoController());

  
  }
}
