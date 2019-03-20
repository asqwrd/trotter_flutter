import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:trotter_flutter/widgets/itinerary-card/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/widgets/trips/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';

Future<HomeData> fetchHome() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('home') ?? null;
  if(cacheData != null) {
    final response =  await http.get('http://localhost:3002/api/itineraries/all/', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var homeData = json.decode(cacheData);
      homeData['itineraries'] = json.decode(response.body)['itineraries'];
      return HomeData.fromJson(homeData);
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      throw Exception('Response> $msg');
    }
  } else {
    final getData =  http.get('http://localhost:3002/api/explore/home/', headers:{'Authorization':'security'});
    final getData2 =  http.get('http://localhost:3002/api/itineraries/all?public=true', headers:{'Authorization':'security'});
    var responses = await Future.wait([getData, getData2]);
    var response = responses[0];
    var response2 = responses[1];
    if (response.statusCode == 200 && response2.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      await prefs.setString('home', response.body);
      var homeData = json.decode(response.body);
      homeData['itineraries'] = json.decode(response2.body)['itineraries'];
      return HomeData.fromJson(homeData);
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      throw Exception('Response> $msg');
    }
  }
}

class HomeData {
  //final List<dynamic> nationalParks;
  final List<dynamic> popularCities;
  //final List<dynamic> popularCountries;
  final List<dynamic> popularIslands;
  final List<dynamic> itineraries;
 

  HomeData({this.popularCities, this.popularIslands, this.itineraries});

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      //nationalParks: json['national_parks'],
      popularCities: json['popular_cities'],
      //popularCountries: json['popular_countries'],
      popularIslands: json['popular_islands'],
      itineraries: json['itineraries'],
    );
  }
}

class Home extends StatefulWidget {
  final String2VoidFunc onPush;
  Home({Key key, @required this.onPush}) : super(key: key);
  @override
  HomeState createState() => new HomeState(onPush:this.onPush);
}


class HomeState extends State<Home> {
  //final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  final String2VoidFunc onPush;

  final ScrollController _scrollController = ScrollController();
    var kExpandedHeight = 280;

    
  @override
  void initState() {
    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;
    }));
    super.initState();
    
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }

  Future<HomeData> data = fetchHome();
  HomeState({
    this.onPush,
  });

  Future<Null> _refreshData() async {
    await new Future.delayed(new Duration(seconds: 2));

    setState(() {
      data = fetchHome();
    });

    return null;
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

  bottomSheetModal(BuildContext context, dynamic data){
    return showModalBottomSheet(context: context,
      builder: (BuildContext context) {
        return new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new ListTile(
              leading: new Icon(Icons.trip_origin),
              title: new Text('Create Trip'),
              onTap: () {
                Navigator.pop(context);
                onPush({'level':'createtrip', 'param':data}); 
                
              }   
            ),
            new ListTile(
              leading: new Icon(Icons.add_circle),
              title: new Text('Add to Trip'),
              onTap: () { 
                Navigator.pop(context);
                showTripsBottomSheet(context, data); 
              }        
            ),
          ]
        );
      }
    );
  } 

  // function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    var color = Color.fromRGBO(106,154,168,1);
    List<Widget> widgets = [
      Padding(
        padding: EdgeInsets.only(bottom: 10, top: 50, left: 20, right: 20),
        child: Text(
        'Get inspired by itineraries!',
        style: TextStyle(
          fontSize: 25,
          color: color,
          fontWeight: FontWeight.w500
        ),
      )),
      Padding(
        padding: EdgeInsets.only(bottom: 10, top: 0, left: 20, right: 20),
        child: Text(
        'Trotter is for people who love to travel and those who need help planning. Itineraries are helpful in organizing your trips.',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w300
        ),
      ))
    ];
    for (var itinerary in snapshot.data.itineraries) {
      widgets.add(
        ItineraryCard(
          item: itinerary,
          color:color,
          onPressed: (data){
            onPush({'id':data['id'].toString(), 'level':data['level'].toString()});
          },
        )
      );
    }

    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            title: SearchBar(
              placeholder: 'Explore the world',
              onPressed: (){
                onPush({'query':'', 'level':'search'});
              },
                  
            ),
            centerTitle: true,
            backgroundColor: this._showTitle ? color : Colors.white,
            automaticallyImplyLeading: false,
            bottom: PreferredSize(preferredSize: Size.fromHeight(15), child: Container(),),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child:ClipPath(
                      child: Image.asset("images/home_bg.jpeg", fit:BoxFit.cover),
                      clipper: BottomWaveClipper(),
                    )),
                  Positioned.fill(
                    top: 0,
                    left: 0,
                    child: ClipPath(
                        child: Container(
                        color: color.withOpacity(0.5),
                      ),
                      clipper: BottomWaveClipper(),
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
                          child: Text("Trotter",
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
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: RefreshIndicator(
          onRefresh: () => _refreshData(),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              TopList(
                items: snapshot.data.popularCities,
                onPressed: (data){
                  onPush({'id':data['id'], 'level':data['level']});
                },
                onLongPressed: (data){
                  bottomSheetModal(context, data['item']);
                },
                header: "Trending cities"
              ),
              TopList(
                items: snapshot.data.popularIslands,
                onPressed: (data){
                  onPush({'id':data['id'], 'level':data['level']});
                },
                onLongPressed: (data){
                  bottomSheetModal(context, data['item']);
                },
                header: "Explore the island life"
              )
            ]..addAll(widgets),
          )
        )
      ),
    );
  }
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
     
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            backgroundColor: Color.fromRGBO(240, 240, 240, 1),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              background: ClipPath(
                clipper: BottomWaveClipper(),
                child:Container(
                  color: Color.fromRGBO(240, 240, 240, 1)
                )
              ),
            ),
          ),
        ];
      },
      body: RefreshIndicator(
        onRefresh: () => _refreshData(),
        child: Container( 
          padding: EdgeInsets.only(top: 40.0),
          decoration: BoxDecoration(color: Colors.white),
          child: ListView(
            children: <Widget>[
              Container(
                //height: 175.0,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 30.0),
                child: TopListLoading()
              ),
              Container(
                //height: 175.0,
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 30.0),
                child: TopListLoading()
              ),
            ]
          )
        ),
      )
    );
  }
}

  

