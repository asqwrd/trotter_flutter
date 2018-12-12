import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/widgets/vaccine-list/index.dart';

Future<CountryData> fetchCountry(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('country_$id') ?? null;
  if(cacheData != null) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return CountryData.fromJson(json.decode(cacheData));
  } else {
    print('no-cached');
    final response = await http.get('http://localhost:3002/api/explore/countries/$id', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      await prefs.setString('country_$id', response.body);
      return CountryData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      throw Exception('Response> $msg');
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
 

  CountryData({this.color, this.country, this.currency, this.emergencyNumber,this.plugs, this.safety, this.visa});

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      color: json['color'],
      country: json['country'],
      currency: json['currency'],
      emergencyNumber: json['emergency_number'],
      plugs: json['plugs'],
      safety: json['safety'],
      visa: json['visa'],
    );
  }
}

const kExpandedHeight = 450.0;

class Country extends StatefulWidget {
  final String countryId;
  Country({Key key, @required this.countryId}) : super(key: key);
  @override
  CountryState createState() => new CountryState(countryId:this.countryId);
}

class CountryState extends State<Country> {
  bool _showTitle = false;
  static String id;
  final String countryId;
  Future<CountryData> data;

  @override
  void initState() {
    super.initState();
    data = fetchCountry(this.countryId);
    
  }

  CountryState({
    this.countryId,
  });

  


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildLoadedBody(context,snapshot);
          }
          return _buildLoadingBody(context);
        }
      )
    );
  }

  hexStringToHexInt(String hex) {
  hex = hex.replaceFirst('#', '');
  hex = hex.length == 6 ? 'ff' + hex : hex;
  int val = int.parse(hex, radix: 16);
  return val;
}

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    final ScrollController _scrollController = ScrollController();
    bool _showVisaTextual = false;
    bool _showVisaAllowedStay = false;
    bool _showVisa = false;
    bool _showVisaNotes = false;
    bool _showVisaPassportValid = false;
    bool _showVisaBlankPages = false;

    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    var name = snapshot.data.country['name'];
    var image = snapshot.data.country['image'];
    var visa = snapshot.data.visa;
    var safety = snapshot.data.safety;
    var descriptionShort = snapshot.data.country['description_short'];
    var color = Color(hexStringToHexInt(snapshot.data.color));
    _showVisa = visa != null;
    _showVisaTextual = _showVisa && visa['visa']['textual'] != null;
    _showVisaAllowedStay = _showVisa && visa['visa']['allowed_stay'] != null;
    _showVisaNotes = _showVisa && visa['visa']['notes'] != null;
    _showVisaPassportValid = _showVisa && visa['passport'] != null  && visa['passport']['passport_validity'] != null;
    _showVisaBlankPages = _showVisa && visa['passport'] != null  && visa['passport']['blank_pages'] != null;

    Color _getAdviceColor(int rating){
      if(rating > 0 && rating < 2.5){
        return Colors.green;
      } else if(rating >= 2.5 && rating < 3.5){
        return Colors.blue;
      } else if(rating >= 3.5 && rating < 4.5){
        return Colors.amber;
      }

      return Colors.red;
    }
    


    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 500.0,
            floating: false,
            pinned: true,
            backgroundColor: color,
            automaticallyImplyLeading: false,
            leading: Padding(
                padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 0.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {  Navigator.pop(context);},
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                  iconSize: 40,
                )
            ),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                title: _showTitle
                    ? Text(name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ))
                    : null,
                background: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                      )),
                  Positioned.fill(
                      top: 0,
                      left: 0,
                      child: Container(
                        color: color.withOpacity(0.4),
                      )),
                  Positioned(
                    right: 20,
                    top: 30,
                    child: Image.asset("images/logo_nw.png",
                        width: 55.0,
                        height: 55.0,
                        fit: BoxFit.contain),
                  ),
                  Positioned(
                    left: 20,
                    top: 250,
                    child: Text(name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w300
                      )
                    )
                  ),
                ]
              )
            ),
          ),
        ];
      },
      body: Container(
        padding: EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
        decoration: BoxDecoration(color: Colors.white),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Text(
                descriptionShort, 
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w300
                )
              )
            ),
            _showVisa ? Container(
              margin: EdgeInsets.only(bottom:40.0),
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: Colors.black,
                    width: 0.8,
                )                
              ),
              child: Padding(
                padding:EdgeInsets.all(20.0),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'VISA SNAPSHOT',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    _showVisaTextual ? _buildInfoParagraphBlock(ctxt, visa['visa']['textual'], 'text', 'Visa information ') : Container(),             
                    _showVisaAllowedStay ? _buildInfoBlock(ctxt, visa['visa']['allowed_stay'], 'Duration of stay ', 'You are allowed to stay') : Container(),             
                    _showVisaNotes ? _buildInfoParagraphBlock(ctxt, visa['visa'], 'notes', 'Additional notes') : Container(),
                    _showVisaPassportValid ? _buildInfoBlock(ctxt, visa['passport']['passport_validity'], 'Passport validity requirement',''): Container(),  

                    _showVisaBlankPages ? _buildInfoBlock(ctxt, visa['passport']['blank_pages'], 'Blank passport pages requirement', '') : Container(),
                  ] 
                )
              )
            ):Container(),
            Divider(color: Colors.grey),  
            Container(
              margin: EdgeInsets.symmetric(vertical: 40.0), 
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Health and Safety',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 25.0
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top:20.0, bottom:20.0),
                    child:Text(
                      safety['advice'],
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w300,
                        color: _getAdviceColor(safety['rating'])
                      )
                    )
                  ),
                  VaccineList(vaccines: visa['vaccination']),
                  
                  Text('gdfgljdlgjkldjfgld')
                ]
              ),
            )
          ],
        )
      ),
    );
  }

  Widget _buildInfoParagraphBlock(BuildContext ctx, dynamic obj, String key, String label) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0, bottom:5.0),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label, 
            style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20.0
          )),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child:Text(
              obj[key].join(' '),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w300
              ),
            )
          )
        ]
      )
    );                
  }

  Widget _buildInfoBlock(BuildContext ctx, dynamic objValue, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 20.0, bottom:5.0),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label, 
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20.0,
            )
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child:Text('$value $objValue',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w300
              ),
            )
          )
        ]
      )
    );                
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {

    final ScrollController _scrollController = ScrollController();
     _scrollController.addListener(() => setState(() {
       _showTitle =_scrollController.hasClients &&
        _scrollController.offset > kExpandedHeight - kToolbarHeight;
     }));

    return NestedScrollView(
      //controller: _scrollControllerCountry,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            backgroundColor: Color.fromRGBO(194, 121, 73, 1),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              background: Container(
                color: Color.fromRGBO(240, 240, 240, 1)
              ),
            ),
          ),
        ];
      },
      body: Container(
        padding: EdgeInsets.only(top: 40.0),
        decoration: BoxDecoration(color: Colors.white),
        child: ListView(
          children: <Widget>[
            Container(
              height: 175.0,
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 30.0),
              child: TopListLoading()
            ),
            Container(
              height: 175.0,
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 30.0),
              child: TopListLoading()
            ),
          ],
        )
      ),
    );
  }
}

  

