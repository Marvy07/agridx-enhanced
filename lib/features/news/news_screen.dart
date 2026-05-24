import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/news_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme_provider.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open article link.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(newsListProvider(_selectedCategory));
    final themeColor = ref.watch(themeColorProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search News...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              )
            : const Text(
                'Agri News',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
              icon: const Icon(Icons.search, color: Colors.black),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'All', 'Diseases', 'Weather', 'Market'
                ].map((cat) => GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = cat;
                    _searchQuery = '';
                    _searchController.clear();
                  }),
                  child: FilterChipWidget(label: cat, active: _selectedCategory == cat),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.refresh(newsListProvider(_selectedCategory)),
              child: newsAsync.when(
                data: (articles) {
                  var filteredArticles = articles;
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    filteredArticles = articles.where((article) {
                      return article.title.toLowerCase().contains(query) ||
                             article.description.toLowerCase().contains(query) ||
                             article.source.toLowerCase().contains(query);
                    }).toList();
                  }

                  if (filteredArticles.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('No news articles found.')),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemCount: filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = filteredArticles[index];
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: GestureDetector(
                            onTap: () => _launchUrl(article.url),
                            child: FeaturedNewsCard(article: article),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () => _launchUrl(article.url),
                          child: NewsFeedItem(article: article),
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(child: CircularProgressIndicator(color: themeColor)),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Failed to load news'),
                      TextButton(
                        onPressed: () => ref.refresh(newsListProvider(_selectedCategory)),
                        child: Text('Retry', style: TextStyle(color: themeColor)),
                      ),
                    ],
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

class FeaturedNewsCard extends ConsumerWidget {
  final NewsArticle article;
  const FeaturedNewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeColorProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: themeColor.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 12)),
        ],
        border: Border.all(color: themeColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: article.urlToImage.isNotEmpty 
              ? CachedNetworkImage(
                  imageUrl: article.urlToImage,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(color: themeColor),
                )
              : Container(height: 180, color: themeColor),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${article.source} • ${ref.watch(newsServiceProvider).formatTimeAgo(article.publishedAt)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterChipWidget extends ConsumerWidget {
  final String label;
  final bool active;

  const FilterChipWidget({super.key, required this.label, this.active = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeColorProvider);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: active ? themeColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: active ? [
          BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
        ] : [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
        ],
        border: Border.all(color: active ? Colors.transparent : Colors.grey[200]!),
      ),
      child: Text(
        label,
        style: TextStyle(color: active ? Colors.white : Colors.grey[700], fontWeight: FontWeight.bold),
      ),
    );
  }
}

class NewsFeedItem extends ConsumerWidget {
  final NewsArticle article;

  const NewsFeedItem({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeColorProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.source,
                  style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  article.title, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  article.description, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, 
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  ref.watch(newsServiceProvider).formatTimeAgo(article.publishedAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          if (article.urlToImage.isNotEmpty) ...[
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: article.urlToImage,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(width: 80, height: 80, color: themeColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
