import 'package:uklivetrains/structs/place.dart';

class PlaceList {
  final List<Place> placeList;
  final String name;
  final String? via;

  const PlaceList(this.placeList, this.name, this.via);

  static String generateMultiPlaceName(List<Place> places) {
    if (places.isEmpty) return "";
    if (places.length == 1) return places[0].name;
    String name = places[0].name;
    for (var i = 1; i < places.length; i++) {
      if (i == places.length - 1)
        name += " and " + places[i].name;
      else
        name += ", " + places[i].name;
    }
    return name;
  }

  static String? generateMultiViaName(List<Place> places) {
    // TODO: replace this if needed (no test case where proper functionality here is required)
    return places.isEmpty ? null : places[0].via;
  }

  factory PlaceList.fromNoName(List<Place> placeList) {
    return PlaceList(placeList, generateMultiPlaceName(placeList),
        generateMultiViaName(placeList));
  }

  factory PlaceList.fromJson(List<dynamic> json) {
    List<Place> placeList = (json).map((e) => Place.fromAPIJson(e)).toList();
    return PlaceList.fromNoName(placeList);
  }

  bool crsInPlaces(String crs) {
    for (Place place in placeList) {
      //print(place.crs + " : " + crs);
      if (place.crs == crs) return true;
    }
    return false;
  }
}
