import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:integrand/backend/data_classes.dart';
import 'package:integrand/backend/database_interactions.dart';
import 'package:integrand/widget_templates.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime selectedTime = DateTime.now();
  int filter = -1;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchEvents(4),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Event> events = snapshot.data as List<Event>;
          return Column(children: [
            Row(children: [
              Expanded(
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: textWhite,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      if (selectedTime.month == 1) {
                        selectedTime = DateTime(
                            selectedTime.year - 1, 12, selectedTime.day);
                      } else {
                        selectedTime = DateTime(selectedTime.year,
                            selectedTime.month - 1, selectedTime.day);
                      }
                    });
                  },
                ),
              ),
              Expanded(
                  child:
                      Center(child: MonthDisplay(currentTime: selectedTime))),
              Expanded(
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward,
                      color: textWhite, size: 20),
                  onPressed: () {
                    setState(() {
                      if (selectedTime.month == 12) {
                        selectedTime = DateTime(
                            selectedTime.year + 1, 1, selectedTime.day);
                      } else {
                        selectedTime = DateTime(selectedTime.year,
                            selectedTime.month + 1, selectedTime.day);
                      }
                    });
                  },
                ),
              ),
            ]),
            SizedBox(
              height: 291,
              child: CalendarGrid(
                  events: events,
                  filter: filter,
                  selectDayCallback: (day) {
                    setState(() {
                      selectedTime = DateTime(
                          selectedTime.year,
                          selectedTime.month,
                          day,
                          selectedTime.hour,
                          selectedTime.minute);
                    });
                  },
                  currentTime: selectedTime),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              FilterBar(
                filter: filter,
                filterCallback: (int newFilter) {
                  setState(() {
                    if (filter == newFilter) {
                      filter = -1;
                    } else {
                      filter = newFilter;
                    }
                  });
                },
              ),
            ]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
                child: DayEventsList(
                    events: eventsThisMonth(events, selectedTime),
                    currentTime: selectedTime,
                    filter: filter),
              ),
            ),
          ]);
        } else if (snapshot.hasError) {
          return const Center(
            child: Text("Error loading events"),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

List<Event> eventsThisMonth(List<Event> events, DateTime currentTime) {
  return events.where((event) {
    return event.startTime.month == currentTime.month &&
        event.startTime.year == currentTime.year;
  }).toList();
}

class FilterBar extends StatelessWidget {
  const FilterBar(
      {super.key, required this.filter, required this.filterCallback});

  final int filter;
  final Function(int) filterCallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
      child: Row(
        children: List.generate(eventTypeNames.length, (index) {
          return GestureDetector(
            onTap: () {
              filterCallback(index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: filter == index ? null : background1,
                gradient: filter == index ? textGradient : null,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                    color:
                        filter == index ? Colors.transparent : background2,
                    width: 1),
              ),
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: eventTypeColors[index],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    eventTypeNames[index],
                    style: labelStyle,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class MonthDisplay extends StatelessWidget {
  const MonthDisplay({super.key, required this.currentTime});

  final DateTime currentTime;

  @override
  Widget build(BuildContext context) {
    String month = months[currentTime.month - 1];
    String year = currentTime.year.toString();

    return Text(
      month + ' ' + year,
      style: bodyStyleBold,
    );
  }
}

class CalendarGrid extends StatelessWidget {
  const CalendarGrid(
      {super.key,
      required this.events,
      required this.selectDayCallback,
      required this.currentTime,
      required this.filter});

  final List<Event> events;
  final Function(int) selectDayCallback;
  final DateTime currentTime;
  final int filter;

  @override
  Widget build(BuildContext context) {
    int month = currentTime.month;
    int year = currentTime.year;
    int day = currentTime.day;
    int daysInMonth = DateUtils.getDaysInMonth(year, month);
    int offset = DateTime(year, month, 1).weekday % 7;

    List<Event> eventsThisMonth = events.where((event) {
      return (event.startTime.month == month && event.startTime.year == year);
    }).toList();

    if (filter != -1) {
      eventsThisMonth = eventsThisMonth.where((event) {
        return event.type == filter;
      }).toList();
    }

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
                style: labelStyleSubdued,
              ),
            ),
          ),
        );
      }),
    );

    int trueCurrentDay = -1;
    if (DateTime.now().month == month + 1 && DateTime.now().year == year) {
      trueCurrentDay = DateTime.now().day;
    }

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
                  style: labelStyleSubdued,
                ),
              ),
            ),
          ));
        } else {
          dayWidgets.add(Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  selectDayCallback(dayNumber);
                },
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: dayNumber == day ? textGradient : null,
                      border: Border.all(
                          color: dayNumber == trueCurrentDay
                              ? background2
                              : Colors.transparent),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        Text(
                          dayNumber.toString(),
                          style: labelStyle,
                        ),
                        DayEvents(
                          events: eventsThisMonth
                              .where(
                                  (event) => event.startTime.day == dayNumber)
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
        }
      }

      weekRows.add(Row(children: dayWidgets));
      weekRows.add(const SizedBox(
        height: 5,
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
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
  const DayEvents({super.key, required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = [];
    // Sort events by type
    events.sort((a, b) {
      return a.type.compareTo(b.type);
    });
    if (events.length <= 3) {
      for (int i = 0; i < events.length; i++) {
        icons.add(Padding(
          padding: const EdgeInsets.only(top: 2, right: 1, left: 1),
          child: Icon(eventTypeIcons[events[i].type],
              size: 5, color: eventTypeColors[events[i].type]),
        ));
      }
    } else {
      for (int i = 0; i < 3; i++) {
        icons.add(Padding(
          padding: const EdgeInsets.only(top: 2, right: 1, left: 1),
          child: Icon(eventTypeIcons[events[i].type],
              size: 5, color: eventTypeColors[events[i].type]),
        ));
      }
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
    return ExpandableListItem(
      unexpandedHeight: 70,
      expandedHeight: 70,
      child: Row(children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: eventTypeColors[event.type],
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
          ),
          child: Center(
            child: Icon(
              eventTypeIcons[event.type],
              color: textWhite,
              size: 50,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(
                children: [
                  Text(event.title,
                      style: bodyStyle, textAlign: TextAlign.left),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.place, size: 16, color: textWhite),
                  const SizedBox(width: 5),
                  Text(event.location, style: labelStyle),
                ],
              )
            ]),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            textAlign: TextAlign.right,
            TimeOfDay.fromDateTime(event.startTime).format(context) +
                ' - ' +
                TimeOfDay.fromDateTime(event.endTime).format(context),
            style: labelStyle,
          ),
        ),
        const SizedBox(width: 10)
      ]),
    );
  }
}

