import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:raffle_time/app/data/constants/icons.dart';
import 'package:raffle_time/app/modules/nfts/controllers/nfts_controller.dart';
import 'package:raffle_time/app/modules/nfts/views/nfts_view.dart';
import 'package:raffle_time/app/modules/raffles/controllers/raffles_controller.dart';
import 'package:raffle_time/app/modules/raffles/views/raffles_view.dart';
import 'package:raffle_time/app/modules/tickets/controllers/tickets_controller.dart';
import 'package:raffle_time/app/modules/tickets/views/tickets_view.dart';
import 'package:raffle_time/app/modules/won/controllers/won_controller.dart';
import 'package:raffle_time/app/modules/won/views/won_view.dart';
import 'package:raffle_time/size_config.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    
    final HomeController homeController = Get.find();
    final NftsController nftsController = Get.put(NftsController());
    final RafflesController rafflesController = Get.put(RafflesController());
    final TicketsController ticketsController = Get.put(TicketsController());
    final WonController wonController = Get.put(WonController());

    const Color selectedIconColor = Color(0xFFEA9528);
    const Color unselectedIconColor = Color(0xFF9492A0);
    return Obx(
      () => Scaffold(
        body: Obx(
          () => IndexedStack(
            index: homeController.tabIndex.value,
            children: [
              NftsView(),
              RafflesView(),
              TicketsView(),
              WonView()
            ],
          ),
        ),
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            unselectedItemColor: unselectedIconColor,
            selectedItemColor: selectedIconColor,
            onTap: homeController.changeTabIndex,
            currentIndex: homeController.tabIndex.value,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 10,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppIcons.nftIcon,
                  height: 24,
                  color: homeController.tabIndex.value == 0
                      ? selectedIconColor
                      : unselectedIconColor,
                ),
                label: 'NFTS',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppIcons.raffleIcon,
                  height: 24,
                  color: homeController.tabIndex.value == 1
                      ? selectedIconColor
                      : unselectedIconColor,
                ),
                label: 'Raffles',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppIcons.ticketIcon,
                  height: 24,
                  color: homeController.tabIndex.value == 2
                      ? selectedIconColor
                      : unselectedIconColor,
                ),
                label: 'Tickets',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  AppIcons.winIcon,
                  height: 24,
                  color: homeController.tabIndex.value == 3
                      ? selectedIconColor
                      : unselectedIconColor,
                ),
                label: 'Won',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
