import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_provider.dart';
import '../../core/settings_provider.dart';
import 'language_selection_screen.dart';
import 'region_selection_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String selectedRegion = 'Centre';
  String selectedTempUnit = 'Celsius';

  void _showTempUnitDialog() {
    final l10n = ref.watch(localizationProvider.notifier).strings;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n['temp_units']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Celsius (°C)'),
                value: 'Celsius',
                groupValue: selectedTempUnit,
                onChanged: (value) {
                  setState(() => selectedTempUnit = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Fahrenheit (°F)'),
                value: 'Fahrenheit',
                groupValue: selectedTempUnit,
                onChanged: (value) {
                  setState(() => selectedTempUnit = value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Kelvin (K)'),
                value: 'Kelvin',
                groupValue: selectedTempUnit,
                onChanged: (value) {
                  setState(() => selectedTempUnit = value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n['cancel']!),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n['save']!),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localizationProvider);
    final l10n = ref.watch(localizationProvider.notifier).strings;
    final langName = ref.read(localizationProvider.notifier).languageName;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Modern light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n['settings']!,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(l10n['general']!),
              _buildCardGroup(
                children: [
                  _buildSettingsTile(
                    title: l10n['select_language']!,
                    subtitle: langName,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    title: l10n['app_region']!,
                    subtitle: selectedRegion,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegionSelectionScreen()),
                      );
                      if (result != null) {
                        setState(() => selectedRegion = result);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n['notifications']!),
              _buildCardGroup(
                children: [
                  _buildNotificationTile(
                    title: l10n['crops_info']!,
                    subtitle: l10n['push_notif']!,
                    value: settings.receiveCropsNotif,
                    onChanged: (v) => settingsNotifier.toggleReceiveCropsNotif(v),
                  ),
                  _buildDivider(),
                  _buildNotificationTile(
                    title: l10n['popular_posts']!,
                    subtitle: l10n['push_notif']!,
                    value: settings.receivePopularPostsNotif,
                    onChanged: (v) => settingsNotifier.toggleReceivePopularPostsNotif(v),
                  ),
                  _buildDivider(),
                  _buildNotificationTile(
                    title: l10n['answer_post']!,
                    subtitle: l10n['push_notif']!,
                    value: settings.receiveAnswerNotif,
                    onChanged: (v) => settingsNotifier.toggleReceiveAnswerNotif(v),
                  ),
                  _buildDivider(),
                  _buildNotificationTile(
                    title: l10n['upvote_post']!,
                    subtitle: l10n['push_notif']!,
                    value: settings.receiveUpvoteNotif,
                    onChanged: (v) => settingsNotifier.toggleReceiveUpvoteNotif(v),
                  ),
                  _buildDivider(),
                  _buildNotificationTile(
                    title: l10n['new_follower']!,
                    subtitle: l10n['push_notif']!,
                    value: settings.receiveFollowerNotif,
                    onChanged: (v) => settingsNotifier.toggleReceiveFollowerNotif(v),
                  ),
                  _buildDivider(),
                  _buildNotificationTile(
                    title: l10n['following_post']!,
                    subtitle: l10n['push_notif']!,
                    value: settings.receiveFollowingPostNotif,
                    onChanged: (v) => settingsNotifier.toggleReceiveFollowingPostNotif(v),
                  ),
                  _buildDivider(),
                  _buildNotificationTile(
                    title: l10n['comment_following']!,
                    subtitle: l10n['push_notif']!,
                    value: settings.receiveCommentNotif,
                    onChanged: (v) => settingsNotifier.toggleReceiveCommentNotif(v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n['weather']!),
              _buildCardGroup(
                children: [
                  _buildSettingsTile(
                    title: l10n['temp_units']!,
                    subtitle: l10n['temp_units_desc']! + selectedTempUnit,
                    onTap: _showTempUnitDialog,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n['other']!),
              _buildCardGroup(
                children: [
                  _buildNotificationTile(
                    title: l10n['google_analytics']!,
                    subtitle: l10n['google_analytics_desc']!,
                    value: settings.googleAnalytics,
                    onChanged: (v) => settingsNotifier.toggleGoogleAnalytics(v),
                  ),
                  _buildDivider(),
                  _buildNotificationTile(
                    title: l10n['crash_reporting']!,
                    subtitle: l10n['crash_reporting_desc']!,
                    value: settings.crashReporting,
                    onChanged: (v) => settingsNotifier.toggleCrashReporting(v),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCardGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Divider(height: 1, thickness: 1, color: Colors.grey[100]),
    );
  }

  Widget _buildSettingsTile({required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF43A047),
      ),
    );
  }
}
