import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trotter_flutter/utils/index.dart';

class ItineraryListLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
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

  Widget buildBody(BuildContext context, int index, int count) {
    var width = MediaQuery.of(context).size.width;
    if (index + 1 == count && count.isEven && count > 2) {
      width = MediaQuery.of(context).size.width;
    } else if (index > 0 && count > 2 && count.isEven) {
      width = (MediaQuery.of(context).size.width - 60) * .5;
    } else if (index > 0 && count > 2 && count.isOdd || count == 2) {
      width = (MediaQuery.of(context).size.width - 60) * .5;
    }

    return Shimmer.fromColors(
        baseColor: Color.fromRGBO(220, 220, 220, 0.8),
        highlightColor: Color.fromRGBO(240, 240, 240, 0.8),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: width,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(220, 220, 220, 0.8),
                ),
              ),
              Container(
                  width: width,
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 20.0, top: 10.0),
                          width: 100.0,
                          height: 18.0,
                          margin: EdgeInsets.only(left: 0.0, bottom: 10),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(240, 240, 240, 0.8),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 20.0, top: 10.0),
                          width: 70.0,
                          height: 18.0,
                          margin: EdgeInsets.only(left: 0.0),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(240, 240, 240, 0.8),
                          ),
                        )
                      ]))
            ]));
  }
}
