import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';



Future<SearchData> fetchSearch(String query, String id, bool searchPoi) async {
  var response;
  if(query.isEmpty && !searchPoi){
    response = await http.get('http://localhost:3002/api/search/recent', headers:{'Authorization':'security'});
  } else if(query.isEmpty && searchPoi){
    response = await http.get('http://localhost:3002/api/search/recent?poi=true', headers:{'Authorization':'security'});
  } else if(query.isNotEmpty && (id != null && id.isNotEmpty) && searchPoi) {
    response = await http.get('http://localhost:3002/api/search/find/$query?id=${id}', headers:{'Authorization':'security'});
  }else {
    response = await http.get('http://localhost:3002/api/search/find/$query', headers:{'Authorization':'security'});
  }
  
  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return SearchData.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    var msg = response.statusCode;
    throw Exception('Response> $msg');
  }
  
}

class SearchData {
  final List<dynamic> recentSearch; 
  final List<dynamic> results; 

  SearchData({this.results, this.recentSearch});

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      results: json['results'],
      recentSearch: json['recent_search']
    );
  }
}


class Search extends StatefulWidget {
  final String query;
  final String id;
  final String location;
  final ValueChanged<dynamic> onPush;
  Search({Key key, @required this.query, this.onPush, this.id, this.location}) : super(key: key);
  @override
  SearchState createState() => new SearchState(query:this.query, id:this.id, onPush:this.onPush, location:this.location);
}

class SearchState extends State<Search> {
  bool _showTitle = false;
  String query;
  String id;
  String location;
  bool selectId = false;
  final ValueChanged<dynamic> onPush;
   GoogleMapController mapController;
  
  Future<SearchData> data;
  var txt = new TextEditingController();

  @override
  void initState() {
    super.initState();
    txt.text = '';
    selectId = this.id != null && this.id.isNotEmpty ? true : false;
    data = fetchSearch('',this.id,selectId);
    
  }
  

  SearchState({
    this.query,
    this.onPush,
    this.id,
    this.location
  });


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Press button to start.');
            case ConnectionState.active:
            case ConnectionState.waiting:
              return _buildLoadedBody(context,snapshot, true,'');
            case ConnectionState.done:
              if (snapshot.hasData) {
                return _buildLoadedBody(context,snapshot, false, this.id);
              } else if(snapshot.hasError) {
                return Text('No Connection');
              }
          }
          
        }
      )
    );
  }
  

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot, bool isLoading, String id) {
    final ScrollController _scrollController = ScrollController();
    var kExpandedHeight = 300;
    var timer;

    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    var recentSearch = snapshot.hasData ? snapshot.data.recentSearch : null;
    var results = snapshot.hasData ? snapshot.data.results : null;
    var chips = [
      FilterChip(
        selected: this.id != null && this.id.isNotEmpty ? !selectId : true,
        label: Text("Anywhere"),
        onSelected: (bool value){
          setState(() {
            if(this.id.isNotEmpty) {
              selectId = !selectId;
              txt.text =  '';
              data = fetchSearch('', this.id, selectId); 
            }
          }); 
        }
      )
    ];

    if(this.id != null) {
      chips.add(
        FilterChip(
          selected: selectId,
          label: Text(this.location),
          onSelected: (bool value){
            setState(() {
              if(this.id != null)
                selectId = !selectId;
                txt.text =  '';
                data = fetchSearch('', this.id, selectId); 
            }); 
          }
        )
      );
    }
    

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        leading: IconButton(
          padding: EdgeInsets.all(0),
          icon:  Icon(Icons.close),
          onPressed: () {  Navigator.pop(context);},
          iconSize: 30,
          color: Colors.black,
        ),
        actions:<Widget>[
          FlatButton(
            child: Text('Clear'),
            onPressed: () {
              setState(() {
                txt.text = '';
                data = fetchSearch('', this.id, selectId);              
              });
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80), 
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  enabled: true,
                  controller: txt,
                  cursorColor: Colors.black,
                  textInputAction: TextInputAction.search,
                  enableInteractiveSelection: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    hintText: selectId ? 'Search for places in $location...' : 'Search cities to travel to...'
                  ),
                  onChanged: (value){
                    if(timer != null){
                      timer.cancel();
                      timer = null;
                      
                    }
                    timer = new Timer(const Duration(milliseconds: 500), (){
                      print('Print $value');
                      setState(() {
                        data = fetchSearch(value,this.id,selectId);             
                      });
                    });
                    
                  },
                ),
                Container( 
                  margin: EdgeInsets.symmetric(horizontal:20.0),
                  child: Wrap(
                    spacing: 10.0,
                    children: chips
                  )
                )
              ]
            ),
          )
        ),
      ),
      body: isLoading ? _buildLoadingBody() : results != null ? 
        ListView.builder(
          //separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
          itemCount: results.length,
          //shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return selectId == false ? InkWell(
              onTap: (){
                onPush({'id':results[index]['id'].toString(), 'level':results[index]['level'].toString(), 'from':'search'});
              },
              child: ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  title: Text(
                    results[index]['country_id'] == 'United_States' ? '${results[index]['name']}, ${results[index]['parent_name']}, ${results[index]['country_name']}' :'${results[index]['name']}, ${results[index]['country_name']}',
                  )
                )
              ) : InkWell(
               onTap: (){
                onPush({'id':results[index]['id'].toString(), 'level':results[index]['level'].toString(), 'from':'search'});
              },
              child: Container( 
                margin:EdgeInsets.symmetric(vertical: 20), 
                child:ListTile(
                  leading: Container(
                    width: 130.0,
                    height: 80.0, 
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: results[index]['image'] != null ? NetworkImage(
                          results[index]['image'],
                        ) : AssetImage('images/placeholder.jpg')
                      )
                    ),
                  ),
                  title: Text(
                    results[index]['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  subtitle: Text(
                    results[index]['description_short'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                )
              )
            );
          },
        ) : ListView.builder(
          //separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
          itemCount: recentSearch.length,
          //shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: (){
                setState(() {
                  txt.text = recentSearch[index]['value'];
                  data = fetchSearch(recentSearch[index]['value'], this.id,selectId);                
                });
              },
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                title: Text(
                  recentSearch[index]['value'],
                )
              )
            );
          },
        ),
    );
  }

  // function for rendering while data is loading
  Widget _buildLoadingBody() {
    return ListView(
      //crossAxisAlignment: CrossAxisAlignment.start,
      shrinkWrap: true,
      primary: false,
      children: <Widget>[
        Align(alignment:Alignment.centerLeft, child:TextLoading()),
        Align(alignment:Alignment.centerLeft, child:TextLoading(width:200.0)),
        Align(alignment:Alignment.centerLeft, child:TextLoading()),
        Align(alignment:Alignment.centerLeft, child:TextLoading(width:220.0)),
        Align(alignment:Alignment.centerLeft, child:TextLoading()),
        Align(alignment:Alignment.centerLeft, child:TextLoading(width:180.0)),
        Align(alignment:Alignment.centerLeft, child:TextLoading(width:180.0)),
        Align(alignment:Alignment.centerLeft, child:TextLoading(width:150.0)),
        Align(alignment:Alignment.centerLeft, child:TextLoading(width:200.0)),
        Align(alignment:Alignment.centerLeft, child:TextLoading(width:180.0)),
      ]
    );
  }
}