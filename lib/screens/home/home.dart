import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';





Future<HomeData> fetchHome() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('home') ?? null;
  if(cacheData != null) {
    await Future.delayed(const Duration(seconds: 1));
    return HomeData.fromJson(json.decode(cacheData));
  } else {
    final response = await http.get('http://localhost:3002/api/explore/home/', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      await prefs.setString('home', response.body);
      return HomeData.fromJson(json.decode(response.body));
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
 

  HomeData({this.popularCities, this.popularIslands});

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      //nationalParks: json['national_parks'],
      popularCities: json['popular_cities'],
      //popularCountries: json['popular_countries'],
      popularIslands: json['popular_islands'],
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

  @override
  void initState() {
    super.initState();
    
    //_scrollController.addListener(() => setState(() {}));
  }

  final Future<HomeData> data = fetchHome();
  HomeState({
    this.onPush,
  });

  


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
            title: new Text('Add to trip'),
            onTap: () => print('')          
          ),
        ]
      );
  });
}

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    final ScrollController _scrollController = ScrollController();
    var kExpandedHeight = 300;

     _scrollController.addListener(() => setState(() {
       _showTitle =_scrollController.hasClients &&
        _scrollController.offset > kExpandedHeight - kToolbarHeight;
     }));
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
              leading: SvgPicture.asset("images/search-icon.svg",
                width: 55.0,
                height: 55.0,
                color: Colors.black,
                fit: BoxFit.contain
              ),
              onPressed: (){
                onPush({'query':'', 'level':'search'});
              },
                  
            ),
            centerTitle: true,
            backgroundColor: _showTitle ? Color.fromRGBO(194, 121, 73, 1) : Colors.white,
            automaticallyImplyLeading: false,
            bottom: PreferredSize(preferredSize: Size.fromHeight(15), child: Container(),),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
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
                        color: Color.fromRGBO(194, 121, 73, 0.5),
                      ),
                      clipper: BottomWaveClipper(),
                    )
                  ),
                  Positioned(
                    left: 0,
                    top: 200,
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
                        Text("Trotter",
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
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            /*TopList(
              items: snapshot.data.popularCountries,
              onPressed: (data){
                print("Clicked ${data['id']}");
                onPush({'id':data['id'], 'level':data['level']});
              },
              header: "Trending countries"
            ),*/
            TopList(
              items: snapshot.data.popularCities,
              onPressed: (data){
                print("Clicked ${data['level']}");
                onPush({'id':data['id'], 'level':data['level']});
              },
              onLongPressed: (data){
                bottomSheetModal(context, data['item']);
              },
              header: "Trending cities"
            ),
            /*TopList(
              items: snapshot.data.nationalParks,
              onPressed: (data){
                print("Clicked ${data['id']}");
                onPush({'id':data['id'], 'level':data['level']});
              },
              header: "Explore national parks"
            ),*/
            TopList(
              items: snapshot.data.popularIslands,
              onPressed: (data){
                print("Clicked ${data['id']}");
                onPush({'id':data['id'], 'level':data['level']});
              },
              onLongPressed: (data){
                bottomSheetModal(context, data['item']);
              },
              header: "Explore the island life"
            )
          ],
        )
      ),
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
      body: Container(
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
          ],
        )
      ),
    );
  }
}

  

