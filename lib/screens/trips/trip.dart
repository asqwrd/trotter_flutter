import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:queries/collections.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'trip-api.dart';
import 'add-destination-modal.dart';

showDateModal(BuildContext context, dynamic destination, Color color,String tripId) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
      Animation<double> secondaryAnimation) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40, bottom: 20),
              child: Text(
                'Arrival and Departure',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300
                ),
              )
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: _buildDatesModal(buildContext, destination, color, tripId)
            )
          ],
        )
      );
    },
    transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
      return new FadeTransition(
            opacity: animation,
            child: child,
          );
    },
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
  );
}
_buildDatesModal(BuildContext context, dynamic destination, Color color,tripId){
  var dateFormat = DateFormat("EEE, MMM d, yyyy");
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var arrival = destination['start_date'];
  var departure = destination['end_date'];
  return Form(
    key: _formKey,
    child: Column(
      children: <Widget>[
        Container(
          margin:EdgeInsets.only(left: 20.0, right:20, top: 20.0, bottom:0),
          child:DateTimePickerFormField(
            format: dateFormat,
            dateOnly: true,
            editable: false,
            initialValue: destination['start_date'] > 0 ? DateTime.fromMillisecondsSinceEpoch(destination['start_date']*1000) : null,
            //firstDate: destination['start_date'] > 0 ? DateTime.fromMillisecondsSinceEpoch(destination['start_date']*1000) : DateTime.now(),
            initialDate: destination['start_date'] > 0 ? DateTime.fromMillisecondsSinceEpoch(destination['start_date']*1000) : DateTime.now(),
            decoration: InputDecoration(
              hintText: 'Arrival date', 
              contentPadding: EdgeInsets.symmetric(vertical:20.0),
              prefixIcon: Padding(
                padding:EdgeInsets.only(left:20.0, right: 5.0), 
                child:Icon(
                  Icons.calendar_today,
                  size: 18,
                )
              ), 
              //fillColor: Colors.blueGrey.withOpacity(0.5),
              filled: true,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(
                  width: 1.0,
                  color: Colors.red
                )
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(
                  width: 1.0,
                  color: Colors.red
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(
                  width: 0.0,
                  color: Colors.transparent
                )
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(
                  width: 0.0,
                  color: Colors.transparent
                )
              ),
            ),
            onChanged: (dt){ 
              if(dt != null) {
                var startDate = dt.millisecondsSinceEpoch/1000;
                arrival =  startDate.toInt();
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select an arrival date';
              }
            },
          )
        ),
        Container(
          margin:EdgeInsets.only(left: 20.0, right:20, top: 20.0, bottom:0),
          child: DateTimePickerFormField(
            format: dateFormat,
            dateOnly: true,
            editable: false,
            initialValue: destination['end_date'] > 0 ? DateTime.fromMillisecondsSinceEpoch(destination['end_date']*1000) : null,
            //firstDate: destination['end_date'] > 0 ? DateTime.fromMillisecondsSinceEpoch(destination['end_date']*1000) : DateTime.now(),
            initialDate: destination['end_date'] > 0 ? DateTime.fromMillisecondsSinceEpoch(destination['end_date']*1000) : DateTime.now(),
            decoration: InputDecoration(
              hintText: 'Departure date', 
              contentPadding: EdgeInsets.symmetric(vertical:20.0),
              prefixIcon: Padding(
                padding:EdgeInsets.only(left:20.0, right: 5.0), 
                child:Icon(
                  Icons.calendar_today,
                  size: 18,
                )
              ), 
              //fillColor: Colors.blueGrey.withOpacity(0.5),
              filled: true,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(
                  width: 1.0,
                  color: Colors.red
                )
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(
                  width: 1.0,
                  color: Colors.red
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(
                  width: 0.0,
                  color: Colors.transparent
                )
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(
                  width: 0.0,
                  color: Colors.transparent
                )
              ),
            ),
            onChanged: (dt){
              if(dt != null) {
                var endDate = dt.millisecondsSinceEpoch/1000;
                departure =  endDate.toInt();
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a departure date';
              } else if(departure < arrival){
                return "Please choose a later departure date";
              }
            },
          )
        ),
        Container(
          width:double.infinity,
          margin: EdgeInsets.only(top: 40, left: 20, right: 20, bottom:20),
          child: FlatButton(
            color: color.withOpacity(0.8),
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'Change date',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w300,
                  color: Colors.white
                )
              )
            ),
            onPressed: () async {
              if(_formKey.currentState.validate() ){
                destination["start_date"] =  arrival;
                destination["end_date"] = departure;
                var response = await putUpdateTripDestination(tripId, destination['id'], destination);
                if(response.success == true){
                  //setState(() {
                    destination["start_date"] =  arrival;
                    destination["end_date"] = departure;
                    Navigator.pop(context,{"arrival": arrival, "departure": departure});   
                  //});
                }

              }
            },
          )
        ),
        Container(
          width:double.infinity,
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: FlatButton(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child:Text(
                'Close',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w300
                )
              )
            ),
            onPressed: (){
              Navigator.pop(context,{"arrival": arrival, "departure": departure, "closed":true});  
            },
          )
        )
      ]
    )
  );
}

