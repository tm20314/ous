import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ous/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:ous/home.dart';
import 'package:ous/review.dart';
import 'package:ous/info/info.dart';
import 'account/login.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ここに追加

  // Firebaseの初期化
  await Firebase.initializeApp();

  // 画面回転無効化
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(392, 759),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('ja'),
              ],
              locale: const Locale('ja'),
              debugShowCheckedModeBanner: false,
              title: 'ホーム',
              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.lightGreen,
                fontFamily: 'NotoSansCJKJp',
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                useMaterial3: true,
                colorSchemeSeed: Colors.lightGreen,
                fontFamily: 'NotoSansCJKJp',
              ),
              home: SplashScreen());
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//アップデート通知
  late String _currentVersion;
  late String _latestVersion;
//クイックショートカット
  String shortcut = 'no action set';

  @override
  void initState() {
    super.initState();
    _checkVersion();
    //ショートカット関連
  }

//バージョンチェック
  void _checkVersion() async {
    WidgetsFlutterBinding.ensureInitialized();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    setState(() {
      _currentVersion = version;
    });

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('config')
        .doc('3wmNMFXQArQHWpJA20je')
        .get();
    Map<String, dynamic>? data =
        documentSnapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      setState(() {
        _latestVersion = data['version'];
      });
      if (_currentVersion != _latestVersion) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('アプリのアップデートがあるぞ！'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '見てくれ',
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        "アップデートのお知らせ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                                width: 100,
                                height: 100,
                                child: Image(
                                  image: AssetImage('assets/icon/rocket.gif'),
                                  fit: BoxFit.cover,
                                )),
                            Text(
                              'アプリのアップデートがあります！\n新機能などが追加されたので\nアップデートをよろしくお願いします。',
                              textAlign: TextAlign.center,
                            ),
                          ]),
                      actions: <Widget>[
                        // ボタン領域
                        ElevatedButton(
                            child: const Text("後で"),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        if (Platform.isIOS)
                          ElevatedButton(
                              child: const Text("おっけー"),
                              onPressed: () {
                                launch(
                                    'https://apps.apple.com/jp/app/%E5%B2%A1%E7%90%86%E3%82%A2%E3%83%97%E3%83%AA/id1671546931');
                              }),
                        if (Platform.isAndroid)
                          ElevatedButton(
                              child: const Text("おっけー"),
                              onPressed: () {
                                launch(
                                    'https://play.google.com/store/apps/details?id=com.ous.unoffical.app');
                              }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      }
    }
  }

//ボトムナビゲーションバー

  int _currentindex = 0;
  List<Widget> pages = [
    const Home(),
    const Info(),
    const Review(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(child: pages[_currentindex]),
        drawer: const NavBar(),
        backgroundColor: const Color.fromARGB(0, 253, 253, 246),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentindex,
          onDestinationSelected: (index) {
            setState(() {
              _currentindex = index;
            });
            HapticFeedback.heavyImpact(); // ライトインパクトの振動フィードバック
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'ホーム',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline),
              label: 'お知らせ',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              label: '講義評価',
            ),
          ],
        ));
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen(context);
  }

  Future<bool> checkMaintenance() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(minutes: 5),
    ));

    await remoteConfig.setDefaults(<String, dynamic>{
      "isUnderMaintenance": false,
    });

    await remoteConfig.fetchAndActivate();
    bool isUnderMaintenance = remoteConfig.getBool('isUnderMaintenance');

    return isUnderMaintenance;
  }

  _navigateToNextScreen(BuildContext context) async {
    bool isUnderMaintenance = await checkMaintenance();
    if (isUnderMaintenance) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MaintenanceScreen()));
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // スプラッシュ画面などに書き換えても良い
        }
        if (snapshot.hasData) {
          // User が null でなない、つまりサインイン済みのホーム画面へ
          return const MyHomePage(title: 'home');
        }
        // User が null である、つまり未サインインのサインイン画面へ
        return const Login();
      },
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
              width: 200,
              height: 200,
              child: Image(
                image: AssetImage('assets/icon/maintenance.gif'),
                fit: BoxFit.cover,
              )),
          SizedBox(
            height: 50.h,
          ),
          Text(
            'メンテナンス中です！\nメンテナンス終了までお待ち下さい。',
            style: TextStyle(fontSize: 18.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 50.h,
          ),
          ElevatedButton(
              onPressed: () {
                final url = Uri.parse('https://twitter.com/TAN_Q_BOT_LOCAL');
                launchUrl(url);
              },
              child: const Text('詳しくは開発者のTwitterをご確認ください。'))
        ],
      )),
    );
  }
}
