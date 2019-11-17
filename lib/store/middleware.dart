import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as LocationPermission;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trotter_flutter/globals.dart';

import '../bottom_navigation.dart';

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

class ThingsToDoData {
  final List<dynamic> destinations;
  final bool success;

  ThingsToDoData({this.destinations, this.success});

  factory ThingsToDoData.fromJson(Map<String, dynamic> json) {
    return ThingsToDoData(destinations: json['destinations'], success: true);
  }
}

class NearByData {
  final List<dynamic> places;
  final bool success;
  final bool denied;

  NearByData({this.places, this.success, this.denied});

  factory NearByData.fromJson(Map<String, dynamic> json) {
    return NearByData(places: json['places'], success: true, denied: false);
  }
}

Future<ThingsToDoData> fetchThingsToDo(String userId,
    [bool refresh = false]) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String cacheData = prefs.getString('thingsToDo') ?? null;
  final int cacheDataExpire = prefs.getInt('thingsToDo-expiration') ?? null;
  final currentTime = DateTime.now().millisecondsSinceEpoch;
  if (cacheData != null &&
      cacheDataExpire != null &&
      refresh != true &&
      (currentTime < cacheDataExpire)) {
    var doData = json.decode(cacheData);

    return ThingsToDoData.fromJson(doData);
  } else {
    try {
      final response = await http.get(
          '$ApiDomain/api/explore/do?user_id=$userId',
          headers: {'Authorization': 'security'});
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        await prefs.setString('thingsToDo', response.body);
        await prefs.setInt('thingsToDo-expiration',
            DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch);
        var data = json.decode(response.body);
        return ThingsToDoData.fromJson(data);
      } else {
        // If that response was not OK, throw an error.
        var msg = response.statusCode;
        print(msg);
        return ThingsToDoData(success: false);
      }
    } catch (error) {
      print('Response> $error');
      return ThingsToDoData(success: false);
    }
  }
}

Future<bool> getLocationPermission() async {
  var location = LocationPermission.Location();

// Platform messages may fail, so we use a try/catch PlatformException.
  try {
    var permission = await location.hasPermission();
    if (permission == false) {
      await location.requestPermission();
    }
    return true;
  } catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      var error = 'Permission denied';
      print(error);
    }
    return false;
  }
}

Future<NearByData> fetchNearbyPlaces(String type, String keywords) async {
  final PermissionStatus isLocationEnabled =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.location);
  Position position;
  print(isLocationEnabled);
  if (isLocationEnabled == PermissionStatus.granted) {
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  } else {
    try {
      var getPerm = await getLocationPermission();
      if (getPerm == true) {
        position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      } else {
        return NearByData(denied: true);
      }
    } catch (e) {
      return NearByData(denied: true);
    }
  }
  print(ApiDomain);
  try {
    final response = await http.get(
        '$ApiDomain/api/explore/nearby?type=$type&lat=${position.latitude}&lng=${position.longitude}&keywords=$keywords',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var data = json.decode(response.body);
      return NearByData.fromJson(data);
    } else {
      // If that response was not OK, throw an error.
      var msg = response.statusCode;
      print(msg);
      return NearByData(success: false);
    }
  } catch (error) {
    print('Response> $error');
    return NearByData(success: false);
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

Future<NotificationsData> clearNotifications([TrotterStore store]) async {
  try {
    final response = await http.post(
        '$ApiDomain/api/notifications/clear?user_id=${store.currentUser.uid}',
        headers: {'Authorization': 'security'});
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var results = NotificationsData.fromJson(json.decode(response.body));
      store?.setNotificationsError(false);
      store?.setOffline(false);
      store?.setNotifications(results.notifications);
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

class FocusChangeEvent {
  dynamic data;
  TabItem tab;

  FocusChangeEvent({this.data, this.tab});

  factory FocusChangeEvent.fromJson(Map<dynamic, dynamic> json) {
    return FocusChangeEvent(data: json, tab: null);
  }
}

class RefreshHomeEvent {
  bool refresh;

  RefreshHomeEvent({this.refresh});
}