Future<TripData> fetchTrip(String id) async {
  final response = await http.get('http://localhost:3002/api/trips/get/$id', headers:{'Authorization':'security'});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return TripData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

class TripDestinationDialogContent extends StatefulWidget {
   TripDestinationDialogContent({
    Key key,
    this.destinations,
    this.color,
    @required this.tripId
  }): super(key: key);
  final dynamic destinations;
  final String tripId;
  final Color color;
  @override
  _TripDestinationDialogContentState createState() => new _TripDestinationDialogContentState(color: this.color, tripId: this.tripId, destinations: this.destinations);

}

class TripNameDialogContent extends StatefulWidget {
   TripNameDialogContent({
    Key key,
    this.trip,
    this.color,
    @required this.tripId
  }): super(key: key);
  final dynamic trip;
  final String tripId;
  final Color color;
  @override
  _TripNameDialogContentState createState() => new _TripNameDialogContentState(color: this.color, tripId: this.tripId, trip: this.trip);

}

class _TripNameDialogContentState extends State<TripNameDialogContent> {
  _TripNameDialogContentState({this.color,this.tripId,this.trip});
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameControllerModal = TextEditingController();
    
  
  final dynamic trip;
  final String tripId;
  final Color color;
  @override
  void initState(){
    _nameControllerModal.text = this.trip['name'];
    super.initState();
  }

   @override
  Widget build(BuildContext context) {
    return Form(
      key: this._formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal:0.0, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top:20, bottom: 30),
              child:Text(
              'Update trip name',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w300
              )
            )),
            Container(
              margin:EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                maxLength: 20,
                maxLengthEnforced: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical:20.0),
                  prefixIcon: Padding(padding:EdgeInsets.only(left:20.0, right: 5.0), child:Icon(Icons.label)), 
                  //fillColor: Colors.blueGrey.withOpacity(0.5),
                  filled: true,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(
                      width: 1.0,
                      color: Colors.red
                    )
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(
                      width: 1.0,
                      color: Colors.red
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(
                      width: 0.0,
                      color: Colors.transparent
                    )
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(
                      width: 0.0,
                      color: Colors.transparent
                    )
                  ),
                  hintText: 'Name your trip',
                ),
                controller: _nameControllerModal,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please name your trip.';
                  }
                },
              )
            ),
            Container(
              width:double.infinity,
              margin: EdgeInsets.only(top: 40, left: 20, right: 20, bottom:20),
              child: FlatButton(
                color: color.withOpacity(0.8),
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w300,
                      color: Colors.white
                    )
                  )
                ),
                onPressed: () async {
                  if(_formKey.currentState.validate() ){
                    var response = await putUpdateTrip(tripId, {"name": _nameControllerModal.text});
                    if(response.success == true){
                      setState(() {
                        this.trip['name'] = _nameControllerModal.text; 
                        Navigator.pop(context);

                      });
                    }

                  }
                },
              )
            ),
            Container(
              width:double.infinity,
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: FlatButton(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child:Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w300
                    )
                  )
                ),
                onPressed: (){
                  Navigator.pop(context,{"closed":true});  
                },
              )
            )
          ],
        )
      )
    ); 
  }
}


class AddButtonModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text("Button moved to separate widget"),
      onPressed: () {
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Button moved to separate widget'),
            duration: Duration(seconds: 3),
          )
        );
      }
    );
  }
}



class _TripDestinationDialogContentState extends State<TripDestinationDialogContent> {
  _TripDestinationDialogContentState({this.color,this.tripId,this.destinations});
  
  final List<dynamic> destinations;
  final String tripId;
  final Color color;
  @override
  void initState(){
    super.initState();
  }

  

