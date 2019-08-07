import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:duration/duration.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlightsAccomodationsList extends StatelessWidget {
  final dynamic destination;
  final ValueChanged onAddPressed;
  final ValueChanged onDeletePressed;
  final double height;
  final ScrollController controller;
  final ScrollPhysics physics;

  //passing props in react style
  FlightsAccomodationsList({
    this.destination,
    this.onAddPressed,
    this.onDeletePressed,
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
    if (details.length == 0) {
      return renderEmpty(destination);
    }
    return Container(
        height: this.height ?? this.height,
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(top: 0.0),
        decoration: BoxDecoration(color: Colors.transparent),
        child: ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: details.length,
          itemBuilder: (BuildContext listContext, int index) {
            final segments = details[index]['segments'];
            final travelers = details[index]['travelers_full'];

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: ListTile(
                          trailing: IconButton(
                            icon: Icon(EvilIcons.trash),
                            iconSize: 32,
                            onPressed: () {
                              this.onDeletePressed({
                                "id": details[index]['id'],
                                "destinationId": destination['id'],
                              });
                            },
                          ),
                          title: Text('${details[index]['source']}',
                              style: TextStyle(fontSize: 24)),
                          subtitle: Container(
                            margin: EdgeInsets.only(top: 20, left: 10),
                            width: 250,
                            child: InkWell(
                                onTap: () {
                                  this.onAddPressed({
                                    "id": details[index]['id'],
                                    "destinationId": destination['id'],
                                    "travelers": travelers,
                                    "index": index,
                                  });
                                },
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        margin: EdgeInsets.only(top: 0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: Colors.transparent),
                                        child: SvgPicture.asset(
                                            'images/edit-icon.svg',
                                            color: Colors.blueAccent,
                                            width: 25,
                                            height: 25),
                                      ),
                                      Text('Edit travelers',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.blueAccent))
                                    ])),
                          ))),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
                        primary: false,
                        shrinkWrap: true,
                        itemCount: segments.length,
                        itemBuilder:
                            (BuildContext segmentContext, int segIndex) {
                          final segment = segments[segIndex];
                          return IntrinsicHeight(
                              child: renderSegment(segmentContext, segment,
                                  segIndex, travelers));
                        },
                      ))
                ]);
          },
        ));
  }

  renderSegment(
      BuildContext context, dynamic segment, index, dynamic travelers) {
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
        final timeInAir =
            prettyDuration(difference, tersity: DurationTersity.minute);
        return Center(
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20),
                margin: EdgeInsets.only(bottom: 40, top: index == 0 ? 0 : 20),
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
                            Text(
                              'Confirmation #: ${segment['confirmation_no']}',
                              style: substyle,
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 60),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          '${segment['number_of_pax']} ${segment['number_of_pax'] > 1 ? 'people' : 'person'} traveling'),
                                      Container(
                                          width: 50,
                                          height: 1,
                                          margin: EdgeInsets.only(
                                              left: 5, right: 3),
                                          color: Colors.black.withOpacity(0.3)),
                                      Container(
                                          //width: double.infinity,
                                          child: buildTravelers(travelers))
                                    ])),
                            Container(
                              margin: EdgeInsets.only(top: 60),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                      "${segment['airline']} flight ${segment['iata_code']}${segment['flight_number']}",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400)),
                                  Container(
                                      width: 30,
                                      height: 1,
                                      margin:
                                          EdgeInsets.only(left: 5, right: 3),
                                      color: Colors.black.withOpacity(0.3)),
                                  Text("$timeInAir in air",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300)),
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
        final hotelInfo = [
          {"label": "Checkin", "value": segment['checkin_date']},
          {"label": "Checkout", "value": segment['checkout_date']},
          {"label": "Confirmation number", "value": segment['confirmation_no']},
          {'label': "Guests", "value": travelers}
        ];
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <
                Widget>[
              Container(
                  margin: EdgeInsets.only(right: 20),
                  child: icon(segment['type'])),
              Flexible(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    Container(
                        child: Text(segment['hotel_name'], style: topstyle)),
                    Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        child: ClipPath(
                            clipper: CornerRadiusClipper(10.0),
                            child: GoogleMap(
                              // onMapCreated: (GoogleMapController controller) {
                              //   _controller.complete(controller);
                              // },
                              markers: <Marker>[
                                Marker(
                                    markerId:
                                        MarkerId(segment['confirmation_no']),
                                    position: LatLng(
                                        double.parse(segment['lat']),
                                        double.parse(segment['lon'])))
                              ].toSet(),
                              initialCameraPosition: CameraPosition(
                                bearing: 0.0,
                                target: LatLng(double.parse(segment['lat']),
                                    double.parse(segment['lon'])),
                                tilt: 30.0,
                                zoom: 17.0,
                              ),
                            ))),
                    Container(
                        height: 170,
                        margin: EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: hotelInfo.length,
                          itemBuilder: (BuildContext hotelContext, int index) {
                            if (hotelInfo[index]['label'] == 'Guests') {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(hotelInfo[index]['label'],
                                      style: substyle),
                                  buildTravelers(travelers)
                                ],
                              );
                            }
                            if (hotelInfo[index]['label'] ==
                                'Confirmation number') {
                              return Container(
                                  height: 35,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(hotelInfo[index]['label'],
                                          style: substyle),
                                      Text(hotelInfo[index]['value'],
                                          style: substyle)
                                    ],
                                  ));
                            }
                            return Container(
                                height: 35,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(hotelInfo[index]['label'],
                                        style: substyle),
                                    Text(
                                        DateFormat("MMMM d, y").format(
                                            DateTime.parse(
                                                hotelInfo[index]['value'])),
                                        style: substyle)
                                  ],
                                ));
                          },
                        ))
                  ]))
            ]));
    }
  }

  static Icon icon(String type) {
    switch (type) {
      case 'Air':
        return Icon(
          Icons.flight_takeoff,
          color: Colors.black.withOpacity(.3),
        );
      case 'Hotel':
        return Icon(
          Icons.hotel,
          color: Colors.black.withOpacity(.3),
        );
    }

    return null;
  }

  renderEmpty(dynamic destination) {
    return Stack(children: <Widget>[
      Center(
          child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      width: 270,
                      height: 270,
                      foregroundDecoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(.3),
                              Colors.white.withOpacity(1),
                              Colors.white.withOpacity(1),
                            ],
                            center: Alignment.center,
                            focal: Alignment.center,
                            radius: 1.05,
                          ),
                          borderRadius: BorderRadius.circular(130)),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('images/email-icon.jpg'),
                              fit: BoxFit.contain),
                          borderRadius: BorderRadius.circular(130))),
                  Text(
                    'Your missing details for ${destination["destination_name"]}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Forward your travel confirmation emails to trips@ajibade.me',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ))),
    ]);
  }
}
