class BeaconData {
  String? name;
  int rssi = -100;
  String? id;
  String? advData;
  int? signalStrength;
  int timeout = 0;

  static int MAX_TIMEOUT = 2; // * 6 seconds to officially time out

  BeaconData(this.name, this.rssi, this.id, this.advData);

  // Sets a value for signal strength of 0,1,2. 0 being the weakest.
  // Might want to adjust the cutoffs.
  // Use signal strength for the visual connectivity output.
  // Make sure to call the function before trying to retrieve the signal strength ( beaconData[x].SS() ).

  SS() {
    if (rssi! <= -80)
      signalStrength = 0;
    else if (rssi! >= -55)
      signalStrength = 2;
    else
      signalStrength = 1;
  }
}
