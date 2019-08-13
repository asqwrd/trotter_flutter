import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/trips/middleware.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/flights-accomodation-list/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/travelers/travelers-modal.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:trotter_flutter/store/store.dart';

class FlightsAccomodations extends StatefulWidget {
  final String tripId;
  final String ownerId;
  final String currentUserId;
  final ValueChanged<dynamic> onPush;
  FlightsAccomodations(
      {Key key,
      @required this.tripId,
      this.ownerId,
      this.currentUserId,
      this.onPush})
      : super(key: key);
  @override
  FlightsAccomodationsState createState() => new FlightsAccomodationsState(
      tripId: this.tripId,
      ownerId: this.ownerId,
      currentUserId: this.currentUserId,
      onPush: this.onPush);
}

class FlightsAccomodationsState extends State<FlightsAccomodations> {
  final String tripId;
  final String ownerId;
  final String currentUserId;
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
    super.initState();
    data = fetchFlightsAccomodations(this.tripId, this.currentUserId);
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

  FlightsAccomodationsState(
      {this.tripId, this.ownerId, this.currentUserId, this.onPush});

  @override
  Widget build(BuildContext context) {
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    var store = Provider.of<TrotterStore>(context);
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
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        maxHeight: _panelHeightOpen,
        panel: Center(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: FutureBuilder(
                    future: data,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: RefreshProgressIndicator());
                      }
                      if (snapshot.hasData && snapshot.data.error == null) {
                        return _buildLoadedBody(context, snapshot);
                      } else if (snapshot.hasData &&
                          snapshot.data.error != null) {
                        return ListView(shrinkWrap: true, children: <Widget>[
                          Container(
                              height: _panelHeightOpen - 80,
                              width: MediaQuery.of(context).size.width,
                              child: ErrorContainer(
                                color: Color.fromRGBO(106, 154, 168, 1),
                                onRetry: () {
                                  setState(() {
                                    data = fetchFlightsAccomodations(
                                        this.tripId, store.currentUser.uid);
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
                              ))
                        ]);
                      }
                      return Center(child: RefreshProgressIndicator());
                    }))),
        body: Container(
            height: _panelHeightOpen,
            child: Stack(children: <Widget>[
              Positioned.fill(
                top: 0,
                left: 0,
                child: Container(color: this.color.withOpacity(.8)),
              )
            ])),
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              onPush: onPush,
              color: color,
              title: 'Flights & accommodation',
              back: true)),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    double _panelHeightOpen = MediaQuery.of(ctxt).size.height - 130;
    var tabContents = <Widget>[];
    for (var i = 0; i < this.flightsAccomodations.length; i++) {
      var destination = this.flightsAccomodations[i];
      tabContents.add(
        FlightsAccomodationsList(
            destination: destination,
            onDeletePressed: (data) async {
              print(data);
              final detailId = data['id'];
              final destinationId = data['destinationId'];
              setState(() {
                this.loading = true;
              });
              final response = await deleteFlightsAndAccomodations(
                  this.tripId, destinationId, detailId);
              print(response);
              if (response.success == true) {
                var res = await fetchFlightsAccomodations(
                    this.tripId, this.currentUserId);
                setState(() {
                  this.loading = false;
                  this.flightsAccomodations = res.flightsAccomodations;
                });
                Scaffold.of(this.context).showSnackBar(SnackBar(
                  content:
                      Text('Delete successful', style: TextStyle(fontSize: 18)),
                  duration: Duration(seconds: 2),
                ));
              } else {
                setState(() {
                  this.loading = false;
                });
                Scaffold.of(this.context).showSnackBar(SnackBar(
                  content:
                      Text('Unable to delete', style: TextStyle(fontSize: 18)),
                  duration: Duration(seconds: 2),
                ));
              }
            },
            onAddPressed: (data) async {
              var dialogData = await showGeneralDialog(
                context: ctxt,
                pageBuilder: (BuildContext buildContext,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation) {
                  return TravelersModal(
                      ownerId: this.ownerId,
                      currentUserId: this.currentUserId,
                      tripId: this.tripId,
                      travelers: data['travelers']);
                },
                transitionBuilder: (BuildContext context,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    Widget child) {
                  return new FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                barrierDismissible: true,
                barrierLabel:
                    MaterialLocalizations.of(context).modalBarrierDismissLabel,
                barrierColor: Colors.black.withOpacity(0.5),
                transitionDuration: const Duration(milliseconds: 300),
              );
              if (dialogData != null) {
                final detailId = data['id'];
                final destinationId = data['destinationId'];
                final travelers = dialogData['travelers'];
                final response = await putUpdateFlightsAccommodationTravelers(
                    this.tripId,
                    destinationId,
                    detailId,
                    {"travelers": travelers});
                if (response.error == null) {
                  setState(() {
                    this.loading = true;
                  });
                  var res = await fetchFlightsAccomodations(
                      this.tripId, this.currentUserId);
                  setState(() {
                    this.loading = false;
                    this.flightsAccomodations = res.flightsAccomodations;
                  });
                }
              }
            }),
      );
    }
    return Container(
        height: _panelHeightOpen,
        width: MediaQuery.of(ctxt).size.width,
        child: Stack(children: <Widget>[
          DefaultTabController(
              length: this.flightsAccomodations.length,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      color: Colors.transparent,
                      child: _renderTabBar(Colors.blueGrey, Colors.black)),
                  Flexible(
                      child: Container(
                          width: MediaQuery.of(ctxt).size.width,
                          child: TabBarView(children: tabContents)))
                ],
              )),
          this.loading
              ? Center(
                  child: RefreshProgressIndicator(),
                )
              : Container()
        ]));
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
}
