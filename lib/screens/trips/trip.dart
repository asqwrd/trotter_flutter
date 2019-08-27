import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/itineraries/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/store/trips/middleware.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/cannot-view.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:queries/collections.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'add-destination-modal.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share/share.dart';
import 'package:trotter_flutter/widgets/travelers/travelers-modal.dart';
import 'package:trotter_flutter/globals.dart';





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
              child: AutoSizeText(
                'Arrival and Departure',
                style: TextStyle(
                  fontSize: 20,
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
  final store = Provider.of<TrotterStore>(context);
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
            inputType: InputType.date,
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
              return null;
            },
          )
        ),
        Container(
          margin:EdgeInsets.only(left: 20.0, right:20, top: 20.0, bottom:0),
          child: DateTimePickerFormField(
            format: dateFormat,
            inputType: InputType.date,
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
              return null;
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
              child: AutoSizeText(
                'Change date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.white
                )
              )
            ),
            onPressed: () async {
              if(_formKey.currentState.validate() && store.tripStore.tripLoading == false){
                destination["start_date"] =  arrival;
                destination["end_date"] = departure;
                store.tripStore.setTripsLoading(true); 
                var response = await putUpdateTripDestination(tripId, destination['id'], destination);
                if(response.success == true){
                    destination["start_date"] =  arrival;
                    destination["end_date"] = departure;
                    Navigator.pop(context,{"arrival": arrival, "departure": departure});   
                }
                store.tripStore.setTripsLoading(false); 

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
              child:AutoSizeText(
                'Close',
                style: TextStyle(
                  fontSize: 18,
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

Future<TripData> fetchTrip(String id, [TrotterStore store]) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
    final response = await http.get('$ApiDomain/api/trips/get/$id', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      await prefs.setString('trip_$id', response.body);
      var tripData = json.decode(response.body);
      store?.setOffline(
          false,
      );
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
      store?.setOffline(
          true,
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
    this.travelers,
    this.controller,
    @required this.tripId
  }): super(key: key);
  final dynamic trip;
  final List<dynamic> travelers;
  final String tripId;
  final Color color;
  final TextEditingController controller;
  @override
  _TripNameDialogContentState createState() => new _TripNameDialogContentState(controller: this.controller,color: this.color, tripId: this.tripId, trip: this.trip, travelers: this.travelers);

}

class _TripNameDialogContentState extends State<TripNameDialogContent> {
  _TripNameDialogContentState({this.color,this.tripId,this.trip, this.travelers, this.controller});
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  
  final dynamic trip;
  final TextEditingController controller;
  final List<dynamic> travelers;
  final String tripId;
  final Color color;
  Form _form; 

  @override
  void initState(){
    this.controller.text = this.trip['name'];
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }



   @override
  Widget build(BuildContext context) {
    print(_form);
    if(_form == null) {
      _form = _createForm(context);
    }

    return _form;
  }

  _createForm(BuildContext context){
    final store = Provider.of<TrotterStore>(context);
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal:0.0, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top:20, bottom: 30),
              child:AutoSizeText(
              'Update trip name',
              style: TextStyle(
                fontSize: 18,
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
                controller: this.controller,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please name your trip.';
                  }
                  return null;
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
                  child: AutoSizeText(
                    'Update',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Colors.white
                    )
                  )
                ),
                onPressed: () async {
                  print(_formKey.currentState.validate());
                  if(_formKey.currentState.validate() ){
                    var response = await putUpdateTrip(tripId, {"name": this.controller.text}, store.currentUser.uid);
                    print(response.success);
                    if(response.success == true){
                      setState(() {
                        var oldName = this.trip['name'];
                        this.trip['name'] = this.controller.text;
                        this.trip['travelers'] = this.travelers;
                        store.tripStore.updateTrip(this.trip); 
                        Navigator.pop(context, {"oldName": oldName, "trip": this.trip});

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
                  child:AutoSizeText(
                    'Close',
                    style: TextStyle(
                      fontSize: 18,
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
      child: AutoSizeText("Button moved to separate widget"),
      onPressed: () {
        Scaffold.of(context).showSnackBar(SnackBar(
            content: AutoSizeText(
              'Button moved to separate widget',
              style: TextStyle(
                fontSize: 13
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
  AddDestinationModal destinationModal;
  final List<dynamic> destinations;
  final String tripId;
  final Color color;
  @override
  void initState(){
    setState(() {
      destinationModal = AddDestinationModal(tripId: this.tripId,color: this.color);

    });
    super.initState();
  }
  

  

   @override
  Widget build(BuildContext context) {
    final store = Provider.of<TrotterStore>(context);
    return Scaffold(
      floatingActionButton: Builder( builder: (BuildContext builderContext) => FloatingActionButton(
        backgroundColor: this.color,
        onPressed: () async { 
          var data = 
           await showGeneralDialog(
            context: builderContext,
            pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
              return Dialog(
                child: destinationModal
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
            var response = await postAddToTrip(this.tripId, data, store.currentUser.uid);
            if(response.destination != null) {
              data['id'] = response.destination['ID'];
              setState(() {
                this.destinations.add(data);
                store.tripStore.updateTripDestinations(this.tripId, data); 
                Scaffold.of(builderContext).showSnackBar(SnackBar(
                  content: AutoSizeText(
                        '${data['destination_name']}\'s has been added',
                          style: TextStyle(
                            fontSize: 13
                          )
                        ),
                        duration: Duration(seconds: 2)
                      )
                    )
                  ;
              });
            } else if(response.exists == true){
              setState(() {
                Scaffold.of(builderContext).showSnackBar(SnackBar(content: AutoSizeText(
                      '${data['destination_name']}\'s already exist for this trip.',
                       style: TextStyle(
                          fontSize: 13
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
        elevation: 1,
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        title: AutoSizeText(
          'Destinations',
          textAlign: TextAlign.left,
          style:TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                          fontSize: 19),
        ),
        centerTitle: false,
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
            subtitle: AutoSizeText(
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
                          title: new AutoSizeText(
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
                                .showSnackBar(SnackBar(content: AutoSizeText(
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
                          title: new AutoSizeText(
                            'Delete $name',
                          ),
                          onTap: () async {
                            var response = await deleteDestination(this.tripId, this.destinations[index]['id'], store.currentUser.uid);
                            if(response.success == true){
                              
                              setState(() {
                                var undoDestination = this.destinations[index];
                                store.tripStore.removeTripDestinations(this.tripId, this.destinations[index]);
                                this.destinations.removeAt(index);
                                
                                Scaffold
                                .of(listContext)
                                .showSnackBar(
                                  SnackBar(
                                    content: AutoSizeText(
                                      '$name\'s was deleted.',
                                      style: TextStyle(
                                        fontSize: 15
                                      )
                                    ),
                                    duration: Duration(seconds: 5),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      textColor: this.color,
                                      onPressed: () async {
                                        var response = await postAddToTrip(this.tripId, undoDestination, store.currentUser.uid);
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
                              .showSnackBar(SnackBar(content: AutoSizeText(
                                  'Unable to delete $name',
                                    style: TextStyle(
                                      fontSize: 15
                                    )
                                  ),
                                  duration: Duration(seconds: 5)
                                )
                              );
                            }
                            Navigator.pop(modalcontext);
                          }        
                        ),
                      ]
                    );
                  }
                );
              },
              icon:Icon(Icons.more_vert)
            ),
            title: AutoSizeText(
              destinations[index]['destination_name'],
              style: TextStyle(
                fontSize: 20,
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
  final List<dynamic> travelers;
  final String error; 

  TripData({this.trip, this.destinations, this.travelers, this.error});

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      trip: json['trip'],
      destinations: json['destinations'],
      travelers: json['travelers'],
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
  final ValueChanged<dynamic> onPush;
  final String tripId;
  Color color = Colors.blueGrey;
  bool loading = false;
  List<dynamic> destinations;
  dynamic trip;
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  String image;
  String tripName;
  dynamic travelers;
  TripNameDialogContent _nameDialog;
  TripDestinationDialogContent destinationDialog;
  static final TextEditingController _nameControllerModal = TextEditingController();
  TrotterStore store;

  
  Future<TripData> data;
  bool canView = true;

   

  @override
  void initState() {
      _sc.addListener(() {
      setState(() {
        if (_pc.isPanelOpen()) {
          disableScroll = _sc.offset <= 0;
        }
      });
    });
    data = fetchTrip(this.tripId);
    data.then((data){
        setState((){
          this.canView = data.travelers.any((traveler)=>store.currentUser.uid == traveler['uid']);
          this.color = Color(hexStringToHexInt(data.trip['color']));
          this.destinations = data.destinations;
          this.travelers = data.travelers;
          this.trip = data.trip;
          this.trip['destinations'] = this.destinations;
          this.tripName = data.trip['name'];
          _nameControllerModal.text = this.tripName;
          _nameDialog = TripNameDialogContent(tripId:this.tripId, trip:this.trip, color:this.color, travelers: this.travelers, controller: _nameControllerModal,);
          this.destinationDialog = TripDestinationDialogContent(color: color, tripId: this.tripId, destinations:destinations);
        });
      
      
    });
    super.initState();
    
  }

  @override
  void dispose(){
    _sc.dispose();
    super.dispose();
  }


  TripState({
    this.onPush,
    this.tripId
  });

  bottomSheetModal(BuildContext topcontext, dynamic data){
    
  return showModalBottomSheet(context: topcontext,
    builder: (BuildContext buildercontext) {
      return new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
         this.trip['owner_id'] == store.currentUser.uid ? ListTile(
            leading: new Icon(Icons.card_travel),
            title: new AutoSizeText('Edit trip name'),
            onTap: () async {
              Navigator.pop(buildercontext);
              var data = await showGeneralDialog(
                context: buildercontext,
                pageBuilder: (BuildContext buildContext, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                  return Dialog(
                    child: _nameDialog
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

              if(data['trip'] != null){
                setState(() {
                  this.tripName = data['trip']['name'];
                 });
              }
          
              if(data['oldName'] != null){
                 var oldName = data['oldName'];
                Scaffold.of(topcontext).showSnackBar(SnackBar(
                    content: AutoSizeText(
                      '$oldName has been changed to ${this.trip['name']}',
                      style: TextStyle(
                        fontSize: 13
                      )
                    ),
                    duration: Duration(seconds: 2),
                  )
                );
              }
              
            }   
          ) : Container(),
          this.trip['owner_id'] == store.currentUser.uid ? ListTile(
            leading: new Icon(Icons.pin_drop),
            title: new AutoSizeText('Edit destinations'),
            onTap: () async { 
              Navigator.pop(context);
              await showDestinationsModal(context,this.destinations, this.color);
              setState(() {
               this.destinations = this.destinations; 
              });

            }        
          ) : Container(),
          ListTile(leading: Icon(Icons.share), title: AutoSizeText('Invite travelers'), onTap: (){
            Share.share('Lets plan our trip using Trotter. https://trotter.page.link/?link=http://ajibade.me?trip%3D${this.tripId}&apn=org.trotter.application');
            Navigator.pop(context);
          },)
        ]
      );
    }
  );
}



  


  @override
  Widget build(BuildContext context) {
    final double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    final double _bodyHeight = MediaQuery.of(context).size.height - 110;
    final double _panelHeightClosed = 100.0;
    if(store == null){
      store = Provider.of<TrotterStore>(context);
    }
   
    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingUpPanel(
        parallaxEnabled: true,
        parallaxOffset: .5,
        minHeight: errorUi == false && canView == true ? _panelHeightClosed : _panelHeightOpen,
        controller: _pc,
        backdropEnabled: true,
        backdropColor: color,
        backdropTapClosesPanel: false,
        backdropOpacity: .8,
        onPanelOpened: () {
          
          setState(() {
            disableScroll = false;
          });
        },
        onPanelClosed: () {
          setState(() {
            disableScroll = true;
          });
        },
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        maxHeight: _panelHeightOpen,
        panel: Center(
            child: Scaffold(
              resizeToAvoidBottomPadding: false,
          backgroundColor: Colors.transparent,
          body: FutureBuilder(
            future: data,
            builder: (context, snapshot) {
              
               if(snapshot.hasData && snapshot.data.error == null){
                 if(this.canView){
                return _buildLoadedBody(context,snapshot, store);
                 } else {
                   return CannotView();
                 }
              } else if(snapshot.hasData && snapshot.data.error != null){
                return ListView(
                  controller: _sc,
                  physics: disableScroll
                      ? NeverScrollableScrollPhysics()
                      : ClampingScrollPhysics(), 
                      shrinkWrap: true, 
                      children: <Widget>[
                        Container(
                          height: _panelHeightOpen - 80,
                          width: MediaQuery.of(context).size.width,
                          child: ErrorContainer(
                  color: Color.fromRGBO(106,154,168,1),
                  onRetry: () {
                    setState(() {
                      data =  fetchTrip(this.tripId, store); 
                       data.then((data){
                          setState((){
                            this.canView = data.travelers.any((traveler)=>store.currentUser.uid == traveler['uid']);
                            this.color = Color(hexStringToHexInt(data.trip['color']));
                            this.destinations = data.destinations;
                            this.travelers = data.travelers;
                            this.trip = data.trip;
                            this.trip['destinations'] = this.destinations;
                            this.tripName = data.trip['name'];
                            _nameControllerModal.text = this.tripName;
                            _nameDialog = TripNameDialogContent(tripId:this.tripId, trip:this.trip, color:this.color, travelers: this.travelers, controller: _nameControllerModal,);
                            this.destinationDialog = TripDestinationDialogContent(color: color, tripId: this.tripId, destinations:destinations);
                          });
                       });
                    });
                  },
                ))]);
              }
              return _buildLoadingBody(context);
            }
          )
        )
      
    ),
        body: Container(
            height: _bodyHeight,
            child: Stack(children: <Widget>[
               this.destinations == null ? Container() : Positioned.fill(
                    top: 0,
                    child: new Swiper(
                      itemBuilder: (BuildContext context,int index){
                        var startDate = new DateFormat.yMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destinations[index]['start_date']*1000));
                        var endDate = new DateFormat.yMMMd("en_US").format(new DateTime.fromMillisecondsSinceEpoch(destinations[index]['end_date']*1000));
                        return Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            TransitionToImage(
                          image: AdvancedNetworkImage(
                            this.destinations[index]['image'],
                            useDiskCache: true,
                            cacheRule:
                                CacheRule(maxAge: const Duration(days: 7)),
                          ),
                          loadingWidgetBuilder:
                              (BuildContext context, double progress, test) =>
                                  Center(
                                      child: RefreshProgressIndicator(
                            backgroundColor: Colors.white,
                          )),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: const Icon(Icons.refresh),
                          enableRefresh: true,
                        ),

                            Container(
                              color:Colors.black.withOpacity(0.5)
                            ),
                            Positioned(
                              left: 0,
                              top: (MediaQuery.of(context).size.height/2) - 110,
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:<Widget>[
                  
                                  AutoSizeText('${this.destinations[index]['destination_name']}, ${this.destinations[index]['country_name']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w300
                                    )
                                  ),
                                  AutoSizeText('$startDate - $endDate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
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
              this.destinations == null
                  ? Positioned(
                      child: Center(
                          child: RefreshProgressIndicator(
                      backgroundColor: Colors.white,
                    )))
                  : Container()
            ])),
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              onPush: onPush, color: color, title: this.tripName, back: true, actions: store.offline == false ? <Widget>[
              Container(
                  width: 58,
                  height: 58,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: FlatButton(
                    
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    onPressed: () { 
                      bottomSheetModal(context, this.trip);
                    },
                    child:  SvgPicture.asset("images/setting-icon.svg",
                          width: 35,
                          height: 35,
                          //color: fontContrast(color),
                          fit: BoxFit.cover),
                  ))
            ] : null)),
    ]);
  }
  

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot, TrotterStore store) {

    this.trip = snapshot.data.trip;
    this.destinations = snapshot.data.destinations;
    this.travelers = snapshot.data.travelers;
    this.trip['destinations'] = this.destinations;
    var destTable = new Collection<dynamic>(this.destinations);
    var result2 = destTable.groupBy<dynamic>((destination) => destination['country_id']);
    this.color = Color(hexStringToHexInt(snapshot.data.trip['color']));
    var iconColor = Color.fromRGBO(0, 0, 0, 0.5);
    var fields = [
      {"level":"travelers-modal","label": "${this.travelers.length} ${this.travelers.length != 1 ? 'people': 'person'} traveling", "icon":Container(width: MediaQuery.of(context).size.width/2, height:50, 
      child:InkWell(
        onTap: () async {
          await openTravelersModal(ctxt, store);
        }, 
        child:buildTravelers(this.travelers)))},
      {"label":"Travel details", "icon": Icon(Icons.flight, color: iconColor), "level":"travelinfo"},
    ];
 
    for (var group in result2.asIterable()) {
      var key = group.key;
      for (var destination in group.asIterable()) {
        fields.addAll([
          {"label":"Itinerary for ${destination['destination_name']}", "icon": Icon(Icons.map, color: iconColor), "level":"itinerary/edit", "destination": destination},
          {"label":"Activities in ${destination['destination_name']}", "icon": Icon(Icons.local_activity, color: iconColor), "id":destination['destination_id'].toString(), "level": destination['level'].toString()}
        ]);
      }
      
        fields.add(
          {"label":"Tips & requirements for ${group.asIterable().first['country_name']}", "icon": Icon(Icons.info_outline, color: iconColor), "id": key.toString(), "level":"country"}
        );
      
    }
  
    return Container(
      height: MediaQuery.of(ctxt).size.height, 
      child: ListView(
         controller: _sc,
            physics: disableScroll
                ? NeverScrollableScrollPhysics()
                : ClampingScrollPhysics(),
      children: <Widget>[
        Center(
                child: Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
            )),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: AutoSizeText(
                'Get Organized',
                style: TextStyle(fontSize: 25),
              ),
            ),
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
                } else if(destination != null && destination['itinerary_id'].isEmpty && fields[index]['route'] == 'itinerary/edit'){
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
                } else if(destination != null && !destination['itinerary_id'].isEmpty){
                  onPush({'id': destination['itinerary_id'].toString(), 'level': fields[index]['level'].toString()});
                } else if(fields[index]['level'] == 'travelinfo'){
                  onPush({'tripId':this.tripId, 'currentUserId': store.currentUser.uid,"level": "travelinfo"});
                }else if(fields[index]['level'] == 'travelers-modal'){
                  await openTravelersModal(ctxt, store);
                }
              },
              trailing: fields[index]['icon'],
              title: AutoSizeText(
                fields[index]['label'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300
                ),
              ),
                  
            );
          }
        )
      ]
    ));
  }

  Future openTravelersModal(BuildContext ctxt, TrotterStore store) async {
    var dialogData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) =>  TravelersModal(
              currentUserId: store.currentUser.uid,
                ownerId: this.trip['owner_id'],
                tripId: this.tripId, travelers: this.travelers)));
        
        if (dialogData != null) {
          final List<String> travelers = dialogData['travelers'];
          
          var response = await putUpdateTrip(tripId, {"group": travelers}, store.currentUser.uid);
            if(response.success == true){
              if(!travelers.contains(store.currentUser.uid)){
                await fetchTrips(store);
                Navigator.pop(context);
              } else{
                setState(() {
                  this.trip['group'] = travelers;
                  this.trip['travelers'] = response.travelers;
                  this.travelers = response.travelers;
                  store.tripStore.updateTrip(this.trip); 
                  data = fetchTrip(this.tripId);
      
                });
              }
            
            }
        }
  }

  showDestinationsModal(BuildContext context, dynamic destinations, Color color) {
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
        return destinationDialog;
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

    return Container(
        padding: EdgeInsets.only(top: 0.0),
        decoration: BoxDecoration(color: Colors.transparent),
        child: ListView(
          controller: _sc,
            physics:  NeverScrollableScrollPhysics(),
          children: <Widget>[
             Center(
                child: Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
            )),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: AutoSizeText(
                'Get Organized',
                style: TextStyle(fontSize: 25),
              ),
            ),
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
    );
  }
}