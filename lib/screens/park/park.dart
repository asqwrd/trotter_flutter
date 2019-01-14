import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';





Future<ParkData> fetchPark(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('park_$id') ?? null;
  if(cacheData != null) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return ParkData.fromJson(json.decode(cacheData));
  } else {
    print('no-cached');
    print(id);
    final response = await http.get('http://localhost:3002/api/explore/national_parks/$id/', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      await prefs.setString('park_$id', response.body);
      return ParkData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      throw Exception('Response> $msg');
    }
  }
}

class ParkData {
  final String color;
  final Map<String, dynamic> park;
  final List<dynamic> pois; 

  ParkData({
    this.color, 
    this.park, 
    this.pois, 
  });

  factory ParkData.fromJson(Map<String, dynamic> json) {
    return ParkData(
      color: json['color'],
      park: json['park'],
      pois: json['pois'],
    );
  }
}

class Park extends StatefulWidget {
  final String parkId;
  final ValueChanged<dynamic> onPush;
  Park({Key key, @required this.parkId, this.onPush}) : super(key: key);
  @override
  ParkState createState() => new ParkState(parkId:this.parkId, onPush:this.onPush);
}

class ParkState extends State<Park> with SingleTickerProviderStateMixin{
  bool _showTitle = false;
  static String id;
  final String parkId;
  Future<ParkData> data;
  TabController _tabController;
  final ValueChanged<dynamic> onPush;
  var kExpandedHeight = 200;
    final ScrollController _scrollController = ScrollController();
    
    

  @override
  void initState() {
    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    super.initState();
    _tabController = TabController(vsync: this, length: 8);
    data = fetchPark(this.parkId);
    
  }

  ParkState({
    this.parkId,
    this.onPush
  });

 @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
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
    
    var name = snapshot.data.park['name'];
    var image = snapshot.data.park['image'];
    var descriptionShort = snapshot.data.park['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));
    var pois = snapshot.data.pois;

     
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
              placeholder: 'Search',
              leading: IconButton(
                padding: EdgeInsets.all(0),
                icon:  Icon(Icons.arrow_back),
                onPressed: () {  Navigator.pop(context);},
                iconSize: 30,
                color: Colors.black,
              ),
              onPressed: (){
                onPush({'query':'', 'level':'search'});
              },
                  
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(15), 
              child: Container()
            ),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: ClipPath(
                        clipper: BottomWaveClipper(),
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
                        clipper:BottomWaveClipper(),
                        child: Container(
                        color: color.withOpacity(0.5),
                      )
                    )
                  ),
                  Positioned(
                    left: 0,
                    top: 180,
                    width: MediaQuery.of(context).size.width,
                    child: Padding( 
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
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
                          width: MediaQuery.of(context).size.width - 100,
                          child:Text(name,
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w300
                          )
                        ))
                      ]
                    ))
                  ),
                ]
              )
            ),
          ),
        ];
      },
      body: Column(
        //shrinkWrap: true,
        //primary: false,
        children:<Widget>[
          Container(
            padding: EdgeInsets.only(top: 40, left: 20, right:20),
            child: Text(
              descriptionShort,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w300
              ),
            )
          ),
          Flexible(  
            child:_buildListView(
              pois, 
              'Poi'
            )
          )
        ]
      )
    );
  }

  _buildListView(List<dynamic> items, key) {
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
  
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {

    return NestedScrollView(
      //controller: _scrollControllerPark,
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

  

