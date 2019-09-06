import 'package:event_bus/event_bus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trotter_flutter/store/auth.dart';
import 'package:trotter_flutter/store/itineraries/store.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'trips/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrotterStore extends Store {
  TrotterUser _currentUser;
  bool profileLoading = false;
  TrotterUser get currentUser => _currentUser;

  TripsStore tripStore = TripsStore();
  final FocusNode explore = FocusNode();
  final FocusNode trips = FocusNode();
  final FocusNode profile = FocusNode();
  final FocusNode notification = FocusNode();
  EventBus eventBus = EventBus();

  BuildContext appContext;

  ItineraryStore itineraryStore = ItineraryStore();
  bool bottomSheetLoading = false;
  bool tripsLoading = false;
  bool notificationsLoading = false;
  bool tripsRefreshing = false;
  NotificationsData _notifications =
      NotificationsData(notifications: [], success: false);
  get notifications => _notifications;

  bool offline = false;

  setAppContext(BuildContext context) {
    appContext = context;
  }

  updateUserNotification(bool value) {
    setState(() {
      _currentUser.notificationOn = value;
    });
  }

  updateUserCountry(String value) {
    setState(() {
      _currentUser.country = value;
    });
  }

  setOffline(bool value) {
    setState(() {
      offline = value;
    });
  }

  setTripsLoading(bool value) {
    setState(() {
      tripsLoading = value;
    });
  }

  setTripsRefreshing(bool value) {
    setState(() {
      tripsRefreshing = value;
    });
  }

  setBottomSheetLoading(bool value) {
    setState(() {
      bottomSheetLoading = value;
    });
  }

  setNotifications(dynamic data) {
    setState(() {
      _notifications = NotificationsData(notifications: data, success: true);
    });
  }

  setNotificationsError(bool error) {
    setState(() {
      _notifications = NotificationsData(notifications: [], success: false);
    });
  }

  setNotificationsLoading(bool loading) {
    setState(() {
      notificationsLoading = loading;
    });
  }

  login() async {
    setState(() {
      profileLoading = true;
    });
    try {
      var user = await googleLogin();
      setState(() {
        _currentUser = user;
        profileLoading = false;
      });
    } catch (err) {}
  }

  logout() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = new GoogleSignIn();
    setState(() {
      profileLoading = true;
    });
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('logged out!');
      setState(() {
        _currentUser = null;
        _notifications = NotificationsData(notifications: [], success: true);
        tripStore = TripsStore();
        itineraryStore = ItineraryStore();
        profileLoading = false;
      });
    } catch (error) {
      print('store.dart error');
      print(error);
    }
  }

  checkLoginStatus() async {
    FirebaseUser userFirebase;
    TrotterUser user;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Actions are classes, so you can Typecheck them
    try {
      userFirebase = await _auth.currentUser();
      final userTrotter = await getUser(userFirebase.uid);
      user = userTrotter.user;
      final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
      final token = await _firebaseMessaging.getToken();
      final deviceId = await getDeviceId();
      print(deviceId);
      final dataToken = {"deviceId": deviceId, "token": token, "uid": user.uid};
      await saveDeviceTokenFirebase(dataToken);

      print("Push Messaging token: $dataToken");

      print('Logged in ' + user.displayName);

      setState(() {
        _currentUser = user;
      });
    } catch (error) {
      print('checkstatus error');
      print(error);
    }
  }
}
