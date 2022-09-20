import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kitit/resourses/exceReader.dart';
import 'package:kitit/service/datos_predios.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../widgets/drawer.dart';

class Map1 extends StatefulWidget {
  Map1({Key? key}) : super(key: key);

  @override
  State<Map1> createState() => _Map1State();
}

class _Map1State extends State<Map1> {
  final TextEditingController _textLugar = TextEditingController();
  double size_word = 17;
  Completer<GoogleMapController> _controller = Completer();
  int contador = 0;
  bool wasTaped = false;
  LatLng? postionOnTap;

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

  ValueNotifier<String> direccion = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    // final TextEditingController textLugar = TextEditingController();

    String? address;

    var device_data = MediaQuery.of(context);

    Completer<GoogleMapController> _controller = Completer();

    void moveCamera(double lat, double long) async {
      print('Entro a move camera');
      // double lat = 20.7016358;
      // double long = -103.3867676;

      final GoogleMapController controller = await _controller.future;

      LatLng latLngPosition = LatLng(lat, long);

      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLngPosition,
            zoom: 20,
          ),
        ),
      );

      setState(() {
        final id = _markers.length.toString();
        final markerId = MarkerId(id);

        final marker = Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          markerId: markerId,
          position: latLngPosition,
          anchor: const Offset(0.5, 1),
          onTap: () {
            _markersController.sink.add(id);
            latlon1 = latLngPosition;
          },
          // draggable: true,
          // onDragEnd: (newPosition) {
          //   //print("el marcador se puso en las longitudes $newPosition");
          //   print("latitud ");

          //   position = newPosition;

          //   print("POSI EN LA QUE PUSISTE EL MARCADOR WEY $position");
          // },
        );

        _markers[markerId] = marker;
      });
    }

    GoogleMap mapa = GoogleMap(
      mapType: MapType.normal,
      // zoomControlsEnabled: false,
      onTap: onTap,
      markers: markers,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );

    getLocation() async {
      List<Location> locations =
          await locationFromAddress("${_textLugar.text}, Guadalajara, Jal.");

      // await locationFromAddress("Jesus garcia 3020, Guadalajara, Jal.");

      return locations;
    }

    return Scaffold(
      drawer: const DrawerWidget(),
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: device_data.size.width,
                  height: device_data.size.height,
                  child: mapa,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 7),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                margin: const EdgeInsets.only(top: 70, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: device_data.size.width * 0.7,
                      child: TextField(
                        controller: _textLugar,
                        onChanged: (value) {
                          direccion.value = value;
                          print(direccion.value);
                        },
                        decoration: const InputDecoration(
                            labelText: "Ingrese su direccion",
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    style: BorderStyle.none, width: 0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)))),
                      ),
                    ),

                    ElevatedButton(
                        onPressed: () async {
                          // print('ENTRE AL ZOOM');

                          print('Direccion: ');
                          print(direccion.value);

                          final locations = await getLocation();

                          // double lat = locations[0].latitude;
                          // double long = locations[0].longitude;

                          // print('Entro a move camera');
                          // double lat = 20.7016358;
                          // double long = -103.3867676;

                          // final GoogleMapController controller =
                          //     await _controller.future;

                          LatLng latLngPosition = LatLng(
                              locations[0].latitude, locations[0].longitude);

                          // controller.animateCamera(
                          //   CameraUpdate.newCameraPosition(
                          //     CameraPosition(
                          //       target: latLngPosition,
                          //       zoom: 20,
                          //     ),
                          //   ),
                          // );

                          setState(() {
                            if (contador == 0) {
                              contador += 1;

                              final id = _markers.length.toString();
                              final markerId = MarkerId(id);

                              final marker = Marker(
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueAzure),
                                markerId: markerId,
                                position: latLngPosition,
                                anchor: const Offset(0.5, 1),
                                onTap: () {
                                  _markersController.sink.add(id);
                                  latlon1 = latLngPosition;
                                },
                                // draggable: true,
                                // onDragEnd: (newPosition) {
                                //   //print("el marcador se puso en las longitudes $newPosition");
                                //   print("latitud ");

                                //   position = newPosition;

                                //   print("POSI EN LA QUE PUSISTE EL MARCADOR WEY $position");
                                // },
                              );

                              _markers[markerId] = marker;
                            }

                            // });
                          });
                        },
                        child: const Icon(Icons.search))

                    // IconButton(
                    //     color: Colors.black,
                    //     onPressed: searchAddres(textLugar.text),
                    //     // onPressed: () {
                    //     //   print('aAAAAAAAAa');
                    //     // },
                    //     icon: const Icon(Icons.search))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Column(children: [

      //   Center(child: Container(width: device_data.size.width,height: device_data.size.height-100,child: mapa,),)
      // ],),
      floatingActionButton: Container(
        padding: const EdgeInsetsDirectional.only(start: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              onPressed: () {
                // final GoogleMapController controller = await _controller.future;

                // LatLng latLngPosition = const LatLng(20.6711593, -103.3557154);

                // controller.animateCamera(
                //   CameraUpdate.newCameraPosition(
                //     CameraPosition(
                //       target: latLngPosition,
                //       zoom: 11.54,
                //     ),
                //   ),
                // );

                // print('Comienza la funcion: ');

                _textLugar.clear();

                setState(() {
                  wasTaped = false;
                  _markers.clear();
                  contador = 0;
                });
              },
              child: const Icon(Icons.delete),
            ),
            const Divider(height: 50),
            Builder(
              builder: (context) {
                if (contador == 0) {
                  return const FloatingActionButton(
                    onPressed: null,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.remove_red_eye),
                  );
                } else {
                  return FloatingActionButton(
                    child: const Icon(Icons.remove_red_eye),
                    onPressed: () async {
                      if (wasTaped) {
                        
                        print('Posicion colocada:::::::::::::::::::: ');
                        print(postionOnTap!.latitude);
                        print(postionOnTap!.longitude);

                        List<double> coordsUTM =
                            await ExcelReader.modifyLatAndLon(
                                postionOnTap!.latitude,
                                postionOnTap!.longitude);

                        print('CORDENADAS UTM AAAAAAAAAAAAAAAAAAA');
                        print(coordsUTM);

                        data_predio_cordenada(coordsUTM).then(
                          (value) {
                            if (value.length == 0) {
                              //redondeo de cus
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    height: 600,
                                    child: Center(
                                      child: ListView(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                            .only(
                                                        bottom: 10, top: 10),
                                                child: const Text(
                                                  "No se encontraron datos",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              List<Widget> usos_permitidos_list = [];
                              List<Widget> usos_no_permitidos_list = [];
                              String inStringCus =
                                  value[0]["cus"].toStringAsFixed(2); // '2.35'
                              double inDoubleCus = double.parse(inStringCus);

                              var usos_permitidos = value[0]
                                  ["zonificacion_default"]["usos_permitidos"];
                              var usos_no_permitidos = value[0]
                                      ["zonificacion_default"]
                                  ["usos_condicionados"];

                              for (var tipo_uso in usos_permitidos) {
                                String? tipo_uso_string =
                                    tipos_uso_nombre[tipo_uso];
                                var texto = Container(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 10, top: 5),
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
                                String? tipo_uso_no_string =
                                    tipos_uso_nombre[tipo_uso_no];
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    height: 600,
                                    child: Center(
                                      child: ListView(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                            .only(
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
                                              info_total(
                                                  "Tipo: ${value[0]["tipo"]}"),
                                              info_total(
                                                  "Ubicacion:  ${value[0]["ubicacion"]}"),
                                              info_total(
                                                  "Colonia: ${value[0]["colonia"]}"),
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
                                              info_total(
                                                  "CUS: ${inDoubleCus.toString()}"),
                                              info_total(
                                                  "CUS permitido:  ${value[0]["zonificacion_default"]["cus_max"].toString()}"),
                                            ],
                                          ),
                                          Divider(),
                                          Container(
                                            padding: const EdgeInsetsDirectional
                                                .only(bottom: 10),
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
                                                  MainAxisAlignment
                                                      .spaceAround),
                                          const Divider(),
                                          Container(
                                            padding: const EdgeInsetsDirectional
                                                .only(bottom: 10),
                                            child: const Text(
                                              'Usos Condicionados',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Column(
                                              children:
                                                  usos_no_permitidos_list),
                                          const Divider()
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        );
                      } else {
                        // ENTONCES HARAS LA BUSQUEDA POR NOMBRE

                        // FocusScope.of(context).requestFocus(new FocusNode());
                        // nombre1, nombre2 y numero
                        var minusculas = _textLugar.text.toUpperCase();
                        var texto_split = minusculas.split(" ");
                        // GARCIA JESUS 3020

                        var numero = texto_split.last;
                        texto_split.removeLast();

                        var nombre = texto_split.join(" ");

                        data_predio(nombre, numero).then(
                          (value) {
                            if (value.length == 0) {
                              //redondeo de cus
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    height: 600,
                                    child: Center(
                                      child: ListView(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                            .only(
                                                        bottom: 10, top: 10),
                                                child: const Text(
                                                  "No se encontraron datos",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              List<Widget> usos_permitidos_list = [];
                              List<Widget> usos_no_permitidos_list = [];
                              String inStringCus =
                                  value[0]["cus"].toStringAsFixed(2); // '2.35'
                              double inDoubleCus = double.parse(inStringCus);

                              var usos_permitidos = value[0]
                                  ["zonificacion_default"]["usos_permitidos"];
                              var usos_no_permitidos = value[0]
                                      ["zonificacion_default"]
                                  ["usos_condicionados"];

                              for (var tipo_uso in usos_permitidos) {
                                String? tipo_uso_string =
                                    tipos_uso_nombre[tipo_uso];
                                var texto = Container(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 10, top: 5),
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
                                String? tipo_uso_no_string =
                                    tipos_uso_nombre[tipo_uso_no];
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    height: 600,
                                    child: Center(
                                      child: ListView(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                            .only(
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
                                              info_total(
                                                  "Tipo: ${value[0]["tipo"]}"),
                                              info_total(
                                                  "Ubicacion:  ${value[0]["ubicacion"]}"),
                                              info_total(
                                                  "Colonia: ${value[0]["colonia"]}"),
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
                                              info_total(
                                                  "CUS: ${inDoubleCus.toString()}"),
                                              info_total(
                                                  "CUS permitido:  ${value[0]["zonificacion_default"]["cus_max"].toString()}"),
                                            ],
                                          ),
                                          Divider(),
                                          Container(
                                            padding: const EdgeInsetsDirectional
                                                .only(bottom: 10),
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
                                                  MainAxisAlignment
                                                      .spaceAround),
                                          const Divider(),
                                          Container(
                                            padding: const EdgeInsetsDirectional
                                                .only(bottom: 10),
                                            child: const Text(
                                              'Usos Condicionados',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Column(
                                              children:
                                                  usos_no_permitidos_list),
                                          const Divider()
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        );
                      }
                    },
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  void onTap(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (contador == 0) {
      contador += 1;
      print(contador);
      setState(() {
        postionOnTap = position;
        wasTaped = true;
        // _textLugar.text = transformAddress(placemarks[0].street!);

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
