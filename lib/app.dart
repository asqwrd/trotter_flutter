import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:trotter_flutter/bottom_navigation.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/tab_navigator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:trotter_flutter/widgets/auth/google.dart';
import 'store/trips/middleware.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppStateWidget();
}

class AppStateWidget extends State<App> with WidgetsBindingObserver {
  bool focusTrips = false;
  bool logIn = false;
  TabItem currentTab = TabItem.explore;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.explore: GlobalKey<NavigatorState>(),
    TabItem.trips: GlobalKey<NavigatorState>(),
    TabItem.notifications: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
  };
  BuildContext appContext;

  // static final FocusNode _focusA = FocusNode();
  // static final FocusNode _focusB = FocusNode();
  // static final FocusNode _focusC = FocusNode();
  // static final FocusNode _focusD = FocusNode();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TrotterStore store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        await fetchNotifications(store);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        await fetchNotifications(store);
        // if (message['data']['focus'] == "notifications") {
        //   _selectTab(this.appContext, TabItem.notifications);
        // } else if (message['data']['focus'] == 'trips') {
        //   _selectTab(this.appContext, TabItem.trips);
        //   var data =
        //       json.decode(message['data']["notificationData"].toString());

        //   var results = FocusChangeEvent.fromJson(data);
        //   results.tab = TabItem.trips;
        //   store.eventBus.fire(results);
        // }
      },
      onResume: (Map<String, dynamic> message) async {
        // print("onResume: $message");
        await fetchNotifications(store);
        if (message['data']['focus'] == "notifications") {
          _selectTab(this.appContext, TabItem.notifications);
        } else if (message['data']['focus'] == 'trips') {
          _selectTab(this.appContext, TabItem.trips);
          var data =
              json.decode(message['data']["notificationData"].toString());

          var results = FocusChangeEvent.fromJson(data);
          results.tab = TabItem.trips;
          store.eventBus.fire(results);
        }
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (store == null) {
      store = Provider.of<TrotterStore>(context);
      store.checkLoginStatus();
      store.eventBus.on<dynamic>().listen((event) {
        // All events are of type UserLoggedInEvent (or subtypes of it).
        _selectTab(context, event.tab);
      });
    }
  }

  void _selectTab(BuildContext context, TabItem tabItem) {
    setState(() {
      if (tabItem == TabItem.explore)
        FocusScope.of(context).requestFocus(store.explore);
      else if (tabItem == TabItem.trips)
        FocusScope.of(context).requestFocus(store.trips);
      else if (tabItem == TabItem.profile)
        FocusScope.of(context).requestFocus(store.notification);
      else if (tabItem == TabItem.notifications)
        FocusScope.of(context).requestFocus(store.profile);

      currentTab = tabItem;
    });
  }

  checkDynamicLink(TrotterStore store, String tripId) async {
    if (tripId != null && store.currentUser != null) {
      await setInvite(store, tripId);
    } else if (tripId != null && store.currentUser == null) {
      await showLoginModal(this.appContext);
      await setInvite(store, tripId);
    }
  }

  Future setInvite(TrotterStore store, String tripId) async {
    final user = {
      "user": {
        "displayName": store.currentUser.displayName,
        "photoUrl": store.currentUser.photoUrl,
        "email": store.currentUser.email,
        "phoneNumber": store.currentUser.phoneNumber,
        "uid": store.currentUser.uid,
      }
    };
    var response = await addTraveler(store, tripId, user);
    if (response.success == true && response.exists == false) {
      await fetchTrips(store);
      _selectTab(this.appContext, TabItem.trips);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FirebaseDynamicLinks.instance.retrieveDynamicLink().then((data) {
        final tripId = data?.link?.queryParameters != null
            ? data?.link?.queryParameters['trip']
            : null;
        checkDynamicLink(store, tripId);
      });
    }
  }

  @override
  void dispose() {
    store.explore.dispose();
    store.trips.dispose();
    store.profile.dispose();
    store.notification.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  showLoginModal(BuildContext context) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Dialog(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 20, bottom: 40),
                child: AutoSizeText(
                  'Please sign up to view the trip',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                )),
            Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: GoogleAuthButtonContainer(
                  store: store,
                  isModal: true,
                ))
          ],
        ));
      },
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return new FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    // print('Focus ${this.focusTrips}');
    // if (this.focusTrips == true) {
    //   _selectTab(context, TabItem.trips);
    // }
    setState(() {
      this.appContext = context;
      store.setAppContext(context);
    });

    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[currentTab].currentState.maybePop(),
      child: SizedBox.expand(
          child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          Focus(
              focusNode: store.explore,
              child: _buildOffstageNavigator(TabItem.explore)),
          Focus(
              focusNode: store.trips,
              child: _buildOffstageNavigator(TabItem.trips)),
          Focus(
              focusNode: store.notification,
              child: _buildOffstageNavigator(TabItem.notifications)),
          Focus(
              focusNode: store.profile,
              child: _buildOffstageNavigator(TabItem.profile)),
        ]),
        bottomNavigationBar: BottomNavigation(
            currentTab: currentTab,
            onSelectTab: (TabItem tabitem) => _selectTab(context, tabitem)),
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
