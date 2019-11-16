import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/utils/index.dart';

class CirlcleList extends StatelessWidget {
  final String2VoidFunc onPressed;
  final ValueChanged onLongPressed;
  final String name;
  final String header;
  final String subText;
  final List<dynamic> items;
  final Function(String) callback;

  //passing props in react style
  CirlcleList(
      {this.header,
      this.name,
      this.onPressed,
      this.onLongPressed,
      this.items,
      this.subText,
      this.callback});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    List<Widget> widgets = [];
    for (var index = 0; index < items.length; index++) {
      widgets.add(buildBody(items[index], index));
    }
    return Container(
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  margin:
                      EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: AutoSizeText(
                    this.header,
                    style:
                        TextStyle(fontSize: 19.0, fontWeight: FontWeight.w500),
                  )),
              this.subText != null
                  ? Container(
                      margin: EdgeInsets.only(
                          left: 20.0, right: 20.0, bottom: 20.0),
                      child: AutoSizeText(
                        this.subText,
                        style: TextStyle(
                            fontSize: 13.0, fontWeight: FontWeight.w300),
                      ))
                  : Container(),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widgets,
                  ))
            ]));
  }

  Widget buildBody(dynamic item, int index) {
    return new InkWell(
        onTap: () {
          var id = item['id'];
          var level = item['level'];
          this.onPressed({'id': id, 'level': level});
        },
        onLongPress: () {
          this.onLongPressed({'poi': item, "index": index});
        },
        child: buildThumbnailItem(index, item, Colors.black));
  }

  Container buildThumbnailItem(int index, item, Color fontColor) {
    return Container(
        //height:210.0,
        margin: EdgeInsets.only(left: 0.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                      child: Container(
                          width: 100,
                          height: 100,
                          // decoration: BoxDecoration(
                          //     color: Color(hexStringToHexInt(item['color']))
                          //         .withOpacity(.3),
                          //     borderRadius: BorderRadius.circular(100),
                          //     border: Border.all(
                          //         style: BorderStyle.solid,
                          //         color: item['color'] != null
                          //             ? Color(hexStringToHexInt(item['color']))
                          //                 .withOpacity(.3)
                          //             : Colors.black,
                          //         width: 2)),
                          child: Stack(fit: StackFit.expand, children: <Widget>[
                            ClipPath(
                                clipper: CornerRadiusClipper(10),
                                child: renderImage(item)),
                            ClipPath(
                                clipper: CornerRadiusClipper(10),
                                child: Container(
                                    color: Colors.black.withOpacity(.3))),
                            Positioned(
                                bottom: 0,
                                child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    width: 100.0,
                                    child: AutoSizeText(
                                      item['name'],
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    )))
                          ])))),
            ]));
  }

  Widget renderImage(item) {
    return item['image'] != null
        ? Container(
            child: Image.asset(item['image'], fit: BoxFit.cover),
          )
        : Container(
            decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/placeholder.png'), fit: BoxFit.cover),
          ));
  }
}
