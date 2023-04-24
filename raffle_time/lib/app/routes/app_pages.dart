import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/nfts/bindings/nfts_binding.dart';
import '../modules/nfts/views/nfts_view.dart';
import '../modules/raffles/bindings/raffles_binding.dart';
import '../modules/raffles/views/raffles_view.dart';
import '../modules/tickets/bindings/tickets_binding.dart';
import '../modules/tickets/views/tickets_view.dart';
import '../modules/won/bindings/won_binding.dart';
import '../modules/won/views/won_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // ignore: constant_identifier_names
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.NFTS,
      page: () => NftsView(),
      binding: NftsBinding(),
    ),
    GetPage(
      name: _Paths.RAFFLES,
      page: () => RafflesView(),
      binding: RafflesBinding(),
    ),
    GetPage(
      name: _Paths.TICKETS,
      page: () => TicketsView(),
      binding: TicketsBinding(),
    ),
    GetPage(
      name: _Paths.WON,
      page: () => WonView(),
      binding: WonBinding(),
    ),
  ];
}
