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
    return const GradientBackground(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 35.0,
            ),
            SizedBox(
              height: 95.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GreyRoundedContainer(
                      padding: 10.0,
                    ),
                  ),
                  Expanded(
                    child: GreyRoundedContainer(
                      padding: 10.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            SizedBox(
              height: 60.0,
              child: GreyRoundedContainer(
                padding: 10.0,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 250.0,
              child: GreyRoundedContainer(
                padding: 10.0,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 250.0,
              child: GreyRoundedContainer(
                padding: 10.0,
              ),
            ),
          ]
        ),
      ),
    );
  }
}

class GreyRoundedContainer extends StatelessWidget {
  const GreyRoundedContainer({super.key, required this.padding});

  final double padding;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        decoration: BoxDecoration(
          color: lightGrey,
          borderRadius: BorderRadius.circular(10)
        ),
      ),
    );
  }
}
