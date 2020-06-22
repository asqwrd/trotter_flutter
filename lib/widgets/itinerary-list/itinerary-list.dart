import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:recase/recase.dart';

class ItineraryList extends StatefulWidget {
  final String2VoidFunc onPressed;
  final Function(dynamic) onLongPressed;
  final Function(dynamic) onRefreshImage;
  final String name;
  final Color color;
  final List<dynamic> items;
  final dynamic linkedItinerary;
  final Function(String) callback;

  //passing props in react style
  ItineraryList(
      {this.name,
      this.onPressed,
      this.onLongPressed,
      this.linkedItinerary,
      this.items,
      this.callback,
      this.onRefreshImage,
      this.color});

  ItineraryListState createState() => ItineraryListState(
      name: this.name,
      onPressed: this.onPressed,
      onLongPressed: this.onLongPressed,
      linkedItinerary: this.linkedItinerary,
      items: this.items,
      callback: this.callback,
      onRefreshImage: this.onRefreshImage,
      color: this.color);
}

class ItineraryListState extends State<ItineraryList> {
  final String2VoidFunc onPressed;
  final Function(dynamic) onLongPressed;
  final Function(dynamic) onRefreshImage;
  final String name;
  final Color color;
  final List<dynamic> items;
  final dynamic linkedItinerary;
  final Function(String) callback;

  //passing props in react style
  ItineraryListState(
      {this.name,
      this.onPressed,
      this.onLongPressed,
      this.linkedItinerary,
      this.items,
      this.callback,
      this.onRefreshImage,
      this.color});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return Container(
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child: buildRow(buildItems(context, widget.items)));
  }

  buildItems(BuildContext context, List<dynamic> items) {
    var widgets = <Widget>[];
    var length = items.length;
    var totalLength = items.length;
    if (length > 3) {
      length = 3;
    }

    if (this.linkedItinerary != null) {
      totalLength++;
    }

    for (int i = 0; i < length; i++) {
      widgets.add(buildBody(context, items[i], i, totalLength));
    }
    if (this.linkedItinerary != null && length < 3) {
      widgets.add(buildBodyItinerary(context,
          widget.linkedItinerary['destination'], length + 1, totalLength));
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

  Widget buildBody(BuildContext context, dynamic item, int index, int count) {
    var time = item['time'];
    var image = item['image'].isEmpty == false
        ? item['image']
        : 'images/placeholder.png';
    var title = item['title'].isEmpty
        ? item['poi'] == null || item['poi']['name'].isEmpty
            ? 'No title given'
            : item['poi']['name'].trim()
        : item['title'].trim();
    var usePlaceholder = item['image'].isEmpty ? true : false;
    var width = MediaQuery.of(context).size.width;
    if (index + 1 == count && count.isEven && count > 2) {
      width = MediaQuery.of(context).size.width;
    } else if (index > 0 && count > 2 && count.isEven) {
      width = (MediaQuery.of(context).size.width - 60) * .5;
    } else if (index > 0 && count > 2 && count.isOdd || count == 2) {
      width = (MediaQuery.of(context).size.width - 60) * .5;
    }

    var timeUnit = time['unit'].toString();
    var timeValue = time['value'].toString();
    var unit = timeUnit;

    if (timeValue.isNotEmpty &&
        double.parse(timeValue) == 1 &&
        timeUnit.endsWith('s')) {
      unit = timeUnit.substring(0, timeUnit.length - 1);
    } else if (timeValue.isNotEmpty &&
        double.parse(timeValue) != 1 &&
        timeUnit.endsWith('s') == false) {
      unit = '${timeUnit}s';
    }

    return new InkWell(
        onTap: () {
          var id = item['poi']['id'];
          var level = 'poi';
          var googlePlace = item['poi']['google_place'];
          this.onPressed(
              {'id': id, 'level': level, 'google_place': googlePlace});
        },
        onLongPress: () {
          this.onLongPressed(item);
        },
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 250,
                width: width,
                child: ClipPath(
                    clipper: ShapeBorderClipper(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: usePlaceholder == false
                        ? TrotterImage(
                            imageUrl: image,
                            loadingWidgetBuilder: (BuildContext context) =>
                                Center(
                                    child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor:
                                  new AlwaysStoppedAnimation<Color>(this.color),
                            )),
                            enableRefresh: true,
                            placeholder: Center(
                                child: IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: () {
                                this.onRefreshImage({
                                  "index": index,
                                  "poi": item['poi'],
                                  "itineraryItemId": item['id']
                                });
                              },
                            )),
                          )
                        : Container(
                            decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(image), fit: BoxFit.cover),
                          ))),
              ),
              Container(
                  width: width,
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        AutoSizeText(ReCase(title).titleCase,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400)),
                        AutoSizeText(
                            time['unit'].toString().isEmpty == false
                                ? 'Suggested time to spend here ${new HtmlUnescape().convert('&bull;')} ${time['value']} $unit'
                                : 'Suggested time to spend here ${new HtmlUnescape().convert('&bull;')} Not given',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w300)),
                      ]))
            ]));
  }

  Widget buildBodyItinerary(
      BuildContext context, dynamic item, int index, int count) {
    var image = item['image'].isEmpty == false
        ? item['image']
        : 'images/placeholder.png';
    var title = item['destination_name'];
    var usePlaceholder = item['image'].isEmpty ? true : false;
    var width = MediaQuery.of(context).size.width;
    if (index + 1 == count && count.isEven && count > 2) {
      width = MediaQuery.of(context).size.width;
    } else if (index > 0 && count > 2 && count.isEven) {
      width = (MediaQuery.of(context).size.width - 60) * .5;
    } else if (index > 0 && count > 2 && count.isOdd || count == 2) {
      width = (MediaQuery.of(context).size.width - 60) * .5;
    }

    return new InkWell(
        onTap: () {
          this.onPressed({'level': "destination"});
        },
        onLongPress: () {},
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 250,
                width: width,
                child: ClipPath(
                    clipper: ShapeBorderClipper(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: usePlaceholder == false
                        ? TrotterImage(
                            imageUrl: image,
                            loadingWidgetBuilder: (BuildContext context) =>
                                Center(
                                    child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor:
                                  new AlwaysStoppedAnimation<Color>(this.color),
                            )),
                            placeholder: const Icon(Icons.refresh),
                          )
                        : Container(
                            decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(image), fit: BoxFit.cover),
                          ))),
              ),
              Container(
                  width: width,
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        AutoSizeText(title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400)),
                      ]))
            ]));
  }
}
