// reducers/auth_reducer.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:redux/redux.dart';
import 'package:trotter_flutter/redux/index.dart';

// This is a built in method for creating type safe reducers.
// The alternative is building something the way we did with
// the counter reducer -- a simple method.
//
// This is the preferred method and it allows us to create
// modular functions that are safer.
//

FirebaseUser userReducer(dynamic state, dynamic action) {
  if(action is LogOutSuccessful){
    return null;

  }

  if(action is LogInSuccessful){
    return action.user;
  }

  return state;
}

// Create the actual reducer methods:
//
// this is dispatched from the LogIn middleware,
// That middleware passes in the user and the action.
// All the reducer needs to do is replace the slice of state
// That handles user.
//
// *NB -- We haven't actually added a user to the state yet.
FirebaseUser _logIn(FirebaseUser user, action) {
  return action.user;
}

// This will just replace the user slice of state with null.
Null _logOut(FirebaseUser user, action) {
  print('herejlkjkj');
  return null;
}