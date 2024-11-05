import 'dart:math';

import 'package:flutter/material.dart';
import 'package:integrand/backend/studentvue_api.dart';
import 'package:integrand/widget_templates.dart';
import 'package:provider/provider.dart';
import 'package:integrand/backend/data_classes.dart';
import 'package:integrand/main.dart';

import '../../../consts.dart';

class Gradebook extends StatefulWidget {
  const Gradebook({super.key});

  @override
  State<Gradebook> createState() => _GradebookState();
}

class _GradebookState extends State<Gradebook> {
  double realCourseGrade = 0;
  CourseGrading virtualCourse = CourseGrading();
  bool justUpdatedSlider = false;

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

      PageController controller;

      int selectedCourse = Provider.of<AppData>(context).selectedGradebookIndex;

      if (selectedCourse != -1) {
        if (!justUpdatedSlider) {
          virtualCourse = value.gradebookData.courses[selectedCourse].clone();
          realCourseGrade = virtualCourse.grade;
        }
        justUpdatedSlider = false;
        controller = PageController(initialPage: 1);
      } else {
        controller = PageController(initialPage: 0);
      }
      return PageView(
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: GPADisplay(),
                ),
                RecommendationsDisplay(courses: value.gradebookData.courses),
                GradebookDisplay(selectedCourse: (CourseGrading course) {
                  setState(() {
                    virtualCourse = course.clone();
                    realCourseGrade = virtualCourse.grade;
                  });
                  Provider.of<AppData>(context, listen: false)
                      .selectGradebookClass(value.gradebookData.courses
                          .indexWhere((element) => element == course));
                  controller.animateToPage(1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut);
                }),
              ],
            ),
            Column(children: [
              ClassHeaderBar(
                classTitle: virtualCourse.courseTitle,
                exitCallback: () {
                  Provider.of<AppData>(context, listen: false)
                      .selectGradebookClass(-1);
                  controller.animateToPage(0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut);
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              ClassGradeDisplay(
                  course: realCourseGrade, virtualized: virtualCourse.grade),
              const SizedBox(
                height: 40.0,
              ),
              Expanded(
                child: ClassGradeCalculator(
                  virtualized: virtualCourse,
                  updateCallback: (CourseGrading course) {
                    setState(() {
                      virtualCourse = course;
                      virtualCourse.calculateGrade();
                      justUpdatedSlider = true;
                    });
                  },
                ),
              ),
            ])
          ]);
    });
  }
}

class Recommendation {
  final double percent;
  final double courseGradeIfZero;
  final double courseGradeIfMax;
  final String title;
  final String courseTitle;
  final double classGradeMaxImprovement;

  Recommendation({
    required this.percent,
    required this.courseGradeIfZero,
    required this.courseGradeIfMax,
    required this.title,
    required this.courseTitle,
    required this.classGradeMaxImprovement,
  });
}

class RecommendationsDisplay extends StatelessWidget {
  const RecommendationsDisplay({super.key, required this.courses});

  final List<CourseGrading> courses;

  @override
  Widget build(BuildContext context) {
    final List<Recommendation> recommendations = [];

    for (var course in courses) {
      double totalTotalPoints = 0;
      for (var assignment in course.assignments) {
        totalTotalPoints += assignment.totalPoints * assignment.type.weight;
      }
      for (var assignment in course.assignments) {
        double maxImprovement = assignment.totalPoints - assignment.points;
        double classGradeMaxImprovement =
            maxImprovement / totalTotalPoints * 4.0 * assignment.type.weight;

        if (classGradeMaxImprovement >= 0.1) {
          double courseGradeIfZero = course.grade -
              assignment.points /
                  totalTotalPoints *
                  4.0 *
                  assignment.type.weight;
          double courseGradeIfMax = course.grade + classGradeMaxImprovement;

          double percent = assignment.score / assignment.total;

          recommendations.add(Recommendation(
              percent: percent,
              courseGradeIfZero: courseGradeIfZero,
              courseGradeIfMax: courseGradeIfMax,
              title: assignment.title,
              courseTitle: course.courseTitle,
              classGradeMaxImprovement: classGradeMaxImprovement));
        }
      }
    }

    recommendations.sort((a, b) {
      return a.classGradeMaxImprovement.compareTo(b.classGradeMaxImprovement);
    });

    List<Widget> recommendationsWidgets = [];

    for (var recommendation in recommendations) {
      recommendationsWidgets.add(Padding(
        padding: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
        child: SizedBox(
            height: 40,
            child:
                Stack(alignment: AlignmentDirectional.centerStart, children: [
              Row(
                children: [
                  Expanded(
                    flex: (recommendation.percent * 100).toInt(),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: textGradient,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 100 - (recommendation.percent * 100).toInt(),
                    child: Container(color: background3),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(recommendation.courseGradeIfZero.toStringAsFixed(2),
                        style: boldSmallBodyStyle),
                    Text(
                        "${recommendation.title} - ${recommendation.courseTitle}",
                        style: smallBodyStyle),
                    Text(recommendation.courseGradeIfMax.toStringAsFixed(2),
                        style: boldSmallBodyStyle),
                  ],
                ),
              )
            ])),
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: background2),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 8.0),
                child: Text("Suggested Retakes", style: boldBodyStyle),
              ),
              Expanded(child: ListView(children: recommendationsWidgets)),
            ],
          )),
    );
  }
}

