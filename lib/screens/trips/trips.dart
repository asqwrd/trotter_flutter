import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/store/trips/middleware.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'dart:core';
import 'package:trotter_flutter/widgets/auth/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:trotter_flutter/widgets/comments/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:share/share.dart';

import '../../bottom_navigation.dart';

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
  bool refreshing = false;
  bool loggedIn = false;
  BuildContext context;
  final ValueChanged<dynamic> onPush;
  bool isSub = false;

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
    final store = Provider.of<TrotterStore>(context);
    if (isSub == false) {
      store.eventBus.on<FocusChangeEvent>().listen((event) async {
        // All events are of type UserLoggedInEvent (or subtypes of it).
        if (event.tab == TabItem.trips) {
          // add mark notification as read if it makes it to the page
          final eventdata = event.data;
          if (eventdata['level'] == 'comments') {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => CommentsModal(
                        itineraryId: eventdata['itineraryId'],
                        dayId: eventdata['dayId'],
                        tripId: eventdata['tripId'],
                        currentUserId: store.currentUser.uid,
                        itineraryItemId: eventdata['itineraryItemId'],
                        title:
                            '${eventdata['itineraryName']} - ${eventdata['itineraryItemName']}')));
            onPush({
              "itineraryId": eventdata['itineraryId'],
              "dayId": eventdata['dayId'],
              "startLocation": eventdata['startLocation'],
              'level': 'itinerary/day/edit'
            });
          } else {
            fetchTrips(store);
            onPush(eventdata);
          }
        }
      });
      setState(() {
        isSub = true;
      });
    }

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
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        maxHeight: _panelHeightOpen,
        panel: Center(child: buildScaffold(color, store, context)),
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
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    onPressed: () async {
                      store.setTripsRefreshing(true);
                      await fetchTrips(store);
                      store.setTripsRefreshing(false);
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

  Scaffold buildScaffold(
      Color color, TrotterStore store, BuildContext context) {
    var currentUser = store.currentUser;
    var tripsError = store.tripStore.tripsError;
    var offline = store.offline;
    return Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton:
            (currentUser != null && tripsError == null && offline == false)
                ? FloatingActionButton(
                    backgroundColor: color,
                    onPressed: () {
                      onPush({"level": "createtrip"});
                    },
                    tooltip: 'Create trip',
                    child: Icon(Icons.add),
                    elevation: 5.0,
                  )
                : null,
        body: _buildLoadedBody(context, store, color));
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, TrotterStore store, Color color) {
    var error = store.tripStore.tripsError;
    var offline = store.offline;
    var trips = store.tripStore.trips;
    var currentUser = store.currentUser;
    var loading = store.tripsLoading;

    if (error != null && offline == false) {
      return ErrorContainer(
        color: color,
        onRetry: () {
          store.tripStore.setTripsLoading(true);
          fetchTrips(store);
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
                      child: AutoSizeText(
                        'Get Started',
                        style: TextStyle(fontSize: 25),
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
                        Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.width / 2,
                            foregroundDecoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(.3),
                                    Colors.white.withOpacity(1),
                                    Colors.white.withOpacity(1),
                                  ],
                                  center: Alignment.center,
                                  focal: Alignment.center,
                                  radius: 1.05,
                                ),
                                borderRadius: BorderRadius.circular(130)),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('images/trips-login.jpg'),
                                    fit: BoxFit.contain),
                                borderRadius: BorderRadius.circular(130))),
                        AutoSizeText(
                          'Want to create a trip?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              color: color,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 10),
                        AutoSizeText(
                          'Sign up and start planning right away.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              color: color,
                              fontWeight: FontWeight.w300),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: 35),
                            child: GoogleAuthButtonContainer())
                      ],
                    ))),
            store.tripsLoading == true
                ? Center(child: RefreshProgressIndicator())
                : Container()
          ]));
    } else if (currentUser != null && trips == null) {
      fetchTrips(store).then((res) {
        setState(() {
          this.loggedIn = true;
        });
      });
    }

    if (loading == true || trips == null) {
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
          child: AutoSizeText(
            'Getting trips...',
            style: TextStyle(fontSize: 25),
          ),
        ),
        Center(child: RefreshProgressIndicator())
      ]);
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
                      child: AutoSizeText(
                        'Get started',
                        style: TextStyle(fontSize: 25),
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
                        Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.width / 2,
                            foregroundDecoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(.2),
                                    Colors.white.withOpacity(1),
                                    Colors.white.withOpacity(1),
                                  ],
                                  center: Alignment.center,
                                  focal: Alignment.center,
                                  radius: 1,
                                ),
                                borderRadius: BorderRadius.circular(130)),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('images/trips-empty.jpg'),
                                    fit: BoxFit.contain),
                                borderRadius: BorderRadius.circular(130))),
                        AutoSizeText(
                          'No trips planned yet?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              color: color,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 10),
                        AutoSizeText(
                          'Create a trip to start planning your next adventure!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w200),
                        )
                      ],
                    ))),
            store.tripsLoading == true
                ? Center(child: RefreshProgressIndicator())
                : Container()
          ]));
    }

    var tripBuilder = ['', '', ...trips];

    return Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          ListView.builder(
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
                  child: AutoSizeText(
                    'Your adventures',
                    style: TextStyle(fontSize: 25),
                  ),
                );
              }
              var color = Color(hexStringToHexInt(tripBuilder[index]['color']));
              //var maincolor = Color.fromRGBO(1, 155, 174, 1);
              var onPressed2 = () async {
                final details = await fetchFlightsAccomodations(
                    tripBuilder[index]['id'], store.currentUser.uid);
                var undoData = {
                  "trip": {
                    "image": tripBuilder[index]['image'],
                    "name": tripBuilder[index]['name'],
                    "owner_id": currentUser.uid,
                    "group": tripBuilder[index]['group']
                  },
                  "destinations": tripBuilder[index]['destinations'],
                  "user": {
                    "displayName": store.currentUser.displayName,
                    "photoUrl": store.currentUser.photoUrl,
                    "email": store.currentUser.email,
                    "phoneNumber": store.currentUser.phoneNumber,
                    "uid": store.currentUser.uid,
                  }
                };
                store.setTripsRefreshing(true);

                var response =
                    await deleteTrip(store, tripBuilder[index]['id']);
                store.setTripsRefreshing(false);
                if (response.success == true) {
                  this.context = context;
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: AutoSizeText(
                        '${tripBuilder[index]['name']}\'s was deleted.',
                        style: TextStyle(fontSize: 13)),
                    duration: Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: color,
                      onPressed: () async {
                        store.setTripsRefreshing(true);

                        var undoResponse =
                            await undoDeleteTrip(store, undoData, index - 2);

                        for (var detail in details.flightsAccomodations) {
                          for (var item in detail['details']) {
                            final destination = undoResponse
                                .trip['destinations']
                                .firstWhere((item) {
                              return item['destination_id'] ==
                                  detail['destination']['destination_id'];
                            });
                            postAddFlightsAndAccomodations(
                                undoResponse.trip['id'],
                                destination['id'],
                                item);
                          }
                        }
                        store.setTripsRefreshing(false);
                        if (response.success == true) {
                          Scaffold.of(this.context).removeCurrentSnackBar();
                          Scaffold.of(this.context).showSnackBar(SnackBar(
                            content: AutoSizeText('Undo successful!',
                                style: TextStyle(fontSize: 13)),
                            duration: Duration(seconds: 2),
                          ));
                        } else {
                          Scaffold.of(this.context).removeCurrentSnackBar();
                          Scaffold.of(this.context).showSnackBar(SnackBar(
                              content: AutoSizeText('Sorry the undo failed!',
                                  style: TextStyle(fontSize: 13)),
                              duration: Duration(seconds: 2)));
                        }
                      },
                    ),
                  ));
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: AutoSizeText(
                          '${tripBuilder[index]['name']} failed to be deleted.',
                          style: TextStyle(fontSize: 13)),
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
                          height: 230.0,
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                  top: 0,
                                  left: 0,
                                  child: TransitionToImage(
                                    image: AdvancedNetworkImage(
                                      tripBuilder[index]['image'],
                                      useDiskCache: true,
                                      cacheRule: CacheRule(
                                          maxAge: const Duration(days: 7)),
                                    ),
                                    loadingWidgetBuilder: (BuildContext context,
                                            double progress, test) =>
                                        Center(
                                            child: RefreshProgressIndicator(
                                      backgroundColor: Colors.white,
                                    )),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    placeholder: const Icon(Icons.refresh),
                                    enableRefresh: true,
                                  )),
                              Positioned.fill(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                            center: Alignment.center,
                                            focal: Alignment.center,
                                            radius: .75,
                                            // begin: FractionalOffset.topCenter,
                                            // end: FractionalOffset.bottomCenter,
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
                                          child: AutoSizeText(
                                            tripBuilder[index]['name'],
                                            overflow: TextOverflow.fade,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: fontContrast(color),
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w400),
                                          )),
                                    ]),
                              ),
                              Positioned(
                                  top: 20,
                                  right: 20,
                                  child: Column(children: <Widget>[
                                    tripBuilder[index]['owner_id'] ==
                                            currentUser.uid
                                        ? GestureDetector(
                                            onTap: onPressed2,
                                            child: Container(
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Colors.transparent),
                                                child: Icon(
                                                  EvilIcons.close,
                                                  color: fontContrast(color),
                                                  size: 30,
                                                )),
                                          )
                                        : Container(),
                                    GestureDetector(
                                      onTap: () {
                                        Share.share(
                                            'Lets plan our trip using Trotter. https://trotter.page.link/?link=http://ajibade.me?trip%3D${tripBuilder[index]['id'].toString()}&apn=org.trotter.application');
                                      },
                                      child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: Colors.transparent),
                                          child: Icon(
                                            EvilIcons.share_google,
                                            color: fontContrast(color),
                                            size: 35,
                                          )),
                                    )
                                  ])),
                              Positioned(
                                  left: 10,
                                  bottom: 15,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      _buildDestinationInfo(
                                          tripBuilder[index]['destinations'],
                                          color),
                                    ],
                                  )),
                              Positioned(
                                  right: 35,
                                  bottom: 25,
                                  width: 220,
                                  height: 40,
                                  child: buildTravelers(
                                      tripBuilder[index]['travelers']))
                            ],
                          )),
                    ]),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 1,
                    margin: EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 20),
                  ));
            },
          ),
          store.tripsRefreshing == true
              ? Center(child: RefreshProgressIndicator())
              : Container()
        ]));
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
        child: AutoSizeText('${destination['destination_name']}',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: fontContrast(color),
              fontSize: 15,
            )),
      ));
    }
    if (destinations.length > length) {
      widgets.add(Padding(
        padding: EdgeInsets.only(top: 0, bottom: 10),
        child: AutoSizeText('+${destinations.length - length} more',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: fontContrast(color),
              fontSize: 15,
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
