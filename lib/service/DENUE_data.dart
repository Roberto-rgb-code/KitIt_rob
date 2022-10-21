import 'dart:convert';
import 'package:http/http.dart' as http;

class datosDenue {
  static Future<List> fetchPost(
      tipoComercio, String latitud, String longitud) async {
    var response = await http.get(Uri.parse(
        'https://www.inegi.org.mx/app/api/denue/v1/consulta/Buscar/${tipoComercio}/${latitud},${longitud}/1000/d28a2536-ca8d-47da-bfac-6a57d5c396e0'));

    if (response.statusCode == 200) {
      List negocios = [];
  
      var data = json.decode(response.body);
      for (var element in data) {
    

        negocios
            .add([element["Latitud"], element["Longitud"], element["Nombre"], element["Clase_actividad"]]);
      }
      return negocios;
    } else {

      throw Exception('Failed to load post');
    }
  }
}
