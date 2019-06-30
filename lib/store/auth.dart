import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

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
    PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.retrieveDynamicLink();
    print('trip');
    print(data?.link?.queryParameters);
    var tripId = data?.link?.queryParameters;
    if (tripId != null) {
      //tripInvite(tripId['trip']);
    }

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
  } catch (e) {
    print('Google Sign-In error');
    print(e);
  }
}
