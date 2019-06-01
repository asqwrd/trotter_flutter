import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:cached_network_image/cached_network_image.dart';

Future<PoiData> fetchPoi(String id,
    [bool googlePlace, String locationId]) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('poi_$id') ?? null;
  if (cacheData != null) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return PoiData.fromJson(json.decode(cacheData));
  } else {
    try {
      print('no-cached');
      final response = await http.get(
          'http://localhost:3002/api/explore/poi/$id?googlePlace=$googlePlace&locationId=$locationId',
          headers: {'Authorization': 'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('poi_$id', response.body);
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
  bool _showTitle = false;
  static String id;
  final String poiId;
  final bool googlePlace;
  final String locationId;
  final ValueChanged<dynamic> onPush;
  GoogleMapController mapController;
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
          else
            if (data.error == null)
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
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        maxHeight: _panelHeightOpen,
        panel: Center(
            child: FutureBuilder(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data.error == null) {
                    return _buildLoadedBody(context, snapshot);
                  } else if (snapshot.hasData && snapshot.data.error != null) {
                    return ErrorContainer(
                      onRetry: () {
                        setState(() {
                          data = fetchPoi(this.poiId);
                        });
                      },
                    );
                  }
                  return _buildLoadingBody(context);
                })),
        body: Container(
            height: _bodyHeight,
            child: Stack(children: <Widget>[
              Positioned.fill(
                  top: 0,
                  child: this.image == null
                      ? Container()
                      : CachedNetworkImage(
                          imageUrl: this.image,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: (context, url) => SizedBox(
                              width: 50,
                              height: 50,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.blueAccent),
                                  ))))),
              this.image == null
                  ? Positioned(
                      child: Center(
                          child: RefreshProgressIndicator(
                      backgroundColor: Colors.white,
                    )))
                  : Container()
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
    var name = snapshot.data.poi['name'];
    var poi = snapshot.data.poi;
    var properties = poi['properties'];
    var images = snapshot.data.poi['images'];
    var descriptionShort = snapshot.data.poi['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));

    void _onMapCreated(GoogleMapController controller) {
      setState(() {
        mapController = controller;
        mapController.addMarker(MarkerOptions(
          position: LatLng(poi['location']['lat'], poi['location']['lng']),
        ));
        /*mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 270.0,
            target: LatLng(poi['location']['lat'], poi['location']['lng']),
            tilt: 30.0,
            zoom: 17.0,
          ),
        ));*/
      });
    }

    return Container(
        height: MediaQuery.of(ctxt).size.height,
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
                '${this.poiName} info',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(bottom: 40.0, left: 20.0, right: 20.0),
                child: Text(descriptionShort,
                    style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.w300))),
            Container(
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
                        CachedNetworkImage(
                          placeholder: (context, url) => SizedBox(
                              width: 50,
                              height: 50,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            color),
                                  ))),
                          imageUrl: this.images[index]['sizes']['original']
                              ['url'],
                          fit: BoxFit.cover,
                        )
                      ]);
                    },
                    loop: true,
                    indicatorLayout: PageIndicatorLayout.SCALE,
                    itemCount: this.images.length,
                    //transformer: DeepthPageTransformer(),
                    pagination: new SwiperPagination(
                      builder: new SwiperCustomPagination(builder:
                          (BuildContext context, SwiperPluginConfig config) {
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
                          constraints: new BoxConstraints.expand(height: 50.0),
                        );
                      }),
                    ),
                  ),
                )),
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
                    onMapCreated: _onMapCreated,
                    options: GoogleMapOptions(
                      cameraPosition: CameraPosition(
                        bearing: 0.0,
                        target: LatLng(
                            poi['location']['lat'], poi['location']['lng']),
                        tilt: 30.0,
                        zoom: 17.0,
                      ),
                    ),
                  )),
            )),
          ],
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
                child: Text(
                  '${properties[index]['name']}:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                )),
            Flexible(
                child: Text(
              properties[index]['value'],
              //maxLines: 2,
              //overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
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
