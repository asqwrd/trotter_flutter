import 'package:flutter/material.dart';


class SearchBar extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget leading;
  final String placeholder;

    //passing props in react style
  SearchBar({
    this.onPressed,
    this.leading,
    this.placeholder
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(3.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            //offset: Offset(0, 0),
            blurRadius: 2,
            spreadRadius: 2,
          ),
        ]
      ),
      child: new Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical:10.0),
            child:this.leading
          ),
          Container(
            child: Text(
              this.placeholder,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.w400
              )
            ),
          )

        ],
      ),
    );
  }
}