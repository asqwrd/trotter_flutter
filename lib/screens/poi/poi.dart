import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';




Future<PoiData> fetchPoi(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('poi_$id') ?? null;
  if(cacheData != null) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return PoiData.fromJson(json.decode(cacheData));
  } else {
    print('no-cached');
    final response = await http.get('http://localhost:3002/api/explore/poi/$id', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      await prefs.setString('poi_$id', response.body);
      return PoiData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      throw Exception('Response> $msg');
    }
  }
}

class PoiData {
  final String color;
  final Map<String, dynamic> poi; 

  PoiData({this.color, this.poi});

  factory PoiData.fromJson(Map<String, dynamic> json) {
    return PoiData(
      color: json['color'],
      poi: json['poi'],
    );
  }
}


class Poi extends StatefulWidget {
  final String poiId;
  final ValueChanged<dynamic> onPush;
  Poi({Key key, @required this.poiId, this.onPush}) : super(key: key);
  @override
  PoiState createState() => new PoiState(poiId:this.poiId, onPush:this.onPush);
}

class PoiState extends State<Poi> {
  bool _showTitle = false;
  static String id;
  final String poiId;
  final ValueChanged<dynamic> onPush;
  
  Future<PoiData> data;

  @override
  void initState() {
    super.initState();
    data = fetchPoi(this.poiId);
    
  }

  PoiState({
    this.poiId,
    this.onPush
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
    var kExpandedHeight = 300;


    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    var name = snapshot.data.poi['name'];
    var images = snapshot.data.poi['images'];
    var descriptionShort = snapshot.data.poi['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));

    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 450,
            floating: false,
            pinned: true,
            backgroundColor: _showTitle ? color : Colors.transparent,
            automaticallyImplyLeading: false,
            title: SearchBar(
              placeholder: 'Search',
              leading: IconButton(
                padding: EdgeInsets.all(0),
                icon:  Icon(Icons.arrow_back),
                onPressed: () {  Navigator.pop(context);},
                iconSize: 30,
                color: Colors.black,
              )
                  
            ),
            bottom: PreferredSize(preferredSize: Size.fromHeight(15), child: Container(),),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
                  /*Positioned.fill(
                      top: 0,
                      child: ClipPath(
                        clipper: BottomWaveClipper(),
                        child: Image.network(
                        image,
                        fit: BoxFit.cover,
                      )
                    )
                  ),*/
                  Positioned.fill(
                    top: 0,
                    left: 0,
                    child: Container(
                        color: color.withOpacity(0.5),
                    )
                  ),
                  Positioned(
                    left: 0,
                    top: 280,
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
                        Text("Learn about $name",
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
        margin: EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
        decoration: BoxDecoration(color: Colors.white),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 40.0, left:20.0, right: 20.0),
              child: Text(
                descriptionShort, 
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300
                )
              )
            ),
          ],
        )
      ),
    );
  }

  
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    var kExpandedHeight = (MediaQuery.of(context).size.height * 0.80) - 150;
    final ScrollController _scrollController = ScrollController();
     _scrollController..addListener(() => setState(() {
       _showTitle =_scrollController.hasClients &&
        _scrollController.offset > kExpandedHeight - kToolbarHeight;
     }));

    return NestedScrollView(
      //controller: _scrollControllerPoi,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 450,
            floating: false,
            pinned: true,
            backgroundColor: Color.fromRGBO(194, 121, 73, 1),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              background: Container(
                color: Color.fromRGBO(240, 240, 240, 1)
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