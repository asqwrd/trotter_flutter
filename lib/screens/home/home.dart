import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loadmore/loadmore.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/app_button/index.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';
import 'package:trotter_flutter/widgets/itinerary-card/index.dart';
import 'package:trotter_flutter/widgets/trips/index.dart';
import 'package:trotter_flutter/globals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:showcaseview/showcaseview.dart';

Future<HomeData> fetchHome([bool refresh]) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('home') ?? null;
  final int cacheDataExpire = prefs.getInt('home-expiration') ?? null;
  final currentTime = DateTime.now().millisecondsSinceEpoch;
  if (cacheData != null &&
      cacheDataExpire != null &&
      refresh != true &&
      (currentTime < cacheDataExpire)) {
    // If server returns an OK response, parse the JSON
    var homeData = json.decode(cacheData);
    return HomeData.fromJson(homeData);
  } else {
    try {
      var response = await http.get('$ApiDomain/api/explore/home/',
          headers: {'Authorization': 'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('home', response.body);
        await prefs.setInt('home-expiration',
            DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch);
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
    final response = await http.get(
        '$ApiDomain/api/itineraries/all?public=true',
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

Future<HomeItinerariesData> fetchHomeItinerariesNext(lastId) async {
  try {
    final response = await http.get(
        '$ApiDomain/api/itineraries/all?public=true&last=$lastId',
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
  final dynamic totalPublic;
  final String error;

  HomeItinerariesData({this.itineraries, this.error, this.totalPublic});

  factory HomeItinerariesData.fromJson(Map<String, dynamic> json) {
    return HomeItinerariesData(
        itineraries: json['itineraries'],
        totalPublic: json['total_public'],
        error: null);
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
  List<dynamic> itineraries = [];
  int totalPublic = 0;
  final Color color = Color.fromRGBO(216, 167, 177, 1);
  GlobalKey _one = GlobalKey();

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

  Future<Null> _refreshData() {
    //await new Future.delayed(new Duration(seconds: 2));

    setState(() {
      data = fetchHome(true);
      this.itineraries = [];
      dataItineraries = fetchHomeItineraries();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;
    double _panelHeightClosed = (MediaQuery.of(context).size.height / 2) - 50;

    dataItineraries.then((data) => {
          if (data.error == null)
            {
              setState(() {
                this.itineraries = data.itineraries;
                this.totalPublic = data.totalPublic['count'];
              })
            }
        });
    data.then((data) => {
          if (data.error != null)
            {
              setState(() {
                this.errorUi = true;
                this.loading = false;
              })
            }
          else if (data.error == null)
            {
              setState(() {
                this.errorUi = false;
                this.loading = false;
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
        onPanelOpened: () async {
          setState(() {
            disableScroll = false;
          });
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final String cacheData = prefs.getString('homeShowcase') ?? null;
          if (cacheData == null) {
            ShowCaseWidget.startShowCase(context, [_one]);
            await prefs.setString('homeShowcase', "true");
          }
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
                  if (snapshot.hasData && snapshot.data.error != null) {
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
                                color: color,
                                onRetry: () {
                                  setState(() {
                                    this.loading = true;
                                    this.errorUi = false;
                                    data = fetchHome();
                                    dataItineraries = fetchHomeItineraries();
                                  });
                                },
                              ))
                        ]);
                  }
                  return _buildLoadedBody(context, snapshot);
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
          child: new TrotterAppBar(
            onPush: onPush,
            color: color,
            actions: <Widget>[
              Container(
                  width: 58,
                  height: 58,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                        errorUi = false;
                      });
                      this._refreshData();
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

  bottomSheetModal(BuildContext context, dynamic data) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            new ListTile(
                leading: new Icon(Icons.trip_origin),
                title: new AutoSizeText('Create Trip'),
                onTap: () {
                  Navigator.pop(context);
                  onPush({'level': 'createtrip', 'param': data});
                }),
            new ListTile(
                leading: new Icon(Icons.add_circle),
                title: new AutoSizeText('Add to Trip'),
                onTap: () {
                  Navigator.pop(context);
                  showTripsBottomSheet(context, data);
                }),
          ]);
        });
  }

  Widget _buildItinerary(
      BuildContext ctxt, AsyncSnapshot snapshot, Color color) {
    var widgets = <Widget>[
      Padding(
          padding: EdgeInsets.only(bottom: 10, top: 10, left: 20, right: 20),
          child: AutoSizeText(
            'Get inspired by itineraries!',
            style: TextStyle(
                fontSize: 20, color: color, fontWeight: FontWeight.w500),
          )),
      Padding(
          padding: EdgeInsets.only(bottom: 10, top: 0, left: 20, right: 20),
          child: AutoSizeText(
            'Trotter is for people who love to travel and those who need help planning. Itineraries are helpful in organizing your trips.',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
          ))
    ];
    for (var itinerary in itineraries) {
      widgets.add(ItineraryCard(
        item: itinerary,
        color: color,
        onLongPressed: (data) {},
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
    final store = Provider.of<TrotterStore>(context);

    return Container(
      child: LoadMore(
          delegate: TrotterLoadMoreDelegate(this.color),
          isFinish: this.itineraries.length >= this.totalPublic ||
              this.errorUi == true,
          onLoadMore: () async {
            if (this.itineraries.length > 0) {
              var lastId = this.itineraries[this.itineraries.length - 1]['id'];
              var res = await fetchHomeItinerariesNext(lastId);
              setState(() {
                this.itineraries = this.itineraries..addAll(res.itineraries);
              });
            }
            return true;
          },
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
                child: AutoSizeText(
                  'Explore',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              snapshot.connectionState == ConnectionState.waiting
                  ? Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 30.0),
                      child: TopListLoading())
                  : Showcase.withWidget(
                      width: 200,
                      height: 50,
                      container: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TopList().buildThumbnailItem(0, popularCities[0]),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              width: 200,
                              child: Text(
                                'Tap to view destination page.\n Press and hold to show menu',
                                style: TextStyle(color: Colors.white),
                                maxLines: 2,
                              ))
                        ],
                      ),
                      key: _one,
                      child: TopList(
                          items: popularCities,
                          onPressed: (data) {
                            onPush({'id': data['id'], 'level': data['level']});
                          },
                          onLongPressed: (data) {
                            var currentUser = store.currentUser;
                            if (currentUser == null) {
                              loginBottomSheet(context, data, color);
                            } else {
                              bottomSheetModal(context, data['poi']);
                            }
                          },
                          header: "Trending cities")),
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
                        var currentUser = store.currentUser;
                        if (currentUser == null) {
                          loginBottomSheet(context, data, color);
                        } else {
                          bottomSheetModal(context, data['poi']);
                        }
                      },
                      header: "Explore these islands"),
              FutureBuilder(
                  future: dataItineraries,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildItineraryLoading(context);
                    } else if (snapshot.hasData &&
                        snapshot.data.error == null) {
                      return _buildItinerary(context, snapshot, color);
                    } else if (snapshot.hasData &&
                        snapshot.data.error != null) {
                      return Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: AutoSizeText(
                                    'Failed to get itineraries.',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w300),
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
          )),
    );
  }
}
