// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:convert/convert.dart';
import 'package:raffle_time/app/data/constants/address.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:walletconnect_secure_storage/walletconnect_secure_storage.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  final count = 0.obs;
  final tabIndex = 0.obs;

  late WalletConnectSecureStorage sessionStorage;
  late WalletConnectSession session;
  late WalletConnect connector;

  late Web3Client web3client;
  final httpClient = http.Client();

  var metamaskUri, signature;
  var rpcURL = 'https://rpc-mumbai.maticvigil.com/';
  late EthereumWalletConnectProvider provider;
  var walletAddress = "".obs;

  var raffleTimeABI;
  var ticketABI;
  var erc20ABI;

  var usersRaffles = [];
  var isLoadingUsersRaffles = true.obs;

  var allRaffles = [];
  var isLoadingAllRaffles = true.obs;

  var ticketsBoughts = [];
  var isLoadingTicketsBoughts = true.obs;

  var wonRaffles = [];
  var isLoadingWonRaffles = true.obs;

  String generateSessionMessage(String accountAddress) {
    String message =
        'Hello $accountAddress, welcome to RaffleTime. By signing this message you agree to our terms and conditions.';

    var hash = keccakUtf8(message);
    final hashString = '0x${bytesToHex(hash).toString()}';

    return hashString;
  }

  loginUsingMetamask() async {
    if (!connector.connected) {
      try {
        final session = await connector.createSession(
          chainId: 80001,
          onDisplayUri: (uri) async {
            metamaskUri = uri;
            await launchUrlString(metamaskUri,
                mode: LaunchMode.externalApplication);
          },
        );
        if (kDebugMode) {
          print("session${session.chainId}");
        }
        walletAddress.value = session.accounts[0];
        provider = EthereumWalletConnectProvider(connector);
        fetchRaffles();
        // signMessageWithMetamask(generateSessionMessage(session.accounts[0]));
      } catch (exp) {
        if (kDebugMode) {
          print(exp);
        }
      }
    }
  }

  signMessageWithMetamask(String message) async {
    if (connector.connected) {
      try {
        launchUrlString(metamaskUri, mode: LaunchMode.externalApplication);
        signature = await provider.personalSign(
            message: message, address: session.accounts[0], password: "");
        if (kDebugMode) {
          print(signature);
        }
        // setState(() {
        //   _signature = signature;
        // });
      } catch (exp) {
        if (kDebugMode) {
          print(exp);
        }
      }
    }
  }

  Future<DeployedContract> getRaffleTimeContract() async {
    return DeployedContract(ContractAbi.fromJson(raffleTimeABI, 'RaffleTime'),
        EthereumAddress.fromHex(Address.raffleTime));
  }

  Future<DeployedContract> getTicketContract(
      String ticketContractAddress) async {
    return DeployedContract(ContractAbi.fromJson(ticketABI, 'Ticket'),
        EthereumAddress.fromHex(ticketContractAddress));
  }

  Future<DeployedContract> getERC20Contract(String tokenAddress) async {
    return DeployedContract(ContractAbi.fromJson(erc20ABI, 'ERC20'),
        EthereumAddress.fromHex(tokenAddress));
  }

  Future<void> createRaffle(
      String name,
      String nftContractAddress,
      String tokenId,
      String salePrice,
      String ticketPrice,
      String sellPrice,
      int endTime) async {
    final DeployedContract raffleTimeContract = await getRaffleTimeContract();

    final raffleData = raffleTimeContract.function('createRaffle').encodeCall([
      name,
      EthereumAddress.fromHex(nftContractAddress),
      BigInt.parse(tokenId),
      BigInt.from(double.parse(salePrice) * 1e18),
      BigInt.from(double.parse(ticketPrice) * 1e18),
      BigInt.parse(sellPrice),
      BigInt.from(endTime)
    ]);

    final maxGas = await web3client.estimateGas(
        sender: EthereumAddress.fromHex(walletAddress.value),
        to: EthereumAddress.fromHex(Address.raffleTime),
        gasPrice: await web3client.getGasPrice(),
        data: raffleData);

    String createRaffleTransaction;
    launchUrlString(metamaskUri, mode: LaunchMode.externalApplication);
    createRaffleTransaction = await provider
        .sendTransaction(
            from: walletAddress.value,
            to: Address.raffleTime,
            gas: maxGas.toInt(),
            gasPrice: BigInt.parse(
                (await web3client.getGasPrice()).toString().split(" ")[1]),
            data: raffleData)
        .onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      return 'Failed';
    });

    print(createRaffleTransaction);
  }

  Future<void> fetchRaffles() async {
    isLoadingAllRaffles.value = true;
    isLoadingUsersRaffles.value = true;
    isLoadingTicketsBoughts.value = true;
    isLoadingWonRaffles.value = true;

    final DeployedContract raffleTimeContract = await getRaffleTimeContract();

    final totalRaffleCount = ((await web3client.call(
            contract: raffleTimeContract,
            function: raffleTimeContract.function('raffleId'),
            params: []))[0])
        .toInt();

    for (var i = 0; i < totalRaffleCount; i++) {
      final raffleResponse = await web3client.call(
          contract: raffleTimeContract,
          function: raffleTimeContract.function('raffles'),
          params: [BigInt.from(i)]);
      print(raffleResponse);
      final raffleTicketBuyers = (await web3client.call(
          contract: raffleTimeContract,
          function: raffleTimeContract.function('getTicketBuyers'),
          params: [BigInt.from(i)]))[0];
      final raffle = {
        "raffleId": raffleResponse[0].toInt(),
        "owner": raffleResponse[1].toString(),
        "raffleName": raffleResponse[2].toString(),
        "nftAddress": raffleResponse[3].toString(),
        "nftTokenId": raffleResponse[4].toString(),
        "ticketPrice": raffleResponse[5].toString(),
        "ticketCount": raffleResponse[9].toString(),
        "endTime": raffleResponse[8].toString(),
        "winner": raffleResponse[10].toString(),
        "ended": raffleResponse[11],
      };
      var url = Uri.https(
          'testnets-api.opensea.io', 'v2/orders/mumbai/seaport/listings', {
        'format': 'json',
        'limit': '10',
        'asset_contract_address': raffle['nftAddress'],
        'token_ids': raffle['nftTokenId']
      });
      var response = await http.get(url, headers: {
        "Content-type": "application/json",
        "accept": "application/json",
      });
      // var bodyEncode = jsonEncode(response.body)
      var body = jsonDecode(response.body);
      var orders = body['orders'];
      raffle['image_url'] = orders[0]['maker_asset_bundle']['assets'][0]
              ['image_url'] ??
          "https://drive.google.com/file/d/13PjaPjovczH-E07PpKlaggtGh8Rn-i6t/view";
      print(raffle);
      if (raffle['owner'] == walletAddress.value) {
        usersRaffles.add(raffle);
      } else {
        if (raffle['ended'] == false) {
          if (walletAddress.value != "") {
            if (raffleTicketBuyers
                .contains(EthereumAddress.fromHex(walletAddress.value))) {
              ticketsBoughts.add(raffle);
            }
          }
          else {
            allRaffles.add(raffle);
          }
        } else {
          if (walletAddress.value != "") {
            if (raffle['winner'].toString().toUpperCase() ==
                walletAddress.value.toUpperCase()) {
              wonRaffles.add(raffle);
            }
          }
        }
      }
    }

    isLoadingAllRaffles.value = false;
    isLoadingUsersRaffles.value = false;
    isLoadingTicketsBoughts.value = false;
    isLoadingWonRaffles.value = false;
  }

  Future<void> buyTickets(int raffleId, String raffleName, String nftAddress,
      String nftTokenId, String ticketPrice) async {
    var data = jsonEncode({
      "pinataContent": {
        "image":
            "https://ipfs.io/ipfs/QmdLYFJxX8GnVhnZT3hDzchAcsDB3wuLJ8vwc1eX8DVK95",
        "price": ticketPrice,
        "raffleName": raffleName,
        "nftAddress": nftAddress
      }
    });
    // https://api.pinata.cloud/pinning/pinJSONToIPFS
    var urlIPFS = Uri.https('api.pinata.cloud', 'pinning/pinJSONToIPFS');
    var responseIPFS = await http.post(urlIPFS,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Address.pinataJWT}'
        },
        body: data);
    var response = jsonDecode(responseIPFS.body);
    String ipfsHash = response['IpfsHash'];

    var urlAPI = Uri.https(
        'testnets-api.opensea.io', 'v2/orders/mumbai/seaport/listings', {
      'format': 'json',
      'limit': '10',
      'asset_contract_address': nftAddress,
      'token_ids': nftTokenId
    });
    var responseAPI = await http.get(urlAPI, headers: {
      "Content-type": "application/json",
      "accept": "application/json",
    });
    // var bodyEncode = jsonEncode(responseAPI.body)
    var body = jsonDecode(responseAPI.body);
    var orders = body['orders'];
    var sellPrice = orders[0]['current_price'] ?? "0";

    var tokenURL = "https://ipfs.io/ipfs/$ipfsHash";

    final DeployedContract raffleTimeContract = await getRaffleTimeContract();

    final buyTicketData = raffleTimeContract
        .function('purchaseTickets')
        .encodeCall([BigInt.from(raffleId), BigInt.parse(sellPrice), tokenURL]);

    final DeployedContract erc20Contract = await getERC20Contract(Address.weth);
    final currentAllowance = await web3client.call(
        contract: erc20Contract,
        function: erc20Contract.function('allowance'),
        params: [
          EthereumAddress.fromHex(walletAddress.value),
          EthereumAddress.fromHex(Address.raffleTime)
        ]);

    if (currentAllowance[0].toDouble() < double.parse(ticketPrice)) {
      final BigInt newAllowance = BigInt.from(2).pow(256) - BigInt.one;

      // you can set any new allowance value here
      final approveData = erc20Contract.function('approve').encodeCall(
          [EthereumAddress.fromHex(Address.raffleTime), newAllowance]);

      final maxGas = await web3client.estimateGas(
          sender: EthereumAddress.fromHex(walletAddress.value),
          to: EthereumAddress.fromHex(Address.weth),
          gasPrice: await web3client.getGasPrice(),
          data: approveData);

      String approveTransaction;
      launchUrlString(metamaskUri, mode: LaunchMode.externalApplication);
      approveTransaction = await provider
          .sendTransaction(
        from: walletAddress.value,
        to: Address.weth,
        gas: maxGas.toInt(),
        gasPrice: BigInt.parse(
            (await web3client.getGasPrice()).toString().split(" ")[1]),
        data: approveData,
      )
          .onError((error, stackTrace) {
        print(error);
        print(stackTrace);
        return 'Approval Failed. Try Again';
      });
      print(approveTransaction);
    }

    final maxGas = await web3client
        .estimateGas(
            sender: EthereumAddress.fromHex(walletAddress.value),
            to: EthereumAddress.fromHex(Address.raffleTime),
            gasPrice: await web3client.getGasPrice(),
            data: buyTicketData)
        .onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      return BigInt.from(900000);
    });

    String purchaseTicketTransaction;
    launchUrlString(metamaskUri, mode: LaunchMode.externalApplication);
    purchaseTicketTransaction = await provider
        .sendTransaction(
            from: walletAddress.value,
            to: Address.raffleTime,
            gas: maxGas.toInt(),
            gasPrice: BigInt.parse(
                (await web3client.getGasPrice()).toString().split(" ")[1]),
            data: buyTicketData)
        .onError((error, stackTrace) {
      print(error);
      print(stackTrace);
      return 'Failed';
    });

    print(purchaseTicketTransaction);
    fetchRaffles();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  @override
  void onInit() async {
    super.onInit();
    web3client = Web3Client(rpcURL, httpClient);

    raffleTimeABI =
        await rootBundle.loadString('assets/abi/RaffleTime_ABI.json');
    ticketABI = await rootBundle.loadString('assets/abi/Ticket_ABI.json');
    erc20ABI = await rootBundle.loadString('assets/abi/ERC20_ABI.json');

    sessionStorage = WalletConnectSecureStorage();
    if (await sessionStorage.getSession() == null) {
      connector = WalletConnect(
          bridge: 'https://bridge.walletconnect.org',
          sessionStorage: sessionStorage,
          clientMeta: const PeerMeta(
              name: 'Raffle Time',
              url: 'https://walletconnect.org',
              icons: [
                'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
              ]));
    } else {
      session = (await sessionStorage.getSession())!;
      connector = WalletConnect(
          bridge: 'https://bridge.walletconnect.org',
          session: session,
          sessionStorage: sessionStorage,
          clientMeta: const PeerMeta(
              name: 'Raffle Time',
              url: 'https://walletconnect.org',
              icons: [
                'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
              ]));
      metamaskUri =
          "${session.protocol}:${session.handshakeTopic}@1?bridge=${session.bridge}&key=${hex.encode(session.key as List<int>)}";
      provider = EthereumWalletConnectProvider(connector);
      walletAddress.value = session.accounts[0];
    }
    connector.registerListeners(
      onConnect: (status) {
        walletAddress.value = status.accounts[0];
      },
    );

    fetchRaffles();
    Timer.periodic(const Duration(minutes: 1), (timer) {
      fetchRaffles();
    });
  }

  void increment() => count.value++;
}
