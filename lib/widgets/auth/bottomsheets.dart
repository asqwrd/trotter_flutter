import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';

loginBottomSheet(BuildContext context, dynamic data, Color color) {
  return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset('images/trips-login.png',
                    width: 170, height: 170, fit: BoxFit.contain),
                AutoSizeText(
                  'Want to create a trip?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 35, color: color, fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 10),
                AutoSizeText(
                  'Sign up and start planning right away.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25, color: color, fontWeight: FontWeight.w300),
                ),
                Container(
                    margin: EdgeInsets.only(top: 40),
                    child: GoogleAuthButtonContainer())
              ],
            ));
      });
}
