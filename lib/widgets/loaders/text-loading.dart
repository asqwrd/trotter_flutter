import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TextLoading extends StatelessWidget {
  final double width;



  //passing props in react style
  TextLoading({
    this.width,
  });


  @override
  
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
    baseColor: Color.fromRGBO(220, 220, 220, 0.8),
    highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(240, 240, 240, 0.8)
      ),
      width: this.width != null ? this.width : 180.0,
      height: 20.0,
  
    ));
  }
}