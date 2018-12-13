import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';




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
  final List<dynamic> nationalParks;
  final List<dynamic> popularCities;
  final List<dynamic> popularCountries;
  final List<dynamic> popularIslands;
 

  HomeData({this.nationalParks, this.popularCities, this.popularCountries, this.popularIslands});

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      nationalParks: json['national_parks'],
      popularCities: json['popular_cities'],
      popularCountries: json['popular_countries'],
      popularIslands: json['popular_islands'],
    );
  }
}
typedef String2VoidFunc = void Function(String, String);

class Home extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  Home({Key key, @required this.onPush}) : super(key: key);
  @override
  HomeState createState() => new HomeState(onPush:this.onPush);
}

const kExpandedHeight = 450.0;

class HomeState extends State<Home> {
  //final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  final ValueChanged<dynamic> onPush;

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

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    final ScrollController _scrollController = ScrollController();
     _scrollController.addListener(() => setState(() {
       _showTitle =_scrollController.hasClients &&
        _scrollController.offset > kExpandedHeight - kToolbarHeight;
     }));
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 600.0,
            floating: false,
            pinned: true,
            title: SearchBar(
              placeholder: 'Explore the world',
              leading: SvgPicture.asset("images/search-icon.svg",
                width: 55.0,
                height: 55.0,
                color: Colors.black,
                fit: BoxFit.contain
              )
                  
            ),
            centerTitle: true,
            backgroundColor: _showTitle ? Color.fromRGBO(194, 121, 73, 1) : Colors.white,
            automaticallyImplyLeading: false,
            /*leading: _showTitle ? Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0),
              child: Image.asset(
              "images/logo_nw.png", 
              width: 25.0,
              height: 25.0,
              fit: BoxFit.contain,
            )): null,*/
            bottom: !_showTitle
                ? PreferredSize(
                    preferredSize: Size.fromHeight(40),
                    child: Container(
                      width: double.infinity,
                      height: 100.0,
                      child:Image.asset("images/header.png", fit:BoxFit.fill)
                    )
                  )
                : PreferredSize(preferredSize: Size.fromHeight(15), child: Container(),),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                /*title: _showTitle
                    ? Text("Explore the world",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ))
                    : null,*/
                background: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: Image.asset(
                        "images/home_bg.jpeg",
                        fit: BoxFit.cover,
                      )),
                  Positioned.fill(
                    top: 0,
                    left: 0,
                    child: Container(
                      color: Color.fromRGBO(194, 121, 73, 0.4),
                    )
                  ),
                  /*Positioned(
                    left: 20,
                    top: 30,
                    child: Image.asset("images/logo_nw.png",
                        width: 55.0,
                        height: 55.0,
                        fit: BoxFit.contain),
                  ),*/
                  Positioned(
                    left: 20,
                    top: 180,
                    child: Text("Explore the world",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w300
                      )
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
          children: <Widget>[
            TopList(
              items: snapshot.data.popularCountries,
              onPressed: (data){
                print("Clicked ${data['id']}");
                onPush({'id':data['id'], 'level':data['level']});
              },
              header: "Trending countries"
            ),
            TopList(
              items: snapshot.data.popularCities,
              onPressed: (data){
                print("Clicked ${data['level']}");
              },
              header: "Trending cities"
            ),
            TopList(
              items: snapshot.data.nationalParks,
              onPressed: (data){
                print("Clicked ${data['id']}");
              },
              header: "Explore national parks"
            ),
            TopList(
              items: snapshot.data.popularIslands,
              onPressed: (data){
                print("Clicked ${data['id']}");
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
            backgroundColor: Color.fromRGBO(194, 121, 73, 1),
            automaticallyImplyLeading: false,
            bottom: !_showTitle
              ? PreferredSize(
                  preferredSize: Size.fromHeight(40),
                  child: Image.asset("images/header.png",
                      fit: BoxFit.fill,
                      height: 100.0,
                      width: double.infinity))
              : null,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              background: Container(
                color: Color.fromRGBO(240, 240, 240, 0.8)
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

  

