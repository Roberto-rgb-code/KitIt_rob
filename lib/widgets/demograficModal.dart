import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitit/service/MySQLConnection.dart';
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
  List demoGraficData;

  // DemograficModal(
  //     {super.key,
  //     required this.total,
  //     required this.hombres,
  //     required this.mujeres});

  DemograficModal(this.total, this.hombres, this.mujeres, this.demoGraficData,
      {Key? key})
      : super(key: key) {
    // getData();
  }

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
        width: size.width * 0.5,
        child: PageView(
          children: [
            womenAndMen(size, chartData),
            otherDemografic(size),
          ],
        ),
      ),
    );
  }

  womenAndMen(Size size, List<ChartData> chartData) {
    return SizedBox(
      height: size.height * 0.5,
      width: size.width * 0.5,
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
    );
  }

  otherDemografic(Size size) {
    print('ENTRANDO A OTRO DEMOGRAFICOOOOSOSOOSOS');
    Map listOfExpandible = {
      'MS': [],
      'SI': [],
      'SP': [],
      'GE': [],
      'MF': [],
      'EE': [],
      'P': [],
      'ARI': [],
      'ISE': [],
      'I': [],
      'T': [],
      'PO': [],
    };

    for (var element in demoGraficData) {
      if (element['categoria'] == 'MS') {
        listOfExpandible['MS'].add(element);
      }
      if (element['categoria'] == 'SI') {
        listOfExpandible['SI'].add(element);
      }
      if (element['categoria'] == 'SP') {
        listOfExpandible['SP'].add(element);
      }
      if (element['categoria'] == 'GE') {
        listOfExpandible['GE'].add(element);
      }
      if (element['categoria'] == 'MF') {
        listOfExpandible['MF'].add(element);
      }
      if (element['categoria'] == 'EE') {
        listOfExpandible['EE'].add(element);
      }
      if (element['categoria'] == 'P') {
        listOfExpandible['P'].add(element);
      }
      if (element['categoria'] == 'ARI') {
        listOfExpandible['ARI'].add(element);
      }
      if (element['categoria'] == 'ISE') {
        listOfExpandible['ISE'].add(element);
      }
      if (element['categoria'] == 'I') {
        listOfExpandible['I'].add(element);
      }
      if (element['categoria'] == 'T') {
        listOfExpandible['T'].add(element);
      }
      if (element['categoria'] == 'PO') {
        listOfExpandible['PO'].add(element);
      }
    }

    print(listOfExpandible);
    return SizedBox(
      height: size.height * 0.5,
      width: size.width * 0.5,
      child: SingleChildScrollView(
          child: Column(children: returnExpandibles(listOfExpandible, size))),
    );
  }

  List<Widget> returnExpandibles(Map listOfExpandible, Size size) {
    List<Widget> listWidgets = [];

    for (var categoria in listOfExpandible.keys) {
      String name = getCategoriString(categoria);
      List<Widget> explandible = [];
      print('Name: ${name}}');
      for (var element in listOfExpandible[categoria]) {
        explandible.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
            child: ExpansionTile(
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              collapsedTextColor: Colors.white,
              collapsedBackgroundColor: Colors.black,
              textColor: Colors.white,
              backgroundColor: Colors.black,
              title: Text(element['nombre']),
              children: [
                Text(
                  element['dato'] + ' ' + element['unidad'],
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        );
      }
      print(explandible);
      Widget w = Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
            width: size.width * 0.85,
            child: ExpansionTile(
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              collapsedTextColor: Colors.white,
              collapsedBackgroundColor: Colors.black,
              textColor: Colors.white,
              // color
              backgroundColor: Colors.black,
              title: Text(name),
              children: explandible,
            )),
      );
      listWidgets.add(w);
    }

    return listWidgets;
  }

  String getCategoriString(categoria) {
    if (categoria == 'MS') {
      return 'Manejo sustentable del medio ambiente';
    }
    if (categoria == 'SI') {
      return 'Sociedad incluyente';
    }
    if (categoria == 'SP') {
      return 'Sistema político';
    }
    if (categoria == 'GE') {
      return 'Gobierno eficiente';
    }
    if (categoria == 'MF') {
      return 'Mercado de factores';
    }
    if (categoria == 'EE') {
      return 'Economia estable';
    }
    if (categoria == 'P') {
      return 'Precursores';
    }
    if (categoria == 'ARI') {
      return 'Aprovechamiento de relaciones internacionales';
    }
    if (categoria == 'ISE') {
      return 'Innovacion de sectores economicos';
    }
    if (categoria == 'I') {
      return 'Inversion';
    }
    if (categoria == 'T') {
      return 'Talento';
    } else {
      return 'Población';
    }
  }
}
