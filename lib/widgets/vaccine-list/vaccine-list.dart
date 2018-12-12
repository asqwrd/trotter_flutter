import 'package:flutter/material.dart';

typedef String2VoidFunc = void Function(String);

class VaccineList extends StatelessWidget {
  final dynamic vaccines;


  //passing props in react style
  VaccineList({
    this.vaccines,
  });
  @override
  
  Widget build(BuildContext context) {
      //print(this.vaccines);
      this.vaccines['recommended'] = [{'type':'Hepatitus A'}, {'type':'Routine immunizations'}, {'type':'Typhoid fever'},{'type':'Typhoid fever'},{'type':'Typhoid fever'},{'type':'Typhoid fever'}];

    return SingleChildScrollView(
      primary: false,
      scrollDirection: Axis.horizontal,
      child: buildRow(context)
    );
  }

  buildRow(BuildContext context){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children:<Widget>[
        buildBody(context, this.vaccines['recommended']),
        buildBody(context, this.vaccines['recommended']),
        buildBody(context, this.vaccines['risk']),
      ],
    );
  }

  Widget buildBody(BuildContext ctxt, List<dynamic> vaccines) {
    return new Container(
      //margin: EdgeInsets.only(right: 20),
      child:Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              // A fixed-height child.
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  width: 0.8,
                  color: Colors.black
                )
              ),
              width: 350.0,
              //height: 70.0,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.asset('images/vaccines.png',width: 45.0, height: 45.0,),
                  Text(
                    "Viral Risk",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700
                    )
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: buildBodyList(vaccines),
                  )
                ],
              )
            )
          )
        ]
      )
    );
  }

  buildBodyList(List<dynamic> vaccines) {
    var vaccineWidgets = List<Widget>();
    for (var vaccine in vaccines) {
      vaccineWidgets.add(
        Text(
          vaccine['type'],
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w300
          )
        )
      );
    }

    return vaccineWidgets;
  }
}