// ignore_for_file: unnecessary_overrides
import 'package:get/get.dart';

class RafflesController extends GetxController {
  var tabIndex = 0.obs;

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  void increment() => count.value++;
}
