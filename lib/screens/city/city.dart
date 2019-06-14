import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trotter_flutter/widgets/itineraries/index.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';

Future<CityData> fetchCity(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('city_$id') ?? null;
  if (cacheData != null) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return CityData.fromJson(json.decode(cacheData));
  } else {
    try {
      print('no-cached');
      print(id);
      final response = await http.get(
          'http://localhost:3002/api/explore/cities/$id/',
          headers: {'Authorization': 'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('city_$id', response.body);
        return CityData.fromJson(json.decode(response.body));
      } else {
        // If that response was not OK, throw an error.
        var msg = response.statusCode;
        return CityData(error: 'Response > $msg');
      }
    } catch (error) {
      return CityData(error: 'Server is down');
    }
  }
}

class CityData {
  final String color;
  final Map<String, dynamic> city;
  final List<dynamic> discover;
  final List<dynamic> discoverLocations;
  final List<dynamic> eat;
  final List<dynamic> eatLocations;
  final List<dynamic> nightlife;
  final List<dynamic> nightlifeLocations;
  final List<dynamic> play;
  final List<dynamic> playLocations;
  final List<dynamic> relax;
  final List<dynamic> relaxLocations;
  final List<dynamic> see;
  final List<dynamic> seeLocations;
  final List<dynamic> shop;
  final List<dynamic> shopLocations;
  final String error;

  CityData(
      {this.color,
      this.city,
      this.discover,
      this.eat,
      this.nightlife,
      this.play,
      this.relax,
      this.see,
      this.shop,
      this.discoverLocations,
      this.eatLocations,
      this.nightlifeLocations,
      this.playLocations,
      this.relaxLocations,
      this.seeLocations,
      this.shopLocations,
      this.error});

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
        color: json['color'],
        city: json['city'],
        discover: json['discover'],
        eat: json['eat'],
        nightlife: json['nightlife'],
        play: json['play'],
        relax: json['relax'],
        see: json['see'],
        shop: json['shop'],
        error: null);
  }
}

class City extends StatefulWidget {
  final String cityId;
  final ValueChanged<dynamic> onPush;
  City({Key key, @required this.cityId, this.onPush}) : super(key: key);
  @override
  CitiesState createState() =>
      new CitiesState(cityId: this.cityId, onPush: this.onPush);
}

class CitiesState extends State<City> with SingleTickerProviderStateMixin {
  static String id;
  final String cityId;
  Future<CityData> data;
  final ValueChanged<dynamic> onPush;
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  Color color = Colors.transparent;
  String cityName;
  dynamic location;

  @override
  void initState() {
    _sc.addListener(() {
      setState(() {
        if (_pc.isPanelOpen()) {
          disableScroll = _sc.offset <= 0;
        }
      });
    });
    super.initState();
    data = fetchCity(this.cityId);
  }

