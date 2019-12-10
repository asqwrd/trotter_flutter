import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trotter_flutter/utils/index.dart';

class TrotterAppBar extends StatefulWidget {
  final onPush;
  final Color color;
  final dynamic back;
  final List<Widget> actions;
  final String title;
  final dynamic location;
  final String id;
  final bool showSearch;
  final bool loading;
  final dynamic destination;
  final Brightness brightness;

  TrotterAppBar(
      {Key key,
      this.onPush,
      this.color,
      this.back,
      this.loading,
      this.showSearch,
      this.actions,
      this.title,
      this.id,
      this.destination,
      this.brightness,
      this.location}) : super(key: key);

      TrotterAppBarState createState() => TrotterAppBarState(onPush: this.onPush,color: this.color, back:this.back,loading: this.loading,showSearch: this.showSearch,actions: this.actions,title: this.title,id:this.id, destination: this.destination,brightness: this.brightness,location:this.location);


}

class TrotterAppBarState extends State<TrotterAppBar> {
  TrotterAppBarState(
      {
      this.onPush,
      this.color,
      this.back,
      this.loading,
      this.showSearch,
      this.actions,
      this.title,
      this.id,
      this.destination,
      this.brightness,
      this.location});

  final onPush;
  final Color color;
  final dynamic back;
  final List<Widget> actions;
  final String title;
  final dynamic location;
  final String id;
  final bool showSearch;
  final bool loading;
  final dynamic destination;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    var actions = this.actions;
    var loading = this.loading;
    if (this.actions == null) {
      actions = [];
    }
    if (this.loading == null) {
      loading = false;
    }
    // for (var action in actions) {
    //   action = IgnorePointer(ignoring: loading, child: action);
    // }
    // print(actions[0]);

    return Container(child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            brightness: this.brightness,
            leading: back == true || back != null
                ? IconButton(
                    padding: EdgeInsets.all(0),
                    icon: SvgPicture.asset(
                      'images/back-icon.svg',
                      width: 30,
                      height: 30,
                      color: fontContrast(color),
                    ),
                    onPressed: () {
                      if (back is Function) {
                        back();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    iconSize: 30,
                    color: fontContrast(color),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: SvgPicture.asset(
                      "images/trotter-logo.svg",
                      width: 24.0,
                      height: 24.0,
                      fit: BoxFit.contain,
                      color: fontContrast(color),
                    )),
            title: title != null
                ? AutoSizeText(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 24,
                        color: fontContrast(color)),
                  )
                : AutoSizeText(
                    'Trotter',
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 24,
                        color: fontContrast(color)),
                  ),
            actions: <Widget>[
          ...actions.map((action) {
            return IgnorePointer(ignoring: loading, child: action);
          }),
          this.showSearch == true || this.showSearch == null
              ? Container(
                  width: 58,
                  height: 58,
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    onPressed: () {
                      if (loading == false) {
                        onPush({
                          'query': '',
                          'level': 'search',
                          'id': this.id,
                          'location': this.location,
                          'destinationName': this.title,
                          'destination': this.destination,
                        });
                      }
                    },
                    child: SvgPicture.asset("images/search-icon.svg",
                        width: 24.0,
                        height: 24.0,
                        color: fontContrast(color),
                        fit: BoxFit.contain),
                  ))
              : Container()
        ]));
  }
}

class TabBarLoading extends StatelessWidget {
  const TabBarLoading({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
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
