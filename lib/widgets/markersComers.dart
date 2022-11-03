import 'dart:ui';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assets/ColorPolygon.dart';
import '../assets/colors.dart';
import '../service/MySQLConnection.dart';

class MarkersCom {
  Set<Marker> _markersComers = new Set();
  List data_markers = [];

  MarkersCom(List data_markers) {
    this.data_markers = data_markers;
  }
  

  Future<Set<Marker>> printMarkersComers(
    
      CustomInfoWindowController _customInfoWindowController, context) async {
        final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(
          
        ), 
        'lib/_img/dispv1.png'
      );
    List LonLat_markers = [];

    for (var i = 0; i < data_markers.length; i++) {
      String cord_aux = data_markers[i]["coordenadas"].replaceAll(" ", "");

      List cord_list = cord_aux.split(",");

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
        onTap: () {
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
                child: Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                          child:
                              row_(i, "Nombre: ", data_markers[i]["nombre"])),
                      FittedBox(
                        child: row_(
                            i, "Descripcion: ", data_markers[i]["descripcion"]),
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
                            icon_info("lib/_img/apertura-de-puerta-abierta.png",
                                data_markers[i]["num_cuartos"], "Cuartos"),
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
              );
            },
          );
        },
      );
      _markersComers.add(markerNew);
    }
    return _markersComers;
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
}
