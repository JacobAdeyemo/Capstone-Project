import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'dart:convert';

import 'aisle_detail_tab.dart';
import "product_factory.dart";

import 'widgets.dart';

class AislesTab extends StatefulWidget {
  final Widget? androidDrawer;
  static const androidIcon = Icon(Icons.shopping_basket);
  final Map<String, int>? beaconAisleMap;
  static const iosIcon = Icon(CupertinoIcons.square_grid_2x2_fill);
  final Map<int, List<Product>>? productAisleMap;
  static const title = 'Aisles';

  const AislesTab({
    this.androidDrawer,
    required this.beaconAisleMap,
    required this.productAisleMap,
    Key? key,
  }) : super(key: key);

  @override
  State<AislesTab> createState() => _AislesTabState();
}

class _AislesTabState extends State<AislesTab> {
  static const _itemsLength = 6;

  final _androidRefreshKey = GlobalKey<RefreshIndicatorState>();

  late List<String> aisleNames;

  @override
  void initState() {
    super.initState();
    _setData();
  }

  void _setData() {
    aisleNames = [
      'Aisle 1',
      'Aisle 2',
      'Aisle 3',
      'Aisle 4',
      'Aisle 5',
      'Aisle 6'
    ];
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (index >= _itemsLength) return Container();

// Load the image asset
  final AssetImage image = AssetImage('assets/images/${aisleNames[index]}.jpg');

    // Show a slightly different color palette. Show poppy-ier colors on iOS
    // due to lighter contrasting bars and tone it down on Android.
    // final color = defaultTargetPlatform == TargetPlatform.iOS
    //     ? colors[index]
    //     : colors[index].shade400;
    const color = Colors.transparent;

    return SafeArea(
      top: false,
      bottom: false,
      child:Stack(
      children: [
        // Add the image as the background of the card
        Positioned.fill(child: Image(image: image, fit: BoxFit.cover)), 
        Hero(
        tag: index,
        child: HeroAnimatingBeaconCard(
          beacon: aisleNames[index],
          color: Colors.transparent,
          heroAnimation: const AlwaysStoppedAnimation(0),
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) => AislesDetailTab(
                aisle: aisleNames[index],
                beaconAisleMap: widget.beaconAisleMap,
                productAisleMap: widget.productAisleMap,
                products: widget.productAisleMap![index + 1],
          ),
         ),
        ),
       ),
      ),
     ],
    )
   );
  }

  void _togglePlatform() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
    } else {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    }

    // This rebuilds the application. This should obviously never be
    // done in a real app but it's done here since this app
    // unrealistically toggles the current platform for demonstration
    // purposes.
    WidgetsBinding.instance.reassembleApplication();
  }

  // ===========================================================================
  // Non-shared code below because:
  // - Android and iOS have different scaffolds
  // - There are different items in the app bar / nav bar
  // - Android has a hamburger drawer, iOS has bottom tabs
  // - The iOS nav bar is scrollable, Android is not
  // - Pull-to-refresh works differently, and Android has a button to trigger it too
  //
  // And these are all design time choices that doesn't have a single 'right'
  // answer.
  // ===========================================================================
  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AislesTab.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async =>
                await _androidRefreshKey.currentState!.show(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _togglePlatform,
          ),
        ],
      ),
      drawer: widget.androidDrawer,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _itemsLength,
        itemBuilder: _listBuilder,
      ),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CupertinoSliverNavigationBar(
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _togglePlatform,
            child: const Icon(CupertinoIcons.search),
          ),
        ),
        SliverSafeArea(
          top: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                _listBuilder,
                childCount: _itemsLength,
              ),
            ),
          ),
        ),
      ],
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
