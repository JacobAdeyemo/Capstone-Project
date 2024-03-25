import "dart:async";

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import "beacon_data.dart";
import "beacon_scanner.dart";
import 'home_page.dart';
import "http_service.dart";
import 'landing_page.dart';
import "product_factory.dart";

void main() => runApp(MyAdaptingApp());


class MyAdaptingApp extends StatelessWidget {
  const MyAdaptingApp({super.key});

  @override
  Widget build(context) {
    // Either Material or Cupertino widgets work in either Material or Cupertino
    // Apps.
    return MaterialApp(
      title: 'Adaptive BLE App',
      theme: ThemeData(
        // Use the green theme for Material widgets.
        primaryColor: Colors.white,
      ),
      darkTheme: ThemeData.dark(),
      builder: (context, child) {
        return CupertinoTheme(
          // Instead of letting Cupertino widgets auto-adapt to the Material
          // theme (which is green), this app will use a different theme
          // for Cupertino (which is blue by default).
          data: const CupertinoThemeData(),
          child: Material(child: child),
        );
      },
      home: LoadingPage(context: context,),
    );
  }
}

class LoadingPage extends StatefulWidget {
  BuildContext context;

  LoadingPage({super.key, required this.context});

  @override
  State<LoadingPage> createState() => _LoadingPageState(context: context,);
}

class _LoadingPageState extends State<LoadingPage> {
  final BeaconScanner beaconScanner = BeaconScanner();
  int discoveryTimeout = 0;
  final int TIMEOUT_MAX = 5;

  BuildContext context;

  _LoadingPageState({required this.context});

  int nearestAisle = -1;

  //List<Product> nearestProducts = [];

  Map<int, List<Product>>? productAisleMap;
  Map<String, int>? beaconAisleMap;
  List<BeaconData>? beaconData;

  Timer? timer;

  HttpService? httpService;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      timer = Timer.periodic(
        const Duration(seconds: 6),
        (Timer t) async => await _scanLocalArea(context),
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _scanLocalArea(BuildContext context) async {
    // scan for surrounding devices
    if(discoveryTimeout > TIMEOUT_MAX) {
      _navigateToLandingPage(context);
      return;
    }

    if(httpService == null) { // get database url
      discoveryTimeout++;
      String? dbUrl = await beaconScanner.getDatabaseUrl();
      if(dbUrl == null) return;

      print("Found database URL!");
      this.httpService = HttpService(databaseUrl: dbUrl,);
    }

    print("Starting scan...");
    if (productAisleMap == null) {
      print("productAisleMap is empty!");
      productAisleMap = await httpService?.getProductAisleMap() ?? null;
    }

    if (beaconAisleMap == null) {
      print("beaconAisleMap is empty!");
      beaconAisleMap = await httpService?.getBeaconAisleMap() ?? null;
      beaconScanner.idList = beaconAisleMap?.keys.toList() ?? [];
    }

    // beaconData = await BeaconScanner.printDevices(beaconData, idList);
    List<BeaconData>? beaconData = await beaconScanner.printDevices();

    // null checks
    if (beaconData == null || beaconData.isEmpty) {
      print("no beacon data found of ${beaconScanner.idList}...");
      return; // don't update anything
    } // */

    String? beaconID = beaconData[0].id;
    if (beaconID == null || beaconData[0].timeout >= BeaconData.MAX_TIMEOUT) {
      beaconID = ""; // effectively, say there is no beacon near by
    }

    nearestAisle = beaconAisleMap?[beaconID] ?? -1;

    if (nearestAisle != -1) {
      _navigateToPlatformAdaptingHomePage(context);
    } else {
      _navigateToLandingPage(context);
    }
  }

  Future<void> _navigateToLandingPage(BuildContext context) async {
    // navigate to LandingPage
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LandingPage()),
    );
  }

  Future<void> _navigateToPlatformAdaptingHomePage(BuildContext context) async {
    // navigate to PlatformAdaptingHomePage
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PlatformAdaptingHomePage(
          beaconAisleMap: beaconAisleMap,
          productAisleMap: productAisleMap,
          firstAisle: nearestAisle,
        ),
      ),
    );
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircularProgressIndicator(),
            Text(
              'Nearby Now',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
