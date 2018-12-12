
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


enum TabItem { explore, trips, search, profile }

class TabHelper {
  static TabItem item({int index}) {
    switch (index) {
      case 0:
        return TabItem.explore;
      case 1:
        return TabItem.trips;
      case 2:
        return TabItem.search;
      case 3:
        return TabItem.profile;
    }
    return TabItem.explore;
  }

  static String description(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.explore:
        return 'Explore';
      case TabItem.trips:
        return 'Trips';
      case TabItem.search:
        return 'Search';
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
      case TabItem.search:
        return 'images/search-icon.svg';
      case TabItem.profile:
        return 'images/avatar-icon.svg';
    }

    return '';
    //return SvgPicture.asset('images/explore-icon.svg', color: Colors.black, width: 30, height: 30, fit: BoxFit.contain);
  }

  static MaterialColor color(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.explore:
        return Colors.red;
      case TabItem.trips:
        return Colors.green;
      case TabItem.search:
        return Colors.blue;
      case TabItem.profile:
        return Colors.blue;
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
    child:BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildItem(tabItem: TabItem.explore),
        _buildItem(tabItem: TabItem.trips),
        _buildItem(tabItem: TabItem.search),
        _buildItem(tabItem: TabItem.profile),
      ],
      onTap: (index) => onSelectTab(
        TabHelper.item(index: index),
      ),
    ));
  }

  BottomNavigationBarItem _buildItem({TabItem tabItem}) {

    String text = TabHelper.description(tabItem);
    //SvgPicture icon = TabHelper.icon(tabItem);
    return BottomNavigationBarItem(
      icon: _icon(item: tabItem),
      title: Text(
        text,
        style: TextStyle(
          color: _colorTabMatching(item: tabItem),
        ),
      ),
    );
  }

  Color _colorTabMatching({TabItem item}) {
    return currentTab == item ? TabHelper.color(item) : Colors.grey;
  }

  SvgPicture _icon({TabItem item}) {
    return SvgPicture.asset(TabHelper.icon(item), color: currentTab == item ? TabHelper.color(item) : Colors.black, width: 30, height: 30, fit: BoxFit.contain);
  }
}