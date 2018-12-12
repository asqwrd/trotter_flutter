import 'package:flutter/material.dart';
import 'package:trotter_flutter/bottom_navigation.dart';
import 'package:trotter_flutter/tab_navigator.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';


class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  TabItem currentTab = TabItem.explore;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.explore: GlobalKey<NavigatorState>(),
    TabItem.trips: GlobalKey<NavigatorState>(),
    TabItem.search: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
  };

  void _selectTab(TabItem tabItem) {
    setState(() {
      currentTab = tabItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    
        /*FlutterStatusbarcolor.setNavigationBarColor(Colors.white);
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);*/
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[currentTab].currentState.maybePop(),
      child: SizedBox.expand(child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          _buildOffstageNavigator(TabItem.explore),
          _buildOffstageNavigator(TabItem.trips),
          _buildOffstageNavigator(TabItem.search),
          _buildOffstageNavigator(TabItem.profile),
        ]),
        bottomNavigationBar: BottomNavigation(
          currentTab: currentTab,
          onSelectTab: _selectTab,
        ),
      )),
    );
  }

  Widget _buildOffstageNavigator(TabItem tabItem) {
    return Offstage(
      offstage: currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}