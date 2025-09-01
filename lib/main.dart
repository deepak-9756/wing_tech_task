import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  // “testwtsm@gmail.com” / “wts@123”
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await DatabaseService.instance.database;

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
