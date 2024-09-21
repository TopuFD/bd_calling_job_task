import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoController extends GetxController {
  String? deviceId;
  getId() {
    final uuid = Uuid().v4();
    deviceId = uuid.substring(0, 5);
  }

  @override
  void onInit() {
    getId();
    super.onInit();
  }
}
