import 'package:mysql_client/mysql_client.dart';

class MySQLConnector {
  // static final _settings = MySQLConnection(
  //   host: '192.168.100.226',
  //   port: 3306,
  //   userName: 'kikit2',
  //   password: 'polloasado1',
  //   databaseName: 'kikit',
  // );

  static late MySQLConnection connector;

  MySQLConnector() {
    connection();
  }

  static void connection() async {
    connector = await MySQLConnection.createConnection(
      host: "192.168.100.247",
      port: 3306,
      userName: "kikit2",
      password: "polloasado1",
      databaseName: "kikit", // optional
    );
    print('CONENCTANDO A BASE DE DATOS');
    await connector.connect();
    print(
        'Conexión exitosa a la base de datos|||||||||||||||||||||||||||||||||||||||||||||||||||||||||');
  }

  static void prueba() {
    print('ESTA CONECTADOOOOOOOOOOOO????');
    print(connector.connected);
  }

  static Future<List> getData(CP) async {
    List geometry_list = [];
    List aux = [];
    var result = await connector.execute(
        "select manz.geometry from ageb join manz on ageb.idageb = manz.idageb where ageb.codigoPostal= :CP",
        {'CP': CP});

    for (final row in result.rows) {
      //print(row.assoc()["geometry"]);
     
      geometry_list.add([row.assoc()["geometry"]]);
      
    }
    return geometry_list;
  }
}
