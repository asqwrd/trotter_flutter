import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:sliding_panel/sliding_panel.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/day-list/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';

class Day extends StatefulWidget {
  final String dayId;
  final String itineraryId;
  final String linkedItinerary;
  final ValueChanged<dynamic> onPush;
  Day(
      {Key key,
      @required this.dayId,
      this.itineraryId,
      this.linkedItinerary,
      this.onPush})
      : super(key: key);
  @override
  DayState createState() => new DayState(
      dayId: this.dayId,
      itineraryId: this.itineraryId,
      linkedItinerary: this.linkedItinerary,
      onPush: this.onPush);
}

class DayState extends State<Day> {
  final String dayId;
  final String itineraryId;
  final String linkedItinerary;
  final ValueChanged<dynamic> onPush;
  Color color = Colors.blueGrey;
  String destinationName = '';
  dynamic destination;
  String destinationId;
  List<dynamic> itineraryItems = [];
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  bool imageLoading = true;
  String image;
  String itineraryName;
  dynamic day;
  bool shadow = false;
  List<dynamic> days;

  Future<DayData> data;

  @override
  void initState() {
    super.initState();
    data = fetchDay(this.itineraryId, this.dayId);
    data.then((data) {
      if (data.error == null) {
        setState(() {
          this.color = Color(hexStringToHexInt(data.color));
          this.itineraryName = data.itinerary['name'];
          this.destinationName = data.destination['name'];
          this.destination = data.destination;
          this.destinationId = data.destination['id'].toString();
          this.itineraryItems = data.day['itinerary_items'].sublist(1);
          this.image = data.destination['image'];
          this.loading = false;
          this.day = data.day;
          this.days = data.itinerary['days'];
        });
      } else {
        setState(() {
          this.errorUi = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  DayState({this.dayId, this.itineraryId, this.linkedItinerary, this.onPush});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;

    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingPanel(
              snapPanel: true,
              initialState: this.errorUi == true
                  ? InitialPanelState.expanded
                  : InitialPanelState.closed,
              size: PanelSize(closedHeight: .45, expandedHeight: .835),
              isDraggable: true,
              autoSizing: PanelAutoSizing(),
              decoration: PanelDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              parallaxSlideAmount: .5,
              backdropConfig: BackdropConfig(
                  dragFromBody: true,
                  shadowColor: color,
                  opacity: 1,
                  enabled: true),
              panelController: _pc,
              content: PanelContent(
                headerWidget: PanelHeaderWidget(
                  headerContent: Container(
                      decoration: BoxDecoration(
                          boxShadow: this.shadow
                              ? <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.black.withOpacity(.2),
                                      blurRadius: 10.0,
                                      offset: Offset(0.0, 0.75))
                                ]
                              : [],
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Center(
                              child: Container(
                            width: 30,
                            height: 5,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0))),
                          )),
                          this.loading
                              ? Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 10, bottom: 0),
                                  child: AutoSizeText(
                                    'Loading day...',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: 10, bottom: 0),
                                  child: Column(children: <Widget>[
                                    AutoSizeText(
                                      '${ordinalNumber(day['day'] + 1)} day',
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ]),
                                ),
                          this.loading == false
                              ? Center(
                                  child: DayListTabs(
                                  days: this.days,
                                  activeDay: this.dayId,
                                  activeColor: color,
                                  onSelected: (day, index) {
                                    print(day);
                                    onPush({
                                      'itineraryId': this.itineraryId,
                                      'dayId': day['id'].toString(),
                                      "linkedItinerary": this.days[index]
                                          ['linked_itinerary'],
                                      'level': 'itinerary/day'
                                    });
                                  },
                                ))
                              : Container()
                        ],
                      )),
                ),
                panelContent: (context, _sc) {
                  return Center(
                      child: Scaffold(
                          backgroundColor: Colors.transparent,
                          body: FutureBuilder(
                              future: data,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return _buildLoadingBody(context, _sc);
                                }
                                if (snapshot.hasData &&
                                    snapshot.data.error == null) {
                                  return RenderWidget(
                                      onScroll: onScroll,
                                      scrollController: _sc,
                                      builder: (context, scrollController,
                                              asynSnapshot) =>
                                          _buildLoadedBody(context, snapshot,
                                              scrollController));
                                } else if (snapshot.hasData &&
                                    snapshot.data.error != null) {
                                  return SingleChildScrollView(
                                      controller: _sc,
                                      child: ErrorContainer(
                                        color: Color.fromRGBO(106, 154, 168, 1),
                                        onRetry: () {
                                          setState(() {
                                            data = fetchDay(
                                                this.itineraryId, this.dayId);
                                            data.then((data) {
                                              if (data.error == null) {
                                                setState(() {
                                                  this.color = Color(
                                                      hexStringToHexInt(
                                                          data.color));
                                                  this.destinationName =
                                                      data.destination['name'];
                                                  this.days =
                                                      data.itinerary['days'];
                                                  this.day = data.day;
                                                  this.destination =
                                                      data.destination;
                                                  this.destinationId = data
                                                      .destination['id']
                                                      .toString();
                                                  this.itineraryItems = data
                                                      .day['itinerary_items']
                                                      .sublist(1);
                                                });
                                              }
                                            });
                                          });
                                        },
                                      ));
                                }
                                return _buildLoadingBody(context, _sc);
                              })));
                },
                bodyContent: Container(
                    height: _bodyHeight,
                    child: Stack(children: <Widget>[
                      Positioned(
                          width: MediaQuery.of(context).size.width,
                          height: _bodyHeight,
                          top: 0,
                          left: 0,
                          child: this.image != null
                              ? TransitionToImage(
                                  image: AdvancedNetworkImage(
                                    this.image,
                                    useDiskCache: true,
                                    cacheRule: CacheRule(
                                        maxAge: const Duration(days: 7)),
                                  ),
                                  loadingWidgetBuilder: (BuildContext context,
                                          double progress, test) =>
                                      Container(),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  placeholder: const Icon(Icons.refresh),
                                  enableRefresh: true,
                                  loadedCallback: () async {
                                    await Future.delayed(Duration(seconds: 2));
                                    setState(() {
                                      this.imageLoading = false;
                                    });
                                  },
                                  loadFailedCallback: () async {
                                    await Future.delayed(Duration(seconds: 2));
                                    setState(() {
                                      this.imageLoading = false;
                                    });
                                  },
                                )
                              : Container()),
                      Positioned.fill(
                        top: 0,
                        left: 0,
                        child: Container(
                            color: this.imageLoading
                                ? this.color
                                : this.color.withOpacity(.3)),
                      ),
                      Positioned(
                          left: 0,
                          top: (MediaQuery.of(context).size.height / 2) - 110,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                AutoSizeText('$destinationName',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w300)),
                              ])),
                      this.image == null || this.imageLoading == true
                          ? Positioned.fill(
                              top: -((_bodyHeight / 2) + 100),
                              // left: -50,
                              child: Center(
                                  child: Container(
                                      width: 250,
                                      child: TrotterLoading(
                                          file: 'assets/globe.flr',
                                          animation: 'flight',
                                          color: Colors.transparent))))
                          : Container()
                    ])),
              ))),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              loading: loading,
              onPush: onPush,
              color: color,
              title: this.itineraryName,
              back: true)),
    ]);
  }

  void onScroll(offset) {
    if (offset > 0) {
      setState(() {
        this.shadow = true;
      });
    } else {
      setState(() {
        this.shadow = false;
      });
    }
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, ScrollController _sc) {
    var day = snapshot.data.day;
    var color = Color(hexStringToHexInt(snapshot.data.color));

    return Stack(fit: StackFit.expand, children: <Widget>[
      DayList(
        header: '${ordinalNumber(day['day'] + 1)} day',
        controller: _sc,
        items: itineraryItems,
        color: color,
        onLongPressed: (data) {},
        onPressed: (data) {
          if (data['itinerary'] != null) {
            onPush({'id': data['itinerary']['id'], 'level': 'itinerary'});
          } else {
            onPush({
              'id': data['id'],
              'level': 'poi',
              'google_place': data['google_place']
            });
          }
        },
      ),
    ]);
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt, ScrollController _sc) {
    return Stack(fit: StackFit.expand, children: <Widget>[
      DayListLoading(controller: _sc),
    ]);
  }
}
