import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';




Future<List> fetchSearch(String query) async {
  var response = await http.get('http://localhost:3002/api/search/find/$query', headers:{'Authorization':'security'});
  
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    var data = SearchData.fromJson(json.decode(response.body));

    return data.results;

  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

class SearchData {
  final List<dynamic> results; 

  SearchData({this.results});

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      results: json['results'],
    );
  }
}


Future<CreateTripData> postCreateTrip(dynamic data) async {
  final response = await http.post('http://localhost:3002/api/trips/create/', body: data, headers:{'Authorization':'security',"Content-Type": "application/json"});
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return CreateTripData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

class CreateTripData {
  final Map<String, dynamic> trip; 
  final List<dynamic> destIds; 

  CreateTripData({this.trip, this.destIds});

  factory CreateTripData.fromJson(Map<String, dynamic> json) {
    return CreateTripData(
      trip: json['doc'],
      destIds: json['dest_ids']
    );
  }
}


class CreateTrip extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  CreateTrip({Key key, this.onPush}) : super(key: key);
  @override
  CreateTripState createState() => new CreateTripState(onPush:this.onPush);
}



class CreateTripState extends State<CreateTrip> {
  bool _showTitle = false;
  final ValueChanged<dynamic> onPush;
  GoogleMapController mapController;
  
  Future<CreateTripData> data;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //final TextEditingController _typeAheadController = TextEditingController();
  
