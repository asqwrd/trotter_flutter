import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loadmore/loadmore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/app_button/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/itinerary-card/itinerary-card-loading.dart';
import 'package:trotter_flutter/widgets/itinerary-card/itinerary-card.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/itineraries/index.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/globals.dart';

Future<DestinationData> fetchDestination(
    String id, String destinationType) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('destination_$id') ?? null;
  final int cacheDataExpire =
      prefs.getInt('destination_$id-expiration') ?? null;
  final currentTime = DateTime.now().millisecondsSinceEpoch;
  if (cacheData != null &&
      cacheDataExpire != null &&
      (currentTime < cacheDataExpire)) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return DestinationData.fromJson(json.decode(cacheData));
  } else {
    try {
      print('no-cached');
      print(id);
      final response = await http.get(
          '$ApiDomain/api/explore/destinations/$id?type=$destinationType',
          headers: {'Authorization': 'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('destination_$id', response.body);
        await prefs.setInt('destination_$id-expiration',
            DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch);
        return DestinationData.fromJson(json.decode(response.body));
      } else {
        // If that response was not OK, throw an error.
        var msg = response.statusCode;
        return DestinationData(error: 'Response > $msg');
      }
    } catch (error) {
      return DestinationData(error: 'Server is down');
    }
  }
}

Future<DestinationItinerariesData> fetchDestinationItineraries(
    String destinationId) async {
  try {
    final response = await http.get(
        '$ApiDomain/api/itineraries/all?public=true&destination=$destinationId',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var data = json.decode(response.body);

      return DestinationItinerariesData.fromJson(data);
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      return DestinationItinerariesData(error: "Api returned a $msg");
    }
  } catch (error) {
    //print('Response> $error');
    return DestinationItinerariesData(error: "Server is down");
  }
}

Future<DestinationItinerariesData> fetchDestinationItinerariesNext(
    String destinationId, lastId) async {
  try {
    final response = await http.get(
        '$ApiDomain/api/itineraries/all?public=true&last=$lastId&destination=$destinationId',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var data = json.decode(response.body);

      return DestinationItinerariesData.fromJson(data);
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      return DestinationItinerariesData(error: "Api returned a $msg");
    }
  } catch (error) {
    //print('Response> $error');
    return DestinationItinerariesData(error: "Server is down");
  }
}

class DestinationItinerariesData {
  final List<dynamic> itineraries;
  final dynamic totalPublic;
  final String error;

  DestinationItinerariesData({this.itineraries, this.error, this.totalPublic});

  factory DestinationItinerariesData.fromJson(Map<String, dynamic> json) {
    return DestinationItinerariesData(
        itineraries: json['itineraries'],
        totalPublic: json['total_public'],
        error: null);
  }
}

class DestinationData {
  final String color;
  final Map<String, dynamic> destination;
  final dynamic sections;

  final String error;

  DestinationData({this.color, this.destination, this.sections, this.error});

  factory DestinationData.fromJson(Map<String, dynamic> json) {
    return DestinationData(
        color: json['color'],
        destination: json['destination'],
        sections: json['sections'],
        error: null);
  }
}

class Destination extends StatefulWidget {
  final String destinationId;
  final String destinationType;
  final Future2VoidFunc onPush;
  Destination(
      {Key key,
      @required this.destinationId,
      @required this.destinationType,
      this.onPush})
      : super(key: key);
  @override
  DestinationState createState() => new DestinationState(
      destinationId: this.destinationId,
      destinationType: this.destinationType,
      onPush: this.onPush);
}

