import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/comments/index.dart';
import 'package:trotter_flutter/widgets/day-list/index.dart';
import 'package:trotter_flutter/widgets/errors/cannot-view.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:trotter_flutter/widgets/itineraries/index.dart';
import 'package:intl/intl.dart';

class DayEdit extends StatefulWidget {
  final String dayId;
  final String itineraryId;
  final dynamic startLocation;
  final ValueChanged<dynamic> onPush;
  DayEdit(
      {Key key,
      @required this.dayId,
      this.startLocation,
      this.itineraryId,
      this.onPush})
      : super(key: key);
  @override
  DayEditState createState() => new DayEditState(
      dayId: this.dayId,
      itineraryId: this.itineraryId,
      startLocation: this.startLocation,
      onPush: this.onPush);
}

class DayEditState extends State<DayEdit> {
  final String dayId;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  Color color = Colors.transparent;
  String destinationName;
  String destinationId;
  dynamic destination;
  dynamic startLocation;
  dynamic location;
  List<dynamic> itineraryItems = [];
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  String ownerId;
  String tripId;
  String itineraryName;
  dynamic currentPosition;
  int startDate;

  Future<DayData> data;
  TrotterStore store;
  bool canView = true;

  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();

  @override
  void initState() {
    super.initState();
    getLocationPermission().then((res) {
      _sc.addListener(() {
        setState(() {
          if (_pc.isPanelOpen()) {
            disableScroll = _sc.offset <= 0;
          }
        });
      });

      data = fetchDay(this.itineraryId, this.dayId, this.startLocation);
      data.then((data) {
        if (data.error == null) {
          setState(() {
            this.canView = data.itinerary['travelers']
                .any((traveler) => store.currentUser.uid == traveler);
            this.color = Color(hexStringToHexInt(data.color));
            this.itineraryName = data.itinerary['name'];
            this.ownerId = data.itinerary['owner_id'];
            this.tripId = data.itinerary['trip_id'];
            this.startDate = data.itinerary['start_date'] * 1000;
            this.destinationName = data.destination['name'];
            this.location = data.destination['location'];
            this.destination = data.destination;
            this.destinationId = data.destination['id'].toString();
            this.itineraryItems = data.day['itinerary_items'].sublist(1);
            this.startLocation = data.itinerary['start_location'];
            this.currentPosition = data.currentPosition;
            this.image = data.destination['image'];
            this.loading = false;
          });
        } else {
          setState(() {
            this.errorUi = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  DayEditState({this.dayId, this.itineraryId, this.startLocation, this.onPush});

  @override
  Widget build(BuildContext context) {
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = MediaQuery.of(context).size.height - 110;
    double _panelHeightClosed = 100.0;
    if (store == null) {
      store = Provider.of<TrotterStore>(context);
    }

    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingUpPanel(
        parallaxEnabled: true,
        parallaxOffset: .5,
        minHeight: errorUi == false && canView == true
            ? _panelHeightClosed
            : _panelHeightOpen,
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
          final String cacheData = prefs.getString('dayEditShowcase') ?? null;
          if (cacheData == null) {
            ShowCaseWidget.startShowCase(context, [_one, _two, _three]);
            await prefs.setString('dayEditShowcase', "true");
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
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: FutureBuilder(
                    future: data,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingBody(context);
                      }
                      if (snapshot.hasData && snapshot.data.error == null) {
                        if (this.itineraryItems.length == 0 &&
                            _pc.isPanelClosed() == true) {
                          _pc.open();
                        }
                        if (this.canView) {
                          return _buildLoadedBody(context, snapshot);
                        } else {
                          return CannotView();
                        }
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
                                    color: Color.fromRGBO(106, 154, 168, 1),
                                    onRetry: () {
                                      setState(() {
                                        data = fetchDay(
                                            this.itineraryId, this.dayId);
                                        data.then((data) {
                                          if (data.error == null) {
                                            setState(() {
                                              this.color = Color(
                                                  hexStringToHexInt(
                                                      data.color));
                                              this.itineraryName =
                                                  data.itinerary['name'];
                                              this.ownerId =
                                                  data.itinerary['owner_id'];
                                              this.startDate =
                                                  data.itinerary['start_date'] *
                                                      1000;
                                              this.destinationName =
                                                  data.destination['name'];
                                              this.location =
                                                  data.destination['location'];
                                              this.destination =
                                                  data.destination;
                                              this.destinationId = data
                                                  .destination['id']
                                                  .toString();
                                              this.itineraryItems = data
                                                  .day['itinerary_items']
                                                  .sublist(1);
                                              this.startLocation = data
                                                  .itinerary['start_location'];
                                              this.currentPosition =
                                                  data.currentPosition;
                                              this.image =
                                                  data.destination['image'];
                                            });
                                          }
                                        });
                                      });
                                    },
                                  ))
                            ]);
                      }
                      return _buildLoadingBody(context);
                    }))),
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
                          loadingWidgetBuilder:
                              (BuildContext context, double progress, test) =>
                                  Center(
                                      child: RefreshProgressIndicator(
                            backgroundColor: Colors.white,
                          )),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: const Icon(Icons.refresh),
                          enableRefresh: true,
                        )
                      : Container()),
              Positioned.fill(
                top: 0,
                left: 0,
                child: Container(color: this.color.withOpacity(.3)),
              ),
              Positioned(
                  left: 0,
                  top: (MediaQuery.of(context).size.height / 2) - 110,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        destinationName != null
                            ? AutoSizeText('$destinationName',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w300))
                            : Container(),
                      ])),
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
              onPush: onPush,
              color: color,
              title: this.itineraryName,
              showSearch: false,
              actions: <Widget>[
                this.canView == true
                    ? Container(
                        width: 70,
                        height: 70,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        child: Showcase(
                            key: _one,
                            description:
                                'Click here to search for places to add',
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              onPressed: () async {
                                final store =
                                    Provider.of<TrotterStore>(context);
                                var suggestion = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (context) => SearchModal(
                                            query: '',
                                            destinationName:
                                                this.destinationName,
                                            location: this.location,
                                            near: this.currentPosition != null
                                                ? this.currentPosition
                                                : this.startLocation,
                                            id: this.destinationId)));
                                if (suggestion != null) {
                                  var poi = suggestion;
                                  poi['image'] = suggestion['image_hd'];
                                  var data = {
                                    "poi": poi,
                                    "title": "",
                                    "description": "",
                                    "time": {"value": "", "unit": ""},
                                    "poi_id": poi['id'],
                                    "added_by": store.currentUser.uid
                                  };

                                  setState(() {
                                    this.loading = true;
                                  });

                                  var response = await addToDay(
                                      store,
                                      this.itineraryId,
                                      this.dayId,
                                      this.destinationId,
                                      data,
                                      false);
                                  setState(() {
                                    this.color = Color(
                                        hexStringToHexInt(response.color));
                                    this.destinationName =
                                        response.destination['name'];
                                    this.location =
                                        response.destination['location'];
                                    this.destinationId =
                                        response.destination['id'].toString();
                                    this.itineraryItems =
                                        response.day['itinerary_items'];
                                    this.loading = false;
                                  });
                                }
                              },
                              child: SvgPicture.asset(
                                  "images/add-location-bold.svg",
                                  width: 35,
                                  height: 35,
                                  color: fontContrast(color),
                                  fit: BoxFit.cover),
                            )))
                    : Container()
              ],
              back: true)),
    ]);
  }

  Future getLocationPermission() async {
    var location = Location();

// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      var permission = await location.hasPermission();
      if (permission == false) {
        await location.requestPermission();
        return;
      }
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        var error = 'Permission denied';
        print(error);
      }
      return;
    }
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    var day = snapshot.data.day;
    //var itinerary = snapshot.data.itinerary;
    var color = Color(hexStringToHexInt(snapshot.data.color));
    final formatter = DateFormat.yMMMMd("en_US");
    return Stack(fit: StackFit.expand, children: <Widget>[
      DayList(
        header: '${ordinalNumber(day['day'] + 1)} day',
        subHeader: formatter.format(
            DateTime.fromMillisecondsSinceEpoch(this.startDate)
                .add(Duration(days: day['day']))),
        ownerId: this.ownerId,
        controller: _sc,
        physics: disableScroll
            ? NeverScrollableScrollPhysics()
            : ClampingScrollPhysics(),
        items: itineraryItems,
        color: color,
        startLocation: this.currentPosition != null
            ? this.currentPosition
            : this.startLocation,
        onLongPressed: (data) {
          final store = Provider.of<TrotterStore>(ctxt);
          if (this.ownerId == store.currentUser.uid ||
              store.currentUser.uid == data['added_by'])
            bottomSheetModal(context, day['day'] + 1, data);
        },
        onPressed: (data) {
          onPush({
            'id': data['id'],
            'level': 'poi',
            'google_place': data['google_place']
          });
        },
        comments: true,
        showCaseKeys: [_two, _three],
        onCommentPressed: (itineraryItem) async {
          final totalComments = await Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => CommentsModal(
                      itineraryId: this.itineraryId,
                      dayId: this.dayId,
                      tripId: this.tripId,
                      currentUserId: store.currentUser.uid,
                      itineraryItemId: itineraryItem['id'],
                      title:
                          '${this.itineraryName} - ${itineraryItem['poi']['name']}')));
          setState(() {
            itineraryItem['total_comments'] = totalComments['total_comments'];
          });
        },
      ),
      this.loading
          ? Align(
              alignment: Alignment.center,
              child: RefreshProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(color),
              ))
          : Container()
    ]);
  }

  bottomSheetModal(BuildContext ctxt, int dayIndex, dynamic data) {
    var name = data['poi']['name'];
    var undoData = data;
    var id = data['id'];
    final store = Provider.of<TrotterStore>(ctxt);
    return showModalBottomSheet(
        context: ctxt,
        builder: (BuildContext context) {
          return new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new ListTile(
                    leading: new Icon(EvilIcons.external_link),
                    title: new AutoSizeText('Move to another day'),
                    onTap: () async {
                      var result = await showDayBottomSheet(
                          store,
                          context,
                          this.itineraryId,
                          data['poi'],
                          this.destinationId,
                          this.color,
                          this.destination,
                          data['added_by'],
                          force: true,
                          isSelecting: false,
                          movingFromId: this.dayId);
                      if (result != null && result['selected'] != null) {
                        setState(() {
                          this.loading = true;
                        });
                        var response = await deleteFromDay(this.itineraryId,
                            this.dayId, id, store.currentUser.uid);
                        if (response.success == true) {
                          setState(() {
                            this
                                .itineraryItems
                                .removeWhere((item) => item['id'] == id);
                            store.itineraryStore
                                .updateItineraryBuilderDelete(this.dayId, id);
                            Navigator.of(context).pop();
                            this.loading = false;
                          });
                        } else {
                          setState(() {
                            Scaffold.of(this.context).showSnackBar(SnackBar(
                              content: AutoSizeText(
                                  'Unable to delete from itinerary',
                                  style: TextStyle(fontSize: 18)),
                              duration: Duration(seconds: 2),
                            ));
                            this.loading = false;
                          });
                        }
                      }
                    }),
                new ListTile(
                    leading: new Icon(
                      EvilIcons.trash,
                    ),
                    title: new AutoSizeText('Delete from itnerary'),
                    onTap: () async {
                      this.loading = true;
                      var response = await deleteFromDay(this.itineraryId,
                          this.dayId, id, store.currentUser.uid);
                      if (response.success == true) {
                        setState(() {
                          this
                              .itineraryItems
                              .removeWhere((item) => item['id'] == id);
                          store.itineraryStore
                              .updateItineraryBuilderDelete(this.dayId, id);
                          this.loading = false;
                        });
                        Scaffold.of(ctxt).showSnackBar(SnackBar(
                          content: AutoSizeText('$name was removed.',
                              style: TextStyle(fontSize: 18)),
                          duration: Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: color,
                            onPressed: () async {
                              setState(() {
                                this.loading = true;
                              });
                              var response = await addToDay(
                                  store,
                                  this.itineraryId,
                                  this.dayId,
                                  this.destinationId,
                                  undoData,
                                  false);
                              if (response.success == true) {
                                setState(() {
                                  this.color =
                                      Color(hexStringToHexInt(response.color));
                                  this.destinationName =
                                      response.destination['name'];
                                  this.destinationId =
                                      response.destination['id'].toString();
                                  this.itineraryItems =
                                      response.day['itinerary_items'];
                                  this.loading = false;
                                  Scaffold.of(ctxt).removeCurrentSnackBar();
                                  Scaffold.of(ctxt).showSnackBar(SnackBar(
                                    content: AutoSizeText('Undo successful!',
                                        style: TextStyle(fontSize: 18)),
                                    duration: Duration(seconds: 2),
                                  ));
                                });
                              } else {
                                Scaffold.of(ctxt).removeCurrentSnackBar();
                                Scaffold.of(ctxt).showSnackBar(SnackBar(
                                    content: AutoSizeText(
                                        'Sorry the undo failed!',
                                        style: TextStyle(fontSize: 18)),
                                    duration: Duration(seconds: 2)));
                              }
                            },
                          ),
                        ));
                      } else {
                        setState(() {
                          Scaffold.of(this.context).showSnackBar(SnackBar(
                            content: AutoSizeText(
                                'Unable to delete from itinerary',
                                style: TextStyle(fontSize: 18)),
                            duration: Duration(seconds: 2),
                          ));
                          this.loading = false;
                        });
                      }
                      Navigator.of(context).pop();
                    }),
              ]);
        });
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    return Column(children: <Widget>[
      Container(
        color: Color.fromRGBO(240, 240, 240, 1),
      ),
      Flexible(
        child: DayListLoading(),
      )
    ]);
  }
}
