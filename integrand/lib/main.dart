import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:integrand/backend/studentvue_api.dart';
import 'package:integrand/schedule.dart';
import 'package:integrand/gradebook.dart';
import 'package:integrand/news.dart';
import 'package:integrand/transit.dart';
import 'package:integrand/calendar.dart';
import 'package:integrand/profile.dart';
import 'package:integrand/settings.dart';
import 'package:integrand/intake_primary.dart';
import 'package:integrand/intake_credentials.dart';
import 'package:integrand/consts.dart';
import 'package:integrand/backend/data_storage.dart';
import 'package:integrand/loading_schedule.dart';

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
        ChangeNotifierProvider(create: (context) => AppData()),
        ChangeNotifierProvider(create: (context) => StudentVueAPI()),
      ],
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

class AppData extends ChangeNotifier {
  AppPage _currentPage = AppPage.schedule;
  AppPage get currentPage => _currentPage;

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

  void changePage(AppPage page) {
    _currentPage = page;
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
                if (appData.intakePage == IntakePage.credentials) {
                  return const IntakeCredentials();
                } else {
                  return const IntakePrimary();
                }
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
        initialPage: 1); // Make starting index go to schedule page

    List<Widget> pages = [
      const Profile(),
      CenterPage(pageController: pageController),
      const Settings(),
    ];

    return GradientBackground(
      child: PageView.builder(
        itemCount: pages.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return pages[index];
        },
        controller: pageController,
      ),
    );
  }
}

class CenterPage extends StatelessWidget {
  CenterPage({super.key, required this.pageController});

  final PageController pageController;

  final PageController innerPageController = PageController(
    initialPage: 2,
  );

  final List<Widget> innerPages = [
    const Transit(),
    const Calendar(),
    const Schedule(),
    const Gradebook(),
    const News(),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.account_circle_sharp,
                  size: 25,
                  color: textColor,
                ),
                onPressed: () {
                  pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_sharp,
                  size: 25,
                  color: textColor,
                ),
                onPressed: () {
                  pageController.animateToPage(2,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut);
                },
              ),
            ],
          ),
        ),
        // Consumer<AppData>(
        //   builder: (context, appData, child) {
        //     switch (appData.currentPage) {
        //       case AppPage.transit:
        //         return const Transit();
        //       case AppPage.calendar:
        //         return const Calendar();
        //       case AppPage.schedule:
        //         return const Schedule();
        //       case AppPage.gradebook:
        //         return const Gradebook();
        //       case AppPage.news:
        //         return const News();
        //     }
        //   },
        // ),
        Expanded(
          child: PageView.builder(
              itemCount: innerPages.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return innerPages[index];
              },
              controller: innerPageController,
              onPageChanged: (value) => {
                    Provider.of<AppData>(context, listen: false)
                        .changePage(AppPage.values[value])
                  }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PageSelect(
              page: AppPage.transit,
              text: 'Transit',
              icon: Icons.commute_sharp,
              pageController: innerPageController,
            ),
            PageSelect(
              page: AppPage.calendar,
              text: 'Calendar',
              icon: Icons.calendar_month_sharp,
              pageController: innerPageController,
            ),
            PageSelect(
              page: AppPage.schedule,
              text: 'Schedule',
              icon: Icons.browse_gallery_sharp,
              pageController: innerPageController,
            ),
            PageSelect(
              page: AppPage.gradebook,
              text: 'Gradebook',
              icon: Icons.book_sharp,
              pageController: innerPageController,
            ),
            PageSelect(
              page: AppPage.news,
              text: 'News',
              icon: Icons.newspaper_sharp,
              pageController: innerPageController,
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}

class PageSelect extends StatelessWidget {
  const PageSelect(
      {super.key,
      required this.page,
      required this.text,
      required this.icon,
      required this.pageController});

  final AppPage page;
  final String text;
  final IconData icon;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        return TextButton(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              shape: WidgetStateProperty.all<ContinuousRectangleBorder>(
                const ContinuousRectangleBorder(),
              ),
            ),
            onPressed: () {
              pageController.animateToPage(AppData.indexFromPage(page),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 25,
                  color:
                      appData.currentPage == page ? barColorSelected : barColor,
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  text,
                  style:
                      appData.currentPage == page ? barStyleSelected : barStyle,
                ),
              ],
            ));
      },
    );
  }
}
