import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ous/NavBar.dart';
import 'package:ous/review/gakubu/keieigakubu.dart';
import 'package:ous/review/gakubu/kibankamoku.dart';
import 'package:ous/review/gakubu/kougakubu.dart';
import 'package:ous/review/gakubu/kyouikugakubu.dart';
import 'package:ous/review/gakubu/kyousyokukamoku.dart';
import 'package:ous/review/gakubu/rigakubu.dart';
import 'package:ous/review/gakubu/seibututikyuugakubu.dart';
import 'package:ous/review/gakubu/seimeikagaku.dart';
import 'package:ous/review/gakubu/zyouhourikougakubu.dart';
import 'package:ous/review/gakubu/zyuuigakubu.dart';
import 'package:ous/review/post.dart';
import 'package:ous/review/postuser.dart';
import 'package:ous/test/zyouhourikou.dart';
import 'package:ous/test/zyuui.dart';
import 'package:path/path.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_dialogs/flutter_dialogs.dart';

class Review extends StatefulWidget {
  const Review({Key? key}) : super(key: key);

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {

  Future<Map<String, dynamic>> _getDocumentCount() async {
    Map<String, dynamic> result = {};
    List<String> collections = [
      'rigaku',
      'kougakubu',
      'zyouhou',
      'seibutu',
      'kyouiku',
      'keiei',
      'zyuui',
      'seimei',
      'kiban',
      'kyousyoku'
    ];
    for (String collection in collections) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collection).get();
      result[collection] = querySnapshot.size;
    }
    return result;
  }






  @override

    Widget build(BuildContext context) => Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        elevation: 0,
        title: Text('講義評価'),
      ),
      body: WillPopScope(
        onWillPop: ()async => false,
        child: SingleChildScrollView(
          child: Column(
            children: [

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [


                    GestureDetector(
                      child: Card(

                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            height: 176.h,
                            width: 180.w,
                            child: Column(
                              children: [
                                Container(

                                  decoration: BoxDecoration(color: Colors.lightGreen[100]),
                                  child: Image.asset(
                                    'assets/images/理学部.jpg',
                                    height: 110.h,
                                    width: 200.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                ListTile(
                                  title:  Text(
                                    '理学部',
                                    style: GoogleFonts.notoSans(
                                      // フォントをnotoSansに指定(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Rigakubu()),
                        );
                      },

                    ),
                    GestureDetector(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            height: 176.h,
                            width: 180.w,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.lightGreen[100]),
                                  child: Image.asset(
                                    'assets/images/工学部.jpg',
                                    height: 110.h,
                                    width: 180.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                ListTile(
                                  title:  Text(
                                    '工学部',
                                    style: GoogleFonts.notoSans(
                                      // フォントをnotoSansに指定(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),                                    ),
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Kougakubu()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            height: 176.h,
                            width: 180.w,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.lightGreen[100]),
                                  child: Image.asset(
                                    'assets/images/情報理工学部.jpg',
                                    height: 110.h,
                                    width: 180.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                ListTile(
                                  title:  Text(
                                    '情報理工学部',
                                    style: GoogleFonts.notoSans(
                                      // フォントをnotoSansに指定(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),                                    ),
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => zyouhourikougakubu()),
                        );
                      },
                    ),
                    GestureDetector(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            height: 176.h,
                            width: 180.w,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.lightGreen[100]),
                                  child: Image.asset(
                                    'assets/images/生物地球学部.jpg',
                                    height: 110.h,
                                    width: 180.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                ListTile(
                                  title:  Text(
                                    '生物地球学部',
                                    style: GoogleFonts.notoSans(
                                      // フォントをnotoSansに指定(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),                                    ),
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => seibututikyuu()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            height: 176.h,
                            width: 180.w,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.lightGreen[100]),
                                  child: Image.asset(
                                    'assets/images/教育学部.jpg',
                                    height: 110.h,
                                    width: 180.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                ListTile(
                                  title:  Text(
                                    '教育学部',
                                    style: GoogleFonts.notoSans(
                                      // フォントをnotoSansに指定(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),                                    ),
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => kyouikugakubu()),
                        );
                      },
                    ),
                    GestureDetector(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            height: 176.h,
                            width: 180.w,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.lightGreen[100]),
                                  child: Image.asset(
                                    'assets/images/経営学部.jpg',
                                    height: 110.h,
                                    width: 180.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                ListTile(
                                  title:  Text(
                                    '経営学部',
                                    style: GoogleFonts.notoSans(
                                      // フォントをnotoSansに指定(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),                                    ),
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => keieigakubu()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            height: 176.h,
                            width: 180.w,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.lightGreen[100]),
                                  child: Image.asset(
                                    'assets/images/獣医学部.jpg',
                                    height: 110.h,
                                    width: 180.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                ListTile(
                                  title:  Text(
                                    '獣医学部',
                                    style: GoogleFonts.notoSans(
                                      // フォントをnotoSansに指定(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),                                    ),
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => zyuuigakubu()),
                        );
                      },
                    ),
                    GestureDetector(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            height: 176.h,
                            width: 180.w,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(color: Colors.lightGreen[100]),
                                  child: Image.asset(
                                    'assets/images/生命科学部.jpg',
                                    height: 110.h,
                                    width: 180.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                ListTile(
                                  title:  Text(
                                    '生命科学部',
                                    style: GoogleFonts.notoSans(
                                      // フォントをnotoSansに指定(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => seimei()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(), //区切り線
              Text(
                '共通科目はこちら',
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            height: 100.h,
                            width: 180.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ListTile(
                                  title:  Text(
                                    '基盤教育科目',
                                    style: GoogleFonts.notoSans(
                                      // フォントをnotoSansに指定(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => kibankamoku()),
                        );
                      },
                    ),
                    GestureDetector(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                            height: 100.h,
                            width: 180.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ListTile(
                                  title:  Text(
                                    '教職関連科目',
                                    style: GoogleFonts.notoSans(
                                      // フォントをnotoSansに指定(
                                      textStyle: TextStyle(
                                        fontSize: 20.sp,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => kyousyokukamoku()),
                        );
                      },
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    floatingActionButton: Column(
      verticalDirection: VerticalDirection.up,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Column(
          children: [
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MultipleCollectionsPage()),
                );
              },              child: Icon(Icons.person_2_outlined),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => post()),
                  );
                },
                child: const Icon(Icons.upload_outlined),
              ),
            )
          ],
        ),
      ],
    ),


    );

}

