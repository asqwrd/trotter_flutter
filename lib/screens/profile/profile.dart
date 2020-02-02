import 'package:auto_size_text/auto_size_text.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/store/auth.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/auth/index.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Profile extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  Profile({Key key, this.onPush}) : super(key: key);
  @override
  ProfileState createState() => new ProfileState(onPush: this.onPush);
}

class ProfileState extends State<Profile> {
  final ValueChanged<dynamic> onPush;
  PanelController _pc = new PanelController();

  var kExpandedHeight = 280;
  var trip;
  final color = Color.fromRGBO(1, 155, 174, 1);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ProfileState({this.onPush});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    final store = Provider.of<TrotterStore>(context);
    final panelHeights = getPanelHeights(context);

    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingUpPanel(
              backdropColor: color,
              backdropEnabled: true,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              backdropOpacity: 1,
              maxHeight: panelHeights.max,
              minHeight: panelHeights.max,
              isDraggable: false,
              defaultPanelState: PanelState.OPEN,
              parallaxEnabled: true,
              parallaxOffset: .5,
              controller: _pc,
              panelBuilder: (sc) {
                return Center(
                    child: RenderWidget(
                        builder: (context,
                                {scrollController,
                                asyncSnapshot,
                                startLocation}) =>
                            _buildContent(context, store, scrollController)));
              })),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
            onPush: onPush,
            color: color,
            title: 'Profile',
            showSearch: false,
          )),
    ]);
  }

  Widget _buildContent(
      BuildContext context, TrotterStore store, ScrollController _sc) {
    final List<Widget> fields = [
      store.currentUser != null
          ? ListTile(
              title: CountryCodePicker(
                searchDecoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                    prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 5.0),
                        child: Icon(Icons.home, size: 15)),
                    //fillColor: Colors.blueGrey.withOpacity(0.5),
                    filled: true,
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(width: 1.0, color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(width: 1.0, color: Colors.red)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide:
                            BorderSide(width: 0.0, color: Colors.transparent)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide:
                            BorderSide(width: 0.0, color: Colors.transparent)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide:
                            BorderSide(width: 0.0, color: Colors.transparent)),
                    hintText: 'Search country',
                    hintStyle: TextStyle(fontSize: 13)),
                onChanged: (CountryCode data) {
                  print(data.code);
                  setState(() {
                    store.updateUserCountry(data.code);
                  });
                },
                showOnlyCountryWhenClosed: true,
                initialSelection: store.currentUser.country,
                showCountryOnly: true,
                alignLeft: true,
              ),
            )
          : Container(),
      store.currentUser != null
          ? ListTile(
              title: AutoSizeText('Notifications'),
              trailing: Switch(
                value: store.currentUser.notificationOn,
                onChanged: (value) {
                  setState(() {
                    //isSwitched = value;
                    store.updateUserNotification(value);
                  });
                },
                activeTrackColor: color.withOpacity(.65),
                activeColor: color,
              ),
            )
          : Container()
    ];
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Center(
                child: ListView(shrinkWrap: true, controller: _sc, children: <
                    Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        margin:
                            EdgeInsets.only(right: 10.0, bottom: 10, top: 10),
                        child: store.currentUser == null
                            ? SvgPicture.asset(
                                "images/avatar-icon.svg",
                                width: 80.0,
                                height: 80.0,
                                fit: BoxFit.contain,
                                color: color,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        style: BorderStyle.solid,
                                        color: Colors.white,
                                        width: 2)),
                                child: ClipPath(
                                    clipper: CornerRadiusClipper(300),
                                    child: Image.network(
                                        store.currentUser.photoUrl,
                                        width: 80.0,
                                        height: 80.0,
                                        fit: BoxFit.contain)))),
                    store.currentUser == null
                        ? AutoSizeText('Who are you?',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w300))
                        : AutoSizeText(store.currentUser.displayName,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w300))
                  ]),
              Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: GoogleAuthButtonContainer()),
              store.currentUser != null
                  ? ListView.separated(
                      separatorBuilder:
                          (BuildContext serperatorContext, int index) =>
                              new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
                      padding: EdgeInsets.all(20.0),
                      itemCount: fields.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (BuildContext listContext, int index) {
                        return fields[index];
                      })
                  : Container(),
              store.currentUser != null
                  ? Container(
                      margin: EdgeInsets.only(top: 50),
                      alignment: Alignment.center,
                      child: RaisedButton(
                        onPressed: () async {
                          if (store.profileLoading == false) {
                            setState(() {
                              store.profileLoading = true;
                            });
                            final data = {
                              "notifications_on":
                                  store.currentUser.notificationOn,
                              "country": store.currentUser.country
                            };
                            print(data);
                            final response =
                                await updateUser(store.currentUser.uid, data);
                            print(response.success);
                            if (response.success == true) {
                              final SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear();
                              setState(() {
                                store.profileLoading = false;
                              });
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: AutoSizeText('Profile updated',
                                    style: TextStyle(fontSize: 18)),
                                duration: Duration(seconds: 2),
                              ));
                            }
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        color: color,
                        child: Container(
                          width: 100,
                          height: 40,
                          alignment: Alignment.center,
                          child: AutoSizeText(
                            'Save',
                            textAlign: TextAlign.center,
                            style: new TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w300,
                                color: fontContrast(color)),
                          ),
                        ),
                      ))
                  : Container(),
              Center(
                  child: Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: FlatButton(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        child: AutoSizeText(
                          "Privacy policy",
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (context) {
                                    return Container(
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                                //color: color,
                                                height: 80,
                                                child: TrotterAppBar(
                                                    title: 'Privacy policy',
                                                    back: true,
                                                    onPush: () {},
                                                    showSearch: false,
                                                    brightness:
                                                        Brightness.light,
                                                    color: Colors.white)),
                                            Flexible(
                                                child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              margin: EdgeInsets.only(top: 0),
                                              child: WebView(
                                                initialUrl:
                                                    'https://ajibade.me/privacy.html',
                                              ),
                                            ))
                                          ],
                                        ));
                                  }));
                        },
                      )))
            ])),
            store.profileLoading
                ? Align(
                    alignment: Alignment.center,
                    child: RefreshProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(color)),
                  )
                : Container()
          ],
        ));
  }
}
