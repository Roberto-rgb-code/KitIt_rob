import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assets/ColorPolygon.dart';
import '../assets/colors.dart';
import '../resourses/exceReader.dart';
import '../service/MySQLConnection.dart';
import '../service/datos_predios.dart';

class MarkersCom {
  Set<Marker> _markersComers = new Set();
  List data_markers = [];
  PageController pageController = PageController();
  String? _p;

  String? get p => _p;

  set p(String? p) {
    _p = p;
  }

  MarkersCom(List data_markers) {
    this.data_markers = data_markers;
  }

  Future<Set<Marker>> printMarkersComers(
      CustomInfoWindowController _customInfoWindowController,
      context,
      MediaQueryData deviceData) async {
    final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 'lib/_img/MARCADOR_PALOMA.png');
    List LonLat_markers = [];
    Size size = deviceData.size;
    for (var i = 0; i < data_markers.length; i++) {

      String cord_aux = data_markers[i]["coordenadas"].replaceAll(" ", "");

      List cord_list = cord_aux.split(",");
      // Map data = await onPressedHammerButton(cord_aux);
      Marker markerNew = Marker(
        markerId: MarkerId("${i}"),
        consumeTapEvents: true,
        icon: icon,
        position: LatLng(
          double.parse(cord_list[0]),
          double.parse(cord_list[1]),
        ),
        zIndex: 2,
        anchor: const Offset(0.5, 1),
        onTap: () async {
          List coordinates = cord_aux.split(',');

          double lat = double.parse(coordinates[0]);

          double lon = double.parse(coordinates[1]);

          final data = await onPressedHammerButton(lat, lon);

          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (BuildContext context) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                height: 400,
                child: PageView(
                  controller: pageController,
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                              child: row_(
                                  i, "Nombre: ", data_markers[i]["nombre"])),
                          FittedBox(
                            child: row_(i, "Descripcion: ",
                                data_markers[i]["descripcion"]),
                          ),
                          Container(
                            width: 400,
                            height: 250,
                            child: GridView.count(
                              primary: false,
                              padding: const EdgeInsets.only(
                                  top: 10, left: 15, right: 15),
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              crossAxisCount: 3,
                              children: <Widget>[
                                icon_info(
                                    "lib/_img/_bosquejo.png",
                                    data_markers[i]["superficie_m3"] + "m2",
                                    "Superficie"),
                                icon_info(
                                    "lib/_img/apertura-de-puerta-abierta.png",
                                    data_markers[i]["num_cuartos"],
                                    "Cuartos"),
                                icon_info("lib/_img/bano-publico.png",
                                    data_markers[i]["num_baños"], "Baños"),
                                icon_info("lib/_img/coche.png",
                                    data_markers[i]["num_cajones"], "Cajones"),
                              ],
                            ),
                          ),
                          FittedBox(
                            child: row_(i, "Informacion adicional: ",
                                data_markers[i]["extras"]),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Container(
                        padding:
                            const EdgeInsets.only(top: 15, left: 10, right: 10),
                        child: Column(
                          children: [
                            // PRIMERO  LA CLAVE Y EL MAPITA
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: firtsRow(data, LatLng(lat, lon)),
                            ),
                            // UBICACION Y ZONIFICACION
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              padding: const EdgeInsets.all(15),
                              width: size.width,
                              child: Column(
                                children: ubicationDescription(data),
                              ),
                            ),
                            //SUPERFICIE LEGAL
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Column(
                                children: surfaceLegal(data),
                              ),
                            ),
                            Container(
                              color: Colors.black,
                              height: 1,
                              width: size.width,
                            ),
                            //COMENZAMOS CON LOS PERMISOS
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Center(
                                child: Column(
                                  children: bothPermitions(data, size),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
      _markersComers.add(markerNew);
    }
    return _markersComers;
  }

  Future<Map> onPressedHammerButton(double lat, double lon) async {
    List<double> coordsUTM = await ExcelReader.modifyLatAndLon(lat, lon);

    final response = await data_predio_cordenada(coordsUTM);

    Map dataJson = response[0];

    Iterable keysData = dataJson.keys;

    return dataJson;
  }

  Row row_(int i, String nombreData, String tipoData) {
    return Row(
      children: [
        texto_(nombreData, 23, FontWeight.bold),
        texto_(tipoData, 20, FontWeight.w500),
      ],
    );
  }

  Text texto_(String dataInfo, double tamFont, FontWeight fontWeight) {
    Text data = Text(
      dataInfo,
      style: TextStyle(
        overflow: TextOverflow.ellipsis,
        fontWeight: fontWeight,
        fontSize: tamFont,
      ),
    );

    return data;
  }

  Widget icon_info(String urlImage, String data, String nombre) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: ColorPolygon.borderColor, width: 3)),
      child: Column(
        children: [
          Container(margin: EdgeInsets.only(bottom: 5), child: Text(nombre)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ImageIcon(
                size: 50,
                AssetImage(urlImage),
              ),
              Text(
                data,
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> firtsRow(Map data, LatLng cordinates) {
    CameraPosition _kGooglePlex = CameraPosition(
      target: cordinates,
      zoom: 11,
    );

    Set<Marker> markers = {
      Marker(markerId: const MarkerId('a'), position: cordinates)
    };
    return [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.black),
        child: Column(
          children: [
            // Text('Clave: $p'),
            Text(
              'Clave: ${data['clave']}',
              textAlign: TextAlign.start,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text('Tipo: ${data['tipo']}',
                textAlign: TextAlign.start,
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(2),
        height: 100,
        width: 100,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: GoogleMap(
          zoomControlsEnabled: false,
          initialCameraPosition: _kGooglePlex,
          markers: markers,
        ),
      )
    ];
  }

  List<Widget> ubicationDescription(Map data) {
    return [
      Text('Ubicación: ${data['colonia']}, ${data['ubicacion']}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.justify),
      const SizedBox(
        height: 6,
      ),
      Row(
        children: [
          Text('Zonificación: ${data['zonificacion']}',
              style: const TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    ];
  }

  List<Widget> surfaceLegal(Map data) {
    double a = data['cos'];

    return [
      Text('Superficie legal: ${data['superficieLegal']}m2',
          style: const TextStyle(color: Colors.white, fontSize: 18)),
      const SizedBox(
        height: 6,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text('Frente: ${data['frente']}',
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              Text('Cos: ${a.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          Column(
            children: [
              Text('Fondo: ${data['fondo']}',
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
              Text('Cus: ${data['cus'].toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ],
      ),
    ];
  }

  List<Widget> bothPermitions(Map data, Size size) {
    List<Widget> listaUsosPermitidos = [];
    List<Widget> listaUsosCondicionados = [];

    for (var element in data['zonificacion_default']['usos_permitidos']) {
      // listaUsosPermitidos.add(tipos_uso_nombre[element]);
      String? d = tipos_uso_nombre[element];
      listaUsosPermitidos.add(Padding(
        padding: const EdgeInsets.all(3.0),
        child: Text(
          d!,
          style: const TextStyle(color: Colors.white),
        ),
      ));
    }
    for (var element in data['zonificacion_default']['usos_condicionados']) {
      String? d = tipos_uso_nombre[element];
      listaUsosCondicionados
          .add(Text(d!, style: const TextStyle(color: Colors.white)));
    }

    return [
      SizedBox(
          width: size.width * 0.85,
          child: ExpansionTile(
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            collapsedTextColor: Colors.white,
            collapsedBackgroundColor: Colors.black,
            textColor: Colors.white,
            backgroundColor: Colors.black,
            title: const Text('Usos permitidos'),
            children: listaUsosPermitidos,
          )),
      const SizedBox(
        height: 15,
      ),
      SizedBox(
          width: size.width * 0.85,
          child: ExpansionTile(
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            collapsedTextColor: Colors.white,
            collapsedBackgroundColor: Colors.black,
            textColor: Colors.white,
            backgroundColor: Colors.black,
            title: const Text('Usos condicionados'),
            children: listaUsosCondicionados,
          )),
      const SizedBox(
        height: 15,
      ),
    ];
  }
}
