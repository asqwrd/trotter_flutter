import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/itinerary-list/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  bool _showTitle = false;
  static String id;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  Color color = Colors.transparent;
  String itineraryName;
  Future<ItineraryData> data;

  @override
  void initState() {
    _sc.addListener(() {
      setState(() {
        if (_pc.isPanelOpen()) {
          disableScroll = _sc.offset <= 0;
        }
      });
    });
    super.initState();
    data = fetchItinerary(this.itineraryId);
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  ItineraryState({this.itineraryId, this.onPush});

  @override
  Widget build(BuildContext context) {
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = MediaQuery.of(context).size.height - 110;
    double _panelHeightClosed = 100.0;
    final store = Provider.of<TrotterStore>(context);

    data.then((res) {
      if (res.error != null) {
        setState(() {
          this.errorUi = true;
        });
      } else if (res.error == null) {
        setState(() {
          this.errorUi = false;
          this.image = res.destination['image'];
          this.itineraryName = res.itinerary['name'];
          this.color = Color(hexStringToHexInt(res.color));
          store.itineraryStore.setItineraryLoading(false);
          store.itineraryStore
              .getItinerary(res.itinerary, res.destination, res.color);
        });
      }
    });
    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingUpPanel(
        parallaxEnabled: true,
        parallaxOffset: .5,
        minHeight: errorUi == false ? _panelHeightClosed : _panelHeightOpen,
        controller: _pc,
        backdropEnabled: true,
        backdropColor: color,
        backdropTapClosesPanel: false,
        backdropOpacity: .8,
        onPanelOpened: () {
          setState(() {
            disableScroll = false;
          });
        },
        onPanelClosed: () {
          setState(() {
            disableScroll = true;
          });
        },
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        maxHeight: _panelHeightOpen,
        panel: Center(
            child: FutureBuilder(
                future: data,
                builder: (context, snapshot) {
                  return _buildLoadedBody(context, store);
                })),
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
                                  Center(
                                      child: RefreshProgressIndicator(
                            backgroundColor: Colors.white,
                          )),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: const Icon(Icons.refresh),
                          enableRefresh: true,
                        )
                      // CachedNetworkImage(
                      //     imageUrl: this.image,
                      //     fit: BoxFit.cover,
                      //     alignment: Alignment.center,
                      //     placeholder: (context, url) => SizedBox(
                      //         width: 50,
                      //         height: 50,
                      //         child: Align(
                      //             alignment: Alignment.center,
                      //             child: CircularProgressIndicator(
                      //               valueColor:
                      //                   new AlwaysStoppedAnimation<Color>(
                      //                       Colors.blueAccent),
                      //             ))))
                      : Container()),
              Positioned.fill(
                top: 0,
                left: 0,
                child: Container(color: this.color.withOpacity(.3)),
              ),
              this.image == null
                  ? Positioned(
                      child: Center(
                          child: RefreshProgressIndicator(
                      backgroundColor: Colors.white,
                    )))
                  : Container()
            ])),
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              onPush: onPush,
              color: color,
              title: this.itineraryName,
              back: true)),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, TrotterStore store) {
    if (store.itineraryStore.itinerary.itinerary == null ||
        store.itineraryStore.itinerary.loading) {
      return _buildLoadingBody(ctxt);
    }
    if (store.itineraryStore.itinerary.error != null) {
      return ErrorContainer(
        onRetry: () async {
          store.itineraryStore.setItineraryLoading(true);
          await fetchItinerary(this.itineraryId, store);
          store.itineraryStore.setItineraryLoading(false);
        },
      );
    }
    var itinerary = store.itineraryStore.itinerary.itinerary;
    var destinationName = itinerary['destination_name'];
    var destinationCountryName = itinerary['destination_country_name'];
    var days = itinerary['days'];
    var color = Color(hexStringToHexInt(store.itineraryStore.itinerary.color));

    return Container(
        height: MediaQuery.of(context).size.height,
        child: _buildDay(days, destinationName, destinationCountryName,
            itinerary['destination'], color));
  }

  _buildDay(List<dynamic> days, String destinationName,
      String destinationCountryName, String locationId, Color color) {
    var dayBuilder = ['', '', ...days];
    return ListView.separated(
      controller: _sc,
      physics: disableScroll
          ? NeverScrollableScrollPhysics()
          : ClampingScrollPhysics(),
      separatorBuilder: (BuildContext serperatorContext, int index) => index > 1
          ? new Container(
              margin: EdgeInsets.only(bottom: 40, top: 40),
              child: Divider(color: Color.fromRGBO(0, 0, 0, 0.3)))
          : Container(),
      padding: EdgeInsets.all(20.0),
      itemCount: dayBuilder.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext listContext, int dayIndex) {
        if (dayIndex == 0) {
          return Center(
              child: Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
          ));
        }

        if (dayIndex == 1) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 10, bottom: 40),
            child: Text(
              '$destinationName, $destinationCountryName',
              style: TextStyle(fontSize: 30),
            ),
          );
        }
        var itineraryItems = dayBuilder[dayIndex]['itinerary_items'];
        var dayId = dayBuilder[dayIndex]['id'];
        var pois = [];
        if (itineraryItems != null) {
          for (var item in itineraryItems) {
            pois.add(item['poi']);
          }
        }

        return GestureDetector(
            onTap: () => onPush({
                  'itineraryId': this.itineraryId,
                  'dayId': dayId,
                  'level': 'itinerary/day'
                }),
            child: Column(children: <Widget>[
              Column(children: <Widget>[
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        child: Text(
                      'Your ${ordinalNumber(dayBuilder[dayIndex]['day'] + 1)} day in $destinationName',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
                    ))),
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Text(
                          '${itineraryItems.length} ${itineraryItems.length == 1 ? "place" : "places"} to see',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300),
                        )))
              ]),
              itineraryItems.length > 0
                  ? Container(
                      margin: EdgeInsets.only(top: 0),
                      child: ItineraryList(
                        items: itineraryItems,
                        color: color,
                        onPressed: (data) {
                          onPush({
                            'itineraryId': this.itineraryId,
                            'dayId': dayId,
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
  Widget _buildLoadingBody(BuildContext ctxt) {
    var children2 = <Widget>[
      Center(
          child: Container(
        width: 30,
        height: 5,
        decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
      )),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 10, bottom: 20),
        child: Text(
          'Getting itinerary...',
          style: TextStyle(fontSize: 30),
        ),
      ),
      Center(heightFactor: 12, child: RefreshProgressIndicator()),
    ];
    return Container(
      padding: EdgeInsets.only(top: 0.0),
      decoration: BoxDecoration(color: Colors.transparent),
      child: ListView(
        controller: _sc,
        physics: disableScroll
            ? NeverScrollableScrollPhysics()
            : ClampingScrollPhysics(),
        children: children2,
      ),
    );
  }
}
