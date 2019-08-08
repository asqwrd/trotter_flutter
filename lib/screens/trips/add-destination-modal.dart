import 'package:flutter/material.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

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
    return _buildAddModal(context, color);
  }

  _buildDestField(BuildContext context, color, formKey) {
    var dateFormat = DateFormat("EEE, MMM d, yyyy");

    return Column(children: <Widget>[
      Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text('Add destination',
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
      Container(
          margin: EdgeInsets.only(left: 20.0, right: 20, top: 20.0, bottom: 0),
          child: DateTimePickerFormField(
            format: dateFormat,
            inputType: InputType.date,
            editable: false,
            firstDate: init.subtract(Duration(hours: 1)),
            decoration: InputDecoration(
              hintText: 'Arrival date',
              contentPadding: EdgeInsets.symmetric(vertical: 20.0),
              prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 5.0),
                  child: Icon(
                    Icons.calendar_today,
                    size: 18,
                  )),
              //fillColor: Colors.blueGrey.withOpacity(0.5),
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
            ),
            onChanged: (dt) {
              if (dt != null) {
                //setState(() {
                var startDate = dt.millisecondsSinceEpoch / 1000;
                this.destination['start_date'] = startDate.toInt();
                //});
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select an arrival date';
              }
              return null;
            },
          )),
      Container(
          margin: EdgeInsets.only(left: 20.0, right: 20, top: 20.0, bottom: 0),
          child: DateTimePickerFormField(
            format: dateFormat,
            inputType: InputType.date,
            editable: false,
            firstDate: init.subtract(Duration(hours: 1)),
            decoration: InputDecoration(
              hintText: 'Departure date',
              contentPadding: EdgeInsets.symmetric(vertical: 20.0),
              prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 5.0),
                  child: Icon(
                    Icons.calendar_today,
                    size: 18,
                  )),
              //fillColor: Colors.blueGrey.withOpacity(0.5),
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
            ),
            onChanged: (dt) {
              if (dt != null) {
                //setState(() {
                var endDate = dt.millisecondsSinceEpoch / 1000;
                this.destination['end_date'] = endDate.toInt();
                //});
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a departure date';
              } else if (this.destination['end_date'] <
                  this.destination['start_date']) {
                return "Please choose a later departure date";
              }
              return null;
            },
          )),
      Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
          child: FlatButton(
            color: color.withOpacity(0.8),
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(5.0)),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text('Add destination',
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
                child: Text('Close',
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
