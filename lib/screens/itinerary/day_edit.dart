import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trotter_flutter/redux/index.dart';




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


  DayEditState({
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
        this.itineraryItems = data.day['itinerary_items'];
      });
      
    });
    return new Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: this.color,
        onPressed: () async { 
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
            print(suggestion);
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
            print(response);
            this.itineraryItems.add(response.itineraryItem);
          }
        },
        tooltip: ' Add a place',
        child: Icon(Icons.add),
        elevation: 5.0,
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
                        //clipper:BottomWaveClipperSlant(),
                        child: Container(
                        color: color.withOpacity(0.5),
                      )
                    )
                  ),
                  /*Positioned.fill(
                    top: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child:Text(
                        'Your ${ordinalNumber(day['day'] + 1)} day in $destinationName',
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                          fontWeight: FontWeight.w300
                        ),
                      ))
                    ),
                  ),*/
                ]
              )
            ),
          ),
        ];
      },
      body: Container(
        margin: EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
        decoration: BoxDecoration(color: Colors.white),
        child: ListView.builder(
          itemCount: itineraryItems.length,
          itemBuilder: (BuildContext context, int index){
            var color = Color(hexStringToHexInt(itineraryItems[index]['color']));
            var poi = itineraryItems[index]['poi'];
            var item = itineraryItems[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child:Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 0),
                    width:40,
                    child: Icon(
                            Icons.blur_circular,
                            color:Colors.grey,
                            size: 30,
                            
                          ),
                  ),
                  Flexible(
                    //width:200,
                    child: Card(
                      color: color,
                      elevation: 0,
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 40),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right:10),
                                  child:Icon(
                                    Icons.place,
                                    color:fontContrast(color),
                                    size: 16,
                                    
                                  )
                                ),
                                Text(
                                  poi['name'],
                                  style: TextStyle(
                                    color: fontContrast(color),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300
                                  )
                                ),
                              ]
                            )
                          ),
                          Opacity(
                            opacity: 0.75,
                            child: Container(
                              height: 380,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(item['image']),
                                  fit: BoxFit.cover
                                ),
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))

                              ),
                            )
                          )

                        ]
                      )
                    )
                  )
                  
                ],
              )
            );
          },
        )
      ),
    );
  }
  
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
    return NestedScrollView(
      //controller: _scrollControllerDay,
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