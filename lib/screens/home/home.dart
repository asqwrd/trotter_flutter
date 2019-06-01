import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/app_button/index.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';
import 'package:trotter_flutter/widgets/itinerary-card/index.dart';
import 'package:trotter_flutter/widgets/trips/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

Future<HomeData> fetchHome() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('home') ?? null;
  if (cacheData != null) {
    // If server returns an OK response, parse the JSON
    var homeData = json.decode(cacheData);
    return HomeData.fromJson(homeData);
  } else {
    try {
      var response = await http.get('http://localhost:3002/api/explore/home/',
          headers: {'Authorization': 'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('home', response.body);
        var homeData = json.decode(response.body);
        return HomeData.fromJson(homeData);
      } else {
        // If that response was not OK, throw an error.
        var msg = response.statusCode;
        return HomeData(error: "Api returned a $msg");
      }
    } catch (error) {
      return HomeData(error: "Server is down");
    }
  }
}

Future<HomeItinerariesData> fetchHomeItineraries() async {
  try {
    final response = await http.get('http://localhost:3002/api/itineraries/all',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var data = json.decode(response.body);
      return HomeItinerariesData.fromJson(data);
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      return HomeItinerariesData(error: "Api returned a $msg");
    }
  } catch (error) {
    //print('Response> $error');
    return HomeItinerariesData(error: "Server is down");
  }
}

class HomeData {
  final List<dynamic> popularCities;
  final List<dynamic> popularIslands;
  final String error;

  HomeData({this.popularCities, this.popularIslands, this.error});

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
        popularCities: json['popular_cities'],
        popularIslands: json['popular_islands'],
        error: null);
  }
}

class HomeItinerariesData {
  final List<dynamic> itineraries;
  final String error;

  HomeItinerariesData({this.itineraries, this.error});

  factory HomeItinerariesData.fromJson(Map<String, dynamic> json) {
    return HomeItinerariesData(itineraries: json['itineraries'], error: null);
  }
}

class Home extends StatefulWidget {
  final String2VoidFunc onPush;
  Home({Key key, @required this.onPush}) : super(key: key);
  @override
  HomeState createState() => new HomeState(onPush: this.onPush);
}

class HomeState extends State<Home> {
  final String2VoidFunc onPush;
  ScrollController _sc = new ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;

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

  Future<HomeData> data = fetchHome();
  Future<HomeItinerariesData> dataItineraries = fetchHomeItineraries();
  HomeState({
    this.onPush,
  });

