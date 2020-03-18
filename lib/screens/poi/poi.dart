import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/globals.dart';
import 'package:trotter_flutter/widgets/images/image-swiper.dart';
import 'package:trotter_flutter/widgets/itineraries/bottomsheet.dart';
import 'package:trotter_flutter/widgets/map/static-map.dart';
import 'package:timeago/timeago.dart' as timeago;

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
          headers: {'Authorization': APITOKEN});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('poi_$id', response.body);
        await prefs.setInt('poi_$id-expiration',
            DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch);
        var poi = PoiData.fromJson(json.decode(response.body));
        var openNow = poi.poi['opening_hours']['open_now'];
        if (poi.poi['properties'] != null && openNow != null) {
          poi.poi['properties'].add({
            "key": "open_now",
            "name": "Open now",
            "value": openNow == true ? 'Yes' : 'No'
          });
        }
        return poi;
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
  final dynamic destination;

  PoiData({this.color, this.poi, this.error, this.destination});

  factory PoiData.fromJson(Map<String, dynamic> json) {
    return PoiData(color: json['color'], poi: json['poi'], error: null);
  }
}

class Poi extends StatefulWidget {
  final String poiId;
  final bool googlePlace;
  final String locationId;
  final dynamic destination;
  final Future2VoidFunc onPush;
  Poi({
    Key key,
    @required this.poiId,
    this.onPush,
    this.locationId,
    this.destination,
    this.googlePlace,
  }) : super(key: key);
  @override
  PoiState createState() => new PoiState(
      poiId: this.poiId,
      onPush: this.onPush,
      destination: this.destination,
      locationId: this.locationId,
      googlePlace: this.googlePlace);
}

class PoiState extends State<Poi> {
  static String id;
  final String poiId;
  final bool googlePlace;
  final dynamic destination;
  final String locationId;
  final Future2VoidFunc onPush;
  //Completer<GoogleMapController> _controller = Completer();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  List<dynamic> images = [];
  String image;
  Color color = Colors.blueGrey;
  String poiName;
  dynamic poi;
  bool addedToItinerary = false;
  bool imageLoading = true;
  bool shadow = false;

  Future<PoiData> data;

