import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/errors/index.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/widgets/searchbar/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/vaccine-list/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trotter_flutter/widgets/itineraries/index.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';




Future<CityStateData> fetchCityState(String id) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('cityState_$id') ?? null;
  if(cacheData != null) {
    print('cached');
    await Future.delayed(const Duration(seconds: 1));
    return CityStateData.fromJson(json.decode(cacheData));
  } else {
    try {
      print('no-cached');
      final response = await http.get('http://localhost:3002/api/explore/city_states/$id/', headers:{'Authorization':'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('cityState_$id', response.body);
        return CityStateData.fromJson(json.decode(response.body));
      } else {
        // If that response was not OK, throw an error.
        var msg = response.statusCode;
        return CityStateData(error:'Response> $msg');
      }
    } catch(error){
      return CityStateData(error:'Server is down');
    }
    
  }
}

class CityStateData {
  final String color;
  final Map<String, dynamic> cityState;
  final List<dynamic> discover;
  final List<dynamic> discoverLocations;
  final List<dynamic> eat;
  final List<dynamic> eatLocations;
  final List<dynamic> nightlife;
  final List<dynamic> nightlifeLocations;
  final List<dynamic> play;
  final List<dynamic> playLocations;
  final List<dynamic> relax;
  final List<dynamic> relaxLocations;
  final List<dynamic> see;
  final List<dynamic> seeLocations;
  final List<dynamic> shop;
  final List<dynamic> shopLocations;
  final dynamic currency;
  final dynamic emergencyNumber;
  final List<dynamic> plugs;
  final dynamic safety;
  final dynamic visa;
  final String error;
 

  CityStateData({
    this.color, 
    this.cityState, 
    this.discover, 
    this.eat,
    this.nightlife, 
    this.play, 
    this.relax, 
    this.see,
    this.shop,
    this.discoverLocations,
    this.eatLocations,
    this.nightlifeLocations,
    this.playLocations,
    this.relaxLocations,
    this.seeLocations,
    this.shopLocations,
    this.currency, 
    this.emergencyNumber,
    this.plugs, 
    this.safety, 
    this.visa,
    this.error
  });

  factory CityStateData.fromJson(Map<String, dynamic> json) {
    return CityStateData(
      color: json['color'],
      cityState: json['city_state'],
      discover: json['city_state_places']['discover'],
      eat: json['city_state_places']['eat'],
      nightlife: json['city_state_places']['nightlife'],
      play: json['city_state_places']['play'],
      relax: json['city_state_places']['relax'],
      see: json['city_state_places']['see'],
      shop: json['city_state_places']['shop'],
      currency: json['currency'],
      emergencyNumber: json['emergency_number'],
      plugs: json['plugs'],
      safety: json['safety'],
      visa: json['visa'],
      error: null
    );
  }
}

class CityState extends StatefulWidget {
  final String cityStateId;
  final ValueChanged<dynamic> onPush;
  CityState({Key key, @required this.cityStateId, this.onPush}) : super(key: key);
  @override
  CityStateState createState() => new CityStateState(cityStateId:this.cityStateId, onPush:this.onPush);
}

class CityStateState extends State<CityState> with SingleTickerProviderStateMixin{
  bool _showTitle = false;
  static String id;
  final String cityStateId;
  Future<CityStateData> data;
  TabController _tabController;
  final ValueChanged<dynamic> onPush;
  var kExpandedHeight = 200;
    final ScrollController _scrollController = ScrollController();
    
      
  


  @override
  void initState() {
    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    super.initState();
    _tabController = TabController(vsync: this, length: 8);
    data = fetchCityState(this.cityStateId);
    
  }

  CityStateState({
    this.cityStateId,
    this.onPush
  });

 @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return _buildLoadingBody(context);
          }
          if (snapshot.hasData && snapshot.data.error == null) {
            return _buildLoadedBody(context,snapshot);
          } else if (snapshot.hasData && snapshot.data.error != null) {
            return ErrorContainer(
              onRetry: () {
                setState(() {
                  data = fetchCityState(this.cityStateId);
                });
              },
            );
          }
          return _buildLoadingBody(context);
        }
      )
    );
  }
// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot) {
    

    var name = snapshot.data.cityState['name'];
    var destination = snapshot.data.cityState;
    var image = snapshot.data.cityState['image'];
    var color = Color(hexStringToHexInt(snapshot.data.color));
    var discover = snapshot.data.discover;
    var see = snapshot.data.see;
    var eat = snapshot.data.eat;
    var relax = snapshot.data.relax;
    var play = snapshot.data.play;
    var shop = snapshot.data.shop;
    var nightlife = snapshot.data.nightlife;
    var allTab = [
      {'items': discover, 'header':'Discover' },
      {'items': see, 'header':'See' },
      {'items': eat, 'header':'Eat' },
      {'items': relax, 'header':'Relax' },
      {'items': play, 'header':'Play' },
      {'items': shop, 'header':'Shop' },
      {'items': nightlife, 'header':'Nightlife' },
    ];

    
   
   
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 350,
            floating: false,
            pinned: true,
            backgroundColor: _showTitle ? color : Colors.white,
            automaticallyImplyLeading: false,
            title: SearchBar(
              placeholder: 'Explore $name',
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
            bottom: !_showTitle
            ? PreferredSize(
                preferredSize: Size.fromHeight(100),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 40.0,
                    ),
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: _renderTabBar(color, Colors.white, allTab)
                    )
                  ]        
                )
              )
            : PreferredSize(
              preferredSize: Size.fromHeight(70), 
              child: Container(color: Colors.transparent, child:_renderTabBar(Colors.white, color, allTab))
            ),
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                background: Stack(children: <Widget>[
                  Positioned.fill(
                      top: 0,
                      child: ClipPath(
                        clipper: CurveClipper(),
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
                        clipper:CurveClipper(),
                        child: Container(
                        color: color.withOpacity(0.5),
                      )
                    )
                  ),
                  Positioned(
                    left: 0,
                    top: 150,
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
                        Text(name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w300
                          )
                        )
                      ]
                    )
                  ),
                ]
              )
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(
            _buildAllTab(allTab, snapshot, color, destination),
            'All'
          ),
          _buildListView(
            discover, 
            'Discover',
            color,
            destination
          ),
          _buildListView(
            see, 
            'See',
            color,
            destination
          ),
          _buildListView(
            eat, 
            'Eat',
            color,
            destination
          ),
          _buildListView(
            relax, 
            'Relax',
            color,
            destination
          ),
          _buildListView(
            play, 
            'Play',
            color,
            destination
          ),
          _buildListView(
            shop, 
            'Shop',
            color,
            destination
          ),
          _buildListView(
            nightlife, 
            'NightLife',
            color,
            destination
          ),
        ],
      ),
    );
  }

  _getPlugs(List<dynamic> plugsData, String name ) {
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
          padding: EdgeInsets.only(right: 20.0),
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

  Widget _buildInfoParagraphBlock(dynamic obj, String key, String label) {
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
              obj[key].join(' '),
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

  Widget _buildInfoBlock(dynamic objValue, String label, String value) {
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



  _buildTabContent(List<Widget> widgets, String key){
    return Container(
      margin: EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
      decoration: BoxDecoration(color: Colors.white),
      key: new PageStorageKey(key),
      child: ListView(
        children: widgets
      )
    );
  }

  _buildAllTab(List<dynamic> sections, AsyncSnapshot snapshot, Color color, dynamic destination ) {
    bool _showVisaTextual = false;
    bool _showVisaAllowedStay = false;
    bool _showVisa = false;
    bool _showVisaNotes = false;
    bool _showVisaPassportValid = false;
    bool _showVisaBlankPages = false;
    var name = snapshot.data.cityState['name'];
    var descriptionShort = snapshot.data.cityState['description_short'];
    

    var visa = snapshot.data.visa;
    var safety = snapshot.data.safety;
    double rating = safety['rating'] * 1.0;
    var plugs = snapshot.data.plugs;
    var emergencyNumbers = snapshot.data.emergencyNumber;
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
    var widgets = <Widget>[
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
              _showVisaTextual ? _buildInfoParagraphBlock(visa['visa']['textual'], 'text', 'Visa information ') : Container(),             
              _showVisaAllowedStay ? _buildInfoBlock(visa['visa']['allowed_stay'], 'Duration of stay ', 'You are allowed to stay') : Container(),             
              _showVisaNotes ? _buildInfoParagraphBlock(visa['visa'], 'notes', 'Additional notes') : Container(),
              _showVisaPassportValid ? _buildInfoBlock(visa['passport']['passport_validity'], 'Passport validity requirement',''): Container(),  

              _showVisaBlankPages ? _buildInfoBlock(visa['passport']['blank_pages'], 'Blank passport pages requirement', '') : Container(),
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
                  color: _getAdviceColor(rating)
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
                ] 
              )
            ),

            buildDivider(),

            Container(
              padding:EdgeInsets.all(20.0),
              margin: EdgeInsets.only(left: 20.0, right:20.0, top: 40.0, bottom: 40.0 ),
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
      ),
    ];
    for (var section in sections) {
      var items = section['items'];
      widgets.add(
        TopList(
          items: items,
          onPressed: (data){
            onPush({'id':data['id'], 'level':data['level']});
          },
          onLongPressed: (data) async {
            var currentUser = StoreProvider.of<AppState>(context).state.currentUser;
            if(currentUser == null){
              loginBottomSheet(context, data, color);
            } else {
              var index = data['index'];
              await addToItinerary(context, items, index, color, destination);
            }
          },
          header: section['header']
        )
      );
    }
    return new List<Widget>.from(widgets)..addAll(
      <Widget>[
      ]
    );
  }

  _buildListView(List<dynamic> items, String key, Color color, dynamic destination) {
    return ListView.builder(
      key: new PageStorageKey(key),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            var id = items[index]['id'];
            var level  = items[index]['level'];
            onPush({'id':id.toString(), 'level':level.toString()});
          },
          onLongPress: () async {
            var currentUser = StoreProvider.of<AppState>(context).state.currentUser;
            if(currentUser == null){
              loginBottomSheet(context, data, color);
            } else {
              await addToItinerary(context, items, index, color, destination);
            }
          },
          child:Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 150,
                  height: 90,
                  margin:EdgeInsets.only(right:20),
                  child: ClipPath(
                    clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                        )
                      ), 
                      child: items[index]['image'] != null ? CachedNetworkImage(
                        placeholder: (context, url) => SizedBox(
                          width: 50, 
                          height:50, 
                          child: Align( alignment: Alignment.center, child:CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          )
                        )),
                      fit: BoxFit.cover, 
                      imageUrl: items[index]['image'],
                      errorWidget: (context,url, error) =>  Container( 
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:AssetImage('images/placeholder.jpg'),
                            fit: BoxFit.cover
                          ),
                          
                        )
                      )
                    ) : Container( 
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:AssetImage('images/placeholder.jpg'),
                            fit: BoxFit.cover
                          ),
                          
                        )
                      )
                  )
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width - 210,
                        child: Text(
                          items[index]['name'],
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500
                          ),
                        )
                      ),
                      Container(
                        margin: EdgeInsets.only(top:5),
                        width: MediaQuery.of(context).size.width - 210,
                        child: Text(
                          items[index]['description_short'],
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w300
                          ),
                        )
                      )
                      
                    ],
                  ),
                )
              ],
            )
          )
        );
      },
    );
  }

  _renderTab(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w300,
      )
    );
  }

  _renderTabBar(Color mainColor, Color fontColor, List<dynamic> sections){
    var tabs = [
      Tab(
        child: _renderTab('All')
      ),
    ];

    for (var section in sections) {
      if(section['items'].length > 0){
        tabs.add(
          Tab(
            child:  _renderTab(section['header'])
          ),
        );
      }
    }

    return TabBar(
      controller: _tabController,
      labelColor: mainColor,
      isScrollable: true,
      unselectedLabelColor: fontContrast(fontColor).withOpacity(0.6),
      indicator: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: mainColor,
            width: 2.0
          )
        )
      ),
      tabs: tabs,
    );
  }

  
  // function for rendering while data is loading
  Widget _buildLoadingBody(BuildContext ctxt) {
 
    return NestedScrollView(
      //controller: _scrollControllerCityState,
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
                  clipper:CurveClipper(),
                  child: Container(
                  color: Color.fromRGBO(240, 240, 240, 1),
                )
              ),
            ),
          ),
        ];
      },
      body: Container(
        padding: EdgeInsets.only(top: 0.0),
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

  

