import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:sliding_panel/sliding_panel.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/itinerary-list/index.dart';
import 'package:trotter_flutter/utils/index.dart';

class Itinerary extends StatefulWidget {
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  Itinerary({Key key, @required this.itineraryId, this.onPush})
      : super(key: key);
  @override
  ItineraryState createState() =>
      new ItineraryState(itineraryId: this.itineraryId, onPush: this.onPush);
}

class ItineraryState extends State<Itinerary> {
  static String id;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  Color color = Colors.transparent;
  String itineraryName;
  Future<ItineraryData> data;
  bool imageLoading = true;
  bool shadow = false;

  @override
  void initState() {
    super.initState();
    data = fetchItinerary(this.itineraryId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  ItineraryState({this.itineraryId, this.onPush});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;
    final store = Provider.of<TrotterStore>(context);

    data.then((res) {
      if (res.error != null) {
        setState(() {
          this.errorUi = true;
          this.loading = false;
        });
      } else if (res.error == null) {
        setState(() {
          this.errorUi = false;
          this.image = res.destination['image'];
          this.loading = false;
          this.itineraryName = res.itinerary['name'];
          this.color = Color(hexStringToHexInt(res.color));
          store.itineraryStore.setItineraryLoading(false);
          store.itineraryStore
              .setItinerary(res.itinerary, res.destination, res.color);
        });
      }
    });
    var itinerary = store.itineraryStore.itinerary.itinerary;
    var destinationName =
        itinerary != null ? itinerary['destination_name'] : '';
    var destinationCountryName =
        itinerary != null ? itinerary['destination_country_name'] : '';
    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingPanel(
        snapPanel: true,
        initialState: this.errorUi == true
            ? InitialPanelState.expanded
            : InitialPanelState.closed,
        size: PanelSize(closedHeight: .45, expandedHeight: .835),
        isDraggable: this.errorUi == true ? false : true,
        autoSizing: PanelAutoSizing(),
        decoration: PanelDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        parallaxSlideAmount: .5,
        backdropConfig: BackdropConfig(
            dragFromBody: true, shadowColor: color, opacity: 1, enabled: true),
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
                      itinerary == null || this.loading == true
                          ? Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: 10, bottom: 20),
                              child: AutoSizeText(
                                'Getting itinerary...',
                                style: TextStyle(fontSize: 25),
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(top: 10, bottom: 20),
                              child: AutoSizeText(
                                '$destinationName, $destinationCountryName',
                                style: TextStyle(fontSize: 25),
                              ),
                            )
                    ],
                  )),
            ),
            panelContent: (context, _sc) {
              if (_sc.hasListeners == false) {
                _sc.addListener(() {
                  if (_sc.offset > 0) {
                    setState(() {
                      this.shadow = true;
                    });
                  } else {
                    setState(() {
                      this.shadow = false;
                    });
                  }
                });
              }
              return Center(
                  child: FutureBuilder(
                      future: data,
                      builder: (context, snapshot) {
                        return _buildLoadedBody(context, store, _sc);
                      }));
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
              back: true)),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, TrotterStore store, ScrollController _sc) {
    if (store.itineraryStore.itinerary.itinerary == null ||
        store.itineraryStore.itinerary.loading ||
        store.itineraryStore.itinerary.itinerary['id'] != this.itineraryId) {
      return _buildLoadingBody(ctxt, _sc);
    }
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    if (store.itineraryStore.itinerary.error != null) {
      return ListView(controller: _sc, shrinkWrap: true, children: <Widget>[
        Container(
            height: _panelHeightOpen - 80,
            width: MediaQuery.of(context).size.width,
            child: ErrorContainer(
              onRetry: () async {
                store.itineraryStore.setItineraryLoading(true);
                await fetchItinerary(this.itineraryId, store);
                store.itineraryStore.setItineraryLoading(false);
              },
            ))
      ]);
    }
    var itinerary = store.itineraryStore.itinerary.itinerary;
    var destinationName = itinerary['destination_name'];
    var destinationCountryName = itinerary['destination_country_name'];
    var days = itinerary['days'];
    var color = Color(hexStringToHexInt(store.itineraryStore.itinerary.color));

    return Container(
        height: MediaQuery.of(context).size.height,
        child: _buildDay(days, destinationName, destinationCountryName,
            itinerary['destination'], color, _sc));
  }

  _buildDay(
      List<dynamic> days,
      String destinationName,
      String destinationCountryName,
      String locationId,
      Color color,
      ScrollController _sc) {
    var dayBuilder = days;
    return ListView.separated(
      controller: _sc,
      separatorBuilder: (BuildContext serperatorContext, int index) =>
          new Container(
              margin: EdgeInsets.only(bottom: 40, top: 40),
              child: Divider(color: Color.fromRGBO(0, 0, 0, 0.3))),
      padding: EdgeInsets.all(20.0),
      itemCount: dayBuilder.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext listContext, int dayIndex) {
        var itineraryItems = dayBuilder[dayIndex]['itinerary_items'];
        var dayId = dayBuilder[dayIndex]['id'];
        var pois = [];
        if (itineraryItems != null) {
          for (var item in itineraryItems) {
            pois.add(item['poi']);
          }
        }

        return InkWell(
            onTap: () => onPush({
                  'itineraryId': this.itineraryId,
                  'dayId': dayId,
                  "linkedItinerary": dayBuilder[dayIndex]['linked_itinerary'],
                  'level': 'itinerary/day'
                }),
            child: Column(children: <Widget>[
              Column(children: <Widget>[
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        child: AutoSizeText(
                      'Your ${ordinalNumber(dayBuilder[dayIndex]['day'] + 1)} day in $destinationName',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ))),
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: AutoSizeText(
                          '${itineraryItems.length} ${itineraryItems.length == 1 ? "place" : "places"} to see',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w300),
                        )))
              ]),
              itineraryItems.length > 0 ||
                      dayBuilder[dayIndex]['linked_itinerary'] != null
                  ? Container(
                      margin: EdgeInsets.only(top: 0),
                      child: ItineraryList(
                        items: itineraryItems,
                        linkedItinerary: dayBuilder[dayIndex]
                            ['linked_itinerary'],
                        color: color,
                        onPressed: (data) {
                          onPush({
                            'itineraryId': this.itineraryId,
                            'dayId': dayId,
                            "linkedItinerary": dayBuilder[dayIndex]
                                ['linked_itinerary'],
                            'level': 'itinerary/day'
                          });
                        },
                        onLongPressed: (data) {},
                      ))
                  : Container()
            ]));
      },
    );
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt, ScrollController _sc) {
    var children2 = <Widget>[
      Center(heightFactor: 12, child: RefreshProgressIndicator()),
    ];
    return Container(
      padding: EdgeInsets.only(top: 0.0),
      decoration: BoxDecoration(color: Colors.transparent),
      child: ListView(
        controller: _sc,
        children: children2,
      ),
    );
  }
}
