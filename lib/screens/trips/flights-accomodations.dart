import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/trips/middleware.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/autocomplete/autocomplete.dart';
import 'package:trotter_flutter/widgets/flights-accomodation-list/index.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/travelers/travelers-modal.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:trotter_flutter/store/store.dart';

class FlightsAccomodations extends StatefulWidget {
  final String tripId;
  final bool isPast;
  final String currentUserId;
  final ValueChanged<dynamic> onPush;
  FlightsAccomodations(
      {Key key,
      @required this.tripId,
      this.currentUserId,
      this.isPast,
      this.onPush})
      : super(key: key);
  @override
  FlightsAccomodationsState createState() => new FlightsAccomodationsState(
      tripId: this.tripId,
      isPast: this.isPast,
      currentUserId: this.currentUserId,
      onPush: this.onPush);
}

class FlightsAccomodationsState extends State<FlightsAccomodations> {
  final String tripId;
  final String currentUserId;
  final ValueChanged<dynamic> onPush;
  Color color = Colors.blueGrey;
  bool isPast = false;
  String destinationName = '';
  dynamic destination;
  List<dynamic> itineraryItems = [];
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  String itineraryName;
  List<dynamic> flightsAccomodations;
  bool refreshParent = false;
  bool shadow = false;

  Future<FlightsAndAccomodationsData> data;

