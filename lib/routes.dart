import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter/services.dart';


class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

// const mySystemTheme= StyleUiOverlayStyle.light
//  .copyWith(systemNavigationBarColor: Colors.red);
class Routes {
  final mySystemTheme = SystemUiOverlayStyle.dark.copyWith(
    systemNavigationBarIconBrightness: Brightness.dark, 
    systemNavigationBarColor: Colors.white, 
    statusBarColor: Colors.transparent
  );


  Routes () {
    
    runApp(
      new AnnotatedRegion<SystemUiOverlayStyle>(
        value:mySystemTheme,
        child:new MaterialApp(
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
          ),
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: MyBehavior(),
              child: child,
            );
          },
          home: new App()
        )
      )
    );
  }
    
}