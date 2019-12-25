import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:duration/duration.dart';
import 'package:trotter_flutter/globals.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/widgets/map/static-map.dart';

class FlightsAccomodationsList extends StatelessWidget {
  final dynamic destination;
  final ValueChanged onAddPressed;
  final ValueChanged onDeletePressed;
  final double height;
  final ScrollController controller;
  final ScrollPhysics physics;
  final bool readWrite;

  //passing props in react style
  FlightsAccomodationsList(
      {this.destination,
      this.onAddPressed,
      this.onDeletePressed,
      this.controller,
      this.physics,
      this.height,
      this.readWrite});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return buildTimeLine(context, this.destination);
  }

  Widget buildTimeLine(BuildContext context, dynamic item) {
    final details = item['details'];
    final destination = item['destination'];
    if (details.length == 0) {
      return renderEmpty(context, destination);
    }
    return Container(
        height: this.height ?? this.height,
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.only(top: 0.0),
        decoration: BoxDecoration(color: Colors.transparent),
        child: ListView.builder(
          controller: this.controller != null ? this.controller : null,
          shrinkWrap: true,
          primary: false,
          itemCount: details.length,
          itemBuilder: (BuildContext listContext, int index) {
            final segments = details[index]['segments'];
            final travelers = details[index]['travelers_full'];
            final store = Provider.of<TrotterStore>(context);

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(bottom: 0),
                      child: ListTile(
                        trailing: store.currentUser.uid ==
                                    details[index]['ownerId'] &&
                                readWrite == true
                            ? IconButton(
                                icon: Icon(EvilIcons.trash),
                                iconSize: 27,
                                onPressed: () {
                                  this.onDeletePressed({
                                    "id": details[index]['id'],
                                    "destinationId": destination['id'],
                                    'undoData': details[index]
                                  });
                                },
                              )
                            : Container(width: 20, height: 20),
                        title: AutoSizeText(
                            '${details[index]['source'].length > 0 ? details[index]['source'] : "Travel itinerary"}',
                            style: TextStyle(fontSize: 17)),
                      )),
                  readWrite == true
                      ? Container(
                          margin: EdgeInsets.only(top: 0, left: 10, bottom: 20),
                          width: 250,
                          child: InkWell(
                              onTap: () {
                                this.onAddPressed({
                                  "id": details[index]['id'],
                                  "destinationId": destination['id'],
                                  "travelers": travelers,
                                  "index": index,
                                  "ownerId": details[index]['ownerId']
                                });
                              },
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(0),
                                      margin: EdgeInsets.only(top: 0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: Colors.transparent),
                                      child: SvgPicture.asset(
                                          'images/edit-icon.svg',
                                          color: Colors.blueAccent,
                                          width: 20,
                                          height: 20),
                                    ),
                                    AutoSizeText('Edit travelers',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.blueAccent))
                                  ])))
                      : Container(),
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
                          return Container(
                              margin: EdgeInsets.only(bottom: 45),
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
        fontSize: 23, color: Colors.black, fontWeight: FontWeight.w400);
    TextStyle topstyle = TextStyle(
        fontSize: 18, color: Colors.black, fontWeight: FontWeight.w200);
    TextStyle substyle = TextStyle(
        fontSize: 11, color: Colors.black, fontWeight: FontWeight.w300);
    TextStyle substyle2 = TextStyle(
        fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.w300);

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
                padding: EdgeInsets.symmetric(horizontal: 0),
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
                            Container(
                                width: MediaQuery.of(context).size.width / 1.4,
                                child: AutoSizeText(
                                  segment['origin_name'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: topstyle,
                                )),
                            AutoSizeText(
                              segment['origin_city_name'],
                              style: style,
                            ),
                            AutoSizeText(
                              segment['origin_country'],
                              style: topstyle,
                            ),
                            AutoSizeText(
                              DateFormat("MMMM d, y hh:mm a").format(
                                  DateTime.parse(
                                      segment['departure_datetime'])),
                              style: substyle,
                            ),
                            segment['confirmation_no'] != null
                                ? GestureDetector(
                                    onLongPress: () {
                                      Clipboard.setData(new ClipboardData(
                                          text: segment['confirmation_no']));
                                      Scaffold.of(context)
                                          .showSnackBar(new SnackBar(
                                        duration: Duration(seconds: 2),
                                        content:
                                            new Text("Copied to Clipboard"),
                                      ));
                                    },
                                    child: AutoSizeText(
                                      'Confirmation #: ${segment['confirmation_no']}',
                                      style: substyle2,
                                    ))
                                : Container(),
                            Container(
                                margin: EdgeInsets.only(top: 60),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      AutoSizeText(
                                          '${travelers.length} ${travelers.length > 1 ? 'people' : 'person'} traveling'),
                                      Container(
                                          width: 30,
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
                                  Container(
                                      width: 128,
                                      child: AutoSizeText(
                                          "${segment['airline']} flight ${segment['iata_code']}${segment['flight_number']}",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400))),
                                  Container(
                                      width: 28,
                                      height: 1,
                                      margin:
                                          EdgeInsets.only(left: 0, right: 15),
                                      color: Colors.black.withOpacity(0.3)),
                                  Container(
                                      width: 100,
                                      child: AutoSizeText("$timeInAir in air",
                                          maxLines: 3,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300))),
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
                            Container(
                                width: MediaQuery.of(context).size.width / 1.4,
                                child: AutoSizeText(
                                  segment['destination_name'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: topstyle,
                                )),
                            AutoSizeText(segment['destination_city_name'],
                                style: style),
                            AutoSizeText(
                              segment['destination_country'],
                              style: topstyle,
                            ),
                            AutoSizeText(
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
          {"label": "Confirmation no", "value": segment['confirmation_no']},
          {
            "label": "Address",
            "value":
                '${segment['address1']}${segment['address2'] != null ? ' ${segment['address2']}' : ''} ${segment['city_name']}, ${segment['country']} ${segment['postal_code'] != null ? segment['postal_code'] : ''}'
          },
          {'label': "Guests", "value": travelers}
        ];
        String address = '';
        if (segment['address1'] != null && segment['postal_code'] != null) {
          address =
              '${segment['address1']}${segment['address2'] != null ? ' ${segment['address2']}' : ''} ${segment['city_name']}, ${segment['country']} ${segment['postal_code']}';
        }

        final lat = segment['lat'] != null
            ? double.tryParse(segment['lat']) ?? null
            : null;
        final lon = segment['lon'] != null
            ? double.tryParse(segment['lon']) ?? null
            : null;
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 0),
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
                        child: AutoSizeText(segment['hotel_name'],
                            style: topstyle)),
                    lat != null && lon != null
                        ? Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            child: StaticMap(GOOGLE_API_KEY,
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                color: Colors.blueGrey,
                                zoom: 18,
                                lat: lat,
                                lng: lon))
                        : address != null
                            ? Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                child: StaticMap(
                                  GOOGLE_API_KEY,
                                  width: MediaQuery.of(context).size.width,
                                  height: 200,
                                  color: Colors.blueGrey,
                                  zoom: 18,
                                  address: address,
                                ))
                            : Container(),
                    Container(
                        constraints: BoxConstraints(minHeight: 170),
                        //height: 170,
                        margin: EdgeInsets.only(top: 10),
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: hotelInfo.length,
                          itemBuilder: (BuildContext hotelContext, int index) {
                            if (hotelInfo[index]['label'] == 'Guests') {
                              return ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 0),
                                  title: AutoSizeText(hotelInfo[index]['label'],
                                      style: substyle),
                                  trailing: buildTravelers(travelers));
                            }
                            if ((hotelInfo[index]['label'] ==
                                        'Confirmation no' &&
                                    hotelInfo[index]['value'] != null ||
                                (hotelInfo[index]['label'] == 'Address' &&
                                    hotelInfo[index]['value'] != null))) {
                              return Container(
                                  constraints: BoxConstraints(minHeight: 35),
                                  //height: 35,
                                  child: ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 0),
                                      title: AutoSizeText(
                                          hotelInfo[index]['label'],
                                          style: substyle),
                                      trailing: Container(
                                          width: 150,
                                          child: GestureDetector(
                                              onLongPress: () {
                                                Clipboard.setData(
                                                    new ClipboardData(
                                                        text: hotelInfo[index]
                                                            ['value']));
                                                Scaffold.of(context)
                                                    .showSnackBar(new SnackBar(
                                                  duration:
                                                      Duration(seconds: 2),
                                                  content: new Text(
                                                      "Copied to Clipboard"),
                                                ));
                                              },
                                              child: AutoSizeText(
                                                  hotelInfo[index]['value'],
                                                  textAlign: TextAlign.right,
                                                  style: substyle2)))));
                            }
                            return Container(
                                constraints: BoxConstraints(minHeight: 35),
                                child: ListTile(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    title: AutoSizeText(
                                        hotelInfo[index]['label'],
                                        style: substyle),
                                    trailing: hotelInfo[index]['value'] != null
                                        ? AutoSizeText(
                                            DateFormat("MMMM d, y").format(
                                                DateTime.parse(
                                                    hotelInfo[index]['value'])),
                                            style: substyle)
                                        : AutoSizeText("Not given",
                                            style: substyle)));
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

  renderEmpty(BuildContext context, dynamic destination) {
    return Stack(children: <Widget>[
      SingleChildScrollView(
          controller: controller,
          child: Container(
              height: MediaQuery.of(context).size.height / 1.5,
              alignment: Alignment.center,
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AutoSizeText(
                    'Forward your travel confirmation emails to trips@ajibade.me or manually add them',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w300),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2,
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
                              image: AssetImage('images/email-icon2.png'),
                              fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(130))),
                  AutoSizeText(
                    'Forwarded emails will appear in notifications. You can add them to your trip from notifications',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 10),
                  AutoSizeText(
                    'Protip: Change the subject text before forwarding your email so you can find the correct notification for this destination. ie - Flight for ${destination["destination_name"]}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ))),
    ]);
  }
}
