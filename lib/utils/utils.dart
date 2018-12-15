
import 'package:flutter/material.dart';

class PixelRatioDivider {
  double quantizedUnit;
  double remainder;

  PixelRatioDivider(BuildContext context, pixels, divideBy) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    quantizedUnit = (pixels * pixelRatio ~/ divideBy) / pixelRatio;
    remainder = pixels - (quantizedUnit * divideBy);
  }
}

hexStringToHexInt(String hex) {
  hex = hex.replaceFirst('#', '');
  hex = hex.length == 6 ? 'ff' + hex : hex;
  int val = int.parse(hex, radix: 16);
  return val;
}

Color fontContrast(Color color){
  if(color.computeLuminance() < 0.5){
    return Colors.white;
  }

  return Colors.black;
}

buildDivider() {
  return Padding(padding:EdgeInsets.symmetric(horizontal: 20.0), child:Divider(color: Colors.grey));  
}

arrayString(List<dynamic> list) {
  return list.join(', ');
}