import 'package:flutter/material.dart';

typedef String2VoidFunc = void Function(String);

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children:<Widget>[
      Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          this.header,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w300
          ),
        )
      ),
      
      Container(
        height:130.0,
        margin: EdgeInsets.only(top: 20.0),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: this.items.length,
          itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index, this.items)
        )
      )
      ]
    );
  }

  Widget buildBody(BuildContext ctxt, int index, List<dynamic> items) {
  return new GestureDetector ( 
    onTap: (){
      var id = items[index]['id'];
      this.onPressed(id);
    },
    child:Container(
      height:210.0,
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
                    image: NetworkImage(items[index]['image']),
                    fit: BoxFit.cover
                  )
                ),
                width: 120.0,
                height: 70.0,
              
                
              )
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              width: 150.0,
              child: Text(
                items[index]['name'], 
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