class DayEventsList extends StatelessWidget {
  const DayEventsList(
      {super.key,
      required this.events,
      required this.currentTime,
      required this.filter});

  final List<Event> events;
  final DateTime currentTime;
  final int filter;

  @override
  Widget build(BuildContext context) {
    List<Event> eventsThisDay = events.where((event) {
      return event.startTime.day == currentTime.day;
    }).toList();

    if (filter != -1) {
      eventsThisDay = eventsThisDay.where((event) {
        return event.type == filter;
      }).toList();
    }

    eventsThisDay.sort((a, b) {
      return a.startTime.compareTo(b.startTime);
    });

    List<TimeOfDay> displayedTimes = [];

    List<Widget> eventCards = [];

    for (Event event in eventsThisDay) {
      if (!displayedTimes.contains(TimeOfDay.fromDateTime(event.startTime))) {
        displayedTimes.add(TimeOfDay.fromDateTime(event.startTime));
        eventCards.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              const SizedBox(width: 10),
              Text(
                TimeOfDay.fromDateTime(event.startTime).format(context),
                style: bodyStyleBold,
                textAlign: TextAlign.left,
              ),
            ]),
          ),
        );
      }
      eventCards.add(EventCard(event: event));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: eventCards.length,
      itemBuilder: (context, index) {
        return eventCards[index];
      },
    );
  }
}
