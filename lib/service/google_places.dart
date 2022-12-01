import 'dart:convert';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../assets/colors.dart';

class GooglePlace {
  static Future get_places_all(String tipoLugar, latitud, longitud) async {
    List<Map> negocios = [];
    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=${tipoLugar}&location=${latitud}%2C${longitud}&radius=1500&key=AIzaSyBW-I02qm2e2fhlbJg1mtL7bKG5ItJPB5A&language=es-419'

        ));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
    
      try {
        for (var element in data["results"]) {
          negocios.add({
            'lat': element["geometry"]["location"]["lat"],
            'lon': element["geometry"]["location"]["lng"],
            'nombre': element["name"],
            'direccion': element["vicinity"]
          });
        }
      } catch (e) {
        print(e);
      }

      return negocios;

      // return data;
    } else {
      throw Exception('Failed to load post');
    }
  }

  static dynamic marker_window_places(id_marker, posicion, name,
      CustomInfoWindowController _customInfoWindowController) async {
    print("holaaaaaaaaaaaaaa");
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'lib/_img/marcador_google_places.png',
    );
    Marker marker = Marker(
      icon: icon,
      markerId: MarkerId(id_marker),
      position: posicion,
      zIndex: 2,
      anchor: const Offset(0.5, 1),
      onTap: () {
        _customInfoWindowController.addInfoWindow!(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: DesingColors.nuse,
              ),
              child: Column(
                children: [
                  Center(
                      child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  )),
                  const Divider(
                    color: Colors.white,
                    thickness: 2,
                  ),
                ],
              ),
            ),
            posicion);
      },
    );

    return marker;
  }
}
