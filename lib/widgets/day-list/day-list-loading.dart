import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:shimmer/shimmer.dart';

class DayListLoading extends StatelessWidget {
  final String2VoidFunc onPressed;
  final ValueChanged onLongPressed;
  final Color color;
  final List<dynamic> items;
  final Function(String) callback;

  //passing props in react style
  DayListLoading(
      {this.onPressed,
      this.onLongPressed,
      this.items,
      this.callback,
      this.color});

  @override
  Widget build(BuildContext context) {
    return buildTimeLine(context);
  }

  Widget buildTimeLine(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
        decoration: BoxDecoration(color: Colors.white),
        child: ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext serperatorContext, int index) =>
              index > 1
                  ? new Container(
                      margin: EdgeInsets.only(left: 80, bottom: 20, top: 0),
                      child: Divider(color: Color.fromRGBO(0, 0, 0, 0.3)))
                  : Container(),
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Center(
                  child: Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
              ));
            }

            if (index == 1) {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 10, bottom: 40),
                child: Text(
                  'Loading day...',
                  style: TextStyle(fontSize: 30),
                ),
              );
            }
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: IntrinsicHeight(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Shimmer.fromColors(
                        baseColor: Color.fromRGBO(220, 220, 220, 0.8),
                        highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(240, 240, 240, 1),
                              borderRadius: BorderRadius.circular(100)),
                        )),
                    Flexible(
                        child: Container(
                            margin:
                                EdgeInsets.only(left: 20, right: 0, bottom: 20),
                            child: Column(children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.all(0),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Shimmer.fromColors(
                                                baseColor: Color.fromRGBO(
                                                    220, 220, 220, 0.8),
                                                highlightColor: Color.fromRGBO(
                                                    240, 240, 240, 0.8),
                                                child: Container(
                                                    color: Color.fromRGBO(
                                                        240, 240, 240, 1),
                                                    height: 20,
                                                    width: 150)),
                                            Shimmer.fromColors(
                                                baseColor: Color.fromRGBO(
                                                    220, 220, 220, 0.8),
                                                highlightColor: Color.fromRGBO(
                                                    240, 240, 240, 0.8),
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      top: 20,
                                                      left: 0,
                                                      right: 0,
                                                      bottom: 20),
                                                  color: Color.fromRGBO(
                                                      240, 240, 240, 1),
                                                  height: 20,
                                                  width: 250,
                                                )),
                                            Shimmer.fromColors(
                                                baseColor: Color.fromRGBO(
                                                    220, 220, 220, 0.8),
                                                highlightColor: Color.fromRGBO(
                                                    240, 240, 240, 0.8),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      105,
                                                  height: 20,
                                                  color: Color.fromRGBO(
                                                      240, 240, 240, 1),
                                                  padding: EdgeInsets.all(0),
                                                  margin: EdgeInsets.only(
                                                      top: 10,
                                                      left: 0,
                                                      right: 0,
                                                      bottom: 20),
                                                )),
                                            Shimmer.fromColors(
                                                baseColor: Color.fromRGBO(
                                                    220, 220, 220, 0.8),
                                                highlightColor: Color.fromRGBO(
                                                    240, 240, 240, 0.8),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      105,
                                                  height: 20,
                                                  color: Color.fromRGBO(
                                                      240, 240, 240, 1),
                                                  padding: EdgeInsets.all(0),
                                                  margin: EdgeInsets.only(
                                                      top: 10,
                                                      left: 0,
                                                      right: 0,
                                                      bottom: 20),
                                                )),
                                          ],
                                        )
                                      ])),
                              Shimmer.fromColors(
                                  baseColor: Color.fromRGBO(220, 220, 220, 0.8),
                                  highlightColor:
                                      Color.fromRGBO(240, 240, 240, 0.8),
                                  child: Container(
                                    height: 230,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ))
                            ])))
                  ],
                )));
          },
        ));
  }
}
