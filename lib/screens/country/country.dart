import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_panel/sliding_panel.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:trotter_flutter/widgets/vaccine-list/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/globals.dart';

Future<CountryData> fetchCountry(String id, String userId) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('country_$id') ?? null;
  final int cacheDataExpire = prefs.getInt('country_$id-expiration') ?? null;
  final currentTime = DateTime.now().millisecondsSinceEpoch;
  if (cacheData != null &&
      cacheDataExpire != null &&
      (currentTime < cacheDataExpire)) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return CountryData.fromJson(json.decode(cacheData));
  } else {
    try {
      print('no-cached');
      final response = await http.get(
          '$ApiDomain/api/explore/countries/$id?user_id=$userId',
          headers: {'Authorization': 'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('country_$id', response.body);
        await prefs.setInt('country_$id-expiration',
            DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch);
        return CountryData.fromJson(json.decode(response.body));
      } else {
        // If that response was not OK, throw an error.
        var msg = response.statusCode;
        return CountryData(error: 'Response> $msg');
      }
    } catch (error) {
      return CountryData(error: 'Server is down');
    }
  }
}

class CountryData {
  final String color;
  final Map<String, dynamic> country;
  final dynamic currency;
  final dynamic emergencyNumber;
  final List<dynamic> plugs;
  final dynamic safety;
  final dynamic visa;
  final dynamic popularDestinations;
  final String error;

  CountryData(
      {this.color,
      this.country,
      this.currency,
      this.emergencyNumber,
      this.plugs,
      this.safety,
      this.visa,
      this.popularDestinations,
      this.error});

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
        color: json['color'],
        country: json['country'],
        currency: json['currency'],
        emergencyNumber: json['emergency_number'],
        plugs: json['plugs'],
        safety: json['safety'],
        visa: json['visa'],
        popularDestinations: json['popular_destinations'],
        error: null);
  }
}

class Country extends StatefulWidget {
  final String countryId;
  final String userId;
  final ValueChanged<dynamic> onPush;
  Country({Key key, @required this.countryId, this.userId, this.onPush})
      : super(key: key);
  @override
  CountryState createState() => new CountryState(
      countryId: this.countryId, userId: this.userId, onPush: this.onPush);
}

class CountryState extends State<Country> {
  static String id;
  final String countryId;
  final String userId;
  final ValueChanged<dynamic> onPush;
  PanelController _pc = new PanelController();
  bool disableScroll = true;
  bool errorUi = false;
  bool loading = true;
  String image;
  Color color = Colors.black.withOpacity(.3);
  String countryName;
  bool imageLoading = true;
  bool shadow = false;

  Future<CountryData> data;
  var kExpandedHeight = 280;

