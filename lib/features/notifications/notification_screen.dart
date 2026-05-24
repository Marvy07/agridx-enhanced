import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_provider.dart';
import '../../shared/services/weather_service.dart';
import 'package:weather/weather.dart';
import '../community/services/community_service.dart';
import '../community/models/community_models.dart';
import '../community/post_detail_screen.dart';
import '../../shared/services/auth_service.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  List<Map<String, dynamic>> _generateLiveNotifications(Weather? weather, List<CommunityPost> myPosts) {
    final notifications = <Map<String, dynamic>>[];

    // Add community notifications first
    for (var post in myPosts) {
      if (post.answersCount > 0) {
        notifications.add({
          'title': 'New Answer', 
          'body': '${post.answersCount} people answered your post "${post.title}"', 
          'time': 'Recent', 
          'icon': Icons.comment, 
          'color': Colors.green,
          'post': post
        });
      }
      if (post.likes > 0) {
        notifications.add({
          'title': 'New Like', 
          'body': '${post.likes} people liked your post "${post.title}"', 
          'time': 'Recent', 
          'icon': Icons.thumb_up, 
          'color': Colors.blue,
          'post': post
        });
      }
      if (post.dislikes > 0) {
        notifications.add({
          'title': 'Post Activity', 
          'body': 'Someone disliked your post "${post.title}"', 
          'time': 'Recent', 
          'icon': Icons.thumb_down, 
          'color': Colors.orange,
          'post': post
        });
      }
    }

    notifications.add({
      'title': 'Welcome to AgriDx!', 
      'body': 'Start scanning your crops today.', 
      'time': 'Just now', 
      'icon': Icons.waving_hand, 
      'color': Colors.orange
    });

    if (weather != null) {
      final double windSpeedKmh = (weather.windSpeed ?? 0) * 3.6;
      final description = weather.weatherDescription?.toLowerCase() ?? "";
      final bool isRaining = description.contains('rain') || 
                            description.contains('drizzle') || 
                            description.contains('storm');
      final temp = weather.temperature?.celsius ?? 20;
      final humidity = weather.humidity ?? 50;

      if (isRaining) {
        notifications.add({
          'title': 'Weather Alert: Rain', 
          'body': 'Rain is detected in your area. Avoid spraying pesticides today to prevent runoff.', 
          'time': 'Live Alert', 
          'icon': Icons.water_drop, 
          'color': Colors.blue
        });
      } else if (temp > 32) {
        notifications.add({
          'title': 'Heat Stress Warning', 
          'body': 'High temperatures (${temp.toStringAsFixed(1)}°C) detected. Ensure adequate irrigation for your crops.', 
          'time': 'Live Alert', 
          'icon': Icons.local_fire_department, 
          'color': Colors.deepOrange
        });
      }

      if (humidity > 75 && temp > 20 && temp < 30) {
        notifications.add({
          'title': 'Disease Risk High', 
          'body': 'High humidity ($humidity%) and warm temps create favorable conditions for fungal diseases like Blight or Mildew. Monitor your plants.', 
          'time': 'Live Alert', 
          'icon': Icons.warning_amber_rounded, 
          'color': Colors.redAccent
        });
      }

      if (windSpeedKmh > 15 && !isRaining) {
        notifications.add({
          'title': 'Spraying Advisory', 
          'body': 'High wind speed (${windSpeedKmh.toStringAsFixed(1)} km/h). Spraying is not recommended due to drift risk.', 
          'time': 'Live Alert', 
          'icon': Icons.air, 
          'color': Colors.blueGrey
        });
      }

      if (notifications.length <= (myPosts.isNotEmpty ? myPosts.length * 2 + 1 : 1)) {
        notifications.add({
          'title': 'Weather Update', 
          'body': 'Current conditions: ${weather.weatherDescription}. Temp: ${temp.toStringAsFixed(1)}°C. No immediate risks detected.', 
          'time': 'Live Alert', 
          'icon': Icons.cloud_done, 
          'color': Colors.green
        });
      }
    } else {
       notifications.add({
        'title': 'System Status', 
        'body': 'Fetching live weather and disease risk data...', 
        'time': 'Live', 
        'icon': Icons.sync, 
        'color': Colors.grey
      });
    }

    return notifications;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localizationProvider);
    final strings = ref.watch(localizationProvider.notifier).strings;
    final weatherAsync = ref.watch(currentWeatherProvider);
    final userAsync = ref.watch(userModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings['notifications'] ?? 'Notifications',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return weatherAsync.when(
              data: (weather) => _buildList(context, _generateLiveNotifications(weather, [])),
              loading: () => _buildList(context, _generateLiveNotifications(null, [])),
              error: (err, stack) => _buildList(context, _generateLiveNotifications(null, [])),
            );
          }
          
          final myPostsAsync = ref.watch(myPostsProvider(user.uid));
          return myPostsAsync.when(
            data: (myPosts) {
              return weatherAsync.when(
                data: (weather) => _buildList(context, _generateLiveNotifications(weather, myPosts)),
                loading: () => _buildList(context, _generateLiveNotifications(null, myPosts)),
                error: (err, stack) => _buildList(context, _generateLiveNotifications(null, myPosts)),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Map<String, dynamic>> notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        final post = notif['post'] as CommunityPost?;
        
        return Dismissible(
          key: Key('${notif['title']}_$index'),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification dismissed')),
            );
          },
          child: ListTile(
            onTap: post != null 
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
                  );
                } 
              : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: (notif['color'] as Color).withOpacity(0.1),
              child: Icon(notif['icon'] as IconData, color: notif['color'] as Color),
            ),
            title: Text(
              notif['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(notif['body'] as String),
                const SizedBox(height: 4),
                Text(
                  notif['time'] as String,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
