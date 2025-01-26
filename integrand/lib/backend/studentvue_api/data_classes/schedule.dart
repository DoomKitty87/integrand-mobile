/// This file contains all of the data classes related to scheduling.
/// This is exported to the rest of the app by data_classes.dart.
library data_classes.schedule;

class ClassPeriod {
  String courseTitle = '';
  String teacherName = '';
  String teacherEmail = '';
  /// Room contains 'Room' and room number
  String roomName = '';
  String periodNum = '';

  ClassPeriod();
  ClassPeriod.withValues({
    required this.courseTitle,
    required this.teacherName,
    required this.teacherEmail,
    required this.roomName,
    required this.periodNum,
  });
}

class ScheduleData {
  List<ClassPeriod> courses = [];
  bool error = false;

  ClassPeriod? getCourseByPeriod(String period) {
    for (var course in courses) {
      if (course.periodNum == period) {
        return course;
      }
    }
    return null;
  }

  ScheduleData();

  ScheduleData.testData() {
    courses = [
      ClassPeriod.withValues(
          courseTitle: 'AP Calculus BC',
          teacherName: 'Mr. Smith',
          teacherEmail: 'email@student.pps.net',
          roomName: '123',
          periodNum: '1'),
      ClassPeriod.withValues(
          courseTitle: 'AP Physics C',
          teacherName: 'Mr. Johnson',
          teacherEmail: 'email@student.pps.net',
          roomName: '456',
          periodNum: '2'),
      ClassPeriod.withValues(
          courseTitle: 'AP Computer Science A',
          teacherName: 'Mr. Doe',
          teacherEmail: 'email@student.pps.net',
          roomName: '789',
          periodNum: '3'),
      ClassPeriod.withValues(
          courseTitle: 'AP English Literature',
          teacherName: 'Ms. Smith',
          teacherEmail: 'email@student.pps.net',
          roomName: '101',
          periodNum: '4'),
      ClassPeriod.withValues(
          courseTitle: 'AP US History',
          teacherName: 'Mr. Johnson',
          teacherEmail: 'email@student.pps.net',
          roomName: '202',
          periodNum: '5'),
      ClassPeriod.withValues(
          courseTitle: 'AP Chemistry',
          teacherName: 'Mr. Doe',
          teacherEmail: 'email@student.pps.net',
          roomName: '303',
          periodNum: '6'),
      ClassPeriod.withValues(
          courseTitle: 'AP Spanish',
          teacherName: 'Ms. Smith',
          teacherEmail: 'email@student.pps.net',
          roomName: '404',
          periodNum: '7'),
      ClassPeriod.withValues(
          courseTitle: 'AP Art History',
          teacherName: 'Mr. Johnson',
          teacherEmail: 'email@student.pps.net',
          roomName: '505',
          periodNum: '8'),
    ];
  }
}