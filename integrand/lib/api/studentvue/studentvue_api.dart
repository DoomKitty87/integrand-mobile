import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:integrand/models/models.dart';

class StudentVueModel extends ModelBase {
  StudentVueModel(super.onUpdate);

  bool loggedIn = false;

  /// Logs in to PPS StudentVue with the given username and password. Returns true if successful, false otherwise.
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://parent-portland.cascadetech.org/portland/PXP2_Login_Student.aspx?regenerateSessionId=true'),
        // The headers/body are set to mimic a captured browser request, because I don't know what the API expects.
        headers: <String, String>{
          'Host': 'parent-portland.cascadetech.org',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate, br, zstd',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Origin': 'https://parent-portland.cascadetech.org',
          'DNT': '1',
          'Sec-GPC': '1',
          'Connection': 'keep-alive',
          'Referer': 'https://parent-portland.cascadetech.org/portland/PXP2_Login_Student.aspx',
          'Upgrade-Insecure-Requests': '1',
          'Sec-Fetch-Dest': 'document',
          'Sec-Fetch-Mode': 'navigate',
          'Sec-Fetch-Site': 'same-origin',
          'Sec-Fetch-User': '?1',
        },
        body: {
          // Github Copilot was able to fill in some of these values,
          // This probably means that there is some sort of API documentation available or some standard that the API follows.
          // ctl00 is something related to ASP.NET Web Forms, look into it at some point to see if there's a better way to handle this.

          // May need to scrape this value from the login page, but will fill in with what I have in Postman
          '__VIEWSTATE': 'BcXybKnSYjVKS2yYQxo4ij8vuKn8qh97K92LXX1N8jTe1NoZquAhO8cLTb7E1xJQriS0t1Hq2J5hcea4WXfs7jfm1CApRE97nv/ur0n/U4M=', 
          // Same here
          '__VIEWSTATEGENERATOR': '972A11A6',
          // Same here
          '__EVENTVALIDATION': 'z/qyEXkdjj7lz1oorYiAJZww5yAS8fB3efIGWzHufG/gaJDARRHE1XuqFCqwxlk1cV5oYr02z5cEmWQgWK7CPz3GPtOr5yS4hn8SfY3KZZ7BKM28e6qPX9p0C0TxWoZ+ptL3KKhth6Aw/u8NwmFV6Y4m2YuFGeMaIb04MKLYpF0=',
          'ctl00\$MainContent\$username': username,
          'ctl00\$MainContent\$password': password,
          'ctl00\$MainContent\$Submit1': 'Login',
        },
      );

      if (response.statusCode != 200) {
        print('Unexpected login output, failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false; // Login failed
      }

      final String body = response.body;
      final document = html_parser.parse(body);

      // TODO: Parse the script tag for access token
      final scriptIndicator = document.querySelector('script');
      
      // if (indicator == null) {
      //   print('Login failed, no script tag found in response.');
      //   return false; // Login failed
      // }
      
      return true; 
    } 
    catch (e) {
      print('Exception inside login function: $e');
      return false; // Error occurred during login
    }
  }
}