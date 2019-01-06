import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:trotter_flutter/tab_navigator.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';



class Trips extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  Trips({Key key, this.onPush}) : super(key: key);
  @override
  TripsState createState() => new TripsState(onPush:this.onPush);
}

class TripsState extends State<Trips> {
  bool _showTitle = false;
  final ValueChanged<dynamic> onPush;
   GoogleMapController mapController;
  
  Future<TripsData> data;

  @override
  void initState() {
    super.initState();
    
  }

  TripsState({
    this.onPush
  });

  Future<TripsData> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 3));
    return null;
  }

  


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () { 
          onPush({"level": "createtrip"});
        },
        tooltip: 'Create trip',
        child: Icon(Icons.add),
        elevation: 5.0,
      ),
      body: StoreConnector <AppState, ViewModel>(
        converter: (store) => ViewModel.create(store),
        onInit: (store) async {
          store.dispatch(new SetTripsLoadingAction(true));
          await fetchTrips(store);
          store.dispatch(SetTripsLoadingAction(false));
        },
        builder: (context, viewModel)=> _buildLoadedBody(context, viewModel)
      )
    );
  }
  

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, ViewModel viewModel) {
    final ScrollController _scrollController = ScrollController();
    var kExpandedHeight = 300;

    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    var trips = StoreProvider.of<AppState>(context).state.trips;
    var loading = StoreProvider.of<AppState>(context).state.tripLoading;

    var color = Colors.blueGrey;

    if(loading == true)
      return _buildLoadingBody(context);


    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: _showTitle ? Colors.blueGrey : Colors.transparent,
            automaticallyImplyLeading: false,
            title: SearchBar(
              placeholder: 'Search',
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
            bottom: PreferredSize(preferredSize: Size.fromHeight(15), child: Container(),),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: ClipPath(
                        clipper: BottomWaveClipperSlant(),
                        child: Image.asset(
                        'images/search2.jpg',
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
                        Text('Trips',
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
        child: RefreshIndicator(
          onRefresh: () => viewModel.onGetTrips(),
          child:ListView.builder(
          shrinkWrap: true,
          itemCount: trips.length,
          //itemExtent: 300,
          itemBuilder: (BuildContext context, int index) {
            var color = Color(hexStringToHexInt(trips[index]['color']));
            //print(trips[index]['start_date']);
            
            return InkWell(
              onTap: () async {
               // var refresh =  await TabNavigator().push(context,{'id':trips[index]['id'].toString(), 'level':'trip'});
                //print(refresh);
                /*setState((){
                  data = fetchTrips();
                });*/
                onPush({'id':trips[index]['id'].toString(), 'level':'trip'});
                
              },
              child:Card(
                semanticContainer: true,
                color: Colors.white,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Column(
                  children: <Widget>[  
                    Container(
                      height: 450.0,
                      width: double.infinity,
                      color: Colors.white,
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            top:0,
                            left:0,
                            
                            child: ClipPath( 
                              clipper: BottomWaveClipper(),
                              child: Image.network(
                                trips[index]['image'],
                                fit: BoxFit.cover
                              ),
                            )
                          ),
                          Positioned.fill(
                            top:0,
                            left: 0,
                            child: ClipPath( 
                              clipper: BottomWaveClipper(),
                              child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.transparent,Colors.black.withOpacity(0.8)], // whitish to gray
                                  tileMode: TileMode.repeated, // repeats the gradient over the canvas
                                ),
                              ) 
                            ))
                          )
                        ],
                      )                        
                    ),
                    ListView(
                      shrinkWrap: true,
                      primary: false,
                      children:<Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10),
                          child: Text(
                            trips[index]['name'].toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: color,
                              fontSize: 25.0,
                              fontWeight: FontWeight.w500
                              
                            ),
                          )
                        ),
                        _buildDestinationInfo(trips[index]['destinations'])
                      ] 
                    ),
                    SizedBox(height: 20)
                  ]
                ),
                
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation:1,
                margin: EdgeInsets.only(top:20, left:20, right:20, bottom:20),
              )
            );
          },
        ))
      ),
    );
  }

  _buildDestinationInfo(List<dynamic> destinations){
    var widgets = <Widget>[];
    for (var destination in destinations){
      var startDate = new DateFormat.yMMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destination['start_date']*1000));
      var endDate = new DateFormat.yMMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destination['end_date']*1000));
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top:0, bottom:10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${destination['destination_name']}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.blueGrey,
                  fontSize: 18,
                )
              ),
              destination['start_date'] > 0 && destination['end_date'] > 0 ? 
              Text(
                ' ${new HtmlUnescape().convert('&bull;')} $startDate - $endDate',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.blueGrey,
                  fontSize: 18
                )
              ):
              Text(
                ' ${new HtmlUnescape().convert('&bull;')} Dates have not been set',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.red,
                  fontSize: 18
                )
              ),
            ],
          )
        )
      );
    }
    return Column(
      children: widgets,
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
      //controller: _scrollControllerTrips,
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
      body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Container(
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
    ));
  }
}