import 'package:flutter/material.dart';

import 'routes.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var byteData =
      await rootBundle.load('packages/timezone/data/$tzDataDefaultFilename');
  initializeDatabase(byteData.buffer.asUint8List());

  new Routes();
}
