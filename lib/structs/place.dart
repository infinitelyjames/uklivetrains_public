import 'package:uklivetrains/data/station_codes.dart';

class Place {
  final String name;
  final String crs;
  final String?
      via; // note: text supplied from API is literally "via Horsham" (includes the "via" text)
  String? stationDetailsURL;

  Place({required this.name, required this.crs, this.via});

  String getStationDetailsURL() {
    if (stationDetailsURL != null) return stationDetailsURL!;
    String newName = name.toLowerCase();
    newName = newName.replaceAll(" ", "-");
    newName = newName.replaceAll("(", "");
    newName = newName.replaceAll(")", "");
    stationDetailsURL =
        "https://www.nationalrail.co.uk/stations/$newName/"; // cache
    return stationDetailsURL!;
  }

  factory Place.fromAPIJson(Map<String, dynamic> json) {
    // Origin and destination use 'name', whereas calling points use 'locationName'
    return Place(
        name: json['locationName'] ?? json['name'],
        crs: json['crs'],
        via: json['via']);
  }

  factory Place.fromSerializableJSON(Map<String, dynamic> json) {
    return Place(name: json["name"], crs: json["crs"], via: json["via"]);
  }

  factory Place.fromCRS(String crs) {
    return Place(name: STATION_CODES_INVERTED[crs] ?? "??", crs: crs);
  }

  Map<String, String?> toSerializableJSON() {
    return {
      "name": name,
      "crs": crs,
      "via": via,
    };
  }
}
