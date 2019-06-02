import 'dart:async';

import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/itinerary-list/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    //data = fetchItinerary(this.itineraryId);
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
            child: StoreConnector<AppState, Store<AppState>>(
                converter: (store) => store,
                onInit: (store) async {
                  store.dispatch(new SetItineraryBuilderLoadingAction(true));
                  var data = await fetchItineraryBuilder(
                      store, this.itineraryId, 'itinerary_builder');

                  if (data.error != null) {
                    setState(() {
                      this.errorUi = true;
                    });
                  } else if (data.error == null) {
                    setState(() {
                      this.errorUi = false;
                      this.image = data.destination['image'];
                      this.itineraryName = data.itinerary['name'];
                      this.color = Color(hexStringToHexInt(data.color));
                    });
                  }
                  store.dispatch(SetItineraryBuilderLoadingAction(false));
                },
                builder: (context, store) {
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
                      ? CachedNetworkImage(
                          imageUrl: this.image,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: (context, url) => SizedBox(
                              width: 50,
                              height: 50,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.blueAccent),
                                  ))))
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
  Widget _buildLoadedBody(BuildContext ctxt, Store<AppState> store) {
    if (store.state.itineraryBuilder == null ||
        store.state.itineraryBuilder.loading) {
      return _buildLoadingBody(ctxt);
    }
    if (store.state.itineraryBuilder.error != null) {
      return ErrorContainer(
        onRetry: () async {
          store.dispatch(new SetItineraryBuilderLoadingAction(true));
          await fetchItineraryBuilder(
              store, this.itineraryId, 'itinerary_builder');
          store.dispatch(new SetItineraryBuilderLoadingAction(false));
        },
      );
    }

    var itinerary = store.state.itineraryBuilder.itinerary;
    var destinationName = itinerary['destination_name'];
    var destinationCountryName = itinerary['destination_country_name'];
    var days = itinerary['days'];
    var color = Color(hexStringToHexInt(store.state.itineraryBuilder.color));

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

        return GestureDetector(
            onTap: () => onPush({
                  'itineraryId': this.itineraryId,
                  'dayId': dayId,
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
          ' Loading...',
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
