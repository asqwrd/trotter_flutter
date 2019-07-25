import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:trotter_flutter/bottom_navigation.dart';
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
    TabItem.profile: GlobalKey<NavigatorState>(),
  };
  BuildContext appContext;

  FocusNode _focusA = FocusNode();
  FocusNode _focusB = FocusNode();
  FocusNode _focusC = FocusNode();
  FocusNode _focusD = FocusNode();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TrotterStore store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        if (message['notification'] != null) {
          print(store.notifications.notifications);
          fetchNotifications(store);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
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
    FocusScope.of(context).requestFocus(_focusA);
    store = Provider.of<TrotterStore>(context);
    if (store.currentUser == null) {
      store.checkLoginStatus();
      fetchNotifications(store);
    }
  }

  void _selectTab(BuildContext context, TabItem tabItem) {
    setState(() {
      if (tabItem == TabItem.explore)
        FocusScope.of(context).requestFocus(_focusA);
      else if (tabItem == TabItem.trips)
        FocusScope.of(context).requestFocus(_focusB);
      else if (tabItem == TabItem.profile)
        FocusScope.of(context).requestFocus(_focusC);

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

      //TODO: figure out how to go directly to the trip
      //store.setTripsLoading(true);

      //var data = {"level": "trip", "id": tripId};
      // await Navigator.push(
      //   this.appContext,
      //   MaterialPageRoute(
      //       //fullscreenDialog: true,
      //       builder: (context) => Trip(
      //             tripId: tripId,
      //             onPush: (data) => TabNavigator().push(context, data),
      //           )),
      // );
      //store.setTripsLoading(false);
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
    _focusA.dispose();
    _focusB.dispose();
    _focusC.dispose();
    _focusD.dispose();
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
                child: Text(
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
    });

    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[currentTab].currentState.maybePop(),
      child: SizedBox.expand(
          child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          Focus(
              focusNode: _focusA,
              child: _buildOffstageNavigator(TabItem.explore)),
          Focus(
              focusNode: _focusB,
              child: _buildOffstageNavigator(TabItem.trips)),
          Focus(
              focusNode: _focusD,
              child: _buildOffstageNavigator(TabItem.notifications)),
          Focus(
              focusNode: _focusC,
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
