import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'package:trotter_flutter/screens/itinerary/toggle-visited-modal.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/comments/index.dart';
import 'package:trotter_flutter/widgets/day-list/index.dart';
import 'package:trotter_flutter/widgets/errors/cannot-view.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:trotter_flutter/widgets/itineraries/index.dart';
import 'package:intl/intl.dart';

class DayEdit extends StatefulWidget {
  final String dayId;
  final Color color;
  final String itineraryId;
  final dynamic linkedItinerary;
  final dynamic startLocation;
  final Future2VoidFunc onPush;
  DayEdit(
      {Key key,
      @required this.dayId,
      this.startLocation,
      this.color,
      this.itineraryId,
      this.linkedItinerary,
      this.onPush})
      : super(key: key);
  @override
  DayEditState createState() => new DayEditState(
      dayId: this.dayId,
      itineraryId: this.itineraryId,
      color: this.color,
      linkedItinerary: this.linkedItinerary,
      startLocation: this.startLocation,
      onPush: this.onPush);
}

class DayEditState extends State<DayEdit> {
  final String dayId;
  final String itineraryId;
  final dynamic linkedItinerary;
  final Future2VoidFunc onPush;
  Color color = Colors.transparent;
  String destinationName;
  String destinationId;
  dynamic destination;
  dynamic startLocation;
  dynamic location;
  List<dynamic> itineraryItems = [];
  List<dynamic> visited = [];
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  String ownerId;
  String tripId;
  String itineraryName;
  dynamic currentPosition;
  int startDate;
  dynamic day;
  List<dynamic> days;
  bool imageLoading = true;

