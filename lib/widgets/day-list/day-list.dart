import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:trotter_flutter/utils/index.dart';

class DayList extends StatelessWidget {
  final String2VoidFunc onPressed;
  final Function(dynamic) onLongPressed;
  final Function(dynamic) onCommentPressed;
  final Color color;
  final List<dynamic> items;
  final Function(String) callback;
  final double height;
  final ScrollController controller;
  final ScrollPhysics physics;
  final dynamic startLocation;
  final String ownerId;
  @required
  final String header;
  final String subHeader;
  final bool comments;
  final List<GlobalKey> showCaseKeys;

  //passing props in react style
  DayList(
      {this.onPressed,
      this.onLongPressed,
      this.onCommentPressed,
      this.items,
      this.ownerId,
      this.callback,
      this.color,
      this.controller,
      this.physics,
      this.height,
      this.header,
      this.subHeader,
      this.comments,
      this.showCaseKeys,
      this.startLocation});

  @override
  Widget build(BuildContext context) {
    return buildTimeLine(context, this.items);
  }

  Widget buildEmptyUI(BuildContext context) {
    return Stack(children: <Widget>[
      Center(
          child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2,
                      foregroundDecoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(.2),
                              Colors.white.withOpacity(1),
                              Colors.white.withOpacity(1),
                            ],
                            center: Alignment.center,
                            focal: Alignment.center,
                            radius: 1,
                          ),
                          borderRadius: BorderRadius.circular(130)),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('images/day-empty.jpg'),
                              fit: BoxFit.contain),
                          borderRadius: BorderRadius.circular(130))),
                  AutoSizeText(
                    'Lets find some things to do',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25,
                        color: color,
                        fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 10),
                  AutoSizeText(
                    'Tap the drop point icon at the top to search',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        color: color,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ))),
    ]);
  }

  Widget buildTimeLine(BuildContext context, List<dynamic> items) {
    if (items.length == 0) {
      return buildEmptyUI(context);
    }
    var itineraryItems = ['', '', ...items];
    return Container(
        height: this.height ?? this.height,
        margin: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
        decoration: BoxDecoration(color: Colors.transparent),
        child: ListView.separated(
          controller: this.controller ?? this.controller,
          physics: this.physics ?? this.physics,
          separatorBuilder: (BuildContext serperatorContext, int index) =>
              index > 1
                  ? Container(
                      margin: EdgeInsets.only(left: 80, bottom: 20, top: 0),
                      child: Divider(color: Color.fromRGBO(0, 0, 0, 0.3)))
                  : Container(),
          itemCount: itineraryItems.length,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Center(
                  child: Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
              ));
            }

            if (index == 1) {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 10, bottom: 40),
                child: Column(children: <Widget>[
                  AutoSizeText(
                    '${this.header}',
                    style: TextStyle(fontSize: 25),
                  ),
                  this.subHeader != null
                      ? AutoSizeText(
                          '${this.subHeader}',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w300),
                        )
                      : Container()
                ]),
              );
            }
            var color = itineraryItems[index]['color'].isEmpty == false
                ? Color(hexStringToHexInt(itineraryItems[index]['color']))
                : this.color;
            var poi = itineraryItems[index]['poi'];
            var item = itineraryItems[index];
            var justAdded = itineraryItems[index]['justAdded'];
            var travelTime = itineraryItems[index]['travel'];
            var prevIndex = index - 1;
            var from = this.startLocation != null
                ? this.startLocation['name']
                : 'City Center';
            // value is 2 because first 2 values in the array are empty strings
            if (prevIndex >= 2) {
              from = itineraryItems[prevIndex]['poi']['name'];
            }

            var time = itineraryItems[index]['travel']['duration']['text'];
            var totalComments = itineraryItems[index]['total_comments'] == 0
                ? ''
                : itineraryItems[index]['total_comments'] < 10
                    ? itineraryItems[index]['total_comments']
                    : '9+';

            return InkWell(
                onLongPress: () {
                  this.onLongPressed(itineraryItems[index]);
                },
                onTap: () {
                  this.onPressed(poi);
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    //height: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Column(children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(100)),
                            child: Align(
                                alignment: Alignment.topCenter,
                                child: Column(children: <Widget>[
                                  Icon(Icons.access_time,
                                      color: fontContrast(color), size: 20),
                                ])),
                          ),
                          this.comments != null && this.comments == true
                              ? Showcase(
                                  key: this.showCaseKeys[0],
                                  descTextStyle: TextStyle(),
                                  description:
                                      'Click to write comments for itinerary items',
                                  child: InkWell(
                                      borderRadius: BorderRadius.circular(100),
                                      onTap: () {
                                        this.onCommentPressed(
                                            itineraryItems[index]);
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Row(children: <Widget>[
                                            AutoSizeText(
                                              '$totalComments',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            SvgPicture.asset(
                                              "images/comment-icon.svg",
                                              width: 25,
                                              height: 25,
                                              color: Colors.black,
                                            )
                                          ]))))
                              : Container()
                        ]),
                        Flexible(
                            child: Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 0, bottom: 20),
                                child: Column(children: <Widget>[
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                          //color: color,
                                          //padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(
                                              top: 10, bottom: 20),
                                          child: AutoSizeText(
                                            '${travelTime['distance']['text']} away from $from \nTravel time is $time',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: color,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                height: 1.1),
                                          ))),
                                  Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                poi == null
                                                    ? Container()
                                                    : Row(
                                                        //crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: <Widget>[
                                                            AutoSizeText(
                                                                poi['name'],
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                )),
                                                            justAdded == true
                                                                ? AutoSizeText(
                                                                    ' - just added',
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          color,
                                                                      fontSize:
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ))
                                                                : Container()
                                                          ]),
                                                poi == null
                                                    ? Container()
                                                    : poi['tags'] != null
                                                        ? Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                176,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 5),
                                                            child: AutoSizeText(
                                                                tagsToString(poi[
                                                                    'tags']),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300,
                                                                )))
                                                        : Container(),
                                                item['description'].isEmpty ==
                                                        false
                                                    ? Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            105,
                                                        padding:
                                                            EdgeInsets.all(0),
                                                        margin: EdgeInsets.only(
                                                            top: 10,
                                                            left: 0,
                                                            right: 0,
                                                            bottom: 0),
                                                        child: AutoSizeText(
                                                          item['description'],
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              height: 1.3),
                                                        ))
                                                    : Container()
                                              ],
                                            )
                                          ])),
                                  item['image'].isEmpty == false
                                      ? Showcase(
                                          key: this.showCaseKeys[1],
                                          descTextStyle: TextStyle(),
                                          description:
                                              'Click to view details about itinerary item',
                                          child: Card(
                                              //opacity: 1,
                                              elevation: 1,
                                              margin: EdgeInsets.only(top: 15),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                              child: Container(
                                                height: 200,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    105,
                                                child: ClipPath(
                                                    clipper: ShapeBorderClipper(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15))),
                                                    child: item['image'] != null
                                                        ? Stack(
                                                            fit:
                                                                StackFit.expand,
                                                            children: <Widget>[
                                                                TransitionToImage(
                                                                  image:
                                                                      AdvancedNetworkImage(
                                                                    item[
                                                                        'image'],
                                                                    useDiskCache:
                                                                        true,
                                                                    cacheRule: CacheRule(
                                                                        maxAge: const Duration(
                                                                            days:
                                                                                7)),
                                                                  ),
                                                                  loadingWidgetBuilder: (BuildContext
                                                                              context,
                                                                          double
                                                                              progress,
                                                                          test) =>
                                                                      Center(
                                                                          child:
                                                                              RefreshProgressIndicator(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                  )),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  placeholder:
                                                                      const Icon(
                                                                          Icons
                                                                              .refresh),
                                                                  enableRefresh:
                                                                      true,
                                                                ),
                                                                item['added_by_full'] !=
                                                                        null
                                                                    ? Positioned(
                                                                        width:
                                                                            40,
                                                                        height:
                                                                            40,
                                                                        bottom:
                                                                            10,
                                                                        right:
                                                                            10,
                                                                        child: Container(
                                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), border: Border.all(width: 2, color: Colors.white)),
                                                                            child: CircleAvatar(
                                                                                backgroundImage: AdvancedNetworkImage(
                                                                              item['added_by_full']['photoUrl'],
                                                                              useDiskCache: true,
                                                                              cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                                                                            ))),
                                                                      )
                                                                    : Container()
                                                              ])
                                                        : Container(
                                                            decoration:
                                                                BoxDecoration(
                                                            image: DecorationImage(
                                                                image: AssetImage(
                                                                    'images/placeholder.png'),
                                                                fit: BoxFit
                                                                    .cover),
                                                          ))),
                                              )))
                                      : Container()
                                ])))
                      ],
                    )));
          },
        ));
  }
}
