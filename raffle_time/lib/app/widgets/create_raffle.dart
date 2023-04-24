import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:raffle_time/app/modules/home/controllers/home_controller.dart';
import 'package:raffle_time/app/modules/nfts/controllers/nfts_controller.dart';
import 'package:raffle_time/size_config.dart';

class CreateRaffle extends StatelessWidget {
  CreateRaffle({super.key, required this.nftListing});

  final NftsController nftsController = Get.find();
  final HomeController homeController = Get.find();

  final Map<String, dynamic> nftListing;

  final TextEditingController raffleName = TextEditingController();
  final TextEditingController salePrice = TextEditingController();
  final TextEditingController ticketPrice = TextEditingController();
  Rx<DateTime> raffleEndTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 1,
          DateTime.now().hour,
          DateTime.now().minute)
      .obs;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(16),
          vertical: getProportionateScreenHeight(8)),
      child: InkWell(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(12),
              vertical: getProportionateScreenHeight(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Create Raffle!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.cancel_presentation_sharp))
                ],
              ),
              const Text(
                "Enter Raffle Name:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(8),
              ),
              Container(
                height: getProportionateScreenHeight(48),
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(8),
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black)),
                child: TextField(
                  controller: raffleName,
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  textAlign: TextAlign.left,
                  decoration:
                      const InputDecoration(hintText: 'Enter Raffle Name'),
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(8),
              ),
              const Text(
                "Sale price:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(8),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: getProportionateScreenHeight(48),
                    width: getProportionateScreenWidth(263),
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(8),
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.zero,
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.zero),
                        border: Border.all(color: Colors.black)),
                    child: TextField(
                      controller: salePrice,
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      textAlign: TextAlign.left,
                      decoration:
                          const InputDecoration(hintText: 'Enter Sale Price'),
                    ),
                  ),
                  Container(
                    height: getProportionateScreenHeight(48),
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(12),
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.zero,
                            bottomRight: Radius.circular(8)),
                        border: Border.all(color: Colors.black)),
                    child: const Text(
                      "WETH",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: getProportionateScreenHeight(8),
              ),
              const Text(
                "Ticket price:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(8),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: getProportionateScreenHeight(48),
                    width: getProportionateScreenWidth(263),
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(8),
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.zero,
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.zero),
                        border: Border.all(color: Colors.black)),
                    child: TextField(
                      controller: ticketPrice,
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      textAlign: TextAlign.left,
                      decoration:
                          const InputDecoration(hintText: 'Enter Ticket Price'),
                    ),
                  ),
                  Container(
                    height: getProportionateScreenHeight(48),
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(12),
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.zero,
                            bottomRight: Radius.circular(8)),
                        border: Border.all(color: Colors.black)),
                    child: const Text(
                      "WETH",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: getProportionateScreenHeight(8),
              ),
              const Text(
                "Raffle End Time:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: getProportionateScreenHeight(8),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(context,
                          minTime: DateTime.now(),
                          maxTime: DateTime.fromMillisecondsSinceEpoch(
                              (int.parse(
                                      nftListing['sale_expiry'].toString())) *
                                  1000),
                          showTitleActions: true, onConfirm: (date) {
                        raffleEndTime.value = date;
                      }, currentTime: raffleEndTime.value);
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                  Obx(
                    () => Text(raffleEndTime.value.toString()),
                  )
                ],
              ),
              InkWell(
                onTap: () {
                  homeController.createRaffle(
                      raffleName.text,
                      nftListing['address'],
                      nftListing['token_id'],
                      salePrice.text,
                      ticketPrice.text,
                      nftListing['current_price'],
                      int.parse(
                          (raffleEndTime.value.millisecondsSinceEpoch / 1000)
                              .round()
                              .toString()));
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
                  child: const Text(
                    "Create Raffle",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
