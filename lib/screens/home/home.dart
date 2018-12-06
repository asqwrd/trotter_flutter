import 'package:flutter/material.dart';
import 'package:flutter_parallax/flutter_parallax.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;
  @override
  HomeState createState() => new HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text("Collapsing Toolbar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Image.asset(
                    "images/home_bg.jpeg",
                    fit: BoxFit.cover,
                  )),
            ),
          ];
        },
        body: Center(
          child: Text("Sample Text"),
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    if (index == 0) {
      return new Container(color: Colors.transparent, height: 200.0);
    } else if (index == 1) {
      return new Container(
          height: 400.0,
          child: new Image(
              image: new AssetImage('images/header.png'), fit: BoxFit.fill));
    }
    return new Container(
        height: 400.0, child: new TopList(name: 'bksfjhkds', onPressed: null));
  }
}
