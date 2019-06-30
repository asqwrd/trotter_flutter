import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Profile extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  Profile({Key key, this.onPush}) : super(key: key);
  @override
  ProfileState createState() => new ProfileState(onPush: this.onPush);
}

class ProfileState extends State<Profile> {
  final ValueChanged<dynamic> onPush;
  bool _showTitle = false;
  final ScrollController _scrollController = ScrollController();
  var kExpandedHeight = 280;
  var trip;

  @override
  void initState() {
    _scrollController.addListener(() => setState(() {
          _showTitle = _scrollController.hasClients &&
              _scrollController.offset > kExpandedHeight - kToolbarHeight;
        }));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ProfileState({this.onPush});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<TrotterStore>(context);
    return _buildContent(context, store);
  }

  Widget _buildContent(BuildContext context, TrotterStore store) {
    var color = Color.fromRGBO(1, 155, 174, 1);
    return NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 350,
              floating: false,
              pinned: true,
              backgroundColor: this._showTitle ? color : Colors.white,
              automaticallyImplyLeading: false,
              title: this._showTitle
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(right: 10.0),
                              child: store.currentUser == null
                                  ? SvgPicture.asset("images/avatar-icon.svg",
                                      width: 30.0,
                                      height: 30.0,
                                      fit: BoxFit.contain)
                                  : Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                              style: BorderStyle.solid,
                                              color: Colors.white,
                                              width: 2)),
                                      child: ClipPath(
                                          clipper: CornerRadiusClipper(100),
                                          child: Image.network(
                                              store.currentUser.photoUrl,
                                              width: 30.0,
                                              height: 30.0,
                                              fit: BoxFit.contain)))),
                          Text('Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300))
                        ])
                  : Container(),
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  background: Stack(children: <Widget>[
                    Positioned.fill(
                        top: 0,
                        child: ClipPath(
                          child: Image.asset("images/search2.jpg",
                              fit: BoxFit.cover),
                          clipper: CurveClipper(),
                        )),
                    Positioned.fill(
                        top: 0,
                        left: 0,
                        child: ClipPath(
                            clipper: CurveClipper(),
                            child: Container(
                              color: color.withOpacity(0.5),
                            ))),
                    Positioned(
                        left: 0,
                        top: 100,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(right: 10.0),
                                  child: store.currentUser == null
                                      ? SvgPicture.asset(
                                          "images/avatar-icon.svg",
                                          width: 100.0,
                                          height: 100.0,
                                          fit: BoxFit.contain)
                                      : Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              border: Border.all(
                                                  style: BorderStyle.solid,
                                                  color: Colors.white,
                                                  width: 2)),
                                          child: ClipPath(
                                              clipper: CornerRadiusClipper(100),
                                              child: Image.network(
                                                  store.currentUser.photoUrl,
                                                  width: 100.0,
                                                  height: 100.0,
                                                  fit: BoxFit.contain)))),
                              store.currentUser == null
                                  ? Text('Profile',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w300))
                                  : Text(store.currentUser.displayName,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.w300))
                            ])),
                  ])),
            ),
          ];
        },
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ListView(
                children: <Widget>[Align(child: GoogleAuthButtonContainer())]),
            // this.loading ?? Align(
            //   alignment: Alignment.center,
            //   child: CircularProgressIndicator(
            //     valueColor: new AlwaysStoppedAnimation<Color>(color)
            //   ),
            // )
          ],
        ));
  }
}
