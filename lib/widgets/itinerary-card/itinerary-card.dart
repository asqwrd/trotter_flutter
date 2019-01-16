import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';

class ItineraryCard extends StatelessWidget {
  final String2VoidFunc onPressed;
  final ValueChanged onLongPressed;
  final String name;
  final dynamic item;
  final Function(String) callback;
  final Color color;


  //passing props in react style
  ItineraryCard({
    this.name,
    this.onPressed,
    this.onLongPressed,
    this.item,
    this.callback,
    this.color
  });

  @override
  
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0), 
      child: Container(
        margin: EdgeInsets.only(left: 20.0, right:20.0, bottom:20.0),
        child: buildBody(context, this.item)
      )
    );
  }

  Widget buildBody(BuildContext ctxt, dynamic item) {
  return new InkWell ( 
    onTap: (){
      var id = item['id'];
      this.onPressed({'id': id, 'level': 'itinerary'});
    },
    onLongPress: () {
      this.onLongPressed({'item': item});
    },
    child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(240, 240, 240, 0.8),
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: item['days'][0]['itinerary_items'][0]['poi']['images'] != null ? NetworkImage(item['days'][0]['itinerary_items'][0]['poi']['images'][0]['sizes']['medium']['url']) : AssetImage('images/placeholder.jpg'),
                  fit: BoxFit.cover
                )
              ),
              width: double.infinity,
              height: 300,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    child: Center(child:SvgPicture.asset(
                      'images/trotter-logo.svg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    )
                  ))
                ],
              )
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              //width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children:<Widget>[
                  Flexible(child:Text(
                    item['name'], 
                    textAlign: TextAlign.left, 
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: this.color
                    ),
                  )),
                  Flexible(child:Text(
                    ' ${new HtmlUnescape().convert('&bull;')} ${item['destination_name']}, ${item['destination_country_name']}', 
                    textAlign: TextAlign.left, 

                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300
                    ),
                  )),
                ]
              )
            )
          ]
        )
      
    );
  }
}