import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/trips/middleware.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/flights-accomodation-list/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/travelers/travelers-modal.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:trotter_flutter/store/store.dart';

class FlightsAccomodations extends StatefulWidget {
  final String tripId;
  final String currentUserId;
  final ValueChanged<dynamic> onPush;
  FlightsAccomodations(
      {Key key, @required this.tripId, this.currentUserId, this.onPush})
      : super(key: key);
  @override
  FlightsAccomodationsState createState() => new FlightsAccomodationsState(
      tripId: this.tripId,
      currentUserId: this.currentUserId,
      onPush: this.onPush);
}

class FlightsAccomodationsState extends State<FlightsAccomodations> {
  final String tripId;
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
  bool refreshParent = false;

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

  FlightsAccomodationsState({this.tripId, this.currentUserId, this.onPush});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    var store = Provider.of<TrotterStore>(context);
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, {"refresh": this.refreshParent});
          return;
        },
        child: Stack(alignment: Alignment.topCenter, children: <Widget>[
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
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: RefreshProgressIndicator());
                          }
                          if (snapshot.hasData && snapshot.data.error == null) {
                            return _buildLoadedBody(context, snapshot);
                          } else if (snapshot.hasData &&
                              snapshot.data.error != null) {
                            return ListView(
                                controller: _sc,
                                physics: disableScroll
                                    ? NeverScrollableScrollPhysics()
                                    : ClampingScrollPhysics(),
                                shrinkWrap: true,
                                children: <Widget>[
                                  Container(
                                      height: _panelHeightOpen - 80,
                                      width: MediaQuery.of(context).size.width,
                                      child: ErrorContainer(
                                        color: Color.fromRGBO(106, 154, 168, 1),
                                        onRetry: () {
                                          setState(() {
                                            data = fetchFlightsAccomodations(
                                                this.tripId,
                                                store.currentUser.uid);
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
                  title: 'Transport & lodging',
                  actions: <Widget>[
                    Container(
                        width: 58,
                        height: 58,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          onPressed: () async {
                            setState(() {
                              this.loading = true;
                            });
                            final res = await fetchFlightsAccomodations(
                                this.tripId, this.currentUserId);
                            setState(() {
                              this.loading = false;
                              this.flightsAccomodations =
                                  res.flightsAccomodations;
                            });
                          },
                          child: SvgPicture.asset("images/refresh_icon.svg",
                              width: 24.0,
                              height: 24.0,
                              color: Colors.white,
                              fit: BoxFit.contain),
                        ))
                  ],
                  back: () =>
                      Navigator.pop(context, {"refresh": this.refreshParent}))),
        ]));
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
              final detailId = data['id'];
              final destinationId = data['destinationId'];
              final undoData = data['undoData'];
              var store = Provider.of<TrotterStore>(context);
              setState(() {
                this.loading = true;
              });
              final response = await deleteFlightsAndAccomodations(
                  this.tripId, destinationId, detailId, store.currentUser.uid);
              if (response.success == true) {
                var res = await fetchFlightsAccomodations(
                    this.tripId, this.currentUserId);
                setState(() {
                  this.loading = false;
                  this.flightsAccomodations = res.flightsAccomodations;
                });
                Scaffold.of(this.context).showSnackBar(SnackBar(
                    content: AutoSizeText('Delete successful',
                        style: TextStyle(fontSize: 13)),
                    duration: Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: color,
                      onPressed: () async {
                        setState(() {
                          this.loading = true;
                        });
                        var response = await postAddFlightsAndAccomodations(
                            this.tripId, destinationId, undoData);
                        if (response.success == true) {
                          var res = await fetchFlightsAccomodations(
                              this.tripId, this.currentUserId);
                          setState(() {
                            this.loading = false;
                            this.flightsAccomodations =
                                res.flightsAccomodations;
                          });
                        } else {
                          Scaffold.of(ctxt).removeCurrentSnackBar();
                          Scaffold.of(ctxt).showSnackBar(SnackBar(
                              content: AutoSizeText('Sorry the undo failed!',
                                  style: TextStyle(fontSize: 18)),
                              duration: Duration(seconds: 2)));
                        }
                      },
                    )));
              } else {
                setState(() {
                  this.loading = false;
                });
                Scaffold.of(this.context).showSnackBar(SnackBar(
                  content: AutoSizeText('Unable to delete',
                      style: TextStyle(fontSize: 13)),
                  duration: Duration(seconds: 3),
                ));
              }
            },
            onAddPressed: (data) async {
              final ownerId = data['ownerId'];
              final store = Provider.of<TrotterStore>(context);
              var dialogData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => TravelersModal(
                            ownerId: ownerId,
                            currentUserId: this.currentUserId,
                            tripId: this.tripId,
                            travelers: data['travelers'],
                          )));
              if (dialogData != null) {
                final detailId = data['id'];
                final destinationId = data['destinationId'];
                setState(() {
                  this.loading = true;
                });
                final response = await putUpdateFlightsAccommodationTravelers(
                    this.tripId,
                    destinationId,
                    detailId,
                    dialogData,
                    this.currentUserId);
                if (response.error == null) {
                  fetchTrips(store);
                  var res = await fetchFlightsAccomodations(
                      this.tripId, this.currentUserId);
                  setState(() {
                    this.loading = false;
                    this.flightsAccomodations = res.flightsAccomodations;
                    this.refreshParent = true;
                  });
                }
              }
            }),
      );
    }
    return Container(
        height: _panelHeightOpen,
        width: MediaQuery.of(ctxt).size.width,
        child: Stack(fit: StackFit.expand, children: <Widget>[
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
    return AutoSizeText(label,
        style: TextStyle(
          fontSize: 15,
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
