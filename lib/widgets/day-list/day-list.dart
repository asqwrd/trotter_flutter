import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/auth.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';

class DayList extends StatefulWidget {
  final String2VoidFunc onPressed;
  final Function(dynamic) onLongPressed;
  final Function(dynamic) onCommentPressed;
  final Function(dynamic) onDescriptionAdded;
  final Function(dynamic) onRefreshImage;
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
  final bool showTutorial;
  final bool tabs;
  final bool visited;
  final bool showTimeSpent;
  final bool showDescriptions;
  final bool public;
  final bool editable;
  final PanelController panelController;

  //passing props in react style
  DayList(
      {this.onPressed,
      this.onLongPressed,
      this.showDescriptions,
      this.onCommentPressed,
      this.onRefreshImage,
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
      this.showTutorial,
      this.tabs,
      this.public,
      this.editable,
      this.visited,
      this.showTimeSpent,
      this.onToggleVisited,
      this.panelController,
      this.onDescriptionAdded,
      this.startLocation});

  DayListState createState() => DayListState(
      onPressed: this.onPressed,
      onLongPressed: this.onLongPressed,
      onCommentPressed: this.onCommentPressed,
      onRefreshImage: this.onRefreshImage,
      showDescriptions: this.showDescriptions,
      items: this.items,
      day: this.day,
      ownerId: this.ownerId,
      callback: this.callback,
      color: this.color,
      linkedItinerary: this.linkedItinerary,
      controller: this.controller,
      physics: this.physics,
      height: this.height,
      header: this.header,
      subHeader: this.subHeader,
      comments: this.comments,
      showTutorial: this.showTutorial,
      tabs: this.tabs,
      visited: this.visited,
      editable: this.editable,
      showTimeSpent: this.showTimeSpent,
      onDescriptionAdded: this.onDescriptionAdded,
      onToggleVisited: this.onToggleVisited,
      panelController: this.panelController,
      public: this.public,
      startLocation: this.startLocation);
}

class DayListState extends State<DayList> {
  final String2VoidFunc onPressed;
  final Function(dynamic) onLongPressed;
  final Function(dynamic) onCommentPressed;
  final Function(dynamic) onDescriptionAdded;
  final Function(dynamic) onToggleVisited;
  final Function(dynamic) onRefreshImage;
  final Color color;
  final List<dynamic> items;
  final Function(String) callback;
  final double height;
  final ScrollController controller;
  final PanelController panelController;
  final ScrollPhysics physics;
  final dynamic startLocation;
  final String ownerId;
  @required
  final String header;
  final int day;
  final String subHeader;
  final bool comments;
  final bool showDescriptions;
  final bool public;
  final bool editable;
  final dynamic linkedItinerary;
  final bool showTutorial;
  final bool tabs;
  final bool visited;
  final bool showTimeSpent;
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();
  GlobalKey _four = GlobalKey();
  bool showLastTutrial = true;

