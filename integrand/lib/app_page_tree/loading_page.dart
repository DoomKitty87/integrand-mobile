import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingSchedule extends StatefulWidget {
  const LoadingSchedule({super.key});

  @override
  State<LoadingSchedule> createState() => _LoadingScheduleState();
}

class _LoadingScheduleState extends State<LoadingSchedule> {
  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 35.0,
            ),
            const SizedBox(
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
            const SizedBox(
              height: 30.0,
            ),
            const SizedBox(
              height: 60.0,
              child: GreyRoundedContainer(
                padding: 10.0,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            const SizedBox(
              height: 250.0,
              child: GreyRoundedContainer(
                padding: 10.0,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 250.0,
              child: GreyRoundedContainer(
                padding: 10.0,
              ),
            ),
          ].animate(
            onPlay: (controller) => controller.repeat(reverse: true),
            interval: Durations.short2,
            effects: [
              const ColorEffect(
                blendMode: ShimmerEffect.defaultBlendMode,
                duration: Durations.long4,
                begin: background1,
                end: background2,
                curve: Curves.ease,
              ),
            ]
          ),
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
          color: background1,
          borderRadius: BorderRadius.circular(10)
        ),
      ),
    );
  }
}
