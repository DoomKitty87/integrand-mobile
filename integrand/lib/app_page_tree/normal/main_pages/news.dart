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

  NewsArticle _currentArticle = NewsArticle();

  void enterArticleView(NewsArticle article) {
    setState(() {
      _currentArticle = article;
    });
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(
      initialPage: 0,
    );

    // Fetch articles from backend
    return FutureBuilder<List<NewsArticle>>(
      future: fetchNews(4),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _newsArticles = snapshot.data!;
          _articleCount = _newsArticles.length;

          return PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: [
              ArticleList(
                newsArticles: _newsArticles,
                articleCount: _articleCount,
                enterArticleView: enterArticleView,
                pageController: pageController,
              ),
              ArticleFullscreenPage(
                newsArticle: _currentArticle,
                pageController: pageController,
              ),
            ],
          );
        } 
        else if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading news'),
          );
        } 
        else {
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
      {super.key, required this.newsArticles, required this.articleCount, required this.enterArticleView, required this.pageController});

  final List<NewsArticle> newsArticles;
  final int articleCount;
  final void Function(NewsArticle newsArticle) enterArticleView;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    // Sort articles by release date and release time, with most recent first
    newsArticles.sort((a, b) => b.compareTo(a));
    return Column(
      children: [
        const ArticleSearchBar(),
        Expanded(
          child: ListView.builder(
            itemCount: articleCount,
            itemBuilder: (context, index) {
              // If the current article is the first article, show the date
              if (index == 0) {
                return ArticleListItemContainer(
                  newsArticle: newsArticles[index],
                  hasDate: true,
                  enterArticleView: enterArticleView,
                  ignoreDateSpacing: true,
                  pageController: pageController,
                );
              }
              // If the current article is not the first article, check if the date is different from the previous article
              // If the date is different, show the date
              if (!newsArticles[index]
                  .sameReleaseDateAs(newsArticles[index - 1])) {
                return ArticleListItemContainer(
                  newsArticle: newsArticles[index],
                  hasDate: true,
                  enterArticleView: enterArticleView,
                  pageController: pageController,
                );
              }
              // If the date is the same, don't show the date
              else {
                return ArticleListItemContainer(
                  newsArticle: newsArticles[index],
                  hasDate: false,
                  enterArticleView: enterArticleView,
                  pageController: pageController,
                );
              }
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
  const ArticleListItemContainer({super.key, required this.newsArticle, this.hasDate = false, this.ignoreDateSpacing = false, required this.enterArticleView, required this.pageController});

  final NewsArticle newsArticle;
  final bool hasDate;
  final double dateSpacing = 40;
  final bool ignoreDateSpacing;
  final void Function(NewsArticle newsArticle) enterArticleView;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    double spacing;
    if (ignoreDateSpacing) {
      spacing = 0;
    }
    else {
      spacing = dateSpacing;
    }

    if (hasDate) {
      return Column(
        children: [
          SizedBox(height: spacing),
          ArticleListItemDate(
            newsArticle: newsArticle,
          ),
          const SizedBox(height: 20),
          ArticleListItem(
            newsArticle: newsArticle,
            onTapCallback: (NewsArticle newsArticle) {
              enterArticleView(newsArticle);
              pageController.animateToPage(1, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
            },
          ),
        ],
      );
    } else {
      return Column(
        children: [
          ArticleListItem(
            newsArticle: newsArticle,
            onTapCallback: (NewsArticle newsArticle) {
              enterArticleView(newsArticle);
              pageController.animateToPage(1, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
            },
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
      style: boldSmallBodyStyle,
    );
  }
}

class ArticleListItem extends StatelessWidget {
  const ArticleListItem({super.key, required this.newsArticle, required this.onTapCallback});

  final NewsArticle newsArticle;
  final double height = 170;
  final void Function(NewsArticle newsArticle) onTapCallback;

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (newsArticle.image == null) {
      image = Container(
          height: 100,
          width: 150,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ));
    } else {
      image = Container(
        height: 100,
        width: 150,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: newsArticle.image,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        onTapCallback(newsArticle);
        print("Tapped on article ${newsArticle.title}");
      },
      child: Container(
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
                            image,
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
      ),
    );
  }
}
// News Article Fullscreen ===============================

class ArticleFullscreenPage extends StatelessWidget {
  const ArticleFullscreenPage({super.key, required this.newsArticle, required this.pageController});

  final NewsArticle newsArticle;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ArticleFullscreenPageHeader(
              newsArticle: newsArticle,
              exitArticleView: () {
                pageController.animateToPage(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
              },
            ),
            ArticleFullscreenPageContent(newsArticle: newsArticle),
          ],
        ),
      ),
    );
  }
}

class ArticleFullscreenPageHeader extends StatelessWidget {
  const ArticleFullscreenPageHeader({super.key, required this.newsArticle, required this.exitArticleView});

  final void Function() exitArticleView;
  final NewsArticle newsArticle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: exitArticleView,
              ),
            ],
          ),
          Text(
            newsArticle.getDateString(),
            textAlign: TextAlign.center,
            style: boldSmallBodyStyle,
          ),
        ],
      ),
    );
  }
}

class ArticleFullscreenPageContent extends StatelessWidget {
  const ArticleFullscreenPageContent({super.key, required this.newsArticle});

  final NewsArticle newsArticle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ArticleFullscreenImage(newsArticle: newsArticle),
        ArticleFullscreenText(newsArticle: newsArticle),
      ],
    );
  }
}

class ArticleFullscreenImage extends StatelessWidget {
  const ArticleFullscreenImage({super.key, required this.newsArticle});

  final NewsArticle newsArticle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: newsArticle.image,
      ),
    );
  }
}

class ArticleFullscreenText extends StatelessWidget {
  const ArticleFullscreenText({super.key, required this.newsArticle});

  final NewsArticle newsArticle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          newsArticle.title,
          style: mediumTitleStyle,
        ),
        SizedBox(height: 15),
        Text(
          newsArticle.content,
          style: smallBodyStyle,
          textAlign: TextAlign.left,
        ),
      ],
    );
  }
}