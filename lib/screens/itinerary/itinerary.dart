import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/itinerary-list/index.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html_unescape/html_unescape.dart';






Future<ItineraryData> fetchItinerary(String id) async {
  final response = await http.get('http://localhost:3002/api/itineraries/get/$id', headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return ItineraryData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

class ItineraryData {
  final String color;
  final Map<String, dynamic> itinerary; 

  ItineraryData({this.color, this.itinerary});

  factory ItineraryData.fromJson(Map<String, dynamic> json) {
    return ItineraryData(
     // color: json['color'],
      itinerary: json['itinerary'],
    );
  }
}


class Itinerary extends StatefulWidget {
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  Itinerary({Key key, @required this.itineraryId, this.onPush}) : super(key: key);
  @override
  ItineraryState createState() => new ItineraryState(itineraryId:this.itineraryId, onPush:this.onPush);
}

class ItineraryState extends State<Itinerary> {
  bool _showTitle = false;
  static String id;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
   GoogleMapController mapController;
  
  Future<ItineraryData> data;
  final ScrollController _scrollController = ScrollController();
    var kExpandedHeight = 300;


  @override
  void initState() {
    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    super.initState();
    data = fetchItinerary(this.itineraryId);
    
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }


  ItineraryState({
    this.itineraryId,
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
    
    var itinerary = snapshot.data.itinerary;
    var name = itinerary['name'];
    var destinationName = itinerary['destination_name'];
    var destinationCountryName = itinerary['destination_country_name'];
    var location = itinerary['location'];
    var days = itinerary['days'];
    //var color = Color(hexStringToHexInt(snapshot.data.color));
    var color = Colors.blueGrey;

    void _onMapCreated(GoogleMapController controller) {
      setState(() { 
        mapController = controller; 
        mapController.addMarker(
          MarkerOptions(
            position: LatLng(itinerary['location']['lat'], itinerary['location']['lng']),
          )
        );
        /*mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0.0,
            target: LatLng(itinerary['location']['lat'], itinerary['location']['lng']),
            tilt: 0.0,
            zoom: 10.0,
          ),
        ));*/
      });
    }



    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        backgroundColor: Colors.blueGrey,
        brightness: Brightness.dark,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(15), 
          child: Container()
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (BuildContext serperatorContext, int index) => new Container(margin:EdgeInsets.only(bottom: 40, top: 40), child:Divider(color: Color.fromRGBO(0, 0, 0, 0.3))),
        padding: EdgeInsets.all(20.0),
        itemCount: days.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (BuildContext listContext, int dayIndex){
          var itineraryItems = days[dayIndex]['itinerary_items'];
          
          var pois = [];
          for(var item in itineraryItems){
            pois.add(item['poi']);
          }
          var itineraryItem = itineraryItems[0];
          var time = itineraryItems[0]['time'];
          var image = itineraryItem['image'];
          return  Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child:Container(
                      child: Text(
                        'Your ${ordinalNumber(dayIndex + 1)} day in $destinationName',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w300
                        ),
                      )
                    )
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child:Container(
                      margin: EdgeInsets.only(bottom:20),
                      child: Text(
                        '${itineraryItems.length} items(s)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300
                        ),
                      )
                    )
                  ),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover
                      )
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft, 
                          child:Text(
                            itineraryItem['title'],
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w400
                            )
                          )
                        ),
                        Align(
                          alignment: Alignment.topLeft, 
                          child:Text(
                            time['unit'].toString().isEmpty == false ? 'Estimated time ${new HtmlUnescape().convert('&bull;')} ${time['value']} ${time['unit']}' : 'Estimated time ${new HtmlUnescape().convert('&bull;')} 1 hour',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300
                            )
                          )
                        ),
                      ],
                    )
                  )
                ]
              ), 
              itineraryItems.length > 1 ? 
              Container(
                margin: EdgeInsets.only(top:20),
                child: ItineraryList(
                  items: itineraryItems.sublist(1,itineraryItems.length),
                  onPressed: (data){
                    print("Clicked ${data['id']}");
                    onPush({'id':data['id'], 'level':data['level']});
                  },
                )
              ) : Container()
            ]
          );
        },
      )
    );
  }

  
_buildDay(List<dynamic> days, int index){
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
            '${days[index]['day']}:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500
            ),
          )
        ),
        Flexible(
          child:Text(
            days[index]['date'].toString(),
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
      //controller: _scrollControllerItinerary,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 300,
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