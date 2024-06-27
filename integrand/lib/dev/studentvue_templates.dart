import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/studentvue_api.dart';

class DisplaySchedule extends StatelessWidget {
  const DisplaySchedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(
      builder: (context, studentVueAPI, child) {
        return FutureBuilder(
          future: studentVueAPI.schedule(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Get text from response
                //String result = StudentVueAPI.parseSchedule(snapshot.data!);
                //return Text('Schedule: $result');
                return const Text('Schedule: ');
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        );
      },
    );
  }
}
