import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/itineraries/start-location-modal.dart';
import 'package:trotter_flutter/widgets/itinerary-list/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItineraryBuilder extends StatefulWidget {
  final String itineraryId;
  final Color color;
  final ValueChanged<dynamic> onPush;
  ItineraryBuilder(
      {Key key, @required this.itineraryId, this.onPush, this.color})
      : super(key: key);
  @override
  ItineraryBuilderState createState() => new ItineraryBuilderState(
      itineraryId: this.itineraryId, onPush: this.onPush, color: this.color);
}

class ItineraryBuilderState extends State<ItineraryBuilder> {
  static String id;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  List<dynamic> hotels;
  dynamic destination;
  Color color = Colors.transparent;
  String itineraryName;
  Future<ItineraryData> data;
  int startDate = 0;
  GlobalKey _one = GlobalKey();
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
    data = fetchItineraryBuilder(this.itineraryId);
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  ItineraryBuilderState({this.itineraryId, this.onPush, this.color});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;
    double _panelHeightClosed = (MediaQuery.of(context).size.height / 2) - 50;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String cacheData =
          prefs.getString('itineraryBuilderShowcase') ?? null;
      if (cacheData == null) {
        ShowCaseWidget.of(context).startShowCase([_one]);
        await prefs.setString('itineraryBuilderShowcase', "true");
      }
    });
    final store = Provider.of<TrotterStore>(context);
    data.then((res) {
      if (res.error != null) {
        setState(() {
          this.errorUi = true;
        });
      } else {
        setState(() {
          this.errorUi = false;
          this.image = res.destination['image'];
          this.destination = res.destination;
          this.itineraryName = res.itinerary['name'];
          this.startDate = res.itinerary['start_date'] * 1000;
          this.color = Color(hexStringToHexInt(res.color));
          this.hotels = res.hotels;
          this.loading = false;
          store.itineraryStore.setItineraryBuilder(
            res.itinerary,
            res.destination,
            res.color,
          );
          store.itineraryStore.setItineraryBuilderLoading(false);
        });
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
        backdropOpacity: 1,
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
                  return _buildLoadedBody(context, store);
                })),
        body: Container(
            height: _bodyHeight,
            child: Stack(children: <Widget>[
              Positioned(
                  width: MediaQuery.of(context).size.width,
                  height: _bodyHeight,
                  top: 0,
                  left: 0,
                  child: this.image != null && this.loading == false
                      ? TransitionToImage(
                          image: AdvancedNetworkImage(
                            this.image,
                            useDiskCache: true,
                            cacheRule:
                                CacheRule(maxAge: const Duration(days: 7)),
                          ),
                          loadingWidgetBuilder:
                              (BuildContext context, double progress, test) =>
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
              this.image == null || this.imageLoading
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
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              loading: loading,
              onPush: onPush,
              color: color,
              title: this.itineraryName,
              actions: <Widget>[
                Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    child: Showcase.withWidget(
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        width: 250,
                        height: 50,
                        container: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                                width: 250,
                                child: Text(
                                  'Tap to open location modal.\nSelect a starting location to use for each day',
                                  style: TextStyle(color: Colors.white),
                                  maxLines: 3,
                                ))
                          ],
                        ),
                        key: _one,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          onPressed: () async {
                            final store = Provider.of<TrotterStore>(context);

                            var latlng = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (context) => StartLocationModal(
                                          hotels: this.hotels,
                                          destination: this.destination,
                                        )));

                            if (latlng != null) {
                              final response = await updateStartLocation(
                                  this.itineraryId, latlng, store);
                              if (response.success == true) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: AutoSizeText(
                                      'Updated start location',
                                      style: TextStyle(fontSize: 13)),
                                  duration: Duration(seconds: 5),
                                ));
                              } else {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: AutoSizeText(
                                      'Failed to update start location',
                                      style: TextStyle(fontSize: 13)),
                                  duration: Duration(seconds: 5),
                                ));
                              }
                            }
                          },
                          child: SvgPicture.asset("images/place-icon.svg",
                              width: 25.0,
                              height: 25.0,
                              color: fontContrast(color),
                              fit: BoxFit.cover),
                        ))),
              ],
              back: true)),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, TrotterStore store) {
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    if (this.errorUi == true) {
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
                    store.itineraryStore.setItineraryBuilderLoading(true);
                    data = fetchItineraryBuilder(this.itineraryId, store);
                    store.itineraryStore.setItineraryBuilderLoading(false);
                  },
                ))
          ]);
    }
    if (store.itineraryStore.itineraryBuilder.itinerary == null ||
        store.itineraryStore.itineraryBuilder.loading ||
        store.itineraryStore.itineraryBuilder.itinerary['id'] !=
            this.itineraryId) {
      return _buildLoadingBody(ctxt);
    }

    var itinerary = store.itineraryStore.itineraryBuilder.itinerary;
    var startLocation = itinerary['start_location'] != null
        ? itinerary['start_location']['location']
        : itinerary['location'];
    var destinationName = itinerary['destination_name'];
    var destinationCountryName = itinerary['destination_country_name'];
    var days = itinerary['days'];
    var color =
        Color(hexStringToHexInt(store.itineraryStore.itineraryBuilder.color));

    return Container(
        height: MediaQuery.of(context).size.height,
        child: _buildDay(days, destinationName, destinationCountryName,
            itinerary['destination'], color, startLocation));
  }

  _buildDay(
      List<dynamic> days,
      String destinationName,
      String destinationCountryName,
      String locationId,
      Color color,
      dynamic startLocation) {
    var dayBuilder = ['', '', ...days];
    return ListView.separated(
      controller: _sc,
      physics: disableScroll
          ? NeverScrollableScrollPhysics()
          : ClampingScrollPhysics(),
      separatorBuilder: (BuildContext serperatorContext, int index) => index > 1
          ? new Container(
              margin: EdgeInsets.only(bottom: 40, top: 40),
              child: Divider(color: Color.fromRGBO(0, 0, 0, 0.3)))
          : Container(),
      padding: EdgeInsets.all(20.0),
      itemCount: dayBuilder.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext listContext, int dayIndex) {
        if (dayIndex == 0) {
          return Center(
              child: Container(
            width: 30,
            height: 5,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
          ));
        }

        if (dayIndex == 1) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 10, bottom: 40),
            child: AutoSizeText(
              '$destinationName, $destinationCountryName',
              style: TextStyle(fontSize: 25),
            ),
          );
        }
        var itineraryItems = dayBuilder[dayIndex]['itinerary_items'];
        var dayId = dayBuilder[dayIndex]['id'];
        final formatter = DateFormat.yMMMMd("en_US");

        return InkWell(
            onTap: () => onPush({
                  'itineraryId': this.itineraryId,
                  'dayId': dayId,
                  "linkedItinerary": dayBuilder[dayIndex]['linked_itinerary'],
                  "startLocation": startLocation,
                  'level': 'itinerary/day/edit'
                }),
            child: Column(children: <Widget>[
              Column(children: <Widget>[
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        child: AutoSizeText(
                      'Your ${ordinalNumber(dayBuilder[dayIndex]['day'] + 1)} day in $destinationName',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ))),
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        child: AutoSizeText(
                      formatter.format(DateTime.fromMillisecondsSinceEpoch(
                              this.startDate,
                              isUtc: true)
                          .add(Duration(days: dayBuilder[dayIndex]['day']))),
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                    ))),
                Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: AutoSizeText(
                          '${itineraryItems.length} ${itineraryItems.length == 1 ? "place" : "places"} to see',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w300),
                        )))
              ]),
              itineraryItems.length > 0 ||
                      dayBuilder[dayIndex]['linked_itinerary'] != null
                  ? Container(
                      margin: EdgeInsets.only(top: 0),
                      child: ItineraryList(
                        items: itineraryItems,
                        linkedItinerary: dayBuilder[dayIndex]
                            ['linked_itinerary'],
                        color: color,
                        onPressed: (data) {
                          onPush({
                            'itineraryId': this.itineraryId,
                            'dayId': dayId,
                            'color': this.color,
                            'linkedItinerary': dayBuilder[dayIndex]
                                ['linked_itinerary'],
                            "startLocation": startLocation,
                            'level': 'itinerary/day/edit'
                          });
                        },
                        onLongPressed: (data) {},
                      ))
                  : Container(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: SvgPicture.asset(
                            'images/itinerary-icon.svg',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        FlatButton(
                          onPressed: () {
                            onPush({
                              'itineraryId': this.itineraryId,
                              'color': this.color,
                              'dayId': dayId,
                              'linkedItinerary': dayBuilder[dayIndex]
                                  ['linked_itinerary'],
                              "startLocation": startLocation,
                              'level': 'itinerary/day/edit'
                            });
                          },
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: AutoSizeText('Start planning',
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15)),
                        )
                      ],
                    ))
            ]));
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
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
      )),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 10, bottom: 20),
        child: AutoSizeText(
          'Getting itinerary...',
          style: TextStyle(fontSize: 25),
        ),
      ),
      Flexible(child: ItineraryListLoading()),
    ];
    return Container(
      padding: EdgeInsets.only(top: 0.0, left: 20, right: 20),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        // controller: _sc,
        // physics: disableScroll
        //     ? NeverScrollableScrollPhysics()
        //     : ClampingScrollPhysics(),
        children: children2,
      ),
    );
  }
}
