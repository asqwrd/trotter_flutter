import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'dart:core';
import 'package:trotter_flutter/widgets/auth/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';

enum CardActions { delete }

class _MyInheritedTrips extends InheritedWidget {
  _MyInheritedTrips({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  final TripsState data;

  @override
  bool updateShouldNotify(_MyInheritedTrips oldWidget) {
    return true;
  }
}

class Trips extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  Trips({Key key, this.onPush}) : super(key: key);
  @override
  TripsState createState() => new TripsState(onPush: this.onPush);

  static TripsState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_MyInheritedTrips)
            as _MyInheritedTrips)
        .data;
  }
}

class TripsState extends State<Trips> {
  bool _showTitle = false;
  bool refreshing = false;
  bool loggedIn = false;
  BuildContext context;
  final ValueChanged<dynamic> onPush;

  Future<TripsData> data;
  ScrollController _sc = new ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;

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
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  TripsState({this.onPush});

  @override
  Widget build(BuildContext context) {
    this.context = context;
    var color = Color.fromRGBO(234, 189, 149, 1);
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = MediaQuery.of(context).size.height - 110;
    double _panelHeightClosed = 100.0;

    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingUpPanel(
        parallaxEnabled: true,
        parallaxOffset: .5,
        minHeight: _panelHeightClosed,
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
            child: StoreConnector<AppState, TripViewModel>(
                converter: (store) => TripViewModel.create(store),
                onInit: (store) async {
                  if (store.state.currentUser != null) {
                    store.dispatch(new SetTripsLoadingAction(true));
                    await fetchTrips(store);
                    store.dispatch(SetTripsLoadingAction(false));
                    this.loggedIn = true;
                  }
                },
                rebuildOnChange: true,
                builder: (context, viewModel) {
                  var currentUser =
                      StoreProvider.of<AppState>(context).state.currentUser;
                  var tripsError =
                      StoreProvider.of<AppState>(context).state.tripsError;
                  var offline =
                      StoreProvider.of<AppState>(context).state.offline;
                  return Scaffold(
                      backgroundColor: Colors.transparent,
                      floatingActionButton: (currentUser != null &&
                              tripsError == null &&
                              offline == false)
                          ? FloatingActionButton(
                              backgroundColor: color,
                              onPressed: () {
                                onPush({"level": "createtrip"});
                                if (StoreProvider.of<AppState>(context)
                                        .state
                                        .trips
                                        .length ==
                                    0) {
                                  setState(() {
                                    this._showTitle = false;
                                  });
                                }
                              },
                              tooltip: 'Create trip',
                              child: Icon(Icons.add),
                              elevation: 5.0,
                            )
                          : null,
                      body: _buildLoadedBody(context, viewModel, color));
                })),
        body: Container(
            height: _bodyHeight,
            child: Stack(children: <Widget>[
              Positioned(
                  width: MediaQuery.of(context).size.width,
                  height: _bodyHeight,
                  top: 0,
                  left: 0,
                  child: Image.asset(
                    "images/trips2.jpg",
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  )),
              Positioned.fill(
                top: 0,
                left: 0,
                child: Container(color: color.withOpacity(.3)),
              ),
            ])),
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
            onPush: onPush,
            color: color,
            title: 'Trips',
            actions: <Widget>[
              Container(
                  width: 58,
                  height: 58,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    onPressed: () async {
                      StoreProvider.of<AppState>(context)
                          .dispatch(new SetTripsLoadingAction(true));
                      await fetchTrips(StoreProvider.of<AppState>(context));
                      StoreProvider.of<AppState>(context)
                          .dispatch(SetTripsLoadingAction(false));
                    },
                    child: SvgPicture.asset("images/refresh_icon.svg",
                        width: 24.0,
                        height: 24.0,
                        color: Colors.white,
                        fit: BoxFit.contain),
                  ))
            ],
          )),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, TripViewModel viewModel, Color color) {
    var error = StoreProvider.of<AppState>(context).state.tripsError;
    var offline = StoreProvider.of<AppState>(context).state.offline;
    var trips = StoreProvider.of<AppState>(context).state.trips;
    var currentUser = StoreProvider.of<AppState>(context).state.currentUser;
    var loading = StoreProvider.of<AppState>(context).state.tripLoading;
    var store = StoreProvider.of<AppState>(context);

    if (error != null && offline == false) {
      return ErrorContainer(
        color: color,
        onRetry: () {
          store.dispatch(new SetTripsLoadingAction(true));
          viewModel.onGetTrips();
        },
      );
    }

    if (currentUser == null) {
      return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: Column(
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
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 10, bottom: 20),
                      child: Text(
                        'Get Started',
                        style: TextStyle(fontSize: 30),
                      ),
                    )
                  ],
                ),
              )),
          body: Stack(children: <Widget>[
            Center(
                child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset('images/trips-login.png',
                            width: 170, height: 170, fit: BoxFit.contain),
                        Text(
                          'Want to create a trip?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 35,
                              color: color,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Sign up and start planning right away.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              color: color,
                              fontWeight: FontWeight.w300),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 40),
                            child: GoogleAuthButtonContainer())
                      ],
                    ))),
            this.refreshing == true
                ? Center(child: RefreshProgressIndicator())
                : Container()
          ]));
    } else if (currentUser != null && this.loggedIn == false) {
      store.dispatch(new SetTripsLoadingAction(true));
      fetchTrips(store);
      this.loggedIn = true;
    }

    if (trips.length == 0) {
      return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: Column(
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
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 10, bottom: 20),
                      child: Text(
                        'Get started',
                        style: TextStyle(fontSize: 30),
                      ),
                    )
                  ],
                ),
              )),
          body: Stack(children: <Widget>[
            Center(
                child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset('images/trips-empty.png',
                            width: 170, height: 170, fit: BoxFit.contain),
                        Text(
                          'No trips planned yet?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 35,
                              color: color,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Create a trip to start planning your next adventure!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              color: color,
                              fontWeight: FontWeight.w200),
                        )
                      ],
                    ))),
            this.refreshing == true
                ? Center(child: RefreshProgressIndicator())
                : Container()
          ]));
    }

    var tripBuilder = ['', '', ...trips];
    if (loading == true)
      return ListView(children: <Widget>[
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
            'Getting trips',
            style: TextStyle(fontSize: 30),
          ),
        ),
        Center(child: RefreshProgressIndicator())
      ]);

    return Container(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          controller: _sc,
          physics: disableScroll
              ? NeverScrollableScrollPhysics()
              : ClampingScrollPhysics(),
          itemCount: tripBuilder.length,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Center(
                  child: Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
              ));
            }

            if (index == 1) {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 10, bottom: 20),
                child: Text(
                  'Where are you going?',
                  style: TextStyle(fontSize: 30),
                ),
              );
            }
            var color = Color(hexStringToHexInt(tripBuilder[index]['color']));
            //var maincolor = Color.fromRGBO(1, 155, 174, 1);
            var onPressed2 = () async {
              var undoData = {
                "trip": {
                  "image": tripBuilder[index]['image'],
                  "name": tripBuilder[index]['name']
                },
                "destinations": tripBuilder[index]['destinations']
              };
              setState(() {
                this.refreshing = true;
              });
              var response =
                  await viewModel.onDeleteTrip(tripBuilder[index]['id']);
              setState(() {
                this.refreshing = false;
              });
              if (response.success == true) {
                this.context = context;
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('${trips[index]['name']}\'s was deleted.',
                      style: TextStyle(fontSize: 18)),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: color,
                    onPressed: () async {
                      setState(() {
                        this.refreshing = true;
                      });
                      var response =
                          await viewModel.undoDeleteTrip(undoData, index);
                      setState(() {
                        this.refreshing = false;
                      });
                      if (response.success == true) {
                        Scaffold.of(this.context).removeCurrentSnackBar();
                        Scaffold.of(this.context).showSnackBar(SnackBar(
                          content: Text('Undo successful!',
                              style: TextStyle(fontSize: 18)),
                          duration: Duration(seconds: 2),
                        ));
                      } else {
                        Scaffold.of(this.context).removeCurrentSnackBar();
                        Scaffold.of(this.context).showSnackBar(SnackBar(
                            content: Text('Sorry the undo failed!',
                                style: TextStyle(fontSize: 18)),
                            duration: Duration(seconds: 2)));
                      }
                    },
                  ),
                ));
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                        '${tripBuilder[index]['name']} failed to be deleted.',
                        style: TextStyle(fontSize: 18)),
                    duration: Duration(seconds: 2)));
              }
            };
            return InkWell(
                onTap: () async {
                  onPush({
                    'id': tripBuilder[index]['id'].toString(),
                    'level': 'trip'
                  });
                },
                child: Card(
                  semanticContainer: true,
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Column(children: <Widget>[
                    Container(
                        height: 250.0,
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                                top: 0,
                                left: 0,
                                child: CachedNetworkImage(
                                  imageUrl: tripBuilder[index]['image'],
                                  fit: BoxFit.cover,
                                )),
                            Positioned.fill(
                                top: 0,
                                left: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: FractionalOffset.topCenter,
                                          end: FractionalOffset.bottomCenter,
                                          colors: [
                                        Colors.grey.withOpacity(0.0),
                                        color,
                                      ],
                                          stops: [
                                        0.0,
                                        1.0
                                      ])),
                                )),
                            Positioned.fill(
                              top: 30,
                              left: 20,
                              child: ListView(
                                  shrinkWrap: true,
                                  primary: false,
                                  children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(
                                          top: 0.0,
                                          bottom: 10,
                                          left: 20,
                                        ),
                                        child: Text(
                                          tripBuilder[index]['name']
                                              .toUpperCase(),
                                          overflow: TextOverflow.fade,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25.0,
                                              fontWeight: FontWeight.w500),
                                        )),
                                  ]),
                            ),
                            Positioned(
                                top: 20,
                                right: 20,
                                child: GestureDetector(
                                  onTap: onPressed2,
                                  child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: fontContrast(color)
                                              .withOpacity(.35)),
                                      child: Icon(
                                        EvilIcons.close,
                                        color:
                                            fontContrast(color).withOpacity(.8),
                                        size: 25,
                                      )),
                                )),
                            Positioned(
                                left: 10,
                                bottom: 15,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    _buildDestinationInfo(
                                        tripBuilder[index]['destinations'],
                                        color),
                                  ],
                                ))
                          ],
                        )),
                  ]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 1,
                  margin:
                      EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                ));
          },
        ));
  }

  _buildDestinationInfo(List<dynamic> destinations, Color color) {
    var widgets = <Widget>[];
    var length = destinations.length;
    if (length > 3) {
      length = 2;
    }
    for (var i = 0; i < length; i++) {
      var destination = destinations[i];

      widgets.add(Padding(
        padding: EdgeInsets.only(top: 0, bottom: 5),
        child: Text('${destination['destination_name']}',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: fontContrast(color),
              fontSize: 20,
            )),
      ));
    }
    if (destinations.length > length) {
      widgets.add(Padding(
        padding: EdgeInsets.only(top: 0, bottom: 10),
        child: Text('+${destinations.length - length} more',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: fontContrast(color),
              fontSize: 20,
            )),
      ));
    }
    return Container(
        margin: EdgeInsets.only(top: 40, bottom: 20),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widgets,
        ));
  }
}
