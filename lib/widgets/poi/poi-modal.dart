import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_advanced_networkimage/transition.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';

class PoiModal extends StatefulWidget {
  final dynamic destination;
  final String query;
  final String title;
  final dynamic onPush;

  PoiModal({Key key, this.destination, this.query, this.title, this.onPush})
      : super(key: key);
  @override
  PoiModalState createState() => new PoiModalState(
      destination: this.destination,
      query: this.query,
      title: this.title,
      onPush: this.onPush);
}

class PoiModalState extends State<PoiModal> {
  PoiModalState({this.destination, this.query, this.title, this.onPush});
  bool showDone = false;
  final dynamic destination;
  List<dynamic> results = [];
  final String query;
  final String title;
  Future<CategoryData> data;
  bool loading = true;
  final dynamic onPush;
  ScrollController _sc = new ScrollController();
  bool shadow = false;

  @override
  void initState() {
    data = fetchCategoryPlaces(
        this.destination['destination_id'], this.query, destination['type']);
    data.then((res) {
      if (res.success == true) {
        setState(() {
          this.results = res.places;
        });
      }
      setState(() {
        this.loading = false;
      });
    });

    _sc.addListener(() {
      if (_sc.offset > 0) {
        setState(() {
          this.shadow = true;
        });
      } else {
        setState(() {
          this.shadow = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                //color: color,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    boxShadow: this.shadow
                        ? <BoxShadow>[
                            BoxShadow(
                                color: Colors.black.withOpacity(.2),
                                blurRadius: 10.0,
                                offset: Offset(0.0, 0.75))
                          ]
                        : []),
                height: 80,
                child: TrotterAppBar(
                    title: title,
                    back: true,
                    onPush: () {},
                    showSearch: false,
                    brightness: Brightness.light,
                    color: Colors.white)),
            this.loading
                ? RefreshProgressIndicator()
                : Flexible(
                    child: Results(
                    results: this.results,
                    scrollController: _sc,
                    destination: this.destination,
                    onPush: onPush,
                  ))
          ],
        ));
  }
}

class Results extends StatelessWidget {
  final List<dynamic> results;
  final dynamic destination;
  final dynamic onPush;
  final ScrollController scrollController;

  Results({this.results, this.destination, this.onPush, this.scrollController});

  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
            onTap: () {
              //onSelect({'selected':results[index]});
              this.onPush({
                'id': results[index]['id'],
                'destination': this.destination,
                'level': 'poi',
                'google_place': results[index]['google_place']
              });
              //Navigator.pop(context, results[index]);
            },
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: ListTile(
                  leading: Container(
                    width: 80.0,
                    height: 80.0,
                    child: ClipPath(
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                        child: results[index]['image'] != null
                            ? TransitionToImage(
                                image: AdvancedNetworkImage(
                                  results[index]['image'],
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
                              ))),
                  ),
                  title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        AutoSizeText(
                          '${results[index]['name']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        Container(
                            width: 100,
                            child: RatingBar.readOnly(
                              initialRating: results[index]['score'].toDouble(),
                              size: 20,
                              isHalfAllowed: true,
                              halfFilledIcon: Icons.star_half,
                              filledIcon: Icons.star,
                              emptyIcon: Icons.star_border,
                            )),
                      ]),
                  subtitle: results[index]['description_short'] != null
                      ? AutoSizeText(
                          results[index]['description_short'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w300),
                        )
                      : AutoSizeText(
                          results[index]['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w300),
                        ),
                )));
      },
    );
  }
}
