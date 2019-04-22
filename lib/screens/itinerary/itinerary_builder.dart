import 'dart:async';

import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/itinerary-list/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';



class ItineraryBuilder extends StatefulWidget {
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  ItineraryBuilder({Key key, @required this.itineraryId, this.onPush}) : super(key: key);
  @override
  ItineraryBuilderState createState() => new ItineraryBuilderState(itineraryId:this.itineraryId, onPush:this.onPush);
}

class ItineraryBuilderState extends State<ItineraryBuilder> {
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


  ItineraryBuilderState({
    this.itineraryId,
    this.onPush
  });

  


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: StoreConnector <AppState, Store<AppState>>(
        converter: (store) => store,
        onInit: (store) async {
          store.dispatch(new SetItineraryBuilderLoadingAction(true));
          await fetchItineraryBuilder(store,this.itineraryId,'itinerary_builder');
          store.dispatch(SetItineraryBuilderLoadingAction(false));
        },
        builder: (context, store){
            return _buildLoadedBody(context, store);
        }
      ) 
    );
  }
  

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, Store<AppState> store) {
    if(store.state.itineraryBuilder == null || store.state.itineraryBuilder.loading){
      return _buildLoadingBody(ctxt);
    }
    if(store.state.itineraryBuilder.error != null) {
      return ErrorContainer(
        onRetry: () async {
          store.dispatch(new SetItineraryBuilderLoadingAction(true));
          await fetchItineraryBuilder(store,this.itineraryId,'itinerary_builder');
          store.dispatch(new SetItineraryBuilderLoadingAction(false));
        },
      );
    }

    var itinerary = store.state.itineraryBuilder.itinerary;
    var name = itinerary['name'];
    var destinationName = itinerary['destination_name'];
    var destinationCountryName = itinerary['destination_country_name'];
    var days = itinerary['days'];
    var destination = store.state.itineraryBuilder.destination;
    var color = Color(hexStringToHexInt(store.state.itineraryBuilder.color));


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
                        child: CachedNetworkImage(
                        imageUrl: destination['image'],
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
        var dayId = days[dayIndex]['id'];
        
        return GestureDetector(
          onTap: () => onPush({'itineraryId':this.itineraryId, 'dayId':dayId, 'level':'itinerary/day/edit'}),
          child: Column(
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
                        '${itineraryItems.length == 1 ? "place":"places"} to see',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300
                        ),
                      )
                    )
                  )
                ]
              ), 
              itineraryItems.length > 0 ? Container(
                margin: EdgeInsets.only(top:0),
                child: ItineraryList(
                  items: itineraryItems,
                  color: color,
                  onPressed: (data){
                    onPush({'itineraryId':this.itineraryId, 'dayId':dayId, 'level':'itinerary/day/edit'});
                  },
                  onLongPressed: (data) {

                  },
                )
              ) : Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom:10),
                      child: SvgPicture.asset(
                        'images/itinerary-icon.svg',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    FlatButton(
                      onPressed: (){
                        onPush({'itineraryId':this.itineraryId, 'dayId':dayId, 'level':'itinerary/day/edit'});
                      },
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Text(
                        'Start planning',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w400,
                          fontSize: 20
                        )
                      ),
                    )
                  ],
                )
              )
            ]
          )
        );
      },
    );
}
  
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    return Column(
      //controller: _scrollControllerItinerary,
      children: <Widget>[
        Container(
          height: 350,
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                top: 0,
                left: 0,
                child: ClipPath(
                  clipper:BottomWaveClipperSlant(),
                  child: Container(
                    color: Color.fromRGBO(220, 220, 220, 0.8),
                  )
                )
              ),
            ]
          )
        ),
        Flexible( 
          child: Container(
            padding: EdgeInsets.only(top: 40.0, left:20, right:20),
            decoration: BoxDecoration(color: Colors.white),
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child:Container(
                    width: 200,
                    height: 20,
                    margin: EdgeInsets.only(bottom: 20),
                    color: Color.fromRGBO(220, 220, 220, 0.8),
                  )
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 30.0),
                  child: ItineraryListLoading()
                ),
              ],
            )
          )
        )
      ]
    );
  }
}