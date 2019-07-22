import 'package:flutter/material.dart';
import 'package:trotter_flutter/bottom_navigation.dart';
import 'package:trotter_flutter/screens/home/index.dart';
import 'package:trotter_flutter/screens/country/index.dart';
import 'package:trotter_flutter/screens/city/index.dart';
import 'package:trotter_flutter/screens/city_state/index.dart';
import 'package:trotter_flutter/screens/poi/index.dart';
import 'package:trotter_flutter/screens/park/index.dart';
import 'package:trotter_flutter/screens/trips/index.dart';
import 'package:trotter_flutter/screens/notifications/index.dart';
import 'package:trotter_flutter/screens/region/index.dart';
import 'package:trotter_flutter/screens/itinerary/index.dart';
import 'package:trotter_flutter/screens/profile/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String country = '/country';
  static const String city = '/city';
  static const String region = '/region';
  static const String poi = '/poi';
  static const String search = '/search';
  static const String cityState = '/city_state';
  static const String island = '/island';
  static const String park = '/park';
  static const String trip = '/trip';
  static const String itinerary = '/itinerary';
  static const String itinerary_builder = '/itinerary/edit';
  static const String day_edit = '/itinerary/day/edit';
  static const String day = '/itinerary/day';
  static const String createtrip = '/trip/create';
  static const String travelinfo = '/trip/travelinfo';
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
      case 'itinerary':
        goTo = TabNavigatorRoutes.itinerary;
        break;
      case 'itinerary/edit':
        goTo = TabNavigatorRoutes.itinerary_builder;
        break;
      case 'itinerary/day':
        goTo = TabNavigatorRoutes.day;
        break;
      case 'itinerary/day/edit':
        goTo = TabNavigatorRoutes.day_edit;
        break;
      case 'region':
        goTo = TabNavigatorRoutes.region;
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
      case 'travelinfo':
        goTo = TabNavigatorRoutes.travelinfo;
        break;
      default:
        break;
    }

    if (data['from'] != null &&
        (data['from'] == 'search' || data['from'] == 'createtrip')) {
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
      return goTo == TabNavigatorRoutes.search ||
              goTo == TabNavigatorRoutes.createtrip
          ? Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => routeBuilders[goTo](context),
              ))
          : Navigator.push(
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

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      {Map<String, dynamic> data}) {
    var routes = {
      TabNavigatorRoutes.country: (context) => Country(
            countryId: data['id'],
            onPush: (data) => push(context, data),
          ),
      TabNavigatorRoutes.city: (context) =>
          City(cityId: data['id'], onPush: (data) => push(context, data)),
      TabNavigatorRoutes.region: (context) =>
          Region(regionId: data['id'], onPush: (data) => push(context, data)),
      TabNavigatorRoutes.island: (context) =>
          City(cityId: data['id'], onPush: (data) => push(context, data)),
      TabNavigatorRoutes.cityState: (context) => CityState(
          cityStateId: data['id'], onPush: (data) => push(context, data)),
      TabNavigatorRoutes.poi: (context) => Poi(
          poiId: data['id'],
          locationId: data['locationId'],
          googlePlace: data['google_place'],
          onPush: (data) => push(context, data)),
      TabNavigatorRoutes.park: (context) =>
          Park(parkId: data['id'], onPush: (data) => push(context, data)),
      TabNavigatorRoutes.trip: (context) =>
          Trip(tripId: data['id'], onPush: (data) => push(context, data)),
      TabNavigatorRoutes.itinerary: (context) => Itinerary(
          itineraryId: data['id'], onPush: (data) => push(context, data)),
      TabNavigatorRoutes.itinerary_builder: (context) => ItineraryBuilder(
          itineraryId: data['id'], onPush: (data) => push(context, data)),
      TabNavigatorRoutes.day_edit: (context) => DayEdit(
          itineraryId: data['itineraryId'],
          dayId: data['dayId'],
          onPush: (data) => push(context, data)),
      TabNavigatorRoutes.day: (context) => Day(
          itineraryId: data['itineraryId'],
          dayId: data['dayId'],
          onPush: (data) => push(context, data)),
      TabNavigatorRoutes.travelinfo: (context) => FlightsAccomodations(
          tripId: data['tripId'],
          currentUserId: data['currentUserId'],
          onPush: (data) => push(context, data)),
      TabNavigatorRoutes.createtrip: (context) => CreateTrip(
          param: data['param'], onPush: (data) => push(context, data)),
      TabNavigatorRoutes.search: (context) => Search(
          query: '',
          id: data['id'],
          location: data['location'],
          destinationName: data['destinationName'],
          onPush: (data) => push(context, data)),
    };

    switch (this.tabItem) {
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
      case TabItem.notifications:
        routes[TabNavigatorRoutes.root] = (context) => Notifications(
              onPush: (data) => push(context, data),
            );
        return routes;
      case TabItem.profile:
        routes[TabNavigatorRoutes.root] = (context) => Profile(
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
