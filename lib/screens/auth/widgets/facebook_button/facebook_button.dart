import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/app_button/index.dart';

class FacebookButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return new AppButton(
        buttonName: "facebook", onPressed: null, buttonTextStyle: null);
  }
}
