import 'package:flutter/material.dart';

enum ConcentrationLevel { low, moderate, high, veryHigh }

class ConcentrationResult {
  final String activity;
  final String? postalCode;
  final int nFirms;                     // número de establecimientos
  final double hhi;                     // 0–10000
  final double cr4;                     // 0–1
  final Map<String, double> shares;     // firma -> share
  final List<MapEntry<String, double>> topFirms;
  final ConcentrationLevel level;
  final Color color;

  ConcentrationResult({
    required this.activity,
    required this.nFirms,
    required this.hhi,
    required this.cr4,
    required this.shares,
    required this.topFirms,
    required this.level,
    required this.color,
    this.postalCode,
  });
}

