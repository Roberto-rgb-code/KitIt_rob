// lib/services/cache_service.dart
import 'package:kitit/models/concentration_result.dart';

class CacheService {
  static final _mem = <String, ConcentrationResult>{};

  static String _key(String activity, String? postalCode) =>
      '${activity.toLowerCase().trim()}|${postalCode ?? 'none'}';

  static bool has(String activity, String? postalCode) =>
      _mem.containsKey(_key(activity, postalCode));

  static ConcentrationResult? get(String activity, String? postalCode) =>
      _mem[_key(activity, postalCode)];

  static void put(String activity, String? postalCode, ConcentrationResult v) =>
      _mem[_key(activity, postalCode)] = v;

  static void clear() => _mem.clear();
}
