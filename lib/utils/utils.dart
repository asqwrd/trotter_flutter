import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flare_loading/flare_loading.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;

PanelHeights getPanelHeights(context) {
  return PanelHeights(
      max: MediaQuery.of(context).size.height - 140,
      min: MediaQuery.of(context).size.height / 2);
}

class PanelHeights {
  final double max;
  final double min;
  PanelHeights({this.min, this.max});
}

class PixelRatioDivider {
  double quantizedUnit;
  double remainder;

  PixelRatioDivider(BuildContext context, pixels, divideBy) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    quantizedUnit = (pixels * pixelRatio ~/ divideBy) / pixelRatio;
    remainder = pixels - (quantizedUnit * divideBy);
  }
}

double getPanelHeight(BuildContext context) {
  final relativeHeight = MediaQuery.of(context).size.height;
  double offset = 100;
  if (Platform.isIOS) {
    offset += MediaQuery.of(context).padding.top;
  }

  final height = relativeHeight - offset;

  return height / relativeHeight;
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

String parseHtmlString(String htmlString) {
  if (htmlString == null) return '';
  var document = parse(htmlString);

  String parsedString = parse(document.body.text).documentElement.text;

  return parsedString;
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
  var length = travelers.length < 4 ? travelers.length : 4;
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
                    width: 33.0,
                    height: 33.0,
                    child: AutoSizeText(
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
                      width: 33.0, height: 33.0, fit: BoxFit.contain)))),
    );
    right += 30;
  }
  double maxWidth = 40;
  if (length == 2) {
    maxWidth = 70;
  } else if (length == 3) {
    maxWidth = 110;
  } else if (length == 4) {
    maxWidth = 140;
  }

  return ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight: 40.0,
        minWidth: 40.0,
        maxHeight: 40,
        maxWidth: maxWidth,
      ),
      child:
          Row(children: <Widget>[Flexible(child: Stack(children: avatars))]));
}

typedef String2VoidFunc = void Function(Map<String, dynamic>);
typedef Future2VoidFunc = Future Function(Map<String, dynamic>);

Widget getErrorWidget(BuildContext context, FlutterErrorDetails error) {
  return Center(
    child: Text(
      "Error appeared.",
      style:
          Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
    ),
  );
}

class TrotterLoading extends StatelessWidget {
  const TrotterLoading({
    Key key,
    @required this.color,
    @required this.file,
    @required this.animation,
  }) : super(key: key);

  final Color color;
  final String file;
  final String animation;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: this.color,
        child: Center(
            child: FlareLoading(
          name: file,
          startAnimation: animation,
          loopAnimation: animation,
          endAnimation: animation,
          onSuccess: (data) {},
          onError: (data, error) {},
        )));
  }
}

class RenderWidget extends StatefulWidget {
  final Widget Function(BuildContext,
      {ScrollController scrollController,
      AsyncSnapshot asyncSnapshot,
      dynamic startLocation}) builder;
  final ValueChanged<double> onScroll;
  final ScrollController scrollController;
  final AsyncSnapshot asyncSnapshot;
  final dynamic startLocation;

  RenderWidget(
      {this.builder,
      this.onScroll,
      this.scrollController,
      this.asyncSnapshot,
      this.startLocation});

  @override
  RenderWidgetState createState() => RenderWidgetState(
      builder: this.builder,
      onScroll: this.onScroll,
      asyncSnapshot: this.asyncSnapshot,
      scrollController: this.scrollController,
      startLocation: this.startLocation);
}

class RenderWidgetState extends State<RenderWidget> {
  final Widget Function(BuildContext,
      {ScrollController scrollController,
      AsyncSnapshot asyncSnapshot,
      dynamic startLocation}) builder;
  final ValueChanged<double> onScroll;
  ScrollController scrollController;
  AsyncSnapshot asyncSnapshot;
  dynamic startLocation;

  @override
  void initState() {
    if (scrollController != null) {
      scrollController.addListener(() {
        onScroll(scrollController.offset);
      });
    }
    super.initState();
  }

  RenderWidgetState(
      {this.builder,
      this.onScroll,
      this.scrollController,
      this.asyncSnapshot,
      this.startLocation});

  Widget build(context) {
    return this.builder(context,
        scrollController: scrollController,
        asyncSnapshot: widget.asyncSnapshot,
        startLocation: widget.startLocation);
  }
}

class StatefulSwitch extends StatefulWidget {
  final bool value;
  final bool disabled;
  final ValueChanged<bool> onChanged;
  final Widget title;
  final Widget disableMessage;
  final Color color;
  StatefulSwitch(
      {this.value,
      this.color,
      this.title,
      this.onChanged,
      this.disabled,
      this.disableMessage});

  StatefulSwitchState createState() => StatefulSwitchState(
      color: this.color,
      value: this.value,
      title: this.title,
      disabled: this.disabled,
      disableMessage: this.disableMessage,
      onChanged: this.onChanged);
}

class StatefulSwitchState extends State<StatefulSwitch> {
  final bool value;
  final bool disabled;
  final Color color;
  final Widget title;
  final Widget disableMessage;
  final ValueChanged<bool> onChanged;
  bool isPublic;

  @override
  void initState() {
    super.initState();
    this.isPublic = this.value;
  }

  StatefulSwitchState(
      {this.value,
      this.color,
      this.title,
      this.onChanged,
      this.disabled,
      this.disableMessage});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      title: title,
      subtitle: disabled == true ? disableMessage : null,
      value: this.isPublic,
      activeColor: color,
      onChanged: (value) {
        if (this.disabled == false) {
          setState(() {
            this.isPublic = value;
            onChanged(value);
          });
        }
      },
    );
  }
}
