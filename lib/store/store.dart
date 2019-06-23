import 'package:flutter_store/flutter_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trotter_flutter/store/auth.dart';
import 'package:trotter_flutter/store/itineraries/store.dart';

import 'trips/store.dart';

class TrotterStore extends Store {
  FirebaseUser _currentUser;
  get currentUser => _currentUser;

  TripsStore tripStore = TripsStore();

  ItineraryStore itineraryStore = ItineraryStore();
  bool bottomSheetLoading = false;

  bool offline = false;

  setOffline(bool value) {
    setState(() {
      offline = value;
    });
  }

  setBottomSheetLoading(bool value) {
    setState(() {
      bottomSheetLoading = value;
    });
  }

  login() async {
    var user = await googleLogin();
    setState(() {
      _currentUser = user;
    });
  }

  logout() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.signOut();
      print('logged out!');
      setState(() {
        _currentUser = null;
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
