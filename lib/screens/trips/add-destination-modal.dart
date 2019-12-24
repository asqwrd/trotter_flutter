import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class AddDestinationModal extends StatefulWidget {
  AddDestinationModal({Key key, this.color, @required this.tripId})
      : super(key: key);
  final String tripId;
  final Color color;
  @override
  _AddDestinationModal createState() =>
      new _AddDestinationModal(color: this.color, tripId: this.tripId);
}

class _AddDestinationModal extends State<AddDestinationModal> {
  _AddDestinationModal({this.color, this.tripId, this.destination});
  TextEditingController _typeAheadController = TextEditingController();
  final init = DateTime.now();
  bool setDatesLater = false;
  TextEditingController numOfDaysController = new TextEditingController();

  dynamic destination;
  final String tripId;
  final Color color;
  @override
  void initState() {
    this.destination = {};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return _buildAddModal(context, color);
  }

  _buildDestField(BuildContext context, color, formKey) {
    var dateFormat = DateFormat("EEE, MMM d, yyyy");
    final datesController = TextEditingController();

    return Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: AutoSizeText('Add destination',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w300))),
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
                          child: Icon(Icons.label)),
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
                    ),
                    controller: _typeAheadController,
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
                  //setState(() {
                  _typeAheadController.text = suggestion['country_id'] ==
                          'United_States'
                      ? '${suggestion['name']}, ${suggestion['parent_name']}'
                      : '${suggestion['name']}, ${suggestion['country_name']}';
                  this.destination = {
                    "location": suggestion['location'],
                    "destination_id": suggestion['id'],
                    "parent_name": suggestion['parent_name'],
                    "destination_name": suggestion['name'],
                    "level": suggestion['level'],
                    "country_id": suggestion['country_id'],
                    "country_name": suggestion["country_name"],
                    "start_date": this.destination['start_date'] != null
                        ? destination['start_date']
                        : null,
                    "end_date": this.destination['end_date'] != null
                        ? destination['end_date']
                        : null,
                    "image": suggestion['image'] != null
                        ? suggestion['image']
                        : null,
                  };
                  //});

                }
              })),
      this.setDatesLater == true
          ? Container(
              margin:
                  EdgeInsets.only(left: 20.0, right: 20, top: 20.0, bottom: 0),
              child: TextFormField(
                onChanged: (value) {
                  this.destination['num_of_days'] =
                      int.parse(numOfDaysController.text);
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
          : Container(
              margin:
                  EdgeInsets.only(left: 20.0, right: 20, top: 20.0, bottom: 0),
              child: InkWell(
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
                    if (picked != null && picked.length == 2) {
                      print(picked);

                      datesController.text =
                          '${dateFormat.format(picked[0])} to ${dateFormat.format(picked[1])}';
                      if (picked != null) {
                        var startDate = picked[0].millisecondsSinceEpoch / 1000;
                        this.destination['start_date'] = startDate.toInt();
                        var endDate = picked[1].millisecondsSinceEpoch / 1000;
                        this.destination['end_date'] = endDate.toInt();
                      }
                    }
                  },
                  child: Container(
                      margin: EdgeInsets.only(left: 0, right: 0, top: 0),
                      child: IgnorePointer(
                          ignoring: true,
                          child: TextFormField(
                            maxLengthEnforced: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 20.0),
                              prefixIcon: Padding(
                                  padding:
                                      EdgeInsets.only(left: 20.0, right: 5.0),
                                  child: Icon(
                                    Icons.calendar_today,
                                    size: 15,
                                  )),
                              filled: true,
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(
                                      width: 1.0, color: Colors.red)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(
                                      width: 1.0, color: Colors.red)),
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
                            controller: datesController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please select travel dates.';
                              }
                              return null;
                            },
                          ))))),
      SwitchListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20, top: 0),
        title: Text('Set travel dates later?'),
        value: this.setDatesLater,
        onChanged: (bool newVal) {
          setState(() {
            this.setDatesLater = newVal;
          });
        },
      ),
      Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
          child: FlatButton(
            color: color.withOpacity(0.8),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0)),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: AutoSizeText('Add destination',
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w300,
                        color: Colors.white))),
            onPressed: () async {
              if (formKey.currentState.validate()) {
                Navigator.pop(context, destination);
              }
            },
          )),
      Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: FlatButton(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: AutoSizeText('Close',
                    style:
                        TextStyle(fontSize: 23, fontWeight: FontWeight.w300))),
            onPressed: () {
              Navigator.pop(context);
            },
          ))
    ]);
  }

  Widget _buildAddModal(BuildContext ctxt, Color color) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final fields = <Widget>[
      _buildDestField(ctxt, color, _formKey),
    ];

    return Form(
        key: _formKey,
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: fields.length,
                itemBuilder: (_, int index) {
                  return fields[index];
                })));
  }
}
