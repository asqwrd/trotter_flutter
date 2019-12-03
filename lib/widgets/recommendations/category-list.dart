import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';

class CategoryList extends StatelessWidget {
  final String2VoidFunc onPressed;
  final ValueChanged onLongPressed;
  final String name;
  final String header;
  final String subText;
  final dynamic destination;
  static List<dynamic> items = [];
  final Function(String) callback;

  //passing props in react style
  CategoryList(
      {this.header,
      this.name,
      this.onPressed,
      this.onLongPressed,
      this.destination,
      this.subText,
      this.callback});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    List<Widget> widgets = [];
    var queryName =
        destination['destination_name'].toString().replaceAll(" ", "+");
    if (destination['destination_name'] == null &&
        destination['name'] != null) {
      queryName = destination['name'].toString().replaceAll(" ", "+");
    }
    CategoryList.items = [
      {
        "name": "See & Do",
        "color": "#ffac8e",
        "image": 'images/see.jpg',
        "query":
            '$queryName+${destination['country_name'].toString().replaceAll(" ", "+")}+things+to+do',
        "destination": destination
      },
      {
        "name": "Eat & Drink",
        "color": "#fd7792",
        "image": 'images/food.jpg',
        "query":
            '$queryName+${destination['country_name'].toString().replaceAll(" ", "+")}+places+to+eat',
        "destination": destination
      },
      {
        "name": "Nightlife",
        "color": "#3f4d71",
        "image": 'images/nightlife.jpg',
        "query":
            '$queryName+${destination['country_name'].toString().replaceAll(" ", "+")}+night+life',
        "destination": destination
      },
      {
        "name": "Shopping",
        "color": "#55ae95",
        "image": 'images/shopping.jpg',
        "query":
            '$queryName+${destination['country_name'].toString().replaceAll(" ", "+")}+shopping',
        "destination": destination
      }
    ];
    for (var index = 0; index < items.length; index++) {
      widgets.add(buildBody(context, items[index], index));
    }
    return Container(
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(left: 0.0, right: 0.0, bottom: 10.0),
                  child: AutoSizeText(
                    this.header,
                    style:
                        TextStyle(fontSize: 19.0, fontWeight: FontWeight.w500),
                  )),
              this.subText != null
                  ? Container(
                      margin:
                          EdgeInsets.only(left: 0.0, right: 0.0, bottom: 20.0),
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

  Widget buildBody(BuildContext context, dynamic item, int index) {
    return new InkWell(
        onTap: () {
          this.onPressed({'query': item['query'], 'destination': item});
        },
        onLongPress: () {
          this.onLongPressed({'poi': item, "index": index});
        },
        child: buildThumbnailItem(context, index, item, Colors.black));
  }

  Container buildThumbnailItem(
      BuildContext context, int index, item, Color fontColor) {
    final size = (MediaQuery.of(context).size.width / 4) - 17.5;
    return Container(
        //height:210.0,
        margin: EdgeInsets.only(left: 0.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  margin: index != items.length - 1
                      ? EdgeInsets.only(right: 10)
                      : EdgeInsets.only(right: 0),
                  child: Center(
                      child: Container(
                          width: size,
                          height: size,
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
                                left: 0,
                                child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.0),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    width: size,
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
