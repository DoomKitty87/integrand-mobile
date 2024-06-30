import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.pageController});

  final PageController pageController;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Stack(
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
                      widget.pageController.animateToPage(
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
          ),
        ),
        Container(
          child: const Center(
            child: Text('Settings'),
          ),
        )
      ],
    );
  }
}
