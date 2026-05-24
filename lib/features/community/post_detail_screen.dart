import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/community_models.dart';
import 'widgets/community_profile_modal.dart';
import 'services/community_service.dart';
import '../../shared/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final CommunityPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  late CommunityPost _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  @override
  void dispose() {
    _answerController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  void _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) return;

    final userAsync = ref.read(userModelProvider);
    userAsync.whenData((user) async {
      if (user == null) return;

      final newAnswer = CommunityAnswer(
        answerId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        userName: user.name,
        userAvatar: user.photoURL,
        body: _answerController.text.trim(),
        timestamp: DateTime.now(),
      );

      await ref.read(communityServiceProvider).addAnswer(_currentPost.postId, newAnswer);
      _answerController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userModelProvider).valueOrNull;
    final isPostBlocked = currentUser?.blockedUsers.contains(_currentPost.userId) ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (currentUser != null && currentUser.uid == _currentPost.userId)
            _buildPostMenu(context, ref, _currentPost),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                            onTap: () => showCommunityProfileModal(context, _currentPost.userId),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: _currentPost.userAvatar.isNotEmpty ? NetworkImage(_currentPost.userAvatar) : null,
                                  child: _currentPost.userAvatar.isEmpty ? const Icon(Icons.person) : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_currentPost.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('${_currentPost.userLocation} • ${DateFormat.yMMMd().format(_currentPost.timestamp)}', 
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          if (isPostBlocked)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'The content of this user is blocked.\nUnblock user to see it again.',
                                style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                              ),
                            )
                          else ...[
                            Text(_currentPost.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _buildPostBody(_currentPost.body),
                          ],

                          if (_currentPost.imageUrl.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: isPostBlocked
                                  ? ImageFiltered(
                                      imageFilter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Image.network(
                                        _currentPost.imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.network(
                              _currentPost.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: const Color(0xFF1B5E20),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 220,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.grey[100]!, Colors.grey[200]!],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: Colors.grey[400], size: 48),
                                      const SizedBox(height: 8),
                                      Text('Image unavailable', style: TextStyle(color: Colors.grey[500])),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Answers (${_currentPost.answersCount})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  
                  // Stream of answers
                  StreamBuilder<List<CommunityAnswer>>(
                    stream: ref.watch(communityServiceProvider).getAnswersStream(_currentPost.postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('No answers yet. Be the first to help!')),
                        );
                      }
                      
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (context, index) => const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final answer = snapshot.data![index];
                          final currentUser = ref.watch(userModelProvider).valueOrNull;
                          final isBlocked = currentUser?.blockedUsers.contains(answer.userId) ?? false;
                          
                          return _buildAnswerItem(answer, isBlocked);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Comment box at bottom
          if (isPostBlocked)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).padding.bottom + 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Text(
                'You cannot reply to a blocked user.',
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            )
          else
            Container(
              padding: EdgeInsets.only(
                left: 16, 
                right: 16, 
                top: 12, 
                bottom: MediaQuery.of(context).padding.bottom + 12
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _answerController,
                      focusNode: _replyFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Add an answer...',
                        fillColor: Colors.grey[100],
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _submitAnswer,
                    icon: const Icon(Icons.send, color: Color(0xFF1565C0)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerItem(CommunityAnswer answer, bool isBlocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => showCommunityProfileModal(context, answer.userId),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: answer.userAvatar.isNotEmpty ? NetworkImage(answer.userAvatar) : null,
                    child: answer.userAvatar.isEmpty ? const Icon(Icons.person, size: 16) : null,
                  ),
                  const SizedBox(width: 8),
                  Text(answer.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const Spacer(),
            Text(DateFormat.yMMMd().format(answer.timestamp), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        if (isBlocked)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'The content of this user is blocked.\nUnblock user to see it again.',
              style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.4),
            ),
          )
        else
          _buildAnswerBody(answer.body),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            final currentUser = ref.watch(userModelProvider).valueOrNull;
            final hasLiked = currentUser != null && answer.likedBy.contains(currentUser.uid);
            final hasDisliked = currentUser != null && answer.dislikedBy.contains(currentUser.uid);

            return Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (currentUser == null) return;
                    try {
                      await ref.read(communityServiceProvider).toggleLikeAnswer(_currentPost.postId, answer.answerId, currentUser.uid, true);
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission Denied: Please update your Firebase Rules!')));
                    }
                  },
                  child: Row(
                    children: [
                      Icon(hasLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined, size: 16, color: hasLiked ? Colors.blue : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${answer.likes}', style: TextStyle(color: hasLiked ? Colors.blue : Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () async {
                    if (currentUser == null) return;
                    try {
                      await ref.read(communityServiceProvider).toggleLikeAnswer(_currentPost.postId, answer.answerId, currentUser.uid, false);
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission Denied: Please update your Firebase Rules!')));
                    }
                  },
                  child: Row(
                    children: [
                      Icon(hasDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined, size: 16, color: hasDisliked ? Colors.red : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${answer.dislikes}', style: TextStyle(color: hasDisliked ? Colors.red : Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    _answerController.text = '@${answer.userName.replaceAll(' ', '_')} ';
                    _replyFocusNode.requestFocus();
                  },
                  child: Text('Reply', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                if (currentUser != null && (currentUser.uid == answer.userId || currentUser.uid == _currentPost.userId)) ...[
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () async {
                      bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Answer'),
                          content: const Text('Are you sure you want to delete this answer?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ) ?? false;
                      
                      if (confirm && context.mounted) {
                        try {
                          await ref.read(communityServiceProvider).deleteAnswer(_currentPost.postId, answer.answerId);
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission Denied: Post owners need rule updates to delete comments!')));
                        }
                      }
                    },
                    child: Text('Delete', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnswerBody(String body) {
    final List<String> parts = body.split(' ');
    List<TextSpan> spans = [];
    
    for (String part in parts) {
      if (part.startsWith('@')) {
        String cleanUsername = part.replaceAll(RegExp(r'[^\w\s@_-]'), '');
        cleanUsername = cleanUsername.replaceFirst('@', '');
        String searchName = cleanUsername.replaceAll('_', ' ');
        
        spans.add(
          TextSpan(
            text: '$part ',
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = () async {
              // Try exact match first
              var query = await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: cleanUsername).limit(1).get();
              if (query.docs.isEmpty) {
                // If not found, try replacing underscores with spaces (for our reply feature)
                query = await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: searchName).limit(1).get();
              }
              
              if (query.docs.isNotEmpty) {
                if (mounted) showCommunityProfileModal(context, query.docs.first.id);
              } else {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found')));
              }
            },
          )
        );
      } else {
        spans.add(TextSpan(text: '$part ', style: const TextStyle(color: Colors.black87)));
      }
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
        children: spans,
      ),
    );
  }

  Widget _buildPostBody(String body) {
    final List<String> parts = body.split(' ');
    List<TextSpan> spans = [];
    
    for (String part in parts) {
      if (part.startsWith('#')) {
        spans.add(TextSpan(text: '$part ', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)));
      } else {
        spans.add(TextSpan(text: '$part ', style: TextStyle(color: Colors.grey[800])));
      }
    }
    
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
        children: spans,
      ),
    );
  }

  // Helper to parse hashtags from body text
  List<String> _extractHashtags(String text) {
    final RegExp exp = RegExp(r"\B#\w\w+");
    return exp.allMatches(text).map((m) => m.group(0)!.substring(1)).toList();
  }

  Widget _buildPostMenu(BuildContext context, WidgetRef ref, CommunityPost post) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.black),
      onSelected: (value) async {
        if (value == 'edit') {
          _showEditPostSheet(post);
        } else if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Post'),
              content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(
                  onPressed: () => Navigator.pop(context, true), 
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          if (confirm == true) {
            try {
              await ref.read(communityServiceProvider).deletePost(post.postId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted successfully')));
                Navigator.pop(context); // Go back to community feed
              }
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting post: $e')));
            }
          }
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
      ],
    );
  }

  void _showEditPostSheet(CommunityPost post) {
    final titleController = TextEditingController(text: post.title);
    final bodyController = TextEditingController(text: post.body);
    bool isUpdating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24, left: 20, right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text('Edit Post', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Title of your question...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyController,
                    maxLines: 4,
                    onChanged: (val) => setSheetState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Describe your crop problem...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (bodyController.text.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: _extractHashtags(bodyController.text).map((tag) => 
                        Chip(label: Text('#$tag'), visualDensity: VisualDensity.compact)
                      ).toList(),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUpdating ? null : () async {
                        if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                          return;
                        }
                        setSheetState(() => isUpdating = true);
                        try {
                          final hashtags = _extractHashtags(bodyController.text);
                          
                          final updatedPost = CommunityPost(
                            postId: post.postId,
                            userId: post.userId,
                            userName: post.userName,
                            userLocation: post.userLocation,
                            userAvatar: post.userAvatar,
                            cropType: post.cropType,
                            cropEmoji: post.cropEmoji,
                            title: titleController.text.trim(),
                            body: bodyController.text.trim(),
                            hashtags: hashtags,
                            imageUrl: post.imageUrl,
                            likes: post.likes,
                            dislikes: post.dislikes,
                            answersCount: post.answersCount,
                            timestamp: post.timestamp,
                          );
                          
                          setState(() {
                            _currentPost = updatedPost;
                          });
                          
                          await ref.read(communityServiceProvider).updatePost(updatedPost);
                          
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post updated successfully!')));
                          }
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating post: $e')));
                        } finally {
                          if (context.mounted) setSheetState(() => isUpdating = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: isUpdating 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
