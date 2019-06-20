import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

    // This can be tough to reason about -- or at least it was for me.
    // We're going to dispatch a new action if we logged in,
    //
    // We also continue the current cycle below by calling next(action).
    return user;
  } catch (error) {
    return error;
  }
}
