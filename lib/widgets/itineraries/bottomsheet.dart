import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/tab_navigator.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/itinerary-list/index.dart';

Future addToItinerary(
    BuildContext context, dynamic poi, Color color, dynamic destination,
    {Future2VoidFunc onPush, int startDate}) async {
  final store = Provider.of<TrotterStore>(context);
  final selectedItineraryId =
      store.itineraryStore.selectedItinerary.selectedItineraryId;
  final selectedItineraryDestination =
      store.itineraryStore.selectedItinerary.destinationId;
  final startDate = store.itineraryStore.selectedItinerary.selectedItinerary !=
          null
      ? store.itineraryStore.selectedItinerary.selectedItinerary['start_date']
      : 0;

  if (selectedItineraryId != null &&
      selectedItineraryDestination == destination['id']) {
    var result = await showDayBottomSheet(store, context, selectedItineraryId,
        poi, destination['id'], color, destination, store.currentUser.uid,
        onPush: onPush, startDate: startDate * 1000);
    if (result != null && result['change'] != null) {
      store.itineraryStore
          .setSelectedItinerary(null, destination['id'], null, true);
    }
    return result;
  } else {
    await showItineraryBottomSheet(
        store, context, destination['id'], poi, color, destination);
  }
}

Future showItineraryBottomSheet(TrotterStore store, context,
    String destinationId, dynamic poi, Color color, dynamic destination) {
  var data = fetchItineraries(
      "destination=$destinationId&user_id=${store.currentUser.uid}");
  return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return _buildLoadedList(store, context, snapshot, poi,
                    destinationId, color, destination);
              }
              return _buildLoadingList();
            });
      });
}

_buildLoadedList(
    TrotterStore store,
    BuildContext context,
    AsyncSnapshot snapshot,
    dynamic poi,
    String destinationId,
    Color color,
    dynamic destination) {
  var itineraries = snapshot.data.itineraries;
  var loading = false;
  return IgnorePointer(
      ignoring: loading,
      child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: loading == true && itineraries.length == 0
              ? _buildLoadingList()
              : itineraries == null || itineraries.length == 0
                  ? Container(
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
                            'No itineraries created yet?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w300),
                          ),
                          SizedBox(height: 10),
                          AutoSizeText(
                            'Create a trip and start planning your next adventure!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w200),
                          ),
                          SizedBox(height: 30),
                          FlatButton(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(50.0)),
                            child: AutoSizeText(
                              'Start planning',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w200),
                            ),
                            color: Colors.blueGrey,
                            onPressed: () {
                              TabNavigator().push(context, {
                                'level': 'createtrip',
                                'param': destination
                              });
                            },
                          )
                        ],
                      ))
                  : Wrap(children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(left: 20, bottom: 20),
                          margin: EdgeInsets.only(bottom: 20),
                          child: AutoSizeText(
                            'Choose an itinerary',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w300),
                          )),
                      Stack(children: <Widget>[
                        SingleChildScrollView(
                            primary: false,
                            scrollDirection: Axis.horizontal,
                            child: Container(
                                margin: EdgeInsets.only(left: 20.0),
                                child: _buildRow(_buildItems(
                                    store,
                                    context,
                                    itineraries,
                                    poi,
                                    destinationId,
                                    color,
                                    destination)))),
                        loading
                            ? Center(
                                child: RefreshProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            color)))
                            : Container()
                      ])
                    ])));
}

_buildLoadingList() {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            height: 130.0,
            margin: EdgeInsets.only(top: 20.0),
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (BuildContext ctxt, int index) =>
                    _buildLoadingBody(ctxt, index)))
      ]);
}

_buildItems(TrotterStore store, BuildContext context, List<dynamic> items,
    dynamic poi, String destinationId, Color color, dynamic destination,
    {Future2VoidFunc onPush, int startDate}) {
  var widgets = <Widget>[];
  for (var item in items) {
    widgets.add(_buildBody(
        store, context, item, poi, destinationId, color, destination,
        onPush: onPush));
  }
  return widgets;
}

_buildRow(List<Widget> widgets) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    mainAxisSize: MainAxisSize.min,
    children: widgets,
  );
}

