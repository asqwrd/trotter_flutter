import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:queries/collections.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'add-destination-modal.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';


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
              if(_formKey.currentState.validate() && StoreProvider.of<AppState>(context).state.tripLoading == false){
                destination["start_date"] =  arrival;
                destination["end_date"] = departure;
                StoreProvider.of<AppState>(context).dispatch(SetTripsLoadingAction(true)); 
                var response = await putUpdateTripDestination(tripId, destination['id'], destination);
                if(response.success == true){
                    destination["start_date"] =  arrival;
                    destination["end_date"] = departure;
                    Navigator.pop(context,{"arrival": arrival, "departure": departure});   
                }
                StoreProvider.of<AppState>(context).dispatch(SetTripsLoadingAction(false)); 

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

Future<TripData> fetchTrip(Store<AppState> store, String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.get('http://localhost:3002/api/trips/get/$id', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      await prefs.setString('trip_$id', response.body);
      var tripData = json.decode(response.body);
      return TripData.fromJson(tripData);
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      return TripData(error:'Response> $msg');
    }

  } catch(error){
    final String cacheData = prefs.getString('trip_$id') ?? null;
    if(cacheData != null) {
      var tripData = json.decode(cacheData);
      var results = TripData.fromJson(tripData);
      store.dispatch(
        new OfflineAction(
          true,
        )
      );
      return results;
    } else {
      return TripData(error: "Server is down");
    }
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
                        var oldName = this.trip['name'];
                        this.trip['name'] = _nameControllerModal.text;
                        StoreProvider.of<AppState>(context).dispatch(UpdateTripsFromTripAction(this.trip)); 
                        Navigator.pop(context, oldName);

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
            content: Text(
              'Button moved to separate widget',
              style: TextStyle(
                fontSize: 18
              )),
            duration: Duration(seconds: 2),
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
                StoreProvider.of<AppState>(context).dispatch(UpdateTripsDestinationAction(this.tripId, data)); 
                Scaffold.of(builderContext).showSnackBar(SnackBar(
                  content: Text(
                        '${data['destination_name']}\'s has been added',
                          style: TextStyle(
                            fontSize: 18
                          )
                        ),
                        duration: Duration(seconds: 2)
                      )
                    )
                  ;
              });
            } else if(response.exists == true){
              setState(() {
                Scaffold.of(builderContext).showSnackBar(SnackBar(content: Text(
                      '${data['destination_name']}\'s already exist for this trip.',
                       style: TextStyle(
                          fontSize: 18
                        )
                      ),
                      duration: Duration(seconds: 2)
                    )
                  );
              });
            }
          }
        },
        tooltip: 'Add destination',
        child: Icon(Icons.add),
        elevation: 5.0,
      )),
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
                                .showSnackBar(SnackBar(content: Text(
                                    '${destinations[index]['destination_name']}\'s dates updated',
                                      style: TextStyle(
                                        fontSize: 18
                                      )
                                    ),
                                    duration: Duration(seconds: 2)
                                  )
                                );
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
                                    duration: Duration(seconds: 2),
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
                            } else {
                              Scaffold
                              .of(listContext)
                              .showSnackBar(SnackBar(content: Text(
                                  'Unable to delete $name',
                                    style: TextStyle(
                                      fontSize: 18
                                    )
                                  ),
                                  duration: Duration(seconds: 2)
                                )
                              );
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
  final String error; 

  TripData({this.trip, this.destinations, this.error});

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      trip: json['trip'],
      destinations: json['destinations'],
      error:null
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
  bool loading = false;
  List<dynamic> destinations;
  dynamic trip;
  
  Future<TripData> data;
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


  TripState({
    this.onPush,
    this.tripId
  });

  bottomSheetModal(BuildContext topcontext, dynamic data){
    
  return showModalBottomSheet(context: topcontext,
    builder: (BuildContext context) {
      return new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new ListTile(
            leading: new Icon(Icons.card_travel),
            title: new Text('Edit trip name'),
            onTap: () async {
              Navigator.pop(context);
              var oldName = await showGeneralDialog(
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
              if(oldName != null && oldName is String){
                Scaffold.of(topcontext).showSnackBar(SnackBar(
                    content: Text(
                      '$oldName has been changed to ${this.trip['name']}',
                      style: TextStyle(
                        fontSize: 18
                      )
                    ),
                    duration: Duration(seconds: 2),
                  )
                );
              }
              
            }   
          ),
          new ListTile(
            leading: new Icon(Icons.pin_drop),
            title: new Text('Edit destinations'),
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

    return StoreConnector <AppState, Store<AppState>>(
      converter: (store) => store,
      onInit: (store) async {
        if(store.state.currentUser != null){
          data = fetchTrip(store, this.tripId);
          // data.then((data){
          //   this.color = Color(hexStringToHexInt(data.trip['color']));
          //   this.destinations = data.destinations;
          //   this.trip = data.trip;
          //   this.trip['destinations'] = this.destinations;
          // });
        }
      },
      builder: (context, store){
        return Scaffold(
          floatingActionButton: !store.state.offline ? FloatingActionButton(
            backgroundColor: this.color,
            onPressed: () { 
              bottomSheetModal(context, this.trip);
            },
            tooltip: 'Edit trip',
            child: SvgPicture.asset(
              'images/edit-icon.svg',
              width: 30,
              height: 30
            ),
            elevation: 5.0,
          ) : null,
          body: FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return _buildLoadingBody(context);
              } else if(snapshot.hasData && snapshot.data.error == null){
                return _buildLoadedBody(context,snapshot);
              } else if(snapshot.hasData && snapshot.data.error != null){
                return ErrorContainer(
                  color: Color.fromRGBO(106,154,168,1),
                  onRetry: () {
                    setState(() {
                      data =  fetchTrip(store,this.tripId); 
                    });
                  },
                );
              }
              return _buildLoadingBody(context);
            }
          )
        );
      }
    );
  }
  

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {

    this.trip = snapshot.data.trip;
    var name = snapshot.data.trip['name'];
    //this.name = name;
    this.destinations = snapshot.data.destinations;
    this.trip['destinations'] = this.destinations;
    var destTable = new Collection<dynamic>(destinations);
    var result2 = destTable.groupBy<dynamic>((destination) => destination['country_id']);
    this.color = Color(hexStringToHexInt(snapshot.data.trip['color']));
    var iconColor = Color.fromRGBO(0, 0, 0, 0.5);
    var fields = [
      {"label":"Flights and accommodation", "icon": Icon(Icons.flight, color: iconColor)},
    ];
 
    for (var group in result2.asIterable()) {
      var key = group.key;
      for (var destination in group.asIterable()) {
        fields.addAll([
          {"label":"Itinerary for ${destination['destination_name']}", "icon": Icon(Icons.map, color: iconColor), "level":"itinerary/edit", "destination": destination},
          {"label":"Activities in ${destination['destination_name']}", "icon": Icon(Icons.local_activity, color: iconColor), "id":destination['destination_id'].toString(), "level": destination['level'].toString()}
        ]);
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
            backgroundColor: this._showTitle ? color : Colors.white,
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
                    child: new Swiper(
                      itemBuilder: (BuildContext context,int index){
                        var startDate = new DateFormat.yMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destinations[index]['start_date']*1000));
                        var endDate = new DateFormat.yMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destinations[index]['end_date']*1000));
                        return Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            CachedNetworkImage(
                              placeholder: (context, url) => SizedBox(
                                width: 50, 
                                height:50, 
                                child: Align( alignment: Alignment.center, child:CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(color),
                                )
                              )),
                              imageUrl: destinations[index]['image'],
                              fit: BoxFit.cover,
                            ),
                            Container(
                              color:Colors.black.withOpacity(0.5)
                            ),
                            Positioned(
                              left: 0,
                              top: 180,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:<Widget>[
                                   Text(name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w300
                                    )
                                  ),
                                  Text('${destinations[index]['destination_name']}, ${destinations[index]['country_name']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w300
                                    )
                                  ),
                                  Text('$startDate - $endDate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300
                                    )
                                  )
                                ]
                              )
                            ),

                          ]
                        );
                      },
                      loop: true,
                      indicatorLayout: PageIndicatorLayout.SCALE,
                      itemCount: destinations.length,
                      //index: 0,
                      //transformer: DeepthPageTransformer(),
                      pagination: new SwiperPagination(
                        builder: new SwiperCustomPagination(builder:
                        (BuildContext context, SwiperPluginConfig config) {
                          return new ConstrainedBox(
                            child: new Align(
                                alignment: Alignment.bottomCenter,
                                child: new DotSwiperPaginationBuilder(
                                        color: Colors.white,
                                        activeColor: color,
                                        size: 20.0,
                                        activeSize: 20.0)
                                    .build(context, config),
                            ),
                            constraints: new BoxConstraints.expand(height: 50.0),
                          );
                        }),
                      ),
                    ),
                  ),
                  
                ]
              )
            ),
          ),
        ];
      },
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ListView(
            children: <Widget>[
              ListView.separated(
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.all(0),
                itemCount: fields.length,
                separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
                itemBuilder: (BuildContext context, int index){
                  return ListTile(
                    onTap: () async {
                      dynamic destination = fields[index]['destination'];
                      if(fields[index]['id'] != null){
                        onPush({'id': fields[index]['id'].toString(), 'level': fields[index]['level'].toString()});
                      } else if(destination['itinerary_id'].isEmpty && fields[index]['level'] == 'itinerary/edit'){
                        var store =  StoreProvider.of<AppState>(context);
                        dynamic data = {
                          "itinerary":{
                            "name": trip['name'],
                            "destination": destination['destination_id'],
                            "destination_name": destination['destination_name'],
                            "destination_country_name": destination['country_name'],
                            "destination_country": destination['country_id'],
                            "location": destination['location'],
                            "start_date": destination['start_date'],
                            "end_date": destination['end_date'],
                            "trip_id": trip['id']
                          },
                          "trip_destination_id": destination['id']
                          
                        };
                        setState(() {
                          this.loading = true;                     
                        });
                        var response = await postCreateItinerary(store, data);
                        setState(() {
                          this.loading = false;   
                          destination['itinerary_id'] = response.id;                  
                        });
                        onPush({'id': response.id, 'level': fields[index]['level'].toString()});
                      } else if(!destination['itinerary_id'].isEmpty){
                        onPush({'id': destination['itinerary_id'].toString(), 'level': fields[index]['level'].toString()});
                      }
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
          ),
          this.loading ? Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(color)
            ),
          ) : Container()
        ],
      )
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

    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
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
          primary: false,
          children: <Widget>[
            
            ListView.separated(
              shrinkWrap: true,
              primary: false,
              padding: EdgeInsets.all(0),
              itemCount: 4,
              separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
              itemBuilder: (BuildContext context, int index){
                double width = 300;
                if(index == 0){
                  width = 240;
                }
                if(index == 1){
                  width = 280;
                }
                return ListTile(
                  trailing: Shimmer.fromColors(
                    baseColor: Color.fromRGBO(220, 220, 220, 0.8),
                    highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color:Color.fromRGBO(240, 240, 240, 1),
                        borderRadius: BorderRadius.circular(100)
                      ),
                    )
                  ),
                  title: Shimmer.fromColors(
                    baseColor: Color.fromRGBO(220, 220, 220, 0.8),
                    highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child:Container(
                      color: Color.fromRGBO(240, 240, 240, 1),
                      height: 25,
                      width: width
                    )),
                  )
                );
              }
            )
          ]
        ) 
      ),
    );
  }
}