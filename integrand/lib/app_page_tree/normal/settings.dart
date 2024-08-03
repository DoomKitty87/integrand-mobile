import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:integrand/consts.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.pageController});

  final PageController pageController;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  
  PageController settingPageController = PageController(
    initialPage: 0,
  );

  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SettingTopBar(settings: widget),
        ),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: PageView(
            controller: settingPageController,
            children: [
              SettingsMain(),
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
    required this.settings,
  });

  final Settings settings;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 25,
                color: textColor,
              ),
              onPressed: () {
                settings.pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut
                );
              },
            ),
          ]
        ),
        const Center(
          child: Text(
            'Settings',
            style: boldBodyStyle,
          ),
        )
      ]
    );
  }
}

class SettingsMain extends StatelessWidget {
  const SettingsMain({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SettingListItem(
          title: 'Account', 
          pageIndex: 0,
        ),
      ],
    );
  }
}

class SettingListItem extends StatelessWidget {
  const SettingListItem({super.key, required this.title, required this.pageIndex, this.textAndIconColor = textColor, this.useIcons = false, this.icon = const Icon(Icons.dangerous)});

  final String title;
  final int pageIndex;
  final Color textAndIconColor;
  final bool useIcons;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: lightGrey,
            width: 1
          )
        )
      ),
      child: SizedBox(
        height: 50,
        child: Text(
          title,
          style: bodyStyle,
        ),
      ),
    );
  }
}