

import 'package:flutter/material.dart';
import '../../../helpers/time_of_day_helpers.dart';

class NewsArticle {
  int id = 0;
  String title = 'Welcome To Integrand!';
  Image? image;
  DateTime releaseDate = DateTime.now();
  String content =
      'Integrand is a new app that is designed to help students keep track of their grades, assignments, and more! We hope you enjoy using our app!';

  bool sameReleaseDateAs(NewsArticle other) {
    return releaseDate.year == other.releaseDate.year &&
        releaseDate.month == other.releaseDate.month &&
        releaseDate.day == other.releaseDate.day;
  }

  String getDateString({bool includeYear = false}) {
    if (includeYear) {
      return '${weekdayToName(releaseDate.weekday)}, ${monthToName(releaseDate.month)} ${numberWithSuffix(releaseDate.day)} ${releaseDate.year}';
    }
    return '${weekdayToName(releaseDate.weekday)}, ${monthToName(releaseDate.month)} ${numberWithSuffix(releaseDate.day)}';
  }

  String getShortDateString() {
    return '${monthToName(releaseDate.month, short: true)} ${numberWithSuffix(releaseDate.day)}';
  }

  NewsArticle();

  NewsArticle.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    title = json['Title'];
    if (json['Image'] != "") {
      try {
        image = Image.network("https://integrand.app/cdn/${json['Image']}",
            fit: BoxFit.contain);
      } on NetworkImageLoadException {
        image = null;
      }
    } else {
      image = null;
    }
    releaseDate = DateTime.fromMillisecondsSinceEpoch(json['EpochTime']);
    content = json['Content'];
  }

  int compareTo(NewsArticle other) {
    // check for date
    if (releaseDate.isBefore(other.releaseDate)) {
      return -1;
    } else if (releaseDate.isAfter(other.releaseDate)) {
      return 1;
    }
    return 0;
  }
}