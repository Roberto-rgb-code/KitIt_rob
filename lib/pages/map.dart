import 'dart:collection';
import 'dart:ffi';
import 'dart:io';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kitit/assets/ColorPolygon.dart';
import 'package:kitit/assets/colors.dart';
import 'package:kitit/resourses/exceReader.dart';
import 'package:kitit/service/MySQLConnection.dart';
import 'package:kitit/service/datos_predios.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kitit/widgets/modal_window.dart';
import 'package:kitit/widgets/polygons_metods.dart';
import 'package:kitit/widgets/widow_map.dart';
import 'package:kitit/service/DENUE_data.dart';
import '../widgets/markersComers.dart';

class Map1 extends StatefulWidget {
  Map1({Key? key}) : super(key: key);

  @override
  State<Map1> createState() => _Map1State();
}

class _Map1State extends State<Map1> {
  //variables de google maps and polygons
  Set<Polygon> _polygonSet = new Set();
  Set<Polygon> _polygonSetDisable = new Set();
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  Set<Marker> _markersComers = new Set();

  LatLng? postionOnTap;
  late LatLng latlon1;
  late Map<MarkerId, Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();
  final _markersController = StreamController<String>.broadcast();

  //controladores en general y banderas
  Stream<String> get onMarkerTap => _markersController.stream;
  @override
  final TextEditingController _textLugar = TextEditingController();
  final TextEditingController _textActividadEconomica = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  bool hammerIsTaped = false;
  bool hasPaintedAZone = false;
  bool window_visiviliti = false;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.6599162, -103.3450723),
    zoom: 11,
  );

  ValueNotifier<String> direccion = ValueNotifier<String>('');
  ValueNotifier<String> actividadEconomica = ValueNotifier<String>('');
  ValueNotifier<bool> buttonDisable = ValueNotifier<bool>(true);
  ValueNotifier<bool> buttonAE = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    var deviceData = MediaQuery.of(context);

    Completer<GoogleMapController> _controller = Completer();

    void moveCamera(double lat, double long) async {
      print('Entro a move camera');
      // double lat = 20.7016358;
      // double long = -103.3867676;

      final GoogleMapController controller = await _controller.future;
      final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(
          
        ), 
        'lib/_img/amarilloyblanco(1).png'
      );


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
          icon:icon,
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

    getLocation() async {
      List<Location> locations =
          await locationFromAddress("${_textLugar.text}, Guadalajara, Jal.");

      // await locationFromAddress("Jesus garcia 3020, Guadalajara, Jal.");

      return locations;
    }

    void onTap(LatLng position) async {
      setState(() {
        postionOnTap = LatLng(position.latitude, position.longitude);
      });
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), 
        'lib/_img/amarilloyblanco(1).png'
      );


      print('ESTAS TAPEANDO EL MAPA');
      final resultados = await MySQLConnector.getData(placemarks[0].postalCode);

      if (!hasPaintedAZone) {
        print(
            'PINTANDO POLIGONOS______________________________________________________________________');

        var res_data =
            await MySQLConnector.getMarkersbyCP(placemarks[0].postalCode);

        MarkersCom markerscom = MarkersCom(res_data);
        // ignore: use_build_context_synchronously
        final marcadordeldani = await markerscom.printMarkersComers(
              _customInfoWindowController, context,deviceData);
        setState(() {
          hasPaintedAZone = true;
          myPolygon(resultados);
          _markersComers = marcadordeldani;
          
          for (Marker element in _markersComers) {
            _markers[element.markerId] = element;
          }
          print(
              "________________________________________________________________________________ Hola soy marker nuevo");
          print(_markers.length);
          print(_markers);
        });
      }

      if (hammerIsTaped) {
        print('ESTAS TAPEANDO EL MAPA CON EL MARTILLO');
        setState(() {
          postionOnTap = position;

          // _textLugar.text = transformAddress(placemarks[0].street!);

          String id = 'hammerMaker';
          final markerId = MarkerId(id);

          final marker = Marker(
            icon: icon,
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
            },
          );

          _markers[markerId] = marker;

          // data_predio_cordenada([position.]);
        });
        //AQUI ES DONDE LLAMAREMOS LA VENTANA MODAL
        modal_window modal = modal_window(context, 17);

        List<double> coordsUTM = await ExcelReader.modifyLatAndLon(
            position.latitude, position.longitude);

        final response = await data_predio_cordenada(coordsUTM);

        bool bandVenta = true;
        if (response.length == 0) {
          bandVenta = false;
        }
        modal.venta_modal_info(response, deviceData, bandVenta);
      }

      // POR SI QUIERES ALGUN OTRO IF
    }

    Set<Polygon> paintPolygons() {
      Set<Polygon> a = {};

      if (hammerIsTaped == true) {
        a.addAll(_polygonSetDisable);
        return a;
      } else {
        a.addAll(_polygonSet);
        return a;
      }
    }

    // int conta=0;
    GoogleMap mapa = GoogleMap(
      myLocationEnabled: false,
      mapType: MapType.normal,
      // zoomControlsEnabled: false,
      // polygons: hammerIsTaped == true ? paintPolygons() : _polygonSet,

      polygons: paintPolygons(),
      onTap: onTap,
      markers: markers,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _customInfoWindowController.googleMapController = controller;

        _controller.complete(controller);
      },
      onCameraMove: (latLngPosition) {
        _customInfoWindowController.onCameraMove!();
      },
    );

    var device_data = MediaQuery.of(context);

    return SafeArea(
      child: Scaffold(
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
              CustomInfoWindow(
                controller: _customInfoWindowController,
                height: 180,
                width: 200,
                offset: 80,
              ),
              Container(
                padding: const EdgeInsets.only(top: 7),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: device_data.size.width * 0.7,
                      child: TextField(
                        controller: _textLugar,
                        onChanged: (value) {
                          direccion.value = value;
                        },
                        decoration: const InputDecoration(
                            hoverColor: Colors.black,
                            labelText: "Ingrese su direccion",
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    style: BorderStyle.none, width: 0),
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

                          final resultados = await MySQLConnector.getData(
                              placemarks[0].postalCode);

                          setState(() {
                            print('PINTAR LA ZONA_______________');

                            hasPaintedAZone = true;

                            myPolygon(resultados);

                            postionOnTap = latLngPosition;
                          });
                        }
                      },
                      child: const Icon(
                        Icons.search_rounded,
                        // color: DesingColors.yellow,
                      ),
                    )
                  ],
                ),
              ),
              Builder(builder: (context) {
                if (window_visiviliti == true || buttonAE.value == true) {
                  return Container(
                    margin: EdgeInsets.only(
                        top: device_data.size.height - 690,
                        left: device_data.size.width - 65),
                    child: FloatingActionButton(
                      backgroundColor: DesingColors.dark,
                      onPressed: () {
                        Set<Polygon> _polygonSet_auxiliar = new Set();

                        var tam_polygon_Set = _polygonSet.length;
                        var contador = 0;
                        for (var element in _polygonSet) {
                          if (contador < tam_polygon_Set - 1) {
                            _polygonSet_auxiliar.add(element.clone());
                          }
                          contador++;
                        }

                        setState(() {
                          _customInfoWindowController.hideInfoWindow!();
                          _polygonSet.clear();
                          _polygonSet.addAll(_polygonSet_auxiliar);

                          window_visiviliti = false;
                          buttonAE.value = false;
                        });
                      },
                      child:
                          const Icon(Icons.visibility_off, color: Colors.white),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              })
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
                    _customInfoWindowController.hideInfoWindow!();
                    window_visiviliti = false;
                    _markers.clear();
                    hasPaintedAZone = false;
                    hammerIsTaped = false;
                    _textActividadEconomica.clear();
                    actividadEconomica.value = '';
                    buttonDisable.value = true;
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Escribe o selecciona una zona por favor'),
                          ),
                        );
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
                        // SpeedDialChild(
                        //     backgroundColor: DesingColors.yellow,
                        //     onTap: () {
                        //       setState(
                        //         () {
                        //           if (hammerIsTaped) {
                        //             _markers
                        //                 .remove(const MarkerId('hammerMaker'));
                        //           }
                        //           hammerIsTaped = !hammerIsTaped;
                        //         },
                        //       );
                        //     },
                        //     child: const Icon(Icons.gavel_rounded)),
                        SpeedDialChild(
                          backgroundColor: DesingColors.yellow,
                          child: const Icon(Icons.route_rounded),
                        ),
                        SpeedDialChild(
                            backgroundColor: DesingColors.yellow,
                            child: const Icon(Icons.storefront),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder:
                                      (context) => StatefulBuilder(builder:
                                              (context, StateSetter setState) {
                                            return AlertDialog(
                                              title: const Center(
                                                  child: Text(
                                                'Escribe tu actividad economica',
                                                style: TextStyle(fontSize: 18),
                                              )),
                                              /////////////////
                                              content: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: TextField(
                                                    decoration: InputDecoration(
                                                        suffixIcon: Container(
                                                          color: DesingColors
                                                              .yellow,
                                                          child: IconButton(
                                                              onPressed:
                                                                  () async {
                                                                var isEconomyActivity =
                                                                    await datosDenue
                                                                        .isEconomyActivity(
                                                                            actividadEconomica.value);

                                                                if (isEconomyActivity) {
                                                                  print(
                                                                      'ESTOY HABILITANDO EL BOTOOOOOON');
                                                                  buttonDisable
                                                                          .value =
                                                                      false;
                                                                  print(buttonDisable
                                                                      .value);
                                                                } else {
                                                                  print(
                                                                      'ESTA MAL ASI QUE DESABILITAMOS');
                                                                  buttonDisable
                                                                          .value =
                                                                      true;
                                                                }
                                                                setState(
                                                                  () {},
                                                                );
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .search_rounded,
                                                                color:
                                                                    DesingColors
                                                                        .dark,
                                                              )),
                                                        ),
                                                        errorText: actividadEconomica.value !=
                                                                    '' &&
                                                                buttonDisable
                                                                        .value ==
                                                                    true
                                                            ? 'Escribe una actividad economica valida por favor'
                                                            : null,
                                                        hintText:
                                                            'Ejemplo: Abarrotes'),
                                                    controller:
                                                        _textActividadEconomica,
                                                    onChanged: (value) {
                                                      actividadEconomica.value =
                                                          value;
                                                    }),
                                              ),
                                              ////////////////
                                              actions: [
                                                Center(
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              primary:
                                                                  DesingColors
                                                                      .dark),
                                                      onPressed:
                                                          buttonDisable.value ==
                                                                  true
                                                              ? null
                                                              : () async {
                                                                    final icon = await BitmapDescriptor.fromAssetImage(
                                                                    const ImageConfiguration(
                                                                      //size: Size(20, 20),
                                                                    ), 
                                                                    'lib/_img/amarilloyblanco(1).png'
                                                                  );
                                                                  int cont = 0;
                                                                  modal_window
                                                                      modalWindow =
                                                                      modal_window(
                                                                          context,
                                                                          13);
                                                                  List<Map> list = await datosDenue.fetchPost(
                                                                      actividadEconomica
                                                                          .value,
                                                                      postionOnTap!
                                                                          .latitude
                                                                          .toString(),
                                                                      postionOnTap!
                                                                          .longitude
                                                                          .toString());

                                                                  for (var element
                                                                      in list) {
                                                                    print(
                                                                        'Hola este es ${element}');

                                                                    String
                                                                        name =
                                                                        element[
                                                                            'nombre'];
                                                                    String
                                                                        descrip =
                                                                        element[
                                                                            'descripcion'];

                                                                    double lat =
                                                                        double.parse(
                                                                            element['lat']);

                                                                    double lon =
                                                                        double.parse(
                                                                            element['lon']);

                                                                    LatLng
                                                                        position =
                                                                        LatLng(
                                                                            lat,
                                                                            lon);

                                                                    var markerId =
                                                                        MarkerId(
                                                                            'rivals$cont');
                                                                    cont++;
                                                                    final marker =
                                                                        Marker(
                                                                      icon: icon,
                                                                      markerId:
                                                                          markerId,
                                                                      position:
                                                                          position,
                                                                      zIndex: 2,
                                                                      anchor:
                                                                          const Offset(
                                                                              0.5,
                                                                              1),
                                                                      // infoWindow: InfoWindow(
                                                                      //     title:
                                                                      //         name,
                                                                      //     snippet:
                                                                      //         descrip),
                                                                      onTap:
                                                                          () {
                                                                        buttonAE.value =
                                                                            true;

                                                                        _customInfoWindowController.addInfoWindow!(
                                                                            Container(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                                                              decoration: const BoxDecoration(
                                                                                // border: Border.all(width: 2,color: Colors.black),
                                                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                color: DesingColors.nuse,
                                                                              ),
                                                                              child: Column(
                                                                                children: [
                                                                                  Center(
                                                                                      child: Text(
                                                                                    name,
                                                                                    textAlign: TextAlign.center,
                                                                                    style: const TextStyle(fontSize: 15, color: Colors.white),
                                                                                  )),
                                                                                  const Divider(
                                                                                    color: Colors.white,
                                                                                    thickness: 2,
                                                                                  ),
                                                                                  Text('$descrip.',
                                                                                      style: const TextStyle(
                                                                                        fontSize: 13,
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                      textAlign: TextAlign.justify),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            position);
                                                                        update();
                                                                      },

                                                                      draggable:
                                                                          false,
                                                                    );

                                                                    setState(
                                                                        () {
                                                                      _markers[
                                                                              markerId] =
                                                                          marker;
                                                                    });
                                                                  }
                                                                  print(
                                                                      _markers);

                                                                  // ignore: use_build_context_synchronously
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                      child: const Text(
                                                          'Siguiente')),
                                                ),
                                              ],
                                            );
                                          }));
                            }),
                      ],
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // void onTap(LatLng position) async {
  //   List<Placemark> placemarks =
  //       await placemarkFromCoordinates(position.latitude, position.longitude);

  //   print('ESTAS TAPEANDO EL MAPA');
  //   final resultados = await MySQLConnector.getData(placemarks[0].postalCode);

  //   if (!hasPaintedAZone) {
  //     print(
  //         'PINTANDO POLIGONOS______________________________________________________________________');

  //     print(res_data);
  //     setState(() {
  //       hasPaintedAZone = true;
  //       myPolygon(resultados);

  //     });
  //   }

  //   if (hammerIsTaped) {
  //     print('ESTAS TAPEANDO EL MAPA CON EL MARTILLO');
  //     setState(() {
  //       postionOnTap = position;
  //       // _textLugar.text = transformAddress(placemarks[0].street!);

  //       String id = 'hammerMaker';
  //       final markerId = MarkerId(id);

  //       final marker = Marker(
  //         icon:
  //             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  //         markerId: markerId,
  //         position: position,
  //         zIndex: 2,
  //         anchor: const Offset(0.5, 1),
  //         onTap: () {
  //           _markersController.sink.add(id);
  //           latlon1 = position;
  //         },
  //         draggable: true,
  //         onDragEnd: (newPosition) {
  //           //print("el marcador se puso en las longitudes $newPosition");
  //           print("latitud ");

  //           position = newPosition;

  //           print("POSI EN LA QUE PUSISTE EL MARCADOR WEY $position");
  //         },
  //       );

  //       _markers[markerId] = marker;
  //     });
  //   }
  // }

  Set<Polygon> myPolygon(
    List listaGeometry,
  ) {
    int conta = 0;
    var aux;

    List hola = [];

    for (var i = 0; i < listaGeometry[1].length; i++) {
      List<LatLng> polygonCoords =
          polygonsMetods().geometry_data(listaGeometry[1][i]);
      hola.add(conta);

      Polygon po = Polygon(
        geodesic: true,
        polygonId: PolygonId(listaGeometry[0][i]),
        points: polygonCoords,
        consumeTapEvents: true,
        zIndex: -1,
        strokeColor: ColorPolygon.borderColor,
        strokeWidth: 5,
        fillColor: ColorPolygon.filling,
        onTap: () async {
          _customInfoWindowController.addInfoWindow!(
              window_map(
                data: listaGeometry[2][i],
                listaPolygons: _polygonSet,
              ),
              polygonCoords[0]);

          setState(
            () {
              window_visiviliti = true;
              polygon_seleccion(listaGeometry[0][i]);
            },
          );
        },
      );

      Polygon po2 = Polygon(
        geodesic: true,
        polygonId: PolygonId('test $conta'),
        points: polygonCoords,
        consumeTapEvents: false,
        zIndex: -1,
        strokeColor: ColorPolygon.borderColor2,
        strokeWidth: 5,
        fillColor: ColorPolygon.filling2,
      );

      _polygonSetDisable.add(po2);
      _polygonSet.add(po);

      conta = conta + 1;
    }

    return _polygonSet;
  }

  void polygon_seleccion(ageb) async {
    final resultados = await MySQLConnector.getPolygonBYageb(ageb);
    print(resultados);
    List<LatLng> polygonCoords_2 =
        polygonsMetods().geometry_data(resultados[0]);

    Polygon po = Polygon(
      geodesic: true,
      polygonId: const PolygonId("seleccion"),
      points: polygonCoords_2,
      consumeTapEvents: true,
      zIndex: -1,
      strokeColor: ColorPolygon.filling,
      strokeWidth: 5,
      fillColor: ColorPolygon.borderColor,
    );

    setState(
      () {
        _polygonSet.add(po);
      },
    );
  }

  void update() {
    setState(() {});
  }
}
