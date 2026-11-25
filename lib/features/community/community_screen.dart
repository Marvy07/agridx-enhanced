import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/community_profile_modal.dart';
import '../notifications/notification_screen.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/user_model.dart';
import 'services/community_service.dart';
import 'models/community_models.dart';
import 'post_detail_screen.dart';
import 'crop_selector_screen.dart';
import 'services/crop_filters_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Removed local CommunityPostData in favor of community_models.dart

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  int _postLimit = 10;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postBodyController = TextEditingController();
  String _selectedPostCrop = 'Corn';
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;
  double _uploadProgress = 0;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _postTitleController.dispose();
    _postBodyController.dispose();
    super.dispose();
  }

  static TextSpan _normal(String text) => TextSpan(text: text, style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4));
  static TextSpan _hash(String text) => TextSpan(text: text, style: const TextStyle(color: Colors.blue, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500));

  // Helper to parse hashtags from body text
  List<String> _extractHashtags(String text) {
    final RegExp exp = RegExp(r"\B#\w\w+");
    return exp.allMatches(text).map((m) => m.group(0)!.substring(1)).toList();
  }

  void _showCreatePostSheet() {
    _postTitleController.clear();
    _postBodyController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder( // Use StatefulBuilder for crop picker in bottom sheet
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: const Text(
                          'New Post',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ref.read(cropFiltersProvider).map((filter) {
                        final isSelected = _selectedPostCrop == filter.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text('${filter.emoji} ${filter.name}'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setSheetState(() {
                                _selectedPostCrop = filter.name;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPhotoUploadSection(setSheetState),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _postTitleController,
                    decoration: InputDecoration(
                      hintText: 'Title of your question...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _postBodyController,
                    maxLines: 4,
                    onChanged: (val) => setSheetState(() {}), // Trigger hashtag update
                    decoration: InputDecoration(
                      hintText: 'Describe your crop problem...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Simple Hashtag suggestions
                  if (_postBodyController.text.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: _extractHashtags(_postBodyController.text).map((tag) => 
                        Chip(label: Text('#$tag'), visualDensity: VisualDensity.compact)
                      ).toList(),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final userAsync = ref.watch(userModelProvider);
                        return ElevatedButton(
                          onPressed: userAsync.when(
                            data: (user) => user == null || _isUploading ? null : () async {
                              if (_postTitleController.text.trim().isEmpty || _postBodyController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                                return;
                              }

                              setSheetState(() => _isUploading = true);

                              try {
                                String imageUrl = '';
                                if (_selectedImageBytes != null) {
                                    try {
                                      imageUrl = await ref.read(communityServiceProvider).uploadPostImage(
                                        userId: user.uid, 
                                        bytes: kIsWeb ? _selectedImageBytes : null,
                                        filePath: kIsWeb ? null : _selectedImagePath,
                                        onProgress: (progress) {
                                          setSheetState(() {
                                            _uploadProgress = progress;
                                          });
                                        },
                                      ) ?? '';
                                    
                                    if (imageUrl.isEmpty && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Post shared. Image upload failed — you can edit later.'))
                                      );
                                    }
                                  } catch (uploadError) {
                                    print('Handled upload error: $uploadError');
                                    imageUrl = '';
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Post shared. Image upload failed — you can edit later.'))
                                      );
                                    }
                                  }
                                }

                                final hashtags = _extractHashtags(_postBodyController.text);
                                final cropEmoji = ref.read(cropFiltersProvider).firstWhere((f) => f.name == _selectedPostCrop).emoji;
                                
                                final newPost = CommunityPost(
                                  postId: DateTime.now().millisecondsSinceEpoch.toString(),
                                  userId: user.uid,
                                  userName: user.name,
                                  userLocation: user.location,
                                  userAvatar: user.photoURL,
                                  userRole: user.farmerType,
                                  cropType: _selectedPostCrop,
                                  cropEmoji: cropEmoji,
                                  title: _postTitleController.text.trim(),
                                  body: _postBodyController.text.trim(),
                                  hashtags: hashtags,
                                  imageUrl: imageUrl,
                                  timestamp: DateTime.now(),
                                );
                                
                                await ref.read(communityServiceProvider).addPost(newPost);
                                print('Post saved to Firestore with imageUrl: ${newPost.imageUrl}');
                                
                                // Clear state after successful post
                                setSheetState(() {
                                  _selectedImage = null;
                                  _selectedImageBytes = null;
                                  _selectedImagePath = null;
                                  _isUploading = false;
                                  _uploadProgress = 0;
                                });

                                // Refresh feed
                                ref.refresh(communityPostsProvider((cropType: _selectedFilter, searchQuery: _searchQuery, limit: _postLimit)));

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  if (imageUrl.isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post shared successfully!')));
                                  }
                                }
                              } catch (e) {
                                print('Final post error: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing post: $e')));
                                }
                              } finally {
                                if (context.mounted) {
                                  setSheetState(() => _isUploading = false);
                                }
                              }
                            },
                            error: (e, s) => null,
                            loading: () => null,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: _isUploading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              ),
            );
          }
        );
      },
    ).then((_) {
      setState(() {
        _selectedImage = null;
        _selectedImageBytes = null;
        _selectedImagePath = null;
        _isUploading = false;
        _uploadProgress = 0;
      });
    });
  }

  Widget _buildPhotoUploadSection(StateSetter setSheetState) {
    if (_selectedImageBytes != null) {
      return Stack(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _selectedImageBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setSheetState(() {
                _selectedImage = null;
                _selectedImageBytes = null;
                _selectedImagePath = null;
              }),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          if (_isUploading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => _showImageSourceOptions(setSheetState),
      child: CustomPaint(
        painter: DashedRectPainter(color: Colors.grey[400]!),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, color: Colors.grey[600], size: 32),
                  const SizedBox(width: 16),
                  Icon(Icons.image, color: Colors.grey[600], size: 32),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Add Photo',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAskCommunityButton() {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1976D2).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            gradient: const LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ElevatedButton.icon(
            onPressed: () => _showCreatePostSheet(),
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            label: const Text('Ask Community', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceOptions(StateSetter setSheetState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, setSheetState);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, setSheetState);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, StateSetter setSheetState) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setSheetState(() {
          _selectedImage = image;
          _selectedImageBytes = bytes;
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search in Community',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => ref.refresh(communityPostsProvider((cropType: _selectedFilter, searchQuery: _searchQuery, limit: _postLimit))),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter by', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CropSelectorScreen()),
                    );
                  },
                  child: Text('Change', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer(
              builder: (context, ref, child) {
                final visibleFilters = ref.watch(visibleCropFiltersProvider);
                final filters = visibleFilters.map((f) => {'name': f.name, 'emoji': f.emoji}).toList();

                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: const Text('🌍 All'),
                        selected: _selectedFilter == 'All',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = 'All';
                            });
                          }
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.blue[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: _selectedFilter == 'All' ? Colors.blue : Colors.grey[300]!,
                            width: _selectedFilter == 'All' ? 1.5 : 1,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: _selectedFilter == 'All' ? Colors.blue[800] : Colors.black87,
                          fontWeight: _selectedFilter == 'All' ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    ...filters.map((filter) {
                      final isSelected = _selectedFilter == filter['name'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text('${filter['emoji']} ${filter['name']}'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (isSelected) {
                                _selectedFilter = 'All'; // Deselecting reverts to unfiltered
                              } else {
                                _selectedFilter = filter['name']!;
                              }
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Colors.blue[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? Colors.blue : Colors.grey[300]!,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue[800] : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey[200], thickness: 4),

          // Posts List
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final postsAsync = ref.watch(communityPostsProvider((cropType: _selectedFilter, searchQuery: _searchQuery, limit: _postLimit)));
                final currentUser = ref.watch(userModelProvider).valueOrNull;
                
                return postsAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const Center(child: Text('No posts found.'));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.refresh(communityPostsProvider((cropType: _selectedFilter, searchQuery: _searchQuery, limit: _postLimit)));
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      color: const Color(0xFF1B5E20),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == posts.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _postLimit += 10;
                                  });
                                },
                                child: const Text('Load More'),
                              ),
                            );
                          }
                          final post = posts[index];
                          
                          // Check if post author is blocked
                          final isBlocked = currentUser?.blockedUsers.contains(post.userId) ?? false;
                          
                          return _buildPostCard(post, isBlocked);
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostSheet,
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          'Ask Community',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPostCard(CommunityPost post, bool isBlocked) {
    // Determine colors based on crop
    Color cropColor = Colors.green;
    switch (post.cropType) {
      case 'Corn': cropColor = const Color(0xFFF9A825); break;
      case 'Tomato': cropColor = Colors.red[600]!; break;
      case 'Cassava': cropColor = const Color(0xFFE65100); break;
      case 'Rice': cropColor = const Color(0xFF2E7D32); break;
      case 'Pepper': cropColor = const Color(0xFFB71C1C); break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Graphic Header
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cropColor.withOpacity(0.15),
                    cropColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: post.imageUrl.isNotEmpty 
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: isBlocked
                        ? ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Image.network(
                              post.imageUrl,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.network(
                            post.imageUrl,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 220,
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
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.grey[100]!, Colors.grey[200]!],
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.spa, size: 48, color: cropColor.withOpacity(0.4)),
                        const SizedBox(height: 8),
                        Text(post.cropType, style: TextStyle(color: cropColor.withOpacity(0.6), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => showCommunityProfileModal(context, post.userId),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: 16,
                          backgroundImage: post.userAvatar.isNotEmpty ? NetworkImage(post.userAvatar) : null,
                          child: post.userAvatar.isEmpty ? Icon(Icons.person, color: Colors.grey[500], size: 20) : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () => showCommunityProfileModal(context, post.userId),
                                    child: Text(
                                      post.userName,
                                      style: TextStyle(
                                        color: Colors.blue[800],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                if (post.userRole == 'Agricultural Expert' || post.userRole == 'Researcher') ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.blue[100]!),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified, size: 10, color: Colors.blue[700]),
                                        const SizedBox(width: 2),
                                        Text(
                                          post.userRole == 'Agricultural Expert' ? 'Expert' : 'Researcher',
                                          style: TextStyle(
                                            color: Colors.blue[850],
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const Text(' • ', style: TextStyle(color: Colors.grey)),
                                Flexible(
                                  child: Text(
                                    DateFormat.yMMMd().format(post.timestamp),
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              post.userLocation,
                              style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cropColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          post.cropType,
                          style: TextStyle(color: cropColor, fontSize: 11, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final user = ref.watch(userModelProvider).valueOrNull;
                          if (user != null && user.uid == post.userId) {
                            return _buildPostMenu(context, ref, post);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (isBlocked)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'The content of this user is blocked.\nUnblock user to see it again.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
                      ),
                    )
                  else ...[
                    Text(
                      post.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildPostBody(post.body),
                  ],

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${post.answersCount} answers', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 8),

                  // Reactions
                  Consumer(
                    builder: (context, ref, child) {
                      final userAsync = ref.watch(userModelProvider);
                      return userAsync.when(
                        data: (user) {
                          final isLiked = user?.likedPosts.contains(post.postId) ?? false;
                          final isDisliked = user?.dislikedPosts.contains(post.postId) ?? false;
                          
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (user != null) {
                                    try {
                                      await ref.read(communityServiceProvider).toggleLikePost(post.postId, user.uid, true);
                                    } catch (e) {
                                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission Denied: Please update your Firebase Rules!')));
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isLiked ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined, 
                                            size: 18, color: isLiked ? Colors.blue : Colors.grey[600]),
                                          const SizedBox(width: 6),
                                          Text('${post.likes}', style: TextStyle(fontWeight: isLiked ? FontWeight.bold : FontWeight.normal, color: isLiked ? Colors.blue : Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  if (user != null) {
                                    try {
                                      await ref.read(communityServiceProvider).toggleLikePost(post.postId, user.uid, false);
                                    } catch (e) {
                                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permission Denied: Please update your Firebase Rules!')));
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDisliked ? Colors.red.withOpacity(0.1) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(isDisliked ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined, 
                                            size: 18, color: isDisliked ? Colors.red : Colors.grey[600]),
                                          const SizedBox(width: 6),
                                          Text('${post.dislikes}', style: TextStyle(fontWeight: isDisliked ? FontWeight.bold : FontWeight.normal, color: isDisliked ? Colors.red : Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.reply, size: 18, color: Colors.grey[700]),
                                    const SizedBox(width: 6),
                                    Text('Reply', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const Text('...'),
                        error: (_, __) => const Icon(Icons.error, size: 20),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildPostMenu(BuildContext context, WidgetRef ref, CommunityPost post) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
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
                ref.refresh(communityPostsProvider((cropType: _selectedFilter, searchQuery: _searchQuery, limit: _postLimit)));
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
    String selectedCrop = post.cropType;
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ref.read(cropFiltersProvider).map((filter) {
                        final isSelected = selectedCrop == filter.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text('${filter.emoji} ${filter.name}'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setSheetState(() => selectedCrop = filter.name);
                            },
                          ),
                        );
                      }).toList(),
                    ),
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
                          final cropEmoji = ref.read(cropFiltersProvider).firstWhere((f) => f.name == selectedCrop, orElse: () => CropFilter(name: 'All', emoji: '🌍')).emoji;
                          
                          final updatedPost = CommunityPost(
                            postId: post.postId,
                            userId: post.userId,
                            userName: post.userName,
                            userLocation: post.userLocation,
                            userAvatar: post.userAvatar,
                            cropType: selectedCrop,
                            cropEmoji: cropEmoji,
                            title: titleController.text.trim(),
                            body: bodyController.text.trim(),
                            hashtags: hashtags,
                            imageUrl: post.imageUrl,
                            likes: post.likes,
                            dislikes: post.dislikes,
                            answersCount: post.answersCount,
                            timestamp: post.timestamp,
                          );
                          
                          await ref.read(communityServiceProvider).updatePost(updatedPost);
                          ref.refresh(communityPostsProvider((cropType: _selectedFilter, searchQuery: _searchQuery, limit: _postLimit)));
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

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    final Path dashedPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
