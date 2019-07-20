import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/trips/middleware.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/flights-accomodation-list/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';

class FlightsAccomodations extends StatefulWidget {
  final String tripId;
  final String destinationId;
  final ValueChanged<dynamic> onPush;
  FlightsAccomodations(
      {Key key, @required this.tripId, this.destinationId, this.onPush})
      : super(key: key);
  @override
  FlightsAccomodationsState createState() =>
      new FlightsAccomodationsState(tripId: this.tripId, onPush: this.onPush);
}

class FlightsAccomodationsState extends State<FlightsAccomodations> {
  final String tripId;
  final String destinationId;
  final ValueChanged<dynamic> onPush;
  Color color = Colors.blueGrey;
  String destinationName = '';
  dynamic destination;
  List<dynamic> itineraryItems = [];
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  String itineraryName;
  List<dynamic> flightsAccomodations;

  Future<FlightsAndAccomodationsData> data;

  @override
  void initState() {
    // _sc.addListener(() {
    //   setState(() {
    //     if (_pc.isPanelOpen()) {
    //       disableScroll = _sc.offset <= 0;
    //     }
    //   });
    // });
    super.initState();
    data = fetchFlightsAccomodations(this.tripId);
    data.then((data) {
      if (data.error == null) {
        setState(() {
          this.loading = false;
          this.flightsAccomodations = data.flightsAccomodations;
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

  FlightsAccomodationsState({this.tripId, this.destinationId, this.onPush});

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
        minHeight: _panelHeightOpen,
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
                              data = fetchFlightsAccomodations(this.tripId);
                              data.then((data) {
                                if (data.error == null) {
                                  setState(() {
                                    this.flightsAccomodations =
                                        data.flightsAccomodations;
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
            height: _panelHeightOpen,
            child: Stack(children: <Widget>[
              Positioned.fill(
                top: 0,
                left: 0,
                child: Container(color: this.color.withOpacity(.3)),
              )
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
    double _panelHeightOpen = MediaQuery.of(ctxt).size.height - 130;
    var tabContents = <Widget>[];
    for (var destination in this.flightsAccomodations) {
      tabContents.add(
        FlightsAccomodationsList(
          destination: destination,
        ),
      );
    }
    return Container(
        height: _panelHeightOpen,
        child: DefaultTabController(
            length: this.flightsAccomodations.length,
            child: ListView(
              primary: true,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                Container(
                    color: Colors.transparent,
                    child: _renderTabBar(Colors.blueGrey, Colors.black)),
                Container(
                    width: MediaQuery.of(ctxt).size.width,
                    height: _panelHeightOpen - 70,
                    child: TabBarView(children: tabContents))
              ],
            )));
  }

  _renderTab(String label) {
    return Text(label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w300,
        ));
  }

  _renderTabBar(Color mainColor, Color fontColor) {
    List<Widget> tabs = [];

    for (var section in this.flightsAccomodations) {
      tabs.add(
        Tab(child: _renderTab(section['destination']['destination_name'])),
      );
    }

    return TabBar(
      labelColor: mainColor,
      isScrollable: true,
      unselectedLabelColor: Colors.black.withOpacity(0.6),
      indicator: BoxDecoration(
          border: Border(bottom: BorderSide(color: mainColor, width: 2.0))),
      tabs: tabs,
    );
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    return Stack(fit: StackFit.expand, children: <Widget>[
      FlightsAccomodationsListLoading(),
    ]);
  }
}
