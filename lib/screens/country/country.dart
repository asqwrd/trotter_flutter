import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/widgets/vaccine-list/index.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:cached_network_image/cached_network_image.dart';




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
  final dynamic popularDestinations;
 

  CountryData({this.color, this.country, this.currency, this.emergencyNumber,this.plugs, this.safety, this.visa, this.popularDestinations});

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
    );
  }
}


class Country extends StatefulWidget {
  final String countryId;
  final ValueChanged<dynamic> onPush;
  Country({Key key, @required this.countryId, this.onPush}) : super(key: key);
  @override
  CountryState createState() => new CountryState(countryId:this.countryId, onPush:this.onPush);
}

class CountryState extends State<Country> {
  bool _showTitle = false;
  static String id;
  final String countryId;
  final ValueChanged<dynamic> onPush;
  
  Future<CountryData> data;
  var kExpandedHeight = 280;

  final ScrollController _scrollController = ScrollController();
   

  @override
  void initState() {
     _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    super.initState();
    data = fetchCountry(this.countryId);
    
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }


  CountryState({
    this.countryId,
    this.onPush
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
  

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    
    bool _showVisaTextual = false;
    bool _showVisaAllowedStay = false;
    bool _showVisa = false;
    bool _showVisaNotes = false;
    bool _showVisaPassportValid = false;
    bool _showVisaBlankPages = false;
    
    var name = snapshot.data.country['name'];
    var image = snapshot.data.country['image'];
    var visa = snapshot.data.visa;
    var safety = snapshot.data.safety;
    var plugs = snapshot.data.plugs;
    var descriptionShort = snapshot.data.country['description_short'];
    var emergencyNumbers = snapshot.data.emergencyNumber;
    var popularDestinations = snapshot.data.popularDestinations;
    var color = Color(hexStringToHexInt(snapshot.data.color));
    _showVisa = visa != null;
    _showVisaTextual = _showVisa && visa['visa']['textual'] != null && visa['visa']['textual']['text'] != null;
    _showVisaAllowedStay = _showVisa && visa['visa']['allowed_stay'] != null;
    _showVisaNotes = _showVisa && visa['visa']['notes'] != null;
    _showVisaPassportValid = _showVisa && visa['passport'] != null  && visa['passport']['passport_validity'] != null;
    _showVisaBlankPages = _showVisa && visa['passport'] != null  && visa['passport']['blank_pages'] != null;
    String ambulance = arrayString(emergencyNumbers['ambulance']['all']);
    String police = arrayString(emergencyNumbers['police']['all']);
    String fire = arrayString(emergencyNumbers['fire']['all']);
    String dispatch = arrayString(emergencyNumbers['dispatch']['all']);
    String europeanEmergencyNumber = arrayString(emergencyNumbers['european_emergency_number']);

    Color _getAdviceColor(double rating){
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
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: _showTitle ? color : Colors.transparent,
            automaticallyImplyLeading: false,
            title: SearchBar(
              placeholder: 'Explore the world',
              leading: IconButton(
                padding: EdgeInsets.all(0),
                icon:  Icon(Icons.arrow_back),
                onPressed: () {  Navigator.pop(context);},
                iconSize: 30,
                color: Colors.white,
              ),
              onPressed: (){
                onPush({'query':'', 'level':'search'});
              },
                  
            ),
            bottom: PreferredSize(preferredSize: Size.fromHeight(15), child: Container(),),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: ClipPath(
                        clipper: BottomWaveClipper(),
                        child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                      )
                    )
                  ),
                  Positioned.fill(
                    top: 0,
                    left: 0,
                    child: ClipPath(
                      clipper: BottomWaveClipper(),
                      child: Container(
                        color: color.withOpacity(0.5),
                      )
                    )
                  ),
                  Positioned(
                    left: 0,
                    top: 180,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        Container(
                          margin: EdgeInsets.only(right:10.0),
                          child: SvgPicture.asset("images/trotter-logo.svg",
                            width: 50.0,
                            height: 50.0,
                            fit: BoxFit.contain
                          )
                        ),
                        Container(
                          //width: MediaQuery.of(context).size.width - 100,
                          child: Text(name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w300
                          )
                        ))
                      ]
                    )
                  ),
                ]
              )
            ),
          ),
        ];
      },
      body: Container(
        margin: EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
        decoration: BoxDecoration(color: Colors.white),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 40.0, left:20.0, right: 20.0),
              child: Text(
                descriptionShort, 
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300
                )
              )
            ),
            _showVisa ? Container(
              margin: EdgeInsets.only(bottom:40.0, left: 20.0, right: 20.0),
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
                        fontSize: 18.0,
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

            buildDivider(), 

            Container(
              margin: EdgeInsets.symmetric(vertical: 40.0), 
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child:Text(
                      'Health and Safety',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.0
                      ),
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(top:20.0, bottom:20.0),
                    padding: EdgeInsets.symmetric(horizontal:20.0),
                    child:Text(
                      safety['advice'],
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w300,
                        color: _getAdviceColor(safety['rating'].toDouble())
                      )
                    )
                  ),
                  VaccineList(vaccines: visa['vaccination']),
                ]
              ),
            ),

            buildDivider(),

            Container(
              margin: EdgeInsets.symmetric(vertical: 40.0), 
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child:Text(
                      'Emergency numbers',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.0
                      ),
                    )
                  ),
                  Container(
                    padding:EdgeInsets.all(20.0),
                    margin: EdgeInsets.only(left: 20.0, right:20.0, top: 20.0, bottom: 40.0 ),
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                        color: Colors.black,
                          width: 0.8,
                      )                
                    ),
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ambulance.isNotEmpty ? _buildEmergencyNumRow('Ambulance', ambulance):Container(),
                        dispatch.isNotEmpty ? _buildEmergencyNumRow('Dispatch', dispatch):Container(),
                        fire.isNotEmpty ? _buildEmergencyNumRow('Fire', fire):Container(),
                        police.isNotEmpty ? _buildEmergencyNumRow('Police', police):Container(),
                        europeanEmergencyNumber.isNotEmpty ? _buildEmergencyNumRow('European Emergency Number', europeanEmergencyNumber):Container(),
                      ] 
                    )
                  ),

                  buildDivider(),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 20.0, right:20.0, top: 40.0, bottom: 20.0 ),
                        child:Text(
                          'Sockets & Plugs',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20.0
                          ),
                        )
                      ),
                      Container(
                        padding:EdgeInsets.all(20.0),
                        margin: EdgeInsets.only(left: 20.0, right:20.0, top: 0.0, bottom: 40.0 ),
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color: Colors.black,
                              width: 0.8,
                          )                
                        ),
                        child:Wrap(
                          children: _getPlugs(plugs, name)
                        )
                      ),
                    ]
                  ),

                  /*TopList(
                    items: popularDestinations,
                    onPressed: (data){
                      print("Clicked ${data['id']}");
                      onPush({'id':data['id'], 'level':data['level']});
                    },
                    header: "Popular cities"
                  )*/

                ]
              ),
            ),
          ],
        )
      ),
    );
  }

  _getPlugs(List<dynamic> plugsData, String name) {
    var plugs = <Widget>[
      Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 40.0),
        width: double.infinity,
        child:Text(
          '$name uses a frequency of ${plugsData[0]['frequency']} and voltage of ${plugsData[0]['voltage']} in sockets.  Below are the types of plugs you need when traveling to $name.',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
          ),
        )
      )
    ];
    for (var plug in plugsData) {
      plugs.add(
        Padding(
          padding: EdgeInsets.only(bottom:20, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'images/${plug['type']}.png',
                width: 100.0,
                height: 100.0,
              ),
              Text(
                'Type ${plug['type']}',
                style: TextStyle(
                  fontSize: 20.0,
                )
              )
            ]
          )
        )
      );
    }
    return plugs;
  }

  _buildEmergencyNumRow(String label, String numbers){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20.0
            )
          ),
          Text(
            numbers,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w300
            )
          )
        ],
      
      )
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
            fontSize: 18.0
          )),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child:Text(
              obj[key].join(' ').trim(),
              style: TextStyle(
                fontSize: 18.0,
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
              fontWeight: FontWeight.w600,
              fontSize: 18.0,
            )
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child:Text('$value $objValue'.trim(),
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
 
    return NestedScrollView(
      //controller: _scrollControllerCountry,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              background: ClipPath(
                clipper: BottomWaveClipper(),
                child:Container(
                  color: Color.fromRGBO(240, 240, 240, 1)
                )
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

  

