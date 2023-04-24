// ignore_for_file: unnecessary_overrides

import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:raffle_time/app/modules/home/controllers/home_controller.dart';

class NftsController extends GetxController {
  final count = 0.obs;

  var nftListings = [];
  var isLoading = true.obs;

  final HomeController homeController = Get.find();

  Future<void> fetchNFTListings() async {
    // https://testnets-api.opensea.io/v2/orders/mumbai/seaport/listings?format=json&limit=10
    var url = Uri.https('testnets-api.opensea.io',
        'v2/orders/mumbai/seaport/listings', {'format': 'json', 'limit': '10'});
    var response = await http.get(url, headers: {
      "Content-type": "application/json",
      "accept": "application/json",
    });
    // var bodyEncode = jsonEncode(response.body)
    var body = jsonDecode(response.body);
    var orders = body['orders'];
    for (var order in orders) {
      var data = {
        "sale_expiry": order['expiration_time'] ?? "",
        "current_price": order['current_price'] ?? "",
        "currency": order['taker_asset_bundle']['assets'][0]['asset_contract']
                ['symbol'] ??
            "",
        "token_id": order['maker_asset_bundle']['assets'][0]['token_id'] ?? "",
        "image_url": order['maker_asset_bundle']['assets'][0]['image_url'] ??
            "https://drive.google.com/file/d/13PjaPjovczH-E07PpKlaggtGh8Rn-i6t/view",
        "name": order['maker_asset_bundle']['assets'][0]['name'] ?? "",
        "description":
            order['maker_asset_bundle']['assets'][0]['description'] ?? "",
        "address": order['maker_asset_bundle']['assets'][0]['asset_contract']
                ['address'] ??
            "",
      };
      nftListings.add(data);
    }
    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    fetchNFTListings();
    Timer(const Duration(minutes: 1), () {
      fetchNFTListings();
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
