import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ItineraryListLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child: buildRow(buildItems(context)));
  }

  buildItems(BuildContext context) {
    var widgets = <Widget>[];
    for (int i = 0; i < 3; i++) {
      widgets.add(buildBody(context, i, 3));
    }
    return widgets;
  }

  buildRow(List<Widget> widgets) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.start,
      spacing: 20,
      runSpacing: 40,
      children: widgets,
    );
  }

  Widget buildBody(BuildContext context, index, int count) {
    var width = MediaQuery.of(context).size.width;
    if (index + 1 == count && count.isEven && count > 2) {
      width = MediaQuery.of(context).size.width;
    } else if (index > 0 && count > 2 && count.isEven) {
      width = (MediaQuery.of(context).size.width - 60) * .5;
    } else if (index > 0 && count > 2 && count.isOdd || count == 2) {
      width = (MediaQuery.of(context).size.width - 60) * .5;
    }

    return new InkWell(
        onTap: () {},
        onLongPress: () {},
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Shimmer.fromColors(
                  baseColor: Color.fromRGBO(220, 220, 220, 0.8),
                  highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
                  child: Container(
                      height: 250,
                      width: width,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Color.fromRGBO(220, 220, 220, 0.8)))
                        ],
                      ))),
              Container(
                  width: width,
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Shimmer.fromColors(
                            baseColor: Color.fromRGBO(220, 220, 220, 0.8),
                            highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
                            child: Container(
                              color: Color.fromRGBO(220, 220, 220, 0.8),
                              height: 20,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              width: 150,
                            )),
                        Container(
                          color: Color.fromRGBO(220, 220, 220, 0.8),
                          height: 20,
                          width: 120,
                        ),
                      ]))
            ]));
  }
}
