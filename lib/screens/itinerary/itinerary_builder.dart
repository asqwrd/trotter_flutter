import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/itineraries/start-location-modal.dart';
import 'package:trotter_flutter/widgets/itinerary-list/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItineraryBuilder extends StatefulWidget {
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  ItineraryBuilder({Key key, @required this.itineraryId, this.onPush})
      : super(key: key);
  @override
  ItineraryBuilderState createState() => new ItineraryBuilderState(
      itineraryId: this.itineraryId, onPush: this.onPush);
}

class ItineraryBuilderState extends State<ItineraryBuilder> {
  static String id;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  List<dynamic> hotels;
  dynamic destination;
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
    data = fetchItineraryBuilder(this.itineraryId);
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  ItineraryBuilderState({this.itineraryId, this.onPush});

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
          this.destination = res.destination;
          this.itineraryName = res.itinerary['name'];
          this.color = Color(hexStringToHexInt(res.color));
          this.hotels = res.hotels;
          store.itineraryStore.setItineraryBuilder(
            res.itinerary,
            res.destination,
            res.color,
          );
          store.itineraryStore.setItineraryBuilderLoading(false);
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
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
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
              actions: <Widget>[
                Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      onPressed: () async {
                        final store = Provider.of<TrotterStore>(context);

                        var latlng = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => StartLocationModal(
                                      hotels: this.hotels,
                                      destination: this.destination,
                                    )));
                        print(latlng);
                        if (latlng != null) {
                          final response = await updateStartLocation(
                              this.itineraryId, latlng, store);
                          if (response.success == true) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Updated start location',
                                  style: TextStyle(fontSize: 18)),
                              duration: Duration(seconds: 2),
                            ));
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to update start location',
                                  style: TextStyle(fontSize: 18)),
                              duration: Duration(seconds: 2),
                            ));
                          }
                        }
                      },
                      child: SvgPicture.asset("images/place-icon.svg",
                          width: 25.0,
                          height: 25.0,
                          //color: fontContrast(color),
                          fit: BoxFit.cover),
                    )),
              ],
              back: true)),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, TrotterStore store) {
    if (store.itineraryStore.itineraryBuilder.itinerary == null ||
        store.itineraryStore.itineraryBuilder.loading ||
        store.itineraryStore.itineraryBuilder.itinerary['id'] !=
            this.itineraryId) {
      return _buildLoadingBody(ctxt);
    }
    if (store.itineraryStore.itineraryBuilder.error != null) {
      return ErrorContainer(
        onRetry: () async {
          store.itineraryStore.setItineraryBuilderLoading(true);
          await fetchItineraryBuilder(this.itineraryId, store);
          store.itineraryStore.setItineraryBuilderLoading(false);
        },
      );
    }

    var itinerary = store.itineraryStore.itineraryBuilder.itinerary;
    var startLocation = itinerary['start_location'] != null
        ? itinerary['start_location']['location']
        : itinerary['location'];
    var destinationName = itinerary['destination_name'];
    var destinationCountryName = itinerary['destination_country_name'];
    var days = itinerary['days'];
    var color =
        Color(hexStringToHexInt(store.itineraryStore.itineraryBuilder.color));

    return Container(
        height: MediaQuery.of(context).size.height,
        child: _buildDay(days, destinationName, destinationCountryName,
            itinerary['destination'], color, startLocation));
  }

  _buildDay(
      List<dynamic> days,
      String destinationName,
      String destinationCountryName,
      String locationId,
      Color color,
      dynamic startLocation) {
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

        return InkWell(
            onTap: () => onPush({
                  'itineraryId': this.itineraryId,
                  'dayId': dayId,
                  "startLocation": startLocation,
                  'level': 'itinerary/day/edit'
                }),
            child: Column(children: <Widget>[
              Column(children: <Widget>[
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        child: Text(
                      'Your ${ordinalNumber(dayBuilder[dayIndex]['day'] + 1)} day in $destinationName',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
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
                            "startLocation": startLocation,
                            'level': 'itinerary/day/edit'
                          });
                        },
                        onLongPressed: (data) {},
                      ))
                  : Container(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: SvgPicture.asset(
                            'images/itinerary-icon.svg',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            onPush({
                              'itineraryId': this.itineraryId,
                              'dayId': dayId,
                              "startLocation": startLocation,
                              'level': 'itinerary/day/edit'
                            });
                          },
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Text('Start planning',
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20)),
                        )
                      ],
                    ))
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
