import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:core';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';

class CreateTrip extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  final dynamic param;
  CreateTrip({Key key, this.onPush, this.param}) : super(key: key);
  @override
  CreateTripState createState() => new CreateTripState(onPush:this.onPush, param:this.param);
}



class CreateTripState extends State<CreateTrip> {
  bool _showTitle = false;
  final ValueChanged<dynamic> onPush;
  final dynamic param;
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


  @override
  void initState() {
    if(this.param != null){
      var destination = {
        "location": this.param['location'],
        "destination_id": this.param['id'],
        "destination_name": this.param['name'],
        "level": this.param['level'],
        "country_id": this.param['country_id'],
        "country_name": this.param["country_name"],
        "start_date": null,
        "end_date": null,
      };
      this._destinations.add(destination);
      this._destinationImages.add(this.param['image']);
    }
    this.destinationsCount = this.destinationsCount + 1;
    super.initState();    
  }

  CreateTripState({
    this.onPush,
    this.param
  });

  


  @override
  Widget build(BuildContext context) {
    return StoreConnector <AppState, TripViewModel>(
      converter: (store) => TripViewModel.create(store),
      builder: (context, viewModel)=> new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: _buildForm(context, viewModel)
      )
    );
      
  }

   _buildDestField(int index,[dynamic param]) {
    TextEditingController _typeAheadController = TextEditingController();
    var dateFormat = DateFormat("EEE, MMM d, yyyy");
    if(param != null)
      _typeAheadController.text = param['country_id'] == 'United_States' ? '${param['name']}, ${param['parent_name']}' :'${param['name']}, ${param['country_name']}';
    return Column(
      children: <Widget>[
        Container(
          margin:EdgeInsets.symmetric(horizontal: 20),
          child:InkWell(
            child: IgnorePointer(
              ignoring:true, 
              child: TextFormField(
                enabled: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical:20.0),
                  prefixIcon: Padding(
                    padding:EdgeInsets.only(left:20.0, right: 5.0), 
                    child:Icon(Icons.label)
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
                  disabledBorder: OutlineInputBorder(
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
                  hintText: 'Destination',
                ),
                controller: _typeAheadController,
                validator: (value) {
                  if (value.isEmpty) {
                    print('here');
                    return 'Please select a destination';
                  }
                },
        
              )
            ),
            onTap: () async {
              var suggestion = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => SearchModal(query:'')),);
              print(suggestion);
              if(suggestion != null){
                _typeAheadController.text = suggestion['country_id'] == 'United_States' ? '${suggestion['name']}, ${suggestion['parent_name']}' :'${suggestion['name']}, ${suggestion['country_name']}';
                if(this._destinations.length > 0 && this._destinations[index] != null) {
                  this._destinations.replaceRange(index,index+1,[{
                    "location": suggestion['location'],
                    "destination_id": suggestion['id'],
                    "destination_name": suggestion['name'],
                    "level": suggestion['level'],
                    "country_id": suggestion['country_id'],
                    "country_name": suggestion["country_name"],
                    "start_date": this._destinations[index]['start_date'] != null ? this._destinations[index]['start_date'] : null,
                    "end_date": this._destinations[index]['end_date'] != null ? this._destinations[index]['end_date'] : null,
                  }]);

                } else {
                  this._destinations.insert(index,{
                    "location": suggestion['location'],
                    "destination_id": suggestion['id'],
                    "destination_name": suggestion['name'],
                    "level": suggestion['level'],
                    "country_id": suggestion['country_id'],
                    "country_name": suggestion["country_name"],
                    "start_date":  null,
                    "end_date": null,
                  });
                }
                this._destinationImages.insert(index, suggestion["image"]);
              }
            }
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
                  firstDate: DateTime.now(),
                  decoration: InputDecoration(
                    hintText: 'Arrival date', 
                    contentPadding: EdgeInsets.symmetric(vertical:20.0),
                    prefixIcon: Padding(padding:EdgeInsets.only(left:20.0, right: 5.0), child:Icon(Icons.calendar_today, size: 18)), 
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
                    setState(() { 
                      if(this._destinations.length > 0 && dt != null){
                        var startDate = dt.millisecondsSinceEpoch/1000;
                        this._destinations[index]['start_date'] = startDate.toInt();
                        //print(this._destinations[index]['name']);
                      } else if(dt != null) {
                        print(this._destinations[index]['name']);
                        var startDate = dt.millisecondsSinceEpoch/1000;
                        this._destinations.insert(index,{
                          "start_date": startDate.toInt(),
                        });
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
                  firstDate: DateTime.now(),
                  decoration: InputDecoration(
                    hintText: 'Departure date', 
                    contentPadding: EdgeInsets.symmetric(vertical:20.0),
                    prefixIcon: Padding(padding:EdgeInsets.only(left:20.0, right: 5.0), child:Icon(Icons.calendar_today, size:18)), 
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
                    setState(() {
                      if(this._destinations.length > 0 && dt != null){
                        var endDate = dt.millisecondsSinceEpoch/1000;
                        this._destinations[index]['end_date'] = endDate.toInt();
                      } else if(dt != null) {
                        var endDate = dt.millisecondsSinceEpoch/1000;
                        this._destinations.insert(index,{
                          "end_date": endDate.toInt(),
                        });
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a departure date';
                    } else if(this._destinations[index]['end_date'] < this._destinations[index]['start_date']){
                      return "Please choose a later departure date";
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
  Widget _buildForm(BuildContext ctxt, TripViewModel viewModel) {
    this.fields = [
      _buildDestField(0,this.param),
      Align(
        alignment:Alignment.center, 
        child:Container(
          margin: EdgeInsets.symmetric(vertical: 0.0),
          child:FlatButton(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.add, size:25),
                  Text(
                    ' Add destination',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300
                    )
                  )
              ]
            ),
            onPressed: () { 
              setState(() { 
                this.destinationsCount = this.destinationsCount + 1;
                this.fields.insert(this.destinationsCount - 1, _buildDestField(this.destinationsCount - 1));
              }); 
            },
          )
        )
      ),
      _buildDivider(),
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
          margin: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          width: double.infinity,
          child: FlatButton(
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
            padding: EdgeInsets.symmetric(vertical: 15),
            color: Colors.blueGrey,
            onPressed: () async {
              // Validate will return true if the form is valid, or false if
              // the form is invalid.
              if (this._formKey.currentState.validate()) {
                // If the form is valid, display a snackbar. In the real world, you'd
                // often want to call a server or save the information in a database
                var data = {
                  "trip":{
                    "image": this._destinationImages[0],
                    "name": this.name
                  },
                  "destinations": this._destinations
                };
                var response = await viewModel.onCreateTrip(data);
                Scaffold
                    .of(context)
                    .showSnackBar(SnackBar(
                      content: Text(
                        'Trip created!',
                        style: TextStyle(
                            fontSize: 18
                          )
                        )
                      )
                    );
                onPush({"id": response.trip['id'].toString(),"level":"trip", 'from':'createtrip'});
              }
            },
            child: Text(
              'Create trip', 
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w300,
                color: Colors.white
              )
            ),
          )
        )
      )
    ];
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