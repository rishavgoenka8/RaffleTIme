import 'package:get/get.dart';

import '../controllers/raffles_controller.dart';

class RafflesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RafflesController>(
      () => RafflesController(),
    );
  }
}
