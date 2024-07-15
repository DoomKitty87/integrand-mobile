import 'dart:io';

import 'package:flutter/material.dart';
import 'package:integrand/app_page_tree/normal/main_pages/news.dart';

import '../helpers/time_of_day_helpers.dart';

class Course {
  String courseTitle = '';
  String teacher = '';
  String teacherEmail = '';
  String room = '';
  String period = '';
}

class ScheduleData {
  List<Course> courses = [];

  Course? getCourseByPeriod(String period) {
    for (var course in courses) {
      if (course.period == period) {
        return course;
      }
    }
    return null;
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
}

class AssignmentType {
  String title = '';
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
}

class GradebookData {
  List<CourseGrading> courses = [];
}

class GPAData {
  double unweightedGPA = 0.0;
  double weightedGPA = 0.0;

  int unweightedRank = 0;
  int weightedRank = 0;

  int totalStudents = 0;
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

  BellSchedule();
  BellSchedule.withValues({required this.periods});

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
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  String location = '';

  Event();

  Event.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    title = json['Title'];
    description = json['Description'];
    startDate = DateTime.parse(json['StartDate']);
    endDate = DateTime.parse(json['EndDate']);
    TimeOfDay startTime = TimeOfDay.fromDateTime(json['StartTime']);
    TimeOfDay endTime = TimeOfDay.fromDateTime(json['EndTime']);
    startDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );
    endDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );
    location = json['Location'];
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
  String image = '';
  DateTime releaseDate = DateTime.now();
  String content = 'Integrand is a new app that is designed to help students keep track of their grades, assignments, and more! We hope you enjoy using our app!';

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
    image = json['Image'];
    releaseDate = DateTime.parse(json['Date']);
    TimeOfDay releaseTime = timeOfDayFromJson(json['Time']);
    releaseDate = DateTime(
      releaseDate.year,
      releaseDate.month,
      releaseDate.day,
      releaseTime.hour,
      releaseTime.minute,
    );

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