  Future<Null> _refreshData() async {
    await new Future.delayed(new Duration(seconds: 2));

    setState(() {
      data = fetchHome();
      dataItineraries = fetchHomeItineraries();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var color = Color.fromRGBO(206, 132, 75, 1);
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = MediaQuery.of(context).size.height - 110;
    double _panelHeightClosed = 100.0;
    data.then((data) => {
          if (data.error != null)
            {
              setState(() {
                this.errorUi = true;
                //this.loading = false;
              })
            }
          else
            if (data.error == null)
              {
                setState(() {
                  this.errorUi = false;
                  // this.loading = false;
                })
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadedBody(context, snapshot);
                  } else if (snapshot.hasData && snapshot.data.error == null) {
                    return _buildLoadedBody(context, snapshot);
                  } else if (snapshot.hasData && snapshot.data.error != null) {
                    return ErrorContainer(
                      color: Color.fromRGBO(206, 132, 75, 1),
                      onRetry: () {
                        setState(() {
                          data = fetchHome();
                          dataItineraries = fetchHomeItineraries();
                        });
                      },
                    );
                  }
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
                    "images/home_bg.jpeg",
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
          child: new TrotterAppBar(onPush: onPush, color: color)),
    ]);
  }

  bottomSheetModal(BuildContext context, dynamic data) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            new ListTile(
                leading: new Icon(Icons.trip_origin),
                title: new Text('Create Trip'),
                onTap: () {
                  Navigator.pop(context);
                  onPush({'level': 'createtrip', 'param': data});
                }),
            new ListTile(
                leading: new Icon(Icons.add_circle),
                title: new Text('Add to Trip'),
                onTap: () {
                  Navigator.pop(context);
                  showTripsBottomSheet(context, data);
                }),
          ]);
        });
  }

  Widget _buildItinerary(
      BuildContext ctxt, AsyncSnapshot snapshot, Color color) {
    var itineraries = snapshot.data.itineraries;
    var widgets = <Widget>[
      Padding(
          padding: EdgeInsets.only(bottom: 10, top: 10, left: 20, right: 20),
          child: Text(
            'Get inspired by itineraries!',
            style: TextStyle(
                fontSize: 25, color: color, fontWeight: FontWeight.w500),
          )),
      Padding(
          padding: EdgeInsets.only(bottom: 10, top: 0, left: 20, right: 20),
          child: Text(
            'Trotter is for people who love to travel and those who need help planning. Itineraries are helpful in organizing your trips.',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
          ))
    ];
    for (var itinerary in itineraries) {
      widgets.add(ItineraryCard(
        item: itinerary,
        color: color,
        onPressed: (data) {
          onPush(
              {'id': data['id'].toString(), 'level': data['level'].toString()});
        },
      ));
    }

    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    ));
  }

  Widget _buildItineraryLoading(BuildContext ctxt) {
    var widgets = <Widget>[
      Shimmer.fromColors(
          baseColor: Color.fromRGBO(220, 220, 220, 0.8),
          highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                color: Color.fromRGBO(220, 220, 220, 0.8),
                margin:
                    EdgeInsets.only(bottom: 10, top: 10, left: 20, right: 20),
                height: 20,
                width: 200,
              ))),
      Shimmer.fromColors(
          baseColor: Color.fromRGBO(220, 220, 220, 0.8),
          highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
          child: Container(
            color: Color.fromRGBO(220, 220, 220, 0.8),
            margin: EdgeInsets.only(bottom: 10, top: 10, left: 20, right: 20),
            height: 20,
            width: double.infinity,
          )),
      Shimmer.fromColors(
          baseColor: Color.fromRGBO(220, 220, 220, 0.8),
          highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
          child: Container(
            color: Color.fromRGBO(220, 220, 220, 0.8),
            margin: EdgeInsets.only(bottom: 10, top: 10, left: 20, right: 20),
            height: 20,
            width: double.infinity,
          )),
      ItineraryCardLoading()
    ];

    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    ));
  }

  // function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    var popularCities = snapshot.hasData ? snapshot.data.popularCities : [];
    var popularIslands = snapshot.hasData ? snapshot.data.popularIslands : [];
    var color = Color.fromRGBO(206, 132, 75, 1);

    return Container(
      height: MediaQuery.of(context).size.height,
      child: ListView(
        controller: _sc,
        physics: disableScroll
            ? NeverScrollableScrollPhysics()
            : ClampingScrollPhysics(),
        children: <Widget>[
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
              'Explore',
              style: TextStyle(fontSize: 30),
            ),
          ),
          snapshot.connectionState == ConnectionState.waiting
              ? Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 30.0),
                  child: TopListLoading())
              : TopList(
                  items: popularCities,
                  onPressed: (data) {
                    onPush({'id': data['id'], 'level': data['level']});
                  },
                  onLongPressed: (data) {
                    var currentUser =
                        StoreProvider.of<AppState>(context).state.currentUser;
                    if (currentUser == null) {
                      loginBottomSheet(context, data, color);
                    } else {
                      bottomSheetModal(context, data['item']);
                    }
                  },
                  header: "Trending cities"),
          snapshot.connectionState == ConnectionState.waiting
              ? Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 30.0),
                  child: TopListLoading())
              : TopList(
                  items: popularIslands,
                  onPressed: (data) {
                    onPush({'id': data['id'], 'level': data['level']});
                  },
                  onLongPressed: (data) {
                    var currentUser =
                        StoreProvider.of<AppState>(context).state.currentUser;
                    if (currentUser == null) {
                      loginBottomSheet(context, data, color);
                    } else {
                      bottomSheetModal(context, data['item']);
                    }
                  },
                  header: "Explore the island life"),
          FutureBuilder(
              future: dataItineraries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildItineraryLoading(context);
                } else if (snapshot.hasData && snapshot.data.error == null) {
                  return _buildItinerary(context, snapshot, color);
                } else if (snapshot.hasData && snapshot.data.error != null) {
                  return Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Text(
                                'Failed to get itineraries.',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w300),
                              )),
                          RetryButton(
                            color: color,
                            width: 100,
                            height: 50,
                            onPressed: () {
                              setState(() {
                                dataItineraries = fetchHomeItineraries();
                              });
                            },
                          )
                        ],
                      ));
                }
                return _buildItineraryLoading(context);
              })
        ],
      ),
    );
  }
}
