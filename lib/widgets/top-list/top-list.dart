import 'package:flutter/material.dart';

typedef String2VoidFunc = void Function(Map<String, String>);

class TopList extends StatelessWidget {
  final String2VoidFunc onPressed;
  final String name;
  final String header;
  final List<dynamic> items;
  final Function(String) callback;


  //passing props in react style
  TopList({
    this.header,
    this.name,
    this.onPressed,
    this.items,
    this.callback
  });

  @override
  
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0), 
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children:<Widget>[
          Container(
            margin: EdgeInsets.only(left: 20.0, right:20.0, bottom:20.0),
            child: Text(
              this.header,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w300
              ),
            )
          ),
          
          SingleChildScrollView(
            primary: false,
            scrollDirection: Axis.horizontal,
            child: buildRow(buildItems(this.items))
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
  return new GestureDetector ( 
    onTap: (){
      var id = item['id'];
      var level = item['level'];
      this.onPressed({'id': id, 'level': level});
    },
    child:Container(
      //height:210.0,
      child:Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                // A fixed-height child.
                decoration: BoxDecoration(
                  color: Color.fromRGBO(240, 240, 240, 0.8),
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: NetworkImage(item['image']),
                    fit: BoxFit.cover
                  )
                ),
                width: 120.0,
                height: 90.0,
              
                
              )
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
}