class ClassGradeCalculator extends StatefulWidget {
  const ClassGradeCalculator(
      {super.key, required this.virtualized, required this.updateCallback});

  final CourseGrading virtualized;
  final Function(CourseGrading) updateCallback;

  @override
  State<ClassGradeCalculator> createState() => _ClassGradeCalculatorState();
}

class _ClassGradeCalculatorState extends State<ClassGradeCalculator> {
  bool orderByGrade = false;

  @override
  Widget build(BuildContext context) {
    if (orderByGrade) {
      widget.virtualized.assignments.sort((a, b) {
        double aGrade = a.score / a.total * 4;
        double bGrade = b.score / b.total * 4;

        return aGrade.compareTo(bGrade);
      });
    } else {
      widget.virtualized.assignments.sort((b, a) {
        return a.impact.compareTo(b.impact);
      });
    }

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        GestureDetector(
          child: Container(
            decoration: BoxDecoration(
              color: orderByGrade ? background2 : null,
              gradient: orderByGrade ? null : textGradient,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: textWhite, width: 0.1),
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
              color: orderByGrade ? null : background2,
              gradient: orderByGrade ? textGradient : null,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: textWhite, width: 0.1),
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
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: ListView(
            children: [
              for (int assignment = 0;
                  assignment < widget.virtualized.assignments.length;
                  assignment++)
                AssignmentDisplay(
                  assignment: assignment,
                  virtualized: widget.virtualized,
                  updateCallback: widget.updateCallback,
                  orderByGrade: orderByGrade,
                ),
            ],
          ),
        ),
      ),
    ]);
  }
}

class AssignmentDisplay extends StatefulWidget {
  const AssignmentDisplay(
      {super.key,
      required this.assignment,
      required this.virtualized,
      required this.updateCallback,
      required this.orderByGrade});

  final int assignment;
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
  double score = -1;

