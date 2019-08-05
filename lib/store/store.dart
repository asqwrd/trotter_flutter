import 'package:flutter_store/flutter_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trotter_flutter/store/auth.dart';
import 'package:trotter_flutter/store/itineraries/store.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'trips/store.dart';

class TrotterStore extends Store {
  FirebaseUser _currentUser;
  get currentUser => _currentUser;

  TripsStore tripStore = TripsStore();

  ItineraryStore itineraryStore = ItineraryStore();
  bool bottomSheetLoading = false;
  bool tripsLoading = false;
  bool notificationsLoading = false;
  bool tripsRefreshing = false;
  NotificationsData _notifications =
      NotificationsData(notifications: [], success: false);
  get notifications => _notifications;

  bool offline = false;

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
    try {
      var user = await googleLogin();
      setState(() {
        _currentUser = user;
      });
    } catch (err) {}
  }

  logout() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = new GoogleSignIn();
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print('logged out!');
      setState(() {
        _currentUser = null;
        _notifications = NotificationsData(notifications: [], success: true);
      });
    } catch (error) {
      print('store.dart error');
      print(error);
    }
  }

  checkLoginStatus() async {
    FirebaseUser user;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Actions are classes, so you can Typecheck them
    try {
      user = await _auth.currentUser();

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

class NotificationsData {
  final List<dynamic> notifications;
  final bool success;

  NotificationsData({this.notifications, this.success});

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    return NotificationsData(
        notifications: json['notifications'], success: true);
  }
}

Future<NotificationsData> fetchNotifications([TrotterStore store]) async {
  try {
    final response = await http.get(
        'http://localhost:3002/api/notifications?user_id=${store.currentUser.uid}',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = NotificationsData.fromJson(json.decode(response.body));
      store?.setNotificationsError(false);
      store?.setOffline(false);
      store?.setNotifications(results.notifications);
      store?.setNotificationsLoading(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      return NotificationsData(success: false);
    }
  } catch (error) {
    store?.setNotificationsError(true);
    store?.setNotificationsLoading(false);
    return NotificationsData(success: false);
  }
}

Future<NotificationsData> markNotificationRead(String notificationId,
    [TrotterStore store]) async {
  try {
    final response = await http.put(
        'http://localhost:3002/api/notifications/$notificationId?user_id=${store.currentUser.uid}',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = NotificationsData.fromJson(json.decode(response.body));
      store?.setNotificationsError(false);
      store?.setOffline(false);
      store?.setNotifications(results.notifications);
      store?.setNotificationsLoading(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      return NotificationsData(success: false);
    }
  } catch (error) {
    store?.setNotificationsError(true);
    store?.setNotificationsLoading(false);
    return NotificationsData(success: false);
  }
}
