import 'package:flutter/material.dart';
import 'package:trotter_flutter/bottom_navigation.dart';
import 'package:trotter_flutter/screens/home/index.dart';
import 'package:trotter_flutter/screens/country/index.dart';
import 'package:trotter_flutter/screens/city/index.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String country = '/country';
  static const String city = '/city';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  void _push(BuildContext context, Map<String, String> data) {
    print(data['level']);
    var routeBuilders = _routeBuilders(context, data: data);
    var goTo = TabNavigatorRoutes.root;
    switch(data['level']){
      case 'country':
        goTo = TabNavigatorRoutes.country;
        break;
      case 'city':
        goTo = TabNavigatorRoutes.city;
        break;
      default:
        break;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) =>  routeBuilders[goTo](context),
        transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
          return new FadeTransition(
            opacity: animation,
              child: child,
            );
          /*return new SlideTransition(
            position: new Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
           );*/
         }
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, {Map<String, String> data}) {
    return {
      TabNavigatorRoutes.root: (context) => Home(
        onPush: (data) =>
          _push(context, data),
      ),
      TabNavigatorRoutes.country: (context) => Country(
        countryId:data['id'],
        onPush: (data) => _push(context,data),
        ),
      TabNavigatorRoutes.city: (context) => City(cityId:data['id']),
    };
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    return Navigator(
        key: navigatorKey,
        initialRoute: TabNavigatorRoutes.root,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name](context),
          );
        });
  }
}