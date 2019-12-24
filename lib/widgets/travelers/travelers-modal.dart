import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:trotter_flutter/globals.dart';
import 'package:trotter_flutter/widgets/travelers/travelers-search-modal.dart';

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
  final String ownerId;
  final String currentUserId;
  final List<dynamic> travelers;
  final bool readWrite;

  TravelersModal(
      {Key key,
      @required this.tripId,
      @required this.ownerId,
      @required this.currentUserId,
      this.readWrite,
      this.travelers,
      this.onAdd})
      : super(key: key);
  @override
  TravelersModalState createState() => new TravelersModalState(
      tripId: this.tripId,
      ownerId: this.ownerId,
      currentUserId: this.currentUserId,
      travelers: this.travelers,
      readWrite: this.readWrite,
      onAdd: this.onAdd);
}

class TravelersModalState extends State<TravelersModal> {
  String tripId;
  final String ownerId;
  final String currentUserId;
  List<dynamic> travelers = [];
  List<dynamic> addedTravelers = [];
  List<String> deletedTravelers = [];
  bool showSave = false;
  final ValueChanged<dynamic> onAdd;
  List<Widget> selectedUsers = [];
  List<String> selectedUsersUid = [];
  bool readWrite = true;

  Future<TravelersModalData> data;

  @override
  void initState() {
    super.initState();
    if (this.travelers == null) {
      data = fetchTravelersModal(
        this.tripId,
      );
      data.then((data) {
        setState(() {
          this.travelers = data.travelers;
        });
      });
    } else {
      data = fetchTravelersModal(
        this.tripId,
      );
    }
  }

  TravelersModalState(
      {this.tripId,
      this.travelers,
      this.onAdd,
      this.currentUserId,
      this.ownerId,
      this.readWrite});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
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
                  if (snapshot.hasData && snapshot.data.success) {
                    return _buildLoadedBody(
                        context, snapshot, false, this.tripId);
                  } else if (snapshot.hasData &&
                      snapshot.data.success == false) {
                    return ErrorContainer(
                      onRetry: () {
                        if (this.travelers == null) {
                          data = fetchTravelersModal(
                            this.tripId,
                          );
                          data.then((data) {
                            setState(() {
                              this.travelers = data.travelers;
                            });
                          });
                        } else {
                          data = fetchTravelersModal(
                            this.tripId,
                          );
                        }
                      },
                    );
                  }
              }
              return _buildLoadedBody(context, snapshot, true, '');
            }));
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, bool isLoading, String id) {
    var results = snapshot.hasData && snapshot.data.success
        ? ['', ...this.travelers]
        : [''];

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
                    if (index == 0 && readWrite == true) {
                      return ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        leading: Container(
                          child: Icon(Icons.add),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        title: AutoSizeText("Invite"),
                        onTap: () async {
                          final dialogData = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (context) => TravelersSearchModal(
                                        currentUserId: this.currentUserId,
                                        ownerId: this.ownerId,
                                        tripId: this.tripId,
                                      )));
                          if (dialogData != null) {
                            setState(() {
                              this.travelers = [
                                ...dialogData['travelersFull'],
                                ...this.travelers
                              ];
                              this.addedTravelers = [
                                ...this.addedTravelers,
                                ...dialogData['travelersFull']
                              ];
                              this.selectedUsersUid = [
                                ...dialogData['travelers'],
                                ...this.selectedUsersUid
                              ];
                              this.showSave = true;
                            });
                          }
                        },
                      );
                    } else if (index == 0) {
                      return Container();
                    }
                    return ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      leading: Container(
                        width: 50.0,
                        height: 50.0,
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
                      trailing: results[index]['uid'] == this.currentUserId &&
                              this.currentUserId != this.ownerId &&
                              readWrite == true
                          ? FlatButton(
                              child: AutoSizeText(
                                'Leave',
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              onPressed: () {
                                setState(() {
                                  this.deletedTravelers = [
                                    ...this.deletedTravelers,
                                    results[index]['uid']
                                  ];
                                  final idx = this.travelers.indexWhere(
                                      (item) =>
                                          item['uid'] == results[index]['uid']);
                                  this.travelers.removeAt(idx);
                                  this.showSave = true;
                                });
                              },
                            )
                          : this.currentUserId == this.ownerId &&
                                  results[index]['uid'] == this.currentUserId
                              ? AutoSizeText('Organizer')
                              : this.currentUserId == this.ownerId &&
                                      readWrite == true
                                  ? IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          this.deletedTravelers = [
                                            ...this.deletedTravelers,
                                            results[index]['uid']
                                          ];
                                          this.travelers.removeAt(index - 1);
                                          this.showSave = true;
                                        });
                                      },
                                    )
                                  : Container(width: 20, height: 20),
                    );
                  },
                ))
              ]));
  }

  Container renderTopBar() {
    return Container(
        padding: EdgeInsets.only(top: 30, bottom: 10),
        // decoration: BoxDecoration(
        //     border: Border(
        //         bottom:
        //             BorderSide(width: 1, color: Colors.black.withOpacity(.1)))),
        child: Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.only(left: 10),
                    icon: SvgPicture.asset(
                      'images/back-icon.svg',
                      width: 30,
                      height: 30,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconSize: 25,
                    color: Colors.black,
                  ),
                  Expanded(
                      child: Container(
                          margin: EdgeInsets.only(left: 60),
                          child: AutoSizeText(
                            'All travelers',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                                fontSize: 19),
                          ))),
                  this.showSave == true
                      ? Center(
                          child: Container(
                              width: 100,
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
                                  Navigator.pop(context, {
                                    'added': this.addedTravelers,
                                    "deleted": this.deletedTravelers,
                                  });
                                },
                              )))
                      : Container(width: 100)
                ]),
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
