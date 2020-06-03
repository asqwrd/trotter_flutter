import 'package:flutter/material.dart';

import 'routes.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  tz.initializeTimeZones();

  new Routes();
}
