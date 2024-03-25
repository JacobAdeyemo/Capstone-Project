import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import "beacon_data.dart";
import "beacon_scanner.dart";
import "product_factory.dart";
import 'sale_tab.dart';
import 'widgets.dart';

/// Page shown when a card in the beacons tab is tapped.
///
/// On Android, this page sits at the top of your app. On iOS, this page is on
/// top of the beacons tab's content but is below the tab bar itself.
class AislesDetailTab extends StatefulWidget {
  final String aisle;
  final Map<String, int>? beaconAisleMap;
  final Map<int, List<Product>>? productAisleMap;
  final List<Product>? products;

  const AislesDetailTab({
    required this.aisle,
    required this.beaconAisleMap,
    required this.productAisleMap,
    required this.products,
    Key? key,
  }) : super(key: key);

  @override
  State<AislesDetailTab> createState() => _AislesDetailTabState();
}

class _AislesDetailTabState extends State<AislesDetailTab> {
  final BeaconScanner beaconScanner = BeaconScanner();

  late int nearestAisle;
  late List<Product> nearestProducts;
  bool showFloatingButton = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 6), (timer) async => {_getNearestAisle()});
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _getNearestAisle() async {
    if (beaconScanner.idList.isEmpty)
      print("beacons: ${widget.beaconAisleMap?.keys}");
    beaconScanner.idList = widget.beaconAisleMap?.keys.toList() ?? [];

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

    // Set the nearest aisle and corresponding products
    nearestAisle = widget.beaconAisleMap?[beaconID] ?? -1;
    nearestProducts = widget.productAisleMap?[nearestAisle] ?? [];

    setState(() {
      showFloatingButton = widget.aisle != "Aisle $nearestAisle";
    });
  }

  Widget _buildBody() {
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4 / 5,
        ),
        itemCount: widget.products!.length,
        itemBuilder: (context, index) {
          final item = widget.products![index];
          return Card(
            elevation: 1.3,
            margin: const EdgeInsets.fromLTRB(6, 12, 6, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(item.name),
                  subtitle: Text('Stock: ${item.stock.toString()}'),
                  trailing: Text('\$${item.price.toString()}'),
                ),
                Image.network(
                  item.imgurl,
                  width: 140.0,
                  height: 140.0,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.aisle)),
      body: _buildBody(),
      floatingActionButton: Visibility(
        visible: showFloatingButton,
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to the next aisle.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => AislesDetailTab(
                  aisle: "Aisle $nearestAisle",
                  beaconAisleMap: widget.beaconAisleMap,
                  productAisleMap: widget.productAisleMap,
                  products: widget.productAisleMap![nearestAisle],
                ),
              ),
            );
          },
          child: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.aisle),
        previousPageTitle: 'Aisles',
        trailing: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SaleTab(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Text("Sale!!!"),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: _buildBody(),
            ),
            Visibility(
              visible: showFloatingButton,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, bottom: 70),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: CupertinoButton(
                      onPressed: () {
                        // Navigate to the next aisle.
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => AislesDetailTab(
                              aisle: "Aisle $nearestAisle",
                              beaconAisleMap: widget.beaconAisleMap,
                              productAisleMap: widget.productAisleMap,
                              products: widget.productAisleMap![nearestAisle],
                            ),
                          ),
                        );
                      },
                      child: const Icon(CupertinoIcons.forward,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }
}
  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================
