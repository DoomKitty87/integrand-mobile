import 'dart:io';

import 'package:flutter/material.dart';
import 'package:integrand/app_page_tree/normal/main_pages/news.dart';

import '../helpers/time_of_day_helpers.dart';

class Course {
  String courseTitle = '';
  String teacher = '';
  String teacherEmail = '';
  // Room contains 'Room' and room number
  String room = '';
  String period = '';

  Course();
  Course.withValues(
    {
      required this.courseTitle,
      required this.teacher,
      required this.teacherEmail,
      required this.room,
      required this.period
    }
  );
}

class ScheduleData {
  List<Course> courses = [];
  bool error = false;

  Course? getCourseByPeriod(String period) {
    for (var course in courses) {
      if (course.period == period) {
        return course;
      }
    }
    return null;
  }

  ScheduleData();

  ScheduleData.testData() {
    courses = [
      Course.withValues(
        courseTitle: 'AP Calculus BC',
        teacher: 'Mr. Smith',
        teacherEmail: 'email@student.pps.net',
        room: 'Room 123',
        period: '1'
      ),
      Course.withValues(
        courseTitle: 'AP Physics C',
        teacher: 'Mr. Johnson',
        teacherEmail: 'email@student.pps.net',
        room: 'Room 456',
        period: '2'
      ),
      Course.withValues(
        courseTitle: 'AP Computer Science A',
        teacher: 'Mr. Doe',
        teacherEmail: 'email@student.pps.net',
        room: 'Room 789',
        period: '3'
      ),
      Course.withValues(
        courseTitle: 'AP English Literature',
        teacher: 'Ms. Smith',
        teacherEmail: 'email@student.pps.net',
        room: 'Room 101',
        period: '4'
      ),
      Course.withValues(
        courseTitle: 'AP US History',
        teacher: 'Mr. Johnson',
        teacherEmail: 'email@student.pps.net',
        room: 'Room 202',
        period: '5'
      ),
      Course.withValues(
        courseTitle: 'AP Chemistry',
        teacher: 'Mr. Doe',
        teacherEmail: 'email@student.pps.net',
        room: 'Room 303',
        period: '6'
      ),
      Course.withValues(
        courseTitle: 'AP Spanish',
        teacher: 'Ms. Smith',
        teacherEmail: 'email@student.pps.net',
        room: 'Room 404',
        period: '7'
      ),
      Course.withValues(
        courseTitle: 'AP Art History',
        teacher: 'Mr. Johnson',
        teacherEmail: 'email@student.pps.net',
        room: 'Room 505',
        period: '8'
      ),
    ];
  }
}

class Assignment {
  String title = '';
  double score = 0.0;
  double total = 0.0;

  double points = 0.0;
  double totalPoints = 0.0;

  AssignmentType type = AssignmentType(
    title: 'Default',
    weight: 1.0,
  );

  Assignment();

  Assignment.withValues(
    {
      required this.title,
      required this.score,
      required this.total,
      required this.type,
    }
  );

  Assignment.testData(
    {
      this.title = 'Test Assignment',
      this.score = 90.0,
      this.total = 100.0,
    }
  );
}

class AssignmentType {
  // eg. summative, formative, etc.
  String title = '';
  // weighted value of the assignment
  double weight = 0.0;

  double points = 0.0;
  double total = 0.0;

  AssignmentType({
    required this.title,
    required this.weight,
  });
}

class CourseGrading {
  String courseTitle = '';
  double grade = 0.0;
  List<AssignmentType> assignmentTypes = [];
  List<Assignment> assignments = [];

  CourseGrading();

  CourseGrading.testData() {
    courseTitle = 'AP Calculus BC';
    grade = 95.0;
    assignmentTypes = [
      AssignmentType(
        title: 'Summative',
        weight: 0.6,
      ),
      AssignmentType(
        title: 'Formative',
        weight: 0.4,
      ),
    ];
    assignments = [
      Assignment.withValues(
        title: 'Test 1',
        score: 90.0,
        total: 100.0,
        type: assignmentTypes[0],
      ),
      Assignment.withValues(
        title: 'Quiz 1',
        score: 95.0,
        total: 100.0,
        type: assignmentTypes[1],
      ),
      Assignment.withValues(
        title: 'Test 2',
        score: 100.0,
        total: 100.0,
        type: assignmentTypes[0],
      ),
      Assignment.withValues(
        title: 'Quiz 2',
        score: 85.0,
        total: 100.0,
        type: assignmentTypes[1],
      ),
    ];
  }
}

