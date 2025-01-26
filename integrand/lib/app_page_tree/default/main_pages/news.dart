import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:integrand/consts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:integrand/backend/studentvue_api/data_classes/data_classes.dart';
import 'package:integrand/backend/integrand_servers/integrand_api.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  List<NewsArticle> _newsArticles = [];
  List<NewsArticle> _searchResults = [];
  int _articleCount = 0;
  NewsArticle _currentArticle = NewsArticle();
  bool _showCancelButton = false;

  void enterArticleView(NewsArticle article) {
    setState(() {
      _currentArticle = article;
      _showCancelButton = false;
    });
    searchFieldController.clear();
    mainToFullscreenController.animateToPage(
      1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void cancelSearch() {
    listAndSearchResultController.animateToPage(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _showCancelButton = false;
      _searchResults = [];
    });
  }

  void searchArticles(String query) {
    if (listAndSearchResultController.page == 0) {
      listAndSearchResultController.animateToPage(
        1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
    setState(() {
      _searchResults = getArticlesTitleMatching(query);
      _showCancelButton = true;
      print(
          "*************************\nCalled setState\nSearch results: $_searchResults\nquery: $query\n*************************");
    });
  }

  List<NewsArticle> getArticlesTitleMatching(String query) {
    List<NewsArticle> searchResults = [];
    for (NewsArticle article in _newsArticles) {
      if (article.title.toLowerCase().contains(query.toLowerCase())) {
        searchResults.add(article);
      }
    }
    return searchResults;
  }

  PageController mainToFullscreenController = PageController(
    initialPage: 0,
  );

  PageController listAndSearchResultController = PageController(
    initialPage: 0,
  );

  TextEditingController searchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Fetch articles from backend
    return FutureBuilder<List<NewsArticle>>(
      future: fetchNews(4),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _newsArticles = snapshot.data!;
          _articleCount = _newsArticles.length;

          return PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: mainToFullscreenController,
            children: [
              NewsMainPage(
                newsArticles: _newsArticles,
                searchResults: _searchResults,
                articleCount: _articleCount,
                enterArticleView: enterArticleView,
                searchForArticles: searchArticles,
                searchCancelled: cancelSearch,
                mainToFullscreenController: mainToFullscreenController,
                listAndSearchResultController: listAndSearchResultController,
                showCancelButton: _showCancelButton,
                searchFieldController: searchFieldController,
              ),
              ArticleFullscreenPage(
                newsArticle: _currentArticle,
                mainToFullscreenController: mainToFullscreenController,
              ),
            ],
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

class NewsMainPage extends StatelessWidget {
  const NewsMainPage({
    super.key,
    required this.newsArticles,
    required this.searchResults,
    required this.articleCount,
    required this.enterArticleView,
    required this.searchForArticles,
    required this.searchCancelled,
    required this.mainToFullscreenController,
    required this.listAndSearchResultController,
    required this.showCancelButton,
    required this.searchFieldController,
  });

  final List<NewsArticle> newsArticles;
  final List<NewsArticle> searchResults;
  final int articleCount;
  final void Function(NewsArticle newsArticle) enterArticleView;
  final void Function(String) searchForArticles;
  final void Function() searchCancelled;
  final PageController mainToFullscreenController;
  final PageController listAndSearchResultController;
  final bool showCancelButton;
  final TextEditingController searchFieldController;

  @override
  Widget build(BuildContext context) {
    // Sort articles by release date and release time, with most recent first
    newsArticles.sort((a, b) => b.compareTo(a));
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ArticleSearchBar(
          onSearchCallback: searchForArticles,
          onSearchCancel: searchCancelled,
          showCancelButton: showCancelButton,
          searchFieldController: searchFieldController,
        ),
        SizedBox(height: 20),
        Expanded(
            child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: listAndSearchResultController,
          children: [
            ArticleList(
              articleCount: articleCount,
              newsArticles: newsArticles,
              enterArticleView: enterArticleView,
              pageController: mainToFullscreenController,
            ),
            ArticleSearchResultsList(
              searchResults: searchResults,
              onPressedCallback: enterArticleView,
            ),
          ],
        )),
      ],
    );
  }
}

class ArticleSearchBar extends StatelessWidget {
  const ArticleSearchBar({
    super.key,
    required this.onSearchCallback,
    required this.onSearchCancel,
    required this.showCancelButton,
    required this.searchFieldController,
  });

  final double height = 30;
  final EdgeInsets padding = const EdgeInsets.only(left: 20, right: 20);
  final void Function(String) onSearchCallback;
  final void Function() onSearchCancel;
  final bool showCancelButton;

  final TextEditingController searchFieldController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          showCancelButton
              ? Container(
                  height: height,
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      searchFieldController.clear();
                      onSearchCancel();
                    },
                  ),
                )
              : Container(),
          Expanded(
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: background2,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Material(
                color: Colors.transparent,
                child: Center(
                  // TODO: This is bad, when there's a better solution, replace this padding nonsense
                  child: TextField(
                    controller: searchFieldController,
                    maxLines: 1,
                    style: labelStyle,
                    onChanged: (value) {
                      onSearchCallback(value);
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.5), // just a magic number to center it
                      hintText: "Search for articles",
                      hintStyle: labelStyle,
                      prefixIcon: Icon(
                        Icons.search,
                        size: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleSearchResultsList extends StatelessWidget {
  const ArticleSearchResultsList({
    super.key,
    required this.searchResults,
    required this.onPressedCallback,
  });

  final void Function(NewsArticle newsArticle) onPressedCallback;
  final List<NewsArticle> searchResults;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ArticleSearchResult(
          newsArticle: searchResults[index],
          onPressedCallback: onPressedCallback,
        );
      },
    );
  }
}

class ArticleSearchResult extends StatelessWidget {
  const ArticleSearchResult({
    super.key,
    required this.newsArticle,
    required this.onPressedCallback,
  });

  final void Function(NewsArticle newsArticle) onPressedCallback;
  final NewsArticle newsArticle;
  final double height = 40;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: TextButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
        onPressed: () {
          onPressedCallback(newsArticle);
          FocusManager.instance.primaryFocus?.unfocus();
          print("Tapped on article ${newsArticle.title}");
        },
        child: Column(
          children: [
            BorderLine(),
            SizedBox(
              height: height - 2,
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      newsArticle.title,
                      style: labelStyle,
                    ),
                    Text(
                      newsArticle.getShortDateString(),
                      style: labelStyleSubdued,
                    ),
                  ],
                ),
              ),
            ),
            BorderLine(),
          ],
        ),
      ),
    );
  }
}

