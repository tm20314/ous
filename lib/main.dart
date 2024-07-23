// Flutter imports:
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Project imports:
import 'package:ous/controller/firebase_provider.dart';
import 'package:ous/domain/bus_service_provider.dart';
import 'package:ous/domain/converters/date_time_timestamp_converter.dart';
import 'package:ous/domain/share_preferences_instance.dart';
import 'package:ous/domain/theme_mode_provider.dart';
import 'package:ous/infrastructure/notification_service.dart';
import 'package:ous/presentation/pages/account/login_screen.dart';
import 'package:ous/presentation/pages/main_screen.dart';
import 'package:ous/presentation/widgets/home/mylog_status_button.dart';

import 'infrastructure/config/firebase_options.dart';

void main() async {
  // Flutterの初期化
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // SharedPreferencesの初期化
  await SharedPreferencesInstance.initialize();

  // Firebaseの初期化
  await initializeFirebase();

  // Firestoreの設定
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // 画面の向きを縦固定に設定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ナビゲーションバーの背景色を透明に設定
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Providerの初期化
  final container = ProviderContainer();
  await container.read(busServiceProvider.notifier).fetchBusInfo();
  await container.read(myLogStatusProvider.notifier).fetchMyLogStatus();

  // ローカル通知の初期化と権限のリクエスト
  try {
    await LocalNotifications.init();
    await _requestPermissions();
  } catch (e) {
    print('Error initializing notifications: $e');
  }

  // スプラッシュスクリーンの削除
  FlutterNativeSplash.remove();

  // アプリの起動
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MainApp(),
    ),
  );
}

// ローカル通知の権限をリクエスト
Future<void> _requestPermissions() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  if (Platform.isIOS || Platform.isMacOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  } else if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }
}

// Firebaseの初期化
Future<void> initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangeProvider);
    final theme = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, widget) => MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ja'),
        ],
        theme: ThemeData(
          colorSchemeSeed: theme.primarySwatch,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: theme.primarySwatch,
          brightness: Brightness.dark,
        ),
        themeMode: theme.mode,
        home: authState.when(
          data: (user) {
            if (user == null) {
              return const Login();
            } else {
              return MainScreen();
            }
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => const Scaffold(
            body: Center(
              child: Text('Error'),
            ),
          ),
        ),
      ),
    );
  }
}
