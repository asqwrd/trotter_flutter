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
    return GestureDetector(
      onTap: () {
        print("SearchBar");
        this.onPressed();
      }, 
      child:Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20), 
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.8),
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
        )
      ),
    );
  }
}