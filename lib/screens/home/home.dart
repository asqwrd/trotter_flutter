import 'package:flutter/material.dart';
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
              expandedHeight: 350.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text("Collapsing Toolbar",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      )),
                  background: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        top:0,
                        child:Image.asset(
                          "images/home_bg.jpeg",
                          fit: BoxFit.cover,
                        )
                      ),
                      Positioned.fill(
                        top:250,
                        child: Image.asset(
                          "images/header.png",
                          fit: BoxFit.fill,
                        )
                      )
                    ]
                  )
                ),
            ),
          ];
        },
        body: Stack(
          children: <Widget>[
            TopList(name: "Test", onPressed: null,)
          ],
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
