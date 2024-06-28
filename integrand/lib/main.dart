import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'backend/studentvue_api.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:integrand/schedule.dart';
import 'package:integrand/gradebook.dart';
import 'package:integrand/intake_primary.dart';
import 'package:integrand/intake_credentials.dart';
import 'consts.dart';
import 'backend/data_storage.dart';

enum AppPage {
  schedule,
  gradebook,
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => StudentVueAPI(),
      child: MaterialApp(
        title: appName,
        theme: ThemeData(fontFamily: 'Inter'),
        home: const DefaultTextStyle(
          style: TextStyle(
              fontFamily: 'Inter',
              color: textColor,
              decoration: TextDecoration.none),
          child: IntakePrimary(),
        ), // --------------------------------------------
      ),
    ),
  );
}

// Main is anything that isn't intake or loading
class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    DataStorage.clearData();
    // Provider.of<StudentVueAPI>(context, listen: false).initialize(
    //   'https://parent-portland.cascadetech.org/portland',
    //   'username',
    //   'password',
    // );

    // TODO: Somewhere in here, add a block to check for studentVueAPI.initialized
    // Block app view with loading screen until initialized

    return GradientBackground(
      child: Schedule(),
    );
  }
}