  @override
  void initState() {
    super.initState();
    data = fetchFlightsAccomodations(this.tripId, this.currentUserId);
    data.then((data) {
      if (data.error == null) {
        setState(() {
          this.loading = false;
          this.flightsAccomodations = data.flightsAccomodations;
        });
      } else {
        setState(() {
          this.errorUi = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  FlightsAccomodationsState(
      {this.tripId, this.currentUserId, this.onPush, this.isPast});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    var store = Provider.of<TrotterStore>(context);
    final panelHeights = getPanelHeights(context);

    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, {"refresh": this.refreshParent});
          return;
        },
        child: Stack(alignment: Alignment.topCenter, children: <Widget>[
          Positioned(
              child: SlidingUpPanel(
            backdropColor: color,
            backdropEnabled: true,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            backdropOpacity: 1,
            maxHeight: panelHeights.max,
            minHeight: panelHeights.max,
            isDraggable: false,
            defaultPanelState: PanelState.OPEN,
            parallaxEnabled: true,
            parallaxOffset: .5,
            controller: _pc,
            panelBuilder: (sc) {
              return Center(
                  child: Scaffold(
                      backgroundColor: Colors.transparent,
                      body: FutureBuilder(
                          future: data,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListView(
                                  shrinkWrap: true,
                                  controller: sc,
                                  children: <Widget>[
                                    Center(child: RefreshProgressIndicator())
                                  ]);
                            }
                            if (snapshot.hasData &&
                                snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data.error == null) {
                              return RenderWidget(
                                  scrollController: sc,
                                  asyncSnapshot: snapshot,
                                  onScroll: onScroll,
                                  builder: (context,
                                          {scrollController,
                                          asyncSnapshot,
                                          startLocation}) =>
                                      _buildLoadedBody(context, asyncSnapshot,
                                          scrollController));
                            } else if (snapshot.hasData &&
                                snapshot.data.error != null) {
                              return SingleChildScrollView(
                                  controller: sc,
                                  child: ErrorContainer(
                                    color: Color.fromRGBO(106, 154, 168, 1),
                                    onRetry: () {
                                      setState(() {
                                        data = fetchFlightsAccomodations(
                                            this.tripId, store.currentUser.uid);
                                        data.then((data) {
                                          if (data.error == null) {
                                            setState(() {
                                              this.flightsAccomodations =
                                                  data.flightsAccomodations;
                                            });
                                          }
                                        });
                                      });
                                    },
                                  ));
                            }
                            return ListView(
                                shrinkWrap: true,
                                controller: sc,
                                children: <Widget>[
                                  Center(child: RefreshProgressIndicator())
                                ]);
                          })));
            },
          )),
          Positioned(
              top: 0,
              width: MediaQuery.of(context).size.width,
              child: new TrotterAppBar(
                  loading: loading,
                  onPush: onPush,
                  color: color,
                  title: 'Travel logistics',
                  actions: <Widget>[
                    Container(
                        width: 58,
                        height: 58,
                        margin: EdgeInsets.symmetric(horizontal: 0),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          onPressed: () async {
                            setState(() {
                              this.loading = true;
                            });
                            final res = await fetchFlightsAccomodations(
                                this.tripId, this.currentUserId);
                            setState(() {
                              this.loading = false;
                              this.flightsAccomodations =
                                  res.flightsAccomodations;
                            });
                          },
                          child: SvgPicture.asset("images/refresh_icon.svg",
                              width: 24.0,
                              height: 24.0,
                              color: fontContrast(color),
                              fit: BoxFit.contain),
                        )),
                  ],
                  showSearch: false,
                  back: () =>
                      Navigator.pop(context, {"refresh": this.refreshParent}))),
        ]));
  }

  void onScroll(offset) {
    if (offset > 0) {
      setState(() {
        this.shadow = true;
      });
    } else {
      setState(() {
        this.shadow = false;
      });
    }
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot,
      ScrollController scrollController) {
    double _panelHeightOpen = MediaQuery.of(ctxt).size.height - 130;
    var tabContents = <Widget>[];
    for (var i = 0; i < this.flightsAccomodations.length; i++) {
      var destination = this.flightsAccomodations[i];
      tabContents.add(
        Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blueGrey,
              child: Icon(Icons.add),
              onPressed: () async {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return new Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ListTile(
                                leading: new Icon(Icons.flight_takeoff),
                                title: new AutoSizeText('Add flight detail'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  var res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          fullscreenDialog: true,
                                          builder: (context) {
                                            return FlightsFormModal(
                                                tripId: this.tripId,
                                                destination:
                                                    destination['destination']);
                                          }));
                                  if (res != null && res['success'] == true) {
                                    setState(() {
                                      this.loading = true;
                                    });
                                    final res = await fetchFlightsAccomodations(
                                        this.tripId, this.currentUserId);
                                    setState(() {
                                      this.loading = false;
                                      this.flightsAccomodations =
                                          res.flightsAccomodations;
                                    });
                                  }
                                }),
                            ListTile(
                                leading: new Icon(Icons.hotel),
                                title: new AutoSizeText('Add accommodations'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  var res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          fullscreenDialog: true,
                                          builder: (context) {
                                            return HotelsFormModal(
                                                tripId: this.tripId,
                                                destination:
                                                    destination['destination']);
                                          }));
                                  if (res != null && res['success'] == true) {
                                    setState(() {
                                      this.loading = true;
                                    });
                                    final res = await fetchFlightsAccomodations(
                                        this.tripId, this.currentUserId);
                                    setState(() {
                                      this.loading = false;
                                      this.flightsAccomodations =
                                          res.flightsAccomodations;
                                    });
                                  }
                                }),
                          ]);
                    });
              },
            ),
            body: FlightsAccomodationsList(
                destination: destination,
                readWrite: !isPast,
                controller: scrollController,
                onDeletePressed: (data) async {
                  final detailId = data['id'];
                  final destinationId = data['destinationId'];
                  final undoData = data['undoData'];
                  var store = Provider.of<TrotterStore>(context);
                  setState(() {
                    this.loading = true;
                  });
                  final response = await deleteFlightsAndAccomodations(
                      this.tripId,
                      destinationId,
                      detailId,
                      store.currentUser.uid);
                  if (response.success == true) {
                    var res = await fetchFlightsAccomodations(
                        this.tripId, this.currentUserId);
                    setState(() {
                      this.loading = false;
                      this.flightsAccomodations = res.flightsAccomodations;
                    });
                    Scaffold.of(this.context).showSnackBar(SnackBar(
                        content: AutoSizeText('Delete successful',
                            style: TextStyle(fontSize: 13)),
                        duration: Duration(seconds: 5),
                        action: SnackBarAction(
                          label: 'Undo',
                          textColor: color,
                          onPressed: () async {
                            setState(() {
                              this.loading = true;
                            });
                            var response = await postAddFlightsAndAccomodations(
                                this.tripId, destinationId, undoData);
                            if (response.success == true) {
                              var res = await fetchFlightsAccomodations(
                                  this.tripId, this.currentUserId);
                              setState(() {
                                this.loading = false;
                                this.flightsAccomodations =
                                    res.flightsAccomodations;
                              });
                            } else {
                              Scaffold.of(ctxt).removeCurrentSnackBar();
                              Scaffold.of(ctxt).showSnackBar(SnackBar(
                                  content: AutoSizeText(
                                      'Sorry the undo failed!',
                                      style: TextStyle(fontSize: 18)),
                                  duration: Duration(seconds: 2)));
                            }
                          },
                        )));
                  } else {
                    setState(() {
                      this.loading = false;
                    });
                    Scaffold.of(this.context).showSnackBar(SnackBar(
                      content: AutoSizeText('Unable to delete',
                          style: TextStyle(fontSize: 13)),
                      duration: Duration(seconds: 3),
                    ));
                  }
                },
                onAddPressed: (data) async {
                  final ownerId = data['ownerId'];
                  final store = Provider.of<TrotterStore>(context);
                  var dialogData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => TravelersModal(
                                ownerId: ownerId,
                                currentUserId: this.currentUserId,
                                tripId: this.tripId,
                                travelers: data['travelers'],
                                readWrite: !isPast,
                              )));
                  if (dialogData != null) {
                    final detailId = data['id'];
                    final destinationId = data['destinationId'];
                    setState(() {
                      this.loading = true;
                    });
                    final response =
                        await putUpdateFlightsAccommodationTravelers(
                            this.tripId,
                            destinationId,
                            detailId,
                            dialogData,
                            this.currentUserId);
                    if (response.error == null) {
                      fetchTrips(store);
                      var res = await fetchFlightsAccomodations(
                          this.tripId, this.currentUserId);
                      setState(() {
                        this.loading = false;
                        this.flightsAccomodations = res.flightsAccomodations;
                        this.refreshParent = true;
                      });
                    }
                  }
                })),
      );
    }
    return Container(
        height: _panelHeightOpen,
        width: MediaQuery.of(ctxt).size.width,
        child: Stack(children: <Widget>[
          DefaultTabController(
              length: this.flightsAccomodations.length,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30)),
                          boxShadow: this.shadow
                              ? <BoxShadow>[
                                  BoxShadow(
                                      color: Colors.black.withOpacity(.2),
                                      blurRadius: 10.0,
                                      offset: Offset(0.0, 0.75))
                                ]
                              : []),
                      alignment: Alignment.center,
                      child: RenderWidget(
                          builder: (context,
                                  {scrollController,
                                  asyncSnapshot,
                                  startLocation}) =>
                              _renderTabBar(Colors.blueGrey, Colors.black))),
                  Flexible(
                      child: Container(
                          width: MediaQuery.of(ctxt).size.width,
                          child: TabBarView(children: tabContents)))
                ],
              )),
          this.loading
              ? Center(
                  child: RefreshProgressIndicator(),
                )
              : Container()
        ]));
  }

  _renderTab(String label) {
    return AutoSizeText(label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w300,
        ));
  }

  _renderTabBar(Color mainColor, Color fontColor) {
    List<Widget> tabs = [];

    for (var section in this.flightsAccomodations) {
      tabs.add(
        Tab(
            child: RenderWidget(
                builder: (context,
                        {scrollController, asyncSnapshot, startLocation}) =>
                    _renderTab(section['destination']['destination_name']))),
      );
    }

    return TabBar(
      labelColor: mainColor,
      isScrollable: true,
      labelPadding: EdgeInsets.only(top: 20, right: 20, left: 20),
      unselectedLabelColor: Colors.black.withOpacity(0.6),
      indicator: BoxDecoration(
          border: Border(top: BorderSide(color: mainColor, width: 4.0))),
      tabs: tabs,
    );
  }
}

