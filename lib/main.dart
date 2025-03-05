// Flutter imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ous/domain/theme_mode_provider.dart';
import 'package:ous/infrastructure/auth_service.dart';
import 'package:ous/presentation/pages/account/login_screen.dart';
import 'package:ous/presentation/pages/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'infrastructure/config/firebase_options.dart';

void main() async {
  // エラーハンドラーを設定
  FlutterError.onError = (FlutterErrorDetails details) {
    // キーボード関連のエラーを無視
    if (details.exception.toString().contains('hardware_keyboard')) {
      return;
    }
    // その他のエラーは通常通り処理
    FlutterError.presentError(details);
  };

  WidgetsFlutterBinding.ensureInitialized();

  // システム設定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ステータスバーを表示する設定を追加
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Firebaseの初期化 - グローバル変数で初期化状態を管理
  if (!_firebaseInitialized) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firebaseInitialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      // エラーが発生した場合は、既存のアプリを使用
      if (e.toString().contains('duplicate-app')) {
        _firebaseInitialized = true;
        print('Using existing Firebase app');
      }
    }
  } else {
    print('Firebase already initialized');
  }

  // SharedPreferencesの初期化
  final prefs = await SharedPreferences.getInstance();

  // AuthServiceの初期化
  final authService = AuthService(prefs);
  print('AuthService initialized with SharedPreferences');

  // ThemeNotifierの初期化
  final themeNotifier = ThemeNotifier(prefs);

  // 自動ログインは行わない

  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
        themeProvider.overrideWith((_) => themeNotifier),
      ],
      child: const MyApp(),
    ),
  );
}

// AuthServiceのプロバイダー
final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError();
});

// 認証状態のプロバイダー
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// グローバル変数として Firebase の初期化状態を管理
bool _firebaseInitialized = false;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
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
              return const MainScreen();
            }
          },
          loading: () => const LoadingScreen(),
          error: (error, stackTrace) => const ErrorScreen(),
        ),
      ),
    );
  }
}
