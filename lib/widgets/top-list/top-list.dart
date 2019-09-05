import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:trotter_flutter/utils/index.dart';

class TopList extends StatelessWidget {
  final String2VoidFunc onPressed;
  final ValueChanged onLongPressed;
  final String name;
  final String header;
  final List<dynamic> items;
  final Function(String) callback;

  //passing props in react style
  TopList(
      {this.header,
      this.name,
      this.onPressed,
      this.onLongPressed,
      this.items,
      this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 0.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  margin:
                      EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  child: AutoSizeText(
                    this.header,
                    style:
                        TextStyle(fontSize: 19.0, fontWeight: FontWeight.w300),
                  )),
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 240,
                  child: ListView.builder(
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    itemCount: this.items.length,
                    itemBuilder: (BuildContext context, int index) =>
                        buildBody(this.items[index], index),
                  ))
            ]));
  }

  Widget buildBody(dynamic item, int index) {
    return new InkWell(
        onTap: () {
          var id = item['id'];
          var level = item['level'];
          this.onPressed({'id': id, 'level': level});
        },
        onLongPress: () {
          this.onLongPressed({'poi': item, "index": index});
        },
        child: buildThumbnailItem(index, item, Colors.black));
  }

  Container buildThumbnailItem(int index, item, Color fontColor) {
    return Container(
        //height:210.0,
        margin: index == 0
            ? EdgeInsets.only(left: 20.0)
            : EdgeInsets.only(left: 0.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                // A fixed-height child.
                margin: EdgeInsets.only(right: 20),
                child: Card(
                    //opacity: 1,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: ClipPath(
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: item['image'] != null
                            ? TransitionToImage(
                                image: AdvancedNetworkImage(
                                  item['image'],
                                  useDiskCache: true,
                                  cacheRule: CacheRule(
                                      maxAge: const Duration(days: 7)),
                                ),
                                loadingWidgetBuilder: (BuildContext context,
                                        double progress, test) =>
                                    Center(
                                        child: CircularProgressIndicator(
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
                                    image: AssetImage('images/placeholder.png'),
                                    fit: BoxFit.cover),
                              )))),
                width: 110.0,
                height: 158.0,
              ),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  width: 100.0,
                  child: AutoSizeText(
                    item['name'],
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: fontColor),
                  ))
            ]));
  }
}
