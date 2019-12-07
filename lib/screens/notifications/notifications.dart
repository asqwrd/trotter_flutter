import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:sliding_panel/sliding_panel.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';
import 'package:trotter_flutter/widgets/trips/index.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../bottom_navigation.dart';

class Notifications extends StatefulWidget {
  final ValueChanged<dynamic> onPush;
  Notifications({Key key, this.onPush}) : super(key: key);
  @override
  NotificationsState createState() =>
      new NotificationsState(onPush: this.onPush);
}

class NotificationsState extends State<Notifications> {
  final ValueChanged<dynamic> onPush;
  bool errorUi = false;
  PanelController _pc = new PanelController();
  var kExpandedHeight = 280;
  TrotterStore store;
  var data;
  final Color color = Color.fromRGBO(29, 198, 144, 1);
  bool shadow = false;

  @override
  void initState() {
    super.initState();
    //fetchNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  NotificationsState({this.onPush});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    store = Provider.of<TrotterStore>(context);
    if (store.currentUser != null && data == null) {
      data = fetchNotifications(store);
    }

    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingPanel(
              snapPanel: true,
              initialState: InitialPanelState.expanded,
              isDraggable: false,
              size: PanelSize(expandedHeight: getPanelHeight(context)),
              autoSizing: PanelAutoSizing(),
              decoration: PanelDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              parallaxSlideAmount: .5,
              panelController: _pc,
              content: PanelContent(
                panelContent: (context, _sc) {
                  return Center(
                      child: Stack(children: <Widget>[
                    RenderWidget(
                        onScroll: onScroll,
                        scrollController: _sc,
                        builder: (context, scrollController, snapshot) =>
                            _buildContent(context, store, scrollController)),
                    store.notificationsLoading == true
                        ? Center(child: RefreshProgressIndicator())
                        : Container()
                  ]));
                },
                bodyContent: Container(color: color),
              ))),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
            onPush: onPush,
            color: color,
            showSearch: false,
            title: 'Notifications',
            actions: <Widget>[
              Container(
                  width: 58,
                  height: 58,
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    onPressed: () async {
                      store.setNotificationsLoading(true);
                      fetchNotifications(store);
                    },
                    child: SvgPicture.asset("images/refresh_icon.svg",
                        width: 24.0,
                        height: 24.0,
                        color: fontContrast(color),
                        fit: BoxFit.contain),
                  )),
              Container(
                  width: 65,
                  height: 65,
                  margin: EdgeInsets.symmetric(horizontal: 0),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    onPressed: () async {
                      //fetchNotifications(store);
                      final response = await showDialog(
                        context: context,
                        barrierDismissible: false, // user must tap button!
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            title: Text('Clear notifications?'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text(
                                      'This will mark all notifications as read.'),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                    width: 80,
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: this.color),
                                    )),
                                onPressed: () {
                                  Navigator.of(context).pop({"clear": false});
                                },
                              ),
                              FlatButton(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                color: this.color.withOpacity(1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                child: Container(
                                    width: 80,
                                    child: Text(
                                      'Clear',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300),
                                    )),
                                onPressed: () {
                                  Navigator.of(context).pop({"clear": true});
                                },
                              ),
                            ],
                          );
                        },
                      );
                      if (response['clear'] == true) {
                        store.setNotificationsLoading(true);
                        await clearNotifications(store);
                        fetchNotifications(store);
                        //store.setNotificationsLoading(false);
                      }
                    },
                    child: SvgPicture.asset("images/mark-all.svg",
                        width: 40.0,
                        height: 40.0,
                        color: fontContrast(color),
                        fit: BoxFit.contain),
                  ))
            ],
          )),
    ]);

    //return _buildContent(context, store);
  }

  void onScroll(offset) {
    if (offset > 0) {
      setState(() {
        this.shadow = true;
      });
    } else {
      setState(() {
        this.shadow = false;
      });
    }
  }

  Widget _buildContent(
      BuildContext context, TrotterStore store, ScrollController _sc) {
    var notifications = store.notifications.notifications;
    if (notifications.length == 0) {
      return Center(
          child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: ListView(
                shrinkWrap: true,
                controller: _sc,
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2,
                      foregroundDecoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(1),
                              Colors.white.withOpacity(1),
                            ],
                            center: Alignment.center,
                            focal: Alignment.center,
                            radius: 1.02,
                          ),
                          borderRadius: BorderRadius.circular(130)),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage('images/notification-empty.jpg'),
                              fit: BoxFit.contain),
                          borderRadius: BorderRadius.circular(130))),
                  AutoSizeText(
                    'All caught up!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        color: color,
                        fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 10),
                  AutoSizeText(
                    'Check back later',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        color: color,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              )));
    }
    return Container(
        child: ListView.separated(
            controller: _sc,
            separatorBuilder: (BuildContext context, int index) =>
                new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
            itemCount: notifications.length,
            itemBuilder: (BuildContext listcontext, int index) {
              final data = notifications[index]['data'];
              final createdAt = notifications[index]['created_at'];
              final type = notifications[index]['type'];
              final status = data['status'];
              final id = notifications[index]['id'];
              return ListTile(
                leading: icon(type, data['user']),
                title: AutoSizeText(data['subject']),
                subtitle: AutoSizeText(timeago
                    .format(DateTime.fromMillisecondsSinceEpoch(createdAt))),
                trailing: IconButton(
                  icon: Icon(Icons.more_horiz),
                  onPressed: () {
                    //print("object");
                    bottomSheetModal(context, data, type, status, id);
                  },
                ),
              );
            }));
  }

  bottomSheetModal(BuildContext context, dynamic data, String type,
      String status, String notificationId) {
    store = Provider.of<TrotterStore>(context);
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext listcontext) {
          return new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            new ListTile(
                leading: new Icon(EvilIcons.check),
                title: new AutoSizeText('Mark as read'),
                onTap: () async {
                  print(notificationId);
                  await markNotificationRead(notificationId, store);
                  Navigator.pop(context);
                }),
            type == 'email' && status == 'Processed'
                ? new ListTile(
                    leading: new Icon(EvilIcons.plus),
                    title: new AutoSizeText('Add to trip'),
                    onTap: () async {
                      Navigator.pop(context);
                      showTripsBottomSheet(context, null, data, notificationId);
                    })
                : Container(),
            type == 'user_trip'
                ? new ListTile(
                    leading: new Icon(EvilIcons.arrow_right),
                    title: new AutoSizeText('Go to trip'),
                    onTap: () async {
                      var results = FocusChangeEvent(
                          tab: TabItem.trips, data: data['navigationData']);
                      store.eventBus.fire(results);
                      await markNotificationRead(notificationId, store);
                      Navigator.pop(context);
                    })
                : Container(),
            type == 'user_comment'
                ? new ListTile(
                    leading: new Icon(EvilIcons.arrow_right),
                    title: new AutoSizeText('Go to comments'),
                    onTap: () async {
                      var results = FocusChangeEvent(
                          tab: TabItem.trips, data: data['navigationData']);
                      store.eventBus.fire(results);
                      await markNotificationRead(notificationId, store);
                      Navigator.pop(context);
                    })
                : Container(),
            type == 'user_day'
                ? new ListTile(
                    leading: new Icon(EvilIcons.arrow_right),
                    title: new AutoSizeText('Go to day'),
                    onTap: () async {
                      var results = FocusChangeEvent(
                          tab: TabItem.trips, data: data['navigationData']);
                      store.eventBus.fire(results);
                      await markNotificationRead(notificationId, store);
                      Navigator.pop(context);
                    })
                : Container(),
            type == 'user_travel_details_add' ||
                    type == 'user_travel_details_remove'
                ? new ListTile(
                    leading: new Icon(EvilIcons.arrow_right),
                    title: new AutoSizeText('Go to travel logistics'),
                    onTap: () async {
                      data['navigationData']['currentUserId'] =
                          store.currentUser.uid;
                      var results = FocusChangeEvent(
                          tab: TabItem.trips, data: data['navigationData']);
                      store.eventBus.fire(results);
                      await markNotificationRead(notificationId, store);
                      Navigator.pop(context);
                    })
                : Container(),
          ]);
        });
  }

  static icon(String type, [dynamic user]) {
    switch (type) {
      case 'email':
        return Icon(EvilIcons.envelope);
      case 'user':
      case 'user_travel_details_remove':
      case 'user_travel_details_add':
      case 'user_trip':
      case 'user_trip_remove':
      case 'user_day':
      case 'user_comment':
      case 'user_trip_updated':
      case 'user_trip_added':
        return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(width: 2, color: Colors.blueGrey)),
            child: CircleAvatar(
                backgroundImage: AdvancedNetworkImage(
              user['photoUrl'],
              useDiskCache: true,
              cacheRule: CacheRule(maxAge: const Duration(days: 7)),
            )));
    }

    return null;
  }
}
