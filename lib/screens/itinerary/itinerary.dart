import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/itinerary-list/index.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trotter_flutter/redux/index.dart';


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
    var kExpandedHeight = 280;


  @override
  void initState() {
    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    super.initState();
    //data = fetchItinerary(this.itineraryId);
    
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
    var days = itinerary['days'];
    var destination = snapshot.data.destination;
    var color = Color(hexStringToHexInt(snapshot.data.color));


    return  NestedScrollView(
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
              placeholder: 'Explore the world',
              leading: IconButton(
                padding: EdgeInsets.all(0),
                icon:  Icon(Icons.arrow_back),
                onPressed: () {  Navigator.pop(context);},
                iconSize: 30,
                color: Colors.white,
              ),
              onPressed: (){
                onPush({'query':'', 'level':'search'});
              },
                  
            ),
            bottom: PreferredSize(preferredSize: Size.fromHeight(15), child: Container(),),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: ClipPath(
                        clipper: BottomWaveClipperSlant(),
                        child: Image.network(
                        destination['image'],
                        fit: BoxFit.cover,
                      )
                    )
                  ),
                  Positioned.fill(
                      top: 0,
                      left: 0,
                      child: ClipPath(
                        clipper:BottomWaveClipperSlant(),
                        child: Container(
                        color: color.withOpacity(0.5),
                      )
                    )
                  ),
                  Positioned(
                    left: 0,
                    top: 150,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children:<Widget>[
                            Container(
                              margin: EdgeInsets.only(right:10.0),
                              child: SvgPicture.asset("images/trotter-logo.svg",
                                width: 50.0,
                                height: 50.0,
                                fit: BoxFit.contain
                              )
                            ),
                            Text('$name',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w300
                              )
                            )
                          ]
                        ),
                        Container(
                          child:Text(
                            '$destinationName, $destinationCountryName',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w300
                            )
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
      body:  _buildDay(days, destinationName, itinerary['destination'], color)
    );
  }

  
_buildDay(List<dynamic> days, String destinationName, String locationId, Color color){
  return ListView.separated(
        separatorBuilder: (BuildContext serperatorContext, int index) => new Container(margin:EdgeInsets.only(bottom: 40, top: 40), child:Divider(color: Color.fromRGBO(0, 0, 0, 0.3))),
        padding: EdgeInsets.all(20.0),
        itemCount: days.length,
        shrinkWrap: true,
        primary: true,
        itemBuilder: (BuildContext listContext, int dayIndex){
          var itineraryItems = days[dayIndex]['itinerary_items'];
          
          var pois = [];
          if(itineraryItems != null){
            for(var item in itineraryItems){
              pois.add(item['poi']);
            }
          }
          
          return  Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child:Container(
                      child: Text(
                        'Your ${ordinalNumber(days[dayIndex]['day'] + 1)} day in $destinationName',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400
                        ),
                      )
                    )
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child:Container(
                      margin: EdgeInsets.only(bottom:20),
                      child: Text(
                        itineraryItems != null ? '${itineraryItems.length} items(s)' : '0 item(s)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300
                        ),
                      )
                    )
                  )
                ]
              ), 
              itineraryItems != null ? Container(
                margin: EdgeInsets.only(top:0),
                child: ItineraryList(
                  items: itineraryItems,
                  color: color,
                  onPressed: (data){
                    onPush({'id':data['id'], 'level':data['level'], 'google_place':data['google_place'], 'location_id':locationId});
                  },
                )
              ) : Container()
            ]
          );
        },
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