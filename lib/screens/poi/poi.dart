import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';






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
   GoogleMapController mapController;
  
  Future<PoiData> data;
  final ScrollController _scrollController = ScrollController();
    var kExpandedHeight = 300;


  @override
  void initState() {
    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    super.initState();
    data = fetchPoi(this.poiId);
    
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
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
    
    var name = snapshot.data.poi['name'];
    var poi = snapshot.data.poi;
    var properties = poi['properties'];
    var images = snapshot.data.poi['images'];
    var descriptionShort = snapshot.data.poi['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));

    void _onMapCreated(GoogleMapController controller) {
      setState(() { 
        mapController = controller; 
        mapController.addMarker(
          MarkerOptions(
            position: LatLng(poi['location']['lat'], poi['location']['lng']),
          )
        );
        mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 270.0,
            target: LatLng(poi['location']['lat'], poi['location']['lng']),
            tilt: 30.0,
            zoom: 17.0,
          ),
        ));
      });
    }

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
              placeholder: 'Search',
              fillColor: !_showTitle ? color : Colors.white,
              leading: IconButton(
                padding: EdgeInsets.all(0),
                icon:  Icon(Icons.arrow_back),
                onPressed: () {  Navigator.pop(context);},
                iconSize: 30,
                color: !_showTitle ? fontContrast(color) : Colors.black,
              ),
              onPressed: (){
                onPush({'query':'', 'level':'search', 'id':poi['location_id'].toString()});
              },
                  
            ),
            bottom: PreferredSize(preferredSize: Size.fromHeight(15), child: Container(),),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
                  Positioned.fill(
                    top: 0,
                    child: new Swiper(
                      itemBuilder: (BuildContext context,int index){
                        return new Image.network(images[index]['sizes']['medium']['url'],fit: BoxFit.cover,);
                      },
                      itemCount: images.length,
                      pagination: new SwiperPagination(),
                    ),
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
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                height: 250.0,
                width: double.infinity, 
                child: ClipPath(
                  clipper: CornerRadiusClipper(10.0), 
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                  )
                ),
              )
            ),
            ListView.separated(
              separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
              padding: EdgeInsets.all(20.0),
              itemCount: properties.length,
              shrinkWrap: true,
              primary: false,
              itemBuilder: (BuildContext context, int index) => _buildProperties(properties, index),
            )
            
          ],
        )
      ),
    );
  }

  
_buildProperties(List<dynamic> properties, int index){
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 10.0),
          child:Text(
            '${properties[index]['name']}:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500
            ),
          )
        ),
        Flexible(
          child:Text(
            properties[index]['value'],
            //maxLines: 2,
            //overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w300
            ),
          )
        ),
      ],
    )
  );
}
  
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    return NestedScrollView(
      //controller: _scrollControllerPoi,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350,
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