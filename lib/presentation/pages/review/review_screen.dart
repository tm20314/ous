// Flutter imports:
import 'package:firebase_auth/firebase_auth.dart';
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/review_provider.dart' as review_provider;
import 'package:ous/domain/view_count_provider.dart' as view_count_provider;
// Project imports:
import 'package:ous/gen/assets.gen.dart';
import 'package:ous/infrastructure/config/analytics_service.dart';
import 'package:ous/presentation/pages/review/popular_reviews.dart';
import 'package:ous/presentation/pages/review/review_analytics_screen.dart';
import 'package:ous/presentation/widgets/drawer/drawer.dart';
import 'package:ous/presentation/widgets/review/review_top_component.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewState();

  static fromJson(Map<String, dynamic> data) {}
}

class ReviewTopScreen extends StatefulWidget {
  const ReviewTopScreen({super.key});

  @override
  State<ReviewTopScreen> createState() => _ReviewTopScreenState();
}

class _ReviewState extends ConsumerState<ReviewScreen> {
  late FirebaseAuth auth;
  bool showFloatingActionButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          // 講義評価一覧を更新
          ref.invalidate(review_provider.reviewsProvider);

          // 人気のレビューを更新
          ref.invalidate(view_count_provider.popularReviewsProvider(10));

          // 少し待機して確実にデータが更新されるようにする
          await Future.delayed(const Duration(milliseconds: 300));

          // 更新完了メッセージを表示
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('データを更新しました'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        child: PopScope(
          canPop: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomCard(
                      imagePath: Assets.images.facultyOfScience.path,
                      title: '理学部',
                      collection: 'rigaku',
                    ),
                    CustomCard(
                      imagePath: Assets.images.facultyOfEngineering.path,
                      title: '工学部',
                      collection: 'kougakubu',
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomCard(
                      imagePath: Assets
                          .images.facultyOfInformationScienceAndTechnology.path,
                      title: '情報理工学部',
                      collection: 'zyouhou',
                    ),
                    CustomCard(
                      imagePath:
                          Assets.images.facultyOfBiologyAndEarthScience.path,
                      title: '生物地球学部',
                      collection: 'seibutu',
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomCard(
                      imagePath: Assets.images.facultyOfEducation.path,
                      title: '教育学部',
                      collection: 'kyouiku',
                    ),
                    CustomCard(
                      imagePath:
                          Assets.images.schoolOfBusinessAdministration.path,
                      title: '経営学部',
                      collection: 'keiei',
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomCard(
                      imagePath: Assets.images.facultyOfVeterinaryMedicine.path,
                      title: '獣医学部',
                      collection: 'zyuui',
                    ),
                    CustomCard(
                      imagePath: Assets.images.schoolOfLifeSciences.path,
                      title: '生命科学部',
                      collection: 'seimei',
                    ),
                  ],
                ),
                //ここにアクティブラーナーズを追加したい
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround, // 他のカードと同じ配置に設定
                  children: [
                    CustomCard(
                      imagePath: Assets.images.img0669.path,
                      title: 'アクティブ',
                      collection: 'active',
                    ),
                    const TransparentCard(),
                  ],
                ),
                const Divider(), //区切り線
                const Text(
                  '共通科目はこちら',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomCard(
                      imagePath: '',
                      title: '基盤教育科目',
                      collection: 'kiban',
                    ),
                    CustomCard(
                      imagePath: '',
                      title: '教職関連科目',
                      collection: 'kyousyoku',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton:
          showFloatingActionButton ? const FloatingButton() : null,
    );
  }

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null && user.email != null && user.email!.endsWith('ous.jp')) {
      showFloatingActionButton = true;
    }
    // Analytics
    AnalyticsService().setCurrentScreen(AnalyticsServiceScreenName.review);
  }
}

class _ReviewTopScreenState extends State<ReviewTopScreen> {
  // 現在のページインデックス
  int _currentPageIndex = 0;

  // ページごとのタイトル
  final List<String> _pageTitles = [
    '講義評価',
    '投稿件数',
    'みんながよく見ている講義',
  ];

  // PageControllerを追加
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentPageIndex]),
      ),
      drawer: const NavBar(),
      body: Stack(
        children: [
          // PageView
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            children: const [
              ReviewScreen(),
              AnalyticsScreen(),
              PopularReviewsPage(),
            ],
          ),

          // ページインジケーター
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  activeDotColor: Theme.of(context).primaryColor,
                  dotColor: Colors.grey.shade300,
                ),
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose(); // コントローラーの破棄
    super.dispose();
  }
}
