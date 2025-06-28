// File: lib/main.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';

// FFI for desktop sqflite
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/db_helper.dart';
import 'helpers/notification_helper.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';

import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/db_viewer_screen.dart';
import 'screens/staff/staff_home_screen.dart';
import 'screens/teacher/teacher_home_screen.dart';
import 'screens/teacher/add_complaint_screen.dart';

import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'auth/forgot_password_screen.dart';
import 'auth/reset_password_screen.dart';
import 'auth/change_password_screen.dart';
import 'auth/profile_screen.dart';

// Firebase (used only on mobile/web)
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _firebaseBackgroundHandler(RemoteMessage msg) async {
  await Firebase.initializeApp();
  await NotificationHelper.instance.showNotification(msg);
}

final List<RemoteMessage> _pendingMessages = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite FFI for desktop platforms
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Firebase on mobile/web only
  final useFirebase = kIsWeb || Platform.isAndroid || Platform.isIOS;
  if (useFirebase) {
    await Firebase.initializeApp();
    await NotificationHelper.instance.initialize();
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    FirebaseMessaging.onMessage.listen((msg) {
      NotificationHelper.instance.showNotification(msg);
      _pendingMessages.add(msg);
    });
  }

  // Init & export DB on all non-web
  if (!kIsWeb) {
    await DBHelper.initDb();
    await DBHelper.exportDatabase();
  }

  // **Wrap MyApp in your providers** so MyApp.initState can read them
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Now NotificationProvider is available here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifProv = context.read<NotificationProvider>();
      for (var msg in _pendingMessages) {
        final n = msg.notification;
        if (n != null) notifProv.add(title: n.title ?? '', body: n.body ?? '');
      }
      _pendingMessages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (ctx, theme, auth, _) {
        return MaterialApp(
          title: 'University Asset Maintenance',
          debugShowCheckedModeBanner: false,
          themeMode: theme.mode,
          theme: ThemeData(
              brightness: Brightness.light, primarySwatch: Colors.blue),
          darkTheme: ThemeData(
              brightness: Brightness.dark, primarySwatch: Colors.deepPurple),
          home: const AuthWrapper(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/forgot-password': (_) => const ForgotPasswordScreen(),
            '/reset-password': (_) => const ResetPasswordScreen(),
            '/change-password': (_) => const ChangePasswordScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/notifications': (_) => const NotificationsScreen(),
            '/admin-dashboard': (_) => const AdminDashboardScreen(),
            '/staff-home': (_) => const StaffHomeScreen(),
            '/teacher-home': (_) => const TeacherHomeScreen(),
            '/add-complaint': (_) => const AddComplaintScreen(),
            '/db-viewer': (_) => const DbViewerScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const HomeScreen();
    switch (user.role) {
      case 'supervisor':
        return const DbViewerScreen();
      case 'admin':
        return const AdminDashboardScreen();
      case 'staff':
        return const StaffHomeScreen();
      case 'teacher':
      default:
        return const TeacherHomeScreen();
    }
  }
}
