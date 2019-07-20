import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:duration/duration.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FlightsAccomodationsList extends StatelessWidget {
  final dynamic destination;
  final Function(String) callback;
  final double height;
  final ScrollController controller;
  final ScrollPhysics physics;

  //passing props in react style
  FlightsAccomodationsList({
    this.destination,
    this.callback,
    this.controller,
    this.physics,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return buildTimeLine(context, this.destination);
  }

  Widget buildTimeLine(BuildContext context, dynamic item) {
    final details = item['details'];
    final destination = item['destination'];
    return Container(
        height: this.height ?? this.height,
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(top: 0.0),
        decoration: BoxDecoration(color: Colors.transparent),
        child: ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: details.length,
          itemBuilder: (BuildContext listContext, int index) {
            final segments = details[index]['segments'];
            final travelers = details[index]['travelers_full'];

            return Container(
                child: ListView.separated(
              separatorBuilder: (BuildContext context, int index) =>
                  new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
              primary: false,
              shrinkWrap: true,
              itemCount: segments.length,
              itemBuilder: (BuildContext segmentContext, int segIndex) {
                final segment = segments[segIndex];
                return IntrinsicHeight(
                    child: renderSegment(segment, segIndex, travelers));
              },
            ));
          },
        ));
  }

  renderSegment(dynamic segment, index, dynamic travelers) {
    TextStyle style = TextStyle(
        fontSize: 40, color: Colors.black, fontWeight: FontWeight.w400);
    TextStyle topstyle = TextStyle(
        fontSize: 30, color: Colors.black, fontWeight: FontWeight.w200);
    TextStyle substyle = TextStyle(
        fontSize: 20, color: Colors.black, fontWeight: FontWeight.w300);

    switch (segment['type']) {
      case 'Air':
        var depTime = DateTime.parse(segment['departure_datetime']);
        final departTimeZone = getLocation(segment['departure_time_zone_id']);
        final departureTime = new TZDateTime(departTimeZone, depTime.year,
            depTime.month, depTime.day, depTime.hour, depTime.minute);

        var arrTime = DateTime.parse(segment['arrival_datetime']);
        final arrivalTimeZone = getLocation(segment['arrival_time_zone_id']);
        final arrivalTime = new TZDateTime(arrivalTimeZone, arrTime.year,
            arrTime.month, arrTime.day, arrTime.hour, arrTime.minute);

        final difference = arrivalTime.difference(departureTime);
        final timeInAir = printDuration(difference);
        return Center(
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 20),
                margin: EdgeInsets.only(bottom: 40, top: index == 0 ? 20 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Icon(
                              Icons.flight_takeoff,
                              color: Colors.black.withOpacity(.3),
                            ),
                            Container(
                                width: 1,
                                height: 300,
                                color: Colors.black.withOpacity(.3))
                          ],
                        ),
                        Container(margin: EdgeInsets.only(right: 20)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              segment['origin_name'],
                              style: topstyle,
                            ),
                            Text(
                              segment['origin_city_name'],
                              style: style,
                            ),
                            Text(
                              segment['origin_country'],
                              style: topstyle,
                            ),
                            Text(
                              DateFormat("MMMM d, y hh:mm a").format(
                                  DateTime.parse(
                                      segment['departure_datetime'])),
                              style: substyle,
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 30),
                                child: Row(children: <Widget>[
                                  Text(
                                      '${segment['number_of_pax']} ${segment['number_of_pax'] > 1 ? 'people' : 'person'} traveling'),
                                  Container(
                                      width: 50,
                                      height: 1,
                                      margin:
                                          EdgeInsets.only(left: 5, right: 3),
                                      color: Colors.black.withOpacity(0.3)),
                                  buildTravelers(travelers)
                                ])),
                            Container(
                              margin: EdgeInsets.only(top: 90),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text("$timeInAir in air",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.flight_land,
                            color: Colors.black.withOpacity(.3)),
                        Container(margin: EdgeInsets.only(right: 20)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              segment['destination_name'],
                              style: topstyle,
                            ),
                            Text(segment['destination_city_name'],
                                style: style),
                            Text(
                              segment['destination_country'],
                              style: topstyle,
                            ),
                            Text(
                              DateFormat("MMMM d, y hh:mm a").format(
                                  DateTime.parse(segment['arrival_datetime'])),
                              style: substyle,
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                )));
      case 'Hotel':
        return Container();
    }
  }

  static Icon icon(String type) {
    switch (type) {
      case 'Air':
        return Icon(Icons.flight_takeoff);
      case 'Hotel':
        return Icon(Icons.hotel);
    }

    return null;
  }
}
