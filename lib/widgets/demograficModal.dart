import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  String name;
  int value;
  Color color;
  ChartData({required this.name, required this.value, required this.color});
}

class DemograficModal extends StatelessWidget {
  int total;
  int hombres;
  int mujeres;

  DemograficModal(
      {super.key,
      required this.total,
      required this.hombres,
      required this.mujeres});

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData(name: 'Hombres', value: hombres, color: Colors.blue),
      ChartData(name: 'Mujeres', value: mujeres, color: Colors.red.shade400),
    ];

    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      title: const Center(child: Text('Datos Demograficos')),
      content: SizedBox(
        height: size.height * 0.35,
        child: Column(
          children: [
            const Text('Total de habitantes en la zona: '),
            Text(
              total.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: size.width * 0.8,
              height: size.height * 0.3,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                series: [
                  DoughnutSeries<ChartData, String>(
                    dataSource: chartData,
                    pointColorMapper: (ChartData data, _) => data.color,
                    xValueMapper: (ChartData data, _) => data.name,
                    yValueMapper: (ChartData data, _) => data.value,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
