import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/connectivity_provider.dart';

class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String source;
  final DateTime publishedAt;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.source,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      source: json['source']?['name'] ?? 'Unknown',
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'url': url,
    'urlToImage': urlToImage,
    'source': source,
    'publishedAt': publishedAt.toIso8601String(),
  };
}

class NewsService {
  final String _apiKey = ApiConstants.newsApiKey;
  final String _baseUrl = ApiConstants.newsBaseUrl;

  Future<List<NewsArticle>> fetchNews({String category = 'All', bool forceRefresh = false}) async {
    final box = await Hive.openBox('news_cache');

    if (!forceRefresh) {
      final lastFetchStr = box.get('last_fetch_time_$category');
      if (lastFetchStr != null) {
        final lastFetchDate = DateTime.parse(lastFetchStr);
        if (DateTime.now().difference(lastFetchDate).inHours < 6) {
          final cached = await getCachedNews(category: category);
          if (cached.isNotEmpty) {
            print('Returning cached news for $category (less than 6 hours old)');
            return cached;
          }
        }
      }
    }

    String query = ApiConstants.newsSearchQuery;
    if (category != 'All') {
      query += ' $category';
    }

    final url = Uri.parse('$_baseUrl/everything?q=${Uri.encodeComponent(query)}&language=en&sortBy=publishedAt&apiKey=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List articlesJson = data['articles'] ?? [];
        final articles = articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
        
        // Cache the results
        final box = await Hive.openBox('news_cache');
        await box.put('last_news_$category', articlesJson);
        await box.put('last_fetch_time_$category', DateTime.now().toIso8601String());
        
        return articles;
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      // Try to load from cache if network fails
      return getCachedNews(category: category);
    }
  }

  Future<List<NewsArticle>> getCachedNews({String category = 'All'}) async {
    try {
      final box = await Hive.openBox('news_cache');
      final cachedData = box.get('last_news_$category');
      if (cachedData != null) {
        return (cachedData as List).map((json) => NewsArticle.fromJson(Map<String, dynamic>.from(json))).toList();
      }
    } catch (e) {
      print('Error fetching cached news: $e');
    }
    return [];
  }

  String formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }
}

final newsServiceProvider = Provider((ref) => NewsService());

final newsListProvider = FutureProvider.family<List<NewsArticle>, String>((ref, category) async {
  final connectivity = ref.watch(connectivityProvider);
  final newsService = ref.watch(newsServiceProvider);
  if (connectivity == ConnectivityStatus.offline) {
    return newsService.getCachedNews(category: category);
  }
  // Refreshes triggered by ref.refresh bypass this since the provider is recreated, 
  // but to be explicit we could pass a param. We'll rely on the default behavior here.
  return newsService.fetchNews(category: category);
});

