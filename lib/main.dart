import 'routes.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';


void main () {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark
    ));
  new Routes();
}