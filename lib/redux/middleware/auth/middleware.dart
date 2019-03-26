// lib/middleware/auth_middleware.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redux/redux.dart';
import 'package:trotter_flutter/redux/index.dart';


// Recall that middleware is simply functions.
//
// These functions more or less intercept actions -- pausing
// the Redux cycle while your app does some work.
//
// If you have multiple middleware functions that are related
// to a single piece of state, you can use a method like this
// which will return multiple functions that you can add
// to your store.
//
List<Middleware<AppState>> createAuthMiddleware() {
  final logIn = _createLogInMiddleware();
  final logOut = _createLogOutMiddleware();

  // Built in redux method that tells your store that these
  // are middleware methods.
  //
  // As the app grows, we can add more Auth related middleware
  // here.
  return <Middleware<AppState>>[
    new TypedMiddleware<AppState, LogIn>(logIn),
    new TypedMiddleware<AppState, LogOut>(logOut)
  ];
}

// Now, we need to write those two methods, both of which
// return a Middleware typed function.
//
Middleware<AppState> _createLogInMiddleware() {
  return (Store store, action, NextDispatcher next) async {

  	// FirebaseUser is the type of your User.
		FirebaseUser user;
		// Firebase 'instances' are temporary instances which give
		// you access to your FirebaseUser. This includes
		// some tokens we need to sign in.
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // GoogleSignIn is a specific sign in class.
    final GoogleSignIn _googleSignIn = new GoogleSignIn();

    // Actions are classes, so you can Typecheck them
    if (action is LogIn) {
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

        // This can be tough to reason about -- or at least it was for me.
        // We're going to dispatch a new action if we logged in,
        //
        // We also continue the current cycle below by calling next(action).
        store.dispatch(new LogInSuccessful(user: user));
      } catch (error) {
        store.dispatch(new LogInFail(error));
      }
    }
    next(action);
  };
}

Middleware<AppState> _createLogOutMiddleware() {
  return (Store store, action, NextDispatcher next) async {
		// Temporary instance
		final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      await _auth.signOut();
      print('logging out...');
      store.dispatch(new LogOutSuccessful());
    } catch (error) {
      print(error);
    }
	};
}