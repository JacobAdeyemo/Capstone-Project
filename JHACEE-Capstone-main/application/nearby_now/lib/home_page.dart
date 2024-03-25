import "dart:async";

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'aisle_detail_tab.dart';
import 'aisles_tab.dart';
import "beacon_scanner.dart";
import "product_factory.dart";
import 'sale_tab.dart';

import 'widgets.dart';

class PlatformAdaptingHomePage extends StatefulWidget {
  final Map<String, int>? beaconAisleMap;
  final Map<int, List<Product>>? productAisleMap;
  final int firstAisle;

  const PlatformAdaptingHomePage({
    required this.beaconAisleMap,
    required this.productAisleMap,
    required this.firstAisle,
    Key? key,
  }) : super(key: key);

  @override
  State<PlatformAdaptingHomePage> createState() =>
      _PlatformAdaptingHomePageState();
}

class _PlatformAdaptingHomePageState extends State<PlatformAdaptingHomePage> {
  late int currentAisle;
  late List<Product> currentProducts;
  late int nearestAisle;
  // This app keeps a global key for the beacons tab because it owns a bunch of
  // data. Since changing platform re-parents those tabs into different
  // scaffolds, keeping a global key to it lets this app keep that tab's data as
  // the platform toggles.
  //
  // This isn't needed for apps that doesn't toggle platforms while running.
  final beaconsTabKey = GlobalKey();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    currentAisle = widget.firstAisle;
    currentProducts = widget.productAisleMap?[currentAisle] ?? [];
    Future.delayed(
      const Duration(seconds: 2),
      _buildAisleDetailTab,
    );
  }

  Future<void> _buildAisleDetailTab() async {
    // This function should receive the wanted Aisle or ID and build the Aisle Tab.
    // This function should be called by Aisle Tab when an Aisle has been selected
    // from the Aisle Tab page.
    // This function should be called when The floating button has been pressed.
    // This function should be called the first time this home page is accessed.
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AislesDetailTab(
            aisle: "Aisle $currentAisle",
            beaconAisleMap: widget.beaconAisleMap,
            productAisleMap: widget.productAisleMap,
            products: currentProducts),
      ),
    );
  }

  Widget _buildAndroidHomePage(BuildContext context) {
    return AislesTab(
      key: beaconsTabKey,
      beaconAisleMap: widget.beaconAisleMap,
      productAisleMap: widget.productAisleMap,
      androidDrawer: _AndroidDrawer(),
    );
  }

  // On iOS, the app uses a bottom tab paradigm. Here, each tab view sits inside
  // a tab in the tab scaffold. The tab scaffold also positions the tab bar
  // in a row at the bottom.
  //
  // An important thing to note is that while a Material Drawer can display a
  // large number of items, a tab bar cannot. To illustrate one way of adjusting
  // for this, the app folds its fourth tab (the settings page) into the
  // third tab. This is a common pattern on iOS.
  Widget _buildIosHomePage(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            label: AislesTab.title,
            icon: AislesTab.iosIcon,
          ),
          BottomNavigationBarItem(
            label: SaleTab.title,
            icon: SaleTab.iosIcon,
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              defaultTitle: AislesTab.title,
              builder: (context) => AislesTab(
                key: beaconsTabKey,
                beaconAisleMap: widget.beaconAisleMap,
                productAisleMap: widget.productAisleMap,
              ),
            );
          case 1:
            return CupertinoTabView(
              defaultTitle: SaleTab.title,
              builder: (context) => const SaleTab(),
            );
          default:
            assert(false, 'Unexpected tab');
            return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroidHomePage,
      iosBuilder: _buildIosHomePage,
    );
  }
}

class _AndroidDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.account_circle,
                color: Colors.green.shade800,
                size: 96,
              ),
            ),
          ),
          ListTile(
            leading: AislesTab.androidIcon,
            title: const Text(AislesTab.title),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: SaleTab.androidIcon,
            title: const Text(SaleTab.title),
            onTap: () {
              Navigator.pop(context);
              Navigator.push<void>(context,
                  MaterialPageRoute(builder: (context) => const SaleTab()));
            },
          ),
        ],
      ),
    );
  }
}
