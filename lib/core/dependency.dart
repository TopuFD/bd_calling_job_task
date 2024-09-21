
import 'package:ddddd/controller/google_map_controller.dart';
import 'package:get/get.dart';

class DependancyInjection extends Bindings {
  @override
  void dependencies() {
    //================= google map controller ==================
    Get.lazyPut(() => GMapController());

    //================= Home Controller ==================

  
  }
}
