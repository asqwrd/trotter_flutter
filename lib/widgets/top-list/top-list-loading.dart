import 'package:flutter/material.dart';

class TopListLoading extends StatelessWidget {

  @override
  
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children:<Widget>[
      Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: Color.fromRGBO(240, 240, 240, 0.8)
        ),
        width:150.0,
        height: 24.0,
      ),
      
      Container(
        height:130.0,
        margin: EdgeInsets.only(top: 20.0),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (BuildContext ctxt, int index) => buildBody(ctxt, index)
        )
      )
      ]
    );
  }

  Widget buildBody(BuildContext ctxt, int index) {
  return new Container(height:210.0, child:Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
          margin: EdgeInsets.only(left:20.0),
          decoration: BoxDecoration(
            color: Color.fromRGBO(240, 240, 240, 0.8),
          ),
        )
      ]
    ));
  }
}