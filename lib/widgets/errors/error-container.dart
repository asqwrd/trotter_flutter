import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/app_button/index.dart';
import 'dart:core';

class ErrorContainer extends StatelessWidget {
  final VoidCallback onRetry;
  final Color color;

  //passing props in react style
  ErrorContainer({this.onRetry, this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          brightness: Brightness.light,
        ),
        body: Stack(fit: StackFit.expand, children: <Widget>[
          Center(
              child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.width / 3,
                          foregroundDecoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(.3),
                                  Colors.white.withOpacity(1),
                                  Colors.white.withOpacity(1),
                                ],
                                center: Alignment.center,
                                focal: Alignment.center,
                                radius: 1.05,
                              ),
                              borderRadius: BorderRadius.circular(130)),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('images/error-icon.png'),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(130))),
                      AutoSizeText(
                        'Uh Oh! our connection failed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            color: color,
                            fontWeight: FontWeight.w300),
                      ),
                      SizedBox(height: 10),
                      AutoSizeText(
                        'Press retry to reconnect.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            color: color,
                            fontWeight: FontWeight.w300),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 40),
                          child: RetryButton(
                              color: color,
                              width: MediaQuery.of(context).size.width / 4,
                              height: 50,
                              onPressed: () {
                                this.onRetry();
                              }))
                    ],
                  ))),
        ]));
  }
}
