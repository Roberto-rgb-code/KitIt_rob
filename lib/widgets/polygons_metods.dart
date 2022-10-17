import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kitit/widgets/widow_map.dart';

import '../assets/ColorPolygon.dart';

class polygonsMetods {
  List<LatLng> geometry_data(List data) {
    var data_geometry = data;
    List<LatLng> polygonCoords = [];

    var new_list = data[0].replaceAll(" ", "").split(",");

    while (new_list.isNotEmpty) {
      var lat = double.parse(new_list.removeLast());
      var lon = double.parse(new_list.removeLast());
      polygonCoords.add(LatLng(lat, lon));
    }

    return polygonCoords;
  }
}
