import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:recase/recase.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        : 'images/placeholder.jpg';
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
                                        child: RefreshProgressIndicator(
                              backgroundColor: Colors.white,
                            )),
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            placeholder: const Icon(Icons.refresh),
                            enableRefresh: true,
                          )

                        // CachedNetworkImage(
                        //   placeholder: (context, url) => SizedBox(
                        //     width: 50,
                        //     height:50,
                        //     child: Align( alignment: Alignment.center, child:CircularProgressIndicator(
                        //       valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                        //     )
                        //   )),
                        //   fit: BoxFit.cover,
                        //   imageUrl: image,
                        //   errorWidget: (context,url, error) =>  Container(
                        //     decoration: BoxDecoration(
                        //       image: DecorationImage(
                        //         image:AssetImage(image),
                        //         fit: BoxFit.cover
                        //       ),

                        //     )
                        //   )
                        // )
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
                        Text(ReCase(title).titleCase,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400)),
                        Text(
                            time['unit'].toString().isEmpty == false
                                ? 'Estimated time ${new HtmlUnescape().convert('&bull;')} ${time['value']} ${time['unit']}'
                                : 'Estimated time ${new HtmlUnescape().convert('&bull;')} 1 hour',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w300)),
                      ]))
            ]));
  }
}
