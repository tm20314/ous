
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html/dom.dart' as UserModel;
import "package:universal_html/controller.dart";
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';



class report extends StatefulWidget {
  const report({Key? key}) : super(key: key);

  @override
  State<report> createState() => _reportState();
}

class _reportState extends State<report> {
  List<Article> articles = [];
  @override
  void initState(){
    super .initState();
    getWebsiteData();


  }
  Future getWebsiteData() async {
    final controller = WindowController();
    await controller.openHttp(
      method: 'GET',
      uri: Uri.parse('https://www.ous.ac.jp/topics/?cat=6'),
    );
    final document = controller.window!.document;

    final titles = document
        .querySelectorAll("dl > dd >a")
        .map((element) => element.innerText)
        .toList();

    final urls = document
        .querySelectorAll("dl > dd > a")
        .map((element) {
      var href = element.getAttribute("href")!;
      // リンクが相対パスの場合、絶対URLに変換する
      if (!href.startsWith('http')) {
        href = 'https://www.ous.ac.jp$href';
      }
      return href;
    })
        .toList();

    final dates = document
        .querySelectorAll("div > .p10 > dt")
        .map((element) => element.innerText)
        .toList();

    setState(() {
      articles = List.generate(
        titles.length,
            (index) => Article(
          title: titles[index],
          url: urls[index],
          date: dates[index],
        ),
      );
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {

            print('Loading New Data');
            await getWebsiteData();
          },
          child: Center(
            child: (articles == null || articles.length == 0)?
            CircularProgressIndicator():
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Column(
                  children:[
                    ListTile(
                      title: Text(article.title,style: TextStyle(fontSize: 15.sp),),
                      subtitle: Text(article.date.substring(0,10),style: TextStyle(color: Colors.lightGreen,fontWeight: FontWeight.bold,fontSize: 15.sp),),
                      onTap: () => launch(article.url),

                    ),
                    Divider(),
                    //区切り線
                  ],
                );
              },
            ),
          ),
        )
    );
  }
}


class Article {
  final String url;
  final String title;
  final String date;

  const Article({
    required this.url,
    required this.title,
    required this.date,

  });
}


