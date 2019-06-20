import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:trotter_flutter/bottom_navigation.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/tab_navigator.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppStateWidget();
}

class AppStateWidget extends State<App> {
  TabItem currentTab = TabItem.explore;
  final store = TrotterStore();
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.explore: GlobalKey<NavigatorState>(),
    TabItem.trips: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
  };

  FocusScopeNode _focusA = FocusScopeNode();
  FocusScopeNode _focusB = FocusScopeNode();
  FocusScopeNode _focusC = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    store.checkLoginStatus();
    _retrieveDynamicLink();
  }

  Future<void> _retrieveDynamicLink() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.retrieveDynamicLink();
    print(data?.link?.queryParameters);

    // if (deepLink != null) {
    //   Navigator.pushNamed(
    //       context, deepLink.path); // deeplink.path == '/helloworld'
    // }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FocusScope.of(context).setFirstFocus(_focusA);
  }

  void _selectTab(BuildContext context, TabItem tabItem) {
    setState(() {
      if (tabItem == TabItem.explore)
        FocusScope.of(context).setFirstFocus(_focusA);
      else if (tabItem == TabItem.trips)
        FocusScope.of(context).setFirstFocus(_focusB);
      else if (tabItem == TabItem.profile)
        FocusScope.of(context).setFirstFocus(_focusC);

      currentTab = tabItem;
    });
  }

  @override
  void dispose() {
    _focusA.detach();
    _focusB.detach();
    _focusC.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
        store: store,
        child: WillPopScope(
          onWillPop: () async =>
              !await navigatorKeys[currentTab].currentState.maybePop(),
          child: SizedBox.expand(
              child: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(children: <Widget>[
              FocusScope(
                  node: _focusA,
                  child: _buildOffstageNavigator(TabItem.explore)),
              FocusScope(
                  node: _focusB, child: _buildOffstageNavigator(TabItem.trips)),
              FocusScope(
                  node: _focusC,
                  child: _buildOffstageNavigator(TabItem.profile)),
            ]),
            bottomNavigationBar: BottomNavigation(
                currentTab: currentTab,
                onSelectTab: (TabItem tabitem) => _selectTab(context, tabitem)),
          )),
        ));
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
