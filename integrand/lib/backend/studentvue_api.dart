import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'xml_parsers.dart';
import 'data_classes.dart';

class StudentVueAPI with ChangeNotifier {
  late String baseUrl;
  late String username;
  late String password;

  bool initialized = false;

  bool initializedStudent = false;
  bool initializedGrades = false;
  bool initializedSchedule = false;

  bool initializedCourseHistory = false;
  bool initializedBellSchedule = false;

  ScheduleData scheduleData = ScheduleData();
  GradebookData gradebookData = GradebookData();
  StudentData studentData = StudentData();

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
    updateStudent();
    updateGrades();
    updateSchedule();

    // Updates for data not accessible via SOAP API
    initializeClientData();

    while (allApiCallsNotFinished()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    notifyListeners();
  }

  static bool credsAreNull(String user, String pass) {
    print(user);
    return user == '' || pass == '';
  }

  static Future<bool> credsAreInvalid(String user, String pass, String baseUrl) async {
    String url = '$baseUrl/Service/PXPCommunication.asmx';

    print(user);

    Uri uri = Uri.parse(url);

    String xml =
        '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/"><userID>$user</userID><password>$pass</password><skipLoginLog>1</skipLoginLog><parent>0</parent><webServiceHandleName>PXPWebServices</webServiceHandleName><methodName>StudentInfo</methodName><paramStr>&lt;Parms&gt;&lt;ChildIntID&gt;0&lt;/ChildIntID&gt;&lt;/Parms&gt;</paramStr></ProcessWebServiceRequest></soap:Body></soap:Envelope>';

    http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'text/xml',
        'SOAPAction':
            'http://edupoint.com/webservices/ProcessWebServiceRequest',
      },
      body: xml,
    );

    print(response.body);

    if (response.body.contains('Invalid user id or password')) {
      return true;
    }
    return false;
  }

  bool allApiCallsNotFinished() {
    if (!initializedStudent || !initializedGrades || !initializedSchedule) {
      return true;
    }
    return false;
  }

  bool allWebCallsNotFinished() {
    if (!initializedCourseHistory || !initializedBellSchedule) {
      return true;
    }
    return false;
  }

  Future<http.Response> student() async {
    if (!initialized) {
      throw Exception('StudentVueAPI not initialized');
    }

    String url = '$baseUrl/Service/PXPCommunication.asmx';

    Uri uri = Uri.parse(url);

    String xml =
        '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/"><userID>$username</userID><password>$password</password><skipLoginLog>1</skipLoginLog><parent>0</parent><webServiceHandleName>PXPWebServices</webServiceHandleName><methodName>StudentInfo</methodName><paramStr>&lt;Parms&gt;&lt;ChildIntID&gt;0&lt;/ChildIntID&gt;&lt;/Parms&gt;</paramStr></ProcessWebServiceRequest></soap:Body></soap:Envelope>';

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

    initializedGrades = true;

    return gradebookData;
  }

  Future<ScheduleData> updateSchedule() async {
    http.Response response = await schedule();

    scheduleData = parseSchedule(response);

    initializedSchedule = true;

    return scheduleData;
  }

  Future<StudentData> updateStudent() async {
    http.Response response = await student();

    studentData = parseStudent(response);

    initializedStudent = true;

    return studentData;
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

    requestStudentVueWebData();

    while (allWebCallsNotFinished()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    GPAData gpaData = updateGPA();

    this.gpaData = gpaData;

    BellSchedule bellSchedule = updateCurrentBellSchedule();

    this.bellSchedule = bellSchedule;

    CourseHistory courseHistory = updateCourseHistory();

    this.courseHistory = courseHistory;
  }

  Future<void> requestCourseHistory() async {
    String url = '$baseUrl/PXP2_CourseHistory.aspx?AGU=0';

    http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Cookie': currentCookies,
      },
    );

    currentWebData.courseHistory = removeWhitespace(response.body);
    initializedCourseHistory = true;
  }

  Future<void> requestBellSchedule() async {
    String url = '$baseUrl/PXP2_ClassSchedule.aspx?AGU=0';

    http.Response response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Cookie': currentCookies,
      },
    );

    currentWebData.classSchedule = removeWhitespace(response.body);
    initializedBellSchedule = true;
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

  static String removeWhitespace(String html) {
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

    RegExp periodExp = RegExp(r'0(.):');

    RegExp beginningExp = RegExp(r'startTime">(.*?)</span>');

    RegExp endExp = RegExp(r'endTime">(.*?)</span>');

    List<String> periods = periodExp.allMatches(html).map((e) {
      return e.group(1)!;
    }).toList();

    List<String> beginnings = beginningExp.allMatches(html).map((e) {
      return e.group(1)!;
    }).toList();

    List<String> ends = endExp.allMatches(html).map((e) {
      return e.group(1)!;
    }).toList();

    BellSchedule data = BellSchedule();

    for (int i = 0; i < beginnings.length; i++) {
      BellPeriod period = BellPeriod();

      period.periodName = periods[i];

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

        TimeOfDay lunchStart = period.endTime;

        TimeOfDay lunchEnd = nextPeriod.startTime;

        // Add 1 minute buffer to help with schedule parsing

        if (lunchStart.minute == 59) {
          lunchStart = TimeOfDay(
            hour: lunchStart.hour + 1,
            minute: 0,
          );
        } else {
          lunchStart = TimeOfDay(
            hour: lunchStart.hour,
            minute: lunchStart.minute + 1,
          );
        }

        if (lunchEnd.minute == 0) {
          lunchEnd = TimeOfDay(
            hour: lunchEnd.hour - 1,
            minute: 59,
          );
        } else {
          lunchEnd = TimeOfDay(
            hour: lunchEnd.hour,
            minute: lunchEnd.minute - 1,
          );
        }

        lunch.periodName = 'Lunch';
        lunch.startTime = lunchStart;
        lunch.endTime = lunchEnd;

        data.periods.insert(i + 1, lunch);
      }
    }

    // If multiple periods marked as lunch, keep the closest to noon and set the rest to flex

    if (data.periods.where((element) => element.periodName == 'Lunch').length >
        1) {
      List<BellPeriod> lunches = data.periods
          .where((element) => element.periodName == 'Lunch')
          .toList();
      List<int> distancesFromNoon = lunches
          .map((e) => (e.startTime.hour - 12).abs() * 60 + e.startTime.minute)
          .toList();

      int closestLunchIndex = distancesFromNoon.indexOf(distancesFromNoon
          .reduce((value, element) => value < element ? value : element));

      for (int i = 0; i < lunches.length; i++) {
        if (i == closestLunchIndex) {
          continue;
        }

        lunches[i].periodName = 'Flex';
      }
    }

    return data;
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
