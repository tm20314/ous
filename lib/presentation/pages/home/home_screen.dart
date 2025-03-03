import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ous/constant/urls.dart';
import 'package:ous/domain/bus_service_provider.dart';
import 'package:ous/gen/assets.gen.dart';
import 'package:ous/infrastructure/config/analytics_service.dart';
import 'package:ous/infrastructure/version_check_service.dart';
import 'package:ous/presentation/widgets/home/bus_info_button.dart';
import 'package:ous/presentation/widgets/home/mylog_status_button.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/drawer/drawer.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> {
  final VersionCheckService _versionCheckService = VersionCheckService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        elevation: 0,
        title: const Text('ホーム'),
        actions: [
          if (!kIsWeb && Platform.isIOS)
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () {
                Share.share(StoreUrls.ios);
              },
            ),
          if (!kIsWeb && Platform.isAndroid)
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () {
                Share.share(StoreUrls.android);
              },
            ),
        ],
      ),
      body: PopScope(
        canPop: false,
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              await ref.read(busServiceProvider.notifier).fetchBusInfo();
              await ref.read(myLogStatusProvider.notifier).fetchMyLogStatus();
            } catch (e) {
              // エラーハンドリング
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('データの取得に失敗しました: $e')),
              );
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: 500.w,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? Assets.images.homedark.path
                          : Assets.images.home.path,
                    ),
                  ),
                ),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BusInfoButton(
                              label: '岡山駅西口発',
                              url: BusUrls.okayamaStation,
                            ),
                            BusInfoButton(
                              label: '岡山理科大学正門発',
                              url: BusUrls.okayamaRikaUniversity,
                            ),
                          ],
                        ),
                        SizedBox(height: 10), // Add spacing between rows
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BusInfoButton(
                              label: '岡山天満屋発',
                              url: BusUrls.okayamaTenmaya,
                            ),
                            BusInfoButton(
                              label: '岡山理科大学東門発',
                              url: BusUrls.okayamaRikaUniversityEastGate,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Column(
                    children: [
                      MyLogStatusButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _checkVersion() async {
    await _versionCheckService.checkVersion(context);
  }

  Future<void> _initialize() async {
    await AnalyticsService().setCurrentScreen(AnalyticsServiceScreenName.home);
    await _checkVersion();
  }
}
