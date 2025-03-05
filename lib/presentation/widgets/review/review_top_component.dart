// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// Project imports:
import 'package:ous/presentation/pages/review/gpa.dart';
import 'package:ous/presentation/pages/review/liked_posts_page.dart';
import 'package:ous/presentation/pages/review/my_post_page.dart';
import 'package:ous/presentation/pages/review/post.dart';
import 'package:ous/presentation/pages/review/sabori.dart';
import 'package:ous/presentation/pages/review/view.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String collection;

  const CustomCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isNotEmpty) {
      return GestureDetector(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 170.h,
            width: 170.w,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Image.asset(
                        imagePath,
                        height: 110.h,
                        width: 200.w,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewView(
                gakubu: collection,
                title: title,
              ),
            ),
          );
        },
      );
    } else {
      return GestureDetector(
        child: Stack(
          children: <Widget>[
            Card(
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 100.h,
                width: 170.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      title: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewView(
                gakubu: collection,
                title: title,
              ),
            ),
          );
        },
      );
    }
  }
}

class FloatingButton extends StatelessWidget {
  const FloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            18.0,
          ),
        ), // adjust this value according to your button's height
      ),
      icon: Icons.menu,
      activeIcon: Icons.close,
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 10,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.upload_outlined),
          label: "投稿",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostPage()),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.people),
          label: "自分の投稿",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserPostsScreen(),
              ),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.info_outline),
          label: "教務ガイド（履修削除はこちら）",
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("注意"),
                content: const Text(
                  "この先ログイン画面が表示されます\n大学のGoogleアカウントでログインしてください。",
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("やめる"),
                  ),
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse(
                        'https://accounts.google.com/AccountChooser/signinchooser?continue=https%3A%2F%2Fsites.google.com%2Fous.ac.jp%2Facademicaffairs%2F%25E5%2590%2584%25E7%25A8%25AE%25E7%2594%25B3%25E8%25AB%258B%2F%25E5%25B1%25A5%25E4%25BF%25AE%25E9%2596%25A2%25E4%25BF%2582&flowName=GlifWebSignIn&flowEntry=AccountChooser',
                      );
                      if (await canLaunchUrl(url)) {
                        launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        // ignore: avoid_print
                        print("Can't launch $url");
                      }
                    },
                    child: const Text("おっけー"),
                  ),
                ],
              ),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.book_outlined),
          label: "シラバス",
          onTap: () async {
            final url = Uri.parse(
              'https://mylog.pub.ous.ac.jp/uprx/up/pk/pky001/Pky00101.xhtml?guestlogin=Kmh006',
            );
            if (await canLaunchUrl(url)) {
              launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              // ignore: avoid_print
              print("Can't launch $url");
            }
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.calculate_outlined),
          label: "GPA計算機",
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Gpa()),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.directions_run_outlined),
          label: "サボりカウンター",
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Sabori()),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.favorite_outline),
          label: "いいねした投稿",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LikedPostsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class TransparentCard extends StatelessWidget {
  const TransparentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h,
      width: 170.w,
      child: const Card(
        color: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
