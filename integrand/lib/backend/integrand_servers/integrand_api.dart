import 'package:http/http.dart' as http;
import 'package:integrand/backend/studentvue_api/data_classes/data_classes.dart';
import 'dart:convert';

// Necessary functions to interact with the database
// Fetch list of schools in a district
// Fetch list of news objects for school
// Fetch list of events for school

Future<List<School>> fetchSchools(String districtName) async {
  final response = await http.get(Uri.parse(
      'https://integrand.app/appbackend/get_schools.php?districtId=$districtName'));
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

Future<List<NewsArticle>> fetchNews(int schoolId) async {
  final response = await http.get(Uri.parse(
      'https://integrand.app/appbackend/get_news.php?schoolId=$schoolId'));
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

Future<List<Event>> fetchEvents(int schoolId) async {
  final response = await http.get(Uri.parse(
      'https://integrand.app/appbackend/get_calendar.php?schoolId=$schoolId'));
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
