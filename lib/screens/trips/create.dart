import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'dart:core';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:intl/intl.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/store/trips/middleware.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

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

  Future<CreateTripData> data;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //final TextEditingController _typeAheadController = TextEditingController();

  List<dynamic> _destinations = [{}];
  String name;
  var destinationsCount = 0;
  List<Widget> fields;
  List<Widget> destFields;
  final nameController = TextEditingController();
  final List<TextEditingController> datesControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> numDaysControllers = [
    TextEditingController()
  ];
  bool loading;
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  Color color = Colors.blueGrey;
  bool shadow = false;
  dynamic useDays = {'0': false};
  bool setDatesLater = false;

  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    nameController.dispose();
    datesControllers.forEach((controller) {
      if (controller != null) controller.dispose();
    });
    numDaysControllers.forEach((controller) {
      if (controller != null) controller.dispose();
    });
    super.dispose();
  }

  @override
  void initState() {
    loading = false;

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
    this.destinationsCount = 1;
    super.initState();
  }

  CreateTripState({this.onPush, this.param});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    final TextEditingController _destinationTextController =
        TextEditingController();
    var dateFormat = DateFormat("EEE, MMM d, yyyy");
    if (this.destFields == null) {
      if (param != null)
        _destinationTextController.text = param['country_id'] == 'United_States'
            ? '${param['name']}, United States'
            : '${param['name']}, ${param['country_name']}';
      this.destFields = [_buildDestField(0, this.param, false)];
      //this.destFields[0].setDatesLater =true;
    }
    this.fields = [
      Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            maxLength: 20,
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
      ...destFields,
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
                  print('add');
                  setState(() {
                    this.destinationsCount = this.destinationsCount + 1;
                    datesControllers.add(TextEditingController());
                    numDaysControllers.add(TextEditingController());
                    this.destFields.add(this
                        ._buildDestField(this.destFields.length, null, true));
                    this._destinations.add({});
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
                    borderRadius: new BorderRadius.circular(100.0)),
                padding: EdgeInsets.symmetric(vertical: 20),
                color: Colors.blueGrey,
                onPressed: () async {
                  final store = Provider.of<TrotterStore>(context);

                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (this._formKey.currentState.validate()) {
                    // If the form is valid, display a snackbar. In the real world, you'd
                    // often want to call a server or save the information in a database
                    var data = {
                      "trip": {
                        "image": this._destinations[0]["image"],
                        "name": nameController.text
                      },
                      "destinations": this
                          ._destinations
                          .where((destination) => destination != null)
                          .toList(),
                      "user": {
                        "displayName": store.currentUser.displayName,
                        "photoUrl": store.currentUser.photoUrl,
                        "email": store.currentUser.email,
                        "phoneNumber": store.currentUser.phoneNumber,
                        "uid": store.currentUser.uid,
                      }
                    };
                    //print(data['destinations']);
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
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        content: AutoSizeText('Trip failed to get created!',
                            style: TextStyle(fontSize: 15)),
                        duration: Duration(seconds: 2),
                      ));
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
    double _bodyHeight = MediaQuery.of(context).size.height - 110;
    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingPanel(
              initialState: InitialPanelState.expanded,
              isDraggable: false,
              size: PanelSize(closedHeight: .7),
              autoSizing: PanelAutoSizing(),
              decoration: PanelDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              parallaxSlideAmount: .5,
              backdropConfig: BackdropConfig(
                  dragFromBody: true,
                  shadowColor: color,
                  opacity: 1,
                  enabled: true),
              panelController: _pc,
              content: PanelContent(
                headerWidget: PanelHeaderWidget(
                  headerContent: Container(
                      decoration: BoxDecoration(
                          boxShadow: this.shadow
                              ? <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.black.withOpacity(.2),
                                      blurRadius: 10.0,
                                      offset: Offset(0.0, 0.75))
                                ]
                              : [],
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Center(
                              child: Container(
                            width: 30,
                            height: 5,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0))),
                          )),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: 10, bottom: 20),
                            child: AutoSizeText(
                              'Where to?',
                              style: TextStyle(fontSize: 25),
                            ),
                          )
                        ],
                      )),
                ),
                panelContent: (context, _sc) {
                  if (_sc.hasListeners == false) {
                    _sc.addListener(() {
                      if (_sc.offset > 0) {
                        setState(() {
                          this.shadow = true;
                        });
                      } else {
                        setState(() {
                          this.shadow = false;
                        });
                      }
                    });
                  }
                  return Center(
                      child: new Scaffold(
                          resizeToAvoidBottomPadding: false,
                          backgroundColor: Colors.transparent,
                          body: Stack(children: <Widget>[
                            Positioned.fill(
                                child: IgnorePointer(
                                    ignoring: this.loading,
                                    child: _buildForm(context, _sc))),
                            this.loading
                                ? Center(child: RefreshProgressIndicator())
                                : Container()
                          ])));
                },
                bodyContent: Container(
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
                        child: Container(color: color.withOpacity(.65)),
                      ),
                    ])),
              ))),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
            onPush: onPush,
            color: color,
            title: 'Create a trip',
            back: true,
          )),
    ]);
  }

  Widget _buildDestField(int index, [dynamic param, bool addRemove = false]) {
    print("dest");
    final TextEditingController _destinationTextController =
        TextEditingController();
    var dateFormat = DateFormat("EEE, MMM d, yyyy");
    if (param != null)
      _destinationTextController.text = param['country_id'] == 'United_States'
          ? '${param['name']}, United States'
          : '${param['name']}, ${param['country_name']}';
    return DestinationField(
        //index: index,
        addRemove: addRemove,
        onToggle: (value) {
          setState(() {
            this.useDays['$index'] = value;
            print(useDays);
          });
        },
        onNumDaysChanged: (String value) {
          if (value != null && value.isNotEmpty) {
            setState(() {
              if (this._destinations.length > 0 && value.isNotEmpty) {
                this._destinations[index]['num_of_days'] = int.parse(value);
              } else if (value.isNotEmpty) {
                this._destinations.insert(index, {
                  "num_of_days": int.parse(value),
                });
              }
            });
          }
        },
        onDestinationSelected: (dynamic suggestion) {
          if (suggestion != null) {
            _destinationTextController.text =
                suggestion['country_id'] == 'United_States' &&
                        suggestion['type'] != 'region'
                    ? '${suggestion['name']}, ${suggestion['parent_name']}'
                    : '${suggestion['name']}, ${suggestion['country_name']}';

            if (this._destinations.length == (index + 1)) {
              this._destinations.replaceRange(index, index + 1, [
                {
                  "location": suggestion['location'],
                  "destination_id": suggestion['id'],
                  "destination_name": suggestion['name'],
                  "parent_name": suggestion['parent_name'],
                  "level": suggestion['level'],
                  "country_id": suggestion['country_id'],
                  "country_name": suggestion["country_name"],
                  "start_date": this._destinations[index]['start_date'] != null
                      ? this._destinations[index]['start_date']
                      : null,
                  "end_date": this._destinations[index]['end_date'] != null
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
                "parent_name": suggestion['parent_name'],
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
        },
        onDateSelected: (dynamic picked) {
          if (picked != null && picked.length == 2) {
            setState(() {
              datesControllers[index].text =
                  '${dateFormat.format(picked[0])} to ${dateFormat.format(picked[1])}';
              if (this._destinations.length > 0 && picked != null) {
                var startDate = picked[0].millisecondsSinceEpoch / 1000;
                this._destinations[index]['start_date'] = startDate.toInt();
                var endDate = picked[1].millisecondsSinceEpoch / 1000;
                this._destinations[index]['end_date'] = endDate.toInt();
              } else if (picked != null) {
                var startDate = picked[0].millisecondsSinceEpoch / 1000;
                var endDate = picked[1].millisecondsSinceEpoch / 1000;
                this._destinations.insert(index, {
                  "start_date": startDate.toInt(),
                  "end_date": endDate.toInt(),
                });
              }
            });
          }
        },
        destinationTextController: _destinationTextController,
        context: context,
        destinations: _destinations,
        dateController: datesControllers[index],
        numOfDaysController: numDaysControllers[index],
        dateFormat: dateFormat,
        onRemoved: (res) {
          setState(() {
            this.destinationsCount = this.destFields.length;
            datesControllers[index] = null;
            numDaysControllers[index] = null;
            this.destFields[index] = Container();
            this._destinations[index] = null;
          });
        },
        destFields: destFields);
  }

  _buildDivider() {
    return Container(
        margin: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        child: Divider(color: Color.fromRGBO(0, 0, 0, 0.3)));
  }

// function for rendering view after data is loaded
  Widget _buildForm(BuildContext ctxt, ScrollController _sc) {
    var formFields = this.fields;
    return Form(
        key: this._formKey,
        child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
            child: ListView.builder(
                controller: _sc,
                shrinkWrap: true,
                itemCount: formFields.length,
                itemBuilder: (_, int index) {
                  return formFields[index];
                })));
  }
}

class DestinationField extends StatefulWidget {
  final ValueChanged<dynamic> onToggle;
  final ValueChanged<String> onNumDaysChanged;
  final ValueChanged<dynamic> onRemoved;
  final ValueChanged<dynamic> onDestinationSelected;
  final ValueChanged<dynamic> onDateSelected;
  final bool addRemove;
  final TextEditingController destinationTextController;
  final BuildContext context;
  final List destinations;
  // final bool setDatesLater;
  final TextEditingController dateController;
  final TextEditingController numOfDaysController;
  final DateFormat dateFormat;
  final List<Widget> destFields;

  DestinationField({
    Key key,
    @required this.destinationTextController,
    @required this.onDestinationSelected,
    @required this.onDateSelected,
    @required this.context,
    @required this.destinations,
    @required this.dateController,
    @required this.numOfDaysController,
    @required this.dateFormat,
    @required this.destFields,
    @required this.addRemove,
    this.onToggle,
    this.onRemoved,
    this.onNumDaysChanged,
  }) : super(key: key);
  @override
  DestinationFieldState createState() => new DestinationFieldState(
      onToggle: this.onToggle,
      context: this.context,
      dateController: dateController,
      numOfDaysController: numOfDaysController,
      dateFormat: dateFormat,
      addRemove: addRemove,
      destinationTextController: destinationTextController,
      destFields: destFields,
      onDestinationSelected: onDestinationSelected,
      onDateSelected: onDateSelected,
      onRemoved: onRemoved,
      onNumDaysChanged: onNumDaysChanged,
      destinations: destinations);
}

class DestinationFieldState extends State<DestinationField> {
  final ValueChanged<dynamic> onToggle;
  final ValueChanged<dynamic> onRemoved;
  final ValueChanged<String> onNumDaysChanged;
  final ValueChanged<dynamic> onDestinationSelected;
  final ValueChanged<dynamic> onDateSelected;
  final bool addRemove;
  final TextEditingController destinationTextController;
  final BuildContext context;
  final List destinations;
  // final bool setDatesLater;
  final TextEditingController dateController;
  final TextEditingController numOfDaysController;
  final DateFormat dateFormat;
  final List<Widget> destFields;
  bool setDatesLater;

  @override
  void initState() {
    this.setDatesLater = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  DestinationFieldState({
    @required this.destinationTextController,
    @required this.context,
    @required this.destinations,
    @required this.dateController,
    @required this.numOfDaysController,
    @required this.dateFormat,
    @required this.destFields,
    @required this.addRemove,
    @required this.onToggle,
    @required this.onNumDaysChanged,
    @required this.onDestinationSelected,
    @required this.onDateSelected,
    this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
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
                    controller: this.destinationTextController,
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
                onDestinationSelected(suggestion);
              })),
      this.setDatesLater == true
          ? Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: TextFormField(
                onChanged: (value) {
                  onNumDaysChanged(this.numOfDaysController.text);
                },
                keyboardType: TextInputType.number,
                maxLengthEnforced: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                  prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 5.0),
                      child: Icon(
                        Icons.calendar_today,
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
                  hintText: 'How many days will you be here?',
                  hintStyle: TextStyle(fontSize: 13),
                ),
                controller: this.numOfDaysController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter number of days you will be here';
                  }
                  return null;
                },
              ))
          : InkWell(
              onTap: () async {
                final List<DateTime> picked =
                    await DateRagePicker.showDatePicker(
                        context: context,
                        initialFirstDate: new DateTime.now(),
                        initialLastDate:
                            (new DateTime.now()).add(new Duration(days: 7)),
                        firstDate: new DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            0,
                            0,
                            0,
                            0),
                        lastDate: new DateTime(2021));
                onDateSelected(picked);
              },
              child: Container(
                  margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: IgnorePointer(
                      ignoring: true,
                      child: TextFormField(
                        maxLengthEnforced: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 20.0, right: 5.0),
                              child: Icon(
                                Icons.calendar_today,
                                size: 15,
                              )),
                          filled: true,
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide:
                                  BorderSide(width: 1.0, color: Colors.red)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide:
                                  BorderSide(width: 1.0, color: Colors.red)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(
                                  width: 0.0, color: Colors.transparent)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(
                                  width: 0.0, color: Colors.transparent)),
                          hintText: 'When are you traveling',
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                        controller: this.dateController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please select travel dates.';
                          }
                          return null;
                        },
                      )))),
      SwitchListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20, top: 0),
        title: Text('Set travel dates later?'),
        value: this.setDatesLater,
        onChanged: (bool newVal) {
          setState(() {
            this.setDatesLater = newVal;
            onToggle(newVal);
          });
        },
      ),
      addRemove == true
          ? Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(5.0)),
                color: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 15),
                child: AutoSizeText(
                  'Remove',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w300),
                ),
                onPressed: () {
                  this.onRemoved({});
                },
              ))
          : Container(),
      Container(
          margin: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          child: Divider(color: Color.fromRGBO(0, 0, 0, 0.3)))
      //this.parent._buildDivider()
    ]);
  }
}
