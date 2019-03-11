import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/day-list/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_fab_dialer/flutter_fab_dialer.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';



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
  List<dynamic> itineraryItems = [];
  //List<FabMiniMenuItem> _fabMiniMenuItemList = [];
  
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
        this.destinationId = data.destination['id'].toString();
        this.itineraryItems = data.day['itinerary_items'];
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
          // print(suggestion['location']);
          var data = {
            "poi": suggestion,
            "title":"",
            "description":"",
            "time":{
              "value":"",
              "unit":""
            }
          };

          var response = await addToDay(this.itineraryId, this.dayId, data);
          this.itineraryItems.add(response.itineraryItem);
          StoreProvider.of<AppState>(context).dispatch(UpdateDayAfterAddAction(this.dayId, response.itineraryItem));
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
    var itinerary = snapshot.data.itinerary;
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
      body: DayList(items: itineraryItems, color:color)
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