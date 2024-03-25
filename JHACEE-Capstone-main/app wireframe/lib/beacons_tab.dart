
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'beacon_detail_tab.dart';
import 'utils.dart';
import 'widgets.dart';

class BeaconsTab extends StatefulWidget {
  static const title = 'Beacons';
  static const androidIcon = Icon(Icons.bluetooth);
  static const iosIcon = Icon(CupertinoIcons.bluetooth);

  const BeaconsTab({super.key, this.androidDrawer});

  final Widget? androidDrawer;

  @override
  State<BeaconsTab> createState() => _BeaconsTabState();
}

class _BeaconsTabState extends State<BeaconsTab> {
  static const _itemsLength = 6;

  final _androidRefreshKey = GlobalKey<RefreshIndicatorState>();

  late List<MaterialColor> colors;
  late List<String> beaconNames;

  @override
  void initState() {
    _setData();
    super.initState();
  }

  void _setData() {
    colors = getRandomColors(_itemsLength);
    beaconNames = beaconNames = ['Beacon 1', 'Beacon 2', 'Beacon 3', 'Beacon 4', 'Beacon 5', 'Beacon 6'];

  }

  Future<void> _refreshData() {
    return Future.delayed(
      // This is just an arbitrary delay that simulates some network activity.
      const Duration(seconds: 2),
      () => setState(() => _setData()),
    );
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (index >= _itemsLength) return Container();

    // Show a slightly different color palette. Show poppy-ier colors on iOS
    // due to lighter contrasting bars and tone it down on Android.
    final color = defaultTargetPlatform == TargetPlatform.iOS
        ? colors[index]
        : colors[index].shade400;

    return SafeArea(
      top: false,
      bottom: false,
      child: Hero(
        tag: index,
        child: HeroAnimatingBeaconCard(
          beacon: beaconNames[index],
          color: color,
          heroAnimation: const AlwaysStoppedAnimation(0),
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) => BeaconsDetailTab(
                id: index,
                beacon: beaconNames[index],
                color: color,
              ),
            ),
          ),
        ),
      ),
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
        title: const Text(BeaconsTab.title),
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
      body: RefreshIndicator(
        key: _androidRefreshKey,
        onRefresh: _refreshData,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: _itemsLength,
          itemBuilder: _listBuilder,
        ),
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
        CupertinoSliverRefreshControl(
          onRefresh: _refreshData,
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