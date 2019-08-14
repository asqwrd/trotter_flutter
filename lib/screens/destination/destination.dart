import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:loadmore/loadmore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/itineraries/index.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/globals.dart';

Future<DestinationData> fetchDestination(
    String id, String destinationType) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('destination_$id') ?? null;
  final int cacheDataExpire =
      prefs.getInt('destination_$id-expiration') ?? null;
  final currentTime = DateTime.now().millisecondsSinceEpoch;
  if (cacheData != null &&
      cacheDataExpire != null &&
      (currentTime < cacheDataExpire)) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return DestinationData.fromJson(json.decode(cacheData));
  } else {
    try {
      print('no-cached');
      print(id);
      final response = await http.get(
          '$ApiDomain/api/explore/destinations/$id?type=$destinationType',
          headers: {'Authorization': 'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('destination_$id', response.body);
        await prefs.setInt('destination_$id-expiration',
            DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch);
        return DestinationData.fromJson(json.decode(response.body));
      } else {
        // If that response was not OK, throw an error.
        var msg = response.statusCode;
        return DestinationData(error: 'Response > $msg');
      }
    } catch (error) {
      return DestinationData(error: 'Server is down');
    }
  }
}

class DestinationData {
  final String color;
  final Map<String, dynamic> destination;
  final dynamic discover;
  final dynamic discoverLocations;
  final dynamic eat;
  final dynamic eatLocations;
  final dynamic nightlife;
  final dynamic nightlifeLocations;
  final dynamic play;
  final dynamic playLocations;
  final dynamic relax;
  final dynamic relaxLocations;
  final dynamic see;
  final dynamic seeLocations;
  final dynamic shop;
  final dynamic shopLocations;
  final String error;