class FlightsFormModal extends StatefulWidget {
  final dynamic destination;
  final String tripId;
  FlightsFormModal({Key key, this.destination, this.tripId}) : super(key: key);
  @override
  FlightsFormModalState createState() => new FlightsFormModalState(
      tripId: this.tripId, destination: this.destination);
}

class FlightsFormModalState extends State<FlightsFormModal> {
  FlightsFormModalState({this.tripId, this.destination});
  GlobalKey<FormBuilderState> fbKey = new GlobalKey<FormBuilderState>();
  bool showDone = false;
  final dynamic destination;
  final String tripId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                //color: color,
                height: 80,
                child: TrotterAppBar(
                    title: 'Flight details',
                    back: true,
                    onPush: () {},
                    showSearch: false,
                    brightness: Brightness.light,
                    color: Colors.white)),
            Flexible(
                child: FlightsForm(
                    tripId: this.tripId, destination: this.destination))
          ],
        ));
  }
}

class FlightsForm extends StatefulWidget {
  final dynamic destination;
  final String tripId;
  FlightsForm({this.tripId, this.destination});

  @override
  FlightsFormState createState() =>
      new FlightsFormState(tripId: this.tripId, destination: this.destination);
}

class FlightsFormState extends State<FlightsForm> {
  GlobalKey<FormBuilderState> fbKey = new GlobalKey<FormBuilderState>();
  ValueChanged<dynamic> onAddReturn;
  ValueChanged<dynamic> onSubmit;
  bool showDone = false;
  List<dynamic> segments = [];
  AutoCompleteAirline airlineWidget;
  AutoCompleteAirport departWidget;
  AutoCompleteAirport arrivalWidget;
  final dynamic destination;
  final String tripId;
  bool saving = false;

