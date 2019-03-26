import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/day-list/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trotter_flutter/widgets/itineraries/index.dart';



class DayEdit extends StatefulWidget {
  final String dayId;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  DayEdit({Key key, @required this.dayId, this.itineraryId, this.onPush}) : super(key: key);
  @override
  DayEditState createState() => new DayEditState(dayId:this.dayId, itineraryId: this.itineraryId, onPush:this.onPush);
}

class DayEditState extends State<DayEdit> {
  bool _showTitle = false;
  final String dayId;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  Color color = Colors.blueGrey;
  String destinationName;
  String destinationId;
  dynamic destination;
  List<dynamic> itineraryItems = [];
  //List<FabMiniMenuItem> _fabMiniMenuItemList = [];
  bool loading = false;
  
  Future<DayData> data;
  final ScrollController _scrollController = ScrollController();
    var kExpandedHeight = 130;

  @override
  void initState() {

    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    super.initState();
    data = fetchDay(this.itineraryId, this.dayId);
    data.then((data){
      setState(() {
        this.color = Color(hexStringToHexInt(data.color));
        this.destinationName = data.destination['name'];
        this.destination = data.destination;
        this.destinationId = data.destination['id'].toString();
        this.itineraryItems = data.day['itinerary_items'].sublist(1);
      });
    }); 
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }


  DayEditState({
    this.dayId,
    this.itineraryId,
    this.onPush
  });

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            return _buildFab(Color(hexStringToHexInt(snapshot.data.color)));
          }
          return FloatingActionButton(onPressed: (){}, backgroundColor: Color.fromRGBO(240, 240, 240, 1),);
        }
      ),
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
  
  Widget _buildFab(color){
    var items = [
      new FabMiniMenuItem.withText(
        new Icon(EvilIcons.location),
        Colors.deepPurple,
        4.0,
        null,
        () async { 
        var suggestion = await Navigator.push(
          context, MaterialPageRoute(
            fullscreenDialog: true, 
            builder: (context) => SearchModal(
              query:'',
              location: this.destinationName,
              id: this.destinationId
            )
          )
        );
        if(suggestion != null){
          var data = {
            "poi": suggestion,
            "title":"",
            "description":"",
            "time":{
              "value":"",
              "unit":""
            }
          };

          this.loading = true;
          var response = await addToDay(StoreProvider.of<AppState>(context), this.itineraryId, this.dayId, this.destinationId, data, false);
          setState(() {
            this.color = Color(hexStringToHexInt(response.color));
            this.destinationName = response.destination['name'];
            this.destinationId = response.destination['id'].toString();
            this.itineraryItems = response.day['itinerary_items'];
            this.loading = false;
          });
          
        }
      },
        "Add a place",
        Colors.blueGrey,
        Colors.white,
        true
      ),
      new FabMiniMenuItem.withText(
        new Icon(EvilIcons.bell),
        Colors.red,
        4.0,
        null,
        () async { 
          print('add reminder');
        },
        "Add a reminder",
        Colors.blueGrey,
        Colors.white,
        true
      ),   
    ];
    return new FabDialer(items, color, new Icon(Icons.add));
  }
// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    
    var day = snapshot.data.day;
    //var itinerary = snapshot.data.itinerary;
    var destination = snapshot.data.destination;
    var color = Color(hexStringToHexInt(snapshot.data.color));

    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: _showTitle ? color : Colors.transparent,
            automaticallyImplyLeading: false,
            leading: IconButton(
              padding: EdgeInsets.all(0),
              icon:  Icon(Icons.arrow_back),
              onPressed: () {  Navigator.pop(context);},
              iconSize: 30,
              color: Colors.white,
            ),      
            //bottom: PreferredSize(preferredSize: Size.fromHeight(15), child: Container(),),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Your ${ordinalNumber(day['day'] + 1)} day in $destinationName',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.w300
                  ),
                ),
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: ClipPath(
                        //clipper: BottomWaveClipperSlant(),
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
                        //clipper:BottomWaveClipperSlant(),
                        child: Container(
                        color: color.withOpacity(0.5),
                      )
                    )
                  )
                ]
              )
            ),
          ),
        ];
      },
      body: Stack(
        fit: StackFit.expand,
        children:<Widget>[
          DayList(
            items: itineraryItems, 
            color:color,
            onLongPressed: (data){
              //print(data);
              bottomSheetModal(context, day['day']+1, data);
            },
          ),
          this.loading == true ? Align( alignment: Alignment.center, child:Container( 
            width:50,
            height: 50,
            child:RefreshProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(color),
            ))
          ) :Container()
        ])
    );
  }

  bottomSheetModal(BuildContext ctxt, int dayIndex, dynamic data){
    var name = data['poi']['name'];
    var undoData = data;
    var id = data['id'];

    return showModalBottomSheet(context: ctxt,
      builder: (BuildContext context) {
        return new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new ListTile(
              
              leading: new Icon(EvilIcons.external_link),
              title: new Text('Move to another day'),
              onTap: () async {
                var result = await showDayBottomSheet(StoreProvider.of<AppState>(context),context,this.itineraryId,data['poi'],this.destinationId,this.color,this.destination,force:true, isSelecting: false, movingFromId: this.dayId);
                if(result != null && result['selected'] != null){
                  setState(() {
                    this.loading = true;
                  });
                  var response = await deleteFromDay(this.itineraryId, this.dayId, id);
                  if(response.success == true){
                    setState(() {
                      this.itineraryItems.removeWhere((item)=> item['id'] == id);
                      StoreProvider.of<AppState>(context).dispatch(UpdateDayAfterDeleteAction(this.dayId, id));
                      Navigator.of(context).pop();
                      this.loading = false;
                    });
                  }
                }
              } 
            ),
            new ListTile(
              leading: new Icon(EvilIcons.trash,),
              title: new Text('Delete from itnerary'),
              onTap: () async { 
                this.loading = true;
                var response = await deleteFromDay(this.itineraryId, this.dayId, id);
                if(response.success == true){
                  setState(() {
                    this.itineraryItems.removeWhere((item)=> item['id'] == id);
                    StoreProvider.of<AppState>(context).dispatch(UpdateDayAfterDeleteAction(this.dayId, id));
                    this.loading = false;
                  });
                  Scaffold
                  .of(ctxt)
                  .showSnackBar(
                    SnackBar(
                      content: Text(
                        '$name was removed.',
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
                            this.loading = true;                               
                          });
                          var response = await addToDay(StoreProvider.of<AppState>(ctxt),this.itineraryId, this.dayId, this.destinationId, undoData, false);
                          if(response.success == true){
                            setState(() {
                              this.color = Color(hexStringToHexInt(response.color));
                              this.destinationName = response.destination['name'];
                              this.destinationId = response.destination['id'].toString();
                              this.itineraryItems = response.day['itinerary_items'];
                              this.loading = false;
                              Scaffold.of(ctxt).removeCurrentSnackBar();
                              Scaffold
                              .of(ctxt)
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
                            });
                          } else {
                            Scaffold.of(ctxt).removeCurrentSnackBar();
                            Scaffold
                            .of(ctxt)
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
                }
                Navigator.of(context).pop();
              }        
            ),
          ]
        );
      }
    );
  }
  
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    return Column(
      children: <Widget>[
        Container(
          height: 200,
          margin: EdgeInsets.only(bottom:40),
          color: Color.fromRGBO(240, 240, 240, 1),
        ),
        Flexible(
          child: DayListLoading(),
        )
      ]
    );
  }
}
