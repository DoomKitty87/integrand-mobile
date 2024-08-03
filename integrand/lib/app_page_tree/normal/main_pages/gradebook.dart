import 'package:flutter/material.dart';
import 'package:integrand/backend/studentvue_api.dart';
import 'package:provider/provider.dart';
import 'package:integrand/backend/data_classes.dart';

import '../../../consts.dart';

class Gradebook extends StatefulWidget {
  const Gradebook({super.key});

  @override
  State<Gradebook> createState() => _GradebookState();
}

class _GradebookState extends State<Gradebook> {
  CourseGrading currentCourse = CourseGrading();
  CourseGrading virtualCourse = CourseGrading();

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(builder: (context, value, child) {
      if (value.gradebookData.error || value.gpaData.error) {
        return const Center(
          child: Text(
            "No gradebook data available.",
            style: bodyStyle,
          ),
        );
      }

      PageController controller = PageController();

      return PageView(controller: controller, children: [
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
              child: GPADisplay(),
            ),
            const SizedBox(
              height: 75.0,
            ),
            GradebookDisplay(selectedCourse: (CourseGrading course) {
              currentCourse = course;
              virtualCourse = course;
              controller.animateToPage(1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut);
            }),
          ],
        ),
        Column(children: [
          ClassHeaderBar(
            classTitle: currentCourse.courseTitle,
            exitCallback: () {
              controller.animateToPage(0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut);
            },
          ),
          const SizedBox(
            height: 30.0,
          ),
          ClassGradeDisplay(course: currentCourse, virtualized: virtualCourse),
          const SizedBox(
            height: 40.0,
          ),
          Expanded(
            child: ClassGradeCalculator(
              course: currentCourse,
              virtualized: virtualCourse,
              updateCallback: (CourseGrading course) {
                setState(() {
                  virtualCourse = course;
                });
              },
            ),
          ),
        ])
      ]);
    });
  }
}

class ClassGradeCalculator extends StatefulWidget {
  const ClassGradeCalculator(
      {super.key,
      required this.course,
      required this.virtualized,
      required this.updateCallback});

  final CourseGrading course;
  final CourseGrading virtualized;
  final Function(CourseGrading) updateCallback;

  @override
  State<ClassGradeCalculator> createState() => _ClassGradeCalculatorState();
}

class _ClassGradeCalculatorState extends State<ClassGradeCalculator> {
  bool orderByGrade = false;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: orderByGrade ? lightGrey : null,
              gradient: orderByGrade ? null : textGradient,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: textColor, width: 0.1),
            ),
            child: const SizedBox(
                width: 150,
                height: 50,
                child: Center(child: Text("Order by Impact"))),
          ),
          onTap: () {
            setState(() {
              orderByGrade = false;
            });
          },
        ),
        const SizedBox(
          width: 20.0,
        ),
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: orderByGrade ? null : lightGrey,
              gradient: orderByGrade ? textGradient : null,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: textColor, width: 0.1),
            ),
            child: const SizedBox(
                width: 150,
                height: 50,
                child: Center(child: Text("Order by Grade"))),
          ),
          onTap: () {
            setState(() {
              orderByGrade = true;
            });
          },
        ),
      ]),
      const SizedBox(
        height: 30.0,
      ),
      Expanded(
        child: ListView(
          children: [
            for (int assignment = 0;
                assignment < widget.course.assignments.length;
                assignment++)
              AssignmentDisplay(
                assignment: assignment,
                course: widget.course,
                virtualized: widget.virtualized,
                updateCallback: widget.updateCallback,
                orderByGrade: orderByGrade,
              ),
          ],
        ),
      ),
    ]);
  }
}

class AssignmentDisplay extends StatefulWidget {
  const AssignmentDisplay(
      {super.key,
      required this.assignment,
      required this.course,
      required this.virtualized,
      required this.updateCallback,
      required this.orderByGrade});

  final int assignment;
  final CourseGrading course;
  final CourseGrading virtualized;
  final Function(CourseGrading) updateCallback;
  final bool orderByGrade;

  @override
  State<AssignmentDisplay> createState() => _AssignmentDisplayState();
}

String scoreToMark(double score, double total) {
  double value = score / total * 4;

  if (value >= 3.5) {
    return "A";
  } else if (value >= 3) {
    return "B";
  } else if (value >= 2.5) {
    return "C";
  } else if (value >= 2) {
    return "D";
  } else {
    return "F";
  }
}

