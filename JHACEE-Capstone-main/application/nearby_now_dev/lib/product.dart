import "package:flutter/foundation.dart";

class Product {
  // final String beaconID = "";
  // final String name = "";
  // final String id = "";
  // final Float price = -1.0;
  // final int aisle = -1;
  // final int stock = -1;

  String beaconID;
  String name;       
  String id;
  String imgurl;
  double price;
  double salePrice;
  int aisle;
  int stock;         

  Product({
      @required this.beaconID = "0:0:0:0:0:0",
      @required this.name = "",
      @required this.id = "",
      @required this.imgurl = "",
      @required this.price = -1.0,
      @required this.salePrice = 0.0,
      @required this.aisle = -1,
      @required this.stock = -1,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double salePrice = json["sale_price"] != 0 ? json["sale_price"] as double
                                          : json["sale_price"].toDouble();

    return Product(
        beaconID : json["beacon_id"] as String,
        name : json["name"] as String,
        id : json["id"] as String,
        imgurl : json["imgurl"] as String,
        price : json["price"] as double,
        salePrice : salePrice,
        aisle: json["aisle"] as int,
        stock: json["stock"] as int,
    );
  }
}
