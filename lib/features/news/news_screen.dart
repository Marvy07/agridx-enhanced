import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/design/design.dart';
import '../../shared/services/news_service.dart';
import '../../shared/widgets/widgets.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});
  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  String _category = 'agriculture';
  static const _categories = [
    ('agriculture', 'Agriculture'),
    ('livestock', 'Livestock'),
    ('weather', 'Weather'),
    ('market', 'Markets'),
  ];

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(newsListProvider(_category));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Farm News')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding, vertical: 4),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final (val, label) = _categories[i];
                final active = val == _category;
                return GestureDetector(
                  onTap: () => setState(() => _category = val),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border: active ? null : Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: active ? Colors.white : AppColors.textSecondary,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: newsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, __) =>
                    AppShimmerBox(width: double.infinity, height: 90),
              ),
              error: (e, _) => AppEmptyState(
                icon: Icons.newspaper_outlined,
                title: 'News unavailable',
                message: 'Could not load news. Check your API key.',
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(newsListProvider),
              ),
              data: (articles) {
                if (articles.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.newspaper_outlined,
                    title: 'No articles found',
                    message: 'Try a different category.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: articles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _ArticleCard(article: articles[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: () async {
        final uri = Uri.tryParse(article.url);
        if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.urlToImage.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.cardRadius),
                bottomLeft: Radius.circular(AppSpacing.cardRadius),
              ),
              child: CachedNetworkImage(
                imageUrl: article.urlToImage,
                width: 100,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.backgroundAlt,
                  highlightColor: AppColors.surface,
                  child: Container(width: 100, height: 90, color: AppColors.backgroundAlt),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 100, height: 90,
                  color: AppColors.primarySurface,
                  child: const Icon(Icons.image_outlined, color: AppColors.textHint),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.source,
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    style: AppTextStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(article.publishedAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
