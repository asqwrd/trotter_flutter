import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trotter_flutter/tab_navigator.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trotter_flutter/widgets/itinerary-list/index.dart';

Future addToItinerary(BuildContext context, List items, int index, Color color, dynamic destination) async {
  var selectedItineraryId = StoreProvider.of<AppState>(context).state.selectedItinerary.selectedItineraryId;
  var selectedItineraryDestination = StoreProvider.of<AppState>(context).state.selectedItinerary.destinationId;
  var poi = items[index];
  if(selectedItineraryId != null && selectedItineraryDestination == destination['id']) {
    var result = await showDayBottomSheet(StoreProvider.of<AppState>(context), context, selectedItineraryId, poi , destination['id'], color, destination);
    if(result != null && result['change'] != null) {
      StoreProvider.of<AppState>(context).dispatch(
        new SelectItineraryAction(null,false,destination['id'],null)
      ); 
    }
  } else {
    showItineraryBottomSheet(StoreProvider.of<AppState>(context), context, destination['id'], poi, color, destination);
  }
}

void showItineraryBottomSheet(Store<AppState> store, context, String destinationId, dynamic poi, Color color, dynamic destination) {
  var data = fetchItineraries("destination=$destinationId");
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc){
      return FutureBuilder(
          future: data,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildLoadedList(store, context,snapshot, poi, destinationId, color, destination);
            }
            return _buildLoadingList();
          }
        );
      }
  );
}


_buildLoadedList(Store<AppState> store, BuildContext context, AsyncSnapshot snapshot, dynamic poi, String destinationId, Color color, dynamic destination) {
  var itineraries = snapshot.data.itineraries;
  var loading = false;
  return IgnorePointer(
    ignoring: loading,
    child:Container(
      margin: EdgeInsets.symmetric(vertical: 20.0), 
      child: loading == true && itineraries.length == 0 ? _buildLoadingList() : 
      itineraries == null ? 
      Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('images/trips-empty.png', width:170, height: 170, fit: BoxFit.contain),
            Text(
              'No itineraries created yet?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 35,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w300
                
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Create a trip to start planning your next adventure!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w200
              ),
            ),
            SizedBox(height: 30),
            FlatButton(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(50.0)),
              child:Text(
                'Start planning',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w200
                ),
              ),
              color: Colors.blueGrey,
              onPressed: () {
                TabNavigator().push(context,{'level':'createtrip', 'param':destination});
              },
            )
          ],
        )
      ) 
      : 
      Wrap(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left:20,bottom:20),
            margin: EdgeInsets.only(bottom:20),
            child:Text(
              'Choose an itinerary',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w300
              ),
            )
          ),
          Stack(
            children:<Widget>[          
              SingleChildScrollView(
                  primary: false,
                  scrollDirection: Axis.horizontal,
                  child: Container(margin:EdgeInsets.only(left:20.0), child:_buildRow(_buildItems(store, context,itineraries,poi, destinationId, color, destination)))
                ),
              
              loading ? Center(child:RefreshProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(color))) : Container()
            ]
          )
        ]
      )
    ));
}

_buildLoadingList(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Container(
          height: 130.0,
          margin: EdgeInsets.only(top: 20.0),
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (BuildContext ctxt, int index) => _buildLoadingBody(ctxt, index)
        )
      )
    ]
  );
}

