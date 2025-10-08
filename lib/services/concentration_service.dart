import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kitit/assets/colors_concentration.dart';
import 'package:kitit/models/concentration_result.dart';
import 'package:kitit/models/market_entry.dart';

class ConcentrationService {
  /// Normaliza nombres para agrupar firmas/marcas
  static String normalizeFirm(String raw) {
    var s = raw.toLowerCase().trim();
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    s = s.replaceAll(RegExp(r'[.,\-_/]'), ' ');
    s = s.replaceAll(RegExp(
        r'\b(s\.?a\.?|s\.? de r\.?l\.?|s\.?c\.?|\bsa\b|\bsrl\b|sociedad|an[oó]nima|de|la|el|y)\b'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  static ConcentrationResult compute({
    required List<MarketEntry> entries,
    required String activity,
    String? postalCode,
  }) {
    if (entries.isEmpty) {
      return ConcentrationResult(
        activity: activity,
        postalCode: postalCode,
        nFirms: 0,
        hhi: 0,
        cr4: 0,
        shares: const {},
        topFirms: const [],
        level: ConcentrationLevel.low,
        color: ConcentrationColors.low,
      );
    }

    // Conteo por firma
    final counts = <String, int>{};
    for (final e in entries) {
      counts[e.firm] = (counts[e.firm] ?? 0) + 1;
    }

    final total = entries.length;
    final shares = <String, double>{
      for (final kv in counts.entries) kv.key: kv.value / total
    };

    // HHI
    final hhi = shares.values.fold<double>(0, (acc, s) => acc + s * s) * 10000;

    // CR4
    final sorted = shares.values.toList()..sort((a, b) => b.compareTo(a));
    final cr4 = sorted.take(4).fold<double>(0, (a, b) => a + b);

    // Top 5 firmas
    final top = shares.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = top.take(math.min(5, top.length)).toList();

    final level = _levelForHHI(hhi);
    final color = _colorForLevel(level);

    return ConcentrationResult(
      activity: activity,
      postalCode: postalCode,
      nFirms: total,
      hhi: hhi,
      cr4: cr4,
      shares: shares,
      topFirms: top5,
      level: level,
      color: color,
    );
  }

  static ConcentrationLevel _levelForHHI(double hhi) {
    if (hhi < 1500) return ConcentrationLevel.low;
    if (hhi < 2500) return ConcentrationLevel.moderate;
    if (hhi < 5000) return ConcentrationLevel.high;
    return ConcentrationLevel.veryHigh;
  }

  static Color _colorForLevel(ConcentrationLevel level) {
    switch (level) {
      case ConcentrationLevel.low:      return ConcentrationColors.low;
      case ConcentrationLevel.moderate: return ConcentrationColors.moderate;
      case ConcentrationLevel.high:     return ConcentrationColors.high;
      case ConcentrationLevel.veryHigh: return ConcentrationColors.veryHigh;
    }
  }
}
