import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:raffle_time/app/modules/home/controllers/home_controller.dart';
import 'package:raffle_time/app/widgets/RaffleView.dart';
import 'package:raffle_time/app/widgets/custom_appbar.dart';
import 'package:raffle_time/size_config.dart';

import '../controllers/raffles_controller.dart';

class RafflesView extends GetView<RafflesController> {
  RafflesView({Key? key}) : super(key: key);

  final HomeController homeController = Get.find();
  final RafflesController rafflesController = Get.find();
  // final RafflesController rafflesController = Get.put(RafflesController());

  final List<Tab> tabs = <Tab>[
    Tab(
      child: Container(
        alignment: Alignment.center,
        child: const Text("All"),
      ),
    ),
    Tab(
      child: Container(
        alignment: Alignment.center,
        child: const Text("Yours"),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: "Raffles"),
        body: SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16)),
          child: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    onTap: (index) => rafflesController.changeTabIndex(index),
                    labelPadding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(40)),
                    indicatorColor: const Color(0xFFEA9528),
                    labelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600),
                    labelColor: const Color(0xFFEA9528),
                    unselectedLabelColor: const Color(0xFF4A4960),
                    tabs: tabs,
                    indicator: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Color(0xFFEA9528)))),
                  ),
                  Obx(() => Container(
                        child: (() {
                          switch (rafflesController.tabIndex.value) {
                            case 0:
                              return Obx(() => homeController
                                      .isLoadingAllRaffles.value
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: const [
                                          CircularProgressIndicator(
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            height: 24,
                                          ),
                                          Text(
                                            "Loading All Raffles",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : homeController.allRaffles.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "No Raffles Created",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                          ),
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: homeController.allRaffles
                                              .map((raffle) =>
                                                  RaffleWidget(raffle: raffle))
                                              .toList()));
                            default:
                              return Obx(() => homeController
                                      .isLoadingAllRaffles.value
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: const [
                                          CircularProgressIndicator(
                                            color: Colors.black,
                                          ),
                                          SizedBox(
                                            height: 24,
                                          ),
                                          Text(
                                            "Loading Your Raffles",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : homeController.usersRaffles.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "No Raffles Created",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                            ),
                                          ),
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: homeController.usersRaffles
                                              .map((raffle) =>
                                                  RaffleWidget(raffle: raffle))
                                              .toList()));
                          }
                        }()),
                      ))
                ],
              )),
        ));
  }
}