  @override
  void initState() {
    super.initState();
    data = fetchCountry(this.countryId, this.userId);
    data.then((res) {
      setState(() {
        this.loading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  CountryState({this.countryId, this.userId, this.onPush});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    double _bodyHeight = (MediaQuery.of(context).size.height / 2) + 20;
    data.then((data) => {
          if (data.error != null)
            {
              setState(() {
                this.errorUi = true;
              })
            }
          else if (data.error == null)
            {
              setState(() {
                this.errorUi = false;
                this.image = data.country['image'];
                this.countryName = data.country['name'];
                this.color = Color(hexStringToHexInt(data.color));
              })
            }
        });

    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingPanel(
              initialState: this.errorUi == true
                  ? InitialPanelState.expanded
                  : InitialPanelState.closed,
              size: PanelSize(closedHeight: .45),
              isDraggable: this.errorUi == true ? false : true,
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
                          this.loading
                              ? Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: 10, bottom: 20),
                                  child: AutoSizeText(
                                    'Getting tips & requirements...',
                                    style: TextStyle(fontSize: 25),
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: 10, bottom: 20),
                                  child: AutoSizeText(
                                    'Tips & Requirements',
                                    style: TextStyle(fontSize: 25),
                                  ),
                                ),
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
                  return FutureBuilder(
                      future: data,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data.error != null) {
                          return ListView(
                              controller: _sc,
                              physics: disableScroll
                                  ? NeverScrollableScrollPhysics()
                                  : ClampingScrollPhysics(),
                              shrinkWrap: true,
                              children: <Widget>[
                                Container(
                                    height: _panelHeightOpen - 80,
                                    width: MediaQuery.of(context).size.width,
                                    child: ErrorContainer(
                                      onRetry: () {
                                        setState(() {
                                          data = fetchCountry(
                                              this.countryId, this.userId);
                                        });
                                      },
                                    ))
                              ]);
                        }
                        return _buildLoadedBody(context, snapshot, _sc);
                      });
                },
                bodyContent: Container(
                    height: _bodyHeight,
                    child: Stack(children: <Widget>[
                      Positioned(
                          width: MediaQuery.of(context).size.width,
                          height: _bodyHeight,
                          top: 0,
                          left: 0,
                          child: this.image != null
                              ? TransitionToImage(
                                  image: AdvancedNetworkImage(
                                    this.image,
                                    useDiskCache: true,
                                    cacheRule: CacheRule(
                                        maxAge: const Duration(days: 7)),
                                  ),
                                  loadingWidgetBuilder: (BuildContext context,
                                          double progress, test) =>
                                      Container(),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  placeholder: const Icon(Icons.refresh),
                                  enableRefresh: true,
                                  blendMode: BlendMode.overlay,
                                  loadedCallback: () async {
                                    await Future.delayed(Duration(seconds: 2));
                                    setState(() {
                                      this.imageLoading = false;
                                    });
                                  },
                                  loadFailedCallback: () async {
                                    await Future.delayed(Duration(seconds: 2));
                                    setState(() {
                                      this.imageLoading = false;
                                    });
                                  },
                                )
                              : Container()),
                      Positioned.fill(
                        top: 0,
                        left: 0,
                        child: Container(
                            color: this.imageLoading
                                ? this.color
                                : this.color.withOpacity(.3)),
                      ),
                      this.image == null || this.imageLoading == true
                          ? Positioned.fill(
                              top: -((_bodyHeight / 2) + 100),
                              // left: -50,
                              child: Center(
                                  child: Container(
                                      width: 250,
                                      child: TrotterLoading(
                                          file: 'assets/globe.flr',
                                          animation: 'flight',
                                          color: Colors.transparent))))
                          : Container()
                    ])),
              ))),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
            loading: loading,
            onPush: onPush,
            color: this.color,
            title: this.countryName,
            back: true,
          )),
    ]);
  }

