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


Future<CreateTripData> fetchCreateTrip(dynamic data) async {
  final response = await http.post('http://localhost:3002/api/trips/create/', body: data, headers:{'Authorization':'security'});
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
  var destinationsCount = 0;
  List<Widget> fields;

  @override
  void initState() {
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
              print(this.destinationsCount);
              this.fields.insert(this.destinationsCount - 1, _buildDestField(this.destinationsCount - 1));
              print(this.fields);
            }); 
          },
        )
      ),
      _buildDivider()
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

          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.5),
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ), 
          child:TypeAheadFormField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _typeAheadController,
              decoration: InputDecoration(
                hintText: 'Destination',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0)
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
              if(this._destinations.length > 0){
                this._destinations[index]['location'] = suggestion['location'];
                this._destinations[index]['destination_id'] = suggestion['destination_id'];
                this._destinations[index]['destination_name'] = suggestion['destination_name'];
                this._destinations[index]['level'] = suggestion['level'];
                this._destinations[index]['country_id'] = suggestion['country_id'];
                this._destinations[index]['country_name'] = suggestion['country_name'];
              } else {
                this._destinations.insert(index,{
                  "location": suggestion['location'],
                  "destination_id": suggestion['id'],
                  "destination_name": suggestion['name'],
                  "level": suggestion['level'],
                  "country_id": suggestion['country_id'],
                  "country_name": suggestion["country_name"],
                });
              }
              
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
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),  
                child:DateTimePickerFormField(
                  format: dateFormat,
                  dateOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Arrival date', 
                    contentPadding: EdgeInsets.all(20.0),
                    border: InputBorder.none
                  ),
                  onChanged: (dt){ 
                    setState(() { 
                      if(this._destinations.length > 0){
                        this._destinations[index]['start_date'] = dt;
                      } else {
                        this._destinations.insert(index,{
                          "start_date": dt,
                        });
                      }
                  
                    });
                  }
                )
              )
            ),
            Flexible(
              child:Container(
                margin:EdgeInsets.only(left: 10.0, right:20, top: 20.0, bottom:0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ), 
                child: DateTimePickerFormField(
                  format: dateFormat,
                  dateOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Departure date', 
                    contentPadding: EdgeInsets.all(20.0),
                    border: InputBorder.none
                  ),
                  onChanged: (dt) => setState(() {
                    print(dt); 
                    if(this._destinations.length > 0){
                      this._destinations[index]['end_date'] = dt;
                    } else {
                      this._destinations.insert(index,{
                        "end_date": dt,
                      });
                    }
                  }),
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
            leading: Icon(Icons.close),
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
      body: 
          Form(
            key: this._formKey,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal:0.0),
              child: ListView.builder(
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