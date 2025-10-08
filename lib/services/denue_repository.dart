import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kitit/models/market_entry.dart';
import 'package:kitit/services/concentration_service.dart';
import 'package:kitit/service/DENUE_data.dart' as denue_api;

/// Convierte la respuesta de DENUE en MarketEntry “limpios”
class DenueRepository {
  static Future<List<MarketEntry>> fetchEntries({
    required String activity,
    required double lat,
    required double lon,
    String? postalCode,
  }) async {
    final raw = await denue_api.datosDenue.fetchPost(activity, '$lat', '$lon');
    final out = <MarketEntry>[];

    for (final m in raw) {
      final name = (m['nombre'] ?? '').toString();
      if (name.isEmpty) continue;

      final firm = ConcentrationService.normalizeFirm(name);

      final latVal = (m['lat'] is num)
          ? (m['lat'] as num).toDouble()
          : double.tryParse('${m['lat']}');
      final lonVal = (m['lon'] is num)
          ? (m['lon'] as num).toDouble()
          : double.tryParse('${m['lon']}');

      if (latVal == null || lonVal == null) continue;

      out.add(MarketEntry(
        name: name,
        firm: firm,
        activity: activity,
        postalCode: postalCode,
        position: LatLng(latVal, lonVal),
      ));
    }

    return out;
  }
}
