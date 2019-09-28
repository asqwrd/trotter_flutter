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
  final Function(dynamic) onToggleVisited;
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
  final int day;
  final String subHeader;
  final bool comments;
  final dynamic linkedItinerary;
  final List<GlobalKey> showCaseKeys;
  final bool tabs;
  final bool visited;

  //passing props in react style
  DayList(
      {this.onPressed,
      this.onLongPressed,
      this.onCommentPressed,
      this.items,
      this.day,
      this.ownerId,
      this.callback,
      this.color,
      this.linkedItinerary,
      this.controller,
      this.physics,
      this.height,
      this.header,
      this.subHeader,
      this.comments,
      this.showCaseKeys,
      this.tabs,
      this.visited,
      this.onToggleVisited,
      this.startLocation});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
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
                  this.visited != true
                      ? AutoSizeText(
                          'Lets find some things to do',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              color: color,
                              fontWeight: FontWeight.w300),
                        )
                      : AutoSizeText(
                          'All the places you have visited for the day',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              color: color,
                              fontWeight: FontWeight.w300),
                        ),
                  SizedBox(height: 10),
                  this.visited != true
                      ? AutoSizeText(
                          'Tap the drop point icon at the top to search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: color,
                              fontWeight: FontWeight.w300),
                        )
                      : AutoSizeText(
                          'Places you mark as visited will appear here',
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
    if (items.length == 0 && this.linkedItinerary == null) {
      return buildEmptyUI(context);
    }
    var itineraryItems;
    var linkItineraryPosition = '';
    if (this.linkedItinerary != null &&
        this.day >= this.linkedItinerary['start_day'] &&
        this.day + 1 <
            (this.linkedItinerary['number_of_days'] +
                this.linkedItinerary['start_day'])) {
      itineraryItems = ['', '', ...items, this.linkedItinerary];
      linkItineraryPosition = 'bottom';
    } else if (this.linkedItinerary != null &&
        this.day + 1 ==
            (this.linkedItinerary['number_of_days'] +
                this.linkedItinerary['start_day'])) {
      itineraryItems = ['', '', this.linkedItinerary, ...items];
      linkItineraryPosition = 'top';
    } else {
      itineraryItems = ['', '', ...items];
    }

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
            if (index == 0 && this.tabs != true) {
              return Center(
                  child: Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
              ));
            } else if (index == 0 && this.tabs == true) {
              return Container();
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

            if (linkItineraryPosition == 'bottom' &&
                index == itineraryItems.length - 1) {
              final destination = this.linkedItinerary['destination'];
              return buildLinkedItinerary(context, destination, index);
            }
            if (linkItineraryPosition == 'top' && index == 2) {
              final destination = this.linkedItinerary['destination'];
              return buildLinkedItinerary(context, destination, index);
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
            if (prevIndex >= 2 && linkItineraryPosition != 'top') {
              from = itineraryItems[prevIndex]['poi']['name'];
            } else if (prevIndex >= 3 && linkItineraryPosition == 'top') {
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
                          InkWell(
                              customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              radius: 100,
                              onTap: () {
                                onToggleVisited(itineraryItems[index]);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Column(children: <Widget>[
                                      this.showCaseKeys != null && index == 2
                                          ? Showcase.withWidget(
                                              shapeBorder:
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15)),
                                              width: 250,
                                              height: 50,
                                              container: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                      width: 250,
                                                      child: Text(
                                                        'Tap this button to set a place to visited after you have gone there.',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        maxLines: 3,
                                                      ))
                                                ],
                                              ),
                                              key: this.showCaseKeys[0],
                                              child: Icon(
                                                  this.visited == false ||
                                                          this.visited == null
                                                      ? Icons.place
                                                      : Icons.check,
                                                  color: fontContrast(color),
                                                  size: 20))
                                          : Icon(
                                              this.visited == false ||
                                                      this.visited == null
                                                  ? Icons.place
                                                  : Icons.check,
                                              color: fontContrast(color),
                                              size: 20),
                                    ])),
                              )),
                          this.comments != null && this.comments == true
                              ? this.showCaseKeys != null && index == 2
                                  ? Showcase.withWidget(
                                      shapeBorder: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      width: 250,
                                      height: 50,
                                      container: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                              width: 250,
                                              child: Text(
                                                'Tap to open comments',
                                                style: TextStyle(
                                                    color: Colors.white),
                                                maxLines: 3,
                                              ))
                                        ],
                                      ),
                                      key: this.showCaseKeys[1],
                                      child: renderCommentIcon(
                                          itineraryItems, index, totalComments))
                                  : renderCommentIcon(
                                      itineraryItems, index, totalComments)
                              : Container()
                        ]),
                        Flexible(
                            child: Container(
                                margin: EdgeInsets.only(
                                    left: 10, right: 0, bottom: 20),
                                child: Column(children: <Widget>[
                                  this.visited == false || this.visited == null
                                      ? Align(
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
                                              )))
                                      : Container(),
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
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                            Container(
                                                                constraints: BoxConstraints(
                                                                    maxWidth: justAdded ==
                                                                            false
                                                                        ? MediaQuery.of(context).size.width -
                                                                            105
                                                                        : MediaQuery.of(context).size.width -
                                                                            170,
                                                                    minWidth:
                                                                        50),
                                                                child: AutoSizeText(
                                                                    poi['name'],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        TextStyle(
                                                                      color: this.visited == false ||
                                                                              this.visited ==
                                                                                  null
                                                                          ? Colors
                                                                              .black
                                                                          : color,
                                                                      fontSize:
                                                                          17,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ))),
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
                                      ? this.showCaseKeys != null && index == 2
                                          ? Showcase.withWidget(
                                              shapeBorder:
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15)),
                                              width: 250,
                                              height: 50,
                                              container: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                      width: 250,
                                                      child: Text(
                                                        'Tap to view details about itinerary item.\nPress and hold to bring up menu items',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                        maxLines: 3,
                                                      ))
                                                ],
                                              ),
                                              key: this.showCaseKeys[2],
                                              child:
                                                  renderPoiImage(context, item))
                                          : renderPoiImage(context, item)
                                      : Container()
                                ])))
                      ],
                    )));
          },
        ));
  }

  InkWell buildLinkedItinerary(BuildContext context, destination, int index) {
    return InkWell(
        onLongPress: () {
          // this.onLongPressed(itineraryItems[index]);
        },
        onTap: () {
          this.onPressed(this.linkedItinerary);
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
                        color: this.color,
                        borderRadius: BorderRadius.circular(100)),
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: Column(children: <Widget>[
                          Icon(Icons.flight_land,
                              color: fontContrast(this.color), size: 20),
                        ])),
                  )
                ]),
                Flexible(
                    child: Container(
                        margin: EdgeInsets.only(left: 20, right: 0, bottom: 20),
                        child: Column(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.all(0),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                            //crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      105,
                                                  child: AutoSizeText(
                                                      destination[
                                                          'destination_name'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ))),
                                            ]),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                105,
                                            padding: EdgeInsets.all(0),
                                            margin: EdgeInsets.only(
                                                top: 10,
                                                left: 0,
                                                right: 0,
                                                bottom: 0),
                                            child: AutoSizeText(
                                              'Side trip to ${destination['destination_name']} tap to view this itinerary',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w300,
                                                  height: 1.3),
                                            ))
                                      ],
                                    )
                                  ])),
                          destination['image'].isEmpty == false
                              ? this.showCaseKeys != null && index == 2
                                  ? Showcase.withWidget(
                                      shapeBorder: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      width: 250,
                                      height: 50,
                                      container: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                              width: 250,
                                              child: Text(
                                                'Tap to view details about itinerary item.\nPress and hold to bring up menu items',
                                                style: TextStyle(
                                                    color: Colors.white),
                                                maxLines: 3,
                                              ))
                                        ],
                                      ),
                                      key: this.showCaseKeys[2],
                                      child: renderDestinationImage(
                                          context, destination))
                                  : renderDestinationImage(context, destination)
                              : Container()
                        ])))
              ],
            )));
  }

  InkWell renderCommentIcon(List itineraryItems, int index, totalComments) {
    return InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () {
          this.onCommentPressed(itineraryItems[index]);
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
            ])));
  }

  Card renderPoiImage(BuildContext context, item) {
    return Card(
        //opacity: 1,
        elevation: 1,
        margin: EdgeInsets.only(top: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width - 105,
          child: ClipPath(
              clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: item['image'] != null
                  ? Stack(fit: StackFit.expand, children: <Widget>[
                      TransitionToImage(
                        image: AdvancedNetworkImage(
                          item['image'],
                          useDiskCache: true,
                          cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                        ),
                        loadingWidgetBuilder:
                            (BuildContext context, double progress, test) =>
                                Center(
                                    child: RefreshProgressIndicator(
                          backgroundColor: Colors.white,
                        )),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        placeholder: const Icon(Icons.refresh),
                        enableRefresh: true,
                      ),
                      item['added_by_full'] != null
                          ? Positioned(
                              width: 40,
                              height: 40,
                              bottom: 10,
                              right: 10,
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          width: 2, color: Colors.white)),
                                  child: CircleAvatar(
                                      backgroundImage: AdvancedNetworkImage(
                                    item['added_by_full']['photoUrl'],
                                    useDiskCache: true,
                                    cacheRule: CacheRule(
                                        maxAge: const Duration(days: 7)),
                                  ))),
                            )
                          : Container()
                    ])
                  : Container(
                      decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('images/placeholder.png'),
                          fit: BoxFit.cover),
                    ))),
        ));
  }

  Card renderDestinationImage(BuildContext context, item) {
    return Card(
        //opacity: 1,
        elevation: 1,
        margin: EdgeInsets.only(top: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width - 105,
          child: ClipPath(
              clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: item['image'] != null
                  ? Stack(fit: StackFit.expand, children: <Widget>[
                      TransitionToImage(
                        image: AdvancedNetworkImage(
                          item['image'],
                          useDiskCache: true,
                          cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                        ),
                        loadingWidgetBuilder:
                            (BuildContext context, double progress, test) =>
                                Center(
                                    child: RefreshProgressIndicator(
                          backgroundColor: Colors.white,
                        )),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        placeholder: const Icon(Icons.refresh),
                        enableRefresh: true,
                      ),
                    ])
                  : Container(
                      decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('images/placeholder.png'),
                          fit: BoxFit.cover),
                    ))),
        ));
  }
}
