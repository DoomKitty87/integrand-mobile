import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'backend/studentvue_api/studentvue_api.dart';
import 'consts.dart';
import 'backend/data_storage.dart';
import 'backend/transit_api.dart';

enum AppPage {
  transit,
  calendar,
  schedule,
  gradebook,
  news,
}

enum IntakePage {
  primary,
  credentials,
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (context) => AppData()),
        ChangeNotifierProvider(create: (context) => StudentVueAPI()),
        // ChangeNotifierProvider(create: (context) => TransitAPI(), lazy: false),    
      ],
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(
          fontFamily: 'Inter',
          brightness: Brightness.dark,
          primaryColor: background1,
          scaffoldBackgroundColor: background0,
        ),
        debugShowCheckedModeBanner: false,
        home: DefaultTextStyle(
          style: const TextStyle(
              fontFamily: 'Inter',
              color: textWhite,
              decoration: TextDecoration.none),
          child: MediaQuery.withNoTextScaling(
              // ignored because it lets hot reload work
              // ignore: prefer_const_constructors
              child: App()),
        ), // --------------------------------------------
      ),
    ),
  );
}

class AppData extends ChangeNotifier {
  AppPage _currentPage = AppPage.schedule;
  AppPage get currentPage => _currentPage;

  PageController? _mainPageController;
  int selectedGradebookIndex = -1;

  static int indexFromPage(AppPage page) {
    switch (page) {
      case AppPage.transit:
        return 0;
      case AppPage.calendar:
        return 1;
      case AppPage.schedule:
        return 2;
      case AppPage.gradebook:
        return 3;
      case AppPage.news:
        return 4;
    }
  }

  void selectGradebookClass(int index) {
    selectedGradebookIndex = index;
    notifyListeners();
  }

  void changePage(AppPage page, {bool animate = false}) {
    _currentPage = page;
    if (_mainPageController != null && animate) {
      _mainPageController!.animateToPage(indexFromPage(page),
          duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    }
    notifyListeners();
  }

  bool _isIntake = false;
  bool get isIntake => _isIntake;

  IntakePage _intakePage = IntakePage.primary;
  IntakePage get intakePage => _intakePage;

  void changeIntakePage(IntakePage page) {
    _intakePage = page;
    notifyListeners();
  }

  void setIntake(bool intake) {
    _isIntake = intake;
    notifyListeners();
  }

  void logout() {
    DataStorage.clearData();
    setIntake(true);
  }

  void update() {
    notifyListeners();
  }
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
    return Consumer<AppData>(
      builder: (context, appData, child) {
        return FutureBuilder<bool>(
          future: isCredsStored(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LoadingSchedule();
            } else {
              bool _ = appData.isIntake;
              if (snapshot.data!) {
                Provider.of<StudentVueAPI>(context, listen: false).initialize(
                  'https://parent-portland.cascadetech.org/portland',
                  username,
                  password,
                );
                return Consumer<StudentVueAPI>(
                  builder: (context, studentVueAPI, child) {
                    if (!studentVueAPI.ready) {
                      return const LoadingSchedule();
                    }
                    return const Main();
                  },
                );
              } else {
                PageController pageController = PageController(
                  initialPage: 0,
                );

                return PageView(
                  controller: pageController,
                  children: [
                    IntakePrimary(
                      pageController: pageController,
                    ),
                    const IntakeCredentials(),
                  ],
                  onPageChanged: (value) {
                    Provider.of<AppData>(context, listen: false)
                        .changeIntakePage(IntakePage.values[value]);
                  },
                );
              }
            }
          },
        );
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
    PageController pageController = PageController(
      initialPage: 1,
    ); // Make starting index go to schedule page

    List<Widget> pages = [
      Profile(pageController: pageController),
      Consumer<AppData>(
        builder: (context, appData, child) {
          return CenterPage(
            pageController: pageController,
            startIndex: AppData.indexFromPage(appData.currentPage),
          );
        },
      ),
      Settings(inheritedController: pageController),
    ];

    return AppBackground(
      child: PageView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: pages.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return pages[index];
        },
        onPageChanged: (value) {},
        controller: pageController,
      ),
    );
  }
}