import 'package:http/http.dart' as http;

Future<String> runTest() async {
  // String url = 'https://parent-portland.cascadetech.org/portland';

  // String username = 'username';
  // String password = 'password';

  Map cookies = <String, String>{};

  http.Response response = await http.post(
      Uri.parse(
          r'https://parent-portland.cascadetech.org/portland/PXP2_Login_Student.aspx?regenerateSessionId=True&ct100%24MainContent%24username=username&ct100%24MainContent%24password=password&ct100%24MainContent%24Submit1=Login'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      });

  List<String> cookiesList = response.headers['set-cookie']!.split(';');

  for (String cookie in cookiesList) {
    List<String> cookieParts = cookie.split('=');
    if (cookieParts.length == 1) {
      continue;
    }
    cookies.update(cookieParts[0], (value) => cookieParts[1],
        ifAbsent: () => cookieParts[1]);
  }

  // Get request student info page

  response = await http.get(
    Uri.parse(
        'https://parent-portland.cascadetech.org/portland/PXP2_Student.aspx?AGU=0'),
    headers: <String, String>{
      'ASP.NET_SessionId': cookies['ASP.NET_SessionId']!,
    },
  );

  // Extract student name from response

  // String body = response.body;

  // RegExp studentNameRegExp =
  //     RegExp(r'<span class="tbl_label">Student Name</span><br>(.*?)</td>');

  //String studentName = studentNameRegExp.firstMatch(body)!.group(1)!;
  //print(response.body);
  return response.body;
}

Future<String> runTest2() async {
  // Get login page

  http.Response response = await http.get(
    Uri.parse(
        'https://parent-portland.cascadetech.org/portland/PXP2_Login_Student.aspx?regenerateSessionId=True'),
  );

  List<String> cookiesList = response.headers['set-cookie']!.split(',');

  Map cookies = <String, String>{};

  for (String cookie in cookiesList) {
    List<String> cookieParts = cookie.split('=');
    if (cookieParts.length == 1) {
      continue;
    }
    cookies.update(cookieParts[0], (value) => cookieParts[1],
        ifAbsent: () => cookieParts[1]);
  }

  Map loginData = <String, String>{};

  String html = response.body;

  RegExp viewStateRegExp = RegExp(
      r'<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="(.*?)" />');

  RegExp viewStateGeneratorRegExp = RegExp(
      r'<input type="hidden" name="__VIEWSTATEGENERATOR" id="__VIEWSTATEGENERATOR" value="(.*?)" />');

  RegExp eventValidationRegExp = RegExp(
      r'<input type="hidden" name="__EVENTVALIDATION" id="__EVENTVALIDATION" value="(.*?)" />');

  loginData['__VIEWSTATE'] = viewStateRegExp.firstMatch(html)!.group(1)!;
  loginData['__VIEWSTATEGENERATOR'] =
      viewStateGeneratorRegExp.firstMatch(html)!.group(1)!;
  loginData['__EVENTVALIDATION'] =
      eventValidationRegExp.firstMatch(html)!.group(1)!;

  loginData['ctl00\$MainContent\$username'] = 'username';

  loginData['ctl00\$MainContent\$password'] = 'password';

  loginData['ctl00\$MainContent\$Submit1'] = 'Login';

  //String data = '';

  loginData.forEach((key, value) {
    key = Uri.encodeQueryComponent(key);
    value = Uri.encodeQueryComponent(value);
    //data += '$key=$value&';
  });

  String cookiesString = '';

  cookies.forEach((key, value) {
    cookiesString += '$key=$value; ';
  });

  response = await http.post(
    Uri.parse(
        'https://parent-portland.cascadetech.org/portland/PXP2_Login_Student.aspx?regenerateSessionId=True'),
    headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      'Cookie': cookiesString,
    },
    body: loginData,
  );

  response = await http.get(
    Uri.parse(
        'https://parent-portland.cascadetech.org/portland/PXP2_MyAccount.aspx?AGU=0'),
    headers: <String, String>{
      'Cookie': cookiesString,
    },
  );

  String body = response.body;

  RegExp studentNameRegExp =
      RegExp(r'<span class="tbl_label">Name</span><br>(.*?)</td>');

  String studentName = studentNameRegExp.firstMatch(body)!.group(1)!;

  return studentName;
}
