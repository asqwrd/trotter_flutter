import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/itineraries/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';

Future<ParkData> fetchPark(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('park_$id') ?? null;
  if (cacheData != null) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return ParkData.fromJson(json.decode(cacheData));
  } else {
    try {
      print('no-cached');
      print(id);
      final response = await http.get(
          'http://localhost:3002/api/explore/national_parks/$id/',
          headers: {'Authorization': 'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('park_$id', response.body);
        return ParkData.fromJson(json.decode(response.body));
      } else {
        // If that response was not OK, throw an error.
        var msg = response.statusCode;
        return ParkData(error: 'Response> $msg');
      }
    } catch (error) {
      return ParkData(error: 'Server is down');
    }
  }
}

class ParkData {
  final String color;
  final Map<String, dynamic> park;
  final List<dynamic> pois;
  final String error;

  ParkData({this.color, this.park, this.pois, this.error});

  factory ParkData.fromJson(Map<String, dynamic> json) {
    return ParkData(
        color: json['color'],
        park: json['park'],
        pois: json['pois'],
        error: null);
  }
}

class Park extends StatefulWidget {
  final String parkId;
  final ValueChanged<dynamic> onPush;
  Park({Key key, @required this.parkId, this.onPush}) : super(key: key);
  @override
  ParkState createState() =>
      new ParkState(parkId: this.parkId, onPush: this.onPush);
}

class ParkState extends State<Park> with SingleTickerProviderStateMixin {
  bool _showTitle = false;
  static String id;
  final String parkId;
  Future<ParkData> data;
  final ValueChanged<dynamic> onPush;
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  Color color = Colors.transparent;
  String parkName;

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
    data = fetchPark(this.parkId);
  }

  ParkState({this.parkId, this.onPush});

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = MediaQuery.of(context).size.height - 110;
    double _panelHeightClosed = 100.0;
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
                this.image = data.park['image'];
                this.parkName = data.park['name'];
                this.color = Color(hexStringToHexInt(data.color));
              })
            }
        });
    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingUpPanel(
              parallaxEnabled: true,
              parallaxOffset: .5,
              minHeight:
                  errorUi == false ? _panelHeightClosed : _panelHeightOpen,
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoadedBody(context, snapshot);
                        } else if (snapshot.hasData &&
                            snapshot.data.error == null) {
                          return _buildLoadedBody(context, snapshot);
                        } else if (snapshot.hasData &&
                            snapshot.data.error != null) {
                          return ErrorContainer(
                            onRetry: () {
                              setState(() {
                                data = fetchPark(this.parkId);
                              });
                            },
                          );
                        }
                      })),
              body: Container(
                height: _bodyHeight,
                child: Container(
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
                                )
                              // CachedNetworkImage(
                              //     imageUrl: this.image,
                              //     fit: BoxFit.cover,
                              //     alignment: Alignment.center,
                              //     placeholder: (context, url) => SizedBox(
                              //         width: 50,
                              //         height: 50,
                              //         child: Align(
                              //             alignment: Alignment.center,
                              //             child: CircularProgressIndicator(
                              //               valueColor:
                              //                   new AlwaysStoppedAnimation<
                              //                       Color>(Colors.blueAccent),
                              //             ))))
                              : Container()),
                      Positioned.fill(
                        top: 0,
                        left: 0,
                        child: Container(color: this.color.withOpacity(.3)),
                      ),
                      this.image == null
                          ? Positioned(
                              child: Center(
                                  child: RefreshProgressIndicator(
                              backgroundColor: Colors.white,
                            )))
                          : Container()
                    ])),
              ))),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              onPush: onPush, color: color, title: this.parkName, back: true)),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingBody(ctxt);
    }
    var destination = snapshot.data.park;
    var name = snapshot.data.park['name'];
    var descriptionShort = snapshot.data.park['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));
    var pois = snapshot.data.pois;

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
                  padding:
                      EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                  child: Text(
                    descriptionShort,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
                  )),
              Container(child: _buildListView(pois, 'Poi', color, destination))
            ]));
  }

  _buildListView(List<dynamic> items, String key, Color color, destination) {
    final store = Provider.of<TrotterStore>(context);
    return ListView.builder(
      shrinkWrap: true,
      primary: false,
      key: new PageStorageKey(key),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            onTap: () {
              var id = items[index]['id'];
              var level = items[index]['level'];
              onPush({'id': id.toString(), 'level': level.toString()});
            },
            onLongPress: () async {
              var currentUser = store.currentUser;
              if (currentUser == null) {
                loginBottomSheet(context, data, color);
              } else {
                await addToItinerary(context, items, index, color, destination);
              }
            },
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        width: 120,
                        height: 90,
                        margin: EdgeInsets.only(right: 20),
                        child: ClipPath(
                            clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: items[index]['image'] != null
                                ? TransitionToImage(
                                    image: AdvancedNetworkImage(
                                      items[index]['image'],
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
                                  )
                                // CachedNetworkImage(
                                //     placeholder: (context, url) => SizedBox(
                                //         width: 50,
                                //         height: 50,
                                //         child: Align(
                                //             alignment: Alignment.center,
                                //             child: CircularProgressIndicator(
                                //               valueColor:
                                //                   new AlwaysStoppedAnimation<
                                //                       Color>(Colors.blueAccent),
                                //             ))),
                                //     fit: BoxFit.cover,
                                //     imageUrl: items[index]['image'],
                                //     errorWidget: (context, url, error) =>
                                //         Container(
                                //             decoration: BoxDecoration(
                                //           image: DecorationImage(
                                //               image: AssetImage(
                                //                   'images/placeholder.jpg'),
                                //               fit: BoxFit.cover),
                                //         )))
                                : Container(
                                    decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'images/placeholder.jpg'),
                                        fit: BoxFit.cover),
                                  )))),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              width: MediaQuery.of(context).size.width - 210,
                              child: Text(
                                items[index]['name'],
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500),
                              )),
                          Container(
                              margin: EdgeInsets.only(top: 5),
                              width: MediaQuery.of(context).size.width - 210,
                              child: Text(
                                items[index]['description_short'],
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w300),
                              ))
                        ],
                      ),
                    )
                  ],
                )));
      },
    );
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    var children2 = <Widget>[
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
          ' Loading...',
          style: TextStyle(fontSize: 30),
        ),
      ),
      Center(heightFactor: 12, child: RefreshProgressIndicator()),
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
