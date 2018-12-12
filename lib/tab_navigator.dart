import 'package:flutter/material.dart';
import 'package:trotter_flutter/bottom_navigation.dart';
import 'package:trotter_flutter/screens/home/index.dart';
import 'package:trotter_flutter/screens/country/index.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String country = '/country';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  void _push(BuildContext context, {String id}) {
    var routeBuilders = _routeBuilders(context, id: id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => routeBuilders[TabNavigatorRoutes.country](context),
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      {String id}) {
    return {
      TabNavigatorRoutes.root: (context) => Home(
        onPush: (id) =>
          _push(context, id: id),
      ),
      TabNavigatorRoutes.country: (context) => Country(countryId:id),
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