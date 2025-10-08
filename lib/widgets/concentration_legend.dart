import 'package:flutter/material.dart';
import 'package:kitit/assets/colors_concentration.dart';

class ConcentrationLegend extends StatelessWidget {
  const ConcentrationLegend({super.key});

  Widget _item(Color c, String label) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Concentración (HHI)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _item(ConcentrationColors.low, 'HHI < 1500 (Baja)'),
            const SizedBox(height: 4),
            _item(ConcentrationColors.moderate, '1500–2500 (Moderada)'),
            const SizedBox(height: 4),
            _item(ConcentrationColors.high, '2500–5000 (Alta)'),
            const SizedBox(height: 4),
            _item(ConcentrationColors.veryHigh, '> 5000 (Muy alta)'),
          ],
        ),
      ),
    );
  }
}
