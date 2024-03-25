import "dart:async";
import "package:flutter/material.dart";
import "http_service.dart";
import "product.dart";
import "beacon_data.dart";
import "beacon_scanner.dart";

class ProductsPage extends StatefulWidget {
  ProductsPage() {
    super.key;
  }

  @override
  State<ProductsPage> createState() => _ProductsState();
}

class _ProductsState extends State<ProductsPage> {
  BeaconScanner beaconScanner = BeaconScanner();
  // List<BeaconData> beaconData = [];
  // List<String> idList = [];
  Timer? timer;

  Map<int, List<Product>>? productAisleMap;
  Map<String, int>? beaconAisleMap;
  List<Product> products = [];
  int nearestAisle = 0;
  static final int TOP_BEACON_COUNT = 3;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 6),
        (Timer t) async =>
          _scanLocalArea(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  final HttpService httpService = HttpService(
      databaseUrl : "10.0.0.94",
  );

  void _scanLocalArea() async {
    // scan for surrounding devices
    print("Starting scan...");
    if(productAisleMap == null) {
      print("productAisleMap is empty!");
      productAisleMap = await httpService.getProductAisleMap();
    }

    if(beaconAisleMap == null) {
      print("beaconAisleMap is empty!");
      beaconAisleMap = await httpService.getBeaconAisleMap();
      beaconScanner.idList = beaconAisleMap?.keys.toList() ?? [];
    }

    // beaconData = await BeaconScanner.printDevices(beaconData, idList);
    List<BeaconData>? beaconData = await beaconScanner.printDevices();

    // null checks
    if(beaconData == null || beaconData.isEmpty) {
      print("no beacon data found of ${beaconScanner.idList}...");
      return; // don't update anything
    } // */

    String? beaconID = beaconData[0].id;
    if(beaconID == null || beaconData[0].timeout >= BeaconData.MAX_TIMEOUT) {
      beaconID = ""; // effectively, say there is no beacon near by
    }

    // refresh the page such that products are shown
    setState(() {
        // set the products list to contain the products within the closest aisle, known by the beacon
        products = productAisleMap?[beaconAisleMap?[beaconID]] ?? [];
        // set the nearest aisle
        nearestAisle = beaconAisleMap?[beaconID] ?? -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Products"),
        ),
        body: ListView(
          children: products.map((Product product) =>
            ListTile(
              title: Text("Product: ${product.name} ${product.price}"),
              subtitle: Text("${product.beaconID}"),
          )).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _scanLocalArea,
          tooltip: 'Increment',
          child: Text("${nearestAisle}"),
        ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
