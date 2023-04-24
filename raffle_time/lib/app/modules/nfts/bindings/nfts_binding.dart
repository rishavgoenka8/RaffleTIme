import 'package:get/get.dart';

import '../controllers/nfts_controller.dart';

class NftsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NftsController>(
      () => NftsController(),
    );
  }
}
