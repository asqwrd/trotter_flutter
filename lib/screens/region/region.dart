import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/itineraries/index.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';




Future<RegionData> fetchRegion(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('city_$id') ?? null;
  if(cacheData != null) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return RegionData.fromJson(json.decode(cacheData));
  } else {
    print('no-cached');
    print(id);
    final response = await http.get('http://localhost:3002/api/explore/cities/$id/', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      await prefs.setString('city_$id', response.body);
      return RegionData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      throw Exception('Response> $msg');
    }
  }
}

class RegionData {
  final String color;
  final Map<String, dynamic> region;
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
 

  RegionData({
    this.color, 
    this.region, 
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
  });

  factory RegionData.fromJson(Map<String, dynamic> json) {
    return RegionData(
      color: json['color'],
      region: json['city'],
      discover: json['discover'],
      eat: json['eat'],
      nightlife: json['nightlife'],
      play: json['play'],
      relax: json['relax'],
      see: json['see'],
      shop: json['shop'],
    );
  }
}

class Region extends StatefulWidget {
  final String regionId;
  final ValueChanged<dynamic> onPush;
  Region({Key key, @required this.regionId, this.onPush}) : super(key: key);
  @override
  RegionsState createState() => new RegionsState(regionId:this.regionId, onPush:this.onPush);
}

class RegionsState extends State<Region> with SingleTickerProviderStateMixin{
  bool _showTitle = false;
  static String id;
  final String regionId;
  Future<RegionData> data;
  TabController _tabController;
  final ValueChanged<dynamic> onPush;
  var kExpandedHeight = 200;
    final ScrollController _scrollController = ScrollController();
    
   


  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 8);
     _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    data = fetchRegion(this.regionId);

    
  }

  RegionsState({
    this.regionId,
    this.onPush
  });
  

 @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildLoadedBody(context,snapshot);
          }
          return _buildLoadingBody(context);
        }
      )
    );
  }
// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    
    var name = snapshot.data.region['name'];
    var destination = snapshot.data.region;
    var image = snapshot.data.region['image'];
    var descriptionShort = snapshot.data.region['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));
    var discover = snapshot.data.discover;
    var see = snapshot.data.see;
    var eat = snapshot.data.eat;
    var relax = snapshot.data.relax;
    var play = snapshot.data.play;
    var shop = snapshot.data.shop;
    var nightlife = snapshot.data.nightlife;
    var allTab = [
      {'items': discover, 'header':'Discover' },
      {'items': see, 'header':'See' },
      {'items': eat, 'header':'Eat' },
      {'items': relax, 'header':'Relax' },
      {'items': play, 'header':'Play' },
      {'items': shop, 'header':'Shop' },
      {'items': nightlife, 'header':'Nightlife' },
    ];
   
   
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: _showTitle ? color : Colors.white,
            automaticallyImplyLeading: false,
            title: SearchBar(
              placeholder: 'Explore $name',
              leading: IconButton(
                padding: EdgeInsets.all(0),
                icon:  Icon(Icons.arrow_back),
                onPressed: () {  Navigator.pop(context);},
                iconSize: 30,
                color: Colors.white,
              ),
              onPressed: (){
                onPush({'query':'', 'level':'search', 'id':this.regionId, 'location':name.toString()});
              },
                  
            ),
            bottom: !_showTitle
            ? PreferredSize(
                preferredSize: Size.fromHeight(100),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 40.0,
                    ),
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: _renderTabBar(color, Colors.white,allTab)
                    )
                  ]        
                )
              )
            : PreferredSize(
              preferredSize: Size.fromHeight(70), 
              child: Container(color: Colors.transparent, child:_renderTabBar(Colors.white, color, allTab))
            ),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: ClipPath(
                        clipper: CurveClipper(),
                        child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                      )
                    )
                  ),
                  Positioned.fill(
                      top: 0,
                      left: 0,
                      child: ClipPath(
                        clipper:CurveClipper(),
                        child: Container(
                        color: color.withOpacity(0.5),
                      )
                    )
                  ),
                  Positioned(
                    left: 0,
                    top: 180,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        Container(
                          margin: EdgeInsets.only(right:10.0),
                          child: SvgPicture.asset("images/trotter-logo.svg",
                            width: 50.0,
                            height: 50.0,
                            fit: BoxFit.contain
                          )
                        ),
                        Container(
                          //width: MediaQuery.of(context).size.width - 100,
                          child: Text(name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w300
                          )
                        ))
                      ]
                    )
                  ),
                ]
              )
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(
            _buildAllTab(allTab, descriptionShort,color,destination),
            'All',
          ),
          _buildListView(
            discover, 
            'Discover',
            color,
            destination
          ),
          _buildListView(
            see, 
            'See',
            color,
            destination
          ),
          _buildListView(
            eat, 
            'Eat',
            color,
            destination
          ),
          _buildListView(
            relax, 
            'Relax',
            color,
            destination
          ),
          _buildListView(
            play, 
            'Play',
            color,
            destination
          ),
          _buildListView(
            shop, 
            'Shop',
            color,
            destination
          ),
          _buildListView(
            nightlife, 
            'NightLife',
            color,
            destination
          ),
        ],
      ),
    );
  }



  _buildTabContent(List<Widget> widgets, String key){
    return Container(
      margin: EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
      decoration: BoxDecoration(color: Colors.white),
      key: new PageStorageKey(key),
      child: ListView(
        children: widgets
      )
    );
  }

  _buildAllTab(List<dynamic> sections, String description, Color color, dynamic destination) {
    var widgets = <Widget>[
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Text(
          description,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300
          ),
        )
      )
    ];
    for (var section in sections) {
      if(section['items'].length > 0){
        var items = section['items'];
        widgets.add(
          TopList(
            items: section['items'],
            onPressed: (data){
              onPush({'id':data['id'], 'level':data['level']});
            },
            onLongPressed: (data) async {
              var currentUser = StoreProvider.of<AppState>(context).state.currentUser;
              if(currentUser == null){
                loginBottomSheet(context, data, color);
              } else {
                var index = data['index'];
                await addToItinerary(context, items, index, color, destination);
              }
            },
            header: section['header']
          )
        );
      }
    }
    return new List<Widget>.from(widgets)..addAll(
      <Widget>[
      ]
    );
  }

  _buildListView(List<dynamic> items, String key, Color color, dynamic destination) {
    return ListView.builder(
      key: new PageStorageKey(key),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            var id = items[index]['id'];
            var level  = items[index]['level'];
            onPush({'id':id.toString(), 'level':level.toString()});
          },
          onLongPress: () async {
            var currentUser = StoreProvider.of<AppState>(context).state.currentUser;
              if(currentUser == null){
                loginBottomSheet(context, data, color);
              } else {
                await addToItinerary(context, items, index, color, destination);
              }
          },
          child:Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 150,
                  height: 90,
                  margin:EdgeInsets.only(right:20),
                  child: ClipPath(
                    clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                        )
                      ), 
                      child: items[index]['image'] != null ? CachedNetworkImage(
                        placeholder: (context, url) => SizedBox(
                          width: 50, 
                          height:50, 
                          child: Align( alignment: Alignment.center, child:CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          )
                        )),
                      fit: BoxFit.cover, 
                      imageUrl: items[index]['image'],
                      errorWidget: (context,url, error) =>  Container( 
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:AssetImage('images/placeholder.jpg'),
                            fit: BoxFit.cover
                          ),
                          
                        )
                      )
                    ) : Container( 
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:AssetImage('images/placeholder.jpg'),
                            fit: BoxFit.cover
                          ),
                          
                        )
                      )
                  )
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 210,
                        child: Text(
                          items[index]['name'],
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500
                          ),
                        )
                      ),
                      Container(
                        margin: EdgeInsets.only(top:5),
                        width: MediaQuery.of(context).size.width - 210,
                        child: Text(
                          items[index]['description_short'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w300
                          ),
                        )
                      )
                      
                    ],
                  ),
                )
              ],
            )
          )
        );
      },
    );
  }

  _renderTab(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w300,
      )
    );
  }

  _renderTabBar(Color mainColor, Color fontColor, List<dynamic> sections){
    var tabs = [
      Tab(
        child: _renderTab('All')
      ),
    ];

    for (var section in sections) {
      if(section['items'].length > 0){
        tabs.add(
          Tab(
            child:  _renderTab(section['header'])
          ),
        );
      }
    }

    return TabBar(
      controller: _tabController,
      labelColor: mainColor,
      isScrollable: true,
      unselectedLabelColor: fontContrast(fontColor).withOpacity(0.6),
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: mainColor,
            width: 2.0
          )
        )
      ),
      tabs: tabs,
    );
  }

  
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {

    return NestedScrollView(
      //controller: _scrollControllerRegion,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              background: ClipPath(
                  clipper:CurveClipper(),
                  child: Container(
                  color: Color.fromRGBO(240, 240, 240, 1),
                )
              ),
            ),
          ),
        ];
      },
      body: Container(
        padding: EdgeInsets.only(top: 0.0),
        decoration: BoxDecoration(color: Colors.white),
        child: ListView(
          children: <Widget>[
            Container(
              height: 175.0,
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 30.0),
              child: TopListLoading()
            ),
            Container(
              height: 175.0,
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 30.0),
              child: TopListLoading()
            ),
          ],
        )
      ),
    );
  }
}

  

