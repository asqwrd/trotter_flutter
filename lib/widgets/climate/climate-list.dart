import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';

class ClimateList extends StatelessWidget {
  final TemperatureType temperature;
  final Color color;
  ClimateList({this.temperature, this.color});

  ctoF(num c) {
    return (c * 9 / 5 + 32).round();
  }

  @override
  Widget build(context) {
    final maxMonths = this.temperature.averageMax.months;
    final minMonths = this.temperature.averageMin.months;
    return Container(
        height: 125,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: 12,
          itemBuilder: (context, index) {
            return Container(
                margin: index == 0
                    ? EdgeInsets.only(left: 20, right: 15)
                    : EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _suggestion(ctoF(maxMonths[index])),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _icon(ctoF(maxMonths[index])),
                                _months(index)
                              ]),
                          Container(
                              margin: EdgeInsets.only(left: 15, top: 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                      child: AutoSizeText(
                                          '${ctoF(maxMonths[index])}${new HtmlUnescape().convert('&deg;')}')),
                                  Container(
                                      margin: EdgeInsets.only(top: 3),
                                      child: AutoSizeText(
                                        '${ctoF(minMonths[index])}${new HtmlUnescape().convert('&deg;')}',
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.3)),
                                      ))
                                ],
                              )),
                        ],
                      )
                    ]));
          },
        ));
  }

  _months(int number) {
    final TextStyle style = TextStyle(color: Colors.black.withOpacity(.7));
    final EdgeInsets margin = EdgeInsets.all(10);
    switch (number) {
      case 0:
        return Container(
          margin: margin,
          child: AutoSizeText('Jan', style: style),
        );
      case 1:
        return Container(
            margin: margin, child: AutoSizeText('Feb', style: style));
      case 2:
        return Container(
            margin: margin, child: AutoSizeText('Mar', style: style));
      case 3:
        return Container(
            margin: margin, child: AutoSizeText('Apr', style: style));
      case 4:
        return Container(
            margin: margin, child: AutoSizeText('May', style: style));
      case 5:
        return Container(
            margin: margin, child: AutoSizeText('Jun', style: style));
      case 6:
        return Container(
            margin: margin, child: AutoSizeText('Jul', style: style));
      case 7:
        return Container(
            margin: margin, child: AutoSizeText('Aug', style: style));
      case 8:
        return Container(
            margin: margin, child: AutoSizeText('Sep', style: style));
      case 9:
        return Container(
            margin: margin, child: AutoSizeText('Oct', style: style));
      case 10:
        return Container(
            margin: margin, child: AutoSizeText('Nov', style: style));
      case 11:
        return Container(
            margin: margin, child: AutoSizeText('Dec', style: style));
    }
  }

  _suggestion(num temperature) {
    final TextStyle style = TextStyle(color: Colors.black.withOpacity(.7));
    final EdgeInsets margin = EdgeInsets.symmetric(vertical: 10);
    if (temperature >= 85) {
      return Container(
          margin: margin, child: AutoSizeText('Hot weather', style: style));
    } else if (temperature >= 71 && temperature <= 84) {
      return Container(
          margin: margin,
          child: AutoSizeText('Flip-flop weather', style: style));
    } else if (temperature >= 61 && temperature <= 70) {
      return Container(
          margin: margin, child: AutoSizeText('Sweater weather', style: style));
    } else if (temperature >= 40 && temperature <= 60) {
      return Container(
          margin: margin, child: AutoSizeText('Bring a coat', style: style));
    }

    return Container(
        margin: margin, child: AutoSizeText('Bundle up', style: style));
  }

  _icon(num temperature) {
    final double width = 50;
    final double height = 50;
    final BoxFit fit = BoxFit.contain;
    final BoxDecoration decoration =
        BoxDecoration(borderRadius: BorderRadius.circular(100), color: color);
    final EdgeInsets padding = EdgeInsets.all(10);

    if (temperature >= 85) {
      return Container(
          decoration: decoration,
          width: width,
          height: height,
          padding: padding,
          child: SvgPicture.asset(
            'images/sun-umbrella.svg',
            fit: fit,
          ));
    } else if (temperature >= 71 && temperature <= 84) {
      return Container(
          width: width,
          height: height,
          padding: padding,
          decoration: decoration,
          child: SvgPicture.asset(
            'images/flip-flops.svg',
            fit: fit,
          ));
    } else if (temperature >= 61 && temperature <= 70) {
      return Container(
          width: width,
          height: height,
          padding: padding,
          decoration: decoration,
          child: SvgPicture.asset(
            'images/sweater.svg',
            fit: fit,
          ));
    } else if (temperature >= 40 && temperature <= 60) {
      return Container(
          width: width,
          height: height,
          decoration: decoration,
          padding: padding,
          child: SvgPicture.asset(
            'images/jacket.svg',
            fit: fit,
          ));
    }

    return Container(
        width: width,
        height: height,
        decoration: decoration,
        padding: padding,
        child: SvgPicture.asset(
          'images/hat.svg',
          fit: fit,
        ));
  }
}

class AverageMonths {
  final List<num> months;

  AverageMonths({this.months});
}

class TemperatureType {
  final AverageMonths averageMax;
  final AverageMonths averageMin;
  TemperatureType({this.averageMax, this.averageMin});

  factory TemperatureType.fromJson(Map<dynamic, dynamic> json) {
    final List<num> maxMonths = List<num>.from(json['average_max']['months']);
    final List<num> minMonths = List<num>.from(json['average_min']['months']);
    return TemperatureType(
        averageMax: AverageMonths(months: maxMonths),
        averageMin: AverageMonths(months: minMonths));
  }
}
