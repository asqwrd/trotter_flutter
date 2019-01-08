import 'package:flutter/material.dart';
import 'package:trotter_flutter/screens/trips/index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trotter_flutter/tab_navigator.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:flutter_redux/flutter_redux.dart';

void showTripsBottomSheet(context, dynamic destination){
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc){
      return StoreConnector <AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, trips)=> _buildLoadedList(context,trips,destination)
        );
      }
  );
}


_buildLoadedList(BuildContext context, AppState snapshot, dynamic destination) {
  //snapshot.onGetTrips(false);
  //print(snapshot.trips);
  var trips = snapshot.trips;
  //var color = Colors.blueGrey;
  return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0), 
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[          
          SingleChildScrollView(
            primary: false,
            scrollDirection: Axis.horizontal,
            child: Container(margin:EdgeInsets.only(left:20.0), child:_buildRow(_buildItems(context,trips, destination)))
          )
        ]
      )
    );
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

_buildItems(BuildContext context,List<dynamic> items, dynamic destination) {
    var widgets = List<Widget>();
    for (var item in items) {
      widgets.add(_buildBody(context, item, destination));
        
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

  Widget _buildBody(BuildContext context,  dynamic item, dynamic destination) {
  return new InkWell ( 
    onTap: () async{
      //var id = item['id'];
      //var level = item['level'];
      //this.onPressed({'id': id, 'level': level});
      //Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => AddTrip()),);
      var data = {
        "location": destination['location'],
        "destination_id": destination['id'],
        "destination_name": destination['name'],
        "level": destination['level'],
        "country_id": destination['country_id'],
        "country_name": destination["country_name"],
        "start_date":  0,
        "end_date": 0,
      };

      var response = await postAddToTrip(item['id'], data);
      StoreProvider.of<AppState>(context).dispatch(UpdateTripsDestinationAction(item['id'], data)); 
      if(response.exists == false){
        Scaffold
          .of(context)
          .showSnackBar(
            SnackBar(
              content: Text(
                '${destination['name']} added to ${item['name']}',
                style: TextStyle(
                  fontSize: 18
                )
              ),
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.blueGrey,
                onPressed: () {
                  TabNavigator().push(context,{"id": item['id'].toString(),"level":"trip"});
                  Scaffold.of(context).removeCurrentSnackBar();
                },
              ),
            )
          );
      } else {
         Scaffold
          .of(context)
          .showSnackBar(SnackBar(content: Text(
                '${destination['name']} was already added to ${item['name']}',
                style: TextStyle(
                  fontSize: 18
                )
              )
            )
          );
      }
      

    },
    child:Container(
      //height:210.0,
      child:Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              // A fixed-height child.
              margin:EdgeInsets.only(right:20),
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 0.8),
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: item['image'] != null ? NetworkImage(item['image']) : AssetImage('images/placeholder.jpg'),
                  fit: BoxFit.cover
                )
              ),
              width: 140.0,
              height: 90.0,
            
              
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              width: 150.0,
              child: Text(
                item['name'], 
                textAlign: TextAlign.left, 
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300
                ),
              )
            )
          ]
        )
      )
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