class _AssignmentDisplayState extends State<AssignmentDisplay> {
  bool editing = false;

  @override
  Widget build(BuildContext context) {
    Assignment assignment = widget.course.assignments[widget.assignment];
    Assignment virtualAssignment =
        widget.virtualized.assignments[widget.assignment];

    return Column(children: [
      GestureDetector(
        onTap: () {
          setState(() {
            editing = !editing;
          });
        },
        child: Container(
          color: editing ? lightGrey : null,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Container(
              decoration: const BoxDecoration(
                border: BorderDirectional(
                  bottom: BorderSide(color: textColor, width: 0.1),
                  top: BorderSide(color: textColor, width: 0.1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      assignment.title,
                      style: bodyStyle,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      scoreToMark(assignment.score, assignment.total),
                      style: bodyStyle,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      (assignment.score / assignment.total * 4)
                          .toStringAsFixed(2),
                      style: bodyStyle,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
      if (editing)
        Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("0.0", style: smallBodyStyle),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: SliderTheme(
                      data: const SliderThemeData(
                        trackHeight: 0.5,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      ),
                      child: Slider(
                        inactiveColor: lightGrey,
                        activeColor: purpleGradient,
                        thumbColor: textColor,
                        value: assignment.score,
                        onChanged: (value) {
                          setState(() {
                            virtualAssignment.score = value;
                            widget.updateCallback(widget.virtualized);
                          });
                        },
                        min: 0,
                        max: assignment.total,
                      ),
                    ),
                  ),
                ),
                const Text("4.0", style: smallBodyStyle)
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Type: \n${assignment.type.title}",
                  style: smallBodyStyle, textAlign: TextAlign.center),
              Text(
                  "Virtual Grade: \n${(assignment.score / assignment.total * 4).toStringAsFixed(2)}",
                  style: smallBodyStyle,
                  textAlign: TextAlign.center),
              Text(
                  "Weight: \n${(assignment.type.weight * 100).toStringAsFixed(0)}%",
                  style: smallBodyStyle,
                  textAlign: TextAlign.center),
            ],
          ),
          const SizedBox(height: 20.0)
        ])
    ]);
  }
}

class ClassGradeDisplay extends StatelessWidget {
  const ClassGradeDisplay(
      {super.key, required this.course, required this.virtualized});

  final CourseGrading course;
  final CourseGrading virtualized;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        virtualized.courseTitle != ""
            ? ("${virtualized.grade.toStringAsFixed(2)}*")
            : course.grade.toStringAsFixed(2),
        style: titleStyle,
      ),
      const SizedBox(
        height: 10.0,
      ),
      Text(
        "Default: ${course.grade.toStringAsFixed(2)}",
        style: bodyStyle,
      ),
    ]);
  }
}

class ClassHeaderBar extends StatelessWidget {
  final String classTitle;
  final Function() exitCallback;

  const ClassHeaderBar(
      {super.key, required this.classTitle, required this.exitCallback});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: exitCallback,
              color: textColor,
            ),
          ),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            classTitle,
            style: boldSmallBodyStyle,
          ),
        ]),
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
  const GradebookDisplay({super.key, required this.selectedCourse});

  final Function(CourseGrading) selectedCourse;

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
        String title;

        if (getTitle.firstMatch(course.courseTitle) != null) {
          title = course.courseTitle.replaceFirst(
              getTitle.firstMatch(course.courseTitle)!.group(0).toString(), '');
        } else {
          title = course.courseTitle;
        }

        double grade = course.grade;

        if (grade > 10) grade /= 25;

        children.add(TableRow(
          children: [
            GestureDetector(
              onTap: () {
                widget.selectedCourse(course);
              },
              child: Padding(
                padding: textPadding,
                child: Text(title, style: bodyStyle),
              ),
            ),
            GestureDetector(
              onTap: () {
                widget.selectedCourse(course);
              },
              child: Padding(
                padding: textPadding,
                child: Text(parseGradeToLetter(grade), style: bodyStyle),
              ),
            ),
            GestureDetector(
              onTap: () {
                widget.selectedCourse(course);
              },
              child: Padding(
                padding: textPadding,
                child: Text(grade.toStringAsFixed(2),
                    style: bodyStyle, textAlign: TextAlign.right),
              ),
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