  Future<DayData> data;
  TrotterStore store;
  bool canView = true;

  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();
  GlobalKey _four = GlobalKey();
  bool shadow = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   toggleDialog(context);
    // });
    getLocationPermission().then((res) {
      data = fetchDay(this.itineraryId, this.dayId, this.startLocation, "true");
      data.then((data) {
        if (data.error == null) {
          setState(() {
            this.canView = data.itinerary['travelers']
                .any((traveler) => store.currentUser.uid == traveler);
            this.color = Color(hexStringToHexInt(data.color));
            this.itineraryName = data.itinerary['name'];
            this.days = data.itinerary['days'];
            this.ownerId = data.itinerary['owner_id'];
            this.tripId = data.itinerary['trip_id'];
            this.startDate = data.itinerary['start_date'] * 1000;
            this.destinationName = data.destination['name'];
            this.location = data.destination['location'];
            this.destination = data.destination;
            this.destinationId = data.destination['id'].toString();
            this.itineraryItems = data.day['itinerary_items'].sublist(1);
            this.visited = data.visited;
            this.day = data.day;
            this.startLocation = data.itinerary['start_location'];
            this.currentPosition = data.currentPosition;
            this.image = data.destination['image'];
            this.loading = false;
          });
        } else {
          setState(() {
            this.errorUi = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  DayEditState(
      {this.dayId,
      this.itineraryId,
      this.startLocation,
      this.onPush,
      this.color,
      this.linkedItinerary});

  @override
  Widget build(BuildContext context) {
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;
    if (store == null) {
      store = Provider.of<TrotterStore>(context);
    }

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
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        parallaxSlideAmount: .5,
        backdropConfig: BackdropConfig(
            dragFromBody: true, shadowColor: color, opacity: 1, enabled: true),
        panelController: _pc,
        content: PanelContent(
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
                              if (this.itineraryItems.length == 0 &&
                                  this.linkedItinerary == null &&
                                  _pc.currentState == PanelState.expanded) {
                                _pc.expand();
                              }
                              if (this.canView) {
                                return _buildLoadedBody(context, snapshot, _sc);
                              } else {
                                return CannotView();
                              }
                            } else if (snapshot.hasData &&
                                snapshot.data.error != null) {
                              return ListView(
                                  controller: _sc,
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    Container(
                                        height: _panelHeightOpen - 80,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ErrorContainer(
                                          color:
                                              Color.fromRGBO(106, 154, 168, 1),
                                          onRetry: () {
                                            setState(() {
                                              data = fetchDay(
                                                  this.itineraryId,
                                                  this.dayId,
                                                  this.startLocation[
                                                      'location'],
                                                  'true');
                                              data.then((data) {
                                                if (data.error == null) {
                                                  setState(() {
                                                    this.color = Color(
                                                        hexStringToHexInt(
                                                            data.color));
                                                    this.itineraryName =
                                                        data.itinerary['name'];
                                                    this.days = data.itinerary[
                                                        'itinerary']['days'];
                                                    this.ownerId = data
                                                        .itinerary['owner_id'];
                                                    this.startDate =
                                                        data.itinerary[
                                                                'start_date'] *
                                                            1000;
                                                    this.destinationName = data
                                                        .destination['name'];
                                                    this.location =
                                                        data.destination[
                                                            'location'];
                                                    this.destination =
                                                        data.destination;
                                                    this.destinationId = data
                                                        .destination['id']
                                                        .toString();
                                                    this.itineraryItems = data
                                                        .day['itinerary_items']
                                                        .sublist(1);
                                                    this.visited = data.visited;
                                                    this.startLocation =
                                                        data.itinerary[
                                                            'start_location'];
                                                    this.currentPosition =
                                                        data.currentPosition;
                                                    this.image = data
                                                        .destination['image'];
                                                    this.loading = false;
                                                  });
                                                }
                                              });
                                            });
                                          },
                                        ))
                                  ]);
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
                                cacheRule:
                                    CacheRule(maxAge: const Duration(days: 7)),
                              ),
                              loadingWidgetBuilder: (BuildContext context,
                                      double progress, test) =>
                                  Center(),
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
                            destinationName != null
                                ? AutoSizeText('$destinationName',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w300))
                                : Container(),
                          ])),
                  this.image == null || this.imageLoading
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
                ]))),
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              loading: loading,
              onPush: onPush,
              color: color,
              title: this.itineraryName,
              showSearch: false,
              actions: <Widget>[
                Container(
                    width: 58,
                    height: 58,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      onPressed: () async {
                        data = fetchDay(this.itineraryId, this.dayId,
                            this.startLocation['location'], "true");
                        setState(() {
                          this.loading = true;
                        });
                        data.then((data) {
                          if (data.error == null) {
                            setState(() {
                              this.canView = data.itinerary['travelers'].any(
                                  (traveler) =>
                                      store.currentUser.uid == traveler);
                              this.color = Color(hexStringToHexInt(data.color));
                              this.itineraryName = data.itinerary['name'];
                              this.ownerId = data.itinerary['owner_id'];
                              this.days = data.itinerary['itinerary']['days'];
                              this.tripId = data.itinerary['trip_id'];
                              this.startDate =
                                  data.itinerary['start_date'] * 1000;
                              this.destinationName = data.destination['name'];
                              this.location = data.destination['location'];
                              this.destination = data.destination;
                              this.destinationId =
                                  data.destination['id'].toString();
                              this.itineraryItems =
                                  data.day['itinerary_items'].sublist(1);
                              this.visited = data.visited;
                              this.day = data.day;
                              this.startLocation =
                                  data.itinerary['start_location'];
                              this.currentPosition = data.currentPosition;
                              this.image = data.destination['image'];
                              this.loading = false;
                            });
                          } else {
                            setState(() {
                              this.errorUi = true;
                            });
                          }
                        });
                      },
                      child: SvgPicture.asset("images/refresh_icon.svg",
                          width: 24.0,
                          height: 24.0,
                          color: fontContrast(color),
                          fit: BoxFit.contain),
                    )),
                this.canView == true
                    ? Container(
                        width: 70,
                        height: 70,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        child: Showcase.withWidget(
                            shapeBorder: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            width: 250,
                            height: 50,
                            container: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    width: 250,
                                    child: Text(
                                      'Click here to search for places to add',
                                      style: TextStyle(color: Colors.white),
                                      maxLines: 3,
                                    ))
                              ],
                            ),
                            key: _one,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              onPressed: () async {
                                final store =
                                    Provider.of<TrotterStore>(context);
                                var suggestion = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (context) => SearchModal(
                                            query: '',
                                            onPush: onPush,
                                            destination: this.destination,
                                            destinationName:
                                                this.destinationName,
                                            location: this.location,
                                            near: this.currentPosition != null
                                                ? this.currentPosition
                                                : this.startLocation,
                                            id: this.destinationId)));
                                if (suggestion != null) {
                                  var poi = suggestion;
                                  poi['image'] = suggestion['image_hd'];
                                  var data = {
                                    "poi": poi,
                                    "title": "",
                                    "description": "",
                                    "time": {"value": "", "unit": ""},
                                    "poi_id": poi['id'],
                                    "added_by": store.currentUser.uid
                                  };

                                  setState(() {
                                    this.loading = true;
                                  });

                                  var response = await addToDay(
                                      store,
                                      this.itineraryId,
                                      this.dayId,
                                      this.destinationId,
                                      data,
                                      false);
                                  setState(() {
                                    this.color = Color(
                                        hexStringToHexInt(response.color));
                                    this.destinationName =
                                        response.destination['name'];
                                    this.location =
                                        response.destination['location'];
                                    this.destinationId =
                                        response.destination['id'].toString();
                                    this.itineraryItems =
                                        response.day['itinerary_items'];
                                    this.visited = response.visited;
                                    this.loading = false;
                                  });
                                } else if (store
                                            .itineraryStore
                                            .selectedItinerary
                                            .selectedItinerary !=
                                        null &&
                                    store
                                            .itineraryStore
                                            .selectedItinerary
                                            .selectedItinerary['days']
                                                [this.day['day']]
                                                ['itinerary_items']
                                            .length !=
                                        this.itineraryItems.length) {
                                  setState(() {
                                    this.loading = true;
                                  });
                                  var response = await fetchDay(
                                      itineraryId,
                                      dayId,
                                      this.startLocation['location'],
                                      "true");
                                  setState(() {
                                    this.canView = response
                                        .itinerary['travelers']
                                        .any((traveler) =>
                                            store.currentUser.uid == traveler);
                                    this.color = Color(
                                        hexStringToHexInt(response.color));
                                    this.itineraryName =
                                        response.itinerary['name'];
                                    this.ownerId =
                                        response.itinerary['owner_id'];
                                    this.tripId = response.itinerary['trip_id'];
                                    this.startDate =
                                        response.itinerary['start_date'] * 1000;
                                    this.destinationName =
                                        response.destination['name'];
                                    this.location =
                                        response.destination['location'];
                                    this.destination = response.destination;
                                    this.destinationId =
                                        response.destination['id'].toString();
                                    this.itineraryItems = response
                                        .day['itinerary_items']
                                        .sublist(1);
                                    this.visited = response.visited;
                                    this.startLocation =
                                        response.itinerary['start_location'];
                                    this.currentPosition =
                                        response.currentPosition;
                                    this.image = response.destination['image'];
                                    this.loading = false;
                                  });
                                }
                              },
                              child: SvgPicture.asset(
                                  "images/add-location-bold.svg",
                                  width: 35,
                                  height: 35,
                                  color: fontContrast(color),
                                  fit: BoxFit.cover),
                            )))
                    : Container()
              ],
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
    //var itinerary = snapshot.data.itinerary;
    var color = Color(hexStringToHexInt(snapshot.data.color));
    final formatter = DateFormat.yMMMMEEEEd("en_US");
    return DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    boxShadow: this.shadow
                        ? <BoxShadow>[
                            BoxShadow(
                                color: Colors.black.withOpacity(.2),
                                blurRadius: 10.0,
                                offset: Offset(0.0, 0.75))
                          ]
                        : []),
                alignment: Alignment.center,
                child: Column(children: <Widget>[
                  _renderTabBar(this.color, Colors.black),
                  DayListTabs(
                    days: this.days,
                    startDate: this.startDate,
                    activeDay: this.dayId,
                    activeColor: color,
                    onSelected: (day, index) {
                      print(startLocation);
                      onPush({
                        'itineraryId': this.itineraryId,
                        'dayId': day['id'].toString(),
                        "linkedItinerary": this.days[index]['linked_itinerary'],
                        "startLocation": startLocation['location'],
                        'level': 'itinerary/day/edit'
                      });
                    },
                  )
                ])),
            Flexible(
                child: Container(
                    width: MediaQuery.of(ctxt).size.width,
                    child: TabBarView(children: <Widget>[
                      RenderWidget(
                          onScroll: onScroll,
                          scrollController: _sc,
                          builder: (context, scrollController, asyncSnapshot) =>
                              renderItinerary(day, formatter, color, context,
                                  scrollController)),
                      RenderWidget(
                        onScroll: onScroll,
                        scrollController: _sc,
                        builder: (context, scrollController, asyncSnapshot) =>
                            renderVisited(day, formatter, color, context,
                                scrollController),
                      )
                    ])))
          ],
        ));
  }

  _renderTab(String label) {
    return AutoSizeText(label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ));
  }

  _renderTabBar(Color mainColor, Color fontColor) {
    return TabBar(
      labelColor: mainColor,
      labelPadding: EdgeInsets.all(20),
      isScrollable: true,
      unselectedLabelColor: Colors.black.withOpacity(0.6),
      indicator: BoxDecoration(
          border: Border(
              top: BorderSide(
        color: mainColor,
        width: 4.0,
      ))),
      tabs: <Widget>[
        _renderTab('Itinerary'),
        _renderTab('Visited'),
      ],
    );
  }

  onToggleVisited(BuildContext ctxt, dynamic item) async {
    print(item['visited']);
    setState(() {
      this.loading = true;
    });
    final response =
        await toggleVisited(store, itineraryId, dayId, item['id'], item);
    if (response.success == true) {
      setState(() {
        //this.color = Color(hexStringToHexInt(response.color));
        // this.destinationName = response.destination['name'];
        //this.destinationId = response.destination['id'].toString();
        this.itineraryItems = response.day['itinerary_items'];
        this.visited = response.visited;
        this.loading = false;
        Scaffold.of(ctxt).showSnackBar(SnackBar(
          content: AutoSizeText('Visit status successfully changed',
              style: TextStyle(fontSize: 18)),
          duration: Duration(seconds: 2),
        ));
      });
    } else {
      Scaffold.of(ctxt).showSnackBar(SnackBar(
        content: AutoSizeText('Failed to mark place as visited',
            style: TextStyle(fontSize: 18)),
        duration: Duration(seconds: 2),
      ));
    }
  }

  toggleDialog(BuildContext builderContext) {
    return showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return ToggleVisitedModal(color: color);
      },
      barrierDismissible: false,
    );
  }

  Widget renderItinerary(day, DateFormat formatter, Color color,
      BuildContext ctxt, ScrollController _sc) {
    return Stack(fit: StackFit.expand, children: <Widget>[
      DayList(
        controller: _sc,
        header: '${ordinalNumber(day['day'] + 1)} day',
        tabs: true,
        onToggleVisited: (item) async {
          var time = await toggleDialog(ctxt);
          var data = item;
          print(time);
          if (time != null) {
            data['time'] = time;
            onToggleVisited(context, data);
          }
        },
        subHeader: formatter.format(
            DateTime.fromMillisecondsSinceEpoch(this.startDate, isUtc: true)
                .add(Duration(days: day['day']))),
        ownerId: this.ownerId,
        day: day['day'],
        items: itineraryItems,
        linkedItinerary: this.linkedItinerary,
        color: color,
        startLocation: this.currentPosition != null
            ? this.currentPosition
            : this.startLocation,
        onLongPressed: (data) {
          bottomSheetModal(context, day['day'] + 1, data);
        },
        onPressed: (data) {
          if (data['itinerary'] != null) {
            onPush({'id': data['itinerary']['id'], 'level': 'itinerary/edit'});
          } else {
            onPush({
              'id': data['id'],
              'level': 'poi',
              'google_place': data['google_place']
            });
          }
        },
        comments: true,
        showCaseKeys: [_two, _three, _four],
        onCommentPressed: (itineraryItem) async {
          final totalComments = await Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => CommentsModal(
                      itineraryId: this.itineraryId,
                      dayId: this.dayId,
                      tripId: this.tripId,
                      currentUserId: store.currentUser.uid,
                      itineraryItemId: itineraryItem['id'],
                      title:
                          '${this.itineraryName} - ${itineraryItem['poi']['name']}')));
          setState(() {
            itineraryItem['total_comments'] = totalComments['total_comments'];
          });
        },
      ),
      this.loading
          ? Align(
              alignment: Alignment.center,
              child: RefreshProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(color),
              ))
          : Container()
    ]);
  }

  renderVisited(day, DateFormat formatter, Color color, BuildContext ctxt,
      ScrollController _sc) {
    return Stack(fit: StackFit.expand, children: <Widget>[
      DayList(
        header: '${ordinalNumber(day['day'] + 1)} day',
        tabs: true,
        onToggleVisited: (item) => onToggleVisited(ctxt, item),
        subHeader: formatter.format(
            DateTime.fromMillisecondsSinceEpoch(this.startDate, isUtc: true)
                .add(Duration(days: day['day']))),
        ownerId: this.ownerId,
        controller: _sc,
        day: day['day'],
        items: visited,
        color: color,
        linkedItinerary: this.linkedItinerary,
        startLocation: this.currentPosition != null
            ? this.currentPosition
            : this.startLocation,
        onLongPressed: (data) {
          final store = Provider.of<TrotterStore>(ctxt);
          if (this.ownerId == store.currentUser.uid ||
              store.currentUser.uid == data['added_by'])
            bottomSheetModal(context, day['day'] + 1, data);
        },
        onPressed: (data) {
          if (data['itinerary'] != null) {
            onPush({'id': data['itinerary']['id'], 'level': 'itinerary/edit'});
          } else {
            onPush({
              'id': data['id'],
              'level': 'poi',
              'google_place': data['google_place']
            });
          }
        },
        comments: true,
        visited: true,
        onCommentPressed: (itineraryItem) async {
          final totalComments = await Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => CommentsModal(
                      itineraryId: this.itineraryId,
                      dayId: this.dayId,
                      tripId: this.tripId,
                      currentUserId: store.currentUser.uid,
                      itineraryItemId: itineraryItem['id'],
                      title:
                          '${this.itineraryName} - ${itineraryItem['poi']['name']}')));
          setState(() {
            itineraryItem['total_comments'] = totalComments['total_comments'];
          });
        },
      ),
      this.loading
          ? Align(
              alignment: Alignment.center,
              child: RefreshProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(color),
              ))
          : Container()
    ]);
  }

  bottomSheetModal(BuildContext ctxt, int dayIndex, dynamic data) {
    var name = data['poi']['name'];
    var undoData = data;
    var id = data['id'];
    final store = Provider.of<TrotterStore>(ctxt);
    return showModalBottomSheet(
        context: ctxt,
        builder: (BuildContext context) {
          return new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new ListTile(
                    leading: new Icon(EvilIcons.external_link),
                    title: new AutoSizeText('Move to another day'),
                    onTap: () async {
                      var result = await showDayBottomSheet(
                          store,
                          context,
                          this.itineraryId,
                          data['poi'],
                          this.destinationId,
                          this.color,
                          this.destination,
                          data['added_by'],
                          force: true,
                          startDate: this.startDate,
                          isSelecting: false,
                          movedByUid: store.currentUser.uid,
                          movingFromId: this.dayId,
                          onPush: onPush);
                      if (result != null &&
                          result['selected'] != null &&
                          result['dayId'] != null &&
                          result['toIndex'] != null &&
                          result['itinerary'] != null &&
                          result['poi'] != null &&
                          result['dayIndex'] != null &&
                          result['movedPlaceId'] != null) {
                        Navigator.of(context).pop();
                        setState(() {
                          this.loading = true;
                        });
                        var response = await deleteFromDay(this.itineraryId,
                            this.dayId, id, store.currentUser.uid,
                            sendNotification: false,
                            movedDayId: result['dayId'],
                            movedPlaceId: result['movedPlaceId']);
                        if (response.success == true) {
                          setState(() {
                            this
                                .itineraryItems
                                .removeWhere((item) => item['id'] == id);
                            this
                                .visited
                                .removeWhere((item) => item['id'] == id);
                            store.itineraryStore
                                .updateItineraryBuilderDelete(this.dayId, id);

                            showSuccessSnackbar(this.context,
                                onPush: onPush,
                                toIndex: result['toIndex'],
                                dayId: result['dayId'],
                                dayIndex: result['dayIndex'],
                                itinerary: result['itinerary'],
                                poi: result['poi']);

                            this.loading = false;
                          });
                        } else {
                          setState(() {
                            Scaffold.of(this.context).showSnackBar(SnackBar(
                              content: AutoSizeText(
                                  'Unable to delete from itinerary',
                                  style: TextStyle(fontSize: 18)),
                              duration: Duration(seconds: 2),
                            ));
                            this.loading = false;
                          });
                        }
                      }
                    }),
                new ListTile(
                    leading: new Icon(
                      Ionicons.md_copy,
                      size: 20,
                    ),
                    title: new AutoSizeText('Copy to a different day'),
                    onTap: () async {
                      var result = await showDayBottomSheet(
                          store,
                          context,
                          this.itineraryId,
                          data['poi'],
                          this.destinationId,
                          this.color,
                          this.destination,
                          data['added_by'],
                          force: true,
                          startDate: this.startDate,
                          isSelecting: false,
                          movedByUid: store.currentUser.uid,
                          movingFromId: this.dayId,
                          onPush: onPush);
                      if (result != null &&
                          result['selected'] != null &&
                          result['dayId'] != null &&
                          result['toIndex'] != null &&
                          result['itinerary'] != null &&
                          result['poi'] != null &&
                          result['dayIndex'] != null &&
                          result['movedPlaceId'] != null) {
                        Navigator.of(context).pop();

                        setState(() {
                          showSuccessSnackbar(this.context,
                              onPush: onPush,
                              toIndex: result['toIndex'],
                              dayId: result['dayId'],
                              dayIndex: result['dayIndex'],
                              itinerary: result['itinerary'],
                              poi: result['poi'],
                              action: 'copied');

                          this.loading = false;
                        });
                      } else if (result != null && result['success'] == false) {
                        setState(() {
                          Scaffold.of(this.context).showSnackBar(SnackBar(
                            content: AutoSizeText('Unable to copy',
                                style: TextStyle(fontSize: 18)),
                            duration: Duration(seconds: 2),
                          ));
                          this.loading = false;
                        });
                      }
                    }),
                this.ownerId == store.currentUser.uid ||
                        store.currentUser.uid == data['added_by']
                    ? new ListTile(
                        leading: new Icon(
                          EvilIcons.trash,
                        ),
                        title: new AutoSizeText('Delete from itnerary'),
                        onTap: () async {
                          this.loading = true;
                          var response = await deleteFromDay(this.itineraryId,
                              this.dayId, id, store.currentUser.uid);
                          if (response.success == true) {
                            setState(() {
                              this
                                  .itineraryItems
                                  .removeWhere((item) => item['id'] == id);
                              this
                                  .visited
                                  .removeWhere((item) => item['id'] == id);
                              store.itineraryStore
                                  .updateItineraryBuilderDelete(this.dayId, id);
                              this.loading = false;
                            });
                            Scaffold.of(ctxt).showSnackBar(SnackBar(
                              content: AutoSizeText('$name was removed.',
                                  style: TextStyle(fontSize: 18)),
                              duration: Duration(seconds: 5),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: color,
                                onPressed: () async {
                                  setState(() {
                                    this.loading = true;
                                  });
                                  var response = await addToDay(
                                      store,
                                      this.itineraryId,
                                      this.dayId,
                                      this.destinationId,
                                      undoData,
                                      false);
                                  if (response.success == true) {
                                    setState(() {
                                      this.color = Color(
                                          hexStringToHexInt(response.color));
                                      this.destinationName =
                                          response.destination['name'];
                                      this.destinationId =
                                          response.destination['id'].toString();
                                      this.itineraryItems =
                                          response.day['itinerary_items'];
                                      this.visited = response.visited;
                                      this.loading = false;
                                      Scaffold.of(ctxt).removeCurrentSnackBar();
                                      Scaffold.of(ctxt).showSnackBar(SnackBar(
                                        content: AutoSizeText(
                                            'Undo successful!',
                                            style: TextStyle(fontSize: 18)),
                                        duration: Duration(seconds: 2),
                                      ));
                                    });
                                  } else {
                                    Scaffold.of(ctxt).removeCurrentSnackBar();
                                    Scaffold.of(ctxt).showSnackBar(SnackBar(
                                        content: AutoSizeText(
                                            'Sorry the undo failed!',
                                            style: TextStyle(fontSize: 18)),
                                        duration: Duration(seconds: 2)));
                                  }
                                },
                              ),
                            ));
                          } else {
                            setState(() {
                              Scaffold.of(this.context).showSnackBar(SnackBar(
                                content: AutoSizeText(
                                    'Unable to delete from itinerary',
                                    style: TextStyle(fontSize: 18)),
                                duration: Duration(seconds: 2),
                              ));
                              this.loading = false;
                            });
                          }
                          Navigator.of(context).pop();
                        })
                    : Container(),
              ]);
        });
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt, ScrollController _sc) {
    double _panelHeightOpen = MediaQuery.of(ctxt).size.height - 130;

    return Container(
        width: MediaQuery.of(ctxt).size.width,
        height: _panelHeightOpen,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
            color: Color.fromRGBO(240, 240, 240, 0),
          ),
          Flexible(
            child: DayListLoading(
              controller: _sc,
            ),
          )
        ]));
  }
}
