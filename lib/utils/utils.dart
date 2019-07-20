import 'package:flutter/material.dart';
import 'package:simple_moment/simple_moment.dart';

class PixelRatioDivider {
  double quantizedUnit;
  double remainder;

  PixelRatioDivider(BuildContext context, pixels, divideBy) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    quantizedUnit = (pixels * pixelRatio ~/ divideBy) / pixelRatio;
    remainder = pixels - (quantizedUnit * divideBy);
  }
}

String ordinalNumber(final int n) {
  if (n >= 11 && n <= 13) {
    return "${n}th";
  }
  switch (n % 10) {
    case 1:
      return "${n}st";
    case 2:
      return "${n}nd";
    case 3:
      return "${n}rd";
    default:
      return "${n}th";
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Since the wave goes vertically lower than bottom left starting point,
    // we'll have to make this point a little higher.
    path.lineTo(0.0, size.height - 20);

    var firstControlPoint = new Offset(size.width / 4, size.height);
    var firstEndPoint = new Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // The bottom right point also isn't at the same level as its left counterpart,
    // so we'll adjust that one too.
    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0.0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Since the wave goes vertically lower than bottom left starting point,
    // we'll have to make this point a little higher.
    path.lineTo(0.0, size.height - 60);

    var secondControlPoint = Offset(size.width / 2, size.height - 140);
    var secondEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // var secondControlPoint =
    // Offset(size.width - (size.width / 2), size.height-130);
    // var secondEndPoint = Offset(size.width, size.height);
    // path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
    //     secondEndPoint.dx, secondEndPoint.dy);

    // The bottom right point also isn't at the same level as its left counterpart,
    // so we'll adjust that one too.
    path.lineTo(size.width, size.height - 60);
    path.lineTo(size.width, 0.0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomWaveClipperTab extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Since the wave goes vertically lower than bottom left starting point,
    // we'll have to make this point a little higher.
    path.lineTo(0.0, size.height - 110);

    // The bottom right point also isn't at the same level as its left counterpart,
    // so we'll adjust that one too.
    path.lineTo(size.width, size.height - 70);
    path.lineTo(size.width, 0.0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ShortLocaleEn extends LocaleEn {
  String get seconds => '%is';

  String get aMinute => '%im';
  String get minutes => '%im';

  String get anHour => '%ih';
  String get hours => '%ih';

  String get aDay => '%id';
  String get days => '%id';
}

class BottomWaveClipperSlant extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    // Since the wave goes vertically lower than bottom left starting point,
    // we'll have to make this point a little higher.
    path.lineTo(0.0, size.height - 10);

    // The bottom right point also isn't at the same level as its left counterpart,
    // so we'll adjust that one too.
    path.lineTo(size.width, size.height - 120);
    path.lineTo(size.width, 0.0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CornerRadiusClipper extends CustomClipper<Path> {
  final double radius;

  CornerRadiusClipper(this.radius);

  @override
  Path getClip(Size size) {
    final path = new Path();
    final rect = new Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    path.addRRect(
        new RRect.fromRectAndRadius(rect, new Radius.circular(radius)));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

hexStringToHexInt(String hex) {
  hex = hex.replaceFirst('#', '');
  hex = hex.length == 6 ? 'ff' + hex : hex;
  int val = int.parse(hex, radix: 16);
  return val;
}

tagsToString(List<dynamic> tags) {
  String output = "";
  for (var i = 0; i < tags.length; i++) {
    if (i < tags.length - 1) {
      output += "${tags[i]["tag"]["name"]}, ";
    } else {
      output += "${tags[i]["tag"]["name"]}";
    }
  }
  return output;
}

Color fontContrast(Color color) {
  if (color != null && color.computeLuminance() < 0.5) {
    return Colors.white;
  }

  return Colors.black;
}

buildDivider() {
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Divider(color: Colors.grey));
}

arrayString(List<dynamic> list) {
  return list.join(', ');
}

Widget buildTravelers(List<dynamic> travelers) {
  var avatars = <Widget>[];
  var length =
      travelers.length < 4 ? travelers.length : travelers.sublist(0, 4);
  var more = travelers.length - length;
  double right = 0;
  if (more > 0) {
    var moreText = more > 9 ? '9+' : '+$more';
    avatars.add(Positioned(
        right: 0,
        top: 0,
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    style: BorderStyle.solid, color: Colors.white, width: 2)),
            child: ClipPath(
                clipper: CornerRadiusClipper(100),
                child: Container(
                    color: Colors.blueGrey,
                    alignment: Alignment.center,
                    width: 35.0,
                    height: 35,
                    child: Text(
                      moreText,
                      style: TextStyle(color: Colors.white),
                    ))))));
    right += 30;
  }
  for (int i = 0; i < length; i++) {
    avatars.add(
      Positioned(
          right: right,
          top: 0,
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      style: BorderStyle.solid, color: Colors.white, width: 2)),
              child: ClipPath(
                  clipper: CornerRadiusClipper(100),
                  child: Image.network(travelers[i]['photoUrl'],
                      width: 35.0, height: 35.0, fit: BoxFit.contain)))),
    );
    right += 30;
  }

  return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: 40.0,
        minWidth: 40.0,
        maxHeight: 40,
        maxWidth: 40,
      ),
      child:
          Row(children: <Widget>[Flexible(child: Stack(children: avatars))]));
}

typedef String2VoidFunc = void Function(Map<String, dynamic>);
