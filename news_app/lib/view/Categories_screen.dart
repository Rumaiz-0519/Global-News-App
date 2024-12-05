import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:news_app/database/BookmarkDatabase.dart';
import 'package:news_app/models/categories_news_model.dart';
import 'package:news_app/view/BookmarkScreen.dart';
import 'package:news_app/view_model/news_view_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

NewsViewModel newsViewModel = NewsViewModel();
final format = DateFormat('MMM dd, yyyy');
String categoryname = 'general';
List<String> categoriesList = [
  'General',
  'Entertainment',
  'Health',
  'Sports',
  'Business',
  'Technology'
];

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<CategoriesNewsModel> _futureArticles;
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  void _loadArticles() {
    setState(() {
      _futureArticles = newsViewModel.fetchCategoriesNewsApi(categoryname);
    });
  }

  Future<void> _refreshArticles() async {
    _loadArticles();
    await _futureArticles; // Wait until the articles are loaded before returning
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search articles...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookmarkScreen()),
              );
              _refreshArticles(); // Refresh the UI when returning from the bookmark screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoriesList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (categoryname != categoriesList[index]) {
                        setState(() {
                          categoryname = categoriesList[index];
                          _loadArticles();
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        decoration: BoxDecoration(
                            color: categoryname == categoriesList[index]
                                ? Colors.blue
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Center(
                              child: Text(
                            categoriesList[index],
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white),
                          )),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshArticles,
                child: FutureBuilder<CategoriesNewsModel>(
                  key: ValueKey(categoryname), // Add a key to force update
                  future: _futureArticles,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SpinKitCircle(
                          size: 50,
                          color: Colors.blue,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error}"),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.articles!.isEmpty) {
                      return Center(
                        child: Text("No articles available"),
                      );
                    } else {
                      List<Articles> filteredArticles = snapshot.data!.articles!
                          .where((article) =>
                              article.title != null &&
                              article.title!
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                          .toList();

                      return ListView.builder(
                        itemCount: filteredArticles.length,
                        itemBuilder: (context, index) {
                          DateTime dateTime = DateTime.parse(
                              filteredArticles[index].publishedAt.toString());
                          var article = filteredArticles[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: CachedNetworkImage(
                                    imageUrl: article.urlToImage != null &&
                                            article.urlToImage!.isNotEmpty
                                        ? article.urlToImage!
                                        : 'https://via.placeholder.com/150',
                                    fit: BoxFit.cover,
                                    height: height * .18,
                                    width: width * .3,
                                    placeholder: (context, url) => Container(
                                      child: Center(
                                        child: SpinKitCircle(
                                          size: 50,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: height * .18,
                                    padding: EdgeInsets.only(left: 15),
                                    child: Column(
                                      children: [
                                        Text(
                                          article.title != null &&
                                                  article.title!.isNotEmpty
                                              ? article.title!
                                              : 'No title available',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                article.source?.name != null &&
                                                        article.source!
                                                            .name!.isNotEmpty
                                                    ? article.source!.name!
                                                    : 'No source available',
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                article.isBookmarked
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_border,
                                                color: article.isBookmarked
                                                    ? Colors.blue
                                                    : Colors.black54,
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  article.isBookmarked =
                                                      !article.isBookmarked;
                                                });
                                                if (article.isBookmarked) {
                                                  await BookmarkDatabase
                                                      .instance
                                                      .insertArticle(article);
                                                } else {
                                                  await BookmarkDatabase
                                                      .instance
                                                      .deleteArticle(
                                                          article.url!);
                                                }
                                                _refreshArticles();
                                              },
                                            ),
                                            Text(
                                              format.format(dateTime),
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