  CitiesState({this.cityId, this.onPush});

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = MediaQuery.of(context).size.height - 110;
    double _panelHeightClosed = 100.0;
    data.then((data) => {
          if (data.error != null)
            {
              setState(() {
                this.errorUi = true;
              })
            }
          else
            if (data.error == null)
              {
                setState(() {
                  this.errorUi = false;
                  this.image = data.city['image'];
                  this.cityName = data.city['name'];
                  this.location = data.city['location'];
                  this.color = Color(hexStringToHexInt(data.color));
                })
              }
        });
    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingUpPanel(
        parallaxEnabled: true,
        parallaxOffset: .5,
        minHeight: errorUi == false ? _panelHeightClosed : _panelHeightOpen,
        controller: _pc,
        backdropEnabled: true,
        backdropColor: color,
        backdropTapClosesPanel: false,
        backdropOpacity: .8,
        onPanelOpened: () {
          setState(() {
            disableScroll = false;
          });
        },
        onPanelClosed: () {
          setState(() {
            disableScroll = true;
          });
        },
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        maxHeight: _panelHeightOpen,
        panel: Center(
            child: FutureBuilder(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadedBody(context, snapshot);
                  } else if (snapshot.hasData && snapshot.data.error == null) {
                    return _buildLoadedBody(context, snapshot);
                  } else if (snapshot.hasData && snapshot.data.error != null) {
                    return ErrorContainer(
                      onRetry: () {
                        setState(() {
                          data = fetchCity(this.cityId);
                        });
                      },
                    );
                  }
                })),
        body: Container(
            height: _bodyHeight,
            child: Stack(children: <Widget>[
              Positioned(
                  width: MediaQuery.of(context).size.width,
                  height: _bodyHeight,
                  top: 0,
                  left: 0,
                  child: this.image != null
                      ? CachedNetworkImage(
                          imageUrl: this.image,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: (context, url) => SizedBox(
                              width: 50,
                              height: 50,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.blueAccent),
                                  ))))
                      : Container()),
              Positioned.fill(
                top: 0,
                left: 0,
                child: Container(color: this.color.withOpacity(.3)),
              ),
              this.image == null
                  ? Positioned(
                      child: Center(
                          child: RefreshProgressIndicator(
                      backgroundColor: Colors.white,
                    )))
                  : Container()
            ])),
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              onPush: onPush,
              color: color,
              title: this.cityName,
              back: true,
              id: this.cityId,
              location: this.location)),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingBody(ctxt);
    }
    var city = snapshot.data.city;
    var descriptionShort = snapshot.data.city['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));
    var discover = snapshot.data.discover;
    var see = snapshot.data.see;
    var eat = snapshot.data.eat;
    var relax = snapshot.data.relax;
    var play = snapshot.data.play;
    var shop = snapshot.data.shop;
    var nightlife = snapshot.data.nightlife;
    var allTab = [
      {'items': discover, 'header': 'Discover'},
      {'items': see, 'header': 'See'},
      {'items': eat, 'header': 'Eat'},
      {'items': relax, 'header': 'Relax'},
      {'items': play, 'header': 'Play'},
      {'items': shop, 'header': 'Shop'},
      {'items': nightlife, 'header': 'Nightlife'},
    ];
    var tabContents = <Widget>[
      _buildTabContent(
          _buildAllTab(allTab, descriptionShort, color, city), 'All'),
    ];
    for (var tab in allTab) {
      if (tab['items'].length > 0) {
        tabContents.add(
          _buildListView(tab['items'], tab['header'], color, city),
        );
      }
    }

    return Container(
        height: MediaQuery.of(ctxt).size.height,
        child: DefaultTabController(
            length: tabContents.length,
            child: ListView(
              primary: false,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                Container(
                    color: Colors.transparent,
                    child: _renderTabBar(color, color, allTab)),
                Container(
                    width: MediaQuery.of(ctxt).size.width,
                    height: MediaQuery.of(ctxt).size.height - 180,
                    child: TabBarView(children: tabContents))
              ],
            )));
  }

  _buildTabContent(List<Widget> widgets, String key) {
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
        decoration: BoxDecoration(color: Colors.white),
        key: new PageStorageKey(key),
        child: ListView(
            controller: _sc,
            physics: disableScroll
                ? NeverScrollableScrollPhysics()
                : ClampingScrollPhysics(),
            children: widgets));
  }

  _buildAllTab(List<dynamic> sections, String description, Color color,
      dynamic destination) {
    var widgets = <Widget>[
      Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text(
            description,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300),
          ))
    ];
    for (var section in sections) {
      var items = section['items'];
      if (section['items'].length > 0) {
        widgets.add(TopList(
            items: section['items'],
            onPressed: (data) {
              onPush({'id': data['id'], 'level': data['level']});
            },
            onLongPressed: (data) async {
              var currentUser =
                  StoreProvider.of<AppState>(context).state.currentUser;
              if (currentUser == null) {
                loginBottomSheet(context, data, color);
              } else {
                var index = data['index'];
                await addToItinerary(context, items, index, color, destination);
              }
            },
            header: section['header']));
      }
    }
    return new List<Widget>.from(widgets)..addAll(<Widget>[]);
  }

  _buildListView(
      List<dynamic> items, String key, Color color, dynamic destination) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          controller: _sc,
          physics: disableScroll
              ? NeverScrollableScrollPhysics()
              : ClampingScrollPhysics(),
          key: new PageStorageKey(key),
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
                onTap: () {
                  var id = items[index]['id'];
                  var level = items[index]['level'];
                  onPush({'id': id.toString(), 'level': level.toString()});
                },
                onLongPress: () async {
                  var currentUser =
                      StoreProvider.of<AppState>(context).state.currentUser;
                  if (currentUser == null) {
                    loginBottomSheet(context, data, color);
                  } else {
                    await addToItinerary(
                        context, items, index, color, destination);
                  }
                },
                child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            width: 150,
                            height: 90,
                            margin: EdgeInsets.only(right: 20),
                            child: ClipPath(
                                clipper: ShapeBorderClipper(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                child: items[index]['image'] != null
                                    ? CachedNetworkImage(
                                        placeholder: (context, url) => SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: Align(
                                                alignment: Alignment.center,
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      new AlwaysStoppedAnimation<
                                                              Color>(
                                                          Colors.blueAccent),
                                                ))),
                                        fit: BoxFit.cover,
                                        imageUrl: items[index]['image'],
                                        errorWidget: (context, url, error) =>
                                            Container(
                                                decoration: BoxDecoration(
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
                                      )))),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width - 210,
                                  child: Text(
                                    items[index]['name'],
                                    maxLines: 2,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w500),
                                  )),
                              Container(
                                  margin: EdgeInsets.only(top: 5),
                                  width:
                                      MediaQuery.of(context).size.width - 210,
                                  child: Text(
                                    items[index]['description_short'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w300),
                                  ))
                            ],
                          ),
                        )
                      ],
                    )));
          },
        ));
  }

  _renderTab(String label) {
    return Text(label,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w300,
        ));
  }

  _renderTabBar(Color mainColor, Color fontColor, List<dynamic> sections) {
    var tabs = [
      Tab(child: _renderTab('All')),
    ];

    for (var section in sections) {
      if (section['items'].length > 0) {
        tabs.add(
          Tab(child: _renderTab(section['header'])),
        );
      }
    }

    return TabBar(
      labelColor: mainColor,
      isScrollable: true,
      unselectedLabelColor: Colors.black.withOpacity(0.6),
      indicator: BoxDecoration(
          border: Border(bottom: BorderSide(color: mainColor, width: 2.0))),
      tabs: tabs,
    );
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    var children2 = <Widget>[
      TabBarLoading(),
      Container(
          height: 175.0,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 30.0),
          child: TopListLoading()),
      Container(
          height: 175.0,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 30.0),
          child: TopListLoading()),
      Container(
          height: 175.0,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 30.0),
          child: TopListLoading()),
    ];
    return Container(
      padding: EdgeInsets.only(top: 0.0),
      decoration: BoxDecoration(color: Colors.transparent),
      child: ListView(
        controller: _sc,
        physics: disableScroll
            ? NeverScrollableScrollPhysics()
            : ClampingScrollPhysics(),
        children: children2,
      ),
    );
  }
}
