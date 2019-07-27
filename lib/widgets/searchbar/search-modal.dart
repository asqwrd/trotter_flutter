import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<SearchModalData> fetchSearchModal(
  String query,
  double lat,
  double lng,
  bool searchPoi,
) async {
  try {
    var response;
    if (query.isEmpty && !searchPoi) {
      response = await http.get('http://localhost:3002/api/search/recent',
          headers: {'Authorization': 'security'});
    } else if (query.isEmpty && searchPoi) {
      response = await http.get(
          'http://localhost:3002/api/search/recent?poi=true',
          headers: {'Authorization': 'security'});
    } else if (query.isNotEmpty && (lat != null && lng != null) && searchPoi) {
      response = await http.get(
          'http://localhost:3002/api/search/google/$query?lat=${lat}&lng=$lng',
          headers: {'Authorization': 'security'});
    } else {
      response = await http.get('http://localhost:3002/api/search/find/$query',
          headers: {'Authorization': 'security'});
    }

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return SearchModalData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return SearchModalData(success: false);
    }
  } catch (error) {
    return SearchModalData(success: false);
  }
}

class SearchModalData {
  final List<dynamic> recentSearchModal;
  final List<dynamic> results;
  final bool success;

  SearchModalData({this.results, this.recentSearchModal, this.success});

  factory SearchModalData.fromJson(Map<String, dynamic> json) {
    return SearchModalData(
        results: json['results'],
        recentSearchModal: json['recent_search'],
        success: true);
  }
}

class SearchModal extends StatefulWidget {
  final String query;
  final String id;
  final dynamic location;
  final String destinationName;
  final ValueChanged<dynamic> onSelect;
  SearchModal(
      {Key key,
      @required this.query,
      this.onSelect,
      this.id,
      this.location,
      this.destinationName})
      : super(key: key);
  @override
  SearchModalState createState() => new SearchModalState(
      query: this.query,
      id: this.id,
      destinationName: this.destinationName,
      onSelect: this.onSelect,
      location: this.location);
}

class SearchModalState extends State<SearchModal> {
  String query;
  String id;
  String destinationName;
  dynamic location;
  bool selectId = false;
  final ValueChanged<dynamic> onSelect;
  GoogleMapController mapController;

  Future<SearchModalData> data;
  var txt = new TextEditingController();

  @override
  void initState() {
    super.initState();
    txt.text = '';
    selectId = this.id != null && this.id.isNotEmpty ? true : false;
    data = fetchSearchModal(
        '',
        this.location != null ? this.location['lat'] : null,
        this.location != null ? this.location['lng'] : null,
        selectId);
  }

