import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/utils.dart';

class StartLocationModal extends StatefulWidget {
  final ValueChanged<dynamic> onSelect;
  final List<dynamic> hotels;
  final dynamic destination;
  StartLocationModal(
      {Key key, @required this.hotels, this.onSelect, this.destination})
      : super(key: key);
  @override
  StartLocationModalState createState() => new StartLocationModalState(
        hotels: this.hotels,
        destination: this.destination,
        onSelect: this.onSelect,
      );
}

class StartLocationModalState extends State<StartLocationModal> {
  List<dynamic> hotels;
  final ValueChanged<dynamic> onSelect;
  dynamic destination;

  @override
  void initState() {
    super.initState();
  }

  StartLocationModalState({this.hotels, this.onSelect, this.destination});

  @override
  Widget build(BuildContext context) {
    return _buildLoadedBody(context);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt) {
    final cityCenter = {
      "hotel_name": 'City Center',
      "type": 'Meeting point',
      "lat": this.destination['location']['lat'].toString(),
      "lon": this.destination['location']['lng'].toString()
    };
    final List<dynamic> options = [
      {"hotel": cityCenter, "travelers": []},
      ...this.hotels
    ];
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          elevation: 0,
          // centerTitle: true,
          title: Text(
            'Select starting point',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w300, fontSize: 24),
          ),
          leading: IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
            iconSize: 30,
            color: Colors.black,
          ),
        ),
        body: ListView.separated(
          separatorBuilder: (BuildContext context, int index) =>
              new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
          itemCount: options.length,
          //shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              selected: false,
              onTap: () {
                Navigator.pop(context, {
                  "location": {
                    "lat": double.parse(options[index]['hotel']['lat']),
                    "lng": double.parse(options[index]['hotel']['lon']),
                  },
                  "name": options[index]['hotel']['hotel_name']
                });
              },
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              subtitle: Text(options[index]['hotel']['type']),
              title: Text(
                options[index]['hotel']['hotel_name'],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              trailing: buildTravelers(options[index]['travelers']),
            );
          },
        ));
  }
}
