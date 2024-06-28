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
import 'package:integrand/loading_schedule.dart';

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
          child: App(),
        ), // --------------------------------------------
      ),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Future<bool> isCredsStored() async {
    await DataStorage.loadData();
    if (username == '' || password == '') {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {

    DataStorage.clearData();

    return FutureBuilder<bool>(
      future: isCredsStored(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingSchedule();
        } 
        else {
          if (snapshot.data!) {
            Provider.of<StudentVueAPI>(context, listen: false).initialize(
              'https://parent-portland.cascadetech.org/portland',
              username,
              password,
            );
            return Consumer<StudentVueAPI>(
              builder: (context, studentVueAPI, child) {
                if (!studentVueAPI.initialized) {
                  return const LoadingSchedule();
                }
                return const Main();
              },
            );
          } else {
            return const IntakePrimary();
          }
        }
      },
    );
  }
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
    // DataStorage.clearData();
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
