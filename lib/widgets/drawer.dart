import 'package:flutter/material.dart';


class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        
        children: <Widget>[
          
          UserAccountsDrawerHeader(
              
              accountName: Text(
                'Rodrigo Rodriguez Ruiz',
                style: TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.bold),
                ),
              
              accountEmail: Text(' ')),
          ListTile(
            leading: Icon(Icons.auto_awesome_mosaic),
            title: Text('Pagina principal'),
            onTap: (){
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Rutas'),
            onTap: (){
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Salir'),
            onTap: (){
            },
          ),
        ],
      ),
    );
  }
}