  SearchModalState(
      {this.query,
      this.onSelect,
      this.id,
      this.destinationName,
      this.location});

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
                    return _buildLoadedBody(context, snapshot, false, this.id);
                  } else if (snapshot.hasError) {
                    return Text('No Connection');
                  }
              }
            }));
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, bool isLoading, String id) {
    var timer;
    var recentSearchModal =
        snapshot.hasData ? snapshot.data.recentSearchModal : null;
    var results = snapshot.hasData ? snapshot.data.results : null;
    var chips = [
      FilterChip(
          selected: this.location != null ? !selectId : true,
          label: Text("Anywhere"),
          onSelected: (bool value) {
            setState(() {
              if (this.id.isNotEmpty) {
                selectId = !selectId;
                txt.text = '';
                data = fetchSearchModal(
                    '',
                    this.location != null ? this.location['lat'] : null,
                    this.location != null ? this.location['lng'] : null,
                    selectId);
              }
            });
          })
    ];

    if (this.destinationName != null) {
      chips.add(FilterChip(
          selected: selectId,
          label: Text(this.destinationName),
          onSelected: (bool value) {
            setState(() {
              if (this.id != null) selectId = !selectId;
              txt.text = '';
              data = fetchSearchModal(
                  '',
                  this.location != null ? this.location['lat'] : null,
                  this.location != null ? this.location['lng'] : null,
                  selectId);
            });
          }));
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        leading: IconButton(
          padding: EdgeInsets.all(0),
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
          iconSize: 30,
          color: Colors.black,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Clear'),
            onPressed: () {
              setState(() {
                txt.text = '';
                data = fetchSearchModal(
                    '',
                    this.location != null ? this.location['lat'] : null,
                    this.location != null ? this.location['lng'] : null,
                    selectId);
              });
            },
          )
        ],
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(80),
            child: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      enabled: true,
                      controller: txt,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.search,
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20.0),
                          hintText: selectId
                              ? 'Search for places in $destinationName...'
                              : 'Search for destinations to travel to...'),
                      onChanged: (value) {
                        if (timer != null) {
                          timer.cancel();
                          timer = null;
                        }
                        timer =
                            new Timer(const Duration(milliseconds: 500), () {
                          setState(() {
                            data = fetchSearchModal(
                                value,
                                this.location != null
                                    ? this.location['lat']
                                    : null,
                                this.location != null
                                    ? this.location['lng']
                                    : null,
                                selectId);
                          });
                        });
                      },
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Wrap(spacing: 10.0, children: chips))
                  ]),
            )),
      ),
      body: isLoading
          ? _buildLoadingBody()
          : results != null
              ? ListView.builder(
                  //separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
                  itemCount: results.length,
                  //shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return selectId == false
                        ? InkWell(
                            onTap: () {
                              //onSelect({'selected':results[index]});
                              Navigator.pop(context, results[index]);
                            },
                            child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                title: Text(
                                  results[index]['country_id'] ==
                                          'United_States'
                                      ? '${results[index]['name']}, ${results[index]['parent_name']}, ${results[index]['country_name']}'
                                      : '${results[index]['name']}, ${results[index]['country_name']}',
                                )))
                        : InkWell(
                            onTap: () {
                              //onSelect({'selected':results[index]});
                              Navigator.pop(context, results[index]);
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: ListTile(
                                  leading: Container(
                                    width: 80.0,
                                    height: 80.0,
                                    child: ClipPath(
                                        clipper: ShapeBorderClipper(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        child: results[index]['image'] != null
                                            ? TransitionToImage(
                                                image: AdvancedNetworkImage(
                                                  results[index]['image'],
                                                  useDiskCache: true,
                                                  cacheRule: CacheRule(
                                                      maxAge: const Duration(
                                                          days: 7)),
                                                ),
                                                loadingWidgetBuilder: (BuildContext
                                                            context,
                                                        double progress,
                                                        test) =>
                                                    Center(
                                                        child:
                                                            RefreshProgressIndicator(
                                                  backgroundColor: Colors.white,
                                                )),
                                                fit: BoxFit.cover,
                                                alignment: Alignment.center,
                                                placeholder:
                                                    const Icon(Icons.refresh),
                                                enableRefresh: true,
                                              )
                                            // CachedNetworkImage(
                                            //     placeholder: (context, url) =>
                                            //         SizedBox(
                                            //             width: 50,
                                            //             height: 50,
                                            //             child: Align(
                                            //                 alignment: Alignment
                                            //                     .center,
                                            //                 child:
                                            //                     CircularProgressIndicator(
                                            //                   valueColor:
                                            //                       new AlwaysStoppedAnimation<
                                            //                               Color>(
                                            //                           Colors
                                            //                               .blueAccent),
                                            //                 ))),
                                            //     fit: BoxFit.cover,
                                            //     imageUrl: results[index]
                                            //         ['image'],
                                            //     errorWidget: (context, url,
                                            //             error) =>
                                            //         Container(
                                            //             decoration:
                                            //                 BoxDecoration(
                                            //           image: DecorationImage(
                                            //               image: AssetImage(
                                            //                   'images/placeholder.jpg'),
                                            //               fit: BoxFit.cover),
                                            //         )))
                                            : Container(
                                                decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'images/placeholder.jpg'),
                                                    fit: BoxFit.cover),
                                              ))),
                                  ),
                                  title: Text(
                                    results[index]['name'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: results[index]
                                              ['description_short'] !=
                                          null
                                      ? Text(
                                          results[index]['description_short'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300),
                                        )
                                      : Text(
                                          results[index]['description'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w300),
                                        ),
                                )));
                  },
                )
              : ListView.builder(
                  //separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
                  itemCount: recentSearchModal.length,
                  //shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () {
                          setState(() {
                            txt.text = recentSearchModal[index]['value'];
                            data = fetchSearchModal(
                                recentSearchModal[index]['value'],
                                this.location != null
                                    ? this.location['lat']
                                    : null,
                                this.location != null
                                    ? this.location['lng']
                                    : null,
                                selectId);
                          });
                        },
                        child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            title: Text(
                              recentSearchModal[index]['value'],
                            )));
                  },
                ),
    );
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
