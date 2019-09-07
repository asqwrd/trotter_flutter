import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';

class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final TextStyle buttonTextStyle;
  final String buttonName;

  //passing props in react style
  AppButton({
    this.buttonName,
    this.onPressed,
    this.buttonTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return new RaisedButton(
        child: new AutoSizeText(buttonName,
            textDirection: TextDirection.ltr, style: buttonTextStyle),
        onPressed: onPressed);
  }
}

class RetryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color color;
  final double width;
  final double height;

  //passing props in react style
  RetryButton({
    this.onPressed,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return RaisedButton(
      onPressed: () {
        this.onPressed();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      color: color,
      child: Container(
        // Explicitly set height
        // Contianer has many options you can pass it,
        // Most widgets do *not* allow you to explicitly set
        // width and height
        width: width,
        height: height,

        alignment: Alignment.center,
        // Row is a layout widget
        // that lays out its children on a horizontal axis
        child: AutoSizeText(
          'Retry',
          textAlign: TextAlign.center,
          style: new TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w300,
              color: fontContrast(color)),
        ),
      ),
    );
  }
}
