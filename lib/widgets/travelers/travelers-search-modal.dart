import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:share/share.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:trotter_flutter/globals.dart';

Future<TravelersModalData> fetchSearchUsers(
  String query,
) async {
  try {
    var response;

    response = await http.get('$ApiDomain/api/users/search?query=$query',
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
    return TravelersModalData(travelers: json['results'], success: true);
  }
}

class TravelersSearchModal extends StatefulWidget {
  final ValueChanged<dynamic> onAdd;
  final String ownerId;
  final String tripId;
  final String currentUserId;

  TravelersSearchModal(
      {Key key,
      @required this.ownerId,
      this.tripId,
      @required this.currentUserId,
      this.onAdd,
      s})
      : super(key: key);
  @override
  TravelersSearchModalState createState() => new TravelersSearchModalState(
        ownerId: this.ownerId,
        tripId: this.tripId,
        currentUserId: this.currentUserId,
        onAdd: this.onAdd,
      );
}

class TravelersSearchModalState extends State<TravelersSearchModal> {
  final String ownerId;
  final String tripId;
  final String currentUserId;
  final ValueChanged<dynamic> onAdd;
  List<Widget> selectedUsers = [];
  List<dynamic> travelersFull = [];
  List<String> selectedUsersUid = [];
  var txt = new TextEditingController();

  Future<TravelersModalData> data;

  @override
  void initState() {
    super.initState();
    txt.text = '';
    data = fetchSearchUsers(
      '',
    );
  }

  TravelersSearchModalState(
      {this.onAdd, this.currentUserId, this.ownerId, this.tripId});

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
                  return _buildLoadedBody(context, snapshot, true);
                case ConnectionState.done:
                  if (snapshot.hasData && snapshot.data.success) {
                    return _buildLoadedBody(context, snapshot, false);
                  } else if (snapshot.hasData &&
                      snapshot.data.success == false) {
                    return ErrorContainer(
                      onRetry: () {
                        setState(() {
                          data = fetchSearchUsers(
                            '',
                          );
                        });
                      },
                    );
                  }
              }
              return _buildLoadedBody(context, snapshot, true);
            }));
  }

  _deleteChip(String uid) {
    if (this.selectedUsers.length > 0) {
      setState(() {
        var index = this.selectedUsersUid.indexOf(uid);
        this.selectedUsersUid.removeAt(index);
        this.selectedUsers.removeAt(index);
        this.travelersFull.removeAt(index);
      });
    }
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, bool isLoading) {
    var results = snapshot.hasData && snapshot.data.success
        ? ['', ...snapshot.data.travelers]
        : [''];
    var timer;
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: isLoading
            ? Column(children: <Widget>[
                renderTopBar(timer),
                Flexible(child: _buildLoadingBody())
              ])
            : Column(children: <Widget>[
                renderTopBar(timer),
                Flexible(
                    child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        leading: Container(
                          child: Icon(Icons.share),
                        ),
                        title: AutoSizeText("Share"),
                        onTap: () {
                          Share.share(
                              'Lets plan our trip using Trotter. https://trotter.page.link/?link=http://ajibade.me?trip%3D${this.tripId}%26expired%3D${DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch}&apn=org.trotter.application');
                        },
                      );
                    }
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
                            this.travelersFull.add(results[index]);
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
                      trailing: results[index]['uid'] == this.ownerId
                          ? AutoSizeText('Organizer')
                          : AutoSizeText(''),
                    );
                  },
                ))
              ]));
  }

  Container renderTopBar(timer) {
    return Container(
        padding: EdgeInsets.only(top: 30, bottom: 10),
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
                    AutoSizeText(
                      'Search for travelers',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 19),
                    )
                  ]),
                  Center(
                      child: Container(
                          margin: EdgeInsets.only(right: 20),
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            child: AutoSizeText(
                              'Add',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                            textColor: Colors.lightBlue,
                            padding: EdgeInsets.all(0),
                            color: Colors.lightBlue.withOpacity(.3),
                            onPressed: () {
                              Navigator.pop(context, {
                                "travelers": this.selectedUsersUid,
                                "travelersFull": this.travelersFull
                              });
                            },
                          )))
                ]),
            TextField(
              enabled: true,
              controller: txt,
              cursorColor: Colors.black,
              textInputAction: TextInputAction.search,
              enableInteractiveSelection: true,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20, top: 10),
                  hintText: 'Search name or email...'),
              onChanged: (value) {
                if (timer != null) {
                  timer.cancel();
                  timer = null;
                }
                timer = new Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    data = fetchSearchUsers(value);
                  });
                });
              },
            ),
            Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(spacing: 10.0, children: this.selectedUsers)),
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
