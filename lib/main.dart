import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_todo/pages/login_screen.dart';
import 'package:flutter_todo/pages/register.dart';
import 'package:flutter_todo/pages/store_list.dart';
import 'package:flutter_todo/view_models/login_view_model.dart';
import 'package:flutter_todo/view_models/register_view_model.dart';
import 'package:flutter_todo/view_models/store_list_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final fcm = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");

  @override
  void initState() {
    super.initState();
    setupNotifications();
  }

  void setupNotifications() async {
    final notificationSettings = await fcm.requestPermission(
        alert: true,
        sound: true,
        badge: true,
        criticalAlert: true,
        carPlay: true,
        announcement: true);
    fcm.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      fcm.getToken().then((token) {
        print("FCM Token =====>>> $token");
      });
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
                  create: (context) => RegisterViewModel(),
                  child: RegisterPage(),
                )));
  }

  @override
  Widget build(BuildContext context) {
    print(
        "User is Logged In or Not ${FirebaseAuth.instance.currentUser == null}");

    return MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.language,
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      navigatorKey: navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FirebaseAuth.instance.currentUser == null
          ? ChangeNotifierProvider(
              create: (context) => LoginViewModel(),
              child: LoginScreen(),
            )
          : ChangeNotifierProvider(
              create: (context) => StoreListViewModel(),
              child: StoresList(),
            ),
    );
  }
}
