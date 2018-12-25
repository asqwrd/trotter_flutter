import 'package:flutter/material.dart';
import 'package:trotter_flutter/bottom_navigation.dart';
import 'package:trotter_flutter/screens/home/index.dart';
import 'package:trotter_flutter/screens/country/index.dart';
import 'package:trotter_flutter/screens/city/index.dart';
import 'package:trotter_flutter/screens/city_state/index.dart';
import 'package:trotter_flutter/screens/poi/index.dart';
import 'package:trotter_flutter/screens/park/index.dart';
import 'package:trotter_flutter/screens/trips/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String country = '/country';
  static const String city = '/city';
  static const String poi = '/poi';
  static const String search = '/search';
  static const String cityState = '/city_state';
  static const String island = '/island';
  static const String park = '/park';
  static const String trip = '/trip';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  void _push(BuildContext context, Map<String, String> data) {
    var routeBuilders = _routeBuilders(context, data: data);
    var goTo = TabNavigatorRoutes.root;
    switch (data['level']) {
      case 'country':
        goTo = TabNavigatorRoutes.country;
        break;
      case 'city':
        goTo = TabNavigatorRoutes.city;
        break;
      case 'island':
        goTo = TabNavigatorRoutes.island;
        break;
      case 'poi':
        goTo = TabNavigatorRoutes.poi;
        break;
      case 'search':
        goTo = TabNavigatorRoutes.search;
        break;
      case 'city_state':
        goTo = TabNavigatorRoutes.cityState;
        break;
      case 'national_park':
        goTo = TabNavigatorRoutes.park;
        break;
      case 'trip':
        goTo = TabNavigatorRoutes.trip;
        break;
      default:
        break;
    }

    if(data['from'] != null && data['from'] == 'search') {
      Navigator.pushReplacement(
      context,
      PageRouteBuilder(
          pageBuilder: (context, _, __) => routeBuilders[goTo](context),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
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
          }),
      );
    } else{
      Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (context, _, __) => routeBuilders[goTo](context),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
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
            }),
        );
      }
  }


  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,{Map<String, String> data}) {
    //print(data['id']);
    var routes = {
      TabNavigatorRoutes.country: (context) => Country(
        countryId: data['id'],
        onPush: (data) => _push(context, data),
      ),
      TabNavigatorRoutes.city: (context) =>City(
        cityId: data['id'],
        onPush: (data) => _push(context, data)
      ),
      TabNavigatorRoutes.island: (context) => City(
        cityId: data['id'],
        onPush: (data) => _push(context, data)
      ),
      TabNavigatorRoutes.cityState: (context) => CityState(
        cityStateId: data['id'],
        onPush: (data) => _push(context, data)
      ),
      TabNavigatorRoutes.poi: (context) => Poi(
        poiId: data['id'], 
        onPush: (data) => _push(context, data)
      ),
      TabNavigatorRoutes.park: (context) => Park(
        parkId: data['id'], 
        onPush: (data) => _push(context, data)
      ),
      TabNavigatorRoutes.trip: (context) => Trip(
        tripId: data['id'], 
        onPush: (data) => _push(context, data)
      ),
      TabNavigatorRoutes.search: (context) => Search(
        query: '',
        id: data['id'],
        location: data['location'],
        onPush: (data) => _push(context, data)
      ),
    };

    switch(this.tabItem){
      case TabItem.explore:
        routes[TabNavigatorRoutes.root] = (context) => Home(
          onPush: (data) => _push(context, data),
        );
        return routes;
      case TabItem.trips:
        routes[TabNavigatorRoutes.root] = (context) => Trips(
          onPush: (data) => _push(context, data),
        );
        return routes;
      case TabItem.profile:
        routes[TabNavigatorRoutes.root] = (context) => Home(
          onPush: (data) => _push(context, data),
        );
        return routes;
      default:
        routes[TabNavigatorRoutes.root] = (context) => Home(
          onPush: (data) => _push(context, data),
        );
        return routes;
    }
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
