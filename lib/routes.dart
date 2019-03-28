import 'package:flutter/material.dart';
import 'app.dart';
import 'package:flutter/services.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';


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
    var builders = {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
    };
    final Store store = Store<AppState>(
      appStateReducer,
      initialState: AppState.initialState(),
       middleware: []
      ..addAll(createAuthMiddleware())
      //..add(new LoggingMiddleware.printer()),
    );

    
    runApp(
      StoreProvider<AppState>(
      store: store,
      child:new AnnotatedRegion<SystemUiOverlayStyle>(
        value:mySystemTheme,
        child:new MaterialApp(
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            pageTransitionsTheme: PageTransitionsTheme(builders: builders)
          ),
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: MyBehavior(),
              child: child,
            );
          },
          home: new App()
        )
      ))
    );
  }
    
}