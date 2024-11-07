import 'package:flutter/material.dart';
import 'package:integrand/backend/data_classes.dart';

const String appName = "Integrand";

const Color background0 = Color.fromRGBO(11, 11, 16, 1); //HSVO(0, 0, 2, 1)
const Color background1 = Color.fromRGBO(16, 16, 22, 1);
const Color background2 = Color.fromRGBO(22, 22, 32, 1);
const Color background3 = Color.fromRGBO(54, 54, 74, 1);
const Color background4 = Color.fromRGBO(65, 65, 88, 1);
const Color textWhite = Color.fromRGBO(224, 224, 224, 1);
const Color textGrey = Color.fromRGBO(63, 63, 63, 1);
const Color blueGradient = Color.fromRGBO(5, 62, 148, 1);
const Color purpleGradient = Color.fromRGBO(122, 61, 143, 1);
const Color errorColor = Color.fromRGBO(255, 0, 0, 1);

class BorderLine extends StatelessWidget {
  const BorderLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: background3,
    );
  }
}

const List<Color> eventTypeColors = [
  Color(0xFF8E7DBE),
  Color(0xFFFFC857),
  Color(0xFF61E786),
  Color(0xFFF03A47),
  Color(0xFF2B56A1),
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

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      // BACKGROUND --------------------------------
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [background0, background0],
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
  color: textWhite,
  fontSize: 48,
  fontWeight: FontWeight.w600,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

TextStyle titleStyleGradient = TextStyle(
  fontSize: 48,
  fontWeight: FontWeight.w600,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
  foreground: Paint()
    ..shader = textGradient.createShader(const Rect.fromLTWH(0, 0, 300, 70)),
);

const TextStyle subtitleStyle = TextStyle(
  color: textWhite,
  fontSize: 20,
  fontWeight: FontWeight.w600,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle bodyStyle = TextStyle(
  color: textWhite,
  fontSize: 16,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle bodyStyleSubdued = TextStyle(
  color: textGrey,
  fontSize: 16,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle bodyStyleBold = TextStyle(
  color: textWhite,
  fontSize: 16,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle bodyStyleBoldSubdued = TextStyle(
  color: textGrey,
  fontSize: 16,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle labelStyle = TextStyle(
  color: textWhite,
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle labelStyleSubdued = TextStyle(
  color: textGrey,
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle labelStyleBold = TextStyle(
  color: textWhite,
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
  color: textGrey,
  fontSize: 12,
  fontWeight: FontWeight.normal,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle barStyleSelected = TextStyle(
  color: textWhite,
  fontSize: 12,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

const TextStyle newsDateStyle = TextStyle(
  color: textWhite,
  fontSize: 10,
  fontWeight: FontWeight.bold,
  fontFamily: "Inter",
  decoration: TextDecoration.none,
);

ButtonStyle buttonStyle = ButtonStyle(
  side: const WidgetStatePropertyAll(
    BorderSide(
      color: background3,
      width: 1,
    ),
  ),
  backgroundColor: const WidgetStatePropertyAll(background2),
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
