import 'package:flutter/material.dart';
import 'screens/auth/index.dart';
import 'screens/home/index.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
          color: Colors.white,
          child: Container(
            height: 70.0,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildBottomItem('Explore','images/explore-icon.svg'),
                _buildBottomItem('Search','images/search-icon.svg'),
                _buildBottomItem('Trips', 'images/trips-icon.svg'),
                _buildBottomItem('Profile', 'images/avatar-icon.svg'),
              ],
            ),
          ),
        ),
      )
    ));
  }

  Widget _buildBottomItem (String label, String path) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child:SvgPicture.asset(path, color:Colors.black, width: 50, height: 50, fit: BoxFit.contain,)
          ),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.0
              )
            )
          )
        ]
      ), 
      iconSize: 60, 
      onPressed: () {},
    );
  }
}