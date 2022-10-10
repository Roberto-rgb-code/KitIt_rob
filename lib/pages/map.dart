import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kitit/assets/colors.dart';
import 'package:kitit/resourses/exceReader.dart';
import 'package:kitit/service/MySQLConnection.dart';
import 'package:kitit/service/datos_predios.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:kitit/widgets/modal_window.dart';

class Map1 extends StatefulWidget {
  Map1({Key? key}) : super(key: key);

  @override
  State<Map1> createState() => _Map1State();
}

class _Map1State extends State<Map1> {
  // Set<Polygon> _polygonSet = Set<Polygon>();
  Set<Polygon> _polygonSet = new Set();
  Set<Polygon> _polygonSetDisable = new Set();

  List lista_geometry = [];

  @override
  final TextEditingController _textLugar = TextEditingController();

  Completer<GoogleMapController> _controller = Completer();
  int contador = 0;
  LatLng? postionOnTap;
  double size_word = 17;
  late LatLng latlon1;
  bool hammerIsTaped = false;
  bool hasPaintedAZone = false;
  // bool disableOnTapPolygon = ;

  final Map<MarkerId, Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();

  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarkerTap => _markersController.stream;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.6599162, -103.3450723),
    zoom: 11,
  );

  ValueNotifier<String> direccion = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    // _textLugar.text = "Jesus Garcia 3020";
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
        );

        _markers[markerId] = marker;
      });
    }

    Set<Polygon> myPolygon(
      List lista_geometry,
    ) {
      print("lista que viene de DB -----------------------------");
      print(lista_geometry[1].length);
      int conta = 0;
      var aux;

      List hola = [];

      for (var i = 0; i < lista_geometry[1].length; i++) {
        // print("lista en for each ------------------------");
        // print(lista);
        List<LatLng> polygonCoords = geometry_data(lista_geometry[1][i]);
        hola.add(conta);
        Polygon po = Polygon(
            polygonId: PolygonId('test $conta'),
            points: polygonCoords,
            consumeTapEvents: true,
            zIndex: -1,
            strokeColor: Colors.red.shade600,
            strokeWidth: 5,
            fillColor: Colors.red.shade100,
            onTap: () {
              print('Hola menso ${lista_geometry[2][i]}');
            });

        Polygon po2 = Polygon(
            polygonId: PolygonId('test $conta'),
            points: polygonCoords,
            consumeTapEvents: false,
            zIndex: -1,
            strokeColor: Colors.red.shade600,
            strokeWidth: 5,
            fillColor: Colors.red.shade100,
            onTap: () {
              print('Hola menso ${lista_geometry[2][i]}');
            });
        _polygonSetDisable.add(po2);
        _polygonSet.add(po);

        conta = conta + 1;
      }

      return _polygonSet;
    }

    GoogleMap mapa = GoogleMap(
      mapType: MapType.normal,
      zoomControlsEnabled: false,
      polygons: hammerIsTaped == true ? _polygonSetDisable :_polygonSet,
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
      body: Center(
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
                          hoverColor: Colors.black,
                          labelText: "Ingrese su direccion",
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(style: BorderStyle.none, width: 0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)))),
                    ),
                  ),
                  ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(primary: DesingColors.dark),
                      onPressed: () async {
                        // print('ENTRE AL ZOOM');

                        if (_textLugar.text == '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Escribe o selecciona una zona por favor')));
                        } else {
                          print('Direccion: ');
                          print(direccion.value);

                          final locations = await getLocation();

                          LatLng latLngPosition = LatLng(
                              locations[0].latitude, locations[0].longitude);

                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                  latLngPosition.latitude,
                                  latLngPosition.longitude);
                          //placemarks[0].postalCode
                          final resultados = await MySQLConnector.getData(
                              placemarks[0].postalCode);

                          setState(() {
                            print('PINTAR LA ZONA_______________');

                            hasPaintedAZone = true;

                            myPolygon(resultados);

                            postionOnTap = latLngPosition;

                            // if (contador == 0) {
                            //   contador += 1;

                            //   final id = _markers.length.toString();
                            //   final markerId = MarkerId(id);

                            //   final marker = Marker(
                            //     icon: BitmapDescriptor.defaultMarkerWithHue(
                            //         BitmapDescriptor.hueAzure),
                            //     markerId: markerId,
                            //     position: latLngPosition,
                            //     anchor: const Offset(0.5, 1),
                            //     onTap: () {
                            //       _markersController.sink.add(id);
                            //       latlon1 = latLngPosition;
                            //     },
                            //   );

                            //   _markers[markerId] = marker;
                            // }
                          });
                        }
                      },
                      child: const Icon(
                        Icons.search_rounded,
                        // color: DesingColors.yellow,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: device_data.size.width - 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              backgroundColor: DesingColors.dark,
              onPressed: () {
                _polygonSet.clear();
                _textLugar.clear();

                setState(() {
                  _markers.clear();
                  hasPaintedAZone = false;
                  hammerIsTaped = false;
                  contador = 0;
                });
              },
              child: const Icon(Icons.delete_rounded),
            ),
            SizedBox(
              width: device_data.size.width * 0.6,
            ),
            Builder(
              builder: (context) {
                if (hasPaintedAZone == false) {
                  return FloatingActionButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Escribe o selecciona una zona por favor')));
                    },
                    backgroundColor: DesingColors.bottonDisable,
                    child: const Icon(Icons.do_disturb_alt_outlined),
                  );
                } else {
                  return SpeedDial(
                    overlayOpacity: 0,
                    renderOverlay: false,
                    backgroundColor: DesingColors.dark,
                    animatedIcon: AnimatedIcons.menu_close,
                    spaceBetweenChildren: 10,
                    children: [
                      SpeedDialChild(
                          backgroundColor: DesingColors.yellow,
                          child: const Icon(Icons.family_restroom_rounded)),
                      SpeedDialChild(
                          backgroundColor: DesingColors.yellow,
                          onTap: () {
                            setState(() {
                              hammerIsTaped = !hammerIsTaped;

                              for (Polygon element in _polygonSet) {
                                print('AAaaaaAAAAAAAAAAAAAAAAAAAAAAA');
                                print(element.consumeTapEvents);
                              }

                              print(
                                  'CAMBIO EL MARTILLO A TRUE____________ ${hammerIsTaped}');
                              // print(
                              //     'CAMBIO EL MARTILLO A TRUE____________ ${disableOnTapPolygon.value}');
                            });
                          },
                          child: const Icon(Icons.gavel_rounded)),
                      SpeedDialChild(
                          backgroundColor: DesingColors.yellow,
                          child: const Icon(Icons.route_rounded)),
                    ],
                  );

                  // FloatingActionButton(
                  //   child: const Icon(Icons.menu),
                  //   onPressed: () async {

                  //     List<double> coordsUTM =
                  //         await ExcelReader.modifyLatAndLon(
                  //             postionOnTap!.latitude, postionOnTap!.longitude);

                  //     data_predio_cordenada(coordsUTM).then(
                  //       (value) {
                  //         modal_window modal = modal_window(context, size_word);
                  //         if (value.length == 0) {
                  //           modal.venta_modal_error();
                  //         } else {
                  //           modal.venta_modal_info(value, device_data);
                  //         }
                  //       },
                  //     );
                  //   },
                  // );

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
    print('ESTAS TAPEANDO EL MAPA');
    if (hammerIsTaped) {
      print('ESTAS TAPEANDO EL MAPA CON EL MARTILLO');
      setState(() {
        postionOnTap = position;
        // _textLugar.text = transformAddress(placemarks[0].street!);

        final id = _markers.length.toString();
        final markerId = MarkerId(id);

        final marker = Marker(
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          markerId: markerId,
          position: position,
          zIndex: 2,
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

  List<LatLng> geometry_data(List data) {
    var data_geometry = data;
    List<LatLng> polygonCoords = [];

    var new_list = data[0].replaceAll(" ", "").split(",");

    while (new_list.isNotEmpty) {
      var lat = double.parse(new_list.removeLast());
      var lon = double.parse(new_list.removeLast());
      polygonCoords.add(LatLng(lat, lon));
    }

    return polygonCoords;
  }
}
