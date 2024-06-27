import 'package:flutter/material.dart';
import 'package:integrand/backend/studentvue_api.dart';
import 'package:provider/provider.dart';

import 'consts.dart';

class Gradebook extends StatefulWidget {
  const Gradebook({super.key});

  @override
  State<Gradebook> createState() => _GradebookState();
}

class _GradebookState extends State<Gradebook> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          height: 35.0,
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.0, right: 20.0),
          child: GPADisplay(),
        ),
        SizedBox(
          height: 75.0,
        ),
        GradebookDisplay(),
      ],
    );
  }
}

class GPADisplay extends StatelessWidget {
  const GPADisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(builder: (context, value, child) {
      double gpa = value.gpaData.weightedGPA;
      double uw = value.gpaData.unweightedGPA;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "GPA",
                style: titleStyle,
              ),
              Text(
                gpa.toString(),
                style: titleStyle,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Unweighted $uw",
                style: bodyStyle,
              ),
            ],
          )
        ],
      );
    });
  }
}

String parseGradeToLetter(double grade) {
  if (grade < 10) {
    if (grade >= 3.5) {
      return "A";
    } else if (grade >= 3.0) {
      return "B";
    } else if (grade >= 2.5) {
      return "C";
    } else if (grade >= 2.0) {
      return "D";
    } else {
      return "F";
    }
  } else {
    if (grade >= 90) {
      return "A";
    } else if (grade >= 80) {
      return "B";
    } else if (grade >= 70) {
      return "C";
    } else if (grade >= 60) {
      return "D";
    } else {
      return "F";
    }
  }
}

class GradebookDisplay extends StatefulWidget {
  const GradebookDisplay({super.key});

  @override
  State<GradebookDisplay> createState() => _GradebookDisplayState();
}

class _GradebookDisplayState extends State<GradebookDisplay> {
  final List<TableRow> children = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(builder: (context, value, child) {
      children.clear();

      TableRow border = TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: textColor,
                    width: 0.1,
                  ),
                ),
              ),
              child: const SizedBox(
                height: 0.01,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: textColor,
                  width: 0.1,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: textColor,
                    width: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      );

      const EdgeInsets textPadding = EdgeInsets.only(
        top: 16,
        bottom: 16,
        left: 25.0,
        right: 25.0,
      );

      children.add(border);

      for (var course in value.gradebookData.courses) {
        RegExp getTitle = RegExp(r" [(](.*?)[)]");
        String title = course.courseTitle.replaceFirst(
            getTitle.firstMatch(course.courseTitle)!.group(0).toString(), '');

        double grade = course.grade;

        if (grade > 10) grade /= 25;

        children.add(TableRow(
          children: [
            Padding(
              padding: textPadding,
              child: Text(title, style: bodyStyle),
            ),
            Padding(
              padding: textPadding,
              child: Text(parseGradeToLetter(grade), style: bodyStyle),
            ),
            Padding(
              padding: textPadding,
              child: Text(grade.toString(),
                  style: bodyStyle, textAlign: TextAlign.right),
            ),
          ],
        ));
        children.add(border);
      }

      return Table(
        children: children,
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(0.5),
          2: FlexColumnWidth(1),
        },
      );
    });
  }
}
