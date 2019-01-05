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
  static const String createtrip = '/trip/create';
}

class Contexts {
  static BuildContext trips;
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;
  //final ValueChanged<dynamic> onSwitchTab;

  push(BuildContext context, Map<String, dynamic> data) {
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
      case 'createtrip':
        goTo = TabNavigatorRoutes.createtrip;
        break;
      default:
        break;
    }

    /*if(data['from'] == 'createtrip') {
      Navigator.push(
        Contexts.trips,
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

            }),
        );
        onSwitchTab({'tabItem':TabItem.trips});
      

    }*/


    if(data['from'] != null && (data['from'] == 'search' || data['from'] == 'createtrip')) {
      return Navigator.pushReplacement(
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
        }),
      );
    } else {
       return goTo == TabNavigatorRoutes.search || goTo == TabNavigatorRoutes.createtrip ? Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => routeBuilders[goTo](context),
          )
        )
       : 
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
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
  }


  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,{Map<String, dynamic> data}) {
    //print(this.tabItem);
    var routes = {
      TabNavigatorRoutes.country: (context) => Country(
        countryId: data['id'],
        onPush: (data) => push(context, data),
      ),
      TabNavigatorRoutes.city: (context) =>City(
        cityId: data['id'],
        onPush: (data) => push(context, data)
      ),
      TabNavigatorRoutes.island: (context) => City(
        cityId: data['id'],
        onPush: (data) => push(context, data)
      ),
      TabNavigatorRoutes.cityState: (context) => CityState(
        cityStateId: data['id'],
        onPush: (data) => push(context, data)
      ),
      TabNavigatorRoutes.poi: (context) => Poi(
        poiId: data['id'], 
        onPush: (data) => push(context, data)
      ),
      TabNavigatorRoutes.park: (context) => Park(
        parkId: data['id'], 
        onPush: (data) => push(context, data)
      ),
      TabNavigatorRoutes.trip: (context) => Trip(
        tripId: data['id'], 
        onPush: (data) => push(context, data)
      ),
      TabNavigatorRoutes.createtrip: (context) => CreateTrip(
        param: data['param'],
        onPush: (data) => push(context, data)
      ),
      TabNavigatorRoutes.search: (context) => Search(
        query: '',
        id: data['id'],
        location: data['location'],
        onPush: (data) => push(context, data)
      ),
    };

    switch(this.tabItem){
      case TabItem.explore:
        routes[TabNavigatorRoutes.root] = (context) => Home(
          onPush: (data) => push(context, data),
        );
        return routes;
      case TabItem.trips:
        routes[TabNavigatorRoutes.root] = (context) => Trips(
            onPush: (data) => push(context, data),
        );
        return routes;
      case TabItem.profile:
        routes[TabNavigatorRoutes.root] = (context) => Home(
          onPush: (data) => push(context, data),
        );
        return routes;
      default:
        routes[TabNavigatorRoutes.root] = (context) => Home(
          onPush: (data) => push(context, data),
        );
        return routes;
    }
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    //using trips context for anything trip related
    /*if(this.tabItem == TabItem.trips){
      Contexts.trips = context; 
    }*/

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
