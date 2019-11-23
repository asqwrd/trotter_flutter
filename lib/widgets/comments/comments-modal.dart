import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_loader/awesome_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:trotter_flutter/store/auth.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:trotter_flutter/globals.dart';
import 'package:timeago/timeago.dart' as timeago;

Future<CommentsData> fetchCommentsModal(
    String dayId, String itineraryId, String itineraryItemId,
    [String last]) async {
  try {
    var response;

    response = await http.get(
        '$ApiDomain/api/itineraries/get/$itineraryId/day/$dayId/itinerary_items/$itineraryItemId/comments?last=$last',
        headers: {'Authorization': 'security'});

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return CommentsData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return CommentsData(success: false);
    }
  } catch (error) {
    return CommentsData(success: false);
  }
}

Future<CommentData> postCommentsModal(String dayId, String itineraryId,
    String itineraryItemId, String tripId, dynamic data) async {
  try {
    var response;
    response = await http.post(
        '$ApiDomain/api/itineraries/$itineraryId/day/$dayId/itinerary_items/$itineraryItemId/comments/add?tripId=$tripId',
        headers: {'Authorization': 'security'},
        body: json.encode(data));

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return CommentData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return CommentData(success: false);
    }
  } catch (error) {
    print(error);
    return CommentData(success: false);
  }
}

class CommentsData {
  final List<dynamic> comments;
  final int total;
  final bool success;

  CommentsData({this.comments, this.total, this.success});

  factory CommentsData.fromJson(Map<String, dynamic> json) {
    return CommentsData(
        comments: json['comments'],
        total: json['total_comments']['total'],
        success: true);
  }
}

class CommentData {
  final dynamic comment;
  final dynamic total;
  final bool success;

  CommentData({this.comment, this.total, this.success});

  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
        comment: json['comment'], total: json['total'], success: true);
  }
}

class CommentsModal extends StatefulWidget {
  final String dayId;
  final String itineraryId;
  final String tripId;
  final String itineraryItemId;
  final String currentUserId;
  final String title;

  CommentsModal({
    Key key,
    @required this.itineraryId,
    @required this.itineraryItemId,
    @required this.dayId,
    @required this.tripId,
    @required this.title,
    @required this.currentUserId,
  }) : super(key: key);
  @override
  CommentsModalState createState() => new CommentsModalState(
        dayId: this.dayId,
        itineraryId: this.itineraryId,
        tripId: this.tripId,
        title: this.title,
        itineraryItemId: this.itineraryItemId,
        currentUserId: this.currentUserId,
      );
}

class CommentsModalState extends State<CommentsModal> {
  final String itineraryId;
  final String itineraryItemId;
  final String dayId;
  final String tripId;
  final String title;
  final String currentUserId;
  List<dynamic> comments = [];
  bool sending = false;
  int total = 0;
  dynamic data;
  var txt = new TextEditingController();
  var _sc = new ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      data = fetchCommentsModal(
          this.dayId, this.itineraryId, this.itineraryItemId, '');
      data.then((res) {
        print(res.total);
        this.comments = res.comments;
        this.total = res.total;
      });
    });
  }

  CommentsModalState({
    this.itineraryId,
    this.itineraryItemId,
    this.dayId,
    this.tripId,
    this.title,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, {"total_comments": this.comments.length});
          return;
        },
        child: Scaffold(
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
                            if (this.comments == null) {
                              data = fetchCommentsModal(this.dayId,
                                  this.itineraryId, this.itineraryItemId);
                              data.then((data) {
                                setState(() {
                                  this.comments = data.comments;
                                });
                              });
                            } else {
                              data = fetchCommentsModal(this.dayId,
                                  this.itineraryId, this.itineraryItemId);
                            }
                          },
                        );
                      }
                  }
                  return _buildLoadedBody(context, snapshot, true);
                })));
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, bool isLoading) {
    var results = this.comments;

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
                    child: Stack(fit: StackFit.expand, children: <Widget>[
                  LazyLoadScrollView(
                      onEndOfPage: () async {
                        if (this.comments.length > 0 &&
                            this.comments.length < this.total) {
                          setState(() {
                            this.isLoading = true;
                          });
                          var last = this
                              .comments[this.comments.length - 1]['created_at']
                              .toString();
                          var res = await fetchCommentsModal(this.dayId,
                              this.itineraryId, this.itineraryItemId, last);
                          setState(() {
                            this.comments = this.comments..addAll(res.comments);
                            this.isLoading = false;
                          });
                        }
                        return true;
                      },
                      child: ListView.builder(
                        controller: _sc,
                        itemCount: results.length,
                        itemBuilder: (BuildContext context, int index) {
                          final user =
                              TrotterUser.fromJson(results[index]['user']);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AdvancedNetworkImage(
                                  user.photoUrl,
                                  useDiskCache: true,
                                  cacheRule:
                                      CacheRule(maxAge: Duration(days: 1))),
                            ),
                            title: AutoSizeText(user.displayName),
                            subtitle: AutoSizeText(results[index]['msg']),
                            trailing: AutoSizeText(timeago.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    results[index]['created_at']))),
                          );
                        },
                      )),
                  this.sending == true
                      ? Center(
                          child: RefreshProgressIndicator(
                          backgroundColor: Colors.white,
                        ))
                      : Container()
                ])),
                this.isLoading
                    ? AwesomeLoader(
                        loaderType: AwesomeLoader.AwesomeLoader4,
                        color: Colors.blueAccent,
                      )
                    : Container(),
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top:
                              BorderSide(color: Colors.black.withOpacity(.1)))),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Center(
                        child: TextField(
                      enabled: true,
                      controller: txt,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.newline,
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a comment..."),
                    )),
                    trailing: IconButton(
                      icon: Icon(SimpleLineIcons.paper_plane),
                      onPressed: () async {
                        if (this.sending == false) {
                          final store = Provider.of<TrotterStore>(ctxt);
                          final data = {
                            "msg": txt.text,
                            "created_at": DateTime.now().millisecondsSinceEpoch,
                            "user": {
                              "uid": store.currentUser.uid,
                              "photoUrl": store.currentUser.photoUrl,
                              "email": store.currentUser.email,
                              "phoneNumber": store.currentUser.phoneNumber,
                              "displayName": store.currentUser.displayName
                            }
                          };
                          setState(() {
                            this.sending = true;
                          });
                          final response = await postCommentsModal(
                              this.dayId,
                              this.itineraryId,
                              this.itineraryItemId,
                              this.tripId,
                              data);
                          if (response.success == true) {
                            setState(() {
                              this.comments.add(response.comment);
                              txt.clear();
                              _sc.animateTo(MediaQuery.of(context).size.height,
                                  duration: Duration(milliseconds: 1000),
                                  curve: Curves.ease);
                              this.sending = false;
                            });
                          }
                        }
                      },
                    ),
                  ),
                )
              ]));
  }

  Container renderTopBar() {
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
                        Navigator.pop(
                            context, {"total_comments": this.comments.length});
                      },
                      iconSize: 25,
                      color: Colors.black,
                    ),
                    AutoSizeText(
                      this.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 19),
                    )
                  ]),
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