class DestinationState extends State<Destination>
    with SingleTickerProviderStateMixin {
  static String id;
  final String destinationId;
  final String destinationType;
  Future<DestinationData> data;
  Future<DestinationItinerariesData> dataItineraries;
  final Future2VoidFunc onPush;
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  Color color = Colors.black.withOpacity(.3);
  String destinationName;
  dynamic location;
  dynamic destination;
  dynamic sections = [];
  dynamic itineraries = [];
  int totalPublic = 0;

  bool imageLoading = true;

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
    data = fetchDestination(this.destinationId, this.destinationType);
    dataItineraries = fetchDestinationItineraries(this.destinationId);
  }

  DestinationState({this.destinationId, this.destinationType, this.onPush});

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;
    double _panelHeightClosed = (MediaQuery.of(context).size.height / 2) - 50;
    data.then((data) => {
          if (data.error != null)
            {
              setState(() {
                this.errorUi = true;
              })
            }
          else if (data.error == null)
            {
              setState(() {
                this.errorUi = false;
                this.image = data.destination['image'];
                //print(this.image);
                this.destinationName = data.destination['name'];
                this.destination = data.destination;
                this.location = data.destination['location'];
                this.color = Color(hexStringToHexInt(data.color));
                this.sections = data.sections;

                this.loading = false;
              })
            }
        });
    dataItineraries.then((data) => {
          if (data.error == null)
            {
              setState(() {
                this.itineraries = data.itineraries;
                this.totalPublic = data.totalPublic['count'];
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
              if (disableScroll == false) {
                setState(() {
                  disableScroll = true;
                });
              }
            },
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            maxHeight: _panelHeightOpen,
            panel: Center(
                child: FutureBuilder(
                    future: data,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadedBody(context, snapshot);
                      } else if (snapshot.hasData &&
                          snapshot.data.error == null) {
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
                                    onRetry: () {
                                      setState(() {
                                        data = fetchDestination(
                                            this.destinationId,
                                            this.destinationType);
                                      });
                                    },
                                  ))
                            ]);
                      }
                      return Container();
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
                          ? TransitionToImage(
                              image: AdvancedNetworkImage(
                                this.image,
                                useDiskCache: true,
                                cacheRule:
                                    CacheRule(maxAge: const Duration(days: 7)),
                              ),
                              loadingWidgetBuilder: (BuildContext context,
                                      double progress, test) =>
                                  Container(),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              placeholder: const Icon(Icons.refresh),
                              enableRefresh: true,
                              loadedCallback: () async {
                                await Future.delayed(Duration(seconds: 2));
                                setState(() {
                                  this.imageLoading = false;
                                });
                              },
                              loadFailedCallback: () async {
                                await Future.delayed(Duration(seconds: 2));
                                setState(() {
                                  this.imageLoading = false;
                                });
                              },
                            )
                          : Container()),
                  Positioned.fill(
                    top: 0,
                    left: 0,
                    child: Container(
                        color: this.imageLoading
                            ? this.color
                            : this.color.withOpacity(.3)),
                  ),
                  this.image == null || this.imageLoading == true
                      ? Positioned.fill(
                          top: -((_bodyHeight / 2) + 100),
                          // left: -50,
                          child: Center(
                              child: Container(
                                  width: 250,
                                  child: TrotterLoading(
                                      file: 'assets/globe.flr',
                                      animation: 'flight',
                                      color: Colors.transparent))))
                      : Container()
                ]))),
      ),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              loading: loading,
              onPush: onPush,
              color: color,
              title: this.destinationName,
              back: true,
              destination: this.destination,
              id: this.destinationId,
              actions: <Widget>[
                Container(
                    width: 58,
                    height: 58,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      onPressed: () async {
                        onPush({'level': 'createtrip', 'param': destination});
                      },
                      child: SvgPicture.asset("images/add-icon.svg",
                          width: 24.0,
                          height: 24.0,
                          color: fontContrast(color),
                          fit: BoxFit.contain),
                    ))
              ],
              location: this.location)),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingBody(ctxt);
    }
    var destination = snapshot.data.destination;
    var descriptionShort = snapshot.data.destination['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));

    return Container(
        height: MediaQuery.of(ctxt).size.height,
        color: Colors.transparent,
        child: _buildSectionContent(
          _buildSections(
              ctxt, this.sections, descriptionShort, color, destination),
        ));
  }

  _buildSectionContent(List<Widget> widgets) {
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
        decoration: BoxDecoration(color: Colors.transparent),
        child: ListView(
            controller: _sc,
            physics: disableScroll
                ? NeverScrollableScrollPhysics()
                : ClampingScrollPhysics(),
            children: widgets));
  }

  _buildSections(BuildContext context, List<dynamic> sections,
      String description, Color color, dynamic destination) {
    final store = Provider.of<TrotterStore>(context);
    var widgets = <Widget>[
      GestureDetector(
        onTap: () {
          onPush(
              {'id': destination['country_id'].toString(), 'level': 'country'});
        },
        child: Container(
            margin: EdgeInsets.only(top: 30),
            padding: EdgeInsets.only(right: 20, left: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AutoSizeText('Info on ${destination['country_name']}',
                    style: TextStyle(fontSize: 19, color: color)),
                Icon(
                  Icons.chevron_right,
                  size: 19,
                  color: color,
                )
              ],
            )),
      ),
      Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: AutoSizeText(
            description,
            style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w300),
          ))
    ];
    for (var section in sections) {
      var items = section['places'];
      var title = getTitle(section['key']);
      if (items.length > 0) {
        widgets.add(TopList(
            items: items,
            onPressed: (data) {
              onPush({
                'id': data['id'],
                'level': data['level'],
                "destination": destination,
                "google_place": true,
              });
            },
            onLongPressed: (data) async {
              var currentUser = store.currentUser;
              if (currentUser == null) {
                loginBottomSheet(context, data, color);
              } else {
                var index = data['index'];
                var result = await addToItinerary(
                    context, items[index], color, destination);
                if (result != null &&
                    result['selected'] != null &&
                    result['dayId'] != null &&
                    result['itinerary'] != null &&
                    result['poi'] != null &&
                    result['dayIndex'] != null) {
                  //Navigator.of(context).pop();

                  await showSuccessSnackbar(context,
                      onPush: onPush,
                      dayId: result['dayId'],
                      dayIndex: result['dayIndex'],
                      itinerary: result['itinerary'],
                      poi: result['poi']);
                }
              }
            },
            header: title));
      }
    }
    return new List<Widget>.from(widgets)
      ..addAll(<Widget>[
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
                            child: AutoSizeText(
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
                              dataItineraries = fetchDestinationItineraries(
                                  this.destinationId);
                            });
                          },
                        )
                      ],
                    ));
              }
              return _buildItineraryLoading(context);
            })
      ]);
  }

  Widget _buildItinerary(
      BuildContext ctxt, AsyncSnapshot snapshot, Color color) {
    var widgets = <Widget>[];
    if (itineraries.length == 0) {
      widgets.add(Container(
          width: MediaQuery.of(ctxt).size.width,
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  width: 150,
                  height: 150,
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
                          image: AssetImage('images/day-empty.jpg'),
                          fit: BoxFit.contain),
                      borderRadius: BorderRadius.circular(130))),
              AutoSizeText(
                'Be the first to share your itinerary',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w300),
              ),
              SizedBox(height: 10),
              AutoSizeText(
                'Create a trip and start planning your next adventure!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w200),
              ),
              SizedBox(height: 30),
              FlatButton(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(50.0)),
                child: AutoSizeText(
                  'Start planning',
                  style: TextStyle(
                      color: fontContrast(this.color),
                      fontSize: 13,
                      fontWeight: FontWeight.w200),
                ),
                color: this.color,
                onPressed: () {
                  onPush({'level': 'createtrip', 'param': destination});
                },
              )
            ],
          )));
    } else {
      widgets = <Widget>[
        Padding(
            padding: EdgeInsets.only(bottom: 10, top: 10, left: 20, right: 20),
            child: AutoSizeText(
              'Check out itineraries',
              style: TextStyle(
                  fontSize: 20, color: color, fontWeight: FontWeight.w500),
            )),
        Padding(
            padding: EdgeInsets.only(bottom: 10, top: 0, left: 20, right: 20),
            child: AutoSizeText(
              'See what other people did while traveling to ${destination['name']}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
            ))
      ];
      for (var itinerary in itineraries) {
        widgets.add(ItineraryCard(
          item: itinerary,
          color: color,
          onLongPressed: (data) {},
          onPressed: (data) {
            onPush({
              'id': data['id'].toString(),
              'level': data['level'].toString()
            });
          },
        ));
      }
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

  getTitle(String key) {
    switch (key) {
      case 'do':
        return 'Some things to do';
      case 'shopping':
        return 'Nice for shopping';
      case 'nightlife':
        return 'Night life vibes';
      case 'foodie':
        return 'Good places to eat';
    }
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    var children2 = <Widget>[
      Container(
          height: 220.0,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 30.0),
          child: TopListLoading()),
      Container(
          height: 220.0,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 30.0),
          child: TopListLoading()),
      Container(
          height: 220.0,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 30.0),
          child: TopListLoading()),
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
