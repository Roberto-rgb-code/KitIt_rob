import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarketEntry {
  final String name;          // Nombre original (DENUE)
  final String firm;          // Nombre normalizado para agrupar
  final String activity;      // Actividad (SCIAN / texto)
  final String? postalCode;   // CP (si lo tienes al calcular)
  final LatLng position;      // Coordenadas

  MarketEntry({
    required this.name,
    required this.firm,
    required this.activity,
    required this.position,
    this.postalCode,
  });
}
