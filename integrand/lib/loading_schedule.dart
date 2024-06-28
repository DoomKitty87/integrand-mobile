import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';

class LoadingSchedule extends StatefulWidget {
  const LoadingSchedule({super.key});

  @override
  State<LoadingSchedule> createState() => _LoadingScheduleState();
}

class _LoadingScheduleState extends State<LoadingSchedule> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 5.0,
                top: 50.0,
                bottom: 20
              ),
                child: Container(
                  color: darkGrey,
                ),
              )
            ),
            Expanded(
              child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 5.0,
                top: 50.0,
                bottom: 20
              ),
                child: Container(
                  color: darkGrey,
                ),
              )
            ),
          ],
        ),
        
      ],
    );
  }
}