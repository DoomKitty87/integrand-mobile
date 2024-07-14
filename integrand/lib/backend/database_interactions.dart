import 'package:http/http.dart' as http;
import 'package:integrand/backend/data_classes.dart';
import 'dart:convert';

// Necessary functions to interact with the database
// Fetch list of schools in a district
// Fetch list of news objects for school
// Fetch list of events for school

Future<List<School>> fetchSchools(String districtName) async {
  final response = await http.get(Uri.parse(
      'https://database.integrand.app/fetch_data.php?getting_schools=true&district=$districtName'));
  if (response.statusCode == 200) {
    List<School> schools = [];
    List<dynamic> schoolList = jsonDecode(response.body);

    for (var school in schoolList) {
      schools.add(School.fromJson(school));
    }

    return schools;
  } else {
    throw Exception('Failed to load schools');
  }
}

Future<List<NewsArticle>> fetchNews(String schoolName) async {
  final response = await http.get(Uri.parse(
      'https://database.integrand.app/fetch_data.php?getting_news=true&school=$schoolName'));
  if (response.statusCode == 200) {
    List<NewsArticle> news = [];
    List<dynamic> newsList = jsonDecode(response.body);

    for (var newsItem in newsList) {
      news.add(NewsArticle.fromJson(newsItem));
    }

    return news;
  } else {
    throw Exception('Failed to load news');
  }
}

Future<List<Event>> fetchEvents(String schoolName) async {
  final response = await http.get(Uri.parse(
      'https://database.integrand.app/fetch_data.php?getting_events=true&school=$schoolName'));
  if (response.statusCode == 200) {
    List<Event> events = [];
    List<dynamic> eventList = jsonDecode(response.body);

    for (var event in eventList) {
      events.add(Event.fromJson(event));
    }

    return events;
  } else {
    throw Exception('Failed to load events');
  }
}
