import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/day-list/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';

class Day extends StatefulWidget {
  final String dayId;
  final String itineraryId;
  final dynamic linkedItinerary;
  final Color color;
  final ValueChanged<dynamic> onPush;
  Day(
      {Key key,
      @required this.dayId,
      this.itineraryId,
      this.linkedItinerary,
      this.color,
      this.onPush})
      : super(key: key);
  @override
  DayState createState() => new DayState(
      dayId: this.dayId,
      itineraryId: this.itineraryId,
      color: this.color,
      linkedItinerary: this.linkedItinerary,
      onPush: this.onPush);
}

class DayState extends State<Day> {
  final String dayId;
  final String itineraryId;
  final dynamic linkedItinerary;
  final ValueChanged<dynamic> onPush;
  Color color = Colors.blueGrey;
  String destinationName = '';
  dynamic destination;
  String destinationId;
  List<dynamic> itineraryItems = [];
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  bool imageLoading = true;
  String image;
  String itineraryName;
  dynamic day;
  bool shadow = false;
  bool canView = false;
  List<dynamic> days;
  TrotterStore store;
  dynamic itinerary;

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
          this.itinerary = data.itinerary;
          this.canView = data.itinerary['travelers'] != null
              ? data.itinerary['travelers'].any((traveler) =>
                  store.currentUser != null &&
                  store.currentUser.uid == traveler)
              : false;
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
    super.dispose();
  }

  DayState(
      {this.dayId,
      this.itineraryId,
      this.linkedItinerary,
      this.onPush,
      this.color});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    if (store == null) {
      store = Provider.of<TrotterStore>(context);
    }
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;
    final panelHeights = getPanelHeights(context);
    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingUpPanel(
        backdropColor: color,
        backdropEnabled: true,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        backdropOpacity: 1,
        maxHeight: panelHeights.max,
        minHeight: panelHeights.min,
        defaultPanelState:
            this.errorUi == true ? PanelState.OPEN : PanelState.CLOSED,
        parallaxEnabled: true,
        parallaxOffset: .5,
        controller: _pc,
        panelBuilder: (sc) {
          return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Container(
                constraints: BoxConstraints(maxHeight: 131),
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
                              'Getting day...',
                              style: TextStyle(fontSize: 23),
                            ),
                          )
                        : Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 10, bottom: 0),
                            child: Column(children: <Widget>[
                              AutoSizeText(
                                '${ordinalNumber(day['day'] + 1)} day',
                                style: TextStyle(fontSize: 23),
                              )
                            ]),
                          ),
                    this.loading == false
                        ? Flexible(
                            child: Center(
                                child: DayListTabs(
                            days: this.days,
                            activeDay: this.dayId,
                            activeColor: color,
                            onSelected: (day, index) {
                              onPush({
                                'itineraryId': this.itineraryId,
                                'dayId': day['id'].toString(),
                                "linkedItinerary": this.days[index]
                                    ['linked_itinerary'],
                                'level': 'itinerary/day',
                                'color': color,
                                'replace': true
                              });
                            },
                          )))
                        : Container()
                  ],
                )),
            Expanded(
                child: Center(
                    child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: FutureBuilder(
                            future: data,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildLoadingBody(context, sc);
                              }
                              if (snapshot.hasData &&
                                  snapshot.data.error == null) {
                                return RenderWidget(
                                    onScroll: onScroll,
                                    scrollController: sc,
                                    asyncSnapshot: snapshot,
                                    builder: (context,
                                            {scrollController,
                                            asyncSnapshot,
                                            startLocation}) =>
                                        _buildLoadedBody(context, asyncSnapshot,
                                            scrollController));
                              } else if (snapshot.hasData &&
                                  snapshot.data.error != null) {
                                return SingleChildScrollView(
                                    controller: sc,
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
                              return _buildLoadingBody(context, sc);
                            }))))
          ]);
        },
        body: Container(
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
                          loadingWidgetBuilder:
                              (BuildContext context, double progress, test) =>
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
                  top: (_bodyHeight / 2),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AutoSizeText('$destinationName',
                            style: TextStyle(
                                color: fontContrast(color),
                                fontSize: 28,
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
      )),
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
        linkedItinerary: this.linkedItinerary,
        day: day['day'],
        showTimeSpent: true,
        public: true,
        showTutorial: false,
        showDescriptions: true,
        onLongPressed: (data) {},
        onRefreshImage: (data) async {
          final store = Provider.of<TrotterStore>(context);
          final itemIndex = data['index'];
          final poi = data['poi'];
          final itineraryItemId = data['itineraryItemId'];

          final res = await updatePoiImagePublic(this.itineraryId, this.dayId,
              itineraryItemId, poi['id'], itemIndex, day['day'], store);

          if (res.success == true) {
            setState(() {
              this.itineraryItems[itemIndex]['image'] = res.poi['image'];
              this.itineraryItems[itemIndex]['color'] = res.color;
              this.itineraryItems[itemIndex]['poi'] = res.poi;
            });
          }
        },
        onPressed: (data) {
          final store = Provider.of<TrotterStore>(context);
          setState(() {
            this.canView = this.itinerary['travelers'] != null
                ? this.itinerary['travelers'].any((traveler) =>
                    store.currentUser != null &&
                    store.currentUser.uid == traveler)
                : false;
            if (data['itinerary'] != null &&
                    data['itinerary']['public'] == true ||
                (store.currentUser != null && this.canView == true)) {
              onPush({'id': data['itinerary']['id'], 'level': 'itinerary'});
            } else if (data['itinerary'] != null &&
                data['itinerary']['public'] != true) {
              print('not public');
              Scaffold.of(ctxt).showSnackBar(SnackBar(
                content: AutoSizeText(
                    'This itinerary has not been made public for viewing',
                    style: TextStyle(fontSize: 16)),
                duration: Duration(seconds: 3),
              ));
            } else {
              onPush({
                'id': data['id'],
                'level': 'poi',
                'google_place': data['google_place']
              });
            }
          });
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
