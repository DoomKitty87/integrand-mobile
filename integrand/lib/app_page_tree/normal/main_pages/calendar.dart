import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:integrand/backend/data_classes.dart';
import 'package:integrand/backend/database_interactions.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: Center(child: MonthDisplay())),
      ]),
      CalendarGrid(),
      Padding(
        padding: const EdgeInsets.all(30.0),
        child: EventCard(event: Event()),
      ),
    ]);
  }
}

class MonthDisplay extends StatelessWidget {
  const MonthDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    String month = months[currentTime.month - 1];
    String year = currentTime.year.toString();

    return Text(
      month + ' ' + year,
      style: boldBodyStyle,
    );
  }
}

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key});

  @override
  Widget build(BuildContext context) {
    int month = DateTime.now().month;
    int year = DateTime.now().year;
    int day = DateTime.now().day;
    int daysInMonth = DateUtils.getDaysInMonth(year, month);
    int offset = DateTime(year, month, 1).weekday % 7;

    if (month == 1) {
      year -= 1;
      month = 12;
    } else {
      month -= 1;
    }
    int daysInPrevMonth = DateUtils.getDaysInMonth(year, month);

    Widget dayLabelRow = Row(
      children: List.generate(7, (index) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                daysOfWeek[index],
                style: smallBodyStyleSubdued,
              ),
            ),
          ),
        );
      }),
    );

    List<Widget> weekRows = [];
    weekRows.add(const SizedBox(height: 14));

    int weeks = ((daysInMonth + offset) / 7).ceil();

    for (int i = 0; i < weeks; i++) {
      List<Widget> dayWidgets = [];

      for (int j = 0; j < 7; j++) {
        int dayNumber = i * 7 + j - offset + 1;

        if (dayNumber <= 0 || dayNumber > daysInMonth) {
          int trueDay = dayNumber;
          if (dayNumber <= 0) {
            trueDay = daysInPrevMonth + dayNumber;
          } else {
            trueDay = dayNumber - daysInMonth;
          }
          dayWidgets.add(Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  trueDay.toString(),
                  style: smallBodyStyleSubdued,
                ),
              ),
            ),
          ));
        } else {
          dayWidgets.add(Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: dayNumber == day ? textGradient : null,
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    Text(
                      dayNumber.toString(),
                      style: smallBodyStyle,
                    ),
                    DayEvents(
                      eventCount: 3,
                    ),
                  ],
                ),
              ),
            ),
          ));
        }
      }

      weekRows.add(Row(children: dayWidgets));
      weekRows.add(const SizedBox(height: 10));
    }

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          dayLabelRow,
          ...weekRows,
        ],
      ),
    );
  }
}

class DayEvents extends StatelessWidget {
  const DayEvents({super.key, required this.eventCount});

  final int eventCount;

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];
    if (eventCount <= 3) {
      for (int i = 0; i < eventCount; i++) {
        icons.add(Padding(
          padding: const EdgeInsets.only(top: 2, right: 1, left: 1),
          child: const Icon(Icons.circle, size: 5, color: textColor),
        ));
      }
    } else {
      icons.add(const Icon(Icons.circle, size: 5, color: textColor));
      icons.add(const Icon(Icons.circle, size: 5, color: textColor));
      icons.add(const Icon(Icons.add, size: 5, color: textColor));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: icons,
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: purpleGradient,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
          ),
          child: Center(
            child: Icon(
              Icons.food_bank,
              color: textColor,
              size: 50,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(children: [
              Row(
                children: [
                  Text("Title", style: bodyStyle, textAlign: TextAlign.left),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.place, size: 20, color: textColor),
                  SizedBox(width: 5),
                  Text("Location", style: bodyStyle),
                ],
              )
            ]),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            "Start time",
            style: bodyStyle,
          ),
        ),
        Container(
          width: 15,
          height: 70,
          decoration: BoxDecoration(
            color: lighterGrey,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                size: 4,
                color: textColor,
              ),
              Icon(
                Icons.circle,
                size: 4,
                color: textColor,
              ),
              Icon(
                Icons.circle,
                size: 4,
                color: textColor,
              ),
            ],
          ),
        )
      ]),
    );
  }
}