  FlightsFormState({this.tripId, this.destination});

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: fbKey,
        initialValue: {},
        onChanged: (value) {},
        child: ListView(children: <Widget>[
          airlineWidget = AutoCompleteAirline(
            attribute: 'airline',
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FormBuilderTextField(
                validators: [
                  FormBuilderValidators.required(
                      errorText: 'Flight number is required')
                ],
                maxLines: 1,
                attribute: 'flight_number',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                  prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 5.0),
                      child: Icon(Icons.label, size: 15)),
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
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  hintText: 'Flight number',
                  hintStyle: TextStyle(fontSize: 13),
                ),
              )),
          departWidget = AutoCompleteAirport(
            attribute: 'origin',
            hintText: 'Search departure airport',
          ),
          TrotterDateTime(
            attribute: 'departure_datetime',
            hintText: 'Departure time',
          ),
          arrivalWidget = AutoCompleteAirport(
            attribute: 'destination',
            hintText: 'Search arrival airport',
          ),
          TrotterDateTime(
            attribute: 'arrival_datetime',
            hintText: 'Arrival time',
          ),
          Align(
              alignment: Alignment.center,
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  width: double.infinity,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(100.0),
                        side: BorderSide(color: Colors.blueGrey, width: 1)),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    color: Colors.transparent,
                    onPressed: saving
                        ? null
                        : () async {
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.

                            if (this.fbKey.currentState.validate()) {
                              setState(() {
                                //this.showDone = true;
                                var segment = fbKey.currentState.value;
                                segments.add({
                                  "airline": segment['airline']['name'],
                                  "arrival_datetime":
                                      segment['arrival_datetime'],
                                  "arrival_time_zone_id": segment['destination']
                                      ['time_zone_id'],
                                  "departure_datetime":
                                      segment['departure_datetime'],
                                  "departure_time_zone_id": segment['origin']
                                      ['time_zone_id'],
                                  "destination": segment['destination']['iata'],
                                  "destination_city_name":
                                      segment['destination']['city'],
                                  "destination_country": segment['destination']
                                      ['country'],
                                  "destination_lat": segment['destination']
                                      ['lat'],
                                  "destination_lon": segment['destination']
                                      ['lon'],
                                  "destination_name": segment['destination']
                                      ['name'],
                                  "flight_number": segment['flight_number'],
                                  "iata_code": segment['airline']["iata_code"],
                                  "origin": segment['origin']['iata'],
                                  "origin_city_name": segment['origin']['city'],
                                  "origin_country": segment['origin']
                                      ['country'],
                                  "origin_lat": segment['origin']['lat'],
                                  "origin_lon": segment['origin']['lon'],
                                  "origin_name": segment['origin']['name'],
                                  "type": 'Air'
                                });

                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: AutoSizeText(
                                      'Flight detail added. Click submit to save',
                                      style: TextStyle(fontSize: 13)),
                                  duration: Duration(seconds: 5),
                                ));

                                print(segments);
                                this.fbKey = new GlobalKey<FormBuilderState>();
                              });
                            }
                          },
                    child: AutoSizeText('Add layover or return flight',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Colors.blueGrey)),
                  ))),
          Align(
              alignment: Alignment.center,
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  width: double.infinity,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(100.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    color: Colors.blueGrey,
                    onPressed: saving
                        ? null
                        : () async {
                            final store = Provider.of<TrotterStore>(context);

                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (this.fbKey.currentState.validate()) {
                              var segment = fbKey.currentState.value;
                              //formatter = DateFormat().format(date)
                              segments.add({
                                "airline": segment['airline']['name'],
                                "arrival_datetime": segment['arrival_datetime'],
                                "arrival_time_zone_id": segment['destination']
                                    ['time_zone_id'],
                                "departure_datetime":
                                    segment['departure_datetime'],
                                "departure_time_zone_id": segment['origin']
                                    ['time_zone_id'],
                                "destination": segment['destination']['iata'],
                                "destination_city_name": segment['destination']
                                    ['city'],
                                "destination_country": segment['destination']
                                    ['country'],
                                "destination_lat": segment['destination']
                                    ['lat'],
                                "destination_lon": segment['destination']
                                    ['lon'],
                                "destination_name": segment['destination']
                                    ['name'],
                                "flight_number": segment['flight_number'],
                                "iata_code": segment['airline']["iata_code"],
                                "origin": segment['origin']['iata'],
                                "origin_city_name": segment['origin']['city'],
                                "origin_country": segment['origin']['country'],
                                "origin_lat": segment['origin']['lat'],
                                "origin_lon": segment['origin']['lon'],
                                "origin_name": segment['origin']['name'],
                                "type": 'Air'
                              });

                              print(segments);
                              var data = {
                                "source": segment['airline']['name'],
                                "segments": segments,
                                "travelers": [store.currentUser.uid],
                                "ownerId": store.currentUser.uid
                              };
                              setState(() {
                                this.saving = true;
                              });
                              var res = await postAddFlightsAndAccomodations(
                                  tripId, destination['id'], data);
                              if (res.success == true) {
                                Navigator.of(context).pop({"success": true});
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: AutoSizeText(
                                      'Flight details added successfully',
                                      style: TextStyle(fontSize: 13)),
                                  duration: Duration(seconds: 5),
                                ));
                              } else {
                                this.segments = [];
                                this.fbKey = new GlobalKey<FormBuilderState>();
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: AutoSizeText(
                                      'Failed to save details',
                                      style: TextStyle(fontSize: 13)),
                                  duration: Duration(seconds: 5),
                                ));
                              }
                              setState(() {
                                this.saving = false;
                              });
                            }
                          },
                    child: saving
                        ? AutoSizeText('Saving...',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                color: Colors.white))
                        : AutoSizeText('Submit',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                color: Colors.white)),
                  )))
        ]));
  }
}

