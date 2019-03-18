import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:trotter_flutter/widgets/day-list/index.dart';
import 'package:cached_network_image/cached_network_image.dart';




class Day extends StatefulWidget {
  final String dayId;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  Day({Key key, @required this.dayId, this.itineraryId, this.onPush}) : super(key: key);
  @override
  DayState createState() => new DayState(dayId:this.dayId, itineraryId: this.itineraryId, onPush:this.onPush);
}

class DayState extends State<Day> {
  bool _showTitle = false;
  final String dayId;
  final String itineraryId;
  final ValueChanged<dynamic> onPush;
  Color color = Colors.blueGrey;
  String destinationName;
  String destinationId;
  List<dynamic> itineraryItems = [];
  
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
    
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }


  DayState({
    this.dayId,
    this.itineraryId,
    this.onPush
  });

  


  @override
  Widget build(BuildContext context) {
    data.then((data){
      setState(() {
        this.color = Color(hexStringToHexInt(data.color));
        this.destinationName = data.destination['name'];
        this.destinationId = data.destination['id'].toString();
        this.itineraryItems = data.day['itinerary_items'].sublist(1);
      });
      
    });
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
                  ),
                ]
              )
            ),
          ),
        ];
      },
      body: DayList(items:itineraryItems, color: color,),
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