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
  dynamic value;

  FormBuilderTypeAhead searchTextField;

  TextEditingController controller = new TextEditingController();
  final String attribute;

  _AutoCompleteAirlineState({this.attribute});

  void _loadData() async {
    if (AirlinesViewModel.airlines == null) {
      await AirlinesViewModel.loadAirlines();
    }
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: searchTextField = FormBuilderTypeAhead<Airlines>(
          attribute: attribute,
          validators: [
            FormBuilderValidators.required(
                errorText: 'The $attribute field is required'),
          ],
          initialValue: Airlines(),
          valueTransformer: (value) {
            return this.value;
          },
          selectionToTextTransformer: (airline) {
            this.value = {
              'iata_code': airline.iata != null && airline.iata.isNotEmpty
                  ? airline.iata
                  : airline.icao,
              'name': airline.name
            };
            return airline.name;
          },
          suggestionsCallback: (query) {
            if (AirlinesViewModel.airlines != null) {
              return AirlinesViewModel.airlines.where((item) {
                return item.name.toLowerCase().contains(query.toLowerCase());
              }).toList();
            }
            return [];
          },
          itemBuilder: (context, item) {
            return ListTile(
              title: AutoSizeText(item.name),
              trailing: AutoSizeText(item.country),
              subtitle: item.iata.isNotEmpty && item.iata != '\\N'
                  ? AutoSizeText(item.iata)
                  : item.icao != '\\N' ? AutoSizeText(item.icao) : Container(),
            );
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 20.0),
            prefixIcon: Padding(
                padding: EdgeInsets.only(left: 20.0, right: 5.0),
                child: Icon(
                  Icons.flight,
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
            hintText: 'Search airlines',
            hintStyle: TextStyle(fontSize: 13),
          ),
        ));
  }
}

class AutoCompleteAirport extends StatefulWidget {
  final String attribute;
  final String hintText;
  AutoCompleteAirport({this.attribute, this.hintText});
  @override
  _AutoCompleteAirportState createState() => new _AutoCompleteAirportState(
        attribute: this.attribute,
        hintText: this.hintText,
      );
}

class _AutoCompleteAirportState extends State<AutoCompleteAirport> {
  GlobalKey<AutoCompleteTextFieldState<AirportsStations>> key = new GlobalKey();
  AutoCompleteTextField searchTextField;

  TextEditingController controller = new TextEditingController();
  final String attribute;
  final String hintText;
  dynamic value;

  _AutoCompleteAirportState({this.attribute, this.hintText});

  void _loadData() async {
    if (AirportsViewModel.airports == null) {
      await AirportsViewModel.loadAirports();
    }
  }

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: FormBuilderTypeAhead<AirportsStations>(
          attribute: attribute,
          initialValue: AirportsStations(),
          selectionToTextTransformer: (airport) {
            this.value = {
              'alias': airport.alias,
              'iata': airport.iata,
              'icao': airport.icao,
              'name': airport.name,
              'city': airport.city,
              'country': airport.country,
              'time_zone_id': airport.timezoneName,
              'lat': airport.lat,
              'lon': airport.lon,
            };
            return airport.name;
          },
          valueTransformer: (value) {
            return this.value;
          },
          validators: [
            FormBuilderValidators.required(
                errorText: '$hintText field is required'),
          ],
          suggestionsCallback: (query) {
            if (AirportsViewModel.airports != null) {
              return AirportsViewModel.airports.where((item) {
                return item.name.toLowerCase().contains(query.toLowerCase()) ||
                    item.iata.toLowerCase().contains(query.toLowerCase()) ||
                    item.icao.toLowerCase().contains(query.toLowerCase());
              }).toList();
            }
            return [];
          },
          itemBuilder: (context, item) {
            return ListTile(
              title: AutoSizeText(item.name),
              trailing: AutoSizeText(item.country),
              subtitle: item.iata.isNotEmpty && item.iata != '\\N'
                  ? AutoSizeText(item.iata)
                  : item.icao != '\\N' ? AutoSizeText(item.icao) : Container(),
            );
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 20.0),
            prefixIcon: Padding(
                padding: EdgeInsets.only(left: 20.0, right: 5.0),
                child: Icon(
                  Icons.flight_takeoff,
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
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 13),
          ),
        ));
  }
}