  DestinationData(
      {this.color,
      this.destination,
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

  factory DestinationData.fromJson(Map<String, dynamic> json) {
    return DestinationData(
        color: json['color'],
        destination: json['destination'],
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

class Destination extends StatefulWidget {
  final String destinationId;
  final String destinationType;
  final ValueChanged<dynamic> onPush;
  Destination(
      {Key key,
      @required this.destinationId,
      @required this.destinationType,
      this.onPush})
      : super(key: key);
  @override
  DestinationState createState() => new DestinationState(
      destinationId: this.destinationId,
      destinationType: this.destinationType,
      onPush: this.onPush);
}

class DestinationState extends State<Destination>
    with SingleTickerProviderStateMixin {
  static String id;
  final String destinationId;
  final String destinationType;
  Future<DestinationData> data;
  final ValueChanged<dynamic> onPush;
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  Color color = Colors.transparent;
  String destinationName;
  dynamic location;
  dynamic discover = [];
  dynamic eat = [];
  dynamic play = [];
  dynamic nightlife = [];
  dynamic shop = [];
  dynamic relax = [];
  dynamic see = [];

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
    data = fetchDestination(this.destinationId, this.destinationType);
  }

  DestinationState({this.destinationId, this.destinationType, this.onPush});

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
          else if (data.error == null)
            {
              setState(() {
                this.errorUi = false;
                this.image = data.destination['image'];
                //print(this.image);
                this.destinationName = data.destination['name'];
                this.location = data.destination['location'];
                this.color = Color(hexStringToHexInt(data.color));
                this.discover = data.discover;
                this.eat = data.eat;
                this.see = data.see;
                this.relax = data.relax;
                this.play = data.play;
                this.nightlife = data.nightlife;
                this.shop = data.shop;
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
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            maxHeight: _panelHeightOpen,
            panel: Center(
                child: FutureBuilder(
                    future: data,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadedBody(context, snapshot);
                      } else if (snapshot.hasData &&
                          snapshot.data.error == null) {
                        return _buildLoadedBody(context, snapshot);
                      } else if (snapshot.hasData &&
                          snapshot.data.error != null) {
                        return ListView(
                            controller: _sc,
                            physics: disableScroll
                                ? NeverScrollableScrollPhysics()
                                : ClampingScrollPhysics(),
                            shrinkWrap: true,
                            children: <Widget>[
                              Container(
                                  height: _panelHeightOpen - 80,
                                  width: MediaQuery.of(context).size.width,
                                  child: ErrorContainer(
                                    onRetry: () {
                                      setState(() {
                                        data = fetchDestination(
                                            this.destinationId,
                                            this.destinationType);
                                      });
                                    },
                                  ))
                            ]);
                      }
                      return Container();
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
                          ? TransitionToImage(
                              image: AdvancedNetworkImage(
                                this.image,
                                useDiskCache: true,
                                cacheRule:
                                    CacheRule(maxAge: const Duration(days: 7)),
                              ),
                              loadingWidgetBuilder: (BuildContext context,
                                      double progress, test) =>
                                  Center(
                                      child: RefreshProgressIndicator(
                                backgroundColor: Colors.white,
                              )),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              placeholder: const Icon(Icons.refresh),
                              enableRefresh: true,
                            )
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
                ]))),
      ),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              onPush: onPush,
              color: color,
              title: this.destinationName,
              back: true,
              id: this.destinationId,
              location: this.location)),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return _buildLoadingBody(ctxt);
    }
    var destination = snapshot.data.destination;
    var descriptionShort = snapshot.data.destination['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));
    // var discover = snapshot.data.discover;
    // var see = snapshot.data.see;
    // var eat = snapshot.data.eat;
    // var relax = snapshot.data.relax;
    // var play = snapshot.data.play;
    // var shop = snapshot.data.shop;
    // var nightlife = snapshot.data.nightlife;
    List<dynamic> allTab = [
      {'items': this.discover['places'], 'header': 'Discover'},
      {'items': this.see['places'], 'header': 'See'},
      {'items': this.eat['places'], 'header': 'Eat'},
      {'items': this.relax['places'], 'header': 'Relax'},
      {'items': this.play['places'], 'header': 'Play'},
      {'items': this.shop['places'], 'header': 'Shop'},
      {'items': this.nightlife['places'], 'header': 'Nightlife'},
    ];
    var tabContents = <Widget>[
      _buildTabContent(
          _buildAllTab(allTab, descriptionShort, color, destination), 'All'),
    ];
    for (var tab in allTab) {
      if (tab['items'].length > 0) {
        tabContents.add(
          _buildListView(tab['items'], tab['header'], color, destination),
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
    final store = Provider.of<TrotterStore>(context);
    var widgets = <Widget>[
      GestureDetector(
        onTap: () {
          onPush(
              {'id': destination['country_id'].toString(), 'level': 'country'});
        },
        child: Container(
            margin: EdgeInsets.only(top: 30),
            padding: EdgeInsets.only(right: 20, left: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AutoSizeText('Info on ${destination['country_name']}',
                    style: TextStyle(fontSize: 19, color: color)),
                Icon(
                  Icons.chevron_right,
                  size: 19,
                  color: color,
                )
              ],
            )),
      ),
      Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: AutoSizeText(
            description,
            style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w300),
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
              var currentUser = store.currentUser;
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
    final store = Provider.of<TrotterStore>(context);
    dynamic data;
    switch (key) {
      case 'Discover':
        data = this.discover;
        break;
      case 'See':
        data = this.see;
        break;
      case 'Relax':
        data = this.relax;
        break;
      case 'Shop':
        data = this.shop;
        break;
      case 'Eat':
        data = this.eat;
        break;
      case 'Nightlife':
        data = this.nightlife;
        break;
      case 'Play':
        data = this.play;
    }
    return Container(
        width: MediaQuery.of(context).size.width,
        child: LoadMore(
            delegate: TrotterLoadMoreDelegate(this.color),
            isFinish: data['more'] == false,
            onLoadMore: () async {
              if (data['more'] == true) {
                //print(data);
                var res = await fetchMorePlaces(this.destinationId,
                    key.toLowerCase(), data['places'].length);
                if (res.success == true) {
                  setState(() {
                    switch (key) {
                      case 'Discover':
                        this.discover['places'] = this.discover['places']
                          ..addAll(res.places);
                        this.discover['more'] = res.more;
                        break;
                      case 'See':
                        this.see['places'] = this.see['places']
                          ..addAll(res.places);
                        this.see['more'] = res.more;
                        break;
                      case 'Relax':
                        this.relax['places'] = this.relax['places']
                          ..addAll(res.places);
                        this.relax['more'] = res.more;
                        break;
                      case 'Shop':
                        this.shop['places'] = this.shop['places']
                          ..addAll(res.places);
                        this.shop['more'] = res.more;
                        break;
                      case 'Eat':
                        this.eat['places'] = this.eat['places']
                          ..addAll(res.places);
                        this.eat['more'] = res.more;
                        break;
                      case 'Nightlife':
                        this.nightlife['places'] = this.nightlife['places']
                          ..addAll(res.places);
                        this.nightlife['more'] = res.more;
                        break;
                      case 'Play':
                        this.play['places'] = this.play['places']
                          ..addAll(res.places);
                        this.play['more'] = res.more;
                        break;
                    }
                  });
                }
              }
              return true;
            },
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
                      var currentUser = store.currentUser;
                      if (currentUser == null) {
                        loginBottomSheet(context, data, color);
                      } else {
                        await addToItinerary(
                            context, items, index, color, destination);
                      }
                    },
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: 100,
                                height: 70,
                                margin: EdgeInsets.only(right: 20),
                                child: ClipPath(
                                    clipper: ShapeBorderClipper(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    child: items[index]['image'] != null
                                        ? TransitionToImage(
                                            image: AdvancedNetworkImage(
                                              items[index]['image'],
                                              useDiskCache: true,
                                              cacheRule: CacheRule(
                                                  maxAge:
                                                      const Duration(days: 7)),
                                            ),
                                            loadingWidgetBuilder: (BuildContext
                                                        context,
                                                    double progress,
                                                    test) =>
                                                Center(
                                                    child:
                                                        CircularProgressIndicator(
                                              backgroundColor: Colors.white,
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(this.color),
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
                                          )))),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                      width: MediaQuery.of(context).size.width -
                                          210,
                                      child: AutoSizeText(
                                        items[index]['name'],
                                        maxLines: 2,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500),
                                      )),
                                  Container(
                                      margin: EdgeInsets.only(top: 5),
                                      width: MediaQuery.of(context).size.width -
                                          210,
                                      child: AutoSizeText(
                                        items[index]['description_short'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w300),
                                      ))
                                ],
                              ),
                            )
                          ],
                        )));
              },
            )));
  }

  _renderTab(String label) {
    return AutoSizeText(label,
        style: TextStyle(
          fontSize: 15,
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
          height: 155.0,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 30.0),
          child: TopListLoading()),
      Container(
          height: 155.0,
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 30.0),
          child: TopListLoading()),
      Container(
          height: 155.0,
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