   @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: Builder( builder: (BuildContext builderContext) => FloatingActionButton(
        backgroundColor: this.color,
        onPressed: () async { 
          var data = await showGeneralDialog(
            context: builderContext,
            pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
              return Dialog(
                child: AddDestinationModal(tripId: this.tripId,color: this.color)
              );
            },
            transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
              return new FadeTransition(
                    opacity: animation,
                    child: child,
                  );
            },
            barrierDismissible: true,
            barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.black.withOpacity(0.5),
            transitionDuration: const Duration(milliseconds: 300),
          );
          if(data != null){
            var response = await postAddToTrip(this.tripId, data);
            if(response.destination != null) {
              data['id'] = response.destination['ID'];
              setState(() {
                this.destinations.add(data);
                Scaffold.of(builderContext).showSnackBar(SnackBar(content: Text('${data['destination_name']}\'s has been added')));
              });
            } else if(response.exists == true){
              setState(() {
                Scaffold.of(builderContext).showSnackBar(SnackBar(content: Text('${data['destination_name']}\'s already exist for this trip.')));
              });
            }
          }
        },
        tooltip: 'Add destination',
        child: Icon(Icons.add),
        elevation: 5.0,
      )
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        title: Text(
          'Destinations',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w300
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          iconSize: 25,
          color: Colors.black,
          icon: Icon(Icons.close),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (BuildContext serperatorContext, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
        padding: EdgeInsets.all(20.0),
        itemCount: destinations.length,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (BuildContext listContext, int index){
          var startDate = new DateFormat.yMMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destinations[index]['start_date']*1000));
          var endDate = new DateFormat.yMMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destinations[index]['end_date']*1000));
          var arrival = destinations[index]['start_date'];
          var departure = destinations[index]['end_date'];
          var name = destinations[index]['destination_name'];
          return ListTile(
            subtitle: Text(
              arrival == 0 || departure == 0 ? 'No dates given' : '$startDate - $endDate',
            ),
            trailing: IconButton(
              onPressed: (){
                showModalBottomSheet(context: listContext,
                  builder: (BuildContext modalcontext) {
                    return new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          leading: new Icon(Icons.calendar_today, size:22),
                          title: new Text(
                            'Change arrival and departure dates',
                          ),
                          onTap: () async{
                            Navigator.pop(context);
                            var update = await showDateModal(context,destinations[index],this.color, this.tripId);
                            setState(() {
                              if(update['closed'] == null){
                                startDate = new DateFormat.yMMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(update['arrival']*1000));
                                endDate = new DateFormat.yMMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(update['departure']*1000));
                                Scaffold
                                .of(listContext)
                                .showSnackBar(SnackBar(content: Text('${destinations[index]['destination_name']}\'s dates updated')));
                              }

                            });
                            
                          }   
                        ),
                        new ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          leading: new Icon(Icons.delete, size:22),
                          title: new Text(
                            'Delete $name',
                          ),
                          onTap: () async {
                            var response = await deleteDestination(this.tripId, this.destinations[index]['id']);
                            if(response.success == true){
                              Navigator.pop(modalcontext);
                              setState(() {
                                var undoDestination = this.destinations[index];
                                this.destinations.removeAt(index);
                                Scaffold
                                .of(listContext)
                                .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '$name\'s was deleted.',
                                      style: TextStyle(
                                        fontSize: 18
                                      )
                                    ),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      textColor: this.color,
                                      onPressed: () async {
                                        var response = await postAddToTrip(this.tripId, undoDestination);
                                        if(response.destination != null) {
                                          undoDestination['id'] = response.destination['ID'];
                                          setState(() {
                                            this.destinations.insert(index, undoDestination);
                                            Scaffold.of(listContext).removeCurrentSnackBar();
                                          });
                                        }
                                      },
                                    ),
                                  )
                                );                           
                              });
                            }
                          }        
                        ),
                      ]
                    );
                  }
                );
              },
              icon:Icon(Icons.more_vert)
            ),
            title: Text(
              destinations[index]['destination_name'],
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w300
              ),
            ),
                
          );
        },
      )
    );
  }
}

class TripData {
  final Map<String, dynamic> trip; 
  final List<dynamic> destinations; 

  TripData({this.trip, this.destinations});

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      trip: json['trip'],
      destinations: json['destinations']
    );
  }
}


class Trip extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  final String tripId;
  Trip({Key key, this.onPush, @required this.tripId}) : super(key: key);
  @override
  TripState createState() => new TripState(onPush:this.onPush, tripId: this.tripId);
}

class TripState extends State<Trip> {
  bool _showTitle = false;
  final ValueChanged<dynamic> onPush;
  final String tripId;
  GoogleMapController mapController;
  Color color = Colors.blueGrey;
  List<dynamic> destinations;
  dynamic trip;
  
  Future<TripData> data;

  @override
  void initState() {
    super.initState();
    data = fetchTrip(this.tripId);
    
  }

  TripState({
    this.onPush,
    this.tripId
  });

