import 'package:flutter/material.dart';
import 'package:integrand/backend/studentvue_api.dart';
import 'package:integrand/consts.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Center(
              child: MonthDisplay()
            ),
          ]
        ),
      ]
    );
  }
}

class MonthDisplay extends StatelessWidget {
  const MonthDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime currentTime = DateTime.now();
    String month = month;
    String year = year;

    return Text(
      month + ' ' + year,
      style: boldBodyStyle,
    );
  }
}
