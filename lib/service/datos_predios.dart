import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> data_predio(nombre1, nombre2, numero) async {
  print(nombre1);
  print(nombre2);
  print(numero);
  final response = await http.get(Uri.parse(
      'https://visorurbano.com:3000/api/v2/catastro/predio/search?calle=${nombre1}%20${nombre2}&numeroExterior=${numero}'));
  // https://visorurbano.com:3000/api/v2/catastro/predio/search?calle=SANCHEZ%20PRISCILIANO&numeroExterior=595

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var data = json.decode(response.body);
    
    return data;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

var tipos_uso_nombre = {
  'H': 'Habitacional',
  'H1': 'Habitacional1',
  'H2': 'Habitacional2',
  'H3': 'Habitacional3',
  'H4': 'Habitacional4',
  'H5': 'Habitacional5',
  'CS': 'Comercio y Servicios',
  'CS1': 'Comercio y Servicios Impacto Mínimo',
  'CS2': 'Comercio y Servicios Impacto Bajo',
  'CS3': 'Comercio y Servicios Impacto Medio',
  'CS4': 'Comercio y Servicios Impacto Alto',
  'CS5': 'Comercio y Servicios5 Impacto Máximo',
  'I': 'Industrial',
  'I1': 'Industrial Impacto Mínimo',
  'I2': 'Industrial Impacto Bajo',
  'I3': 'Industrial Impacto Medio',
  'I4': 'Industrial Impacto Alto',
  'I5': 'Industrial Industrial Impacto Máximo',
  'E': 'Equipamiento',
  'E1': 'Equipamiento Impacto Mínimo',
  'E2': 'Equipamiento Impacto Bajo',
  'E3': 'Equipamiento Impacto Medio',
  'E4': 'Equipamiento Impacto Alto',
  'E5': 'Equipamiento Impacto Máximo',
  'EA': 'Espacio Abierto',
  'RI': 'Restricción por Infraestructura',
  'RIE': 'Restricción por Infraestructura de instalaciones especiales',
  'RIS': 'Restricción por Infraestructura de servicios públicos',
  'RIT': 'Restricción por Infraestructura de transportes',
  'P': 'Proteccion Ambiental',
  'ANP': 'Área Natural Protegida',
  'PC': 'Conservación',
  'PRH': 'Protección de Recursos Hídricos',
  'ARN': 'Aprovechamiento de Recursos Naturales',
  'ED': 'Educativo',
  'CR': 'Cultural',
  'AS': 'Asistencia Social',
  'RE': 'Religioso',
  'CA': 'Comercio y Abasto',
  'DE': 'Deportivo',
  'AP': 'Administracion Publica'
};