  List<dynamic> _destinations = [];
  List<dynamic> _destinationImages = [];
  String name;
  var destinationsCount = 0;
  List<Widget> fields;
  final nameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    nameController.dispose();
    super.dispose();
  }

  _printLatestValue() {
    this.name = nameController.text;
  }


  @override
  void initState() {
    nameController.addListener(_printLatestValue);
    this.fields = [
      _buildDestField(0),
      Container(
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child:IconButton(
          icon: Icon(Icons.add),
          tooltip: 'Add Destination',
          onPressed: () { 
            setState(() { 
              this.destinationsCount = this.destinationsCount + 1;
              this.fields.insert(this.destinationsCount - 1, _buildDestField(this.destinationsCount - 1));
            }); 
          },
        )
      ),
      _buildDivider(),
      Container(
        margin:EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical:20.0),
            prefixIcon: Padding(padding:EdgeInsets.only(left:20.0, right: 5.0), child:Icon(Icons.label)), 
            fillColor: Colors.blueGrey.withOpacity(0.5),
            filled: true,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(
                width: 1.0,
                color: Colors.red
              )
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(
                width: 1.0,
                color: Colors.red
              )
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(
                width: 0.0,
                color: Colors.transparent
              )
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide: BorderSide(
                width: 0.0,
                color: Colors.transparent
              )
            ),
            hintText: 'Name your trip',
          ),
          controller: nameController,
          onSaved: (String value) {
            // This optional block of code can be used to run
            // code when the user saves the form.
            print(value);

          },
          validator: (value) {
            if (value.isEmpty) {
              return 'Please name your trip.';
            }
          },
        )
      ),
      Align(
        alignment:Alignment.center, 
        child:Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          width: 200,
          child: FlatButton(
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
            padding: EdgeInsets.symmetric(vertical: 10),
            onPressed: () async {
              // Validate will return true if the form is valid, or false if
              // the form is invalid.
              if (this._formKey.currentState.validate()) {
                // If the form is valid, display a snackbar. In the real world, you'd
                // often want to call a server or save the information in a database
                print(this._destinations);
                print(this._destinationImages);
                print(this.name);
                var data = {
                  "trip":{
                    "image": this._destinationImages[0],
                    "name": this.name
                  },
                  "destinations": this._destinations
                };
                var response = await postCreateTrip(json.encode(data));
                print(response);
                Scaffold
                    .of(context)
                    .showSnackBar(SnackBar(content: Text('Processing Data')));
              }
            },
            child: Text(
              'Submit', 
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w300
              )
            ),
          )
        )
      )
    ];
    this.destinationsCount = this.destinationsCount + 1;
    super.initState();    
  }

  CreateTripState({
    this.onPush,
  });

  


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: _buildForm(context)
    );
      
  }

   _buildDestField(int index) {
    TextEditingController _typeAheadController = TextEditingController();
    var dateFormat = DateFormat("EEE, MMM d, yyyy");
    return Column(
      children: <Widget>[
        Container(
          margin:EdgeInsets.symmetric(horizontal: 20),
          child:TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _typeAheadController,
              decoration: InputDecoration(
                hintText: 'Destination',
                contentPadding: EdgeInsets.symmetric(vertical:20.0),
                prefixIcon: Padding(padding:EdgeInsets.only(left:20.0, right: 5.0), child:Icon(Icons.pin_drop)), 
                fillColor: Colors.blueGrey.withOpacity(0.5),
                filled: true,
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  borderSide: BorderSide(
                    width: 1.0,
                    color: Colors.red
                  )
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  borderSide: BorderSide(
                    width: 1.0,
                    color: Colors.red
                  )
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  borderSide: BorderSide(
                    width: 0.0,
                    color: Colors.transparent
                  )
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  borderSide: BorderSide(
                    width: 0.0,
                    color: Colors.transparent
                  )
                ),
              )
            ),
            debounceDuration: Duration(milliseconds:500),   
            suggestionsCallback: (pattern) async {
              return await fetchSearch(pattern);
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text(
                  suggestion['country_id'] == 'United_States' ? '${suggestion['name']}, ${suggestion['parent_name']}' :'${suggestion['name']}, ${suggestion['country_name']}',
                ),
                //subtitle: Text('\$${suggestion['price']}'),
              );
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            onSuggestionSelected: (suggestion) {
              _typeAheadController.text = suggestion['country_id'] == 'United_States' ? '${suggestion['name']}, ${suggestion['parent_name']}' :'${suggestion['name']}, ${suggestion['country_name']}';
              /*if(this._destinations.length > 0){
                this._destinations[index]['location'] = suggestion['location'];
                this._destinations[index]['destination_id'] = suggestion['destination_id'];
                this._destinations[index]['destination_name'] = suggestion['destination_name'];
                this._destinations[index]['level'] = suggestion['level'];
                this._destinations[index]['country_id'] = suggestion['country_id'];
                this._destinations[index]['country_name'] = suggestion['country_name'];
                this._destinationImages[index] = suggestion['image'];
              } else {*/
                this._destinations.insert(index,{
                  "location": suggestion['location'],
                  "destination_id": suggestion['id'],
                  "destination_name": suggestion['name'],
                  "level": suggestion['level'],
                  "country_id": suggestion['country_id'],
                  "country_name": suggestion["country_name"],
                });
                this._destinationImages.insert(index, suggestion["image"]);
              //}
              
            },
            validator: (value) {
              if (value.isEmpty) {
                return 'Please select a destination';
              }
            },
          )
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child:Container(
                margin:EdgeInsets.only(left: 20.0, right:10, top: 20.0, bottom:0),
                child:DateTimePickerFormField(
                  format: dateFormat,
                  dateOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Arrival date', 
                    contentPadding: EdgeInsets.symmetric(vertical:20.0),
                    prefixIcon: Padding(padding:EdgeInsets.only(left:20.0, right: 5.0), child:Icon(Icons.calendar_today)), 
                    fillColor: Colors.blueGrey.withOpacity(0.5),
                    filled: true,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(
                        width: 1.0,
                        color: Colors.red
                      )
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(
                        width: 1.0,
                        color: Colors.red
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(
                        width: 0.0,
                        color: Colors.transparent
                      )
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(
                        width: 0.0,
                        color: Colors.transparent
                      )
                    ),
                  ),
                  onChanged: (dt){ 
                    setState(() { 
                      if(this._destinations.length > 0 && dt != null){
                        this._destinations[index]['start_date'] = dt.millisecondsSinceEpoch/1000;
                        this._destinations[index]['start_date'] = this._destinations[index]['start_date'].toInt();
                      } else if(dt != null) {
                        this._destinations.insert(index,{
                          "start_date": dt.millisecondsSinceEpoch/1000.toInt(),
                        });
                        this._destinations[index]['start_date'] = this._destinations[index]['start_date'].toInt();
                      }
                  
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an arrival date';
                    }
                  },
                )
              )
            ),
            Flexible(
              child:Container(
                margin:EdgeInsets.only(left: 10.0, right:20, top: 20.0, bottom:0),
                child: DateTimePickerFormField(
                  format: dateFormat,
                  dateOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Departure date', 
                    contentPadding: EdgeInsets.symmetric(vertical:20.0),
                    prefixIcon: Padding(padding:EdgeInsets.only(left:20.0, right: 5.0), child:Icon(Icons.calendar_today)), 
                    fillColor: Colors.blueGrey.withOpacity(0.5),
                    filled: true,
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(
                        width: 1.0,
                        color: Colors.red
                      )
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(
                        width: 1.0,
                        color: Colors.red
                      )
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(
                        width: 0.0,
                        color: Colors.transparent
                      )
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide(
                        width: 0.0,
                        color: Colors.transparent
                      )
                    ),
                  ),
                  onChanged: (dt){
                    setState(() {
                      if(this._destinations.length > 0 && dt != null){
                        this._destinations[index]['end_date'] = dt.millisecondsSinceEpoch/1000;
                        this._destinations[index]['end_date'] = this._destinations[index]['end_date'].toInt();
                      } else if(dt != null) {
                        this._destinations.insert(index,{
                          "end_date": dt.millisecondsSinceEpoch/1000.toInt(),
                        });
                        this._destinations[index]['end_date'] = this._destinations[index]['end_date'].toInt();
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a departure date';
                    }
                  },
                )
              )
            ),
          ],
        ),
        _buildDivider()
      ]
    );
  }

  
  _buildDivider(){
    return Container(
          margin: EdgeInsets.only(top:20, left: 20, right: 20, bottom:20),
          child:Divider(color: Color.fromRGBO(0, 0, 0, 0.3))
        );
  }
  

// function for rendering view after data is loaded
  Widget _buildForm(BuildContext ctxt) {
    final ScrollController _scrollController = ScrollController();
    var kExpandedHeight = 300;


    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    

    var color = Colors.blueGrey;
  
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: _showTitle ? color : Colors.transparent,
            automaticallyImplyLeading: false,
            leading: IconButton(
              padding: EdgeInsets.all(0),
              icon:  Icon(Icons.close),
              onPressed: () {  Navigator.pop(context);},
              iconSize: 30,
              color: Colors.white,
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
                        'images/home_bg.jpeg',
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
                        Text('Create a trip',
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
      body: Form(
        key: this._formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal:0.0, vertical: 0),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: this.fields.length,
            itemBuilder: (_, int index){
              return this.fields[index];
            }
          )
        )
      )  
    ); 
  }
}