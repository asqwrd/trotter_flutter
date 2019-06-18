// containers/auth_button/auth_button_container.dart
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:redux/redux.dart';

class GoogleAuthButtonContainer extends StatelessWidget {
  GoogleAuthButtonContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Connect to the store:
    return new StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        // We haven't made this yet.
        return new GoogleAuthButton(
          buttonText: vm.buttonText,
          onPressedCallback: vm.onPressedCallback,
        );
      },
    );
  }
}

class _ViewModel {
  final String buttonText;
  final Function onPressedCallback;

  _ViewModel({this.onPressedCallback, this.buttonText});

  static _ViewModel fromStore(Store<AppState> store) {
    // This is a bit of a more complex _viewModel
    // constructor. As the state updates, it will
    // recreate this _viewModel, and then pass
    // buttonText and the callback down to the button
    // with the appropriate qualities:
    //
    return new _ViewModel(
        buttonText:
            store.state.currentUser != null ? 'Log Out' : 'Log in with Google',
        onPressedCallback: () {
          if (store.state.currentUser != null) {
            store.dispatch(new LogOut());
          } else {
            store.dispatch(new LogIn());
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
