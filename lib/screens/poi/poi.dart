import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:trotter_flutter/globals.dart';

Future<PoiData> fetchPoi(String id,
    [bool googlePlace, String locationId]) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('poi_$id') ?? null;
  final int cacheDataExpire = prefs.getInt('poi_$id-expiration') ?? null;
  final currentTime = DateTime.now().millisecondsSinceEpoch;
  if (cacheData != null &&
      cacheDataExpire != null &&
      (currentTime < cacheDataExpire)) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return PoiData.fromJson(json.decode(cacheData));
  } else {
    try {
      print('no-cached');
      final response = await http.get(
          '$ApiDomain/api/explore/poi/$id?googlePlace=$googlePlace&locationId=$locationId',
          headers: {'Authorization': 'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('poi_$id', response.body);
        await prefs.setInt('poi_$id-expiration',
            DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch);
        return PoiData.fromJson(json.decode(response.body));
      } else {
        // If that response was not OK, throw an error.
        var msg = response.statusCode;
        return PoiData(error: 'Response> $msg');
      }
    } catch (error) {
      return PoiData(error: 'Server down');
    }
  }
}

class PoiData {
  final String color;
  final Map<String, dynamic> poi;
  final String error;

  PoiData({this.color, this.poi, this.error});

  factory PoiData.fromJson(Map<String, dynamic> json) {
    return PoiData(color: json['color'], poi: json['poi'], error: null);
  }
}

class Poi extends StatefulWidget {
  final String poiId;
  final bool googlePlace;
  final String locationId;
  final ValueChanged<dynamic> onPush;
  Poi({
    Key key,
    @required this.poiId,
    this.onPush,
    this.locationId,
    this.googlePlace,
  }) : super(key: key);
  @override
  PoiState createState() => new PoiState(
      poiId: this.poiId,
      onPush: this.onPush,
      locationId: this.locationId,
      googlePlace: this.googlePlace);
}

class PoiState extends State<Poi> {
  static String id;
  final String poiId;
  final bool googlePlace;
  final String locationId;
  final ValueChanged<dynamic> onPush;
  Completer<GoogleMapController> _controller = Completer();
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  List<dynamic> images = [];
  String image;
  Color color = Colors.transparent;
  String poiName;

  Future<PoiData> data;

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
    data = fetchPoi(this.poiId, this.googlePlace, this.locationId);
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  PoiState({this.locationId, this.googlePlace, this.poiId, this.onPush});

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
                this.images = data.poi['images'];
                this.image = data.poi['image'];
                this.poiName = data.poi['name'];
                this.color = Color(hexStringToHexInt(data.color));
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
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        maxHeight: _panelHeightOpen,
        panel: Center(
            child: FutureBuilder(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.error == null) {
                    return _buildLoadedBody(context, snapshot);
                  } else if (snapshot.hasData && snapshot.data.error != null) {
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
                                    data = fetchPoi(this.poiId);
                                  });
                                },
                              ))
                        ]);
                  }
                  return _buildLoadingBody(context);
                })),
        body: Container(
            height: _bodyHeight,
            child: Stack(children: <Widget>[
              Positioned.fill(
                  top: 0,
                  child: this.image == null
                      ? Container(
                          child: Image(
                              fit: BoxFit.cover,
                              image: AssetImage("images/placeholder.png")),
                        )
                      : TransitionToImage(
                          image: AdvancedNetworkImage(
                            this.image,
                            useDiskCache: true,
                            fallbackAssetImage: "images/placeholder.png",
                            cacheRule:
                                CacheRule(maxAge: const Duration(days: 7)),
                          ),
                          loadingWidgetBuilder:
                              (BuildContext context, double progress, test) =>
                                  Center(
                                      child: RefreshProgressIndicator(
                            backgroundColor: Colors.white,
                          )),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: Container(
                              child: Image(
                                  fit: BoxFit.cover,
                                  image: AssetImage("images/placeholder.png"))),
                          enableRefresh: true,
                        )),
              // this.image == null
              //     ? Positioned(
              //         child: Center(
              //             child: RefreshProgressIndicator(
              //         backgroundColor: Colors.white,
              //       )))
              //     : Container()
            ])),
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              onPush: onPush, color: color, title: this.poiName, back: true)),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    var poi = snapshot.data.poi;
    var properties = poi['properties'];
    var descriptionShort = snapshot.data.poi['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));

    return Container(
        height: MediaQuery.of(ctxt).size.height,
        child: SingleChildScrollView(
          controller: _sc,
          physics: disableScroll
              ? NeverScrollableScrollPhysics()
              : ClampingScrollPhysics(),
          child: ListView(shrinkWrap: true, primary: false, children: <Widget>[
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
              padding:
                  EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
              child: AutoSizeText(
                '${this.poiName} info',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 25),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 40.0, left: 20.0, right: 20.0),
                child: AutoSizeText(descriptionShort,
                    style: TextStyle(
                        fontSize: 13.0, fontWeight: FontWeight.w300))),
            this.images != null && this.images.length > 0
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.only(bottom: 30),
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    child: ClipPath(
                      clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(fit: StackFit.expand, children: <Widget>[
                            TransitionToImage(
                              image: AdvancedNetworkImage(
                                this.images[index]['sizes']['medium']['url'],
                                useDiskCache: true,
                                cacheRule:
                                    CacheRule(maxAge: const Duration(days: 7)),
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
                          ]);
                        },
                        loop: true,
                        indicatorLayout: PageIndicatorLayout.SCALE,
                        itemCount: this.images.length,
                        //transformer: DeepthPageTransformer(),
                        pagination: new SwiperPagination(
                          builder: new SwiperCustomPagination(builder:
                              (BuildContext context,
                                  SwiperPluginConfig config) {
                            return new ConstrainedBox(
                              child: new Align(
                                alignment: Alignment.topCenter,
                                child: new DotSwiperPaginationBuilder(
                                        color: Colors.black.withOpacity(.4),
                                        activeColor: color,
                                        size: 20.0,
                                        activeSize: 20.0)
                                    .build(context, config),
                              ),
                              constraints:
                                  new BoxConstraints.expand(height: 50.0),
                            );
                          }),
                        ),
                      ),
                    ))
                : Container(),
            ListView.separated(
              separatorBuilder: (BuildContext context, int index) =>
                  new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
              padding: EdgeInsets.all(20.0),
              itemCount: properties.length,
              shrinkWrap: true,
              primary: false,
              itemBuilder: (BuildContext context, int index) =>
                  _buildProperties(properties, index),
            ),
            Center(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              margin: EdgeInsets.only(bottom: 20),
              height: 250.0,
              width: double.infinity,
              child: ClipPath(
                  clipper: CornerRadiusClipper(10.0),
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    markers: <Marker>[
                      Marker(
                          markerId: MarkerId(poi['id']),
                          position: LatLng(
                              poi['location']['lat'], poi['location']['lng']))
                    ].toSet(),
                    initialCameraPosition: CameraPosition(
                      bearing: 0.0,
                      target: LatLng(
                          poi['location']['lat'], poi['location']['lng']),
                      tilt: 30.0,
                      zoom: 17.0,
                    ),
                  )),
            )),
          ]),
        ));
  }

  _buildProperties(List<dynamic> properties, int index) {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: 10.0),
                child: AutoSizeText(
                  '${properties[index]['name']}:',
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
                )),
            Flexible(
                child: AutoSizeText(
              properties[index]['value'],
              //maxLines: 2,
              //overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w300),
            )),
          ],
        ));
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
        child: AutoSizeText(
          ' Loading...',
          style: TextStyle(fontSize: 25),
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
