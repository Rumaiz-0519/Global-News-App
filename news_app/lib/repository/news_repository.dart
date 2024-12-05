import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/models/categories_news_model.dart';
import 'package:news_app/models/news_channels_headlines_model.dart';

class NewsRepository {
  final String _apiKey = '669ce0361f0a405a850dc3ee668677dc';
  final String _baseUrl = 'https://newsapi.org/v2';

  Future<NewsChannelsHeadlinesModel> fetchNewChannelHeadlinesApi() async {
    String url =
        '$_baseUrl/top-headlines?sources=bbc-news&apiKey=$_apiKey';

    final response = await http.get(Uri.parse(url));
    if (kDebugMode) {
      print(response.body);
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return NewsChannelsHeadlinesModel.fromJson(body);
    }
    throw Exception('Failed to load top headlines');
  }

  Future<CategoriesNewsModel> fetchCategoriesNewsApi(String category) async {
    String url =
        '$_baseUrl/top-headlines?category=$category&apiKey=$_apiKey';

    final response = await http.get(Uri.parse(url));
    if (kDebugMode) {
      print(response.body);
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return CategoriesNewsModel.fromJson(body);
    }
    throw Exception('Failed to load category news');
  }
}



