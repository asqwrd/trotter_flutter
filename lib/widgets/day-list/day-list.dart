import 'package:flutter/material.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:simple_moment/simple_moment.dart';



class DayList extends StatelessWidget {
  final String2VoidFunc onPressed;
  final ValueChanged onLongPressed;
  final Color color;
  final List<dynamic> items;
  final Function(String) callback;

  //passing props in react style
  DayList({
    this.onPressed,
    this.onLongPressed,
    this.items,
    this.callback,
    this.color
  });

  @override
  Widget build(BuildContext context) {
    return buildTimeLine(context, this.items);
  }
  

  Widget buildTimeLine(BuildContext context, List<dynamic> itineraryItems) {
    return Container(
      margin: EdgeInsets.only(top: 10.0, left: 0.0, right: 0.0),
      decoration: BoxDecoration(color: Colors.white),
      child: ListView.separated(
        separatorBuilder: (BuildContext serperatorContext, int index) => new Container(margin:EdgeInsets.only(left : 80, bottom: 20, top: 0), child:Divider(color: Color.fromRGBO(0, 0, 0, 0.3))),
        itemCount: itineraryItems.length,
        itemBuilder: (BuildContext context, int index){
          var color = itineraryItems[index]['color'].isEmpty == false ? Color(hexStringToHexInt(itineraryItems[index]['color'])) : this.color;
          var poi = itineraryItems[index]['poi'];
          var item = itineraryItems[index];
          var justAdded = itineraryItems[index]['justAdded'];
          var travelTime = itineraryItems[index]['travel'];
          var prevIndex = index - 1;
          var from = 'city center';
          if(prevIndex >= 0){
            from = itineraryItems[prevIndex]['poi']['name'];
          }

          var time = itineraryItems[index]['travel']['duration']['text'];
          
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child:IntrinsicHeight(child:Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  margin:EdgeInsets.only(bottom:20),
                  decoration: BoxDecoration(
                    color:color,
                    borderRadius: BorderRadius.circular(100)
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child:Icon(
                    Icons.access_time,
                    color:fontContrast(color),
                    size: 25
                  )),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(left: 20, right: 0, bottom: 20),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child:Container(
                          //color: color,
                          //padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top:10, bottom:20),
                          child: Text(
                            '${travelTime['distance']['text']} away from $from \nTravel time is $time',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: color,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.1
                              
                            ),
                            )
                        ))
                        ,
                        Padding(
                          padding: EdgeInsets.all(0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  poi == null ? Container() : Row(
                                    //crossAxisAlignment: CrossAxisAlignment.center,
                                    children:<Widget>[ 
                                    Text(
                                      poi['name'],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        
                                      )
                                    ),
                                    justAdded == true ? Text(
                                      ' - just added',
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w400,
                                        
                                      )
                                    ):Container()
                                  ]),
                                  poi == null ? Container() : poi['tags'] != null ? Container(
                                    width: MediaQuery.of(context).size.width - 176,
                                    margin: EdgeInsets.only(top:5),
                                    child:Text(
                                    tagsToString(poi['tags']),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    )
                                  )) : Container(),
                                  item['description'].isEmpty == false ? 
                                    Container(
                                      width: MediaQuery.of(context).size.width - 105,
                                      padding: EdgeInsets.all(0),
                                      margin: EdgeInsets.only(top: 10, left: 0, right:0, bottom: 20),
                                      child: Text(
                                        item['description'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w300,
                                          height: 1.3
                                        ),
                                    )
                                  ) : Container()
                                ],
                              )
                            ]
                          )
                        ),
                        item['image'].isEmpty == false ? Card(
                          //opacity: 1,
                          elevation: 1,
                          margin: EdgeInsets.only(top:30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                          ),
                          child: Container(
                            height: 230,
                            width:MediaQuery.of(context).size.width - 105,
                            child: ClipPath(
                              clipper: ShapeBorderClipper(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
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
                          )
                        ) : Container()

                      ]
                    )
                  )
                )
                
              ],
            ))
          );
        },
      )
    );
  }
}
