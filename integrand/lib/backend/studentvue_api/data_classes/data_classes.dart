import 'package:flutter/material.dart';

export 'schedule.dart';
export 'gradebook.dart';

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


