import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:trotter_flutter/store/middleware.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
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
  final ScrollController _sc = ScrollController();
  PanelController _pc = new PanelController();
  var kExpandedHeight = 280;
  TrotterStore store;
  var data;
  final Color color = Color.fromRGBO(29, 198, 144, 1);

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  NotificationsState({this.onPush});

  @override
  Widget build(BuildContext context) {
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    store = Provider.of<TrotterStore>(context);
    if (store.currentUser != null && data == null) {
      data = fetchNotifications(store);
      // store.eventBus.on<FocusChangeEvent>().listen((event) {
      //   // All events are of type UserLoggedInEvent (or subtypes of it).
      //   if (event.tab == TabItem.notifications) {
      //     onPush({'level': 'createtrip'});
      //   }
      // });
    }

    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Positioned(
          child: SlidingUpPanel(
        parallaxEnabled: true,
        parallaxOffset: .5,
        minHeight: _panelHeightOpen,
        controller: _pc,
        backdropEnabled: true,
        backdropColor: color,
        isDraggable: false,
        backdropTapClosesPanel: false,
        backdropOpacity: .8,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        maxHeight: _panelHeightOpen,
        panel: Center(
            child: Stack(children: <Widget>[
          _buildContent(context, store),
          store.notificationsLoading == true
              ? Center(child: RefreshProgressIndicator())
              : Container()
        ])),
        body: Container(color: color),
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
            onPush: onPush,
            color: color,
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
                        color: Colors.white,
                        fit: BoxFit.contain),
                  ))
            ],
          )),
    ]);

    //return _buildContent(context, store);
  }

  Widget _buildContent(BuildContext context, TrotterStore store) {
    var notifications = store.notifications.notifications;
    if (notifications.length == 0) {
      return Center(
          child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
            separatorBuilder: (BuildContext context, int index) =>
                new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
            itemCount: notifications.length,
            itemBuilder: (BuildContext listcontext, int index) {
              final data = notifications[index]['data'];
              final createdAt = notifications[index]['created_at'];
              final type = notifications[index]['type'];
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
                    bottomSheetModal(context, data, type, id);
                  },
                ),
              );
            }));
  }

  bottomSheetModal(
      BuildContext context, dynamic data, String type, String notificationId) {
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
            type == 'email'
                ? new ListTile(
                    leading: new Icon(EvilIcons.plus),
                    title: new AutoSizeText('Add to Trip'),
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
                    })
                : Container(),
            type == 'user_travel_details_add'
                ? new ListTile(
                    leading: new Icon(EvilIcons.arrow_right),
                    title: new AutoSizeText('Go to travel details'),
                    onTap: () async {
                      var results = FocusChangeEvent(
                          tab: TabItem.trips, data: data['navigationData']);
                      store.eventBus.fire(results);
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
