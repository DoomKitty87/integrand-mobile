import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:provider/provider.dart';
import 'package:integrand/backend/studentvue_api.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(builder: (context, studentVueAPI, child) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              Text(
                studentVueAPI.studentData.name,
                style: titleStyle,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              Text(
                studentVueAPI.studentData.studentId.toString(),
                style: subtitleStyle,
              ),
            ],
          ),
        ),
      ]);
    });
  }
}
