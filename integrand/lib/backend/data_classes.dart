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
  String period = '';
  TimeOfDay startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 0, minute: 0);
  bool beforePeriod(TimeOfDay now) {
    return toMinutesTimeOfDay(now) < toMinutesTimeOfDay(startTime);
  }
  bool withinPeriod(TimeOfDay now) {
    return isBetweenTimeOfDay(startTime, endTime, now);
  }
  bool afterPeriod(TimeOfDay now) {
    return toMinutesTimeOfDay(endTime) < toMinutesTimeOfDay(now);
  }
}

class BellSchedule {
  List<BellPeriod> periods = [];

  BellPeriod? getCurrentPeriod(TimeOfDay now) {
    for (var period in periods) {
      if (period.withinPeriod(now) == false) {
        continue;
      } 
      return period;
    }
    return null;
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
}