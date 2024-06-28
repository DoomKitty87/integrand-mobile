import 'package:flutter/material.dart';
import 'package:integrand/backend/data_classes.dart';

const String appName = "Integrand";

const Color backgroundColor = Color.fromRGBO(13, 13, 13, 1); //HSVO(0, 0, 5, 1)
const Color backgroundColorSecondary = Color.fromRGBO(10, 1, 24, 1);
const Color textColor = Color.fromRGBO(224, 224, 224, 1);
const Color darkGrey = Color.fromRGBO(14, 14, 14, 1);
const Color lightGrey = Color.fromRGBO(26, 27, 33, 1);
const Color purpleGradient = Color.fromRGBO(122, 61, 143, 1);
const Color iconColor = purpleGradient;

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      // BACKGROUND --------------------------------
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, backgroundColorSecondary],
          begin: Alignment(0.5, -1),
          end: Alignment(0.5, 1),
        ),
      ),
      child: SafeArea(
        child: child
      ),
    );
  }
}

const Gradient textGradient = LinearGradient(
  colors: [Color.fromRGBO(5, 62, 148, 1), Color.fromRGBO(122, 61, 143, 1)],
);

const Gradient verticalGradientAccent = LinearGradient(
  colors: [Color.fromRGBO(5, 62, 148, 1), Color.fromRGBO(122, 61, 143, 1)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const TextStyle titleStyle = TextStyle(
  color: textColor,
  fontSize: 48,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

TextStyle titleStyleWithGradient = TextStyle(
  fontSize: 48,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
  foreground: Paint()
    ..shader = textGradient.createShader(const Rect.fromLTWH(0, 0, 300, 70)),
);

const TextStyle subtitleStyle = TextStyle(
  color: textColor,
  fontSize: 48,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle bodyStyle = TextStyle(
  color: textColor,
  fontSize: 16,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

TextStyle bodyStyleSubdued = TextStyle(
  color: textColor.withOpacity(0.5),
  fontSize: 16,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle boldBodyStyle = TextStyle(
  color: textColor,
  fontSize: 16,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle smallBodyStyle = TextStyle(
  color: textColor,
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

ButtonStyle buttonStyle = ButtonStyle(
  backgroundColor: const WidgetStatePropertyAll(darkGrey),
  fixedSize: const WidgetStatePropertyAll(Size(5000, 50)),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);

DateTime testDateTime = DateTime(
  2024,
  1,
  1,
  10,
  07,
  1,
  1,
  1,
);

BellSchedule testASchedule = BellSchedule.withValues(periods: [
  BellPeriod.withValues(
    periodName: "1",
    startTime: const TimeOfDay(hour: 8, minute: 30),
    endTime: const TimeOfDay(hour: 10, minute: 2)),
  BellPeriod.withValues(
    periodName: "2",
    startTime: const TimeOfDay(hour: 10, minute: 9),
    endTime: const TimeOfDay(hour: 11, minute: 41)),
  BellPeriod.withValues(
    periodName: "Lunch",
    startTime: const TimeOfDay(hour: 11, minute: 41),
    endTime:
        const TimeOfDay(hour: 12, minute: 14)), // this will cause problems
  BellPeriod.withValues(
    periodName: "3",
    startTime: const TimeOfDay(hour: 12, minute: 19),
    endTime: const TimeOfDay(hour: 13, minute: 51)),
  BellPeriod.withValues(
    periodName: "4",
    startTime: const TimeOfDay(hour: 13, minute: 58),
    endTime: const TimeOfDay(hour: 15, minute: 30)),
]);

BellSchedule testBSchedule = BellSchedule.withValues(periods: [
  BellPeriod.withValues(
    periodName: "5",
    startTime: const TimeOfDay(hour: 8, minute: 30),
    endTime: const TimeOfDay(hour: 10, minute: 2)),
  BellPeriod.withValues(
    periodName: "6",
    startTime: const TimeOfDay(hour: 10, minute: 9),
    endTime: const TimeOfDay(hour: 11, minute: 41)),
  BellPeriod.withValues(
    periodName: "Lunch",
    startTime: const TimeOfDay(hour: 11, minute: 41),
    endTime:
        const TimeOfDay(hour: 12, minute: 14)), // this will cause problems
  BellPeriod.withValues(
    periodName: "7",
    startTime: const TimeOfDay(hour: 12, minute: 19),
    endTime: const TimeOfDay(hour: 13, minute: 51)),
  BellPeriod.withValues(
    periodName: "8",
    startTime: const TimeOfDay(hour: 13, minute: 58),
    endTime: const TimeOfDay(hour: 15, minute: 30)),
]);

Map<String, String> periodNameToIndicator = {
  "1": "P1",
  "2": "P2",
  "3": "P3",
  "4": "P4",
  "5": "P5",
  "6": "P6",
  "7": "P7",
  "8": "P8",
  "Flex": "FLX",
  "Lunch": "L",
  "": "PASS"
};