class GradebookData {
  List<CourseGrading> courses = [];
  bool error = false;

  GradebookData();

  GradebookData.testData() {
    courses = [
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
      CourseGrading.testData(),
    ];
  }
}

class GPAData {
  double unweightedGPA = 0.0;
  double weightedGPA = 0.0;

  int unweightedRank = 0;
  int weightedRank = 0;

  int totalStudents = 0;

  bool error = false;

  GPAData();

  GPAData.testData() {
    unweightedGPA = 4.0;
    weightedGPA = 4.2;

    unweightedRank = 1;
    weightedRank = 1;

    totalStudents = 100;
  }
}

class BellPeriod {
  String periodName = '';
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 0, minute: 0);

  BellPeriod();
  BellPeriod.withValues(
      {required this.periodName,
      required this.startTime,
      required this.endTime});

  bool willStartAfter(TimeOfDay time) {
    return toMinutesTimeOfDay(time) < toMinutesTimeOfDay(startTime);
  }

  bool isHappening(TimeOfDay time) {
    return isBetweenTimeOfDayInclusive(startTime, endTime, time);
  }

  bool endedBefore(TimeOfDay time) {
    return toMinutesTimeOfDay(endTime) < toMinutesTimeOfDay(time);
  }
}

class BellSchedule {
  List<BellPeriod> periods = [];
  bool error = false;

  BellSchedule();
  BellSchedule.withValues({required this.periods});
  BellSchedule.testDataA() {
    periods = [
      BellPeriod.withValues(
        periodName: "1",
        startTime: const TimeOfDay(hour: 8, minute: 30),
        endTime: const TimeOfDay(hour: 10, minute: 2)
      ),
      BellPeriod.withValues(
        periodName: "2",
        startTime: const TimeOfDay(hour: 10, minute: 9),
        endTime: const TimeOfDay(hour: 11, minute: 41)
      ),
      BellPeriod.withValues(
        periodName: "Lunch",
        startTime: const TimeOfDay(hour: 11, minute: 41),
        endTime: const TimeOfDay(hour: 12, minute: 14)
      ),
      BellPeriod.withValues(
        periodName: "3",
        startTime: const TimeOfDay(hour: 12, minute: 19),
        endTime: const TimeOfDay(hour: 13, minute: 51)
      ),
      BellPeriod.withValues(
        periodName: "4",
        startTime: const TimeOfDay(hour: 13, minute: 58),
        endTime: const TimeOfDay(hour: 15, minute: 30)
      ),
    ];
  }

  BellSchedule.testDataB() {
    periods = [
      BellPeriod.withValues(
        periodName: "5",
        startTime: const TimeOfDay(hour: 8, minute: 30),
        endTime: const TimeOfDay(hour: 10, minute: 2)
      ),
      BellPeriod.withValues(
        periodName: "6",
        startTime: const TimeOfDay(hour: 10, minute: 9),
        endTime: const TimeOfDay(hour: 11, minute: 41)
      ),
      BellPeriod.withValues(
        periodName: "Lunch",
        startTime: const TimeOfDay(hour: 11, minute: 41),
        endTime: const TimeOfDay(hour: 12, minute: 14)
      ),
      BellPeriod.withValues(
        periodName: "7",
        startTime: const TimeOfDay(hour: 12, minute: 19),
        endTime: const TimeOfDay(hour: 13, minute: 51)
      ),
      BellPeriod.withValues(
        periodName: "8",
        startTime: const TimeOfDay(hour: 13, minute: 58),
        endTime: const TimeOfDay(hour: 15, minute: 30)
      ),
    ];
  }



  BellPeriod? getCurrentPeriod(TimeOfDay now) {
    for (var period in periods) {
      if (period.isHappening(now) == true) {
        return period;
      }
    }
    return null;
  }

