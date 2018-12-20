import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';
import 'package:trotter_flutter/widgets/loaders/index.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



Future<SearchData> fetchSearch(String query) async {
  var response;
  if(query.isEmpty){
    response = await http.get('http://localhost:3002/api/search/recent', headers:{'Authorization':'security'});
  } else {
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
  final ValueChanged<dynamic> onPush;
  Search({Key key, @required this.query, this.onPush}) : super(key: key);
  @override
  SearchState createState() => new SearchState(query:this.query, onPush:this.onPush);
}

class SearchState extends State<Search> {
  bool _showTitle = false;
  String query;
  final ValueChanged<dynamic> onPush;
   GoogleMapController mapController;
  
  Future<SearchData> data;
  var txt = new TextEditingController();

  @override
  void initState() {
    super.initState();
    data = fetchSearch('');
    txt.text = '';
    
  }
  

  SearchState({
    this.query,
    this.onPush
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
              return _buildLoadedBody(context,snapshot, true);
            case ConnectionState.done:
              if (snapshot.hasData) {
                return _buildLoadedBody(context,snapshot, false);
            }
          }
          
        }
      )
    );
  }
  

// function for rendering view after data is loaded
  Widget _buildLoadedBody(BuildContext ctxt, AsyncSnapshot snapshot, bool isLoading) {
    final ScrollController _scrollController = ScrollController();
    var kExpandedHeight = 300;
    var timer;



    _scrollController.addListener(() => setState(() {
      _showTitle =_scrollController.hasClients &&
      _scrollController.offset > kExpandedHeight - kToolbarHeight;

    }));
    var recentSearch = snapshot.hasData ? snapshot.data.recentSearch : null;
    var results = snapshot.hasData ? snapshot.data.results : null;
    

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
                data = fetchSearch('');              
              });
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40), 
          child: Container(
            child: TextField(
              enabled: true,
              controller: txt,
              cursorColor: Colors.black,
              textInputAction: TextInputAction.search,
              enableInteractiveSelection: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                hintText: 'Search'
              ),
              onChanged: (value){
                if(timer != null){
                  timer.cancel();
                  timer = null;
                  
                }
                timer = new Timer(const Duration(milliseconds: 500), (){
                  print('Print $value');
                  setState(() {
                    data = fetchSearch(value);             
                  });
                });
                
              },
            ),
          )
        ),
      ) ,
      body: isLoading ? _buildLoadingBody() : results != null ? 
        ListView.builder(
          //separatorBuilder: (BuildContext context, int index) => new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
          itemCount: results.length,
          //shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: (){
                print(results[index]['level']);

                onPush({'id':results[index]['id'].toString(), 'level':results[index]['level'].toString(), 'from':'search'});
              },
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                title: Text(
                  results[index]['country_id'] == 'United_States' ? '${results[index]['name']}, ${results[index]['parent_name']}, ${results[index]['country_name']}' :'${results[index]['name']}, ${results[index]['country_name']}',
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
                  data = fetchSearch(recentSearch[index]['value']);                
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextLoading(),
        TextLoading(width:200.0),
        TextLoading(),
        TextLoading(width:220.0),
        TextLoading(),
        TextLoading(width:180.0),
        TextLoading(width:180.0),
        TextLoading(width:150.0),
        TextLoading(width:200.0),
        TextLoading(width:180.0),
      ]
    );
  }
}