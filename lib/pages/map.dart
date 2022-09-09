import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kitit/service/datos_predios.dart';

class Map1 extends StatefulWidget {
  Map1({Key? key}) : super(key: key);

  @override
  State<Map1> createState() => _Map1State();
}

class _Map1State extends State<Map1> {
  double size_word = 17;
  Completer<GoogleMapController> _controller = Completer();
  int contador = 0;

  late LatLng latlon1;

  final Map<MarkerId, Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();

  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarkerTap => _markersController.stream;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.6599162, -103.3450723),
    zoom: 11,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(20.6711593, -103.3557154),
      tilt: 59.440717697143555,
      zoom: 15);

  @override
  Widget build(BuildContext context) {
    var device_data = MediaQuery.of(context);

    GoogleMap mapa = GoogleMap(
      mapType: MapType.normal,
      onTap: onTap,
      markers: markers,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );

    return Scaffold(
      body: mapa,
      floatingActionButton: Container(
        padding: EdgeInsetsDirectional.only(start: 20),
        child: Row(
          children: [
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _markers.clear();
                  contador = 0;
                });
                print(_markers);
              },
              child: Icon(Icons.delete),
            ),
            const Divider(height: 50),
            FloatingActionButton(
              child: Icon(Icons.remove_red_eye),
              onPressed: () {
                // nombre1, nombre2 y numero
                data_predio("SANCHEZ", "PRISCILIANO", "595").then((value) {
                  //redondeo de cus
                  List<Widget> usos_permitidos_list = [];
                  List<Widget> usos_no_permitidos_list = [];
                  String inStringCus =
                      value[0]["cus"].toStringAsFixed(2); // '2.35'
                  double inDoubleCus = double.parse(inStringCus);

                  var usos_permitidos =
                      value[0]["zonificacion_default"]["usos_permitidos"];
                  var usos_no_permitidos =
                      value[0]["zonificacion_default"]["usos_condicionados"];

                  for (var tipo_uso in usos_permitidos) {
                    String? tipo_uso_string = tipos_uso_nombre[tipo_uso];
                    var texto = Container(
                      padding:
                          const EdgeInsetsDirectional.only(start: 10, top: 5),
                      height: 30,
                      width: device_data.size.width - 50,
                      color: const Color(0xff39B339),
                      child: Text(
                        "$tipo_uso - ${tipo_uso_string!}",
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                    );

                    usos_permitidos_list.add(texto);
                  }
                  for (var tipo_uso_no in usos_no_permitidos) {
                    String? tipo_uso_no_string = tipos_uso_nombre[tipo_uso_no];
                    var texto = Container(
                      padding: const EdgeInsetsDirectional.only(
                          start: 10, top: 5, bottom: 10),
                      height: 30,
                      width: device_data.size.width - 50,
                      color: const Color(0xff39B339),
                      child: Text(
                        tipo_uso_no + " - " + tipo_uso_no_string!,
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.left,
                      ),
                    );

                    usos_no_permitidos_list.add(texto);
                  }

                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        height: 600,
                        child: Center(
                          child: ListView(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsetsDirectional.only(
                                        bottom: 10, top: 10),
                                    child: const Text(
                                      "Datos del lugar",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ),
                                  info_total(
                                      "Clave Catastral: ${value[0]["clave"]}"),
                                  info_total("Tipo: ${value[0]["tipo"]}"),
                                  info_total(
                                      "Ubicacion:  ${value[0]["ubicacion"]}"),
                                  info_total("Colonia: ${value[0]["colonia"]}"),
                                  info_total(
                                      "Clave Catastral: ${value[0]["clave"]}"),
                                  info_total(
                                      "Superficie de Terreno: Escritura ${value[0]["superficieLegal"].toString()} m2"),
                                  info_total(
                                      "Superficie de Terreno: Cartografía ${value[0]["superficieCarto"].toStringAsFixed(2)} m2"),
                                  info_total(
                                      "Superficie Construida: ${value[0]["superficieConstruccion"].toString()} m2"),
                                  info_total(
                                      "Frente de Predio: ${value[0]["frente"].toString()} m"),
                                  info_total(
                                      "Zonificacion: ${value[0]["clave"].toString()}"),
                                  info_total(
                                      "COS: ${value[0]["cos"].toStringAsFixed(2)}"),
                                  info_total(
                                      "COS:  ${value[0]["zonificacion_default"]["cos"].toString()} 0"),
                                  info_total("CUS: ${inDoubleCus.toString()}"),
                                  info_total(
                                      "CUS permitido:  ${value[0]["zonificacion_default"]["cus_max"].toString()}"),
                                ],
                              ),
                              Divider(),
                              Container(
                                padding: const EdgeInsetsDirectional.only(
                                    bottom: 10),
                                child: const Text(
                                  'Usos Permitidos',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Column(
                                  children: usos_permitidos_list,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround),
                              const Divider(),
                              Container(
                                padding: const EdgeInsetsDirectional.only(
                                    bottom: 10),
                                child: const Text(
                                  'Usos Condicionados',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Column(children: usos_no_permitidos_list),
                              const Divider()
                            ],
                          ),
                        ),
                      );
                    },
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  void onTap(LatLng position) {
    if (contador == 0) {
      contador += 1;
      print(contador);
      setState(() {
        print(position);
        final id = _markers.length.toString();
        final markerId = MarkerId(id);

        final marker = Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          markerId: markerId,
          position: position,
          anchor: const Offset(0.5, 1),
          onTap: () {
            _markersController.sink.add(id);
            latlon1 = position;
          },
          draggable: true,
          onDragEnd: (newPosition) {
            //print("el marcador se puso en las longitudes $newPosition");
            print("latitud ");

            position = newPosition;

            print("POSI EN LA QUE PUSISTE EL MARCADOR WEY $position");
          },
        );

        _markers[markerId] = marker;
      });
    }
  }

  Widget info_total(data) {
    return Container(
      padding: const EdgeInsetsDirectional.only(bottom: 5),
      child: Text(
        data,
        style: TextStyle(fontSize: size_word),
      ),
    );
  }
}
