import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'backend/studentvue_api.dart';

import 'package:integrand/schedule.dart';

const String appName = "Integrant";

const Color backgroundColor = Color.fromRGBO(13, 13, 13, 1); //HSVO(0, 0, 5, 1)


enum AppPage {
  Schedule,
  Gradebook,
}

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => StudentVueAPI(),
    child: MaterialApp(
      title: appName,
      theme: ThemeData(fontFamily: 'Inter'),
      home: Container( // BACKGROUND --------------------------------
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundColor, Color.fromRGBO(12, 11, 14, 1)],
            begin: Alignment(0.5, -1),
            end: Alignment(0.5, 1),
          ),
        ),
        child: const Main(),
      ) // --------------------------------------------
      ), 
    ),
  );
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  
  @override
  Widget build(BuildContext context) {
    // Provider.of<StudentVueAPI>(context, listen: false).initialize(
    //   'https://parent-portland.cascadetech.org/portland',
    //   'username',
    //   'password',
    // );
    return const SafeArea(
      child: Schedule(), 
    );
  }
}

// class DisplaySchedule extends StatelessWidget {
//   const DisplaySchedule({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<StudentVueAPI>(
//       builder: (context, studentVueAPI, child) {
//         return FutureBuilder(
//           future: studentVueAPI.schedule(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               } else {
//                 // Get text from response
//                 //String result = StudentVueAPI.parseSchedule(snapshot.data!);
//                 //return Text('Schedule: $result');
//                 return const Text('Schedule: ');
//               }
//             } else {
//               return const CircularProgressIndicator();
//             }
//           },
//         );
//       },
//     );
//   }
// }