  BellPeriod? getPreviousPeriod(TimeOfDay now) {
    if (periods.isEmpty) return null;

    BellPeriod? lastPeriod;
    for (int i = 0; i < periods.length; i++) {
      if (periods[i].endedBefore(now)) {
        lastPeriod = periods[i];
      }
    }
    return lastPeriod;
  }

  BellPeriod? getNextPeriod(TimeOfDay now) {
    if (periods.isEmpty) return null;

    for (int i = 0; i < periods.length; i++) {
      if (periods[i].willStartAfter(now)) {
        return periods[i];
      }
    }
    return null;
  }

  (bool, BellPeriod?, BellPeriod?) isPassingPeriod(TimeOfDay now) {
    if (periods.isEmpty) return (false, null, null);

    // If within period check
    for (var period in periods) {
      if (period.isHappening(now)) {
        return (false, null, null);
      }
    }

    // If after or before school
    if (isOutsideSchoolHours(now)) {
      return (false, null, null);
    }

    return (true, getPreviousPeriod(now), getNextPeriod(now));
  }

  bool isOutsideSchoolHours(TimeOfDay now) {
    if (periods.isEmpty) return true;

    if (periods.first.willStartAfter(now) || periods.last.endedBefore(now)) {
      return true;
    }
    return false;
  }
}

class CourseEntry {
  String courseTitle = '';
  int grade = 0;
  bool isWeighted = false;
}

class CourseHistory {
  List<CourseEntry> courses = [];
  bool error = false;
}

class StudentVueWebData {
  String courseHistory = '';
  String classSchedule = '';
}

class StudentData {
  String name = '';
  int grade = 0;
  int studentId = 0;
  String school = '';
  String locker = '';
  String lockerCombo = '';
  String counselor = '';
  String photo = '';
  bool error = false;
}

class School {
  int id = 0;
  String name = '';
  String district = '';

  School();

  // Decode json object into School object
  School.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    name = json['SchoolName'];
    district = json['DistrictName'];
  }
}

class Event {
  int id = 0;
  String title = '';
  String description = '';
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  String location = '';
  int type = 0;

  Event();

  Event.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    title = json['Title'];
    description = json['Description'];
    startTime = DateTime.fromMillisecondsSinceEpoch(json['StartTime'] * 1000);
    endTime = DateTime.fromMillisecondsSinceEpoch(json['EndTime'] * 1000);
    location = json['Location'];
    type = json['Type'];
  }
}

TimeOfDay timeOfDayFromJson(String time) {
  List<String> timeParts = time.split(':');
  return TimeOfDay(
    hour: int.parse(timeParts[0]),
    minute: int.parse(timeParts[1]),
  );
}

class NewsArticle {
  int id = 0;
  String title = 'Welcome To Integrand!';
  Image? image;
  DateTime releaseDate = DateTime.now();
  String content =
      'Integrand is a new app that is designed to help students keep track of their grades, assignments, and more! We hope you enjoy using our app!';

  bool sameReleaseDateAs(NewsArticle other) {
    return releaseDate.year == other.releaseDate.year &&
        releaseDate.month == other.releaseDate.month &&
        releaseDate.day == other.releaseDate.day;
  }

  String getDateString({bool includeYear = false}) {
    if (includeYear) {
      return '${weekdayToName(releaseDate.weekday)}, ${monthToName(releaseDate.month)} ${numberWithSuffix(releaseDate.day)} ${releaseDate.year}';
    }
    return '${weekdayToName(releaseDate.weekday)}, ${monthToName(releaseDate.month)} ${numberWithSuffix(releaseDate.day)}';
  }

  NewsArticle();

  NewsArticle.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    title = json['Title'];
    if (json['Image'] != "") {
      try {
        image = Image.network("https://integrand.app/cdn/${json['Image']}",
            fit: BoxFit.contain);
      } on NetworkImageLoadException {
        image = null;
      }
    } else {
      image = null;
    }
    releaseDate = DateTime.fromMillisecondsSinceEpoch(json['EpochTime']);
    content = json['Content'];
  }

  int compareTo(NewsArticle other) {
    // check for date
    if (releaseDate.isBefore(other.releaseDate)) {
      return -1;
    } else if (releaseDate.isAfter(other.releaseDate)) {
      return 1;
    }
    return 0;
  }
}
