import 'package:flutter/material.dart';
import 'package:flutter_store/flutter_store.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:trotter_flutter/store/store.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:badges/badges.dart';

enum TabItem { explore, trips, notifications, profile }

class TabHelper {
  static TabItem item({int index}) {
    switch (index) {
      case 0:
        return TabItem.explore;
      case 1:
        return TabItem.trips;
      case 2:
        return TabItem.notifications;
      case 3:
        return TabItem.profile;
    }
    return TabItem.explore;
  }

  static tabIndex(TabItem item) {
    switch (item) {
      case TabItem.explore:
        return 0;
      case TabItem.trips:
        return 1;
      case TabItem.notifications:
        return 2;
      case TabItem.profile:
        return 3;
    }
    return 0;
  }

  static String description(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.explore:
        return 'Explore';
      case TabItem.trips:
        return 'Trips';
      case TabItem.notifications:
        return 'Notifications';
      case TabItem.profile:
        return 'Profile';
    }
    return '';
  }

  static String icon(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.explore:
        return 'images/explore-icon.svg';
      case TabItem.trips:
        return 'images/trips-icon.svg';
      case TabItem.notifications:
        return 'images/notification.svg';
      case TabItem.profile:
        return 'images/avatar-icon.svg';
    }

    return '';
  }

  static Color color(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.explore:
        return Color.fromRGBO(216, 167, 177, 1);
      case TabItem.trips:
        return Color.fromRGBO(234, 189, 149, 1);
      //return Color.fromRGBO(1, 155, 174, 1);
      case TabItem.notifications:
        return Color.fromRGBO(29, 198, 144, 1);
      case TabItem.profile:
        return Color.fromRGBO(1, 155, 174, 1);
    }
    return Colors.black;
  }
}

class BottomNavigation extends StatelessWidget {
  BottomNavigation({this.currentTab, this.onSelectTab});
  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return new Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: Colors.white,
        ), // sets the inactive color of the `BottomNavigationBar`
        child: BubbleBottomBar(
            opacity: .2,
            elevation: 15,
            currentIndex: TabHelper.tabIndex(currentTab),
            items: [
              _buildItem(context: context, tabItem: TabItem.explore),
              _buildItem(context: context, tabItem: TabItem.trips),
              _buildItem(context: context, tabItem: TabItem.notifications),
              _buildItem(context: context, tabItem: TabItem.profile),
            ],
            onTap: (index) {
              onSelectTab(
                TabHelper.item(index: index),
              );
            }));
  }

  BubbleBottomBarItem _buildItem({BuildContext context, TabItem tabItem}) {
    String text = TabHelper.description(tabItem);
    //SvgPicture icon = TabHelper.icon(tabItem);
    final store = Provider.of<TrotterStore>(context);
    if (tabItem == TabItem.notifications) {
      return BubbleBottomBarItem(
        icon: Badge(
            toAnimate: false,
            badgeContent: Text(
              '${store.notifications.notifications.length}',
              style: TextStyle(color: Colors.white),
            ),
            child: _icon(context, item: tabItem)),
        activeIcon: Badge(
            toAnimate: false,
            showBadge: store.notifications != null &&
                store.notifications.notifications.length > 0,
            badgeContent: Text(
              '${store.notifications.notifications.length}',
              style: TextStyle(color: Colors.white),
            ),
            child: _icon(context, item: tabItem)),
        backgroundColor: _colorTabMatching(item: tabItem),
        title: Container(
            margin: EdgeInsets.only(right: 30),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
              ),
            )),
      );
    }
    return BubbleBottomBarItem(
      icon: _icon(context, item: tabItem),
      activeIcon: _icon(context, item: tabItem),
      backgroundColor: _colorTabMatching(item: tabItem),
      title: Container(
          margin: EdgeInsets.only(right: 30),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
            ),
          )),
    );
  }

  Color _colorTabMatching({TabItem item}) {
    return currentTab == item ? TabHelper.color(item) : Colors.grey;
  }

  _icon(BuildContext context, {TabItem item}) {
    final store = Provider.of<TrotterStore>(context);

    return Align(
        alignment: Alignment.centerLeft,
        child: item == TabItem.profile && store.currentUser != null
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                        style: BorderStyle.solid,
                        color: _colorTabMatching(item: item),
                        width: 2)),
                child: ClipPath(
                    clipper: CornerRadiusClipper(100),
                    child: Image.network(store.currentUser.photoUrl,
                        width: 30.0, height: 30.0, fit: BoxFit.contain)))
            : SvgPicture.asset(
                TabHelper.icon(item),
                color:
                    currentTab == item ? TabHelper.color(item) : Colors.black,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ));
  }
}