  @override
  void initState() {
    super.initState();

    data = fetchPoi(this.poiId, this.googlePlace, this.locationId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  PoiState(
      {this.locationId,
      this.googlePlace,
      this.poiId,
      this.onPush,
      this.destination});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;
    data.then((data) {
      if (data.error != null) {
        setState(() {
          this.errorUi = true;
          this.loading = false;
        });
      } else if (data.error == null) {
        setState(() {
          this.errorUi = false;
          this.images = data.poi['images'];
          this.image = data.poi['image'];
          this.loading = false;
          if (this.image == null) {
            this.image = '';
          }
          this.poiName = data.poi['name'];
          this.poi = data.poi;
          this.color = Color(hexStringToHexInt(data.color));
        });
      }
    });
    final panelHeights = getPanelHeights(context);

    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, {"addedToItinerary": this.addedToItinerary});
          return;
        },
        child: Stack(alignment: Alignment.topCenter, children: <Widget>[
          Positioned(
              child: SlidingUpPanel(
            backdropColor: color,
            backdropEnabled: true,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            backdropOpacity: 1,
            maxHeight: panelHeights.max,
            minHeight: panelHeights.min,
            defaultPanelState:
                this.errorUi == true ? PanelState.OPEN : PanelState.CLOSED,
            parallaxEnabled: true,
            parallaxOffset: .5,
            controller: _pc,
            body: Container(
                height: _bodyHeight,
                child: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: this.image != null
                          ? TransitionToImage(
                              image: this.image.length > 0
                                  ? AdvancedNetworkImage(
                                      this.image,
                                      useDiskCache: true,
                                      cacheRule: CacheRule(
                                          maxAge: const Duration(days: 7)),
                                    )
                                  : AssetImage("images/placeholder.png"),
                              loadingWidgetBuilder: (BuildContext context,
                                      double progress, test) =>
                                  Container(),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              placeholder: Container(
                                  child: Image(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                          "images/placeholder.png"))),
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
                ])),
            panelBuilder: (sc) {
              return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Container(
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
                        this.loading
                            ? Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: 10, bottom: 20),
                                child: AutoSizeText(
                                  ' Loading...',
                                  style: TextStyle(fontSize: 23),
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 20, left: 20, right: 20),
                                child: AutoSizeText(
                                  'About ${this.poiName}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 23),
                                ),
                              ),
                      ],
                    )),
                Expanded(
                    child: Center(
                        child: FutureBuilder(
                            future: data,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.data.error == null) {
                                return RenderWidget(
                                    onScroll: onScroll,
                                    scrollController: sc,
                                    asyncSnapshot: snapshot,
                                    builder: (context,
                                            {scrollController,
                                            asyncSnapshot,
                                            startLocation}) =>
                                        _buildLoadedBody(context, asyncSnapshot,
                                            scrollController));
                              } else if (snapshot.hasData &&
                                  snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.data.error != null) {
                                return SingleChildScrollView(
                                    controller: sc,
                                    child: ErrorContainer(
                                      onRetry: () {
                                        setState(() {
                                          data = fetchPoi(this.poiId);
                                        });
                                      },
                                    ));
                              }
                              return _buildLoadingBody(context, sc);
                            }))),
              ]);
            },
          )),
          Positioned(
              top: 0,
              width: MediaQuery.of(context).size.width,
              child: new TrotterAppBar(
                loading: loading,
                onPush: onPush,
                showSearch: false,
                color: color,
                title: this.poiName,
                back: true,
                destination: this.destination,
                actions: <Widget>[
                  this.destination != null
                      ? Container(
                          width: 58,
                          height: 58,
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100)),
                            onPressed: () async {
                              this.poi['google_place'] = this.googlePlace;
                              var result = await addToItinerary(
                                  context, this.poi, color, destination);

                              if (result != null &&
                                  result['selected'] != null &&
                                  result['dayId'] != null &&
                                  result['itinerary'] != null &&
                                  result['poi'] != null &&
                                  result['dayIndex'] != null) {
                                //Navigator.of(context).pop();
                                setState(() {
                                  this.addedToItinerary = true;
                                });

                                await showSuccessSnackbar(context,
                                    onPush: onPush,
                                    dayId: result['dayId'],
                                    dayIndex: result['dayIndex'],
                                    itinerary: result['itinerary'],
                                    poi: result['poi']);
                              } else if (result != null &&
                                  result['exist'] != null &&
                                  result['success'] != null &&
                                  result['poi'] != null &&
                                  result['itinerary'] != null) {
                                await showSuccessWishlistSnackbar(context,
                                    poi: result['poi'],
                                    itinerary: result['itinerary'],
                                    exist: result['exist']);
                              }
                            },
                            child: SvgPicture.asset("images/add-icon.svg",
                                width: 24.0,
                                height: 24.0,
                                color: fontContrast(color),
                                fit: BoxFit.contain),
                          ))
                      : null
                ],
              )),
        ]));
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

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, ScrollController _sc) {
    var poi = snapshot.data.poi;
    List<dynamic> properties = poi['properties'];
    List<dynamic> reviews = poi['reviews'];
    if (reviews != null) {
      reviews.sort((a, b) => b['time'].compareTo(a['time']));
    } else {
      reviews = [];
    }

    var descriptionShort = snapshot.data.poi['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));

    return Container(
        height: MediaQuery.of(ctxt).size.height,
        child: SingleChildScrollView(
          controller: _sc,
          child: ListView(shrinkWrap: true, primary: false, children: <Widget>[
            Padding(
                padding: EdgeInsets.only(bottom: 40.0, left: 20.0, right: 20.0),
                child: AutoSizeText(descriptionShort,
                    style: TextStyle(
                        fontSize: 13.0, fontWeight: FontWeight.w300))),
            this.images != null && this.images.length > 0
                ? ImageSwiper(context: context, images: images, color: color)
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
                    margin: EdgeInsets.only(bottom: 40),
                    height: 250.0,
                    width: MediaQuery.of(context).size.width,
                    child: StaticMap(GOOGLE_API_KEY,
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        color: this.color,
                        placeId: poi['id'],
                        zoom: 18,
                        lat: poi['location']['lat'],
                        lng: poi['location']['lng']))),
            reviews.length > 0
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        AutoSizeText(
                          'Google Reviews',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            width: 100,
                            child: RatingBar.readOnly(
                              initialRating: poi['score'].toDouble(),
                              size: 20,
                              isHalfAllowed: true,
                              halfFilledIcon: Icons.star_half,
                              filledIcon: Icons.star,
                              emptyIcon: Icons.star_border,
                            )),
                        AutoSizeText(
                          '${poi['score']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ))
                : Container(),
            ListView.separated(
              separatorBuilder: (BuildContext context, int index) =>
                  new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
              padding: EdgeInsets.all(20.0),
              itemCount: reviews.length,
              shrinkWrap: true,
              primary: false,
              itemBuilder: (BuildContext context, int index) =>
                  _buildReviews(reviews, index),
            ),
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

  _buildReviews(List<dynamic> reviews, int index) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
            leading: Container(
              width: 35.0,
              height: 35.0,
              child: CircleAvatar(
                  child: TransitionToImage(
                image: AdvancedNetworkImage(
                  reviews[index]['profile_photo_url'],
                  useDiskCache: true,
                  cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                ),
                loadingWidgetBuilder:
                    (BuildContext context, double progress, test) => Center(
                        child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                )),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                placeholder: const Icon(Icons.refresh),
                enableRefresh: true,
              )),
            ),
            title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AutoSizeText(
                    '${reviews[index]['author_name']}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Container(
                      width: 100,
                      child: RatingBar.readOnly(
                        initialRating: reviews[index]['rating'].toDouble(),
                        size: 20,
                        isHalfAllowed: true,
                        halfFilledIcon: Icons.star_half,
                        filledIcon: Icons.star,
                        emptyIcon: Icons.star_border,
                      )),
                ]),
            trailing: AutoSizeText(timeago.format(
                DateTime.fromMillisecondsSinceEpoch(
                    reviews[index]['time'] * 1000))),
            subtitle: AutoSizeText(
              reviews[index]['text'],
              //maxLines: 2,
              //overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
            )));
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt, ScrollController _sc) {
    var children2 = <Widget>[];
    return Container(
      padding: EdgeInsets.only(top: 0.0),
      decoration: BoxDecoration(color: Colors.transparent),
      child: ListView(
        controller: _sc,
        children: children2,
      ),
    );
  }
}
