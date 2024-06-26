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
}

class BellSchedule {
  List<BellPeriod> periods = [];
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

class StudentVueAPI with ChangeNotifier {
  late String baseUrl;
  late String username;
  late String password;

  bool initialized = false;

  ScheduleData scheduleData = ScheduleData();
  GradebookData gradebookData = GradebookData();

  GPAData gpaData = GPAData();
  BellSchedule bellSchedule = BellSchedule();
  CourseHistory courseHistory = CourseHistory();

  String currentCookies = '';

  StudentVueWebData currentWebData = StudentVueWebData();

  StudentVueAPI();

  void initialize(String baseUrl, String username, String password) async {
    this.baseUrl = baseUrl;
    this.username = username;
    this.password = password;
    initialized = true;

    // Should call data updates here
    await updateGrades();
    await updateSchedule();

    // Updates for data not accessible via SOAP API
    await initializeClientData();

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

  Future<void> initializeClientData() async {
    // Send GET request to get cookies
    String url = '$baseUrl/PXP2_Login_Student.aspx?regenerateSessionId=True';

    http.Response response = await http.get(Uri.parse(url));

    List<String> cookiesList = response.headers['set-cookie']!.split(',');

    Map<String, String> cookies = <String, String>{};

    for (String cookie in cookiesList) {
      List<String> cookieParts = cookie.split('=');
      if (cookieParts.length == 1) {
        continue;
      }
      cookies.update(cookieParts[0], (value) => cookieParts[1],
          ifAbsent: () => cookieParts[1]);
    }

    Map<String, String> loginData = <String, String>{};

    String html = response.body;

    RegExp viewStateRegExp = RegExp(
        r'<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="(.*?)" />');

    String viewState = viewStateRegExp.firstMatch(html)!.group(1)!;

    RegExp viewStateGeneratorRegExp = RegExp(
        r'<input type="hidden" name="__VIEWSTATEGENERATOR" id="__VIEWSTATEGENERATOR" value="(.*?)" />');

    String viewStateGenerator =
        viewStateGeneratorRegExp.firstMatch(html)!.group(1)!;

    RegExp eventValidationRegExp = RegExp(
        r'<input type="hidden" name="__EVENTVALIDATION" id="__EVENTVALIDATION" value="(.*?)" />');

    String eventValidation = eventValidationRegExp.firstMatch(html)!.group(1)!;

    loginData['__VIEWSTATE'] = viewState;
    loginData['__VIEWSTATEGENERATOR'] = viewStateGenerator;
    loginData['__EVENTVALIDATION'] = eventValidation;

    loginData['ctl00\$MainContent\$username'] = username;
    loginData['ctl00\$MainContent\$password'] = password;
    loginData['ctl00\$MainContent\$Submit1'] = 'Login';

    String cookiesString = '';

    cookies.forEach((key, value) {
      cookiesString += '$key=$value; ';
    });

    // Send login POST request

    await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': cookiesString,
      },
      body: loginData,
    );

    currentCookies = cookiesString;

    // Logged in, complete all necessary data requests

    await requestStudentVueWebData();

    GPAData gpaData = updateGPA();

    this.gpaData = gpaData;

    BellSchedule bellSchedule = updateCurrentBellSchedule();

    this.bellSchedule = bellSchedule;

    CourseHistory courseHistory = updateCourseHistory();

    this.courseHistory = courseHistory;
  }

