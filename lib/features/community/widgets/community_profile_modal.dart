import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/theme_provider.dart';
import '../services/community_service.dart';
import '../../../shared/services/auth_service.dart';

void showCommunityProfileModal(BuildContext context, String userId) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: CommunityProfileModal(userId: userId),
    ),
  );
}

class CommunityProfileModal extends ConsumerWidget {
  final String userId;

  const CommunityProfileModal({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColor = ref.watch(themeColorProvider);
    final currentUserData = ref.watch(userModelProvider).valueOrNull;

    if (currentUserData == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const SizedBox(
              height: 200,
              child: Center(child: Text("User not found.")),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final user = UserModel.fromMap({
            ...userData,
            'uid': userId,
          });

          bool isFollowing = currentUserData.following.contains(userId);
          bool isBlocked = currentUserData.blockedUsers.contains(userId);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            if (user.farmerType == 'Agricultural Expert' || user.farmerType == 'Researcher')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[300]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 14, color: Colors.blue[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      user.farmerType == 'Agricultural Expert' ? 'Verified Expert' : 'Researcher',
                                      style: TextStyle(
                                        color: Colors.blue[800],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.stars, color: Colors.grey[700], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${user.communityPoints}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Body content
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: (user.farmerType == 'Agricultural Expert' || user.farmerType == 'Researcher')
                          ? Border.all(color: Colors.blue[400]!, width: 3.5)
                          : Border.all(color: Colors.white, width: 1.5),
                      boxShadow: (user.farmerType == 'Agricultural Expert' || user.farmerType == 'Researcher')
                          ? [BoxShadow(color: Colors.blue.withOpacity(0.15), blurRadius: 8, spreadRadius: 1)]
                          : null,
                      image: user.photoURL.isNotEmpty
                          ? DecorationImage(image: NetworkImage(user.photoURL), fit: BoxFit.cover)
                          : const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?u=samuel')),
                    ),
                    child: user.photoURL.isEmpty
                        ? Icon(Icons.person, size: 50, color: themeColor)
                        : null,
                  ),
                  const SizedBox(width: 24),
                  // Info Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.work_outline, user.farmerType),
                        const Divider(height: 12, thickness: 1),
                        _buildInfoRow(Icons.location_on_outlined, user.location.isNotEmpty ? user.location : 'Unknown'),
                        const Divider(height: 12, thickness: 1),
                        _buildInfoRow(Icons.chat_bubble_outline, user.language),
                        const Divider(height: 12, thickness: 1),
                        _buildInfoRow(Icons.emoji_events_outlined, user.rankName),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      await ref.read(communityServiceProvider).reportUser(currentUserData.uid, userId, 'Inappropriate behavior');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report sent to admin.')));
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                    child: const Text('Report', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () async {
                      await ref.read(communityServiceProvider).toggleBlock(currentUserData.uid, userId);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBlocked ? 'User unblocked.' : 'User blocked.')));
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                    child: Text(isBlocked ? 'Unblock User' : 'Block User', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              if (!isBlocked)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      await ref.read(communityServiceProvider).toggleFollow(currentUserData.uid, userId);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isFollowing ? 'Unfollowed user.' : 'Followed user!')));
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.blue[800]),
                    child: Text(isFollowing ? 'Unfollow' : 'Follow', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[800]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
