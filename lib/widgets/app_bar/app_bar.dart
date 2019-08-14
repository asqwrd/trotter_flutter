import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class TrotterAppBar extends StatelessWidget {
  const TrotterAppBar(
      {Key key,
      @required this.onPush,
      @required this.color,
      this.back,
      this.showSearch,
      this.actions,
      this.title,
      this.id,
      this.location})
      : super(key: key);

  final onPush;
  final Color color;
  final bool back;
  final List<Widget> actions;
  final String title;
  final dynamic location;
  final String id;
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    var actions = this.actions;
    if (this.actions == null) {
      actions = [];
    }
    return Container(
        child: AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: back == true
          ? IconButton(
              padding: EdgeInsets.all(0),
              icon: SvgPicture.asset(
                'images/back-icon.svg',
                width: 30,
                height: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              iconSize: 30,
              color: Colors.white,
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: SvgPicture.asset("images/trotter-logo.svg",
                  width: 24.0, height: 24.0, fit: BoxFit.contain)),
      title: title != null
          ? AutoSizeText(
              title,
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24),
            )
          : AutoSizeText(
              'Trotter',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24),
            ),
      actions: <Widget>[
        ...actions,
        this.showSearch == true || this.showSearch == null
            ? Container(
                width: 58,
                height: 58,
                margin: EdgeInsets.symmetric(horizontal: 0),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  onPressed: () {
                    print(this.location);
                    print(this.title);
                    onPush({
                      'query': '',
                      'level': 'search',
                      'id': this.id,
                      'location': this.location,
                      'destinationName': this.title
                    });
                  },
                  child: SvgPicture.asset("images/search-icon.svg",
                      width: 24.0,
                      height: 24.0,
                      //color: fontContrast(color),
                      fit: BoxFit.contain),
                ))
            : Container()
      ],
    ));
  }
}

class TabBarLoading extends StatelessWidget {
  const TabBarLoading({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Shimmer.fromColors(
          baseColor: Color.fromRGBO(220, 220, 220, 0.8),
          highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
          child: Row(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    // A fixed-height child.
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(240, 240, 240, 0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: (MediaQuery.of(context).size.width / 5) - 40,
                    height: 20.0,
                  )),
              Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    // A fixed-height child.
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(240, 240, 240, 0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: (MediaQuery.of(context).size.width / 5) - 40,
                    height: 20.0,
                  )),
              Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    // A fixed-height child.
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(240, 240, 240, 0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: (MediaQuery.of(context).size.width / 5) - 40,
                    height: 20.0,
                  )),
              Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    // A fixed-height child.
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(240, 240, 240, 0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: (MediaQuery.of(context).size.width / 5) - 40,
                    height: 20.0,
                  )),
              Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Container(
                    // A fixed-height child.
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(240, 240, 240, 0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: (MediaQuery.of(context).size.width / 5) - 40,
                    height: 20.0,
                  )),
            ],
          )),
    );
  }
}
