// actions/auth_actions.dart
import 'package:firebase_auth/firebase_auth.dart';
// gives us access to `@required`
import 'package:flutter/foundation.dart';

class LogIn {}

class LogInSuccessful {
  final FirebaseUser user;

  LogInSuccessful({ @required this.user});

  @override
  String toString() {
    return 'LogIn{user: $user}';
  }
}

class LogInFail {
  final dynamic error;
  LogInFail(this.error);
  @override
  String toString() {
    return 'LogIn{There was an error loggin in: $error}';
  }
}

class LogOut {}

class LogOutSuccessful {
  LogOutSuccessful();
  @override
  String toString() {
    return 'LogOut{user: null}';
  }
}