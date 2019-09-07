import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:trotter_flutter/store/auth.dart';
import 'package:trotter_flutter/utils/index.dart';

class MessageNotification extends StatelessWidget {
  final VoidCallback onDismiss;
  final TrotterUser from;
  final String message;
  final String type;

  const MessageNotification(
      {Key key, this.onDismiss, this.from, this.message, this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ListTile(
        contentPadding:
            EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 5),
        leading: icon(this.type, this.from),
        title: AutoSizeText(this.message),
        trailing: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              OverlaySupportEntry.of(context).dismiss();
            }),
      ),
    );
  }

  static icon(String type, [TrotterUser user]) {
    switch (type) {
      case 'email':
        return Icon(EvilIcons.envelope);
      case 'trotter':
        return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(width: 2, color: Colors.blueGrey)),
            child: CircleAvatar(
              backgroundImage: AssetImage('images/logo.png'),
            ));
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
              user.photoUrl,
              useDiskCache: true,
              cacheRule: CacheRule(maxAge: const Duration(days: 7)),
            )));
    }

    return null;
  }
}
