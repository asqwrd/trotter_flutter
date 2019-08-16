import 'package:trotter_flutter/store/store.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trotter_flutter/globals.dart';

class NotificationsData {
  final List<dynamic> notifications;
  final bool success;

  NotificationsData({this.notifications, this.success});

  factory NotificationsData.fromJson(Map<String, dynamic> json) {
    return NotificationsData(
        notifications: json['notifications'], success: true);
  }
}

class PlacesData {
  final dynamic places;
  final bool more;
  final bool success;

  PlacesData({this.places, this.success, this.more});

  factory PlacesData.fromJson(Map<String, dynamic> json) {
    return PlacesData(
        places: json['places'], success: true, more: json['more']);
  }
}

Future<PlacesData> fetchMorePlaces(
    String id, String placeType, int offset) async {
  try {
    print(id);
    final response = await http.get(
        '$ApiDomain/api/explore/places?levelId=$id&type=$placeType&offset=$offset',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return PlacesData.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      print(msg);
      return PlacesData(success: false);
    }
  } catch (error) {
    return PlacesData(success: false);
  }
}

Future<NotificationsData> fetchNotifications([TrotterStore store]) async {
  try {
    final response = await http.get(
        '$ApiDomain/api/notifications?user_id=${store.currentUser.uid}',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = NotificationsData.fromJson(json.decode(response.body));
      store?.setNotificationsError(false);
      store?.setOffline(false);
      store?.setNotifications(results.notifications);
      store?.setNotificationsLoading(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      return NotificationsData(success: false);
    }
  } catch (error) {
    store?.setNotificationsError(true);
    store?.setNotificationsLoading(false);
    return NotificationsData(success: false);
  }
}

Future<NotificationsData> markNotificationRead(String notificationId,
    [TrotterStore store]) async {
  try {
    final response = await http.put(
        '$ApiDomain/api/notifications/$notificationId?user_id=${store.currentUser.uid}',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = NotificationsData.fromJson(json.decode(response.body));
      store?.setNotificationsError(false);
      store?.setOffline(false);
      store?.setNotifications(results.notifications);
      store?.setNotificationsLoading(false);
      return results;
    } else {
      // If that response was not OK, throw an error.
      return NotificationsData(success: false);
    }
  } catch (error) {
    store?.setNotificationsError(true);
    store?.setNotificationsLoading(false);
    return NotificationsData(success: false);
  }
}
