import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map1 extends StatefulWidget {
  Map1({Key? key}) : super(key: key);

  @override
  State<Map1> createState() => _Map1State();
}

class _Map1State extends State<Map1> {
  Completer<GoogleMapController> _controller = Completer(); 
  int contador = 0;

  late LatLng latlon1;

  final Map<MarkerId, Marker> _markers = {};
  Set<Marker> get markers => _markers.values.toSet();

  final _markersController = StreamController<String>.broadcast();
  Stream<String> get onMarkerTap => _markersController.stream;


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(20.6599162,-103.3450723),
    zoom: 11,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(20.6711593, -103.3557154),
      tilt: 59.440717697143555,
      zoom: 15);

  @override
  Widget build(BuildContext context) {
    GoogleMap mapa = GoogleMap(
        mapType: MapType.normal,
        onTap: onTap,
        markers: markers,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      );
      
    return  Scaffold(
      body: mapa,
      floatingActionButton: FloatingActionButton.extended(
        
        onPressed: (){
          
          setState(() {
            _markers.clear();
            contador=0;
          });
          print(_markers);
        },
        label: Text('Limpiar'),
        icon: Icon(Icons.directions_boat),
        
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }



  void onTap(LatLng position){

    if(contador == 0){
    contador+=1;
    print(contador);
    setState(() {
    print(position);
    final id = _markers.length.toString();
    final markerId = MarkerId(id);
    
    final marker = Marker(
      
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      markerId: markerId,
      position: position,
      anchor: const Offset(0.5,1),
      onTap: (){
        _markersController.sink.add(id);
        latlon1=position;
      },
      draggable: true,
      onDragEnd: (newPosition){
        //print("el marcador se puso en las longitudes $newPosition");
        print("latitud ");
        

        position=newPosition;

        print("POSI EN LA QUE PUSISTE EL MARCADOR WEY $position");
      },


      );
      

    _markers[markerId]=marker;
    });
    }
    
    
    }
  
}


