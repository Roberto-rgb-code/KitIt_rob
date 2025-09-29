import 'dart:convert';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../assets/colors.dart';

/// Lee la API key desde --dart-define en tiempo de compilación.
/// Ejemplo:
/// flutter run -d emulator-5554 --dart-define=PLACES_API_KEY=TU_API_KEY
const String placesApiKey = String.fromEnvironment('PLACES_API_KEY');

class GooglePlace {
  static Future<List<Map<String, dynamic>>> get_places_all(
    String tipoLugar,
    double latitud,
    double longitud,
  ) async {
    final List<Map<String, dynamic>> negocios = [];

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?keyword=$tipoLugar'
      '&location=$latitud%2C$longitud'
      '&radius=1500'
      '&key=$placesApiKey'
      '&language=es-419',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      try {
        for (final element in data["results"]) {
          negocios.add({
            'lat': element["geometry"]["location"]["lat"],
            'lon': element["geometry"]["location"]["lng"],
            'nombre': element["name"],
            'direccion': element["vicinity"],
          });
        }
      } catch (e) {
        print("Error procesando resultados de Google Places: $e");
      }

      return negocios;
    } else {
      throw Exception('Error al cargar lugares: ${response.statusCode}');
    }
  }

  static Future<Marker> marker_window_places(
    String id_marker,
    LatLng posicion,
    String name,
    CustomInfoWindowController customInfoWindowController,
  ) async {
    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'lib/_img/marcador_google_places.png',
    );

    return Marker(
      icon: icon,
      markerId: MarkerId(id_marker),
      position: posicion,
      zIndex: 2,
      anchor: const Offset(0.5, 1),
      onTap: () {
        customInfoWindowController.addInfoWindow!(
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
                  ),
                ),
                const Divider(
                  color: Colors.white,
                  thickness: 2,
                ),
              ],
            ),
          ),
          posicion,
        );
      },
    );
  }
}
