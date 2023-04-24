import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raffle_time/app/modules/home/controllers/home_controller.dart';
import 'package:raffle_time/app/modules/nfts/controllers/nfts_controller.dart';
import 'package:raffle_time/size_config.dart';

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    super.key,
    required this.title,
  });

  String title;
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final HomeController homeController = Get.find();
  final NftsController nftsController = Get.find();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AppBar(
      elevation: 1,
      shadowColor: Colors.white,
      centerTitle: false,
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      backgroundColor: Colors.white,
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Obx(
            () => InkWell(
              onTap: () {
                homeController.walletAddress.value != ""
                    ? null
                    : homeController.loginUsingMetamask();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                // width: getProportionateScreenWidth(80),
                height: getProportionateScreenHeight(56),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black)),
                alignment: Alignment.center,
                child: Text(
                  homeController.walletAddress.value != ""
                      ? "${homeController.walletAddress.value.toString().substring(0, 4)}...${homeController.walletAddress.value.toString().substring(homeController.walletAddress.value.toString().length - 4)}"
                      : "Connect",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
