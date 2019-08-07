import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/store/trips/middleware.dart';
import 'package:trotter_flutter/tab_navigator.dart';

void showTripsBottomSheet(context,
    [dynamic destination, dynamic notification, String notificationId]) {
  final store = Provider.of<TrotterStore>(context);
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return _buildLoadedList(
            context, store, destination, notification, notificationId);
      });
}

_buildLoadedList(BuildContext context, TrotterStore store,
    [dynamic destination, dynamic notification, String notificationId]) {
  var trips = store.tripStore.trips;
  var loading = store.tripStore.tripLoading;
  return IgnorePointer(
      ignoring: loading,
      child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: loading == true && trips.length == 0
              ? _buildLoadingList()
              : trips.length == 0
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                              width: 200,
                              height: 200,
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
                                      image:
                                          AssetImage('images/trips-empty.jpg'),
                                      fit: BoxFit.contain),
                                  borderRadius: BorderRadius.circular(130))),
                          Text(
                            'No trips planned yet?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 35,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w300),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Create a trip to start planning your next adventure!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w200),
                          ),
                          SizedBox(height: 30),
                          FlatButton(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(50.0)),
                            child: Text(
                              'Start planning',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w200),
                            ),
                            color: Colors.blueGrey,
                            onPressed: () {
                              TabNavigator()
                                  .push(context, {'level': 'createtrip'});
                            },
                          )
                        ],
                      ))
                  : Wrap(children: <Widget>[
                      Stack(children: <Widget>[
                        SingleChildScrollView(
                            primary: false,
                            scrollDirection: Axis.horizontal,
                            child: Container(
                                margin: EdgeInsets.only(left: 20.0),
                                child: _buildRow(_buildItems(
                                    context,
                                    trips,
                                    destination,
                                    notification,
                                    notificationId)))),
                        loading
                            ? Center(child: RefreshProgressIndicator())
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

_buildItems(BuildContext context, List<dynamic> items,
    [dynamic destination, dynamic notification, String notificationId]) {
  var widgets = List<Widget>();
  for (var item in items) {
    widgets.add(
        _buildBody(context, item, destination, notification, notificationId));
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

Widget _buildBody(BuildContext context, dynamic item,
    [dynamic destination, dynamic notification, String notificationId]) {
  return new InkWell(
      onTap: () async {
        final store = Provider.of<TrotterStore>(context);
        if (destination != null) {
          var data = {
            "location": destination['location'],
            "destination_id": destination['id'],
            "destination_name": destination['name'],
            "level": destination['level'],
            "country_id": destination['country_id'],
            "country_name": destination["country_name"],
            "start_date": 0,
            "end_date": 0,
          };
          var response = await postAddToTrip(item['id'], data);
          if (response.exists == false) {
            store.tripStore.updateTripDestinations(item['id'], data);
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('${destination['name']} added to ${item['name']}',
                  style: TextStyle(fontSize: 18)),
              duration: Duration(seconds: 2),
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.blueGrey,
                onPressed: () {
                  TabNavigator().push(
                      context, {"id": item['id'].toString(), "level": "trip"});
                  Scaffold.of(context).removeCurrentSnackBar();
                },
              ),
            ));
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                    '${destination['name']} was already added to ${item['name']}',
                    style: TextStyle(fontSize: 18)),
                duration: Duration(seconds: 2)));
          }
        } else if (notification != null) {
          var data = {
            "source": notification['source'],
            "segments": notification['segments'],
            "travelers": [store.currentUser.uid],
          };
          final List<Widget> destinations = item['destinations']
              .map<Widget>((destination) => new ListTile(
                  title: new Text(
                      '${destination['destination_name']}, ${destination["country_name"]}'),
                  onTap: () async {
                    var response = await postAddFlightsAndAccomodations(
                        item['id'], destination['id'], data);
                    Navigator.pop(context);
                    if (response.success == true) {
                      await markNotificationRead(notificationId, store);
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Details successfully added to trip',
                              style: TextStyle(fontSize: 18)),
                          duration: Duration(seconds: 2)));
                    }
                  }))
              .toList();
          Navigator.pop(context);
          await showModalBottomSheet(
              context: context,
              builder: (BuildContext modalContext) {
                return new Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Text("Which destination is this for?",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w300))),
                  ...destinations
                ]);
              });
        }
      },
      child: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            Container(
              // A fixed-height child.
              margin: EdgeInsets.only(right: 20),
              child: ClipPath(
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: item['image'] != null
                      ? TransitionToImage(
                          image: AdvancedNetworkImage(
                            item['image'],
                            useDiskCache: true,
                            cacheRule:
                                CacheRule(maxAge: const Duration(days: 7)),
                          ),
                          loadingWidgetBuilder:
                              (BuildContext context, double progress, test) =>
                                  Center(
                                      child: CircularProgressIndicator(
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
                      //                   new AlwaysStoppedAnimation<Color>(
                      //                       Colors.blueAccent),
                      //             ))),
                      //     fit: BoxFit.cover,
                      //     imageUrl: item['image'],
                      //     errorWidget: (context, url, error) => Container(
                      //             decoration: BoxDecoration(
                      //           image: DecorationImage(
                      //               image: AssetImage('images/placeholder.jpg'),
                      //               fit: BoxFit.cover),
                      //         )))
                      : Container(
                          decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('images/placeholder.jpg'),
                              fit: BoxFit.cover),
                        ))),
              width: 140.0,
              height: 178.0,
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                width: 150.0,
                child: Text(
                  item['name'],
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                ))
          ])));
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
