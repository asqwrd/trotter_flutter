import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/day-list/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';

class Day extends StatefulWidget {
  final String dayId;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  Day({Key key, @required this.dayId, this.itineraryId, this.onPush})
      : super(key: key);
  @override
  DayState createState() => new DayState(
      dayId: this.dayId, itineraryId: this.itineraryId, onPush: this.onPush);
}

class DayState extends State<Day> {
  bool _showTitle = false;
  final String dayId;
  final String itineraryId;
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
  String image;
  String itineraryName;

  Future<DayData> data;

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

  DayState({this.dayId, this.itineraryId, this.onPush});

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
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: FutureBuilder(
                    future: data,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingBody(context);
                      }
                      if (snapshot.hasData && snapshot.data.error == null) {
                        return _buildLoadedBody(context, snapshot);
                      } else if (snapshot.hasData &&
                          snapshot.data.error != null) {
                        return ErrorContainer(
                          color: Color.fromRGBO(106, 154, 168, 1),
                          onRetry: () {
                            setState(() {
                              data = fetchDay(this.itineraryId, this.dayId);
                              data.then((data) {
                                if (data.error == null) {
                                  setState(() {
                                    this.color =
                                        Color(hexStringToHexInt(data.color));
                                    this.destinationName =
                                        data.destination['name'];
                                    this.destination = data.destination;
                                    this.destinationId =
                                        data.destination['id'].toString();
                                    this.itineraryItems =
                                        data.day['itinerary_items'].sublist(1);
                                  });
                                }
                              });
                            });
                          },
                        );
                      }
                      return _buildLoadingBody(context);
                    }))),
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
              Positioned(
                  left: 0,
                  top: (MediaQuery.of(context).size.height / 2) - 110,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('$destinationName',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w300)),
                      ])),
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
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    var day = snapshot.data.day;
    var color = Color(hexStringToHexInt(snapshot.data.color));

    return Stack(fit: StackFit.expand, children: <Widget>[
      DayList(
        header: '${ordinalNumber(day['day'] + 1)} day',
        controller: _sc,
        physics: disableScroll
            ? NeverScrollableScrollPhysics()
            : ClampingScrollPhysics(),
        items: itineraryItems,
        color: color,
      ),
    ]);
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    return Stack(fit: StackFit.expand, children: <Widget>[
      DayListLoading(),
    ]);
  }
}
