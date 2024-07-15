import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:integrand/consts.dart';
import 'package:integrand/backend/data_classes.dart';
import 'package:integrand/backend/database_interactions.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  // TODO: move this into consts later or implement backend
  List<NewsArticle> _newsArticles = [];

  int _articleCount = 0;

  @override
  Widget build(BuildContext context) {
    // Fetch articles from backend
    return FutureBuilder<List<NewsArticle>>(
      future: fetchNews(4),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _newsArticles = snapshot.data!;
          _articleCount = _newsArticles.length;
          return ArticleList(
            newsArticles: _newsArticles,
            articleCount: _articleCount,
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading news'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(purpleGradient),
            ),
          );
        }
      },
    );
  }
}

// Main News Page ========================================

class ArticleList extends StatelessWidget {
  const ArticleList(
      {super.key, required this.newsArticles, required this.articleCount});

  final List<NewsArticle> newsArticles;
  final int articleCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ArticleSearchBar(),
        Expanded(
          child: ListView.builder(
            itemCount: articleCount,
            itemBuilder: (context, index) {
              return ArticleListItemContainer(
                newsArticle: newsArticles[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class ArticleSearchBar extends StatelessWidget {
  const ArticleSearchBar({super.key});

  final double height = 50;
  final EdgeInsets padding = const EdgeInsets.only(left: 20, right: 20);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ArticleListItemContainer extends StatelessWidget {
  const ArticleListItemContainer(
      {super.key, required this.newsArticle, this.hasDate = false});

  final NewsArticle newsArticle;
  final bool hasDate;
  final double topSpacing = 20;

  @override
  Widget build(BuildContext context) {
    if (hasDate) {
      return Column(
        children: [
          SizedBox(height: topSpacing + 10),
          ArticleListItemDate(
            newsArticle: newsArticle,
          ),
          const SizedBox(height: 10),
          ArticleListItem(
            newsArticle: newsArticle,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          SizedBox(height: topSpacing),
          ArticleListItem(
            newsArticle: newsArticle,
          ),
        ],
      );
    }
  }
}

class ArticleListItemDate extends StatelessWidget {
  const ArticleListItemDate({super.key, required this.newsArticle});

  final NewsArticle newsArticle;

  @override
  Widget build(BuildContext context) {
    return Text(
      newsArticle.getDateString(),
      textAlign: TextAlign.center,
      style: newsDateStyle,
    );
  }
}

class ArticleListItem extends StatelessWidget {
  const ArticleListItem({super.key, required this.newsArticle});

  final NewsArticle newsArticle;
  final double height = 170;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: lightGreyTransparent,
      child: Column(
        children: [
          Container(
            color: lightGrey,
            height: 1,
          ),
          SizedBox(
            height: height,
            // TODO: Add lr padding here
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            child: Image.memory(
                              base64Decode(newsArticle.image)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newsArticle.title,
                          style: boldBodyStyle,
                        ),
                        SizedBox(height: 15),
                        Text(
                          newsArticle.content,
                          style: smallBodyStyle,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }
}
// News Article Fullscreen ===============================