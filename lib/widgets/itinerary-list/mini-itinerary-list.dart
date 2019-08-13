import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/utils/index.dart';

class MiniItineraryList extends StatelessWidget {
  final String2VoidFunc onPressed;
  final Function(dynamic) onLongPressed;
  final String name;
  final List<dynamic> items;
  final Function(String) callback;
  final dynamic destination;

  //passing props in react style
  MiniItineraryList({
    this.name,
    this.destination,
    this.onPressed,
    this.onLongPressed,
    this.items,
    this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 0.0),
            width: 210,
            child: buildRow(buildItems(context, this.items))));
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
    if (length == 0) {
      widgets.add(buildBody(context, null, 0, 1));
    }
    return widgets;
  }

  buildRow(List<Widget> widgets) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: widgets,
    );
  }

  Widget buildBody(BuildContext context, dynamic item, int index, int count) {
    var image = item != null && item['image'].isEmpty == false
        ? item['image']
        : 'images/placeholder.jpg';
    var usePlaceholder = item == null || item['image'].isEmpty ? true : false;

    if (item == null) {
      return Container(
        height: 210,
        width: 210,
        margin: EdgeInsets.only(right: 20),
        child: ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: usePlaceholder == false
                ? TransitionToImage(
                    image: AdvancedNetworkImage(
                      image,
                      useDiskCache: true,
                      cacheRule: CacheRule(maxAge: const Duration(days: 7)),
                    ),
                    loadingWidgetBuilder:
                        (BuildContext context, double progress, test) => Center(
                            child: RefreshProgressIndicator(
                      backgroundColor: Colors.white,
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
      );
    }

    var width = 210.0;
    var height = 100.0;
    if (index + 1 == count && count.isEven && count > 2) {
      width = 210;
    } else if (index > 0 && count > 2 && count.isEven) {
      width = (200) * .5;
    } else if (index > 0 && count > 2 && count.isOdd) {
      width = 200 * .5;
    } else if (count == 1) {
      height = 210;
    } else if (count == 2) {
      width = 210;
    }

    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
          Container(
            height: height,
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
                          cacheRule: CacheRule(maxAge: const Duration(days: 7)),
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
                    : Container(
                        decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(image), fit: BoxFit.cover),
                      ))),
          )
        ]));
  }
}
