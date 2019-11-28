import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:trotter_flutter/autocomplete/airlines.dart';
import 'package:trotter_flutter/autocomplete/airports_stations.dart';

class AutoCompleteAirline extends StatefulWidget {
  final String attribute;
  AutoCompleteAirline({this.attribute});

  @override
  _AutoCompleteAirlineState createState() =>
      new _AutoCompleteAirlineState(attribute: this.attribute);
}

class _AutoCompleteAirlineState extends State<AutoCompleteAirline> {
  GlobalKey<AutoCompleteTextFieldState<Airlines>> key = new GlobalKey();

  AutoCompleteTextField searchTextField;

  TextEditingController controller = new TextEditingController();
  final String attribute;

  _AutoCompleteAirlineState({this.attribute});

  void _loadData() async {
    await AirlinesViewModel.loadAirlines();
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderCustomField(
        attribute: attribute,
        validators: [
          FormBuilderValidators.required(),
        ],
        valueTransformer: (dynamic value) {
          print(value);
          var airline = value as Airlines;
          return {
            'iata_code': airline.iata.isNotEmpty ? airline.iata : airline.icao,
            'name': airline.name
          };
        },
        formField: FormField(
            enabled: true,
            builder: (FormFieldState<dynamic> field) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: searchTextField = AutoCompleteTextField<Airlines>(
                    style: new TextStyle(color: Colors.black, fontSize: 16.0),
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
                      hintText: 'Search airlines',
                      hintStyle: TextStyle(fontSize: 13),
                    ),
                    itemSubmitted: (item) {
                      field.didChange(item);
                      setState(() => searchTextField.textField.controller.text =
                          item.name);
                    },
                    clearOnSubmit: false,
                    key: key,
                    suggestions: AirlinesViewModel.airlines,
                    itemBuilder: (context, item) {
                      return ListTile(
                        title: AutoSizeText(item.name),
                        trailing: AutoSizeText(item.country),
                        subtitle: item.iata.isNotEmpty
                            ? AutoSizeText(item.iata)
                            : AutoSizeText(item.icao),
                      );
                    },
                    itemSorter: (a, b) {
                      return a.name.compareTo(b.name);
                    },
                    itemFilter: (item, query) {
                      return item.name
                          .toLowerCase()
                          .contains(query.toLowerCase());
                    }),
              );
            }));
  }
}

class AutoCompleteAirport extends StatefulWidget {
  @override
  _AutoCompleteAirportState createState() => new _AutoCompleteAirportState();
}

class _AutoCompleteAirportState extends State<AutoCompleteAirport> {
  GlobalKey<AutoCompleteTextFieldState<AirportsStations>> key = new GlobalKey();

  AutoCompleteTextField searchTextField;

  TextEditingController controller = new TextEditingController();

  _AutoCompleteAirportState();

  void _loadData() async {
    await AirportsViewModel.loadAirports();
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: searchTextField = AutoCompleteTextField<AirportsStations>(
          style: new TextStyle(color: Colors.black, fontSize: 16.0),
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
                borderSide: BorderSide(width: 0.0, color: Colors.transparent)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide(width: 0.0, color: Colors.transparent)),
            hintText: 'Search airports',
            hintStyle: TextStyle(fontSize: 13),
          ),
          itemSubmitted: (item) {
            setState(
                () => searchTextField.textField.controller.text = item.name);
          },
          clearOnSubmit: false,
          key: key,
          suggestions: AirportsViewModel.airports,
          itemBuilder: (context, item) {
            return ListTile(
              title: AutoSizeText(item.name),
              trailing: AutoSizeText(item.country),
              subtitle: item.iata.isNotEmpty && item.iata != '\\N'
                  ? AutoSizeText(item.iata)
                  : item.icao != '\\N' ? AutoSizeText(item.icao) : Container(),
            );
          },
          itemSorter: (a, b) {
            return a.name.compareTo(b.name);
          },
          itemFilter: (item, query) {
            return item.name.toLowerCase().contains(query.toLowerCase()) ||
                item.iata.toLowerCase().contains(query.toLowerCase()) ||
                item.icao.toLowerCase().contains(query.toLowerCase());
          }),
    );
  }
}
