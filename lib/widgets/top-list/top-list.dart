import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:cached_network_image/cached_network_image.dart';


class TopList extends StatelessWidget {
  final String2VoidFunc onPressed;
  final ValueChanged onLongPressed;
  final String name;
  final String header;
  final List<dynamic> items;
  final Function(String) callback;


  //passing props in react style
  TopList({
    this.header,
    this.name,
    this.onPressed,
    this.onLongPressed,
    this.items,
    this.callback
  });

  @override
  
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0), 
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children:<Widget>[
          Container(
            margin: EdgeInsets.only(left: 20.0, right:20.0, bottom:10.0),
            child: Text(
              this.header,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600
              ),
            )
          ),
          
          Container( 
            width:MediaQuery.of(context).size.width,
            height: 216,
            child: ListView.builder(
            primary: false,
            scrollDirection: Axis.horizontal,
            itemCount: this.items.length,
            itemBuilder: (BuildContext context, int index)=> buildBody(this.items[index], index),
          ))
        ]
      )
    );
  }

  Widget buildBody(dynamic item, int index) {
  return new InkWell ( 
    onTap: (){
      var id = item['id'];
      var level = item['level'];
      this.onPressed({'id': id, 'level': level});
    },
    onLongPress: () {
      this.onLongPressed({'item': item});
    },
    child:Container(
      //height:210.0,
      margin: index == 0 ? EdgeInsets.only(left:20.0) : EdgeInsets.only(left:0.0),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              // A fixed-height child.
              margin:EdgeInsets.only(right:20),
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                    )
                  ), 
                  child: item['image'] != null ? CachedNetworkImage(
                    placeholder: (context, url) => SizedBox(
                      width: 50, 
                      height:50, 
                      child: Align( alignment: Alignment.center, child:CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      )
                    )),
                  fit: BoxFit.cover, 
                  imageUrl: item['image'],
                  errorWidget: (context,url, error) =>  Container( 
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:AssetImage('images/placeholder.jpg'),
                        fit: BoxFit.cover
                      ),
                      
                    )
                  )
                ) : Container( 
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image:AssetImage('images/placeholder.jpg'),
                        fit: BoxFit.cover
                      ),
                      
                    )
                  )
              ),
              width: 175.0,
              height: 160.0,              
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              width: 150.0,
              child: Text(
                item['name'], 
                textAlign: TextAlign.left, 
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300
                ),
              )
            )
          ]
        )
      )
    );
  }
}