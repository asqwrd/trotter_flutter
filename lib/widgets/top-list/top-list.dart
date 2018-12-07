import 'package:flutter/material.dart';

class TopList extends StatelessWidget {
  final VoidCallback onPressed;
  final String name;
  final String header;

  //passing props in react style
  TopList({
    this.header,
    this.name,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children:<Widget>[
      Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(this.header)
      ),
      
      Container(
        height:110.0,
        margin: EdgeInsets.only(top: 10.0),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: 20,
          itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index, this.name)
        )
      )
      ]
    );
  }

  Widget buildBody(BuildContext ctxt, int index,name) {
  return new Container(height:200.0,child:Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            // A fixed-height child.
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(5)
            ),
            width: 120.0,
            height: 70.0,
           
            
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Text(name, textAlign: TextAlign.left, overflow: TextOverflow.ellipsis,)
        )
      ]
    ));
  }
}