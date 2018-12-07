import 'package:flutter/material.dart';
import 'package:trotter_flutter/widgets/top-list/index.dart';


class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;
  @override
  HomeState createState() => new HomeState();
}

const kExpandedHeight = 300.0;

class HomeState extends State<Home> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() => setState(() {}));
  }

  bool get _showTitle {
    return _scrollController.hasClients
        && _scrollController.offset > kExpandedHeight - kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 350.0,
              floating: false,
              pinned: true,
              backgroundColor: Color.fromRGBO(194, 121, 73, 1),
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  title: _showTitle ? Text("Collapsing Toolbar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    )
                  ) : null,
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
                        top:0,
                        left:0,
                        child: Container(
                          color: Color.fromRGBO(194, 121, 73,0.3),
                        )
                      ),
                      Positioned(
                        top:250,
                        left:0,
                        child: Image.asset(
                          "images/header.png",
                          fit: BoxFit.fill,
                          height: 300.0,
                        )
                      )
                    ]
                  )
                ),
            ),
          ];
        },
        body: Container(padding:EdgeInsets.only(top:40.0), decoration:BoxDecoration(color: Colors.white), child:Column(
          children: <Widget>[
            Container(height:165.0,width:double.infinity,child:TopList(name: "Test", onPressed: null,header: "Test")),
            Container(height:165.0,width:double.infinity,child:TopList(name: "Test", onPressed: null,header: "Test")),
          ],
        )),
      ),
    );
  }
}
