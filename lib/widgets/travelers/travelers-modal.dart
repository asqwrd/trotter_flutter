import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<TravelersModalData> fetchTravelersModal(
  String tripId,
) async {
  try {
    var response;

    response = await http.get(
        'http://localhost:3002/api/trips/$tripId/travelers',
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
  TravelersModal({Key key, @required this.tripId, this.onAdd, this.travelers})
      : super(key: key);
  @override
  TravelersModalState createState() => new TravelersModalState(
        tripId: this.tripId,
        travelers: this.travelers,
        onAdd: this.onAdd,
      );
}

class TravelersModalState extends State<TravelersModal> {
  String tripId;
  List<dynamic> travelers;
  final ValueChanged<dynamic> onAdd;
  GoogleMapController mapController;
  List<Widget> selectedUsers = [];
  List<String> selectedUsersUid = [];

  Future<TravelersModalData> data;

  @override
  void initState() {
    super.initState();
    for (var traveler in this.travelers) {
      this.selectedUsersUid.add(traveler['uid']);
      this.selectedUsers.add(Chip(
          avatar: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
            traveler['photoUrl'],
          )),
          label: Text("${traveler['displayName']}"),
          deleteIcon: Icon(Icons.close),
          onDeleted: () {
            this._deleteChip(traveler['uid']);
          }));
    }
    data = fetchTravelersModal(
      this.tripId,
    );
  }

  TravelersModalState({this.tripId, this.onAdd, this.travelers});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('Press button to start.');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return _buildLoadedBody(context, snapshot, true, '');
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return _buildLoadedBody(
                        context, snapshot, false, this.tripId);
                  } else if (snapshot.hasError) {
                    return Text('No Connection');
                  }
              }
            }));
  }

  _deleteChip(String uid) {
    setState(() {
      var index = this.selectedUsersUid.indexOf(uid);
      this.selectedUsersUid.removeAt(index);
      this.selectedUsers.removeAt(index);
    });
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, bool isLoading, String id) {
    var results = snapshot.hasData ? snapshot.data.travelers : [];

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          // centerTitle: true,
          title: Text(
            'Select travelers',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w300, fontSize: 24),
          ),
          actions: <Widget>[
            Center(
                child: Container(
                    margin: EdgeInsets.only(right: 20),
                    child: FlatButton(
                      child: Text(
                        'Save',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                      textColor: Colors.lightBlue,
                      padding: EdgeInsets.all(0),
                      color: Colors.lightBlue.withOpacity(.3),
                      onPressed: () {
                        Navigator.pop(
                            context, {"travelers": this.selectedUsersUid});
                      },
                    )))
          ],
          leading: IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
            iconSize: 30,
            color: Colors.black,
          ),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Wrap(spacing: 10.0, children: this.selectedUsers))),
        ),
        body: isLoading
            ? _buildLoadingBody()
            : ListView.builder(
                //separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
                itemCount: results.length,
                //shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    selected:
                        this.selectedUsersUid.contains(results[index]['uid']),
                    onTap: () {
                      var exists =
                          this.selectedUsersUid.contains(results[index]['uid']);
                      if (exists == false) {
                        setState(() {
                          this.selectedUsersUid.add(results[index]['uid']);
                          this.selectedUsers.add(Chip(
                              avatar: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                results[index]['photoUrl'],
                              )),
                              label: Text("${results[index]['displayName']}"),
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
                      width: 50.0,
                      height: 50.0,
                      child: ClipPath(
                          clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100))),
                          child: CachedNetworkImage(
                            placeholder: (context, url) => SizedBox(
                                width: 50,
                                height: 50,
                                child: Align(
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              Colors.blueAccent),
                                    ))),
                            fit: BoxFit.cover,
                            imageUrl: results[index]['photoUrl'],
                          )),
                    ),
                    title: Text(
                      results[index]['displayName'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  );
                },
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