  bottomSheetModal(BuildContext context, dynamic data){
    
  return showModalBottomSheet(context: context,
    builder: (BuildContext context) {
      return new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new ListTile(
            leading: new Icon(Icons.card_travel),
            title: new Text('Trip name'),
            onTap: () {
              Navigator.pop(context);
              return showGeneralDialog(
                context: context,
                pageBuilder: (BuildContext buildContext, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                  return Dialog(
                    child: TripNameDialogContent(tripId:this.tripId, trip:data, color:this.color)
                  );
                },
                transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                  return new FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                },
                barrierDismissible: true,
                barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                barrierColor: Colors.black.withOpacity(0.5),
                transitionDuration: const Duration(milliseconds: 300),
              );
              
            }   
          ),
          new ListTile(
            leading: new Icon(Icons.pin_drop),
            title: new Text('Destinations'),
            onTap: () { 
              Navigator.pop(context);
              showDestinationsModal(context,this.destinations, this.color);
            }        
          ),
        ]
      );
    }
  );
}



  


  @override
  Widget build(BuildContext context) {
    data.then((data){
      setState(() {
        this.color = Color(hexStringToHexInt(data.trip['color']));
        this.destinations = data.destinations;
        this.trip = data.trip;
        
        //print(this.name);
      });
      
    });
    return new Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: this.color,
        onPressed: () { 
          bottomSheetModal(context, this.trip);
        },
        tooltip: 'Create trip',
        child: Icon(Icons.edit),
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
    final ScrollController _scrollController = ScrollController();
    var kExpandedHeight = 300;


    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    var trip = snapshot.data.trip;
    //var name = snapshot.data.trip['name'];
    //this.name = name;
    var destinations = snapshot.data.destinations;
    var destTable = new Collection<dynamic>(destinations);
    var result2 = destTable.groupBy<dynamic>((destination) => destination['country_id']);
    var color = Color(hexStringToHexInt(snapshot.data.trip['color']));
    var iconColor = Color.fromRGBO(0, 0, 0, 0.5);
    var fields = [
      {"label":"Itinerary", "icon": Icon(Icons.map, color: iconColor)},
      {"label":"Flights and accommodation", "icon": Icon(Icons.flight, color: iconColor)},
    ];

    for (var group in result2.asIterable()) {
      var key = group.key;
      for (var destination in group.asIterable()) {
        fields.add(
          {"label":"Activities in ${destination['destination_name']}", "icon": Icon(Icons.local_activity, color: iconColor), "id":destination['destination_id'].toString(), "level": destination['level'].toString()}
        );
      }
      if(group.asIterable().first['level'] != 'city_state'){
        fields.add(
          {"label":"Must knows about ${group.asIterable().first['country_name']}", "icon": Icon(Icons.info_outline, color: iconColor), "id": key.toString(), "level":"country"}
        );
      }
    }
  
    return NestedScrollView(
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
                        child: Image.network(
                        trip['image'],
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
                        Text(this.trip['name'],
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
      body: ListView(
        children: <Widget>[
          _buildDestinationInfo(destinations, color),
          Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
          ListView.separated(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.all(0),
            itemCount: fields.length,
            separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
            itemBuilder: (BuildContext context, int index){
              return ListTile(
                onTap: (){
                  if(fields[index]['id'] != null)
                    onPush({'id': fields[index]['id'].toString(), 'level': fields[index]['level'].toString()});
                },
                trailing: fields[index]['icon'],
                title: Text(
                  fields[index]['label'],
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300
                  ),
                ),
                    
              );
            }
          )
        ]
      )
    );
  }

  _buildDestinationInfo(List<dynamic> destinations, Color color){
    var widgets = <Widget>[];
    for (var destination in destinations){
      var startDate = new DateFormat.yMMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destination['start_date']*1000));
      var endDate = new DateFormat.yMMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destination['end_date']*1000));
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top:5, bottom:5, right:20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                '${destination['destination_name']} ${new HtmlUnescape().convert('&bull;')}  ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.blueGrey,
                  fontSize: 18,
                )
              ),
              destination['start_date'] == 0 || destination['end_date'] == 0 ? 
                InkWell(
                  onTap: () {
                    showDateModal(context, destination, color, this.tripId);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10), 
                    child:Text(
                      'Select arrival and departure dates',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.blueGrey,
                        fontSize: 18,
                        decoration: TextDecoration.underline
                      )
                    )
                  ),
                )
              :
              InkWell(
                onTap: () {
                  showDateModal(context, destination, color, this.tripId);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10), 
                  child:Text(
                    '$startDate - $endDate',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.blueGrey,
                      fontSize: 18,
                      decoration: TextDecoration.underline
                    )
                  )
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

  

  showDestinationsModal(BuildContext context, dynamic destinations, Color color) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
        return TripDestinationDialogContent(color: color, tripId: this.tripId, destinations:destinations);
      },
      transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return new FadeTransition(
              opacity: animation,
              child: child,
            );
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
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
      //controller: _scrollControllerTrip,
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