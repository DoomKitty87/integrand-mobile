import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:provider/provider.dart';
import 'package:integrand/backend/studentvue_api.dart';
import 'package:barcode_widget/barcode_widget.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.pageController});

  final PageController pageController;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Stack(alignment: Alignment.centerRight, children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 25,
                  color: textWhite,
                ),
                onPressed: () {
                  widget.pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut);
                },
              ),
            ]),
            const Center(
              child: Text(
                'Student Info',
                style: bodyStyleBold,
              ),
            )
          ]),
        ),
        Consumer<StudentVueAPI>(builder: (context, studentVueAPI, child) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 60, bottom: 80),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(studentVueAPI.studentData.photo),
                        fit: BoxFit.fill,
                        height: 250,
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textAlign: TextAlign.left,
                        studentVueAPI.studentData.name,
                        style: subtitleStyle,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        textAlign: TextAlign.left,
                        "Student ID: ${studentVueAPI.studentData.studentId.toString()}",
                        style: bodyStyle,
                      ),
                      Text(
                        textAlign: TextAlign.left,
                        "Grade: ${studentVueAPI.studentData.grade.toString()}",
                        style: bodyStyle,
                      ),
                      Text(
                        textAlign: TextAlign.left,
                        "School: ${studentVueAPI.studentData.school}",
                        style: bodyStyle,
                      ),
                      Text(
                        textAlign: TextAlign.left,
                        "Counselor: ${studentVueAPI.studentData.counselor}",
                        style: bodyStyle,
                      ),
                      if (studentVueAPI.studentData.locker != '')
                        Text(
                          textAlign: TextAlign.left,
                          "Locker: ${studentVueAPI.studentData.locker}",
                          style: bodyStyle,
                        ),
                      if (studentVueAPI.studentData.lockerCombo != '')
                        Text(
                          textAlign: TextAlign.left,
                          "Locker Combo: ${studentVueAPI.studentData.lockerCombo}",
                          style: bodyStyle,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 80),
                  child: BarcodeWidget(
                    barcode: Barcode.code39(),
                    drawText: false,
                    width: 250,
                    height: 50,
                    backgroundColor: textWhite,
                    color: background0,
                    data: studentVueAPI.studentData.studentId.toString(),
                  ),
                )
              ]);
        }),
      ],
    );
  }
}
