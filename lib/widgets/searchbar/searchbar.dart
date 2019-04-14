import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:trotter_flutter/redux/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';



class SearchBar extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget leading;
  final String placeholder;
  final Color fillColor;

    //passing props in react style
  SearchBar({
    this.onPressed,
    this.leading,
    this.placeholder,
    this.fillColor
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector <AppState, AppState>(
      converter: (store) => store.state,
      builder: (BuildContext context, AppState store) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical:0.0),
              child:this.leading
            ),
            Flexible(child:GestureDetector(
              onTap: () {
                this.onPressed();
              }, 
              child:Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), 
                    decoration: BoxDecoration(
                      color: this.fillColor != null ? this.fillColor : Color.fromRGBO(255, 255, 255, 0.8),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical:0.0),
                    child:SvgPicture.asset("images/search-icon.svg",
                      width: 40.0,
                      height: 40.0,
                      color: fontContrast(this.fillColor),
                      fit: BoxFit.contain
                    )
                  ),
                  Expanded(child:Container(
                      child: Text(
                        "${this.placeholder}${store.offline == true ? " (offline mode)":""}",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: fontContrast(this.fillColor),
                          fontWeight: FontWeight.w400
                        )
                      ),
                    )
                  )]))
              ),
            )
          ]
        );
      }
    );
  }
}