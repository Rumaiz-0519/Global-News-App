import 'package:flutter/material.dart';
import 'package:news_app/database/BookmarkDatabase.dart';
import 'package:news_app/models/categories_news_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class BookmarkScreen extends StatefulWidget {
  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<List<Articles>>(
        future: BookmarkDatabase.instance.getBookmarkedArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var article = snapshot.data![index];
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: article.urlToImage ?? 'https://via.placeholder.com/150',
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  title: Text(article.title ?? 'No title available',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Text(article.source?.name ?? 'Unknown source',
                      style: GoogleFonts.poppins()),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await BookmarkDatabase.instance.deleteArticle(article.url!);
                      setState(() {});
                    },
                  ),
                  onTap: () {
                    // Open article details screen if needed
                  },
                );
              },
            );
          } else {
            return Center(child: Text('No bookmarks found', style: GoogleFonts.poppins()));
          }
        },
      ),
    );
  }
}