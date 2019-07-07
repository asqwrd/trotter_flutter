import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<UserLoginData> saveUserToFirebase(dynamic data) async {
  try {
    final response = await http.post('http://localhost:3002/api/users/login',
        body: json.encode(data),
        headers: {
          'Authorization': 'security',
          "Content-Type": "application/json"
        });
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = UserLoginData.fromJson(json.decode(response.body));
      return results;
    } else {
      // If that response was not OK, throw an error.
      return UserLoginData(success: false);
    }
  } catch (error) {
    print(error);
    print("User not saved");
    return UserLoginData(success: false);
  }
}

Future<FirebaseUser> googleLogin() async {
  // FirebaseUser is the type of your User.
  FirebaseUser user;
  // Firebase 'instances' are temporary instances which give
  // you access to your FirebaseUser. This includes
  // some tokens we need to sign in.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GoogleSignIn is a specific sign in class.
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  try {
    // Try to sign in the user.
    // This method will either log in a user that your Firebase
    // is aware of, or it will prompt the user to log in
    // if its the first time.
    //
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // After checking for authentication,
    // We wil actually sign in the user
    // using the token that firebase.

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    user = await _auth.signInWithCredential(credential);

    print('Logged in ' + user.displayName);
    final data = {
      "displayName": user.displayName,
      "photoUrl": user.photoUrl,
      "email": user.email,
      "phoneNumber": user.phoneNumber,
      "uid": user.uid,
    };
    await saveUserToFirebase(data);

    // This can be tough to reason about -- or at least it was for me.
    // We're going to dispatch a new action if we logged in,
    //
    // We also continue the current cycle below by calling next(action).
    return user;
  } on PlatformException catch (e) {
    switch (e.code) {
      case 'ERROR_USER_DISABLED':
        print('Google Sign-In error: User disabled');
        break;
      case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
        print(
            'Google Sign-In error: Account already exists with a different credential.');
        break;
      case 'ERROR_INVALID_CREDENTIAL':
        print('Google Sign-In error: Invalid credential.');
        break;
      case 'ERROR_OPERATION_NOT_ALLOWED':
        print('Google Sign-In error: Operation not allowed.');
        break;
      default:
        print('Google Sign-In error');
        break;
    }
    print(e);
    return null;
  } catch (e) {
    print('Google Sign-In error');
    print(e);
    return null;
  }
}

class UserLoginData {
  final bool success;
  final bool exists;

  UserLoginData({this.success, this.exists});

  factory UserLoginData.fromJson(Map<String, dynamic> json) {
    return UserLoginData(success: json['success'], exists: json['exists']);
  }
}
