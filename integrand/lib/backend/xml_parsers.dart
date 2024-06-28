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

  XmlElement name = document.findAllElements('FormattedName').first;
  XmlElement grade = document.findAllElements('Grade').first;
  XmlElement studentId = document.findAllElements('PermID').first;
  XmlElement school = document.findAllElements('CurrentSchool').first;

  StudentData data = StudentData();

  data.name = name.innerText;
  data.grade = int.parse(grade.innerText);
  data.studentId = int.parse(studentId.innerText);
  data.school = school.innerText;

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

      a.score = scoreType == 'Percentage'
          ? double.parse(score.substring(0, score.length - 1))
          : double.parse(score.split(' out of ')[0]);

      a.total = scoreType == 'Percentage'
          ? 100.0
          : double.parse(score.split(' out of ')[1]);

      if (points == 'Dropped') {
        continue;
      }

      a.points = double.parse(points.split(' / ')[0]);
      a.totalPoints = double.parse(points.split(' / ')[1]);

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
