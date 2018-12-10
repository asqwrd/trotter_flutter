import 'package:flutter/material.dart';
import 'screens/auth/index.dart';
import 'screens/home/index.dart';
import 'screens/country/index.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
class Routes {
  final routes = <String, WidgetBuilder>{
    '/Auth': (BuildContext context) => new Auth(),
    '/Home': (BuildContext context) => new Home(),
    //'/Country': (BuildContext context) => new Country(),
  };

  Routes () {
    runApp(new MaterialApp(
      title: 'Flutter Demo',
      routes: routes,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child,
        );
      },
      //home: new Auth(),
      home: Scaffold(
        body: new Home(),
        bottomNavigationBar: BottomNav(),
        )
      )
    );
  }
    
}

class BottomNav extends StatefulWidget {
 BottomNav({Key key}) : super(key: key);

 @override
 _BottomNav createState() => _BottomNav();
}

class _BottomNav extends State<BottomNav> {
  int _selectedIndex = 0;
  Color activeColor = Color.fromRGBO(194, 121, 73, 1);
  @override
  Widget build(BuildContext context) {
    return new Theme(
    data: Theme.of(context).copyWith(
        // sets the background color of the `BottomNavigationBar`
        canvasColor: Colors.white,
      ), // sets the inactive color of the `BottomNavigationBar`
    child: BottomNavigationBar(
      currentIndex: _selectedIndex,
      items: [
        BottomNavigationBarItem(
          icon: new SvgPicture.asset('images/explore-icon.svg', color: _selectedIndex == 0 ? activeColor : Colors.black, width: 30, height: 30, fit: BoxFit.contain),
          title: new Text('Explore'),
        ),
          BottomNavigationBarItem(
          icon: new SvgPicture.asset('images/trips-icon.svg', color: _selectedIndex == 1 ? activeColor : Colors.black, width: 30, height: 30, fit: BoxFit.contain),
          title: new Text('Trips'),
        ),
        BottomNavigationBarItem(
          icon: new SvgPicture.asset('images/search-icon.svg', color: _selectedIndex == 2 ? activeColor : Colors.black, width: 30, height: 30, fit: BoxFit.contain),
          title: new Text('Search'),
        ),
        BottomNavigationBarItem(
          icon: new SvgPicture.asset('images/avatar-icon.svg', color: _selectedIndex == 3 ? activeColor : Colors.black, width: 30, height: 30, fit: BoxFit.contain),
          title: new Text('Profile')
        )
      ],
      fixedColor: activeColor,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
    )
    );
  }
  void _onItemTapped(int index) {
    debugPrint('Response> $index');
    setState(() {
      _selectedIndex = index;
    });
  }

}