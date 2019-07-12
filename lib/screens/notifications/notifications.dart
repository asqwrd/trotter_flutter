import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trotter_flutter/widgets/app_bar/app_bar.dart';

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
    final Color color = Color.fromRGBO(29, 198, 144, 1);
    double _panelHeightOpen = MediaQuery.of(context).size.height - 130;
    store = Provider.of<TrotterStore>(context);
    if (store.currentUser != null && data == null) {
      data = fetchNotifications(store);
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
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        maxHeight: _panelHeightOpen,
        panel: Center(child: _buildContent(context, store)),
        body: Container(color: color),
      )),
      Positioned(
          top: 0,
          width: MediaQuery.of(context).size.width,
          child: new TrotterAppBar(
              onPush: onPush, color: color, title: 'Notifications')),
    ]);

    //return _buildContent(context, store);
  }

  Widget _buildContent(BuildContext context, TrotterStore store) {
    var notifications = store.notifications.notifications;
    return Container(
        child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                new Divider(color: Color.fromRGBO(0, 0, 0, 0.3)),
            itemCount: notifications.length,
            itemBuilder: (BuildContext context, int index) {
              final data = notifications[index]['data'];
              return ListTile(
                title: Text(data['subject']),
                trailing: Icon(Icons.more_vert),
              );
            }));
  }
}
