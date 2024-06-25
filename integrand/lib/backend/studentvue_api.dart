import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

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

class StudentVueAPI with ChangeNotifier {
  late String baseUrl;
  late String username;
  late String password;

  bool initialized = false;

  late ScheduleData scheduleData;
  late GradebookData gradebookData;

  StudentVueAPI();

  void initialize(String baseUrl, String username, String password) {
    this.baseUrl = baseUrl;
    this.username = username;
    this.password = password;
    initialized = true;
    notifyListeners();
  }

  Future<http.Response> schedule() async {
    if (!initialized) {
      throw Exception('StudentVueAPI not initialized');
    }
    String url = '$baseUrl/Service/PXPCommunication.asmx';

    Uri uri = Uri.parse(url);

    String xml =
        '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/"><userID>$username</userID><password>$password</password><skipLoginLog>1</skipLoginLog><parent>0</parent><webServiceHandleName>PXPWebServices</webServiceHandleName><methodName>StudentClassList</methodName><paramStr>&lt;Parms&gt;&lt;childIntID&gt;0&lt;/childIntID&gt; &lt;TermIndex&gt;1&lt;/TermIndex&gt; &lt;/Parms&gt;</paramStr></ProcessWebServiceRequest></soap:Body></soap:Envelope>';

    http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'text/xml',
        'SOAPAction':
            'http://edupoint.com/webservices/ProcessWebServiceRequest',
      },
      body: xml,
    );

    return response;
  }

  Future<http.Response> gradebook() async {
    if (!initialized) {
      throw Exception('StudentVueAPI not initialized');
    }

    String url = '$baseUrl/Service/PXPCommunication.asmx';

    Uri uri = Uri.parse(url);

    String xml =
        '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/"><userID>$username</userID><password>$password</password><skipLoginLog>1</skipLoginLog><parent>0</parent><webServiceHandleName>PXPWebServices</webServiceHandleName><methodName>Gradebook</methodName><paramStr>&lt;Parms&gt;&lt;ChildIntID&gt;0&lt;/ChildIntID&gt;&lt;/Parms&gt;</paramStr></ProcessWebServiceRequest></soap:Body></soap:Envelope>';

    http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'text/xml',
        'SOAPAction':
            'http://edupoint.com/webservices/ProcessWebServiceRequest',
      },
      body: xml,
    );

    return response;
  }

  Future<http.Response> gradebookPeriod(int reportingPeriod) async {
    if (!initialized) {
      throw Exception('StudentVueAPI not initialized');
    }

    String url = '$baseUrl/Service/PXPCommunication.asmx';

    Uri uri = Uri.parse(url);

    String xml =
        '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/"><userID>$username</userID><password>$password</password><skipLoginLog>1</skipLoginLog><parent>0</parent><webServiceHandleName>PXPWebServices</webServiceHandleName><methodName>Gradebook</methodName><paramStr>&lt;Parms&gt;&lt;ChildIntID&gt;0&lt;/ChildIntID&gt;&lt;ReportPeriod&gt;$reportingPeriod&lt;/ReportPeriod&gt;&lt;/Parms&gt;</paramStr></ProcessWebServiceRequest></soap:Body></soap:Envelope>';

    http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'text/xml',
        'SOAPAction':
            'http://edupoint.com/webservices/ProcessWebServiceRequest',
      },
      body: xml,
    );

    return response;
  }

  Future<GradebookData> updateGrades() async {
    http.Response response = await gradebook();

    int currentPeriod = getCurrentReportingPeriod(response);

    response = await gradebookPeriod(currentPeriod);

    gradebookData = parseGradebook(response);

    return gradebookData;
  }

  Future<ScheduleData> updateSchedule() async {
    http.Response response = await schedule();

    scheduleData = parseSchedule(response);

    return scheduleData;
  }

  static String parseWebServiceResponse(String body) {
    XmlDocument document = XmlDocument.parse(body);

    XmlElement element =
        document.findAllElements('ProcessWebServiceRequestResult').first;

    String result = element.innerText;

    return result;
  }

  static ScheduleData parseSchedule(http.Response response) {
    String body = response.body;

    body = parseWebServiceResponse(body);

    XmlDocument document = XmlDocument.parse(body);

    List<XmlElement> elements =
        document.findAllElements('ClassListing').toList();

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

  static int getCurrentReportingPeriod(http.Response response) {
    String body = response.body;

    body = parseWebServiceResponse(body);

    XmlDocument document = XmlDocument.parse(body);

    List<XmlElement> elements =
        document.findAllElements('ReportPeriod').toList();

    int currentPeriod = 0;

    for (XmlElement element in elements) {
      String startDate = element.attributes
          .firstWhere((attribute) => attribute.name.local == 'StartDate')
          .value;

      if (DateTime.parse(startDate).isBefore(DateTime.now())) {
        currentPeriod++;
      }
    }

    return currentPeriod;
  }

  static GradebookData parseGradebook(http.Response response) {
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
          .firstWhere(
              (attribute) => attribute.name.local == 'CalculatedScoreRaw')
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
              .value),
        );

        type.points = double.parse(assignmentType.attributes
            .firstWhere((attribute) => attribute.name.local == 'Points')
            .value);

        type.total = double.parse(assignmentType.attributes
            .firstWhere((attribute) => attribute.name.local == 'PointsPossible')
            .value);

        courseGrading.assignmentTypes.add(type);
      }

      List<XmlElement> assignments =
          mark.findAllElements('Assignment').toList();

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

        a.score = scoreType == 'Percent'
            ? double.parse(score.substring(0, score.length - 1))
            : double.parse(score.split(' out of ')[0]);

        a.total = scoreType == 'Percent'
            ? 100.0
            : double.parse(score.split(' out of ')[1]);

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
}
