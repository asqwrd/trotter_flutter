import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class EmptySearch extends StatelessWidget {
  const EmptySearch({this.color});
  final Color color;
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                    child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        height: MediaQuery.of(context).size.width / 3,
                        foregroundDecoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(.3),
                                Colors.white.withOpacity(1),
                                Colors.white.withOpacity(1),
                              ],
                              center: Alignment.center,
                              focal: Alignment.center,
                              radius: 1.05,
                            ),
                            borderRadius: BorderRadius.circular(130)),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('images/error-icon.png'),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(130)))),
                AutoSizeText(
                  'Sorry nothing came up from ypur search ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25, color: color, fontWeight: FontWeight.w300),
                )
              ],
            )));
  }
}