class ArticleList extends StatelessWidget {
  const ArticleList(
  {
      super.key,
      required this.articleCount,
      required this.newsArticles,
      required this.enterArticleView,
      required this.pageController,
      });

  final int articleCount;
  final List<NewsArticle> newsArticles;
  final void Function(NewsArticle newsArticle) enterArticleView;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
        if (!newsArticles[index].sameReleaseDateAs(newsArticles[index - 1])) {
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
    );
  }
}

class ArticleListItemContainer extends StatelessWidget {
  const ArticleListItemContainer({
    super.key,
    required this.newsArticle,
    this.hasDate = false,
    this.ignoreDateSpacing = false,
    required this.enterArticleView,
    required this.pageController,
  });

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
    } else {
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
            onPressedCallback: (NewsArticle newsArticle) {
              enterArticleView(newsArticle);
            },
          ),
        ],
      );
    } else {
      return Column(
        children: [
          ArticleListItem(
            newsArticle: newsArticle,
            onPressedCallback: (NewsArticle newsArticle) {
              enterArticleView(newsArticle);
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
      style: labelStyleBold,
    );
  }
}

class ArticleListItem extends StatelessWidget {
  const ArticleListItem(
      {super.key, required this.newsArticle, required this.onPressedCallback});

  final NewsArticle newsArticle;
  final double height = 170;
  final void Function(NewsArticle newsArticle) onPressedCallback;

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
      image = SizedBox(
        height: 84,
        width: 150,
        child: Stack(
          children: [
            Positioned(
              height: 84,
              width: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image(
                  image: newsArticle.image!.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      child: TextButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
        onPressed: () {
          onPressedCallback(newsArticle);
          print("Tapped on article ${newsArticle.title}");
        },
        child: Container(
          color: background1,
          child: Column(
            children: [
              const BorderLine(),
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
                              style: bodyStyleBold,
                            ),
                            SizedBox(height: 15),
                            Text(
                              newsArticle.content,
                              style: labelStyle,
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
              BorderLine(),
            ],
          ),
        ),
      ),
    );
  }
}
// News Article Fullscreen ===============================

class ArticleFullscreenPage extends StatelessWidget {
  const ArticleFullscreenPage(
      {super.key,
      required this.newsArticle,
      required this.mainToFullscreenController});

  final NewsArticle newsArticle;
  final PageController mainToFullscreenController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background0,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            ),
            child: ArticleFullscreenPageHeader(
              newsArticle: newsArticle,
              exitArticleView: () {
                mainToFullscreenController.animateToPage(0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut);
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ArticleFullscreenPageContent(newsArticle: newsArticle),
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleFullscreenPageHeader extends StatelessWidget {
  const ArticleFullscreenPageHeader(
      {super.key, required this.newsArticle, required this.exitArticleView});

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
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textWhite,
                ),
                onPressed: exitArticleView,
              ),
            ],
          ),
          Text(
            newsArticle.getDateString(),
            textAlign: TextAlign.center,
            style: labelStyleBold,
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
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        ArticleFullscreenImage(newsArticle: newsArticle),
        const SizedBox(height: 30),
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
    bool hasImage = newsArticle.image != null;
    if (!hasImage) {
      return Container(
        height: 216,
        width: 384,
        color: Colors.black,
      );
    }
    else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 216,
          width: 384,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: newsArticle.image!.image,
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: newsArticle.image,
              ),
            ),
          ),
        ),
      );
    }
  }
}

class ArticleFullscreenText extends StatelessWidget {
  const ArticleFullscreenText({super.key, required this.newsArticle});

  final NewsArticle newsArticle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          newsArticle.title,
          style: subtitleStyle,
        ),
        SizedBox(height: 30),
        MarkdownBody(
          data: newsArticle.content,
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
