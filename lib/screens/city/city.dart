import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';





Future<CityData> fetchCity(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('city_$id') ?? null;
  if(cacheData != null) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return CityData.fromJson(json.decode(cacheData));
  } else {
    print('no-cached');
    print(id);
    final response = await http.get('http://localhost:3002/api/explore/cities/$id/', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      await prefs.setString('city_$id', response.body);
      return CityData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      throw Exception('Response> $msg');
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
 

  CityData({
    this.color, 
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
  });

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
    );
  }
}

class City extends StatefulWidget {
  final String cityId;
  final ValueChanged<dynamic> onPush;
  City({Key key, @required this.cityId, this.onPush}) : super(key: key);
  @override
  CityState createState() => new CityState(cityId:this.cityId, onPush:this.onPush);
}

class CityState extends State<City> with SingleTickerProviderStateMixin{
  bool _showTitle = false;
  static String id;
  final String cityId;
  Future<CityData> data;
  TabController _tabController;
  final ValueChanged<dynamic> onPush;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 8);
    data = fetchCity(this.cityId);
    
  }

  CityState({
    this.cityId,
    this.onPush
  });

 @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          print(snapshot.hasData);
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
    var kExpandedHeight = 200;
    final ScrollController _scrollController = ScrollController();
    
    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    var name = snapshot.data.city['name'];
    var image = snapshot.data.city['image'];
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
            backgroundColor: _showTitle ? color : Colors.transparent,
            automaticallyImplyLeading: false,
            title: SearchBar(
              placeholder: 'Explore $name',
              leading: IconButton(
                padding: EdgeInsets.all(0),
                icon:  Icon(Icons.arrow_back),
                onPressed: () {  Navigator.pop(context);},
                iconSize: 30,
                color: Colors.black,
              )
                  
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
                      child: _renderTabBar(color, Colors.white)
                    )
                  ]        
                )
              )
            : PreferredSize(
              preferredSize: Size.fromHeight(70), 
              child: Container(color: Colors.transparent, child:_renderTabBar(Colors.white, color))
            ),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: ClipPath(
                        clipper: BottomWaveClipperTab(),
                        child: Image.network(
                        image,
                        fit: BoxFit.cover,
                      )
                    )
                  ),
                  Positioned.fill(
                      top: 0,
                      left: 0,
                      child: ClipPath(
                        clipper:BottomWaveClipperTab(),
                        child: Container(
                        color: color.withOpacity(0.5),
                      )
                    )
                  ),
                  Positioned(
                    left: 0,
                    top: 150,
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
                        Text(name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w300
                          )
                        )
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
            _buildAllTab(allTab, descriptionShort),
            'All'
          ),
          _buildListView(
            discover, 
            'Discover'
          ),
          _buildListView(
            see, 
            'See'
          ),
          _buildListView(
            eat, 
            'Eat'
          ),
          _buildListView(
            relax, 
            'Relax'
          ),
          _buildListView(
            play, 
            'Play'
          ),
          _buildListView(
            shop, 
            'Shop'
          ),
          _buildListView(
            nightlife, 
            'NightLife'
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

  _buildAllTab(List<dynamic> sections, String description) {
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
      widgets.add(
        TopList(
          items: section['items'],
          onPressed: (data){
            print("Clicked ${data['id']}");
            onPush({'id':data['id'], 'level':data['level']});
          },
          header: section['header']
        )
      );
    }
    return new List<Widget>.from(widgets)..addAll(
      <Widget>[
      ]
    );
  }

  _buildListView(List<dynamic> items, key) {
    return ListView.builder(
      key: new PageStorageKey(key),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            print(items[index]['level']);
            var id = items[index]['id'];
            var level  = items[index]['level'];
            onPush({'id':id.toString(), 'level':level.toString()});
          },
          child:Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width:150,
                  height: 90,
                  margin: EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    image: DecorationImage(
                      image: items[index]['image'] != null ? NetworkImage(items[index]['image']) : AssetImage('images/placeholder.jpg'),
                      fit: BoxFit.fill   
                    )
                  )
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        items[index]['name'],
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500
                        ),
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

  _renderTabBar(Color mainColor, Color fontColor){
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
      tabs: [
        Tab(
          child: _renderTab('All')
        ),
        Tab(
          child:  _renderTab('Discover')
        ),
        Tab(
          child:  _renderTab('See')
        ),
        Tab(
          child:  _renderTab('Eat')
        ),
        Tab(
          child:  _renderTab('Relax')
        ),
        Tab(
          child:  _renderTab('Play')
        ),
        Tab(
          child:  _renderTab('Shop')
        ),
        Tab(
          child:  _renderTab('Nightlife')
        ),
      ],
    );
  }

  
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    var kExpandedHeight = 300;
    final ScrollController _scrollController = ScrollController();
     _scrollController..addListener(() => setState(() {
       _showTitle =_scrollController.hasClients &&
        _scrollController.offset > kExpandedHeight - kToolbarHeight;
     }));

    return NestedScrollView(
      //controller: _scrollControllerCity,
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
                  clipper:BottomWaveClipperTab(),
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

  

