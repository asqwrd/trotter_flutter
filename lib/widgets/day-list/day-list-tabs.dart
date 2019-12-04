import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:intl/intl.dart';

class DayListTabs extends StatefulWidget {
  final List<dynamic> days;
  final void Function(dynamic, int) onSelected;
  final int startDate;
  final String activeDay;
  final Color activeColor;
  DayListTabs(
      {this.days,
      this.startDate,
      this.activeDay,
      this.activeColor,
      this.onSelected});

  @override
  DayListTabsState createState() => DayListTabsState(
      days: this.days,
      startDate: this.startDate,
      activeDay: this.activeDay,
      onSelected: this.onSelected,
      activeColor: this.activeColor);
}

class DayListTabsState extends State<DayListTabs> {
  final List<dynamic> days;
  final void Function(dynamic, int) onSelected;
  final int startDate;
  ItemScrollController indexController = ItemScrollController();
  final formatter = DateFormat.yMMMEd("en_US");
  final String activeDay;
  int initialIndex = 0;
  final Color activeColor;

  @override
  void initState() {
    initialIndex = this.days.indexWhere((item) => item['id'] == this.activeDay);
    super.initState();
  }

  DayListTabsState(
      {this.days,
      this.startDate,
      this.activeDay,
      this.activeColor,
      this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
        //width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 0),
        height: 80,
        child: ScrollablePositionedList.builder(
          itemCount: this.days.length,
          itemScrollController: indexController,
          initialScrollIndex: initialIndex,
          scrollDirection: Axis.horizontal,
          itemBuilder: (itemContext, index) {
            return InkWell(
                onTap: () {
                  if (this.days[index]['id'] != this.activeDay)
                    this.onSelected(this.days[index], index);
                },
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    alignment: Alignment.center,
                    child: Column(mainAxisSize: MainAxisSize.min, children: <
                        Widget>[
                      AutoSizeText(
                        'Day ${index + 1}',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: activeColor != null && index == initialIndex
                                ? activeColor
                                : index == initialIndex
                                    ? Colors.blueGrey
                                    : Colors.black),
                      ),
                      this.startDate != null && this.startDate > 0
                          ? Container(
                              margin: EdgeInsets.only(top: 5),
                              child: AutoSizeText(
                                formatter.format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                            this.startDate,
                                            isUtc: true)
                                        .add(Duration(
                                            days: this.days[index]['day']))),
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: activeColor != null &&
                                            index == initialIndex
                                        ? activeColor
                                        : index == initialIndex
                                            ? Colors.blueGrey
                                            : Colors.black.withOpacity(0.5)),
                              ))
                          : Container(),
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color:
                                  activeColor != null && index == initialIndex
                                      ? activeColor
                                      : index == initialIndex
                                          ? Colors.blueGrey
                                          : Colors.transparent))
                    ])));
          },
        ));
  }
}
