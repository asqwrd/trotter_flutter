import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:recase/recase.dart';

class ItineraryList extends StatelessWidget {
  final String2VoidFunc onPressed;
  final Function(dynamic) onLongPressed;
  final String name;
  final Color color;
  final List<dynamic> items;
  final Function(String) callback;

  //passing props in react style
  ItineraryList(
      {this.name,
      this.onPressed,
      this.onLongPressed,
      this.items,
      this.callback,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child: buildRow(buildItems(context, this.items)));
  }

  buildItems(BuildContext context, List<dynamic> items) {
    var widgets = <Widget>[];
    var length = items.length;
    if (length > 3) {
      length = 3;
    }
    for (int i = 0; i < length; i++) {
      widgets.add(buildBody(context, items[i], i, items.length));
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
                        ? TransitionToImage(
                            image: AdvancedNetworkImage(
                              image,
                              useDiskCache: true,
                              cacheRule:
                                  CacheRule(maxAge: const Duration(days: 7)),
                            ),
                            loadingWidgetBuilder:
                                (BuildContext context, double progress, test) =>
                                    Center(
                                        child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor:
                                  new AlwaysStoppedAnimation<Color>(this.color),
                            )),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            placeholder: const Icon(Icons.refresh),
                            enableRefresh: true,
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
                                ? 'Estimated time ${new HtmlUnescape().convert('&bull;')} ${time['value']} ${time['unit']}'
                                : 'Estimated time ${new HtmlUnescape().convert('&bull;')} 1 hour',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w300)),
                      ]))
            ]));
  }
}
