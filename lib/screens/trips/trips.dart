import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'dart:core';
import 'package:trotter_flutter/widgets/auth/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

enum CardActions { delete }

class _MyInheritedTrips extends InheritedWidget {
  _MyInheritedTrips({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  final TripsState data;

  @override
  bool updateShouldNotify(_MyInheritedTrips oldWidget) {
    return true;
  }
}

class Trips extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  Trips({Key key, this.onPush}) : super(key: key);
  @override
  TripsState createState() => new TripsState(onPush:this.onPush);

  static TripsState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_MyInheritedTrips) as _MyInheritedTrips).data;
  }
}

class TripsState extends State<Trips> {
  bool _showTitle = false;
  bool refreshing = false;
  bool loggedIn = false;
  BuildContext context;
  final ValueChanged<dynamic> onPush;
  
  
  Future<TripsData> data;
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


  TripsState({
    this.onPush
  });

 
  @override
  Widget build(BuildContext context) {
    this.context = context;
    var color = Color.fromRGBO(234, 189, 149,1);
    var currentUser = StoreProvider.of<AppState>(context).state.currentUser;
    return new Scaffold(
      floatingActionButton: (currentUser != null) ? FloatingActionButton(
        backgroundColor: color,
        onPressed: () { 
          onPush({"level": "createtrip"});
          if(StoreProvider.of<AppState>(context).state.trips.length == 0){
            setState(() {
              this._showTitle = false;           
            });
          }
        },
        tooltip: 'Create trip',
        child: Icon(Icons.add),
        elevation: 5.0,
      ) : null,
      body: StoreConnector <AppState, TripViewModel>(
        converter: (store) => TripViewModel.create(store),
        onInit: (store) async {
          if(store.state.currentUser != null){
            store.dispatch(new SetTripsLoadingAction(true));
            await fetchTrips(store);
            store.dispatch(SetTripsLoadingAction(false));
            this.loggedIn = true;
          }
        },
        rebuildOnChange: true,
        builder: (context, viewModel) => _buildLoadedBody(context, viewModel, color)
      )
    );
  }

  
  

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, TripViewModel viewModel, Color color) {
    
    var trips = StoreProvider.of<AppState>(context).state.trips;
    var currentUser = StoreProvider.of<AppState>(context).state.currentUser;
    var loading = StoreProvider.of<AppState>(context).state.tripLoading;
    var store = StoreProvider.of<AppState>(context);
    if(loading == true)
      return _buildLoadingBody(context, viewModel);
      
    
   if(currentUser == null){
      return Scaffold(
        
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            brightness: Brightness.light,
            title: SearchBar(
              placeholder: 'Explore the world',
              fillColor: color.withOpacity(0.3),
              onPressed: (){
                onPush({'query':'', 'level':'search'});
              },     
            ),
          ),
          body:Stack( children: <Widget>[
            Center(
            child:Container(
              color:Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset('images/trips-login.png', width:170, height: 170, fit: BoxFit.contain),
                  Text(
                    'Want to create a trip?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                      color: color,
                      fontWeight: FontWeight.w300
                      
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sign up and start planning right away.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      color: color,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    child: GoogleAuthButtonContainer()
                  )
                ],
              )
            )
          ),
          this.refreshing == true ? Center(
              child: RefreshProgressIndicator()
            ) : Container()
          ])); 
    } else if(currentUser != null && this.loggedIn == false){
      store.dispatch(new SetTripsLoadingAction(true));
      fetchTrips(store);
      this.loggedIn = true;
    }
    
    if(trips.length == 0) {
      return Scaffold(
        
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            brightness: Brightness.light,
            title: SearchBar(
              placeholder: 'Explore the world',
              fillColor: color.withOpacity(0.3),
              onPressed: (){
                onPush({'query':'', 'level':'search'});
              },     
            ),
          ),
          body:Stack( children: <Widget>[
            Center(
            child:Container(
              color:Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset('images/trips-empty.png', width:170, height: 170, fit: BoxFit.contain),
                  Text(
                    'No trips planned yet?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 35,
                      color: color,
                      fontWeight: FontWeight.w300
                      
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create a trip to start planning your next adventure!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      color: color,
                      fontWeight: FontWeight.w200
                    ),
                  )
                ],
              )
            )
          ),
          this.refreshing == true ? Center(
              child: RefreshProgressIndicator()
            ) : Container()
          ])); 
    }
   


    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: this._showTitle ? color : Colors.white,
            automaticallyImplyLeading: false,
            title: SearchBar(
              placeholder: 'Explore the world',
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
                        clipper: BottomWaveClipper(),
                        child: Image.asset(
                        'images/trips.jpg',
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
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: RefreshIndicator(
                onRefresh: () => viewModel.onGetTrips(),
                child: Stack(
                  children: <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: trips.length,
                      itemBuilder: (BuildContext context, int index) {
                        var color = Color(hexStringToHexInt(trips[index]['color']));
                        //var maincolor = Color.fromRGBO(1, 155, 174, 1);            
                        var onPressed2 = () async {
                          var undoData = {
                            "trip":{
                              "image": trips[index]['image'],
                              "name": trips[index]['name']
                            },
                            "destinations": trips[index]['destinations']
                          };
                          setState(() {
                            this.refreshing = true;                                
                          });
                          var response = await viewModel.onDeleteTrip(trips[index]['id']);
                          setState(() {
                            this.refreshing = false;                           
                          });
                          if(response.success == true) {
                            this.context = context;
                            setState(() {
                              if(StoreProvider.of<AppState>(context).state.trips.length == 0){
                                this._showTitle = false;
                              }                                
                            });
                            Scaffold
                            .of(context)
                            .showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${trips[index]['name']}\'s was deleted.',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                duration: Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: color,
                                  onPressed: () async {
                                    setState(() {
                                      this.refreshing = true;                               
                                    });
                                    var response = await viewModel.undoDeleteTrip(undoData, index);
                                    setState(() {
                                      this.refreshing = false;
                                    });
                                    if(response.success == true){
                                      Scaffold.of(this.context).removeCurrentSnackBar();
                                      Scaffold
                                      .of(this.context)
                                      .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Undo successful!',
                                            style: TextStyle(
                                              fontSize: 18
                                            )
                                          ),
                                          duration: Duration(seconds: 2),
                                        )
                                      ); 
    
                                    } else {
                                      Scaffold.of(this.context).removeCurrentSnackBar();
                                      Scaffold
                                      .of(this.context)
                                      .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Sorry the undo failed!',
                                            style: TextStyle(
                                              fontSize: 18
                                            )
                                          ),
                                          duration: Duration(seconds: 2)
                                        )
                                      ); 
                                    }

                                  },
                                ),
                              )
                            ); 
                          } else {
                            Scaffold
                            .of(context)
                            .showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${trips[index]['name']} failed to be deleted.',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                duration: Duration(seconds: 2)
                              )
                            ); 
                          }
                        };
                        return InkWell(
                          onTap: () async {
                            onPush({'id':trips[index]['id'].toString(), 'level':'trip'});
                          },
                          child:Card(
                            semanticContainer: true,
                            color: Colors.white,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: Column(
                              children: <Widget>[  
                                Container(
                                  height: 350.0,
                                  width: double.infinity,
                                  color: Colors.white,
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned.fill(
                                        top:0,
                                        left:0,
                                        
                                        child: ClipPath( 
                                          clipper: CurveClipper(),
                                          child: CachedNetworkImage(
                                            imageUrl: trips[index]['image'],
                                            fit: BoxFit.cover,
                                          )
                                        )
                                      ),
                                      Positioned.fill(
                                        top:0,
                                        left:0,
                                        
                                        child: ClipPath( 
                                          clipper: CurveClipper(),
                                          child: Container(
                                            color: color.withOpacity(.3),
                                          )
                                        )
                                      ),
                                      Positioned.fill(
                                        top:300,
                                        left:0,
                                        child: ListView(
                                          shrinkWrap: true,
                                          primary: false,
                                          children:<Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(top: 0.0, bottom: 10, left:20, right:20),
                                              child: Text(
                                                trips[index]['name'].toUpperCase(),
                                                overflow: TextOverflow.fade,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: color,
                                                  fontSize: 25.0,
                                                  fontWeight: FontWeight.w500
                                                  
                                                ),
                                              )
                                            ),
                                            Align(child:Container(
                                              padding: EdgeInsets.symmetric(horizontal: 20),
                                              width: 130,
                                              child: Divider(
                                                color: Color.fromRGBO(0, 0, 0, 0.4),
                                                
                                                
                                              )
                                            )),
                                          ] 
                                        ),
                                      ),
                                      Positioned(
                                        top:20,
                                        left: 20,
                                        child: GestureDetector( 
                                          onTap: onPressed2,
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              color: fontContrast(color).withOpacity(.3)
                                            ),
                                            child: Icon(EvilIcons.close, color: fontContrast(color).withOpacity(.8),size: 35,)
                                          ),
                                        )
                                      ),
                                    ],
                                  )                         
                                ),
                                ListView(
                                  shrinkWrap: true,
                                  primary: false,
                                  children:<Widget>[
                                    _buildDestinationInfo(trips[index]['destinations'], color),
                                  ] 
                                )
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
                    )
                  ]
                )
              )
            ),
            this.refreshing == true ? Center(
              child: RefreshProgressIndicator()
            ) : Container()
          ]
        )
      ),
    );
  }

  _buildDestinationInfo(List<dynamic> destinations, Color color){
    var widgets = <Widget>[];
    var length = destinations.length;
    if(length > 3){
      length = 3;
    }
    for (var i = 0; i < length; i++){
      var destination =  destinations[i];
      // var startDate = new DateFormat.yMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destination['start_date']*1000));
      // var endDate = new DateFormat.yMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destination['end_date']*1000));
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top:0, bottom:10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(3),
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  color:color,

                ),
                child:Icon(EvilIcons.location, color:fontContrast(color), size: 15,)
              ),
              Text(
                '${destination['destination_name']}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 20,
                )
              ),
              /*destination['start_date'] > 0 && destination['end_date'] > 0 ? 
              Text(
                ' ${new HtmlUnescape().convert('&bull;')} $startDate - $endDate',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
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
              ),*/
            ],
          )
        )
      );
    }
    if(destinations.length > length) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top:0, bottom:10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(3),
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  color:Color.fromRGBO(0, 0, 0, .3),

                ),
                child:Icon(EvilIcons.location, color:fontContrast(color), size: 15,)
              ),
              Text(
                '$length of ${destinations.length}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, .5),
                  fontSize: 20,
                )
              ),
            ],
          )
        )
      );
    }
    return Container(
      margin: EdgeInsets.only(top:40, bottom:20),
      padding: EdgeInsets.symmetric(horizontal: 60),
      child:Column(
        children: widgets,
      )
    );
  }
  
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt, TripViewModel viewModel) {
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
        onRefresh: ()=> viewModel.onGetTrips(),
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