import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:redux/redux.dart';
import 'package:trotter_flutter/utils/index.dart';
import 'package:trotter_flutter/redux/index.dart';


enum TabItem { explore, trips, profile }

class TabHelper {
  static TabItem item({int index}) {
    switch (index) {
      case 0:
        return TabItem.explore;
      case 1:
        return TabItem.trips;
      case 2:
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
      case TabItem.profile:
        return 2;
    }
    return 0;
  }

  static String description(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.explore:
        return 'Explore';
      case TabItem.trips:
        return 'Trips';
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
      case TabItem.profile:
        return 'images/avatar-icon.svg';
    }

    return '';
  }

  static Color color(TabItem tabItem) {
    switch (tabItem) {
      case TabItem.explore:
        return Color.fromRGBO(106,154,168,1);
      case TabItem.trips:
        return Color.fromRGBO(234, 189, 149,1);
        //return Color.fromRGBO(1, 155, 174, 1);
      case TabItem.profile:
        return Color.fromRGBO(1, 155, 174,1);
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
      child:BubbleBottomBar(
        opacity: .2,
        elevation: 15,
        currentIndex: TabHelper.tabIndex(currentTab),
        items: [
          _buildItem(context: context,tabItem: TabItem.explore),
          _buildItem(context: context, tabItem: TabItem.trips),
          _buildItem(context: context, tabItem: TabItem.profile),
        ],
        onTap: (index){
          onSelectTab(
            TabHelper.item(index: index),
          );
        }
      )
    );
  }

  BubbleBottomBarItem _buildItem({BuildContext context, TabItem tabItem}) {

    String text = TabHelper.description(tabItem);
    //SvgPicture icon = TabHelper.icon(tabItem);
    return BubbleBottomBarItem(
      icon: _icon(context, item: tabItem),
      activeIcon: _icon(context, item: tabItem),
      backgroundColor: _colorTabMatching(item: tabItem),
      title: Container(
        margin:EdgeInsets.only(right:30),
        child:Text(
        text,
        style: TextStyle(
          fontSize: 20 
        ),
      
      )),
    );
  }

  Color _colorTabMatching({TabItem item}) {
    return currentTab == item ? TabHelper.color(item) : Colors.grey;
  }

  _icon(BuildContext context, {TabItem item}) {
    var store = StoreProvider.of<AppState>(context).state;
    return Align(
      alignment: Alignment.centerLeft,
      child: item == TabItem.profile && store.currentUser != null ? ClipPath(
        clipper: CornerRadiusClipper(100),
        child:Image.network(
          store.currentUser.photoUrl,
          width: 30.0,
          height: 30.0,
          fit:BoxFit.contain
        )
      ) : SvgPicture.asset(
          TabHelper.icon(item), 
          color: currentTab == item ? TabHelper.color(item) : Colors.black, 
          width: 30, 
          height: 30, 
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        )
      );
  }
}