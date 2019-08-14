import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'widgets/google_button/index.dart';
import 'widgets/facebook_button/index.dart';


class Auth extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold( // 1
      appBar: new AppBar( //2
        title: new AutoSizeText("Auth"),
      ),
      body: new Container(
      // decoration: new BoxDecoration(color: Colors.white),
        child: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new GoogleButton(),
              new Padding(
                padding: new EdgeInsets.all(8.0),
                child: new FacebookButton()
              )
            ],
          )
        )
      )
    );
  }
}