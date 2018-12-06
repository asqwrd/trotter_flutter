import 'package:flutter/material.dart';
import 'screens/auth/index.dart';
import 'screens/home/index.dart';

class Routes {
  final routes = <String, WidgetBuilder>{
    '/Auth': (BuildContext context) => new Auth()
  };

  Routes () {
    runApp(new MaterialApp(
      title: 'Flutter Demo',
      routes: routes,
      //home: new Auth(),
      home: Scaffold(
        body: new Home(title: 'Parallax demo'),
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: Container(height: 50.0,),
        ),
      )
    ));
  }
}