import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/localization_provider.dart';
import 'settings_screen.dart';
import '../notifications/notification_screen.dart';
import 'my_diagnoses_screen.dart';
import 'help_support_screen.dart';
import 'privacy_security_screen.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/user_model.dart';
import '../../core/theme_provider.dart';
import '../community/services/community_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localizationProvider);
    final l10n = ref.watch(localizationProvider.notifier).strings;
    final themeColor = ref.watch(themeColorProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n['profile']!,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
          ),
        ],
      ),
      body: ref.watch(userModelProvider).when(
        data: (user) {
          if (user == null) return const Center(child: Text("No user data found"));
          
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // Profile Card
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: user.photoURL.isNotEmpty 
                                ? NetworkImage(user.photoURL) 
                                : const NetworkImage('https://i.pravatar.cc/150?u=samuel'),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${user.farmerType} • ${user.location}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _showEditProfileDialog(context, ref, user),
                          icon: Icon(Icons.edit, size: 16, color: themeColor),
                          label: Text('Edit Profile', style: TextStyle(color: themeColor)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StatBadge(value: user.totalScans.toString(), label: 'Scans', color: themeColor),
                          StatBadge(value: user.totalDiagnoses.toString(), label: 'Diagnoses', color: themeColor),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
                const TabBar(
                  labelColor: Colors.black,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: 'General'),
                    Tab(text: 'Community'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // General Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
            // Menu Items
            MenuItem(
              icon: Icons.eco_outlined,
              iconColor: themeColor,
              label: l10n['my_diagnoses']!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyDiagnosesScreen())),
            ),
            MenuItem(
              icon: Icons.notifications_none,
              iconColor: Colors.orange,
              label: l10n['notifications']!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
            ),
            MenuItem(
              icon: Icons.help_outline,
              iconColor: Colors.blue,
              label: l10n['help_support']!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
            ),
            MenuItem(
              icon: Icons.shield_outlined,
              iconColor: Colors.grey,
              label: l10n['privacy_security']!,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySecurityScreen())),
            ),
            const SizedBox(height: 48),
            Text(l10n['app_version']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(l10n['ai_model']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(l10n['logout']!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                      // Community Tab
                      _buildCommunityTab(user),
                    ],
                  ),
                ),
              ],
            ),
          );
    },
    loading: () => Center(child: CircularProgressIndicator(color: themeColor)),
    error: (e, _) => Center(child: Text("Error: $e")),
  ),
);
}

Widget _buildCommunityTab(UserModel user) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Community Rank',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(user.rankIcon, style: const TextStyle(fontSize: 60)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${user.communityPoints} pts',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                user.rankName,
                style: const TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showEditProfileDialog(BuildContext context, WidgetRef ref, UserModel user) {
  final nameController = TextEditingController(text: user.name);
  final locationController = TextEditingController(text: user.location);
  String selectedFarmerType = user.farmerType;
  XFile? selectedImage;
  bool isUploading = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
                  if (image != null) {
                    setState(() => selectedImage = image);
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: selectedImage != null
                      ? (kIsWeb ? NetworkImage(selectedImage!.path) : FileImage(File(selectedImage!.path))) as ImageProvider
                      : (user.photoURL.isNotEmpty ? NetworkImage(user.photoURL) : const NetworkImage('https://i.pravatar.cc/150?u=samuel')),
                  child: selectedImage == null && user.photoURL.isEmpty
                      ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tap to change picture', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedFarmerType,
                items: ['Smallholder', 'Commercial', 'Student', 'Researcher', 'Agricultural Expert']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedFarmerType = val);
                },
                decoration: const InputDecoration(labelText: 'Farmer Type'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: isUploading ? null : () async {
              setState(() => isUploading = true);
              
              String updatedPhotoUrl = user.photoURL;

              try {
                if (selectedImage != null) {
                  final authService = ref.read(authServiceProvider);
                  final bytes = kIsWeb ? await selectedImage!.readAsBytes() : null;
                  final newUrl = await authService.uploadProfileImage(
                    userId: user.uid,
                    filePath: kIsWeb ? null : selectedImage!.path,
                    bytes: bytes,
                  );
                  
                  if (newUrl != null) {
                    updatedPhotoUrl = newUrl;
                  }
                }

                final updatedUser = user.copyWith(
                  name: nameController.text.trim(),
                  location: locationController.text.trim(),
                  farmerType: selectedFarmerType,
                  photoURL: updatedPhotoUrl,
                );
                
                await ref.read(authServiceProvider).updateUserProfile(updatedUser);
                
                // If the photo changed, sync it across community posts!
                if (updatedPhotoUrl != user.photoURL) {
                  await ref.read(communityServiceProvider).updateUserAvatar(user.uid, updatedPhotoUrl);
                }

                ref.invalidate(userModelProvider); // Refresh data
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                setState(() => isUploading = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: isUploading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
}

class StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const StatBadge({super.key, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  const MenuItem({super.key, required this.icon, required this.iconColor, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
