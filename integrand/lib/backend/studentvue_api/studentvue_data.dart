/// This class is a wrapper for all the data classes that are used to store the data from the StudentVue API. 
library student_vue_data;

import 'package:flutter/material.dart';
import 'data_classes/data_classes.dart';
export 'data_classes/data_classes.dart';

class StudentVueData with ChangeNotifier {
  ScheduleData? scheduleData;
  GradebookData? gradebookData;
  StudentData? studentData;
  GPAData? gpaData;
  BellSchedule? bellSchedule;
  CourseHistory? courseHistory;
  // ========================
  StudentVueWebData currentWebData = StudentVueWebData();

  StudentVueData(StudentData this.studentData, ScheduleData this.scheduleData, GradebookData this.gradebookData, GPAData this.gpaData, BellSchedule this.bellSchedule, CourseHistory this.courseHistory);

  double calculateWeightedGPA(CourseHistory courseHistory) {
    // TODO: Include # of credits for each course to make this more accurate
    double totalWeightedGPA = 0;
    int totalWeightedCourses = 0;

    for (CourseEntry course in courseHistory.courses) {
      totalWeightedGPA += course.grade;
      if (course.isWeighted) {
        totalWeightedGPA++;
      }
      totalWeightedCourses++;
    }

    if (totalWeightedCourses == 0) {
      return 0;
    }

    return totalWeightedGPA / totalWeightedCourses;
  }

  double calculateUnweightedGPA(CourseHistory courseHistory) {
    double totalUnweightedGPA = 0;
    int totalUnweightedCourses = 0;

    for (CourseEntry course in courseHistory.courses) {
      totalUnweightedGPA += course.grade;
      totalUnweightedCourses++;
    }

    if (totalUnweightedCourses == 0) {
      return 0;
    }

    return totalUnweightedGPA / totalUnweightedCourses;
  }

  static int parseGrade(String grade) {
    if (grade == 'A') {
      return 4;
    } else if (grade == 'B') {
      return 3;
    } else if (grade == 'C') {
      return 2;
    } else if (grade == 'D') {
      return 1;
    } else if (grade == 'F') {
      return 0;
    } else {
      return 0;
    }
  }
}
