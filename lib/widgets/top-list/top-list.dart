import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';


class TopList extends StatelessWidget {
  final String2VoidFunc onPressed;
  final ValueChanged onLongPressed;
  final String name;
  final String header;
  final List<dynamic> items;
  final Function(String) callback;


  //passing props in react style
  TopList({
    this.header,
    this.name,
    this.onPressed,
    this.onLongPressed,
    this.items,
    this.callback
  });

  @override
  
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0), 
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[
          Container(
            margin: EdgeInsets.only(left: 20.0, right:20.0, bottom:10.0),
            child: Text(
              this.header,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600
              ),
            )
          ),
          
          SingleChildScrollView(
            primary: false,
            scrollDirection: Axis.horizontal,
            child: Container(margin:EdgeInsets.only(left:20.0), child:buildRow(buildItems(this.items)))
          )
        ]
      )
    );
  }

  buildItems(items) {
    var widgets = List<Widget>();
    for (var item in items) {
      widgets.add(buildBody(item));
        
    }
    return widgets;
  }

  buildRow(List<Widget> widgets) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget buildBody(dynamic item) {
  return new InkWell ( 
    onTap: (){
      var id = item['id'];
      var level = item['level'];
      this.onPressed({'id': id, 'level': level});
    },
    onLongPress: () {
      this.onLongPressed({'item': item});
    },
    child:Container(
      //height:210.0,
      child:Stack(
        children:<Widget>[
          Positioned.fill(
            top:-30,
            left:-20,
            //alignment: Alignment.center,
            child:SizedBox(
            width: 50,
            height: 50,
            child: Align(child:CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ))
          )),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  // A fixed-height child.
                  margin:EdgeInsets.only(right:20),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 240, 240, 0.8),
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: item['image'] != null ? NetworkImage(item['image']) : AssetImage('images/placeholder.jpg'),
                      fit: BoxFit.cover
                    )
                  ),
                  width: 175.0,
                  height: 160.0,
                
                  
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
          ]
        )
      )
    );
  }
}