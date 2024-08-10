import 'dart:io';
import 'package:integrand/main.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.inheritedController});

  final PageController inheritedController;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  
  PageController settingsController = PageController(
    initialPage: 0,
  );

  int subpagePageIndex = 0;
  bool isSubpage = false;
  String subpageTitle = '';


  void goToSubpage(int subpageIndex, String subpageName) {
    setState(() {
      subpagePageIndex = subpageIndex;
      isSubpage = true;
      subpageTitle = subpageName;
      settingsController.animateToPage(
        1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut
      );
    });
  }

  void goToMainPage() {
    setState(() {
      isSubpage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingTopBar(
          inheritedController: widget.inheritedController,
          settingsController: settingsController,
          goToMainPageFunction: goToMainPage,
          isSubpage: isSubpage,
          subpageTitle: subpageTitle,
        ),
        const SizedBox(
          height: 50,
        ),
        Expanded(
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: settingsController,
            children: [
              SettingsMain(
                parentSetState: goToSubpage,
              ),
              SettingsSubpages(
                subpagePageIndex: subpagePageIndex,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingTopBar extends StatelessWidget {
  const SettingTopBar({
    super.key,
    required this.inheritedController,
    required this.settingsController,
    required this.goToMainPageFunction,
    required this.isSubpage,
    required this.subpageTitle,
  });

  final PageController inheritedController;
  final PageController settingsController;
  final Function goToMainPageFunction;
  final bool isSubpage;
  final String subpageTitle;

  String getTitle() {
    if (isSubpage) {
      return subpageTitle;
    } else {
      return 'Settings';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 25,
                  color: textColor,
                ),
                onPressed: () {
                  if (isSubpage) {
                    settingsController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut
                    );
                    goToMainPageFunction();
                  } else {
                    inheritedController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut
                    );
                  }
                },
              ),
            ]
          ),
          Center(
            child: Text(
              getTitle(),
              style: boldBodyStyle,
            ),
          )
        ]
      ),
    );
  }
}

class SettingsMain extends StatelessWidget {
  const SettingsMain({super.key, required this.parentSetState});

  final Function(int, String) parentSetState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingListItem(
          parentSetState: parentSetState,
          title: 'Legal', 
          subpagePageIndex: 0,
          textAndIconColor: textColor,
        ),
        SettingListItemButton(
          title: 'Logout', 
          textAndIconColor: Colors.red,
          includeBottomBorder: true,
          useIcons: true,
          icon: Icon(Icons.logout_rounded),
          onPressed: () {
            if (Platform.isIOS) {
              showCupertinoDialog(
                context: context, 
                barrierDismissible: false,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Provider.of<AppData>(context, listen: false).logout();
                          Navigator.pop(context);
                        },
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No'),
                      ),
                    ],
                  );
                }
              );
            }
            else {
              showDialog(
                context: context, 
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: highlightColor,
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Provider.of<AppData>(context, listen: false).logout();
                          Navigator.pop(context);
                        },
                        child: const Text('Yes'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No'),
                      ),
                    ],
                  );
                }
              );
            }
          },
        ),
      ],
    );
  }
}

class SettingListItem extends StatelessWidget {
  const SettingListItem({super.key, required this.parentSetState, required this.title, required this.subpagePageIndex, this.textAndIconColor = textColor, this.includeBottomBorder = false, this.useIcons = false, this.icon = const Icon(Icons.dangerous)});

  final Function(int, String) parentSetState;

  final String title;
  final int subpagePageIndex;
  final Color textAndIconColor;
  final bool useIcons;
  final Icon icon;
  final bool includeBottomBorder;

  final double padding = 10;
  final double height = 50;

  Border getBorder() {
    if (includeBottomBorder) {
      return const Border(
        top: BorderSide(
          color: lightGrey,
          width: 1
        ),
        bottom: BorderSide(
          color: lightGrey,
          width: 1
        )
      );
    } else {
      return const Border(
        top: BorderSide(
          color: lightGrey,
          width: 1
        )
      );
    }
  }

  Widget getIcon() {
    if (useIcons) {
      return Icon(
        icon.icon,
        color: textAndIconColor,
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      decoration: BoxDecoration(
        border: getBorder(),
      ),
      child: SizedBox(
        height: height,
        child: TextButton(
          onPressed: () {
            parentSetState(subpagePageIndex, title);
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: padding,
              right: padding,
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: bodyStyle.copyWith(
                    color: textAndIconColor
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                getIcon(),
              ],
            ),
          ),
        )
      ),
    );
  }
}

class SettingListItemButton extends StatelessWidget {
  const SettingListItemButton({super.key, required this.onPressed, required this.title, this.textAndIconColor = textColor, this.includeBottomBorder = false, this.useIcons = false, this.icon = const Icon(Icons.dangerous)});

  final Function() onPressed;

  final String title;
  final Color textAndIconColor;
  final bool useIcons;
  final Icon icon;
  final bool includeBottomBorder;

  final double padding = 10;
  final double height = 50;

  Border getBorder() {
    if (includeBottomBorder) {
      return const Border(
        top: BorderSide(
          color: lightGrey,
          width: 1
        ),
        bottom: BorderSide(
          color: lightGrey,
          width: 1
        )
      );
    } else {
      return const Border(
        top: BorderSide(
          color: lightGrey,
          width: 1
        )
      );
    }
  }

  Widget getIcon() {
    if (useIcons) {
      return Icon(
        icon.icon,
        color: textAndIconColor,
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      decoration: BoxDecoration(
        border: getBorder(),
      ),
      child: SizedBox(
        height: height,
        child: TextButton(
          onPressed: () {
            onPressed();
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: padding,
              right: padding,
            ),
            child: Row(
              children: [
                Text(
                  title,
                  style: bodyStyle.copyWith(
                    color: textAndIconColor
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                getIcon(),
              ],
            ),
          ),
        )
      ),
    );
  }
}

class SettingsSubpages extends StatelessWidget {
  const SettingsSubpages({super.key, required this.subpagePageIndex});

  final int subpagePageIndex;

  @override
  Widget build(BuildContext context) {
  switch (subpagePageIndex) {
    case 0:
      return const Legal();
    default:
      return const Placeholder();
    }
  }
}

class Legal extends StatelessWidget {
  const Legal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Legal',
        style: bodyStyle,
      )
    );
  }
}

