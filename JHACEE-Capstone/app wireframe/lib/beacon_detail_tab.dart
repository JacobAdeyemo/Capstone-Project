import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'sale_tab.dart';
import 'widgets.dart';

/// Page shown when a card in the beacons tab is tapped.
///
/// On Android, this page sits at the top of your app. On iOS, this page is on
/// top of the beacons tab's content but is below the tab bar itself.


class BeaconsDetailTab extends StatelessWidget {
  const BeaconsDetailTab({
    required this.id,
    required this.beacon,
    required this.color,
    super.key,
  });

  final int id;
  final String beacon;
  final Color color;


  Widget _buildBody() {

    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: id,
            child: HeroAnimatingBeaconCard(
              beacon: beacon,
              color: color,
              heroAnimation: const AlwaysStoppedAnimation(1),
            ),
            // This app uses a flightShuttleBuilder to specify the exact widget
            // to build while the hero transition is mid-flight.
            //
            // It could either be specified here or in BeaconsTab.
            flightShuttleBuilder: (context, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              return HeroAnimatingBeaconCard(
                beacon: beacon,
                color: color,
                heroAnimation: animation,
              );
            },
          ),
          const Divider(
            height: 0,
            color: Colors.grey,
          ),
          Expanded(
          child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 2/3,
          padding: EdgeInsets.all(8),
          children: List.generate(10, (index) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: Center(child: Text("Item $index")),
          );
        }),
      ),
    ),

        ],
      ),
    );
  }

  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(beacon)),
      body: _buildBody(),
    );
  }


  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(beacon),
        previousPageTitle: 'Beacons',
        trailing: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SaleTab(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Text("Sale!!!"),
          ),
        ),
      ),
      child: _buildBody(),
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