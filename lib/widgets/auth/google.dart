// containers/auth_button/auth_button_container.dart
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:trotter_flutter/store/store.dart';

class GoogleAuthButtonContainer extends StatelessWidget {
  final TrotterStore store;
  final bool isModal;
  GoogleAuthButtonContainer({Key key, this.store, this.isModal})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Connect to the store:
    print(this.store);
    final store =
        this.store != null ? this.store : Provider.of<TrotterStore>(context);
    return new GoogleAuthButton(
        buttonText:
            store.currentUser != null ? 'Log out' : 'Log in with Google',
        onPressedCallback: () async {
          if (store.currentUser != null) {
            await store.logout();
          } else {
            await store.login();
          }
          if (this.isModal == true) {
            Navigator.pop(context);
          }
        });
  }
}

class GoogleAuthButton extends StatelessWidget {
  final String buttonText;
  final Function onPressedCallback;

  // Passed in from Container
  GoogleAuthButton({
    @required this.buttonText,
    this.onPressedCallback,
  });

  @override
  Widget build(BuildContext context) {
    // Raised button is a widget that gives some
    // automatic Material design styles
    return RaisedButton(
      onPressed: onPressedCallback,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      color: Colors.white,
      child: Container(
        // Explicitly set height
        // Contianer has many options you can pass it,
        // Most widgets do *not* allow you to explicitly set
        // width and height
        width: 180.0,
        height: 50.0,

        alignment: Alignment.center,
        // Row is a layout widget
        // that lays out its children on a horizontal axis
        child: new Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Padding is a convenience widget that adds Padding to it's child
            new Padding(
              padding: const EdgeInsets.only(right: 20.0),
              // Image, like everyhting, is just a class.
              // This constructor expects an image URL -- I found this one on Google
              child: Image.asset(
                'images/google-logo.png',
                width: 30.0,
                fit: BoxFit.contain,
              ),
            ),
            new Text(
              buttonText,
              textAlign: TextAlign.center,
              style: new TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
