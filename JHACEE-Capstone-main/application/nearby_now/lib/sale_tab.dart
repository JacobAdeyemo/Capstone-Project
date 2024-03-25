import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'widgets.dart';

class SaleTab extends StatefulWidget {
  static const title = 'Sale';
  static const androidIcon = Icon(Icons.money);
  static const iosIcon = Icon(CupertinoIcons.money_dollar_circle);

  const SaleTab({super.key});

  @override
  State<SaleTab> createState() => _SaleTabState();
}

class _SaleTabState extends State<SaleTab> {
  static const _itemsLength = 8;

  late final List<Color> colors;
  late final List<String> titles;
  late final List<String> contents;

  @override
  void initState() {
    colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.lime,
      Colors.pink,
      Colors.amber,
      Colors.teal
    ];
    titles = [
      'Item 1',
      'Item 2',
      'Item 3',
      'Item 4',
      'Item 5',
      'Item 6',
      'Item 7',
      'Item 8'
    ];
    contents = [
      'Description for item 1',
      'Description for item 2',
      'Description for item 3',
      'Description for item 4',
      'Description for item 5',
      'Description for item 5',
      'Description for item 6',
      'Description for item 7',
      'Description for item 8'
    ];

    super.initState();
  }

  Widget _listBuilder(BuildContext context, int index) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Card(
        elevation: 1.5,
        margin: const EdgeInsets.fromLTRB(6, 12, 6, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: InkWell(
          // Make it splash on Android. It would happen automatically if this
          // was a real card but this is just a demo. Skip the splash on iOS.
          onTap: defaultTargetPlatform == TargetPlatform.iOS ? null : () {},
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colors[index],
                  child: Text(
                    titles[index].substring(0, 1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titles[index],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 8)),
                      Text(
                        contents[index],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Non-shared code below because this tab uses different scaffolds.
  // ===========================================================================

  /*Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(SaleTab.title),
      ),
      body: ListView.builder(
        itemCount: _itemsLength,
        itemBuilder: _listBuilder,
      ),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(),
      child: ListView.builder(
        itemCount: _itemsLength,
        itemBuilder: _listBuilder,
      ),
    );
  } */

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(SaleTab.title),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 8 / 9,
        padding: const EdgeInsets.all(12),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: List.generate(
            _itemsLength, (index) => _listBuilder(context, index)),
      ),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 8 / 9,
        padding: const EdgeInsets.all(12),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: List.generate(
            _itemsLength, (index) => _listBuilder(context, index)),
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
