import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_loader/awesome_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/app_button/index.dart';
import 'package:trotter_flutter/widgets/poi/poi-modal.dart';
import 'package:trotter_flutter/widgets/recommendations/category-list.dart';
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
// import 'package:sliding_up_panel/sliding_up_panel.dart';

Future<PopularCitiesData> fetchPopularCities([bool refresh]) async {
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
    return PopularCitiesData.fromJson(homeData);
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
        return PopularCitiesData.fromJson(homeData);
      } else {
        // If that response was not OK, throw an error.
        return PopularCitiesData(success: false);
      }
    } catch (error) {
      print("fetch");
      print(error);
      return PopularCitiesData(success: false);
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

class PopularCitiesData {
  final List<dynamic> popularCities;
  final bool success;

  PopularCitiesData({this.popularCities, this.success});

  factory PopularCitiesData.fromJson(Map<String, dynamic> json) {
    return PopularCitiesData(
        popularCities: json['popular_cities'], success: true);
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
  final ValueChanged<dynamic> onPush;
  Home({Key key, @required this.onPush}) : super(key: key);
  @override
  HomeState createState() => new HomeState(onPush: this.onPush);
}

class HomeState extends State<Home> {
  final ValueChanged<dynamic> onPush;
  ScrollController _sc = new ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  List<dynamic> itineraries = [];
  List<dynamic> thingsToDo;
  int totalPublic = 0;
  final Color color = Color.fromRGBO(216, 167, 177, 1);
  bool isLoading = false;
  bool shadow = false;

  Future<ThingsToDoData> doData;
  //Future<NearByData> nearFoodData = fetchNearbyPlaces("restaurant", "");

  Future<PopularCitiesData> data = fetchPopularCities();
  Future<HomeItinerariesData> dataItineraries = fetchHomeItineraries();

  @override
  void initState() {
    () async {
      await Future.delayed(Duration(seconds: 3));
      final store = Provider.of<TrotterStore>(context);
      if (store.currentUser != null) {
        print(this.thingsToDo);
        setState(() {
          doData = fetchThingsToDo(store.currentUser.uid);
        });
      }

      store.eventBus.on<RefreshHomeEvent>().listen((event) {
        // All events are of type UserLoggedInEvent (or subtypes of it).
        if (event.refresh == true) {
          final store = Provider.of<TrotterStore>(context);
          print("store.currentUser.uid");
          print(store.currentUser.uid);
          setState(() {
            doData = fetchThingsToDo(store.currentUser.uid, true);
          });
        }
      });
    }();

    super.initState();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  HomeState({
    this.onPush,
  });

  Future<Null> _refreshData() {
    //await new Future.delayed(new Duration(seconds: 2));
    final store = Provider.of<TrotterStore>(context);

    setState(() {
      data = fetchPopularCities(true);
      this.itineraries = [];
      dataItineraries = fetchHomeItineraries();
      if (store.currentUser != null) {
        doData = fetchThingsToDo(store.currentUser.uid, true);
      }
      //nearFoodData = fetchNearbyPlaces("restaurant", "");
    });

    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;
    //final store = Provider.of<TrotterStore>(context);
    //print(this.thingsToDo);
    if (doData != null) {
      doData.then((response) {
        if (response.success == true) {
          setState(() {
            this.thingsToDo = response.destinations;
          });
        }
      });
    }
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
          if (data.success == false)
            {
              setState(() {
                this.errorUi = true;
                this.loading = false;
              })
            }
          else if (data.success == true)
            {
              setState(() {
                this.errorUi = false;
                this.loading = false;
              })
            }
        });

    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      SlidingPanel(
        snapPanel: true,
        autoSizing: PanelAutoSizing(),
        parallaxSlideAmount: .5,
        backdropConfig: BackdropConfig(
            dragFromBody: true, shadowColor: color, opacity: 1, enabled: true),
        decoration: PanelDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        panelController: _pc,
        content: PanelContent(
          headerWidget: PanelHeaderWidget(
            headerContent: Container(
                decoration: BoxDecoration(
                    boxShadow: this.shadow
                        ? <BoxShadow>[
                            BoxShadow(
                                color: Colors.black.withOpacity(.2),
                                blurRadius: 10.0,
                                offset: Offset(0.0, 0.75))
                          ]
                        : [],
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        'Explore',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ],
                )),
          ),
          panelContent: (context, scrollController) {
            return FutureBuilder(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.success == false) {
                    return this.loading
                        ? _buildLoadedBody(context, snapshot, scrollController)
                        : SingleChildScrollView(
                            controller: scrollController,
                            child: ErrorContainer(
                              color: color,
                              onRetry: () async {
                                final store =
                                    Provider.of<TrotterStore>(context);
                                setState(() {
                                  this.loading = true;
                                  this.errorUi = false;
                                });
                                await Future.delayed(Duration(seconds: 2));

                                setState(() {
                                  data = fetchPopularCities();
                                  dataItineraries = fetchHomeItineraries();
                                  if (store.currentUser != null) {
                                    doData =
                                        fetchThingsToDo(store.currentUser.uid);
                                  }
                                });
                              },
                            ));
                  }
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return RenderWidget(
                        onScroll: onScroll,
                        asyncSnapshot: snapshot,
                        scrollController: scrollController,
                        builder: (context, scrollController, snapshot) =>
                            _buildLoadedBody(
                                context, snapshot, scrollController));
                  }

                  return _buildLoadedBody(context, snapshot, scrollController);
                });
          },
          bodyContent: Container(
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
        ),
        size: PanelSize(
            closedHeight: .45, expandedHeight: getPanelHeight(context)),
      ),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
            loading: loading,
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

  void onScroll(offset) {
    if (offset > 0) {
      setState(() {
        this.shadow = true;
      });
    } else {
      setState(() {
        this.shadow = false;
      });
    }
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

  Widget _buildThingsToDo(
      BuildContext ctxt, AsyncSnapshot snapshot, Color color) {
    var widgets = <Widget>[];
    for (var item in thingsToDo) {
      var destination = item['destination'];
      Color color = Color(hexStringToHexInt(item['color']));

      widgets.add(Column(
        children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              alignment: Alignment.topLeft,
              child: AutoSizeText(
                'Experience ${destination['destination_name']}',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w500, color: color),
              )),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.topLeft,
              child: AutoSizeText(
                'Check out these places for your upcoming trip to ${destination['destination_name']}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
              )),
          Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              height: 220,
              width: double.infinity,
              child: ClipPath(
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: TransitionToImage(
                    image: AdvancedNetworkImage(
                      destination['image'],
                      useDiskCache: true,
                      cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    ),
                    loadingWidgetBuilder:
                        (BuildContext context, double progress, test) => Center(
                            child: RefreshProgressIndicator(
                      backgroundColor: Colors.white,
                    )),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    placeholder: const Icon(Icons.refresh),
                    enableRefresh: true,
                  ))),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: CategoryList(
                  destination: destination,
                  onPressed: (data) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) {
                              return PoiModal(
                                  query: data['query'],
                                  onPush: onPush,
                                  title:
                                      '${destination['destination_name']} - ${data['destination']['name']}',
                                  destination: destination);
                            }));
                  },
                  onLongPressed: (data) {},
                  subText:
                      "See some recommendations for sights, food, shopping and nightlife",
                  header: "Categories to explore")),
        ],
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
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot,
      ScrollController scrollController) {
    var popularCities = snapshot.hasData ? snapshot.data.popularCities : [];
    final store = Provider.of<TrotterStore>(context);

    return Container(
      child: LazyLoadScrollView(
          isLoading: this.isLoading,
          onEndOfPage: () async {
            if (this.itineraries.length > 0 &&
                this.itineraries.length < this.totalPublic) {
              setState(() {
                this.isLoading = true;
              });
              var lastId = this.itineraries[this.itineraries.length - 1]['id'];
              var res = await fetchHomeItinerariesNext(lastId);
              setState(() {
                this.itineraries = this.itineraries..addAll(res.itineraries);
                this.isLoading = false;
              });
            }
            return true;
          },
          child: ListView(
            cacheExtent: MediaQuery.of(context).size.height,
            controller: scrollController,
            children: <Widget>[
              snapshot.connectionState == ConnectionState.waiting ||
                      this.loading
                  ? Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 30.0),
                      child: TopListLoading(
                        enableMini: true,
                      ))
                  : popularCities.length > 0
                      ? Container(
                          child: TopList(
                              items: popularCities,
                              enableMini: true,
                              onPressed: (data) {
                                onPush(
                                    {'id': data['id'], 'level': data['level']});
                              },
                              onLongPressed: (data) {
                                var currentUser = store.currentUser;
                                if (currentUser == null) {
                                  loginBottomSheet(context, data, color);
                                } else {
                                  bottomSheetModal(context, data['poi']);
                                }
                              },
                              subText:
                                  "Learn about popular cities and why so many people like to travel to them.",
                              header: "Trending cities"))
                      : Container(),
              store.currentUser != null
                  ? Container(
                      margin: EdgeInsets.symmetric(vertical: 0),
                      child: FutureBuilder(
                          future: doData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return doLoadingWidget();
                            } else if (snapshot.hasData &&
                                snapshot.data.success == true) {
                              return _buildThingsToDo(context, snapshot, color);
                            } else if (snapshot.hasData &&
                                    snapshot.data.success == false ||
                                (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData == false)) {
                              return Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                          margin: EdgeInsets.only(bottom: 20),
                                          child: AutoSizeText(
                                            'Failed to get things to do.',
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
                                            doData = fetchThingsToDo(
                                                store.currentUser.uid);
                                          });
                                        },
                                      )
                                    ],
                                  ));
                            }
                            return doLoadingWidget();
                          }))
                  : Container(),
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
                  }),
              this.isLoading
                  ? AwesomeLoader(
                      loaderType: AwesomeLoader.AwesomeLoader4,
                      color: this.color,
                    )
                  : Container()
            ],
          )),
    );
  }

  Container doLoadingWidget() {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 30.0),
        child: TopListLoading());
  }
}
