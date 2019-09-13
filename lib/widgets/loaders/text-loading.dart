import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trotter_flutter/utils/index.dart';

class TextLoading extends StatelessWidget {
  final double width;
  final EdgeInsets margin;

  //passing props in react style
  TextLoading({
    this.width,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return Shimmer.fromColors(
        baseColor: Color.fromRGBO(220, 220, 220, 0.8),
        highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
        child: Container(
          margin: this.margin == null
              ? EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0)
              : this.margin,
          decoration: BoxDecoration(color: Color.fromRGBO(240, 240, 240, 0.8)),
          width: this.width != null ? this.width : 180.0,
          height: 20.0,
        ));
  }
}

class CarouselLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
              height: 140.0,
              margin: EdgeInsets.only(top: 20.0),
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (BuildContext ctxt, int index) =>
                      buildBody(ctxt, index)))
        ]);
  }

  Widget buildBody(BuildContext ctxt, int index) {
    return Shimmer.fromColors(
        baseColor: Color.fromRGBO(220, 220, 220, 0.8),
        highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
        child: Container(
            height: 240.0,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: Container(
                        // A fixed-height child.
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(240, 240, 240, 0.8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: 120.0,
                        height: 70.0,
                      )),
                ])));
  }
}
