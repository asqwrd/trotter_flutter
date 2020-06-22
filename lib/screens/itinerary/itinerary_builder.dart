import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
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
import 'package:trotter_flutter/widgets/poi/poi-modal.dart';

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
  bool shadow = false;
  bool isPublic = false;

  @override
  void initState() {
    super.initState();
    data = fetchItineraryBuilder(this.itineraryId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  ItineraryBuilderState({this.itineraryId, this.onPush, this.color});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;
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
          this.isPublic = res.itinerary['public'];
          store.itineraryStore.setItineraryBuilder(
            res.itinerary,
            res.destination,
            res.color,
          );
          store.itineraryStore.setItineraryBuilderLoading(false);
        });
      }
    });
    var itinerary = store.itineraryStore.itineraryBuilder.itinerary;
    var destinationName =
        itinerary != null ? itinerary['destination_name'] : '';
    var destinationCountryName =
        itinerary != null ? itinerary['destination_country_name'] : '';
    final panelHeights = getPanelHeights(context);

    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: Scaffold(
              floatingActionButton: FloatingActionButton(
                backgroundColor: color,
                child: SvgPicture.asset(
                  'images/pin_list.svg',
                  width: 25,
                  height: 25,
                  color: fontContrast(color),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) {
                            return WishlistModal(
                              itineraryId: this.itineraryId,
                              onPush: onPush,
                              title: 'Pin List',
                            );
                          }));
                },
              ),
              body: SlidingUpPanel(
                backdropColor: color,
                backdropEnabled: true,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                backdropOpacity: 1,
                maxHeight: panelHeights.max,
                minHeight: panelHeights.min,
                defaultPanelState:
                    this.errorUi == true ? PanelState.OPEN : PanelState.CLOSED,
                parallaxEnabled: true,
                parallaxOffset: .5,
                controller: _pc,
                panelBuilder: (sc) {
                  return Column(mainAxisSize: MainAxisSize.min, children: <
                      Widget>[
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
                            itinerary == null || this.loading == true
                                ? Container(
                                    alignment: Alignment.center,
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 20),
                                    child: AutoSizeText(
                                      'Getting itinerary...',
                                      style: TextStyle(fontSize: 23),
                                    ),
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 20),
                                    child: AutoSizeText(
                                      '$destinationName, $destinationCountryName',
                                      style: TextStyle(fontSize: 23),
                                    ),
                                  )
                          ],
                        )),
                    Expanded(
                        child: Center(
                            child: FutureBuilder(
                                future: data,
                                builder: (context, snapshot) {
                                  return RenderWidget(
                                      scrollController: sc,
                                      onScroll: onScroll,
                                      asyncSnapshot: snapshot,
                                      builder: (context,
                                              {scrollController,
                                              asyncSnapshot,
                                              startLocation}) =>
                                          _buildLoadedBody(context, store,
                                              scrollController));
                                })))
                  ]);
                },
                body: Container(
                    height: _bodyHeight,
                    child: Stack(children: <Widget>[
                      Positioned(
                          width: MediaQuery.of(context).size.width,
                          height: _bodyHeight,
                          top: 0,
                          left: 0,
                          child: this.image != null && this.loading == false
                              ? TrotterImage(
                                  imageUrl: this.image,
                                  onLoadedFailed: (value) async {
                                    //await Future.delayed(Duration(seconds: 2));
                                    if (this.imageLoading == true) {
                                      setState(() {
                                        this.imageLoading = false;
                                      });
                                    }
                                  },
                                  onLoaded: (value) async {
                                    //await Future.delayed(Duration(seconds: 2));
                                    if (this.imageLoading == true) {
                                      setState(() {
                                        this.imageLoading = false;
                                      });
                                    }
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
              ))),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              loading: loading,
              onPush: onPush,
              color: color,
              showSearch: false,
              title: this.itineraryName,
              actions: <Widget>[
                Container(
                    width: 58,
                    height: 58,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      onPressed: () {
                        var days = itinerary['days'];
                        final currentTime = DateTime.now();
                        final tempDay = DateTime.fromMillisecondsSinceEpoch(
                                this.startDate,
                                isUtc: false)
                            .add(Duration(days: days[days.length - 1]['day']));
                        final compareDay = DateTime(
                            tempDay.year,
                            tempDay.month,
                            tempDay.day,
                            currentTime.hour,
                            currentTime.minute,
                            currentTime.second,
                            currentTime.millisecond,
                            currentTime.microsecond);

                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext buildercontext) {
                              return ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  Container(
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: Colors.black
                                                      .withOpacity(0.1)))),
                                      child: StatefulSwitch(
                                        disabled:
                                            compareDay.isAfter(currentTime) ||
                                                this.startDate == 0 ||
                                                this.startDate == null,
                                        disableMessage: AutoSizeText(
                                          'Cannot make itinerary public until after your trip',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        title: AutoSizeText(
                                          'Public',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        value: this.isPublic,
                                        color: color,
                                        onChanged: (value) async {
                                          final response = await togglePublic(
                                              store, this.itineraryId);
                                          if (response.success == true) {
                                            setState(() {
                                              this.isPublic = value;
                                              store.itineraryStore
                                                  .toggleItineraryBuilderPublic(
                                                      value);
                                            });
                                          }
                                        },
                                      )),
                                  ListTile(
                                    onTap: () async {
                                      final store =
                                          Provider.of<TrotterStore>(context);

                                      var latlng = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              fullscreenDialog: true,
                                              builder: (context) =>
                                                  StartLocationModal(
                                                    hotels: this.hotels,
                                                    destination:
                                                        this.destination,
                                                  )));

                                      if (latlng != null) {
                                        final response =
                                            await updateStartLocation(
                                                this.itineraryId,
                                                latlng,
                                                store);
                                        if (response.success == true) {
                                          setState(() {
                                            store.itineraryStore
                                                .updateStartLocation(
                                                    response.startLocation);
                                            Navigator.pop(context);
                                          });
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                            content: AutoSizeText(
                                                'Updated start location',
                                                style: TextStyle(fontSize: 13)),
                                            duration: Duration(seconds: 2),
                                          ));
                                        } else {
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                            content: AutoSizeText(
                                                'Failed to update start location',
                                                style: TextStyle(fontSize: 13)),
                                            duration: Duration(seconds: 3),
                                          ));
                                        }
                                      }
                                    },
                                    title: AutoSizeText('Update start location',
                                        style: TextStyle(fontSize: 16)),
                                  )
                                ],
                              );
                            });
                      },
                      child: SvgPicture.asset("images/setting-icon.svg",
                          width: 35,
                          height: 35,
                          color: fontContrast(color),
                          fit: BoxFit.cover),
                    )),
                Container(
                    width: 58,
                    height: 58,
                    margin: EdgeInsets.symmetric(horizontal: 0),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100)),
                      onPressed: () async {
                        store.itineraryStore.setItineraryBuilderLoading(true);
                        data = fetchItineraryBuilder(this.itineraryId, store);
                      },
                      child: SvgPicture.asset("images/refresh_icon.svg",
                          width: 24.0,
                          height: 24.0,
                          color: fontContrast(color),
                          fit: BoxFit.contain),
                    )),
              ],
              back: true)),
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

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, TrotterStore store,
      ScrollController scrollController) {
    if (this.errorUi == true) {
      return SingleChildScrollView(
          controller: scrollController,
          child: ErrorContainer(
            onRetry: () {
              store.itineraryStore.setItineraryBuilderLoading(true);
              data = fetchItineraryBuilder(this.itineraryId, store);
            },
          ));
    }
    if (store.itineraryStore.itineraryBuilder.itinerary == null ||
        store.itineraryStore.itineraryBuilder.loading == true ||
        store.itineraryStore.itineraryBuilder.itinerary['id'] !=
            this.itineraryId) {
      return RenderWidget(
          scrollController: scrollController,
          onScroll: onScroll,
          builder: (ctxt, {scrollController, asyncSnapshot, startLocation}) =>
              _buildLoadingBody(ctxt, scrollController));
    }

    var itinerary = store.itineraryStore.itineraryBuilder.itinerary;
    var startLocation = itinerary['start_location'] != null
        ? itinerary['start_location']['location']
        : itinerary['location'];
    //print(startLocation);
    var destinationName = itinerary['destination_name'];
    var destinationCountryName = itinerary['destination_country_name'];
    var days = itinerary['days'];
    var color =
        Color(hexStringToHexInt(store.itineraryStore.itineraryBuilder.color));

    return Container(
        height: MediaQuery.of(context).size.height,
        child: RenderWidget(
            onScroll: onScroll,
            scrollController: scrollController,
            startLocation: startLocation,
            builder: (context,
                {scrollController, asyncSnapshot, startLocation}) {
              return _buildDay(days, destinationName, destinationCountryName,
                  itinerary['destination'], color, scrollController, store);
            }));
  }

  _buildDay(
      List<dynamic> days,
      String destinationName,
      String destinationCountryName,
      String locationId,
      Color color,
      ScrollController scrollController,
      TrotterStore store) {
    var dayBuilder = days;
    return ListView.separated(
      controller: scrollController,
      separatorBuilder: (BuildContext serperatorContext, int index) =>
          new Container(
              margin: EdgeInsets.only(bottom: 40, top: 40),
              child: Divider(color: Color.fromRGBO(0, 0, 0, 0.3))),
      padding: EdgeInsets.all(20.0),
      itemCount: dayBuilder.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext listContext, int dayIndex) {
        var itineraryItems = dayBuilder[dayIndex]['itinerary_items'];
        var dayId = dayBuilder[dayIndex]['id'];
        final formatter = DateFormat.yMMMMEEEEd("en_US");

        final currentTime = DateTime.now();
        final tempDay =
            DateTime.fromMillisecondsSinceEpoch(this.startDate, isUtc: false)
                .add(Duration(days: dayBuilder[dayIndex]['day']));
        final compareDay = DateTime(
            tempDay.year,
            tempDay.month,
            tempDay.day,
            currentTime.hour,
            currentTime.minute,
            currentTime.second,
            currentTime.millisecond,
            currentTime.microsecond);

        var itinerary = store.itineraryStore.itineraryBuilder.itinerary;
        final startLocation = itinerary['start_location'] != null
            ? itinerary['start_location']['location']
            : itinerary['location'];

        //print(startLocation);

        return Opacity(
            opacity: this.startDate != null &&
                    this.startDate > 0 &&
                    compareDay.isBefore(currentTime)
                ? 0.5
                : 1,
            child: InkWell(
                onTap: () {
                  onPush({
                    'itineraryId': this.itineraryId,
                    'dayId': dayId,
                    "linkedItinerary": dayBuilder[dayIndex]['linked_itinerary'],
                    "startLocation": startLocation,
                    'level': 'itinerary/day/edit'
                  });
                },
                child: Column(children: <Widget>[
                  Column(children: <Widget>[
                    Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                            child: AutoSizeText(
                          'Your ${ordinalNumber(dayBuilder[dayIndex]['day'] + 1)} day in $destinationName',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ))),
                    this.startDate != null && this.startDate != 0
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                                child: AutoSizeText(
                              formatter.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          this.startDate,
                                          isUtc: true)
                                      .add(Duration(
                                          days: dayBuilder[dayIndex]['day']))),
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
                            )))
                        : Container(),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: AutoSizeText(
                              '${itineraryItems.length} ${itineraryItems.length == 1 ? "place" : "places"} to see',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
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
                            onRefreshImage: (data) {
                              final store = Provider.of<TrotterStore>(context);
                              final itemIndex = data['index'];
                              final poi = data['poi'];
                              final itineraryItemId = data['itineraryItemId'];

                              updatePoiImageEdit(
                                  itineraryId,
                                  dayId,
                                  itineraryItemId,
                                  poi['id'],
                                  itemIndex,
                                  dayIndex,
                                  store);
                            },
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
                                      fontSize: 13)),
                            )
                          ],
                        ))
                ])));
      },
    );
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(
      BuildContext ctxt, ScrollController scrollController) {
    var children2 = <Widget>[
      Container(child: ItineraryListLoading()),
    ];
    double _panelHeightOpen = MediaQuery.of(ctxt).size.height - 130;
    return Container(
      height: _panelHeightOpen,
      width: MediaQuery.of(ctxt).size.width,
      padding: EdgeInsets.only(top: 0.0, left: 20, right: 20),
      decoration: BoxDecoration(color: Colors.transparent),
      child: ListView(
        shrinkWrap: true,
        controller: scrollController,
        children: children2,
      ),
    );
  }
}
