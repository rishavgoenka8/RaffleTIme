import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raffle_time/app/modules/home/controllers/home_controller.dart';
import 'package:raffle_time/size_config.dart';
import 'package:share_plus/share_plus.dart';

class RaffleWidget extends StatelessWidget {
  final Map<dynamic, dynamic> raffle;

  RaffleWidget({super.key, required this.raffle});

  final HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black)),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                    image: DecorationImage(
                        image: NetworkImage(raffle['image_url']),
                        fit: BoxFit.fill)),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          raffle['raffleName'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              await Share.share(
                                  "Join my Raffle\nRaffle Name: ${raffle['name']}\nNFT Address ${raffle['nftAddress']}",
                                  subject: "Raffle Time");
                            },
                            icon: const Icon(Icons.share_outlined))
                      ],
                    ),
                    Text(
                      "NFT Address: ${raffle['nftAddress']}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    // Text(
                    //   raffle['description'] ,
                    //   style: const TextStyle(
                    //     fontSize: 12,
                    //     // fontWeight: FontWeight.w600,
                    //     color: Colors.black,
                    //   ),
                    // )
                    SizedBox(
                      height: getProportionateScreenHeight(12),
                    ),
                    raffle['owner'] == homeController.walletAddress.value
                        ? Text(
                            "Raffle Tickets Bought: ${(BigInt.parse(raffle['ticketCount']) / BigInt.parse('1000000000000000000')).toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          )
                        : Container(),
                    Text(
                      "Raffle Ticket Price: ${BigInt.parse(raffle['ticketPrice']) / BigInt.parse('1000000000000000000')} WETH",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Raffle Expiry At: ${DateFormat('dd/MM/yy HH:mm').format(DateTime.fromMillisecondsSinceEpoch((int.parse(raffle['endTime'].toString())) * 1000))}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    raffle['owner'] != homeController.walletAddress.value
                        ? Column(
                            children: [
                              SizedBox(
                                height: getProportionateScreenHeight(12),
                              ),
                              InkWell(
                                onTap: () {
                                  homeController.buyTickets(
                                      raffle["raffleId"],
                                      raffle["raffleName"],
                                      raffle["nftAddress"],
                                      raffle["nftTokenId"],
                                      raffle["ticketPrice"]);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  // width: getProportionateScreenWidth(80),
                                  height: getProportionateScreenHeight(56),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.black)),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Buy Raffle Ticket",
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
                          )
                        : Container(),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        )
      ],
    );
  }
}
