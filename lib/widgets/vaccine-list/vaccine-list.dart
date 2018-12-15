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
      this.vaccines['recommended'] = [{'type':'Hepatitus A'}, {'type':'Routine immunizations'}, {'type':'Typhoid fever'}];

    return SingleChildScrollView(
      primary: false,
      scrollDirection: Axis.horizontal,
      child: buildRow(context)
    );
  }

  buildRow(BuildContext context){
    bool _showRequired = this.vaccines['required'] != null;
    bool _showRisk = this.vaccines['risk'] != null;
    var recommended = [{'type':'Hepatitus A'}, {'type':'Routine immunizations'}, {'type':'Typhoid fever'},{'type':'Typhoid fever'},{'type':'Typhoid fever'},{'type':'Typhoid fever'}];
    if(this.vaccines['recommended'] != null) {
      this.vaccines['recommeded'] = new List.from(this.vaccines['recommended'])..addAll(recommended);
    } else{
      this.vaccines['recommeded'] = recommended;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children:<Widget>[
        buildBody(context, this.vaccines['recommended'], 'Required vaccinations', 'images/vaccines.png' ),
        _showRequired ? buildBody(context, this.vaccines['required'],'Recommended vaccinations', 'images/vaccines.png'): Container(),
        _showRisk ? buildBody(context, this.vaccines['risk'], 'Viral risks', 'images/risk.png'):Container(),
      ],
    );
  }

  Widget buildBody(BuildContext ctxt, List<dynamic> vaccines, String label, String icon) {
    return new Container(
      //margin: EdgeInsets.only(right: 20),
      child:Column(
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
                  Image.asset(icon, width: 45.0, height: 45.0, fit: BoxFit.contain),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600
                    )
                  ),
                  Padding(
                    padding:EdgeInsets.only(top: 10.0, bottom:10.0),
                    child:Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: buildBodyList(vaccines),
                    )
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
          '${vaccine['type'][0]}${vaccine['type'].toLowerCase().replaceAll(new RegExp(r'_'), ' ').substring(1)}',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w300
          )
        )
      );
    }

    return vaccineWidgets;
  }
}