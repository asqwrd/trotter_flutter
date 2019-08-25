import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:overlay_support/overlay_support.dart';
import 'app.dart';
import 'package:flutter/services.dart';

import 'store/store.dart';

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
      statusBarColor: Colors.transparent);

  Routes() {
    var builders = {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
    };
    final store = TrotterStore();

    runApp(new AnnotatedRegion<SystemUiOverlayStyle>(
        value: mySystemTheme,
        child: Provider(
            store: store,
            child: OverlaySupport(
                child: MaterialApp(
                    theme: ThemeData(
                        scaffoldBackgroundColor: Colors.white,
                        pageTransitionsTheme:
                            PageTransitionsTheme(builders: builders)),
                    builder: (context, child) {
                      return ScrollConfiguration(
                        behavior: MyBehavior(),
                        child: child,
                      );
                    },
                    home: new App())))));
  }
}