_buildItems(Store<AppState> store, BuildContext context,List<dynamic> items, dynamic poi, String destinationId, Color color, dynamic destination) {
    var widgets = <Widget>[];
    for (var item in items) {
      widgets.add(_buildBody(store, context, item, poi, destinationId, color, destination));
        
    }
    return widgets;
  }

  _buildRow(List<Widget> widgets) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget _buildBody(Store<AppState> store, BuildContext context,  dynamic item, dynamic poi, String destinationId, Color color, dynamic destination) {
    var days = item['days'] as List;
    var itineraryItems = days.firstWhere((day) { 
        var items = day['itinerary_items'] as List;
        return items.length > 0;
      },
      orElse: ()=>{"itinerary_items":<List<dynamic>>[]}
    
    )['itinerary_items'];

    return Container(margin:EdgeInsets.only(right: 20), child:InkWell(
      onTap: () async {
        Navigator.pop(context);
        var result = await showDayBottomSheet(store, context, item['id'], poi, destinationId, color, destination);
        if(result != null && result['change'] != null) {
          store.dispatch(
            new SelectItineraryAction(null,false,destinationId,null)
          ); 
        }

        
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MiniItineraryList(
            items: itineraryItems,
            onPressed: (data) async {
              Navigator.pop(context);
              var result = await showDayBottomSheet(store,context, item['id'], poi, destinationId, color, destination);
              if(result != null && result['change'] != null) {
                store.dispatch(
                  new SelectItineraryAction(null,false,destinationId,null)
                ); 
              }

            },
            onLongPressed: (data) {

            }
          ),
          Container(
            width:200,
            margin: EdgeInsets.only(top:10),
            child:Text(
              item['name'],
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300
              ),
            )
          )
        ],
      )
    ));
  }

  responseFromDayBottomSheet(BuildContext context, dynamic item, dynamic poi, String dayId, String destinationId, [int toIndex]) async {
    var data = {
      "poi": poi,
      "title":"",
      "description":"",
      "time":{
        "value":"",
        "unit":""
      }
    };
    
    var response = await addToDay(StoreProvider.of<AppState>(context), item['id'], dayId, destinationId, data, true);
    if(response.success == true){
      Scaffold
      .of(context)
      .showSnackBar(
        SnackBar(
          content: Text(
            toIndex != null ? '${poi['name']} moved to day $toIndex' : '${poi['name']} added to ${item['name']}',
            style: TextStyle(
              fontSize: 18
            )
          ),
          duration: Duration(seconds: 2),
        )
      ); 
    }
  }

  showDayBottomSheet(Store<AppState> storeApp, BuildContext context, String itineraryId, dynamic poi, String destinationId, Color color, dynamic destination, {force: false, isSelecting:false, String movingFromId}) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
        return StoreConnector <AppState, SelectItineraryData>(
          converter: (store) => store.state.selectedItinerary,
          onInit: (store) async {
            if(store.state.selectedItinerary.selectedItinerary == null || force == true){
              store.dispatch(new SetSelectItineraryLoadingAction(true));
              await fetchSelectedItinerary(StoreProvider.of<AppState>(context),itineraryId);
              store.dispatch(SetSelectItineraryLoadingAction(false));
            }
          },
          builder: (context, store){
            var loading = store.loading;
            if(loading && store.selectedItinerary == null){
              return Container(
                height: 300,
                width:400,
                child: Center(child:CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(color))) 
              );
            }
            var item = store.selectedItinerary;
            if(item == null){
              return Container();
            }
            var days = item['days'];
            if(movingFromId != null){
              days.removeWhere((day)=> movingFromId == day['id']);
            }
            return IgnorePointer(
              ignoring: StoreProvider.of<AppState>(context).state.selectedItinerary.loading,
              child: Stack( 
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top:30, bottom:20, left:20), 
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Choose a day',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w300
                              ),
                            ),
                            isSelecting == true ? FlatButton(
                              onPressed: (){
                                Navigator.pop(context,{"change":true});
                                showItineraryBottomSheet(storeApp, context, destinationId, poi, color, destination);
                              },
                              child: Text(
                                'Change',
                                style: TextStyle(
                                  color:color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300
                                ),
                              ),
                            ) : Container()
                          ]
                        )
                      ),
                      Container(margin:EdgeInsets.only(bottom: 0, top: 0), child:Divider(color: Color.fromRGBO(0, 0, 0, 0.3))),
                      Flexible(
                        child:ListView.separated(
                          separatorBuilder: (BuildContext serperatorContext, int index) => new Container(margin:EdgeInsets.symmetric(vertical: 0), child:Divider(color: Color.fromRGBO(0, 0, 0, 0.3))),
                          itemCount: days.length,
                          primary: false,
                          itemBuilder:  (BuildContext listContext, int dayIndex){
                            return ListTile(
                              onTap: () async {
                                StoreProvider.of<AppState>(context).dispatch(
                                  new SetSelectItineraryLoadingAction(true)
                                ); 
                                await responseFromDayBottomSheet(context, item, poi, days[dayIndex]['id'], destinationId, days[dayIndex]['day']+1);
                                StoreProvider.of<AppState>(context).dispatch(
                                  new SetSelectItineraryLoadingAction(false)
                                ); 
                                Navigator.pop(context,{'selected': days[dayIndex]});

                              },
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              title: Text(
                                'Day ${days[dayIndex]['day'] + 1}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              subtitle:Text(
                                '${days[dayIndex]['itinerary_items'].length} ${days[dayIndex]['itinerary_items'].length == 1  ? "place":"places"} to see',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300
                                ),
                              )
                            );
                          },  
                        )
                      )
                    ]
                  ),
                  store.loading == true ? Center(child:RefreshProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(color))) : Container()
                ]
              )
            );            
          }
        );
      }
    );
  }



  Widget _buildLoadingBody(BuildContext ctxt, int index) {
    return Shimmer.fromColors(
      baseColor: Color.fromRGBO(220, 220, 220, 0.8),
      highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
      child: Container(
        height: 210.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 10.0),
              child: Container(
                // A fixed-height child.
                decoration: BoxDecoration(
                  color: Color.fromRGBO(240, 240, 240, 0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
                width: 120.0,
                height: 70.0,
              )
            ),
            Container(
              padding: EdgeInsets.only(left: 20.0, top: 10.0),
              width: 80.0,
              height: 18.0,
              margin: EdgeInsets.only(left: 20.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 0.8),
              ),
            )
          ]
        )
      )
    );
  }