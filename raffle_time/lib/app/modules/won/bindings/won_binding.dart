import 'package:get/get.dart';

import '../controllers/won_controller.dart';

class WonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WonController>(
      () => WonController(),
    );
  }
}