  //passing props in react style
  DayListState(
      {this.onPressed,
      this.onLongPressed,
      this.onCommentPressed,
      this.showDescriptions,
      this.onDescriptionAdded,
      this.onRefreshImage,
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
      this.showTutorial,
      this.tabs,
      this.public,
      this.visited,
      this.editable,
      this.showTimeSpent,
      this.onToggleVisited,
      this.panelController,
      this.startLocation});

  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String cacheData = prefs.getString('dayListShowCaseFirst') ?? null;
      if (cacheData == null && this.showTutorial == true) {
        ShowCaseWidget.of(context).startShowCase([_one, _two]);
        await prefs.setString('dayListShowCaseFirst', "true");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String cacheData = prefs.getString('dayListShowCasePoi') ?? null;
      final String cacheDataUncheck =
          prefs.getString('dayListShowCaseVisited') ?? null;
      if (cacheData == null &&
          panelController != null &&
          panelController.isPanelOpen &&
          this.showTutorial == true) {
        ShowCaseWidget.of(context).startShowCase([_three]);
        await prefs.setString('dayListShowCasePoi', "true");
      }

      if (cacheDataUncheck == null && this.visited == true) {
        ShowCaseWidget.of(context).startShowCase([_four]);
        await prefs.setString('dayListShowCaseVisited', "true");
      }
    });
    return buildTimeLine(context, widget.items);
  }

  Widget buildEmptyUI(BuildContext context) {
    return Stack(children: <Widget>[
      Center(
          child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: ListView(
                controller: this.controller,
                shrinkWrap: true,
                primary: false,
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
                  this.visited != true && this.public == false
                      ? AutoSizeText(
                          'Lets find some things to do',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              color: color,
                              fontWeight: FontWeight.w300),
                        )
                      : this.public == false
                          ? AutoSizeText(
                              'All the places you have visited for the day',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: color,
                                  fontWeight: FontWeight.w300),
                            )
                          : AutoSizeText(
                              'Nothing done on this day',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: color,
                                  fontWeight: FontWeight.w300),
                            ),
                  SizedBox(height: 10),
                  this.visited != true && this.public == false
                      ? AutoSizeText(
                          'Tap the drop point icon at the top to search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: color,
                              fontWeight: FontWeight.w300),
                        )
                      : this.public == false
                          ? AutoSizeText(
                              'Places you mark as visited will appear here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: color,
                                  fontWeight: FontWeight.w300),
                            )
                          : AutoSizeText(
                              '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
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
    var noLinklength = items.length;
    var itineraryItems;
    var linkItineraryPosition = '';
    if (this.linkedItinerary != null &&
        this.day >= this.linkedItinerary['start_day'] &&
        this.day + 1 <
            (this.linkedItinerary['number_of_days'] +
                this.linkedItinerary['start_day'])) {
      itineraryItems = [...items, this.linkedItinerary];
      linkItineraryPosition = 'bottom';
    } else if (this.linkedItinerary != null &&
        this.day + 1 ==
            (this.linkedItinerary['number_of_days'] +
                this.linkedItinerary['start_day'])) {
      itineraryItems = [this.linkedItinerary, ...items];
      linkItineraryPosition = 'top';
    } else {
      itineraryItems = items;
    }

    return Container(
        height: this.height ?? this.height,
        margin: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
        decoration: BoxDecoration(color: Colors.transparent),
        child: ListView.separated(
          controller: this.controller ?? this.controller,
          physics: this.physics ?? this.physics,
          separatorBuilder: (BuildContext serperatorContext, int index) =>
              Container(
                  margin: EdgeInsets.only(left: 80, bottom: 30, top: 15),
                  child: Divider(color: Color.fromRGBO(0, 0, 0, 0.3))),
          itemCount: itineraryItems.length,
          itemBuilder: (BuildContext context, int index) {
            if (linkItineraryPosition == 'bottom' &&
                index == itineraryItems.length - 1) {
              final destination = this.linkedItinerary['destination'];
              return buildLinkedItinerary(context, destination, index);
            } else if (linkItineraryPosition == 'top' && index == 0) {
              final destination = this.linkedItinerary['destination'];
              return buildLinkedItinerary(context, destination, index);
            } else if (noLinklength == 0) {
              final destination = this.linkedItinerary['destination'];
              return buildLinkedItinerary(context, destination, index);
            }
            final store = Provider.of<TrotterStore>(context);

            var color = itineraryItems[index]['color'] != null &&
                    itineraryItems[index]['color'].isEmpty == false
                ? Color(hexStringToHexInt(itineraryItems[index]['color']))
                : this.color;
            var poi = itineraryItems[index]['poi'];
            var item = itineraryItems[index];
            List<dynamic> travelerDescription = item['traveler_descriptions'];
            var indexDes = store.currentUser != null
                ? travelerDescription.indexWhere((element) {
                    return element['user']['uid'] == store.currentUser.uid;
                  })
                : null;
            var justAdded = itineraryItems[index]['justAdded'];
            var travelTime = itineraryItems[index]['travel'];
            var prevIndex = index - 1;
            var from = this.startLocation != null
                ? this.startLocation['name']
                : 'City Center';

            if (prevIndex >= 0 && linkItineraryPosition != 'top') {
              from = itineraryItems[prevIndex]['poi']['name'];
            } else if (prevIndex >= 1 && linkItineraryPosition == 'top') {
              from = itineraryItems[prevIndex]['poi']['name'];
            }

            var time = itineraryItems[index]['travel']['duration']['text'];
            var timeSpent = item['time'];
            var timeUnit = timeSpent['unit'].toString();
            var timeValue = timeSpent['value'].toString();
            var unit = timeUnit;
            if (timeValue.isNotEmpty &&
                double.parse(timeValue) == 1 &&
                timeUnit.endsWith('s')) {
              unit = timeUnit.substring(0, timeUnit.length - 1);
            } else if (timeValue.isNotEmpty &&
                double.parse(timeValue) != 1 &&
                timeUnit.endsWith('s') == false) {
              unit = '${timeUnit}s';
            }

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
                    // margin: EdgeInsets.symmetric(vertical: 15),
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
                                      this.showTutorial == true &&
                                              index == 0 &&
                                              this.visited != true
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
                                              key: _one,
                                              child: Icon(Icons.place,
                                                  color: fontContrast(color),
                                                  size: 20))
                                          : this.showTutorial == true &&
                                                  index == 0 &&
                                                  this.visited == true
                                              ? Showcase.withWidget(
                                                  shapeBorder:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                  width: 250,
                                                  height: 50,
                                                  container: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Container(
                                                          width: 250,
                                                          child: Text(
                                                            'Tap this button to unmark a place as visited',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                            maxLines: 3,
                                                          ))
                                                    ],
                                                  ),
                                                  key: _four,
                                                  child: Icon(Icons.check,
                                                      color:
                                                          fontContrast(color),
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
                          widget.comments != null && widget.comments == true
                              ? this.showTutorial == true && index == 0
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
                                      key: _two,
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
                                                '${travelTime['distance']['text']} from $from \nTravel time is $time',
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
                                                    : Container(
                                                        margin: EdgeInsets.only(
                                                            top: 8),
                                                        child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Container(
                                                                  constraints: BoxConstraints(
                                                                      maxWidth: justAdded == false
                                                                          ? MediaQuery.of(context).size.width -
                                                                              105
                                                                          : MediaQuery.of(context).size.width -
                                                                              170,
                                                                      minWidth:
                                                                          50),
                                                                  child: AutoSizeText(
                                                                      poi[
                                                                          'name'],
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        color: this.visited == false ||
                                                                                this.visited == null
                                                                            ? Colors.black
                                                                            : color,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ))),
                                                              justAdded == true
                                                                  ? AutoSizeText(
                                                                      ' - just added',
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            color,
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                      ))
                                                                  : Container()
                                                            ])),
                                                this.visited == true
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            bottom: 3, top: 2),
                                                        child: AutoSizeText(
                                                            timeSpent['unit'].toString().isEmpty == false
                                                                ? 'You were here for ${timeSpent['value']} $unit'
                                                                : '',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight: FontWeight
                                                                    .w300)))
                                                    : this.showTimeSpent == true
                                                        ? Container(
                                                            margin: EdgeInsets.only(
                                                                bottom: 3,
                                                                top: 2),
                                                            child: AutoSizeText(
                                                                timeSpent['unit'].toString().isEmpty == false
                                                                    ? 'Suggested time to spend here ${new HtmlUnescape().convert('&bull;')} ${timeSpent['value']} $unit'
                                                                    : 'Suggested time to spend here ${new HtmlUnescape().convert('&bull;')} Not given',
                                                                textAlign: TextAlign.left,
                                                                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w400)))
                                                        : Container(),
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
                                                            top: 2,
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
                                                    : Container(),
                                                (this.editable == true &&
                                                        travelerDescription
                                                                .length ==
                                                            0 &&
                                                        this.visited == true)
                                                    ? renderEditButton(
                                                        context, poi, item)
                                                    : this.visited == true ||
                                                            this.showDescriptions ==
                                                                true
                                                        ? Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                107,
                                                            child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  indexDes != null &&
                                                                          indexDes <
                                                                              0 &&
                                                                          this.editable ==
                                                                              true
                                                                      ? renderEditButton(
                                                                          context,
                                                                          poi,
                                                                          item)
                                                                      : Container(),
                                                                  ListView
                                                                      .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        NeverScrollableScrollPhysics(),
                                                                    itemCount:
                                                                        travelerDescription
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      final user =
                                                                          TrotterUser.fromJson(travelerDescription[index]
                                                                              [
                                                                              'user']);
                                                                      final description =
                                                                          travelerDescription[index]
                                                                              [
                                                                              'description'];
                                                                      return ListTile(
                                                                          onTap:
                                                                              () async {
                                                                            if (this.editable ==
                                                                                true) {
                                                                              await onDescriptionModal(context, description, poi, item);
                                                                            }
                                                                          },
                                                                          leading: ClipPath(
                                                                              clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                                                                              child: CircleAvatar(
                                                                                child: TrotterImage(
                                                                                  imageUrl: user.photoUrl,
                                                                                ),
                                                                              )),
                                                                          title: AutoSizeText(store.currentUser != null && store.currentUser.uid == user.uid ? "Your thoughts" : '${user.displayName}\'s thoughts'),
                                                                          subtitle: AutoSizeText(description, style: TextStyle(fontSize: 13)));
                                                                    },
                                                                  )
                                                                ]))
                                                        : Container()
                                              ],
                                            )
                                          ])),
                                  item['image'].isEmpty == false
                                      ? this.showTutorial == true && index == 0
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
                                              key: _three,
                                              child: renderPoiImage(
                                                  context, item, index))
                                          : renderPoiImage(context, item, index)
                                      : Container()
                                ])))
                      ],
                    )));
          },
        ));
  }

  renderEditButton(BuildContext context, poi, item) {
    if (item['description'].isNotEmpty) {
      return Container();
    }
    return InkWell(
        onTap: () async {
          await onDescriptionModal(context, '', poi, item);
        },
        child: Container(
            margin: EdgeInsets.only(top: 10),
            width: MediaQuery.of(context).size.width - 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black.withOpacity(0.05),
            ),
            child: ListTile(
                title: AutoSizeText(
              "Tap here to describe your experience at ${poi['name']}",
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 15),
            ))));
  }

  Future onDescriptionModal(
      BuildContext context, String description, poi, item) async {
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) {
              return DescriptionModal(
                  description: description, poiName: poi['name']);
            }));
    if (res != null && res["description"] != null) {
      this.onDescriptionAdded(
          {"item": item, "description": res['description']});
    }
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
                                                      107,
                                                  child: AutoSizeText(
                                                      destination[
                                                          'destination_name'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ))),
                                            ]),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                107,
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
                              ? renderDestinationImage(context, destination)
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
                style: TextStyle(fontSize: 18),
              ),
              SvgPicture.asset(
                "images/comment-icon.svg",
                width: 25,
                height: 25,
                color: Colors.black,
              )
            ])));
  }

  Card renderPoiImage(BuildContext context, item, int index) {
    return Card(
        //opacity: 1,
        elevation: 1,
        margin: EdgeInsets.only(top: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width - 107,
          child: ClipPath(
              clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: item['image'] != null
                  ? Stack(fit: StackFit.expand, children: <Widget>[
                      TrotterImage(
                        imageUrl: item['image'],
                        enableRefresh: true,
                        placeholder: Center(
                            child: IconButton(
                                  icon: Icon(Icons.refresh),
                                  onPressed: () {
                                    this.onRefreshImage({
                                      "index": index,
                                      "poi": item['poi'],
                                      "itineraryItemId": item['id']
                                    });
                                  },
                                )),
                        loadingWidgetBuilder: (BuildContext context) => Center(
                            child: RefreshProgressIndicator(
                          backgroundColor: Colors.white,
                        )),
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
                                      child: TrotterImage(
                                    imageUrl: item['added_by_full']['photoUrl'],
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
                      TrotterImage(
                        imageUrl: item['image'],
                        placeholder: Icon(Icons.refresh),
                        loadingWidgetBuilder: (BuildContext context) => Center(
                            child: RefreshProgressIndicator(
                          backgroundColor: Colors.white,
                        )),
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

class DescriptionModal extends StatefulWidget {
  final String description;
  final String poiName;

  DescriptionModal({this.description, this.poiName});

  DescriptionModalState createState() => DescriptionModalState(
      description: this.description, poiName: this.poiName);
}

class DescriptionModalState extends State<DescriptionModal> {
  final String description;
  final String poiName;
  final TextEditingController controller = new TextEditingController();

  DescriptionModalState({this.description, this.poiName});

  void initState() {
    super.initState();
    controller.text = description;
  }

  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                //color: color,
                height: 80,
                child: TrotterAppBar(
                    title: 'About $poiName',
                    back: true,
                    onPush: () {},
                    showSearch: false,
                    brightness: Brightness.light,
                    color: Colors.white)),
            Flexible(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.only(top: 40),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: controller,
                          maxLines: 8,
                          maxLengthEnforced: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(20.0),
                            //fillColor: Colors.blueGrey.withOpacity(0.5),
                            filled: true,
                            errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide:
                                    BorderSide(width: 1.0, color: Colors.red)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide:
                                    BorderSide(width: 1.0, color: Colors.red)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(
                                    width: 0.0, color: Colors.transparent)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(
                                    width: 0.0, color: Colors.transparent)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                borderSide: BorderSide(
                                    width: 0.0, color: Colors.transparent)),
                            hintText: 'Write about your experience...',
                            hintStyle: TextStyle(fontSize: 13),
                          ),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 20),
                                width: double.infinity,
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(100.0),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  color: Colors.blueGrey,
                                  onPressed: () async {
                                    // Validate will return true if the form is valid, or false if
                                    // the form is invalid.
                                    Navigator.pop(context,
                                        {"description": this.controller.text});
                                  },
                                  child: AutoSizeText('Save',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white)),
                                ))),
                      ],
                    )))
          ],
        ));
  }
}
