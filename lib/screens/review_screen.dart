// Flutter imports:
// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ous/analytics_service.dart';
// Project imports:
import 'package:ous/widgets/nav_bar.dart';
import 'package:ous/widgets/review/review_top_component.dart';

class Review extends StatefulWidget {
  const Review({Key? key}) : super(key: key);

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
//大学のアカウント以外は非表示にする
  late FirebaseAuth auth;
  bool showFloatingActionButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        actions: const [
          //ここにアイコン設置
        ],
        elevation: 0,
        title: const Text('講義評価'),
      ),
      body: const PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomCard(
                    imagePath: 'assets/images/理学部.jpg',
                    title: '理学部',
                    collection: 'rigaku',
                  ),
                  CustomCard(
                    imagePath: 'assets/images/工学部.jpg',
                    title: '工学部',
                    collection: 'kougakubu',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomCard(
                    imagePath: 'assets/images/情報理工学部.jpg',
                    title: '情報理工学部',
                    collection: 'zyouhou',
                  ),
                  CustomCard(
                    imagePath: 'assets/images/生物地球学部.jpg',
                    title: '生物地球学部',
                    collection: 'seibutu',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomCard(
                    imagePath: 'assets/images/教育学部.jpg',
                    title: '教育学部',
                    collection: 'kyouiku',
                  ),
                  CustomCard(
                    imagePath: 'assets/images/経営学部.jpg',
                    title: '経営学部',
                    collection: 'keiei',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomCard(
                    imagePath: 'assets/images/獣医学部.jpg',
                    title: '獣医学部',
                    collection: 'zyuui',
                  ),
                  CustomCard(
                    imagePath: 'assets/images/生命科学部.jpg',
                    title: '生命科学部',
                    collection: 'seimei',
                  ),
                ],
              ),
              Divider(), //区切り線
              Text(
                '共通科目はこちら',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
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