  @override
  Widget build(BuildContext context) {
    Assignment virtualAssignment =
        widget.virtualized.assignments[widget.assignment];

    if (score != -1) {
      virtualAssignment.score = score;
    }

    return ExpandableListItem(
      unexpandedHeight: 50,
      expandedHeight: 160,
      highlighted: score != -1,
      expandedChild: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
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
                        trackShape: GradientRectSliderTrackShape()),
                    child: Slider(
                      inactiveColor: background2,
                      activeColor: purpleGradient,
                      thumbColor: textWhite,
                      value:
                          min(virtualAssignment.score, virtualAssignment.total),
                      onChanged: (value) {
                        setState(() {
                          virtualAssignment.points = value /
                              virtualAssignment.total *
                              virtualAssignment.totalPoints;
                          score = value;
                          widget.updateCallback(widget.virtualized);
                        });
                      },
                      min: 0,
                      max: virtualAssignment.total,
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
            Text("Type: \n${virtualAssignment.type.title}",
                style: smallBodyStyle, textAlign: TextAlign.center),
            Text(
                "Virtual Grade: \n${(virtualAssignment.score / virtualAssignment.total * 4).toStringAsFixed(2)}",
                style: smallBodyStyle,
                textAlign: TextAlign.center),
            Text(
                "Weight: \n${(virtualAssignment.type.weight * 100).toStringAsFixed(0)}%",
                style: smallBodyStyle,
                textAlign: TextAlign.center),
          ],
        ),
      ]),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            Expanded(
              flex: 4,
              child: Text(
                virtualAssignment.title,
                style: bodyStyle,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                scoreToMark(virtualAssignment.score, virtualAssignment.total),
                style: bodyStyle,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                (virtualAssignment.score / virtualAssignment.total * 4)
                    .toStringAsFixed(2),
                style: bodyStyle,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class GradientRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  /// Create a slider track that draws two rectangles with rounded outer edges.
  const GradientRectSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting can be a no-op.
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    LinearGradient gradient = const LinearGradient(
      colors: <Color>[blueGradient, purpleGradient],
    );

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeGradientRect = Rect.fromLTRB(
      trackRect.left,
      (textDirection == TextDirection.ltr)
          ? trackRect.top - (additionalActiveTrackHeight / 2)
          : trackRect.top,
      thumbCenter.dx,
      (textDirection == TextDirection.ltr)
          ? trackRect.bottom + (additionalActiveTrackHeight / 2)
          : trackRect.bottom,
    );

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..shader = gradient.createShader(activeGradientRect)
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final (Paint leftTrackPaint, Paint rightTrackPaint) =
        switch (textDirection) {
      TextDirection.ltr => (activePaint, inactivePaint),
      TextDirection.rtl => (inactivePaint, activePaint),
    };

    final Radius trackRadius = Radius.circular(trackRect.height / 2);
    final Radius activeTrackRadius =
        Radius.circular((trackRect.height + additionalActiveTrackHeight) / 2);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        (textDirection == TextDirection.ltr)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
        bottomLeft: (textDirection == TextDirection.ltr)
            ? activeTrackRadius
            : trackRadius,
      ),
      leftTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        topRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
        bottomRight: (textDirection == TextDirection.rtl)
            ? activeTrackRadius
            : trackRadius,
      ),
      rightTrackPaint,
    );

    final bool showSecondaryTrack = (secondaryOffset != null) &&
        ((textDirection == TextDirection.ltr)
            ? (secondaryOffset.dx > thumbCenter.dx)
            : (secondaryOffset.dx < thumbCenter.dx));

    if (showSecondaryTrack) {
      final ColorTween secondaryTrackColorTween = ColorTween(
          begin: sliderTheme.disabledSecondaryActiveTrackColor,
          end: sliderTheme.secondaryActiveTrackColor);
      final Paint secondaryTrackPaint = Paint()
        ..color = secondaryTrackColorTween.evaluate(enableAnimation)!;
      if (textDirection == TextDirection.ltr) {
        context.canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            thumbCenter.dx,
            trackRect.top,
            secondaryOffset.dx,
            trackRect.bottom,
            topRight: trackRadius,
            bottomRight: trackRadius,
          ),
          secondaryTrackPaint,
        );
      } else {
        context.canvas.drawRRect(
          RRect.fromLTRBAndCorners(
            secondaryOffset.dx,
            trackRect.top,
            thumbCenter.dx,
            trackRect.bottom,
            topLeft: trackRadius,
            bottomLeft: trackRadius,
          ),
          secondaryTrackPaint,
        );
      }
    }
  }
}

class ClassGradeDisplay extends StatelessWidget {
  const ClassGradeDisplay(
      {super.key, required this.course, required this.virtualized});

  final double course;
  final double virtualized;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        virtualized.toStringAsFixed(2),
        style: titleStyle,
      ),
      const SizedBox(
        height: 10.0,
      ),
      Text(
        "Actual: ${course.toStringAsFixed(2)}",
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
              color: textWhite,
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
                gpa.toStringAsFixed(2),
                style: titleStyle,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Unweighted ${uw.toStringAsFixed(2)}",
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
  if (grade == -1) {
    return "N/A";
  }
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
  final List<Widget> children = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentVueAPI>(builder: (context, value, child) {
      return Expanded(
        child: ListView.builder(
          itemCount: value.gradebookData.courses.length,
          itemBuilder: (context, index) {
            CourseGrading course = value.gradebookData.courses[index];

            RegExp getTitle = RegExp(r" [(](.*?)[)]");
            String title;

            if (getTitle.firstMatch(course.courseTitle) != null) {
              title = course.courseTitle.replaceFirst(
                  getTitle.firstMatch(course.courseTitle)!.group(0).toString(),
                  '');
            } else {
              title = course.courseTitle;
            }

            double grade = course.grade;

            if (course.assignments.isEmpty) {
              grade = -1;
            }

            if (grade > 10) grade /= 25;

            return GestureDetector(
              onTap: () {
                widget.selectedCourse(value.gradebookData.courses[index]);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: NonExpandableListItem(
                  height: 50,
                  child: Container(
                    color: background1,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(title, style: bodyStyle),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(parseGradeToLetter(grade),
                                style: bodyStyle),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                                grade == -1 ? "" : grade.toStringAsFixed(2),
                                style: bodyStyle,
                                textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
