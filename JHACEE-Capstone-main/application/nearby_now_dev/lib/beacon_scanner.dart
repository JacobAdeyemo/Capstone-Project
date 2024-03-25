import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'beacon_data.dart';

class BeaconScanner {
  List<BeaconData> beaconData = [];
  List<String> idList = [];

  Future<List<BeaconData>> printDevices() async {
    // Start scanning
    await Permission.location.request();
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(
        timeout: Duration(milliseconds: 500), scanMode: ScanMode.balanced);

    // check if the beacon goes away
    for(BeaconData beacon in beaconData) {
      beacon.timeout++;

      if(beacon.timeout >= BeaconData.MAX_TIMEOUT) {
        beacon.rssi = -100;
      }
    }

    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        List beaconIds = [];
        int idIndex = 0;
        for (var m in beaconData) {
          beaconIds.add(m.id);
        }

        // Add beacon ids to idList in main as strings. Running it as is won't print any BeaconData.
        if (!idList.contains(r.device.id.id)) continue;

        if (!beaconIds.contains(r.device.id.id)) {
          beaconData.add(BeaconData(r.device.name, r.rssi, r.device.id.id,
              r.advertisementData.manufacturerData.toString()));
        } else {
          idIndex = beaconIds.indexOf(r.device.id.id);
          beaconData[idIndex].rssi = r.rssi;
          // ensure the beacon does not time out
          beaconData[idIndex].timeout = 0;
        }
      }
    });


    // print statement to view BeaconData in development
    for (BeaconData beacon in beaconData) {
      beacon.SS();
      print("${beacon.name} : ${beacon.id} : ${beacon.rssi} : ${beacon.signalStrength} : ${beacon.timeout}");
    }

    // Sorts Beacons based on signal strength (strongest signal to weakest)
    beaconData.sort((a, b) => (a.rssi > b.rssi
        ? -1
        : b.rssi > a.rssi
            ? 1
            : 0));

    // Stop scanning
    flutterBlue.stopScan();

    return beaconData;
  }
}
