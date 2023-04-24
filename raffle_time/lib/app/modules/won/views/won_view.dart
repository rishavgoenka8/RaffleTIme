import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:raffle_time/app/modules/home/controllers/home_controller.dart';
import 'package:raffle_time/app/widgets/RaffleView.dart';
import 'package:raffle_time/app/widgets/custom_appbar.dart';
import 'package:raffle_time/size_config.dart';

import '../controllers/won_controller.dart';

class WonView extends GetView<WonController> {
  WonView({Key? key}) : super(key: key);

  final HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Won"),
      body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(16)),
            child: Obx(() => homeController.isLoadingWonRaffles.value
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(
                          color: Colors.black,
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          "Loading Raffles",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        )
                      ],
                    ),
                  )
                : homeController.wonRaffles.isEmpty
                    ? const Center(
                        child: Text(
                          "No Raffles Won",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: homeController.wonRaffles
                            .map((raffle) => RaffleWidget(raffle: raffle))
                            .toList()))));
  }
}
