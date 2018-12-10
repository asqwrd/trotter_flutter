import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Country extends StatefulWidget {
  final String countryId;
  Country({Key key, @required this.countryId}) : super(key: key);
  @override
  CountryState createState() => new CountryState(countryId:this.countryId);
}

Future<CountryData> fetchCountry(String id) async {
  print('Id $id');
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('country_$id') ?? null;
  if(cacheData != null) {
    await Future.delayed(const Duration(seconds: 1));
    return CountryData.fromJson(json.decode(cacheData));
  } else {
    final response = await http.get('http://localhost:3002/api/explore/countries/$id', headers:{'Authorization':'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      //await prefs.setString('country_$id', response.body);
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark));
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.resumed.toString()) {
        debugPrint('SystemChannels> $msg');
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark));
      }
    });
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
     _scrollController.addListener(() => setState(() {
       _showTitle =_scrollController.hasClients &&
        _scrollController.offset > kExpandedHeight - kToolbarHeight;
     }));
     var name = snapshot.data.country['name'];
     var image = snapshot.data.country['image'];
     var description_short = snapshot.data.country['description_short'];
     var color = Color(hexStringToHexInt(snapshot.data.color));
     print(color);

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
                  onPressed: () {  Navigator.pop(ctxt);},
                  tooltip: MaterialLocalizations.of(ctxt).openAppDrawerTooltip,
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
                          fontSize: 16.0,
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
        padding: EdgeInsets.only(top: 40.0),
        decoration: BoxDecoration(color: Colors.white),
        child: ListView(
          children: <Widget>[
                  
          ],
        )
      ),
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

  

