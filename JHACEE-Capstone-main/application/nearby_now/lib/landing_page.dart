import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: const <Widget>[
          LandingPageFindStore(),
          LandingPageOpenNearbyNow(),
          LandingPageBrowseProducts(),
        ],
      ),
    );
  }
}

class LandingPageFindStore extends StatelessWidget {
  const LandingPageFindStore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const LandingPageHeader(),
          Text(
            'Look for our logo at select stores',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          Image.asset('assets/images/find_store.png'),
        ],
      ),
    );
  }
}

class LandingPageOpenNearbyNow extends StatelessWidget {
  const LandingPageOpenNearbyNow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const LandingPageHeader(),
          Text(
            'Open Nearby Now',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          Image.asset('assets/images/open_nearby_now.png'),
        ],
      ),
    );
  }
}

class LandingPageBrowseProducts extends StatelessWidget {
  const LandingPageBrowseProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const LandingPageHeader(),
          Text(
            'Browse Products',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          Image.asset('assets/images/browse_products.png'),
        ],
      ),
    );
  }
}

class LandingPageHeader extends StatelessWidget {
  const LandingPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width,
      child: Image.asset('assets/images/nearby_now_logo.png'),
    );
  }
}
