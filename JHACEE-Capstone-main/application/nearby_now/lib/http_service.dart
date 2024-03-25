import "package:flutter/foundation.dart";
import "dart:async";
import "dart:convert";
import "package:http/http.dart";
import "product_factory.dart";
import "beacon_data.dart";

class HttpService {
  String databaseUrl;
  final String _dbscheme = "http";
  final int _dbport = 80;

  Product _productInfo = new Product();
  List<BeaconData> nearestBeacons = new List<BeaconData>.empty(growable: true);

  HttpService({
    @required this.databaseUrl = "127.0.0.1",
  });

  Future<Map<int, List<Product>>?> getProductAisleMap() async {
    print("requesting data from ${databaseUrl}:${_dbport}...");
    Response res;
    try {
      res = await get(Uri(
        scheme: _dbscheme,
        host: databaseUrl,
        port: _dbport,
        path: "/api/v0/beacon",
      )).timeout(Duration(seconds: 5));
    } on TimeoutException catch (e) {
      print("request timed out");
      return null;
    } on Exception catch (e) {
      print("connection could not be made");
      return null;
    }

    if (res.statusCode != 200) {
      print(
          "unable to fetch products from the database, responded with code ${res.statusCode}");
      return null;
    }

    Map<int, List<Product>> productAisleMap = Map();
    List<dynamic> body = jsonDecode(res.body);

    body.forEach((dynamic data) {
      _productInfo = Product.fromJson(data);

      if (productAisleMap[_productInfo.aisle] == null) {
        productAisleMap[_productInfo.aisle] =
            List<Product>.empty(growable: true);
      }
      productAisleMap[_productInfo.aisle]?.add(_productInfo);
    });

    return productAisleMap;
  }

  Future<Map<String, int>?> getBeaconAisleMap() async {
    Response res;
    try {
      res = await get(Uri(
        scheme: _dbscheme,
        host: databaseUrl,
        port: _dbport,
        path: "/api/v0/mapping",
      )).timeout(Duration(seconds: 5));
    } on TimeoutException catch (e) {
      print("request timed out");
      return null;
    } on Exception catch (e) {
      print("connection could not be made");
      return null;
    }

    if (res.statusCode != 200) {
      print(
          "unable to fetch mapping from the database, responded with code ${res.statusCode}");
      return null;
    }

    Map<String, int> beaconAisleMap = Map();
    List<dynamic> body = jsonDecode(res.body);

    body.forEach((data) {
      Map<String, dynamic> map = data as Map<String, dynamic>;
      String? beaconID = map["beacon_id"] as String;
      int? aisleNum = map["aisle_num"] as int;
      if (beaconID == null || aisleNum == null) return;
      print("associated aisle ${aisleNum} to beacon ${beaconID}");
      beaconAisleMap[beaconID] = aisleNum;
    });

    return beaconAisleMap;
  }

  List<Product> getNearestProducts(
      Map<String, List<Product>>? productAisleMap) {
    if (productAisleMap == null) {
      print("WARNING: no product info passed in");
      return [];
    }

    if (this.nearestBeacons == []) {
      print("WARNING: no nearby beacons");
      return getAllProducts(productAisleMap);
    }

    List<Product> nearProducts = List<Product>.empty(growable: true);
    this.nearestBeacons.forEach((BeaconData beacon) {
      String? beaconID = beacon.id;
      if (beaconID == null) return;
      print("${beaconID}");

      if (productAisleMap[beaconID] == null) return;

      productAisleMap[beaconID]?.forEach((Product p) {
        nearProducts.add(p);
      });
    });

    return nearProducts;
  }

  List<Product> getAllProducts(productAisleMap) {
    if (productAisleMap == null) {
      return [];
    }

    print("returning all products");
    List<Product> allProducts = List<Product>.empty(growable: true);
    productAisleMap.values.forEach((product) {
      allProducts.add(product);
    });

    return allProducts;
  }
}
