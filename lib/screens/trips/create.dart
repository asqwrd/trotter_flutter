import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'dart:core';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/store/trips/middleware.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';

class CreateTrip extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  final dynamic param;
  CreateTrip({Key key, this.onPush, this.param}) : super(key: key);
  @override
  CreateTripState createState() =>
      new CreateTripState(onPush: this.onPush, param: this.param);
}

class CreateTripState extends State<CreateTrip> {
  final ValueChanged<dynamic> onPush;
  final dynamic param;
  GoogleMapController mapController;

  Future<CreateTripData> data;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //final TextEditingController _typeAheadController = TextEditingController();

  List<dynamic> _destinations = [];
  String name;
  var destinationsCount = 0;
  List<Widget> fields;
  final nameController = TextEditingController();
  bool loading;
  ScrollController _sc = new ScrollController();
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  Color color = Colors.blueGrey;

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    nameController.dispose();
    _sc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    loading = false;
    _sc.addListener(() {
      setState(() {
        if (_pc.isPanelOpen()) {
          disableScroll = _sc.offset <= 0;
        }
      });
    });
    this.fields = [
      Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            maxLength: 30,
            maxLengthEnforced: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 20.0),
              prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 5.0),
                  child: Icon(
                    Icons.label,
                    size: 15,
                  )),
              filled: true,
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(width: 1.0, color: Colors.red)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(width: 1.0, color: Colors.red)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide:
                      BorderSide(width: 0.0, color: Colors.transparent)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide:
                      BorderSide(width: 0.0, color: Colors.transparent)),
              hintText: 'Name your trip',
              hintStyle: TextStyle(fontSize: 13),
            ),
            controller: nameController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please name your trip.';
              }
              return null;
            },
          )),
      _buildDestField(0, this.param),
      Align(
          alignment: Alignment.center,
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 0.0),
              child: FlatButton(
                padding: EdgeInsets.all(20),
                child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Icon(Icons.add, size: 20),
                  AutoSizeText(' Add destination',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w300))
                ]),
                onPressed: () {
                  setState(() {
                    this.destinationsCount = this.destinationsCount + 1;
                    this.fields.insert(this.destinationsCount - 1,
                        _buildDestField(this.destinationsCount - 1));
                  });
                },
              ))),
      _buildDivider(),
      Align(
          alignment: Alignment.center,
          child: Container(
              margin: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              width: double.infinity,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0)),
                padding: EdgeInsets.symmetric(vertical: 15),
                color: Colors.blueGrey,
                onPressed: () async {
                  final store = Provider.of<TrotterStore>(context);

                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (this._formKey.currentState.validate()) {
                    // If the form is valid, display a snackbar. In the real world, you'd
                    // often want to call a server or save the information in a database
                    print(this._destinations[0]["image"]);
                    var data = {
                      "trip": {
                        "image": this._destinations[0]["image"],
                        "name": nameController.text
                      },
                      "destinations": this._destinations,
                      "user": {
                        "displayName": store.currentUser.displayName,
                        "photoUrl": store.currentUser.photoUrl,
                        "email": store.currentUser.email,
                        "phoneNumber": store.currentUser.phoneNumber,
                        "uid": store.currentUser.uid,
                      }
                    };
                    // print(data);
                    setState(() {
                      this.loading = true;
                    });
                    var response = await postCreateTrip(store, data);
                    setState(() {
                      this.loading = false;
                    });
                    if (response.success == true) {
                      //store.tripStore.createTrip(response.trip);
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: AutoSizeText('Trip created!',
                              style: TextStyle(fontSize: 15)),
                          duration: Duration(seconds: 2)));
                      onPush({
                        "id": response.trip['id'].toString(),
                        "level": "trip",
                        'from': 'createtrip'
                      });
                    }
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: AutoSizeText('Trip failed to get created!',
                          style: TextStyle(fontSize: 15)),
                      duration: Duration(seconds: 2),
                    ));
                  }
                },
                child: AutoSizeText('Create trip',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: Colors.white)),
              )))
    ];
    if (this.param != null) {
      var destination = {
        "location": this.param['location'],
        "destination_id": this.param['id'],
        "destination_name": this.param['name'],
        "level": this.param['level'],
        "country_id": this.param['country_id'],
        "country_name": this.param["country_name"],
        "start_date": null,
        "end_date": null,
        "image": this.param['image_hd']
      };
      this._destinations.add(destination);
      //this._destinationImages.add(this.param['image']);
    }
    this.destinationsCount = this.destinationsCount + 1;
    super.initState();
  }

  CreateTripState({this.onPush, this.param});

  @override
  Widget build(BuildContext context) {
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = MediaQuery.of(context).size.height - 110;
    double _panelHeightClosed = (MediaQuery.of(context).size.height / 2) + 200;
    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingUpPanel(
        parallaxEnabled: true,
        parallaxOffset: .5,
        minHeight: _panelHeightClosed,
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
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        maxHeight: _panelHeightOpen,
        panel: Center(
            child: new Scaffold(
                resizeToAvoidBottomPadding: false,
                backgroundColor: Colors.transparent,
                body: Stack(children: <Widget>[
                  Positioned.fill(
                      child: IgnorePointer(
                          ignoring: this.loading, child: _buildForm(context))),
                  this.loading
                      ? Center(child: RefreshProgressIndicator())
                      : Container()
                ]))),
        body: Container(
            height: _bodyHeight,
            child: Stack(children: <Widget>[
              Positioned(
                  width: MediaQuery.of(context).size.width,
                  height: _bodyHeight,
                  top: 0,
                  left: 0,
                  child: Image.asset(
                    "images/home_bg.jpeg",
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  )),
              Positioned.fill(
                top: 0,
                left: 0,
                child: Container(color: color.withOpacity(.3)),
              ),
            ])),
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              onPush: onPush, color: color, title: 'Create a trip')),
    ]);
  }

  _buildDestField(int index, [dynamic param]) {
    final TextEditingController _destinationTextController =
        TextEditingController();
    var dateFormat = DateFormat("EEE, MMM d, yyyy");
    if (param != null)
      _destinationTextController.text = param['country_id'] == 'United_States'
          ? '${param['name']}, United States'
          : '${param['name']}, ${param['country_name']}';
    return Column(children: <Widget>[
      Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
              child: IgnorePointer(
                  ignoring: true,
                  child: TextFormField(
                    enabled: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 20.0, right: 5.0),
                          child: Icon(Icons.label, size: 15)),
                      //fillColor: Colors.blueGrey.withOpacity(0.5),
                      filled: true,
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide:
                              BorderSide(width: 1.0, color: Colors.red)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide:
                              BorderSide(width: 1.0, color: Colors.red)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              width: 0.0, color: Colors.transparent)),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              width: 0.0, color: Colors.transparent)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              width: 0.0, color: Colors.transparent)),
                      hintText: 'Destination',
                      hintStyle: TextStyle(fontSize: 13),
                    ),
                    controller: _destinationTextController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please select a destination';
                      }
                      return null;
                    },
                  )),
              onTap: () async {
                var suggestion = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => SearchModal(query: '')),
                );
                if (suggestion != null) {
                  _destinationTextController.text = suggestion['country_id'] ==
                          'United_States'
                      ? '${suggestion['name']}, ${suggestion['parent_name']}'
                      : '${suggestion['name']}, ${suggestion['country_name']}';

                  if (this._destinations.length == (index + 1)) {
                    this._destinations.replaceRange(index, index + 1, [
                      {
                        "location": suggestion['location'],
                        "destination_id": suggestion['id'],
                        "destination_name": suggestion['name'],
                        "level": suggestion['level'],
                        "country_id": suggestion['country_id'],
                        "country_name": suggestion["country_name"],
                        "start_date":
                            this._destinations[index]['start_date'] != null
                                ? this._destinations[index]['start_date']
                                : null,
                        "end_date":
                            this._destinations[index]['end_date'] != null
                                ? this._destinations[index]['end_date']
                                : null,
                        "image": suggestion["image_hd"]
                      }
                    ]);
                  } else {
                    this._destinations.insert(index, {
                      "location": suggestion['location'],
                      "destination_id": suggestion['id'],
                      "destination_name": suggestion['name'],
                      "level": suggestion['level'],
                      "country_id": suggestion['country_id'],
                      "country_name": suggestion["country_name"],
                      "start_date": null,
                      "end_date": null,
                      "image": suggestion["image_hd"]
                    });
                  }
                  //this._destinationImages.insert(index, suggestion["image"]);
                }
              })),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
              child: Container(
                  margin: EdgeInsets.only(
                      left: 20.0, right: 10, top: 20.0, bottom: 0),
                  child: DateTimePickerFormField(
                    format: dateFormat,
                    inputType: InputType.date,
                    editable: false,
                    firstDate: DateTime.now(),
                    decoration: InputDecoration(
                      hintText: 'Arrival',
                      hintStyle: TextStyle(fontSize: 13),
                      contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 20.0, right: 5.0),
                          child: Icon(Icons.calendar_today, size: 15)),
                      //fillColor: Colors.blueGrey.withOpacity(0.5),
                      filled: true,
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide:
                              BorderSide(width: 1.0, color: Colors.red)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide:
                              BorderSide(width: 1.0, color: Colors.red)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              width: 0.0, color: Colors.transparent)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              width: 0.0, color: Colors.transparent)),
                    ),
                    onChanged: (dt) {
                      setState(() {
                        if (this._destinations.length > 0 && dt != null) {
                          var startDate = dt.millisecondsSinceEpoch / 1000;
                          this._destinations[index]['start_date'] =
                              startDate.toInt();
                          //print(this._destinations[index]['name']);
                        } else if (dt != null) {
                          var startDate = dt.millisecondsSinceEpoch / 1000;
                          this._destinations.insert(index, {
                            "start_date": startDate.toInt(),
                          });
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an arrival date';
                      }
                      return null;
                    },
                  ))),
          Flexible(
              child: Container(
                  margin: EdgeInsets.only(
                      left: 10.0, right: 20, top: 20.0, bottom: 0),
                  child: DateTimePickerFormField(
                    format: dateFormat,
                    inputType: InputType.date,
                    editable: false,
                    firstDate: DateTime.now(),
                    decoration: InputDecoration(
                      hintText: 'Departure',
                      hintStyle: TextStyle(fontSize: 13),
                      contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                      prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 20.0, right: 5.0),
                          child: Icon(Icons.calendar_today, size: 15)),
                      //fillColor: Colors.blueGrey.withOpacity(0.5),
                      filled: true,
                      errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide:
                              BorderSide(width: 1.0, color: Colors.red)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide:
                              BorderSide(width: 1.0, color: Colors.red)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              width: 0.0, color: Colors.transparent)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                              width: 0.0, color: Colors.transparent)),
                    ),
                    onChanged: (dt) {
                      setState(() {
                        if (this._destinations.length > 0 && dt != null) {
                          var endDate = dt.millisecondsSinceEpoch / 1000;
                          this._destinations[index]['end_date'] =
                              endDate.toInt();
                        } else if (dt != null) {
                          var endDate = dt.millisecondsSinceEpoch / 1000;
                          this._destinations.insert(index, {
                            "end_date": endDate.toInt(),
                          });
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a departure date';
                      } else if (this._destinations[index]['end_date'] <
                          this._destinations[index]['start_date']) {
                        return "Please choose a later departure date";
                      }
                      return null;
                    },
                  ))),
        ],
      ),
      _buildDivider()
    ]);
  }

  _buildDivider() {
    return Container(
        margin: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        child: Divider(color: Color.fromRGBO(0, 0, 0, 0.3)));
  }

// function for rendering view after data is loaded
  Widget _buildForm(BuildContext ctxt) {
    var formFields = ['', '', ...this.fields];
    return Form(
        key: this._formKey,
        child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
            child: ListView.builder(
                controller: _sc,
                physics: disableScroll
                    ? NeverScrollableScrollPhysics()
                    : ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: formFields.length,
                itemBuilder: (_, int index) {
                  if (index == 0) {
                    return Center(
                        child: Container(
                      width: 30,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                              BorderRadius.all(Radius.circular(12.0))),
                    ));
                  }

                  if (index == 1) {
                    return Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: 10, bottom: 40),
                      child: AutoSizeText(
                        'Where to?',
                        style: TextStyle(fontSize: 25),
                      ),
                    );
                  }
                  return formFields[index];
                })));
  }
}
