import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:raffle_time/app/widgets/create_raffle.dart';
import 'package:raffle_time/app/widgets/custom_appbar.dart';
import 'package:raffle_time/size_config.dart';

import '../controllers/nfts_controller.dart';

class NftsView extends GetView<NftsController> {
  NftsView({Key? key}) : super(key: key);

  final NftsController nftsController = Get.find();
  // final NftsController nftsController = Get.put(NftsController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: CustomAppBar(title: "NFTs"),
        body: Obx(() => nftsController.isLoading.value
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
                      "Loading NFT listings",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
              )
            // : const Text("data")
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(16),
                    vertical: getProportionateScreenHeight(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: nftsController.nftListings
                      .map((nftListing) => Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black)),
                                child: Column(
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.8,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8)),
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  nftListing['image_url']),
                                              fit: BoxFit.fill)),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.all(
                                          getProportionateScreenWidth(16)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            nftListing['name'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            nftListing['address'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          // Text(
                                          //   nftListing['description'] ,
                                          //   style: const TextStyle(
                                          //     fontSize: 12,
                                          //     // fontWeight: FontWeight.w600,
                                          //     color: Colors.black,
                                          //   ),
                                          // )
                                          SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    12),
                                          ),
                                          Text(
                                            "Sell Price: ${BigInt.parse(nftListing['current_price']) / BigInt.parse('1000000000000000000')} ${nftListing['currency']}",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            "Sell Expiry At: ${DateFormat('dd/MM/yy HH:mm').format(DateTime.fromMillisecondsSinceEpoch((int.parse(nftListing['sale_expiry'].toString())) * 1000))}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    12),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Get.dialog(CreateRaffle(nftListing: nftListing,), barrierColor: Colors.black54);
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              // width: getProportionateScreenWidth(80),
                                              height:
                                                  getProportionateScreenHeight(
                                                      56),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                      color: Colors.black)),
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
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              )
                            ],
                          ))
                      .toList(),
                ),
              )));
  }
}
