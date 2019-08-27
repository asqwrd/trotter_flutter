import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trotter_flutter/globals.dart';

Future<SearchModalData> fetchSearchModal(
  String query,
  double lat,
  double lng,
  bool searchPoi,
) async {
  try {
    var response;
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
  final dynamic near;
  final String destinationName;
  final ValueChanged<dynamic> onSelect;
  SearchModal(
      {Key key,
      @required this.query,
      this.onSelect,
      this.id,
      this.location,
      this.near,
      this.destinationName})
      : super(key: key);
  @override
  SearchModalState createState() => new SearchModalState(
      query: this.query,
      id: this.id,
      destinationName: this.destinationName,
      onSelect: this.onSelect,
      near: this.near,
      location: this.location);
}

class SearchModalState extends State<SearchModal> {
  String query;
  String id;
  String destinationName;
  dynamic location;
  dynamic near;
  bool selectId = false;
  bool nearId = false;
  final ValueChanged<dynamic> onSelect;
  GoogleMapController mapController;

  Future<SearchModalData> data;
  var txt = new TextEditingController();

  @override
  void initState() {
    super.initState();
    txt.text = '';
    selectId = this.id != null && this.id.isNotEmpty ? true : false;
    nearId = this.id != null && this.id.isNotEmpty && this.near != null;
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
      this.near,
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
                  return AutoSizeText('Press button to start.');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return _buildLoadedBody(context, snapshot, true, '');
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return _buildLoadedBody(context, snapshot, false, this.id);
                  } else if (snapshot.hasError) {
                    return AutoSizeText('No Connection');
                  }
              }
              return _buildLoadedBody(context, snapshot, true, '');
            }));
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, bool isLoading, String id) {
    var timer;
    var recentSearchModal =
        snapshot.hasData ? snapshot.data.recentSearchModal : null;
    var results = snapshot.hasData ? snapshot.data.results : null;
    var error = snapshot.hasData ? snapshot.data.error : null;

    var chips = [
      ChoiceChip(
          selected: this.location != null ? !selectId : true,
          label: AutoSizeText("Destinations"),
          onSelected: (bool value) {
            setState(() {
              if (this.id.isNotEmpty) {
                selectId = false;
                nearId = false;
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
      chips.add(ChoiceChip(
          selected: selectId,
          label: AutoSizeText(this.destinationName),
          onSelected: (bool value) {
            setState(() {
              if (this.id != null) selectId = !selectId;
              if (selectId == false) {
                nearId = selectId;
              }
              txt.text = '';
              data = fetchSearchModal(
                  '',
                  this.location != null ? this.location['lat'] : null,
                  this.location != null ? this.location['lng'] : null,
                  selectId);
            });
          }));
    }

    if (this.near != null) {
      chips.add(ChoiceChip(
          selected: nearId,
          label: Container(
              constraints: BoxConstraints(maxWidth: 150),
              child: AutoSizeText(
                'near ${this.near['name']}',
                overflow: TextOverflow.ellipsis,
              )),
          onSelected: (bool value) {
            setState(() {
              if (this.id != null && this.near != null) nearId = !nearId;
              if (nearId == true) {
                selectId = true;
              }
              txt.text = '';
              data = fetchSearchModal('', this.near['location']['lat'],
                  this.near['location']['lng'], nearId || selectId);
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
                      child: ListView.builder(
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
                                  title: AutoSizeText(
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
                                                      BorderRadius.circular(
                                                          8))),
                                          child: results[index]['image'] != null
                                              ? TransitionToImage(
                                                  image: AdvancedNetworkImage(
                                                    results[index]['image'],
                                                    useDiskCache: true,
                                                    cacheRule: CacheRule(
                                                        maxAge: const Duration(
                                                            days: 7)),
                                                  ),
                                                  loadingWidgetBuilder:
                                                      (BuildContext context,
                                                              double progress,
                                                              test) =>
                                                          Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                    backgroundColor:
                                                        Colors.white,
                                                  )),
                                                  fit: BoxFit.cover,
                                                  alignment: Alignment.center,
                                                  placeholder:
                                                      const Icon(Icons.refresh),
                                                  enableRefresh: true,
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          'images/placeholder.jpg'),
                                                      fit: BoxFit.cover),
                                                ))),
                                    ),
                                    title: AutoSizeText(
                                      results[index]['name'],
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: results[index]
                                                ['description_short'] !=
                                            null
                                        ? AutoSizeText(
                                            results[index]['description_short'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300),
                                          )
                                        : AutoSizeText(
                                            results[index]['description'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w300),
                                          ),
                                  )));
                    },
                  ))
                ])
              : error != null && recentSearchModal != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                          renderTopBar(timer, chips),
                          Flexible(
                              child: ListView.builder(
                            //separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
                            itemCount: recentSearchModal.length,
                            //shrinkWrap: true,
                            primary: false,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                  onTap: () {
                                    setState(() {
                                      txt.text =
                                          recentSearchModal[index]['value'];
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
                                          vertical: 5, horizontal: 20),
                                      title: AutoSizeText(
                                        recentSearchModal[index]['value'],
                                      )));
                            },
                          ))
                        ])
                  : ListView(shrinkWrap: true, children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width,
                          child: ErrorContainer(
                            color: Color.fromRGBO(106, 154, 168, 1),
                            onRetry: () {
                              setState(() {
                                data = fetchSearchModal(
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
                          ))
                    ]),
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
                    child: AutoSizeText('Clear'),
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
                  hintText: selectId
                      ? 'Search for places in $destinationName...'
                      : 'Search for destinations to travel to...'),
              onChanged: (value) {
                if (timer != null) {
                  timer.cancel();
                  timer = null;
                }
                timer = new Timer(const Duration(milliseconds: 500), () {
                  setState(() {
                    data = fetchSearchModal(
                        value,
                        this.location != null ? this.location['lat'] : null,
                        this.location != null ? this.location['lng'] : null,
                        selectId);
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