class TrotterDateTime extends StatelessWidget {
  final ValueChanged<DateTime> onDatePicked;
  final String attribute;
  final String hintText;
  final DateFormat format;
  final InputType type;
  const TrotterDateTime(
      {Key key,
      this.onDatePicked,
      this.attribute,
      this.hintText,
      this.type,
      this.format})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: FormBuilderDateTimePicker(
        attribute: attribute,
        validators: [
          FormBuilderValidators.required(
              errorText: '$hintText field is required')
        ],
        valueTransformer: (date) {
          if (date is DateTime) {
            return DateFormat("yyyy-MM-ddTHH:mm:ss").format(date);
          }
          return date;
        },
        inputType: this.type != null ? this.type : InputType.both,
        format:
            this.format != null ? this.format : DateFormat("MMMM d, y hh:mm a"),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 20.0),
          prefixIcon: Padding(
              padding: EdgeInsets.only(left: 20.0, right: 5.0),
              child: Icon(Icons.calendar_today, size: 15)),
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
              borderSide: BorderSide(width: 0.0, color: Colors.transparent)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(width: 0.0, color: Colors.transparent)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(width: 0.0, color: Colors.transparent)),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

class HotelsFormModal extends StatefulWidget {
  final dynamic destination;
  final String tripId;
  HotelsFormModal({Key key, this.destination, this.tripId}) : super(key: key);
  @override
  HotelsFormModalState createState() => new HotelsFormModalState(
      tripId: this.tripId, destination: this.destination);
}

