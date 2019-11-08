import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trotter_flutter/utils/index.dart';

class TopListLoading extends StatelessWidget {
  final bool enableMini;

  //passing props in react style
  TopListLoading({
    this.enableMini,
  });
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
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            decoration:
                BoxDecoration(color: Color.fromRGBO(240, 240, 240, 0.8)),
            width: 150.0,
            height: 20.0,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            decoration:
                BoxDecoration(color: Color.fromRGBO(240, 240, 240, 0.8)),
            width: 250.0,
            height: 20.0,
          ),
          Container(
              height: this.enableMini == true ? 75 : 140.0,
              margin: EdgeInsets.only(top: 20.0),
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (BuildContext ctxt, int index) =>
                      buildBody(ctxt, index)))
        ]);
  }

  Widget buildBody(BuildContext ctxt, int index) {
    return Shimmer.fromColors(
        baseColor: Color.fromRGBO(220, 220, 220, 0.8),
        highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
        child: this.enableMini == true
            ? Container(
                width: 100,
                child: Center(
                    child: Container(
                  alignment: Alignment.center,
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(240, 240, 240, 0.8),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          style: BorderStyle.solid,
                          color: Colors.transparent,
                          width: 2)),
                )))
            : Container(
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
                      Container(
                        padding: EdgeInsets.only(left: 20.0, top: 10.0),
                        width: 80.0,
                        height: 18.0,
                        margin: EdgeInsets.only(left: 20.0),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(240, 240, 240, 0.8),
                        ),
                      )
                    ])));
  }
}
