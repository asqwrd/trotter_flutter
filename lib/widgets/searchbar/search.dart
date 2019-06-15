import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<SearchData> fetchSearch(
  String query,
  double lat,
  double lng,
  bool searchPoi,
) async {
  var response;
  try {
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
      return SearchData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      return SearchData(error: "Response > $msg");
    }
  } catch (error) {
    return SearchData(error: "Server is down");
  }
}

class SearchData {
  final List<dynamic> recentSearch;
  final List<dynamic> results;
  final String error;

  SearchData({this.results, this.recentSearch, this.error});

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
        results: json['results'],
        recentSearch: json['recent_search'],
        error: null);
  }
}

class Search extends StatefulWidget {
  final String query;
  final String id;
  final dynamic location;
  final String destinationName;
  final ValueChanged<dynamic> onPush;
  Search(
      {Key key,
      @required this.query,
      this.onPush,
      this.id,
      this.location,
      this.destinationName})
      : super(key: key);
  @override
  SearchState createState() => new SearchState(
      query: this.query,
      id: this.id,
      onPush: this.onPush,
      destinationName: this.destinationName,
      location: this.location);
}

class SearchState extends State<Search> {
  String query;
  String id;
  dynamic location;
  String destinationName;
  bool selectId = false;
  final ValueChanged<dynamic> onPush;
  GoogleMapController mapController;

  Future<SearchData> data;
  var txt = new TextEditingController();
  var timer;

  @override
  void initState() {
    super.initState();
    txt.text = '';
    selectId = this.id != null && this.id.isNotEmpty ? true : false;
    data = fetchSearch('', this.location != null ? this.location['lat'] : null,
        this.location != null ? this.location['lng'] : null, selectId);
  }

  @override
  void dispose() {
    txt.dispose();
    super.dispose();
  }

  SearchState(
      {this.query, this.onPush, this.id, this.location, this.destinationName});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return ErrorContainer(
                    color: Color.fromRGBO(106, 154, 168, 1),
                    onRetry: () {
                      setState(() {
                        data = fetchSearch('', this.location['lat'],
                            this.location['lng'], selectId);
                      });
                    },
                  );
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return _buildLoadedBody(context, snapshot, true, '');
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return _buildLoadedBody(context, snapshot, false, this.id);
                  } else if (snapshot.hasError) {
                    return ErrorContainer(
                      color: Color.fromRGBO(106, 154, 168, 1),
                      onRetry: () {
                        setState(() {
                          data = fetchSearch('', this.location['lat'],
                              this.location['lng'], selectId);
                        });
                      },
                    );
                  }
              }
            }));
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, bool isLoading, String id) {
    var recentSearch = snapshot.hasData ? snapshot.data.recentSearch : null;
    var results = snapshot.hasData ? snapshot.data.results : null;
    var error = snapshot.hasData ? snapshot.data.error : null;
    var chips = [
      FilterChip(
          selected: this.id != null && this.id.isNotEmpty ? !selectId : true,
          label: Text("Anywhere"),
          onSelected: (bool value) {
            setState(() {
              if (this.id.isNotEmpty) {
                selectId = !selectId;
                txt.text = '';
                data = fetchSearch(
                    '',
                    this.location != null ? this.location['lat'] : null,
                    this.location != null ? this.location['lng'] : null,
                    selectId);
              }
            });
          })
    ];

    if (this.location != null) {
      chips.add(FilterChip(
          selected: selectId,
          label: Text(this.destinationName),
          onSelected: (bool value) {
            setState(() {
              if (this.id != null) selectId = !selectId;
              txt.text = '';
              data = fetchSearch(
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
                data = fetchSearch(
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
                              ? 'Search for places in ${this.destinationName}...'
                              : 'Search for destinations to travel to...'),
                      onChanged: (value) {
                        if (timer != null) {
                          timer.cancel();
                          timer = null;
                        }
                        timer =
                            new Timer(const Duration(milliseconds: 500), () {
                          print('Print $value');
                          setState(() {
                            data = fetchSearch(
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
                  itemCount: results.length,
                  itemBuilder: (BuildContext context, int index) {
                    return selectId == false
                        ? InkWell(
                            onTap: () {
                              print(results[index]['google_place']);
                              onPush({
                                'id': results[index]['id'].toString(),
                                'level': results[index]['level'].toString(),
                                'from': 'search',
                                'google_place': results[index]['google_place']
                              });
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
                              onPush({
                                'id': results[index]['id'].toString(),
                                'level': results[index]['level'].toString(),
                                'from': 'search',
                                'google_place': results[index]['google_place']
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: ListTile(
                                  leading: Container(
                                    width: 130.0,
                                    height: 80.0,
                                    child: ClipPath(
                                        clipper: ShapeBorderClipper(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                        child: results[index]['image'] != null
                                            ? CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    SizedBox(
                                                        width: 50,
                                                        height: 50,
                                                        child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  new AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .blueAccent),
                                                            ))),
                                                fit: BoxFit.cover,
                                                imageUrl: results[index]
                                                    ['image'],
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Container(
                                                        decoration:
                                                            BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              'images/placeholder.jpg'),
                                                          fit: BoxFit.cover),
                                                    )))
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
              : error == null
                  ? ListView.builder(
                      itemCount: recentSearch.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {
                              setState(() {
                                txt.text = recentSearch[index]['value'];
                                data = fetchSearch(
                                    recentSearch[index]['value'],
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
                                  recentSearch[index]['value'],
                                )));
                      },
                    )
                  : ErrorContainer(
                      color: Color.fromRGBO(106, 154, 168, 1),
                      onRetry: () {
                        setState(() {
                          data = fetchSearch(
                              '',
                              this.location != null
                                  ? this.location['lat']
                                  : null,
                              this.location != null
                                  ? this.location['lng']
                                  : null,
                              selectId);
                        });
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