class HotelsFormModalState extends State<HotelsFormModal> {
  HotelsFormModalState({this.tripId, this.destination});
  GlobalKey<FormBuilderState> fbKey = new GlobalKey<FormBuilderState>();
  bool showDone = false;
  final dynamic destination;
  final String tripId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                //color: color,
                height: 80,
                child: TrotterAppBar(
                    title: 'Accomodations details',
                    back: true,
                    onPush: () {},
                    showSearch: false,
                    brightness: Brightness.light,
                    color: Colors.white)),
            Flexible(
                child: HotelsForm(
                    tripId: this.tripId, destination: this.destination))
          ],
        ));
  }
}

class CountryPickerForm extends StatelessWidget {
  final ValueChanged<DateTime> onDatePicked;
  final String attribute;
  final String hintText;
  const CountryPickerForm(
      {Key key, this.onDatePicked, this.attribute, this.hintText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderCustomField(
        validators: [
          FormBuilderValidators.required(errorText: 'Country is required')
        ],
        attribute: attribute,
        formField: FormField(
            builder: (FormFieldState<dynamic> field) =>
                Column(children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        color: Colors.blueGrey.withOpacity(0.08),
                        border: Border(
                            top: BorderSide(
                                color: field.hasError
                                    ? Colors.red
                                    : Colors.transparent),
                            left: BorderSide(
                                color: field.hasError
                                    ? Colors.red
                                    : Colors.transparent),
                            right: BorderSide(
                                color: field.hasError
                                    ? Colors.red
                                    : Colors.transparent),
                            bottom: BorderSide(
                                color: field.hasError
                                    ? Colors.red
                                    : Colors.transparent))),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: CountryCodePicker(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      onChanged: (CountryCode data) {
                        print(data.code);
                        field.didChange(data.code);
                      },
                      searchDecoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 20.0, right: 5.0),
                              child: Icon(Icons.home, size: 15)),
                          //fillColor: Colors.blueGrey.withOpacity(0.5),
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
                          disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(
                                  width: 0.0, color: Colors.transparent)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(
                                  width: 0.0, color: Colors.transparent)),
                          hintText: 'Search country',
                          hintStyle: TextStyle(fontSize: 13)),
                      showOnlyCountryWhenClosed: true,
                      showCountryOnly: true,
                      alignLeft: true,
                    ),
                  ),
                  field.hasError
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              margin: EdgeInsets.only(
                                  left: 20, right: 20, bottom: 10),
                              child: AutoSizeText(
                                field.errorText,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13),
                              )))
                      : Container()
                ])));
  }
}

class HotelsForm extends StatefulWidget {
  final dynamic destination;
  final String tripId;
  HotelsForm({this.tripId, this.destination});

  @override
  HotelsFormState createState() =>
      new HotelsFormState(tripId: this.tripId, destination: this.destination);
}

class HotelsFormState extends State<HotelsForm> {
  GlobalKey<FormBuilderState> fbKey = new GlobalKey<FormBuilderState>();
  ValueChanged<dynamic> onAddReturn;
  ValueChanged<dynamic> onSubmit;
  bool showDone = false;
  List<dynamic> segments = [];
  AutoCompleteAirline airlineWidget;
  AutoCompleteAirport departWidget;
  AutoCompleteAirport arrivalWidget;
  final dynamic destination;
  final String tripId;
  bool saving = false;