Widget _buildBody(TrotterStore store, BuildContext context, dynamic item,
    dynamic poi, String destinationId, Color color, dynamic destination,
    {Future2VoidFunc onPush}) {
  var days = item['days'] as List;
  var itineraryItems = days.firstWhere((day) {
    var items = day['itinerary_items'] as List;
    return items.length > 0;
  }, orElse: () => {"itinerary_items": <List<dynamic>>[]})['itinerary_items'];

  return Container(
      margin: EdgeInsets.only(right: 20),
      child: InkWell(
          onTap: () async {
            store.itineraryStore.setSelectItineraryLoading(true);
            Navigator.pop(context);
            var result = await showDayBottomSheet(store, context, item['id'],
                poi, destinationId, color, destination, store.currentUser.uid,
                onPush: onPush, startDate: item['start_date'] * 1000);
            if (result != null && result['change'] != null) {
              store.itineraryStore
                  .setSelectedItinerary(null, destinationId, null);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MiniItineraryList(
                  items: itineraryItems,
                  destination: destination,
                  onPressed: (data) async {
                    store.itineraryStore.setSelectItineraryLoading(true);

                    Navigator.pop(context);
                    var result = await showDayBottomSheet(
                        store,
                        context,
                        item['id'],
                        poi,
                        destinationId,
                        color,
                        destination,
                        store.currentUser.uid,
                        onPush: onPush,
                        startDate: item['start_date'] * 1000);
                    if (result != null && result['change'] != null) {
                      store.itineraryStore
                          .setSelectedItinerary(null, destinationId, null);
                    }
                  },
                  onLongPressed: (data) {}),
              Container(
                  width: 200,
                  margin: EdgeInsets.only(top: 10),
                  child: AutoSizeText(
                    item['name'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                  ))
            ],
          )));
}

Future<DayData> responseFromDayBottomSheet(BuildContext context, dynamic item,
    dynamic poi, String dayId, String destinationId, String addedBy,
    [int toIndex,
    dayIndex,
    String movedByUid,
    BuildContext mainContext,
    Future2VoidFunc onPush]) async {
  final store = Provider.of<TrotterStore>(context);
  var data = {
    "poi": poi,
    "title": "",
    "description": "",
    "time": {"value": "", "unit": ""},
    "poi_id": poi['id'],
    "added_by": addedBy
  };
  var response = await addToDay(
      store, item['id'], dayId, destinationId, data, true, movedByUid, true);

  return response;
}

showDayBottomSheet(
    TrotterStore storeApp,
    BuildContext context,
    String itineraryId,
    dynamic poi,
    String destinationId,
    Color color,
    dynamic destination,
    String addedBy,
    {force: false,
    int startDate,
    isSelecting: false,
    String movedByUid: '',
    String movingFromId,
    onPush: Future2VoidFunc}) {
  final storeApp = Provider.of<TrotterStore>(context);
  final data = fetchSelectedItinerary(storeApp, itineraryId);
  return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              final store = Provider.of<TrotterStore>(context);
              var loading = store.itineraryStore.selectedItinerary.loading;
              if (loading) {
                return Container(
                    height: 300,
                    width: 400,
                    child: Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(color))));
              }
              var item =
                  store.itineraryStore.selectedItinerary.selectedItinerary;

              if (item == null) {
                return Container(
                    height: 300,
                    width: 400,
                    child: Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(color))));
              }
              var days = item['days'];
              if (movingFromId != null) {
                days.removeWhere((day) => movingFromId == day['id']);
              }
              final formatter = DateFormat.yMMMMd("en_US");
              return IgnorePointer(
                  ignoring: store.bottomSheetLoading,
                  child: Stack(children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              padding:
                                  EdgeInsets.only(top: 10, bottom: 5, left: 20),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    AutoSizeText(
                                      'Choose a day',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    store.itineraryStore.selectedItinerary
                                                .selectedItinerary !=
                                            null
                                        ? FlatButton(
                                            onPressed: () {
                                              Navigator.pop(
                                                  context, {"change": true});
                                              showItineraryBottomSheet(
                                                  storeApp,
                                                  context,
                                                  destinationId,
                                                  poi,
                                                  color,
                                                  destination);
                                            },
                                            child: AutoSizeText(
                                              'Change',
                                              style: TextStyle(
                                                  color: color,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          )
                                        : Container()
                                  ])),
                          Container(
                              margin: EdgeInsets.only(bottom: 0, top: 0),
                              child:
                                  Divider(color: Color.fromRGBO(0, 0, 0, 0.3))),
                          Flexible(
                              child: ListView.separated(
                            separatorBuilder: (BuildContext serperatorContext,
                                    int index) =>
                                new Container(
                                    margin: EdgeInsets.symmetric(vertical: 0),
                                    child: Divider(
                                        color: Color.fromRGBO(0, 0, 0, 0.3))),
                            itemCount: days.length,
                            primary: false,
                            itemBuilder:
                                (BuildContext listContext, int dayIndex) {
                              return ListTile(
                                  onTap: () async {
                                    store.setBottomSheetLoading(true);

                                    var response =
                                        await responseFromDayBottomSheet(
                                            listContext,
                                            item,
                                            poi,
                                            days[dayIndex]['id'],
                                            destinationId,
                                            addedBy,
                                            days[dayIndex]['day'] + 1,
                                            dayIndex,
                                            movedByUid,
                                            context,
                                            onPush);
                                    Navigator.pop(listContext, {
                                      'success': response.success,
                                      'selected': days[dayIndex],
                                      'toIndex': days[dayIndex]['day'] + 1,
                                      'poi': poi,
                                      'itinerary': item,
                                      "movedPlaceId": response.justAdded,
                                      "dayIndex": dayIndex,
                                      "dayId": days[dayIndex]['id']
                                    });

                                    store.setBottomSheetLoading(false);
                                  },
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  title: Row(children: <Widget>[
                                    AutoSizeText(
                                      'Day ${days[dayIndex]['day'] + 1}',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    startDate != null && startDate != 0
                                        ? Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                                child: AutoSizeText(
                                              ' - ${formatter.format(DateTime.fromMillisecondsSinceEpoch(startDate, isUtc: true).add(Duration(days: days[dayIndex]['day'])))}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w300),
                                            )))
                                        : Container()
                                  ]),
                                  subtitle: AutoSizeText(
                                    '${days[dayIndex]['itinerary_items'].length} ${days[dayIndex]['itinerary_items'].length == 1 ? "place" : "places"} to see',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300),
                                  ));
                            },
                          ))
                        ]),
                    Positioned.fill(
                        child: store.bottomSheetLoading == true
                            ? Center(
                                child: RefreshProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            color)))
                            : Container())
                  ]));
            });
      });
}

Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>
    showSuccessSnackbar(BuildContext context,
        {dynamic poi,
        dynamic itinerary,
        String dayId,
        Future2VoidFunc onPush,
        int dayIndex,
        int toIndex,
        String action = 'added'}) async {
  return Scaffold.of(context).showSnackBar(SnackBar(
    content: AutoSizeText(
        toIndex != null
            ? '${poi['name']} $action to day $toIndex'
            : '${poi['name']} $action to ${itinerary['name']}',
        style: TextStyle(fontSize: 18)),
    duration: Duration(seconds: 2),
    action: onPush != null
        ? SnackBarAction(
            label: 'Go to day',
            // textColor: this.color,
            onPressed: () async {
              //print(item['start_location']);
              //print(item['days'][dayIndex]);
              // Navigator.pop(mainContext);
              await onPush({
                'itineraryId': itinerary['id'],
                'dayId': dayId,
                "linkedItinerary": itinerary['days'][dayIndex]
                    ['linked_itinerary'],
                "startLocation": itinerary['start_location']['location'],
                'level': 'itinerary/day/edit'
              });
            },
          )
        : null,
  ));
}

Widget _buildLoadingBody(BuildContext ctxt, int index) {
  return Shimmer.fromColors(
      baseColor: Color.fromRGBO(220, 220, 220, 0.8),
      highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
      child: Container(
          height: 210.0,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Container(
                      // A fixed-height child.
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(240, 240, 240, 0.8),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: 120.0,
                      height: 70.0,
                    )),
                Container(
                  padding: EdgeInsets.only(left: 20.0, top: 10.0),
                  width: 80.0,
                  height: 18.0,
                  margin: EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 240, 240, 0.8),
                  ),
                )
              ])));
}
