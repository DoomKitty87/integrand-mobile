import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import 'data_classes.dart';
import '../helpers/datetime_preparse_helpers.dart';

String parseWebServiceResponse(String body) {
  XmlDocument document = XmlDocument.parse(body);

  XmlElement element =
      document.findAllElements('ProcessWebServiceRequestResult').first;

  String result = element.innerText;

  return result;
}

StudentData parseStudent(http.Response response) {
  String body = response.body;

  body = parseWebServiceResponse(body);

  XmlDocument document = XmlDocument.parse(body);

  if (document.findAllElements('FormattedName').isEmpty) {
    StudentData data = StudentData();
    data.error = true;
    return data;
  }

  XmlElement name = document.findAllElements('FormattedName').first;
  XmlElement grade = document.findAllElements('Grade').first;
  XmlElement studentId = document.findAllElements('PermID').first;
  XmlElement school = document.findAllElements('CurrentSchool').first;
  XmlElement counselorName = document.findAllElements('CounselorName').first;
  XmlElement photo = document.findAllElements('Photo').first;

  StudentData data = StudentData();

  data.name = name.innerText;
  data.grade = int.parse(grade.innerText);
  data.studentId = int.parse(studentId.innerText);
  data.school = school.innerText;
  data.counselor = counselorName.innerText;
  data.photo = photo.innerText;

  XmlElement? lockerRecord =
      document.findAllElements('StudentLockerInfoRecord').firstOrNull;

  if (lockerRecord != null) {
    data.locker = lockerRecord.attributes
        .firstWhere((attribute) => attribute.name.local == 'LockerNumber')
        .value;

    data.lockerCombo = lockerRecord.attributes
        .firstWhere((attribute) => attribute.name.local == 'CurrentCombination')
        .value;
  }

  return data;
}

ScheduleData parseSchedule(http.Response response) {
  String body = response.body;

  body = parseWebServiceResponse(body);

  XmlDocument document = XmlDocument.parse(body);

  List<XmlElement> elements = document.findAllElements('ClassListing').toList();

  ScheduleData data = ScheduleData();

  for (XmlElement element in elements) {
    Course course = Course();

    course.courseTitle = element.attributes
        .firstWhere((attribute) => attribute.name.local == 'CourseTitle')
        .value;

    course.teacher = element.attributes
        .firstWhere((attribute) => attribute.name.local == 'Teacher')
        .value;

    course.teacherEmail = element.attributes
        .firstWhere((attribute) => attribute.name.local == 'TeacherEmail')
        .value;

    course.room = element.attributes
        .firstWhere((attribute) => attribute.name.local == 'RoomName')
        .value;

    course.period = element.attributes
        .firstWhere((attribute) => attribute.name.local == 'Period')
        .value;

    data.courses.add(course);
  }

  return data;
}

int getCurrentReportingPeriod(http.Response response) {
  String body = response.body;

  body = parseWebServiceResponse(body);

  XmlDocument document = XmlDocument.parse(body);

  List<XmlElement> elements = document.findAllElements('ReportPeriod').toList();

  int currentPeriod = -1;

  for (XmlElement element in elements) {
    String startDate = element.attributes
        .firstWhere((attribute) => attribute.name.local == 'StartDate')
        .value;

    startDate = parseXXSlashXXSlashXXXXIntoParsableByDateTime(startDate);
    if (DateTime.parse(startDate).isBefore(DateTime.now())) {
      currentPeriod++;
    }
  }

  return currentPeriod;
}

GradebookData parseGradebook(http.Response response) {
  String body = response.body;

  body = parseWebServiceResponse(body);

  XmlDocument document = XmlDocument.parse(body);

  List<XmlElement> courses = document.findAllElements('Course').toList();

  GradebookData data = GradebookData();

  if (courses.isEmpty) {
    data.error = true;
    return data;
  }

  for (XmlElement course in courses) {
    CourseGrading courseGrading = CourseGrading();

    courseGrading.courseTitle = course.attributes
        .firstWhere((attribute) => attribute.name.local == 'Title')
        .value;

    XmlElement mark = course.findAllElements('Mark').first;

    courseGrading.grade = double.parse(mark.attributes
        .firstWhere((attribute) => attribute.name.local == 'CalculatedScoreRaw')
        .value);

    List<XmlElement> assignmentTypes =
        mark.findAllElements('AssignmentGradeCalc').toList();

    for (XmlElement assignmentType in assignmentTypes) {
      AssignmentType type = AssignmentType(
        title: assignmentType.attributes
            .firstWhere((attribute) => attribute.name.local == 'Type')
            .value,
        weight: double.parse(assignmentType.attributes
                .firstWhere((attribute) => attribute.name.local == 'Weight')
                .value
                .replaceFirst('%', '')) /
            100,
      );

      type.points = double.parse(assignmentType.attributes
          .firstWhere((attribute) => attribute.name.local == 'Points')
          .value);

      type.total = double.parse(assignmentType.attributes
          .firstWhere((attribute) => attribute.name.local == 'PointsPossible')
          .value);

      courseGrading.assignmentTypes.add(type);
    }

    List<XmlElement> assignments = mark.findAllElements('Assignment').toList();

    for (XmlElement assignment in assignments) {
      Assignment a = Assignment();

      // Check if element has attributes
      if (assignment.attributes
          .where((attribute) => attribute.name.local == 'Measure')
          .isEmpty) {
        continue;
      }

      if (assignment.attributes
          .where((attribute) => attribute.name.local == 'Score')
          .isEmpty) {
        continue;
      }

      if (assignment.attributes
          .where((attribute) => attribute.name.local == 'ScoreType')
          .isEmpty) {
        continue;
      }

      if (assignment.attributes
          .where((attribute) => attribute.name.local == 'Points')
          .isEmpty) {
        continue;
      }

      a.title = assignment.attributes
          .firstWhere((attribute) => attribute.name.local == 'Measure')
          .value;

      String score = assignment.attributes
          .firstWhere((attribute) => attribute.name.local == 'Score')
          .value;

      String scoreType = assignment.attributes
          .firstWhere((attribute) => attribute.name.local == 'ScoreType')
          .value;

      String points = assignment.attributes
          .firstWhere((attribute) => attribute.name.local == 'Points')
          .value;

      if (score == 'Not Graded') {
        continue;
      }

      switch (scoreType) {
        case 'Percentage':
          a.score = double.parse(score.substring(0, score.length - 1));
          a.total = 100.0;
          break;
        case 'Raw Score':
          a.score = double.parse(score.split(' out of ')[0]);
          a.total = double.parse(score.split(' out of ')[1]);
          break;
        case '4pt Rubric':
          a.score = double.parse(score);
          a.total = 4.0;
          break;
        default:
          // TODO: Report to server so we can add any unknown score types
          break;
      }

      if (points == 'Dropped') {
        continue;
      }

      // Score is the teacher's grade given for the assignment
      // Points is the contribution the assignment makes to the grading category (Assignment Type)

      String type = assignment.attributes
          .firstWhere((attribute) => attribute.name.local == 'Type')
          .value;

      a.type = courseGrading.assignmentTypes
          .firstWhere((element) => element.title == type,
              orElse: () => AssignmentType(
                    title: 'Default',
                    weight: 1.0,
                  ));

      courseGrading.assignments.add(a);
    }

    data.courses.add(courseGrading);
  }

  return data;
}
