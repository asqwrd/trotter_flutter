import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';

class TrotterAppBar extends StatelessWidget {
  const TrotterAppBar({
    Key key,
    @required this.onPush,
    @required this.color,
    this.leading,
    this.actions = const <Widget>[],
    this.title,
  }) : super(key: key);

  final onPush;
  final Color color;
  final Widget leading;
  final List<Widget> actions;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: leading != null
          ? leading
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: SvgPicture.asset("images/trotter-logo.svg",
                  width: 24.0, height: 24.0, fit: BoxFit.contain)),
      title: title != null
          ? Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 30),
            )
          : Text(
              'Trotter',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 30),
            ),
      actions: <Widget>[
        ...actions,
        Container(
            width: 58,
            height: 58,
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              onPressed: () {
                onPush({'query': '', 'level': 'search'});
              },
              child: SvgPicture.asset("images/search-icon.svg",
                  width: 24.0,
                  height: 24.0,
                  //color: fontContrast(color),
                  fit: BoxFit.contain),
            ))
      ],
    );
  }
}
