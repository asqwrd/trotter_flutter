import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItineraryCard extends StatelessWidget {
  final String2VoidFunc onPressed;
  final ValueChanged onLongPressed;
  final String name;
  final dynamic item;
  final Function(String) callback;
  final Color color;

  //passing props in react style
  ItineraryCard(
      {this.name,
      this.onPressed,
      this.onLongPressed,
      this.item,
      this.callback,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        child: Container(
            margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 0.0),
            child: buildBody(context, this.item)));
  }

  Widget buildBody(BuildContext ctxt, dynamic item) {
    return new InkWell(
        onTap: () {
          var id = item['id'];
          this.onPressed({'id': id, 'level': 'itinerary'});
        },
        onLongPress: () {
          this.onLongPressed({'item': item});
        },
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: 90,
                  height: 90,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          child: Center(
                              child: Align(
                                  child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(color),
                      )))),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: ClipPath(
                            clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: item['days'][0]['itinerary_items'][0]['poi']
                                            ['images'][0]['sizes']['medium']
                                        ['url'] !=
                                    null
                                ? CachedNetworkImage(
                                    placeholder: (context, url) => SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  new AlwaysStoppedAnimation<
                                                      Color>(color),
                                            ))),
                                    fit: BoxFit.cover,
                                    imageUrl: item['days'][0]['itinerary_items']
                                            [0]['poi']['images'][0]['sizes']
                                        ['medium']['url'],
                                    errorWidget: (context, url, error) =>
                                        Container(
                                            decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'images/placeholder.jpg'),
                                              fit: BoxFit.cover),
                                        )))
                                : Container(
                                    decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'images/placeholder.jpg'),
                                        fit: BoxFit.cover),
                                  ))),
                      )
                    ],
                  )),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10),
                  width: MediaQuery.of(ctxt).size.width - 130,
                  height: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max, 
                  children: <Widget>[
                    Container(
                        child: Text(
                      item['name'],
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: this.color),
                    )),
                    Container(
                      margin: EdgeInsets.only(top:5),
                        child: Row(children:<Widget>[
                          Icon(Icons.place, size: 15, color: Colors.black.withOpacity(.3),),
                          Text(
                      '${item['destination_name']}, ${item['destination_country_name']}',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color:Colors.black.withOpacity(.5)),
                    )])),
                    Container(
                      height:40,
                      alignment: Alignment.bottomLeft,
                        child: Text(
                      '${item['days'].length} day itinerary',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    )),
                  ]))
            ]));
  }
}