  HotelsFormState({this.tripId, this.destination});

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: fbKey,
        initialValue: {},
        onChanged: (value) {},
        child: ListView(children: <Widget>[
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FormBuilderTextField(
                validators: [
                  FormBuilderValidators.required(errorText: 'Name is required')
                ],
                maxLines: 1,
                attribute: 'hotel_name',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                  prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 5.0),
                      child: Icon(Icons.label, size: 15)),
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
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  hintText: 'Name of place',
                  hintStyle: TextStyle(fontSize: 13),
                ),
              )),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FormBuilderTextField(
                validators: [
                  FormBuilderValidators.required(
                      errorText: 'Address is required')
                ],
                maxLines: 1,
                attribute: 'address1',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                  prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 5.0),
                      child: Icon(Icons.home, size: 15)),
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
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  hintText: 'Address',
                  hintStyle: TextStyle(fontSize: 13),
                ),
              )),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FormBuilderTextField(
                maxLines: 1,
                attribute: 'address2',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                  prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 5.0),
                      child: Icon(Icons.home, size: 15)),
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
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  hintText: 'Address 2',
                  hintStyle: TextStyle(fontSize: 13),
                ),
              )),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FormBuilderTextField(
                validators: [
                  FormBuilderValidators.required(errorText: 'City is required')
                ],
                maxLines: 1,
                attribute: 'city_name',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                  prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 5.0),
                      child: Icon(Icons.location_city, size: 15)),
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
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  hintText: 'City',
                  hintStyle: TextStyle(fontSize: 13),
                ),
              )),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FormBuilderTextField(
                validators: [
                  FormBuilderValidators.required(
                      errorText: 'Postal code is required')
                ],
                maxLines: 1,
                keyboardType: TextInputType.number,
                attribute: 'postal_code',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                  prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 5.0),
                      child: Icon(Icons.local_post_office, size: 15)),
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
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  hintText: 'Postal code',
                  hintStyle: TextStyle(fontSize: 13),
                ),
              )),
          CountryPickerForm(
            attribute: 'country',
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FormBuilderTextField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                attribute: 'confirmation_no',
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                  prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 20.0, right: 5.0),
                      child: Icon(Icons.confirmation_number, size: 15)),
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
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(width: 0.0, color: Colors.transparent)),
                  hintText: 'Confirmation number',
                  hintStyle: TextStyle(fontSize: 13),
                ),
              )),
          TrotterDateTime(
              attribute: 'checkin_date',
              hintText: 'Checkin date',
              format: DateFormat("MMMM d, y"),
              type: InputType.date),
          TrotterDateTime(
              attribute: 'checkout_date',
              hintText: 'Checkout date',
              format: DateFormat("MMMM d, y"),
              type: InputType.date),
          Align(
              alignment: Alignment.center,
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  width: double.infinity,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(100.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    color: Colors.blueGrey,
                    onPressed: saving
                        ? null
                        : () async {
                            final store = Provider.of<TrotterStore>(context);

                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (this.fbKey.currentState.validate()) {
                              var segment = fbKey.currentState.value;
                              //formatter = DateFormat().format(date)
                              segments = [
                                {...segment, "type": 'Hotel'}
                              ];

                              print(segments);
                              var data = {
                                "source": "Trotter",
                                "segments": segments,
                                "travelers": [store.currentUser.uid],
                                "ownerId": store.currentUser.uid
                              };
                              setState(() {
                                this.saving = true;
                              });
                              var res = await postAddFlightsAndAccomodations(
                                  tripId, destination['id'], data);
                              if (res.success == true) {
                                Navigator.of(context).pop({"success": true});
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: AutoSizeText(
                                      'Accomodation added successfully',
                                      style: TextStyle(fontSize: 13)),
                                  duration: Duration(seconds: 5),
                                ));
                              } else {
                                this.segments = [];
                                this.fbKey = new GlobalKey<FormBuilderState>();
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: AutoSizeText(
                                      'Failed to save details',
                                      style: TextStyle(fontSize: 13)),
                                  duration: Duration(seconds: 5),
                                ));
                              }
                              setState(() {
                                this.saving = false;
                              });
                            }
                          },
                    child: saving
                        ? AutoSizeText('Saving...',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                color: Colors.white))
                        : AutoSizeText('Submit',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                                color: Colors.white)),
                  )))
        ]));
  }
}
