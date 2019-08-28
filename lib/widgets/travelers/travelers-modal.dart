import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trotter_flutter/globals.dart';

Future<TravelersModalData> fetchTravelersModal(
  String tripId,
) async {
  try {
    var response;

    response = await http.get('$ApiDomain/api/trips/$tripId/travelers',
        headers: {'Authorization': 'security'});

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return TravelersModalData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return TravelersModalData(success: false);
    }
  } catch (error) {
    return TravelersModalData(success: false);
  }
}

class TravelersModalData {
  final List<dynamic> travelers;
  final bool success;

  TravelersModalData({this.travelers, this.success});

  factory TravelersModalData.fromJson(Map<String, dynamic> json) {
    return TravelersModalData(travelers: json['travelers'], success: true);
  }
}

class TravelersModal extends StatefulWidget {
  final String tripId;
  final ValueChanged<dynamic> onAdd;
  final List<dynamic> travelers;
  final String ownerId;
  final String currentUserId;
  final bool readOnly;

  TravelersModal(
      {Key key,
      @required this.tripId,
      @required this.ownerId,
      @required this.currentUserId,
      this.onAdd,
      this.readOnly,
      this.travelers})
      : super(key: key);
  @override
  TravelersModalState createState() => new TravelersModalState(
      tripId: this.tripId,
      travelers: this.travelers,
      ownerId: this.ownerId,
      currentUserId: this.currentUserId,
      onAdd: this.onAdd,
      readOnly: this.readOnly);
}

class TravelersModalState extends State<TravelersModal> {
  String tripId;
  final String ownerId;
  final String currentUserId;
  List<dynamic> travelers;
  final ValueChanged<dynamic> onAdd;
  GoogleMapController mapController;
  List<Widget> selectedUsers = [];
  List<String> selectedUsersUid = [];
  bool readOnly = false;

  Future<TravelersModalData> data;

  @override
  void initState() {
    super.initState();
    for (var traveler in this.travelers) {
      this.selectedUsersUid.add(traveler['uid']);
      this.selectedUsers.add(Chip(
          avatar: CircleAvatar(
              backgroundImage: AdvancedNetworkImage(
            traveler['photoUrl'],
            useDiskCache: true,
            cacheRule: CacheRule(maxAge: const Duration(days: 7)),
          )),
          label: AutoSizeText("${traveler['displayName']}"),
          deleteIcon: (this.ownerId == this.currentUserId &&
                      this.currentUserId != traveler['uid']) ||
                  (this.currentUserId == traveler['uid'] &&
                      this.currentUserId != this.ownerId)
              ? Icon(Icons.close)
              : Container(),
          onDeleted: () {
            if (this.ownerId == this.currentUserId ||
                this.currentUserId == traveler['uid'])
              this._deleteChip(traveler['uid']);
          }));
    }
    data = fetchTravelersModal(
      this.tripId,
    );
  }

  TravelersModalState(
      {this.tripId,
      this.onAdd,
      this.currentUserId,
      this.ownerId,
      this.readOnly,
      this.travelers});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return AutoSizeText('Press button to start.');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return _buildLoadedBody(context, snapshot, true, '');
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return _buildLoadedBody(
                        context, snapshot, false, this.tripId);
                  } else if (snapshot.hasError) {
                    return AutoSizeText('No Connection');
                  }
              }
              return _buildLoadedBody(context, snapshot, true, '');
            }));
  }

  _deleteChip(String uid) {
    if (this.selectedUsers.length > 1) {
      setState(() {
        var index = this.selectedUsersUid.indexOf(uid);
        this.selectedUsersUid.removeAt(index);
        this.selectedUsers.removeAt(index);
      });
    }
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, bool isLoading, String id) {
    var results = snapshot.hasData ? snapshot.data.travelers : [];

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: isLoading
            ? Column(children: <Widget>[
                renderTopBar(),
                Flexible(child: _buildLoadingBody())
              ])
            : Column(children: <Widget>[
                renderTopBar(),
                Flexible(
                    child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      selected:
                          this.selectedUsersUid.contains(results[index]['uid']),
                      onTap: () {
                        var exists = this
                            .selectedUsersUid
                            .contains(results[index]['uid']);
                        if (exists == false) {
                          setState(() {
                            this.selectedUsersUid.add(results[index]['uid']);
                            this.selectedUsers.add(Chip(
                                avatar: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                  results[index]['photoUrl'],
                                )),
                                label: AutoSizeText(
                                    "${results[index]['displayName']}"),
                                deleteIcon: Icon(Icons.close),
                                onDeleted: () {
                                  this._deleteChip(results[index]['uid']);
                                }));
                          });
                        }
                      },
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      leading: Container(
                        width: 40.0,
                        height: 40.0,
                        child: ClipPath(
                            clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100))),
                            child: TransitionToImage(
                              image: AdvancedNetworkImage(
                                results[index]['photoUrl'],
                                useDiskCache: true,
                                cacheRule:
                                    CacheRule(maxAge: const Duration(days: 7)),
                              ),
                              loadingWidgetBuilder: (BuildContext context,
                                      double progress, test) =>
                                  Center(
                                      child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              placeholder: const Icon(Icons.refresh),
                              enableRefresh: true,
                            )),
                      ),
                      title: AutoSizeText(
                        results[index]['displayName'],
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ))
              ]));
  }

  Container renderTopBar() {
    return Container(
        padding: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
            border: Border(
                bottom:
                    BorderSide(width: 1, color: Colors.black.withOpacity(.1)))),
        child: Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      iconSize: 25,
                      color: Colors.black,
                    ),
                    this.readOnly == false || this.readOnly == null
                        ? AutoSizeText(
                            'Select travelers',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                fontSize: 19),
                          )
                        : AutoSizeText(
                            'All travelers',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                fontSize: 19),
                          )
                  ]),
                  this.readOnly == false || this.readOnly == null
                      ? Center(
                          child: Container(
                              margin: EdgeInsets.only(right: 20),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                child: AutoSizeText(
                                  'Save',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                                textColor: Colors.lightBlue,
                                padding: EdgeInsets.all(0),
                                color: Colors.lightBlue.withOpacity(.3),
                                onPressed: () {
                                  Navigator.pop(context,
                                      {"travelers": this.selectedUsersUid});
                                },
                              )))
                      : Container()
                ]),
            this.readOnly == false || this.readOnly == null
                ? Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Wrap(spacing: 10.0, children: this.selectedUsers))
                : Container(),
          ],
        ));
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody() {
    return ListView(
        //crossAxisAlignment: CrossAxisAlignment.start,
        shrinkWrap: true,
        primary: false,
        children: <Widget>[
          Align(alignment: Alignment.centerLeft, child: TextLoading()),
          Align(
              alignment: Alignment.centerLeft,
              child: TextLoading(width: 200.0)),
          Align(alignment: Alignment.centerLeft, child: TextLoading()),
          Align(
              alignment: Alignment.centerLeft,
              child: TextLoading(width: 220.0)),
          Align(alignment: Alignment.centerLeft, child: TextLoading()),
          Align(
              alignment: Alignment.centerLeft,
              child: TextLoading(width: 180.0)),
          Align(
              alignment: Alignment.centerLeft,
              child: TextLoading(width: 180.0)),
          Align(
              alignment: Alignment.centerLeft,
              child: TextLoading(width: 150.0)),
          Align(
              alignment: Alignment.centerLeft,
              child: TextLoading(width: 200.0)),
          Align(
              alignment: Alignment.centerLeft,
              child: TextLoading(width: 180.0)),
        ]);
  }
}
