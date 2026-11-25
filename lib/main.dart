import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/app_constraints.dart';
import 'core/router.dart';
import 'shared/services/auth_service.dart';
import 'firebase_options.dart';
import 'shared/services/diagnosis_service.dart';
import 'shared/services/notification_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/settings_provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.initialize();
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  await DiagnosisService.initialize();

  await Hive.initFlutter();
  await Hive.openBox('user_preferences');

  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const AgriDxApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AgriDxApp extends ConsumerStatefulWidget {
  const AgriDxApp({super.key});

  @override
  ConsumerState<AgriDxApp> createState() => _AgriDxAppState();
}

class _AgriDxAppState extends ConsumerState<AgriDxApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationRouting();
  }

  void _setupNotificationRouting() async {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);
    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationClick(initialMsg);
      });
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    final postId = message.data['postId']?.toString();
    final type = message.data['type']?.toString();

    if (postId != null && type == 'new_answer') {
      final router = ref.read(routerProvider);
      router.go('/community/$postId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'AgriDx',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF4CAF50),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.light().textTheme,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      builder: (context, child) => AppConstraints(child: child!),
    );
  }
}