  Future<void> requestStudentVueWebData() async {
    String url = '$baseUrl/PXP2_CourseHistory.aspx?AGU=0';

    http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Cookie': currentCookies,
      },
    );

    currentWebData.courseHistory = removeWhitespace(response.body);

    url = '$baseUrl/PXP2_ClassSchedule.aspx?AGU=0';

    response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Cookie': currentCookies,
      },
    );

    currentWebData.classSchedule = removeWhitespace(response.body);
  }

  String removeWhitespace(String html) {
    return html
        .replaceAll('\n', '')
        .replaceAll(' ', '')
        .replaceAll('\t', '')
        .replaceAll('\r', '');
  }

  GPAData updateGPA() {
    String html = currentWebData.courseHistory;

    RegExp gpaRegExp = RegExp(r'<spanclass="gpa-score">(.*?)</span>');

    String unweightedGPA = gpaRegExp.firstMatch(html)!.group(1)!;
    String weightedGPA = gpaRegExp.allMatches(html).elementAt(1).group(1)!;

    RegExp rankRegExp = RegExp(r'Rank:(.*?)outof');

    String unweightedRank = rankRegExp.firstMatch(html)!.group(1)!;
    String weightedRank = rankRegExp.allMatches(html).elementAt(1).group(1)!;

    RegExp totalStudentsRegExp = RegExp(r'outof(.*?)</span>');

    String totalStudents = totalStudentsRegExp.firstMatch(html)!.group(1)!;

    GPAData data = GPAData();

    data.unweightedGPA = double.parse(unweightedGPA);
    data.weightedGPA = double.parse(weightedGPA);

    data.unweightedRank = int.parse(unweightedRank);
    data.weightedRank = int.parse(weightedRank);

    data.totalStudents = int.parse(totalStudents);

    return data;
  }

  BellSchedule updateCurrentBellSchedule() {
    String html = currentWebData.classSchedule;

    RegExp beginningExp = RegExp(r'startTime">(.*?)</span>');

    RegExp endExp = RegExp(r'endTime">(.*?)</span>');

    List<String> beginnings = beginningExp.allMatches(html).map((e) {
      return e.group(1)!;
    }).toList();

    List<String> ends = endExp.allMatches(html).map((e) {
      return e.group(1)!;
    }).toList();

    BellSchedule data = BellSchedule();

    for (int i = 0; i < beginnings.length; i++) {
      BellPeriod period = BellPeriod();

      period.period = 'Period ${i + 1}';

      bool isPM = beginnings[i].contains('PM');
      bool isPMEnd = ends[i].contains('PM');

      String startTime =
          beginnings[i].replaceAll(' AM', '').replaceAll(' PM', '');
      String endTime = ends[i].replaceAll(' AM', '').replaceAll(' PM', '');

      period.startTime = TimeOfDay(
        hour: int.parse(startTime.split(':')[0]) + (isPM ? 12 : 0),
        minute: int.parse(startTime.split(':')[1]),
      );

      period.endTime = TimeOfDay(
        hour: int.parse(endTime.split(':')[0]) + (isPMEnd ? 12 : 0),
        minute: int.parse(endTime.split(':')[1]),
      );

      data.periods.add(period);
    }

    // Determine lunch period

    for (int i = 0; i < data.periods.length - 1; i++) {
      BellPeriod period = data.periods[i];

      BellPeriod nextPeriod = data.periods[i + 1];

      int timeDifference = nextPeriod.startTime.hour * 60 +
          nextPeriod.startTime.minute -
          period.endTime.hour * 60 -
          period.endTime.minute;

      if (timeDifference > 12) {
        BellPeriod lunch = BellPeriod();

        lunch.period = 'Lunch';
        lunch.startTime = period.endTime;
        lunch.endTime = nextPeriod.startTime;

        data.periods.insert(i + 1, lunch);
      }
    }

    return data;
  }

  int parseGrade(String grade) {
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

  CourseHistory updateCourseHistory() {
    String html = currentWebData.courseHistory;

    RegExp courseTitleRegExp = RegExp(r'text: CourseTitle">(.*?)</span>');
    RegExp courseIdRegExp = RegExp(r'text: CourseID">(.*?)</span>');
    RegExp gradeRegExp = RegExp(r'text: Mark">(.*?)</span>');
    RegExp schoolTypeRegExp = RegExp(r'text: CHSType">(.*?)</span>');

    List<String> courseTitles = courseTitleRegExp.allMatches(html).map((e) {
      return e.group(1)!;
    }).toList();

    List<String> courseIds = courseIdRegExp.allMatches(html).map((e) {
      return e.group(1)!;
    }).toList();

    List<String> grades = gradeRegExp.allMatches(html).map((e) {
      return e.group(1)!;
    }).toList();

    List<String> types = schoolTypeRegExp.allMatches(html).map((e) {
      return e.group(1)!;
    }).toList();

    CourseHistory data = CourseHistory();

    for (int i = 0; i < courseTitles.length; i++) {
      if (types[i] != 'HighSchool') {
        continue;
      }

      CourseEntry entry = CourseEntry();

      entry.courseTitle = courseTitles[i];
      entry.grade = parseGrade(grades[i]);
      entry.isWeighted =
          courseIds[i].contains('AP') || courseIds[i].contains('IB');

      data.courses.add(entry);
    }

    return data;
  }
}
