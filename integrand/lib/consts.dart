import 'package:flutter/material.dart';
import 'package:integrand/backend/data_classes.dart';

const String appName = "Integrand";

const Color backgroundColor = Color.fromRGBO(5, 5, 5, 1); //HSVO(0, 0, 2, 1)
const Color primaryColor = Color.fromRGBO(10, 10, 10, 1);
const Color highlightColor = Color.fromRGBO(22, 22, 22, 1);
const Color backgroundColorSecondary = Color.fromRGBO(5, 5, 5, 1);
const Color textColor = Color.fromRGBO(224, 224, 224, 1);
const Color textColorSecondary = Color.fromRGBO(112, 112, 112, 1);
const Color darkGrey = Color.fromRGBO(14, 14, 14, 1);
const Color lightGrey = Color.fromRGBO(26, 27, 33, 1);
const Color lightGreyTransparent = Color.fromRGBO(217, 217, 217, 0.02);
const Color lighterGrey = Color.fromRGBO(45, 47, 57, 1);
const Color lightestGrey = Color.fromRGBO(85, 87, 97, 1);
const Color blueGradient = Color.fromRGBO(5, 62, 148, 1);
const Color purpleGradient = Color.fromRGBO(122, 61, 143, 1);
const Color iconColor = purpleGradient;
const Color errorColor = Color.fromRGBO(255, 0, 0, 1);
const Color barColor = textColorSecondary;
const Color barColorSelected = textColor;

class BorderLine extends StatelessWidget {
  const BorderLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: lightGrey,
    );
  }
}

const List<Color> eventTypeColors = [
  Color(0x8E7DBEFF),
  Color(0xFFC857FF),
  Color(0x61E786FF),
  Color(0xF03A47FF),
  Color(0x2B56A1FF),
];

const List<String> eventTypeNames = [
  "School",
  "Campus",
  "Clubs",
  "Arts",
  "Sports",
];

const List<IconData> eventTypeIcons = [
  Icons.school,
  Icons.apartment,
  Icons.group,
  Icons.palette,
  Icons.sports_soccer,
];

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
      child: SafeArea(child: child),
    );
  }
}

const Gradient textGradient = LinearGradient(
  colors: [blueGradient, purpleGradient],
);

const Gradient verticalGradientAccent = LinearGradient(
  colors: [blueGradient, purpleGradient],
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

const TextStyle mediumTitleStyle = TextStyle(
  color: textColor,
  fontSize: 24,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle mediumSubtitleStyle = TextStyle(
  color: textColor,
  fontSize: 24,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle bodyStyle = TextStyle(
  color: textColor,
  fontSize: 14,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle bodyStyleSubdued = TextStyle(
  color: textColorSecondary,
  fontSize: 14,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle boldBodyStyle = TextStyle(
  color: textColor,
  fontSize: 14,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle boldBodyStyleSubdued = TextStyle(
  color: textColorSecondary,
  fontSize: 14,
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

const TextStyle smallBodyStyleSubdued = TextStyle(
  color: textColorSecondary,
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle boldSmallBodyStyle = TextStyle(
  color: textColor,
  fontSize: 12,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle errorStyle = TextStyle(
  color: errorColor,
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle barStyle = TextStyle(
  color: textColorSecondary,
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle barStyleSelected = TextStyle(
  color: textColor,
  fontSize: 12,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle newsDateStyle = TextStyle(
  color: textColor,
  fontSize: 10,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

ButtonStyle buttonStyle = ButtonStyle(
  side: const WidgetStatePropertyAll(
    BorderSide(
      color: lighterGrey,
      width: 1,
    ),
  ),
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
  5,
  1,
  1,
  1,
);

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

List<String> months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

List<String> daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
