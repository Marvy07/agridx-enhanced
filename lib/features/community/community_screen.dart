import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/design.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/widgets/widgets.dart';
import 'models/community_models.dart';
import 'services/community_service.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});
  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Crops', 'Animals', 'Weather', 'General'];

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityPostsProvider((
      cropType: _filter,
      searchQuery: '',
      limit: 20,
    )));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showNewPostSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding, vertical: 4),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final active = f == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border: active ? null : Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      f,
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
            child: postsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, __) =>
                    AppShimmerBox(width: double.infinity, height: 100),
              ),
              error: (e, _) => AppEmptyState(
                icon: Icons.forum_outlined,
                title: 'Could not load posts',
                message: e.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(communityPostsProvider),
              ),
              data: (posts) {
                if (posts.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.forum_outlined,
                    title: 'No posts yet',
                    message: 'Be the first to start a conversation.',
                    actionLabel: 'Post something',
                    onAction: () => _showNewPostSheet(context),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _PostCard(
                    post: posts[i],
                    onTap: () => context.push(
                      '/community/${posts[i].postId}',
                      extra: posts[i],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showNewPostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _NewPostSheet(),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onTap});
  final CommunityPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  (post.userName.isNotEmpty ? post.userName[0] : '?').toUpperCase(),
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.userName, style: AppTextStyles.labelLarge),
                    Text(_timeAgo(post.timestamp), style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (post.cropType.isNotEmpty && post.cropType != 'All')
                AppChip(label: post.cropType),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.title,
            style: AppTextStyles.h4,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (post.body.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              post.body,
              style: AppTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text('${post.answersCount} replies', style: AppTextStyles.caption),
              const SizedBox(width: 12),
              Icon(Icons.thumb_up_outlined, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text('${post.likes}', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _NewPostSheet extends ConsumerStatefulWidget {
  const _NewPostSheet();
  @override
  ConsumerState<_NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends ConsumerState<_NewPostSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _category = 'General';
  bool _loading = false;

  static const _categories = ['Crops', 'Animals', 'Weather', 'General'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final service = ref.read(communityServiceProvider);
      final authService = ref.read(authServiceProvider);
      final user = authService.authStateChanges.first;
      final u = await user;
      final post = CommunityPost(
        postId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: u?.uid ?? 'guest',
        userName: u?.displayName ?? 'Farmer',
        userLocation: '',
        userAvatar: u?.photoURL ?? '',
        cropType: _category,
        cropEmoji: '',
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        hashtags: [],
        timestamp: DateTime.now(),
      );
      await service.addPost(post);
      if (mounted) {
        Navigator.pop(context);
        ref.invalidate(communityPostsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('New Post', style: AppTextStyles.h3),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(hintText: 'Title or question...'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _bodyCtrl,
            decoration: const InputDecoration(hintText: 'Add more details (optional)...'),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            children: _categories.map((c) {
              final active = c == _category;
              return GestureDetector(
                onTap: () => setState(() => _category = c),
                child: AppChip(
                  label: c,
                  color: active ? AppColors.primary : AppColors.primarySurface,
                  textColor: active ? Colors.white : AppColors.primary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: 'Post', isLoading: _loading, onPressed: _submit),
        ],
      ),
    );
  }
}
