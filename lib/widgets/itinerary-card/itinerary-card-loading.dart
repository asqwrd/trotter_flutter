import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trotter_flutter/utils/index.dart';

class ItineraryCardLoading extends StatelessWidget {
  //passing props in react style
  ItineraryCardLoading();

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        child: Container(
            margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 0.0),
            child: buildBody(context)));
  }

  Widget buildBody(BuildContext ctxt) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Shimmer.fromColors(
              baseColor: Color.fromRGBO(220, 220, 220, 0.8),
              highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(220, 220, 220, 0.8),
                ),
              )),
          Shimmer.fromColors(
              baseColor: Color.fromRGBO(220, 220, 220, 0.8),
              highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                width: 400,
                height: 20,
              ))
        ]);
  }
}