// function for rendering view after data is loaded
  Widget _buildLoadedBody(
      BuildContext ctxt, AsyncSnapshot snapshot, ScrollController _sc) {
    if (snapshot.connectionState != ConnectionState.done) {
      return _buildLoadingBody(ctxt, _sc);
    }
    bool _showVisaTextual = false;
    bool _showVisaAllowedStay = false;
    bool _showVisa = false;
    bool _showVisaNotes = false;
    bool _showVisaPassportValid = false;
    bool _showVisaBlankPages = false;

    var name = snapshot.data.country['name'];
    var visa = snapshot.data.visa;
    var currency = snapshot.data.currency;
    var safety = snapshot.data.safety;
    var plugs = snapshot.data.plugs;
    var descriptionShort = snapshot.data.country['description_short'];
    var emergencyNumbers = snapshot.data.emergencyNumber;
    _showVisa = visa != null;
    _showVisaTextual = _showVisa &&
        visa['visa']['textual'] != null &&
        visa['visa']['textual']['text'] != null;
    _showVisaAllowedStay = _showVisa && visa['visa']['allowed_stay'].length > 0;
    _showVisaNotes = _showVisa &&
        visa['visa']['notes'] != null &&
        visa['visa']['notes'].length > 0;
    _showVisaPassportValid = _showVisa &&
        visa['passport'] != null &&
        visa['passport']['passport_validity'] != null;
    _showVisaBlankPages = _showVisa &&
        visa['passport'] != null &&
        visa['passport']['blank_pages'] != null;
    String ambulance = arrayString([
      ...emergencyNumbers['ambulance']['all'],
      ...emergencyNumbers['ambulance']['fixed'],
      ...emergencyNumbers['ambulance']['gsm']
    ]);
    String police = arrayString([
      ...emergencyNumbers['police']['all'],
      ...emergencyNumbers['police']['fixed'],
      ...emergencyNumbers['police']['gsm']
    ]);
    String fire = arrayString([
      ...emergencyNumbers['fire']['all'],
      ...emergencyNumbers['fire']['fixed'],
      ...emergencyNumbers['fire']['gsm']
    ]);
    String dispatch = arrayString([
      ...emergencyNumbers['dispatch']['all'],
      ...emergencyNumbers['dispatch']['fixed'],
      ...emergencyNumbers['dispatch']['gsm']
    ]);
    String europeanEmergencyNumber =
        arrayString(emergencyNumbers['european_emergency_number']);

    Color _getAdviceColor(double rating) {
      if (rating > 0 && rating < 2.5) {
        return Colors.green;
      } else if (rating >= 2.5 && rating < 3.5) {
        return Colors.blue;
      } else if (rating >= 3.5 && rating < 4.5) {
        return Colors.amber;
      }

      return Colors.red;
    }

    return Container(
        margin: EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
        height: MediaQuery.of(context).size.height,
        child: ListView(
          controller: _sc,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
                child: AutoSizeText(descriptionShort,
                    style: TextStyle(
                        fontSize: 13.0, fontWeight: FontWeight.w300))),
            _showVisa
                ? Container(
                    margin:
                        EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
                    decoration: BoxDecoration(
                      //color: this.color.withOpacity(.3),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AutoSizeText(
                                'VISA SNAPSHOT',
                                style: TextStyle(
                                  //color: fontContrast(this.color),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 13.0,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              _showVisaTextual
                                  ? _buildInfoParagraphBlock(
                                      ctxt,
                                      visa['visa']['textual'],
                                      'text',
                                      'Visa information ')
                                  : Container(),
                              _showVisaAllowedStay
                                  ? _buildInfoBlock(
                                      ctxt,
                                      visa['visa']['allowed_stay'],
                                      'Duration of stay ',
                                      'You are allowed to stay')
                                  : Container(),
                              _showVisaNotes
                                  ? _buildInfoParagraphBlock(ctxt, visa['visa'],
                                      'notes', 'Additional notes')
                                  : Container(),
                              _showVisaPassportValid
                                  ? _buildInfoBlock(
                                      ctxt,
                                      visa['passport']['passport_validity'],
                                      'Passport validity requirement',
                                      '')
                                  : Container(),
                              _showVisaBlankPages
                                  ? _buildInfoBlock(
                                      ctxt,
                                      visa['passport']['blank_pages'],
                                      'Blank passport pages requirement',
                                      '')
                                  : Container(),
                            ])))
                : Container(),
            _showVisa ? buildDivider() : Container(),
            Container(
              margin: EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: AutoSizeText(
                          'Health and Safety',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13.0),
                        )),
                    Container(
                        margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: AutoSizeText(safety['advice'],
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w300,
                                color: _getAdviceColor(
                                    safety['rating'].toDouble())))),
                    _showVisa
                        ? VaccineList(
                            vaccines: visa['vaccination'],
                            color: this.color.withOpacity(.3))
                        : Container(),
                  ]),
            ),
            buildDivider(),
            Container(
              margin: EdgeInsets.symmetric(vertical: 40.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: AutoSizeText(
                          'Emergency numbers',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15.0),
                        )),
                    Container(
                        padding: EdgeInsets.all(20.0),
                        margin: EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 0.0, bottom: 20.0),
                        decoration: BoxDecoration(
                          //color: this.color.withOpacity(.3),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ambulance.isNotEmpty
                                  ? _buildEmergencyNumRow(
                                      'Ambulance', ambulance)
                                  : Container(),
                              dispatch.isNotEmpty
                                  ? _buildEmergencyNumRow('Dispatch', dispatch)
                                  : Container(),
                              fire.isNotEmpty
                                  ? _buildEmergencyNumRow('Fire', fire)
                                  : Container(),
                              police.isNotEmpty
                                  ? _buildEmergencyNumRow('Police', police)
                                  : Container(),
                              europeanEmergencyNumber.isNotEmpty
                                  ? _buildEmergencyNumRow(
                                      'European Emergency Number',
                                      europeanEmergencyNumber)
                                  : Container(),
                            ])),
                    buildDivider(),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                  top: 40.0,
                                  bottom: 0.0),
                              child: AutoSizeText(
                                'Sockets & Plugs',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.0),
                              )),
                          Container(
                              padding: EdgeInsets.all(20.0),
                              margin: EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                  top: 0.0,
                                  bottom: 40.0),
                              decoration: BoxDecoration(
                                //color: this.color.withOpacity(.3),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Wrap(children: _getPlugs(plugs, name))),
                        ]),
                    this.userId.length > 0 ? buildDivider() : Container(),
                    this.userId.length > 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 40.0,
                                        bottom: 0.0),
                                    child: AutoSizeText(
                                      'Currency rates',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.0),
                                    )),
                                Container(
                                    padding: EdgeInsets.all(20.0),
                                    margin: EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 0.0,
                                        bottom: 40.0),
                                    decoration: BoxDecoration(
                                      //color: this.color.withOpacity(.3),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: _getCurrency(currency))
                              ])
                        : Container(),

                    /*TopList(
                    items: popularDestinations,
                    onPressed: (data){
                      print("Clicked ${data['id']}");
                      onPush({'id':data['id'], 'level':data['level']});
                    },
                    header: "Popular cities"
                  )*/
                  ]),
            ),
          ],
        ));
  }

  _getCurrency(dynamic currency) {
    return ListView(
      primary: false,
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
            title: AutoSizeText(
                'Currency in ${currency['converted_unit']['name']}',
                style: TextStyle(
                    //color: fontContrast(this.color),
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400)),
            trailing: AutoSizeText(currency['converted_unit']['currencyName'],
                style: TextStyle(
                    //color: fontContrast(this.color),
                    fontSize: 15.0,
                    fontWeight: FontWeight.w300))),
        ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
            title: AutoSizeText('1 ${currency['unit']['currencyName']}',
                style: TextStyle(
                    // color: fontContrast(this.color),
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400)),
            trailing: AutoSizeText(
                '${currency['converted_unit']['currencySymbol']}${currency['converted_currency']}',
                style: TextStyle(
                    //color: fontContrast(this.color),
                    fontSize: 15.0,
                    fontWeight: FontWeight.w300))),
      ],
    );
  }

  _getPlugs(List<dynamic> plugsData, String name) {
    var plugs = <Widget>[
      Container(
          margin: EdgeInsets.only(top: 10.0, bottom: 40.0),
          width: double.infinity,
          child: AutoSizeText(
            '$name uses a frequency of ${plugsData[0]['frequency']} and voltage of ${plugsData[0]['voltage']} in sockets.  Below are the types of plugs you need when traveling to $name.',
            style: TextStyle(
              fontSize: 15.0,
              //color: fontContrast(this.color),
              fontWeight: FontWeight.w400,
            ),
          ))
    ];
    for (var plug in plugsData) {
      plugs.add(Padding(
          padding: EdgeInsets.only(bottom: 0, right: 20.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'images/${plug['type']}.png',
                  width: 100.0,
                  height: 100.0,
                  //color: fontContrast(this.color)),
                ),
                AutoSizeText('Type ${plug['type']}',
                    style: TextStyle(fontSize: 15.0))
              ])));
    }
    return plugs;
  }

  _buildEmergencyNumRow(String label, String numbers) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AutoSizeText(label,
                style: TextStyle(
                    //color: fontContrast(this.color),
                    fontWeight: FontWeight.w500,
                    fontSize: 15.0)),
            AutoSizeText(numbers,
                style: TextStyle(
                    //color: fontContrast(this.color),
                    fontSize: 15.0,
                    fontWeight: FontWeight.w300))
          ],
        ));
  }

  Widget _buildInfoParagraphBlock(
      BuildContext ctx, dynamic obj, String key, String label) {
    return Padding(
        padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AutoSizeText(label,
                  style: TextStyle(
                      //color: fontContrast(this.color),
                      fontWeight: FontWeight.w700,
                      fontSize: 13.0)),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: AutoSizeText(
                    obj[key].join(' ').trim(),
                    style: TextStyle(
                        //color: fontContrast(this.color),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w300),
                  ))
            ]));
  }

  Widget _buildInfoBlock(
      BuildContext ctx, dynamic objValue, String label, String value) {
    return Padding(
        padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AutoSizeText(label,
                  style: TextStyle(
                    //color: fontContrast(this.color),
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                  )),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: AutoSizeText(
                    '$value $objValue'.trim(),
                    style: TextStyle(
                        //color: fontContrast(this.color),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w300),
                  ))
            ]));
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt, ScrollController _sc) {
    var children2 = <Widget>[
      Align(
          alignment: Alignment.topLeft,
          child: Container(
              width: MediaQuery.of(context).size.width - 30,
              child: TextLoading(
                  margin:
                      EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10)))),
      Align(
          alignment: Alignment.topLeft,
          child: Container(
              width: MediaQuery.of(context).size.width - 50,
              child: TextLoading(
                  margin:
                      EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10)))),
      Align(
          alignment: Alignment.topLeft,
          child: Container(
              width: MediaQuery.of(context).size.width - 100,
              child: TextLoading(
                  margin:
                      EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10)))),
      Shimmer.fromColors(
          baseColor: Color.fromRGBO(220, 220, 220, 0.8),
          highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
          child: Container(
            decoration: BoxDecoration(
                color: Color.fromRGBO(220, 220, 220, 0.8),
                borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20),
            height: 240.0,
          )),
      CarouselLoading(),
      CarouselLoading()
    ];
    return Container(
      padding: EdgeInsets.only(top: 0.0),
      decoration: BoxDecoration(color: Colors.transparent),
      child: ListView(
        controller: _sc,
        children: children2,
      ),
    );
  }
}
