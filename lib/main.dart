import 'package:location/location.dart' as prefix0;

import 'routes.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter/services.dart';

void main() async {
  var byteData =
      await rootBundle.load('packages/timezone/data/$tzDataDefaultFilename');
  initializeDatabase(byteData.buffer.asUint8List());

  var location = new prefix0.Location();

// Platform messages may fail, so we use a try/catch PlatformException.
  try {
    var permission = await location.hasPermission();
    if (permission == false) {
      var request = await location.requestPermission();
    }
  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      var error = 'Permission denied';
    }
  }

  new Routes();
}
