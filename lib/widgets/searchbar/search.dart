import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_loader/awesome_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:trotter_flutter/globals.dart';

Future<SearchData> fetchSearch(
  String query,
  double lat,
  double lng,
  bool searchPoi,
) async {
  var response;
  try {
    if (query.isEmpty && !searchPoi) {
      response = await http.get('$ApiDomain/api/search/recent',
          headers: {'Authorization': 'security'});
    } else if (query.isEmpty && searchPoi) {
      response = await http.get('$ApiDomain/api/search/recent?poi=true',
          headers: {'Authorization': 'security'});
    } else if (query.isNotEmpty && (lat != null && lng != null) && searchPoi) {
      response = await http.get(
          '$ApiDomain/api/search/google/$query?lat=$lat&lng=$lng',
          headers: {'Authorization': 'security'});
    } else {
      response = await http.get('$ApiDomain/api/search/find/$query',
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

Future<SearchData> fetchSearchNext(
  String query,
  double lat,
  double lng,
  String nextPageToken,
) async {
  try {
    var response;
    response = await http.get(
        '$ApiDomain/api/search/google/$query?lat=$lat&lng=$lng&nextPageToken=$nextPageToken',
        headers: {'Authorization': 'security'});

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return SearchData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      return SearchData(error: 'Server error');
    }
  } catch (error) {
    return SearchData(error: 'Server error');
  }
}

class SearchData {
  final List<dynamic> recentSearch;
  final List<dynamic> results;
  final String error;
  final String nextPageToken;

  SearchData({this.results, this.recentSearch, this.error, this.nextPageToken});

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
        results: json['results'],
        nextPageToken: json['nextPageToken'],
        recentSearch: json['recent_search'],
        error: null);
  }
}

class Search extends StatefulWidget {
  final String query;
  final String id;
  final dynamic location;
  final String destinationName;
  final dynamic destination;
  final ValueChanged<dynamic> onPush;
  Search(
      {Key key,
      @required this.query,
      this.onPush,
      this.id,
      this.location,
      this.destination,
      this.destinationName})
      : super(key: key);
  @override
  SearchState createState() => new SearchState(
      query: this.query,
      id: this.id,
      onPush: this.onPush,
      destination: this.destination,
      destinationName: this.destinationName,
      location: this.location);
}

class SearchState extends State<Search> {
  String query;
  String id;
  dynamic location;
  String destinationName;
  final dynamic destination;
  bool selectId = false;
  final ValueChanged<dynamic> onPush;
  List<dynamic> results;
  String nextPageToken;

  Future<SearchData> data;
  var txt = new TextEditingController();
  var timer;
  bool isSearchLoading = false;

  @override
  void initState() {
    super.initState();
    txt.text = '';
    selectId = this.id != null && this.id.isNotEmpty ? true : false;
    data = fetchSearch('', this.location != null ? this.location['lat'] : null,
        this.location != null ? this.location['lng'] : null, selectId);
    data.then((res) {
      setState(() {
        this.nextPageToken = res.nextPageToken;
        this.results = res.results;
      });
    });
  }

  @override
  void dispose() {
    txt.dispose();
    super.dispose();
  }

  SearchState(
      {this.query,
      this.onPush,
      this.id,
      this.location,
      this.destination,
      this.destinationName});

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
                  return SingleChildScrollView(
                      child: ErrorContainer(
                    color: Color.fromRGBO(106, 154, 168, 1),
                    onRetry: () {
                      setState(() {
                        data = fetchSearch('', this.location['lat'],
                            this.location['lng'], selectId);
                      });
                      data.then((res) {
                        setState(() {
                          this.nextPageToken = res.nextPageToken;
                          this.results = res.results;
                        });
                      });
                    },
                  ));
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
                          data.then((res) {
                            setState(() {
                              this.nextPageToken = res.nextPageToken;
                              this.results = res.results;
                            });
                          });
                        });
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
    var recentSearch = snapshot.hasData ? snapshot.data.recentSearch : null;
    var results = this.results;
    var error = snapshot.hasData ? snapshot.data.error : null;
    var chips = [
      ChoiceChip(
          selected: this.id != null && this.id.isNotEmpty ? !selectId : true,
          label: AutoSizeText("Destinations"),
          onSelected: (bool value) {
            setState(() {
              if (this.id != null && this.id.isNotEmpty) {
                selectId = !selectId;
                txt.text = '';
                data = fetchSearch(
                    '',
                    this.location != null ? this.location['lat'] : null,
                    this.location != null ? this.location['lng'] : null,
                    selectId);
                data.then((res) {
                  setState(() {
                    this.nextPageToken = res.nextPageToken;
                    this.results = res.results;
                  });
                });
              }
            });
          })
    ];

    if (this.location != null) {
      chips.add(ChoiceChip(
          selected: selectId,
          label: AutoSizeText(this.destinationName),
          onSelected: (bool value) {
            setState(() {
              if (this.id != null) selectId = !selectId;
              txt.text = '';
              data = fetchSearch(
                  '',
                  this.location != null ? this.location['lat'] : null,
                  this.location != null ? this.location['lng'] : null,
                  selectId);
              data.then((res) {
                setState(() {
                  this.nextPageToken = res.nextPageToken;
                  this.results = res.results;
                });
              });
            });
          }));
    }
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: isLoading
            ? Column(children: <Widget>[
                renderTopBar(timer, chips),
                Flexible(child: _buildLoadingBody())
              ])
            : results != null
                ? Column(children: <Widget>[
                    renderTopBar(timer, chips),
                    Flexible(
                        child: this.location != null
                            ? LazyLoadScrollView(
                                onEndOfPage: () async {
                                  if (this.results != null &&
                                      this.nextPageToken.isNotEmpty) {
                                    setState(() {
                                      this.isSearchLoading = true;
                                    });
                                    var res = await fetchSearchNext(
                                        txt.text,
                                        this.location['lat'],
                                        this.location['lng'],
                                        this.nextPageToken);
                                    setState(() {
                                      this.results = this.results
                                        ..addAll(res.results);
                                      this.nextPageToken = res.nextPageToken;
                                      this.isSearchLoading = false;
                                    });
                                  }
                                  return true;
                                },
                                child: renderResults(results))
                            : renderResults(results)),
                    this.isSearchLoading
                        ? AwesomeLoader(
                            loaderType: AwesomeLoader.AwesomeLoader4,
                            color: Colors.blueAccent,
                          )
                        : Container(),
                  ])
                : error == null && recentSearch != null
                    ? Column(children: <Widget>[
                        renderTopBar(timer, chips),
                        Flexible(
                            child: ListView.builder(
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
                                    data.then((res) {
                                      setState(() {
                                        this.nextPageToken = res.nextPageToken;
                                        this.results = res.results;
                                      });
                                    });
                                  });
                                },
                                child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    title: AutoSizeText(
                                      recentSearch[index]['value'],
                                    )));
                          },
                        ))
                      ])
                    : SingleChildScrollView(
                        child: ErrorContainer(
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
                            data.then((res) {
                              setState(() {
                                this.nextPageToken = res.nextPageToken;
                                this.results = res.results;
                              });
                            });
                          });
                        },
                      )));
  }

  ListView renderResults(results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        return selectId == false
            ? InkWell(
                onTap: () {
                  onPush({
                    'id': results[index]['id'].toString(),
                    'level': results[index]['level'].toString(),
                    'from': 'search',
                    'destination': this.destination,
                    'google_place': results[index]['google_place']
                  });
                },
                child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    title: AutoSizeText(
                      results[index]['country_id'] == 'United_States' &&
                              results[index]['type'] != 'region'
                          ? '${results[index]['name']}, ${results[index]['parent_name']}, ${results[index]['country_name']}'
                          : '${results[index]['name']}, ${results[index]['country_name']}',
                    )))
            : InkWell(
                onTap: () {
                  onPush({
                    'id': results[index]['id'].toString(),
                    'level': results[index]['level'].toString(),
                    'from': 'search',
                    'destination': this.destination,
                    'google_place': results[index]['google_place']
                  });
                },
                child: Container(
                    margin: EdgeInsets.symmetric(vertical: 0),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      leading: Container(
                        width: 80.0,
                        height: 80.0,
                        child: ClipPath(
                            clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: results[index]['image'] != null
                                ? TransitionToImage(
                                    image: AdvancedNetworkImage(
                                      results[index]['image'],
                                      useDiskCache: true,
                                      cacheRule: CacheRule(
                                          maxAge: const Duration(days: 7)),
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
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'images/placeholder.png'),
                                        fit: BoxFit.cover),
                                  ))),
                      ),
                      title: AutoSizeText(
                        results[index]['name'],
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: results[index]['description_short'] != null
                          ? AutoSizeText(
                              results[index]['description_short'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
                            )
                          : AutoSizeText(
                              results[index]['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
                            ),
                    )));
      },
    );
  }

  Container renderTopBar(timer, List<ChoiceChip> chips) {
    return Container(
      padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          border: Border(
              bottom:
                  BorderSide(width: 1, color: Colors.black.withOpacity(.1)))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    iconSize: 30,
                    color: Colors.black,
                  ),
                  FlatButton(
                    child: AutoSizeText('Clear',
                        style: TextStyle(color: Colors.blue)),
                    color: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    onPressed: () {
                      setState(() {
                        txt.text = '';
                        data = fetchSearch(
                            '',
                            this.location != null ? this.location['lat'] : null,
                            this.location != null ? this.location['lng'] : null,
                            selectId);
                        data.then((res) {
                          setState(() {
                            this.nextPageToken = res.nextPageToken;
                            this.results = res.results;
                          });
                        });
                      });
                    },
                  )
                ]),
            TextField(
              enabled: true,
              controller: txt,
              cursorColor: Colors.black,
              textInputAction: TextInputAction.search,
              enableInteractiveSelection: true,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  hintText: selectId
                      ? 'Search for places in ${this.destinationName}...'
                      : 'Search for destinations to travel to...'),
              // onChanged: (value) {
              //   if (timer != null) {
              //     timer.cancel();
              //     timer = null;
              //   }
              //   timer = new Timer(const Duration(milliseconds: 500), () {
              //     print('Print $value');
              //     setState(() {
              //       data = fetchSearch(
              //           value,
              //           this.location != null ? this.location['lat'] : null,
              //           this.location != null ? this.location['lng'] : null,
              //           selectId);
              //       data.then((res) {
              //         setState(() {
              //           this.nextPageToken = res.nextPageToken;
              //           this.results = res.results;
              //         });
              //       });
              //     });
              //   });
              // },
              onEditingComplete: () {
                setState(() {
                  data = fetchSearch(
                      txt.text,
                      this.location != null ? this.location['lat'] : null,
                      this.location != null ? this.location['lng'] : null,
                      selectId);
                  data.then((res) {
                    setState(() {
                      this.nextPageToken = res.nextPageToken;
                      this.results = res.results;
                    });
                  });
                });
              },
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                child: Wrap(spacing: 10.0, children: chips))
          ]),
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
