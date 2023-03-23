

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/streams.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:url_launcher/url_launcher.dart';

class MultipleCollectionsPage extends StatefulWidget {
  @override
  _MultipleCollectionsPageState createState() =>
      _MultipleCollectionsPageState();
}

class _MultipleCollectionsPageState extends State<MultipleCollectionsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('投稿した評価'),
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: _getStream(),
        builder: (BuildContext context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<DocumentSnapshot> documents = [];

          if (snapshot.hasData) {
            for (QuerySnapshot querySnapshot in snapshot.data!) {
              documents.addAll(querySnapshot.docs);
            }
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = documents[index];
              return ListTile(
                title: Text(document['zyugyoumei']),
                subtitle: Text(document['kousimei']),
              );
            },
          );
        },
      )



    );
  }
  Stream<List<QuerySnapshot<Map<String, dynamic>>>> _getStream() async* {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    String? uid = user?.uid;

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

    List<Stream<QuerySnapshot<Map<String, dynamic>>>> streams = collections
        .map((collection) => FirebaseFirestore.instance
        .collection(collection)
        .where('accountuid', isEqualTo: uid)
        .snapshots())
        .toList();

    yield* CombineLatestStream.list(streams);
  }





}


class DetailsScreen extends StatefulWidget {
  //現在の講義データ
  final zyugyoumei;
  final kousimei;
  final tannisuu;
  final zyugyoukeisiki;
  final syusseki;
  final kyoukasyo;
  final tesutokeisiki;
  final omosirosa;
  final toriyasusa;
  final sougouhyouka;
  final komento;
  final name;
  final senden;
  final nenndo;
  final ID;
  final userid;

  //新しい講義データ
  late final new_zyugyoumei;
  final new_kousimei;
  final new_tannisuu;
  final new_zyugyoukeisiki;
  final new_syusseki;
  final new_kyoukasyo;
  final new_tesutokeisiki;
  final new_omosirosa;
  final new_toriyasusa;
  final new_sougouhyouka;
  final new_komento;
  final new_name;
  final new_senden;
  final new_nenndo;

  DetailsScreen({
    Key? key,
    required this.nenndo,
    required this.zyugyoumei,
    required this.kousimei,
    required this.tannisuu,
    required this.zyugyoukeisiki,
    required this.syusseki,
    required this.kyoukasyo,
    required this.tesutokeisiki,
    required this.omosirosa,
    required this.toriyasusa,
    required this.sougouhyouka,
    required this.komento,
    required this.name,
    required this.ID,
    required this.userid,
    required this.senden,
    //新しい講義データ
    this.new_zyugyoumei,
    this.new_kousimei,
    this.new_tannisuu,
    this.new_zyugyoukeisiki,
    this.new_syusseki,
    this.new_kyoukasyo,
    this.new_tesutokeisiki,
    this.new_omosirosa,
    this.new_toriyasusa,
    this.new_sougouhyouka,
    this.new_komento,
    this.new_name,
    this.new_senden,
    this.new_nenndo,
  }) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Future<void> _updateData(String userid, String ID) async {
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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('accountuid', isEqualTo: userid)
          .where('ID', isEqualTo: ID)
          .get();

      List<DocumentSnapshot> documents = querySnapshot.docs;

      for (DocumentSnapshot document in documents) {
        document.reference.update({
          'zyugyoumei': widget.new_zyugyoumei,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.zyugyoumei),
        actions: [
          IconButton(
              icon: Icon(Icons.mode_edit_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text("編集モード"),
                      content: Text(
                        "編集モードです\n各項目上で長押しをすると\n編集できます",
                        textAlign: TextAlign.center,
                      ),
                      actions: <Widget>[
                        // ボタン領域
                        TextButton(
                          child: Text("おけ"),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    );
                  },
                );
              }),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text("授業名"),
                        content: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                  labelText: 'メールアドレス',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.lightGreen))),
                              onChanged: (String value) {
                                setState(() {
                                  widget.new_zyugyoumei = value;
                                });
                              },
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          // ボタン領域
                          TextButton(
                            child: Text("やっぱやめる"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                              child: Text("おけ"),
                              onPressed: () async {
                                _updateData(widget.userid, widget.ID);
                              }),
                        ],
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '授業名',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        widget.zyugyoumei ?? '不明',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text(""),
                        content: Text(
                          "",
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          // ボタン領域
                          TextButton(
                            child: Text("やっぱやめる"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(child: Text("おけ"), onPressed: () {}),
                        ],
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '講師名',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        widget.kousimei ?? '不明',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text("年度"),
                        content: Text(
                          "",
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          // ボタン領域
                          TextButton(
                            child: Text("やっぱやめる"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(child: Text("おけ"), onPressed: () {}),
                        ],
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '年度',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        widget.nenndo ?? '不明'.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text(""),
                        content: Text(
                          "",
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          // ボタン領域
                          TextButton(
                            child: Text("やっぱやめる"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(child: Text("おけ"), onPressed: () {}),
                        ],
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '単位数',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        widget.tannisuu.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text(""),
                        content: Text(
                          "",
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          // ボタン領域
                          TextButton(
                            child: Text("やっぱやめる"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(child: Text("おけ"), onPressed: () {}),
                        ],
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '授業形式',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        widget.zyugyoukeisiki,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text(""),
                        content: Text(
                          "",
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          // ボタン領域
                          TextButton(
                            child: Text("やっぱやめる"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(child: Text("おけ"), onPressed: () {}),
                        ],
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '出席確認の有無',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        widget.syusseki,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text(""),
                        content: Text(
                          "",
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          // ボタン領域
                          TextButton(
                            child: Text("やっぱやめる"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(child: Text("おけ"), onPressed: () {}),
                        ],
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '教科書の有無',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        widget.kyoukasyo,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text(""),
                        content: Text(
                          "",
                          textAlign: TextAlign.center,
                        ),
                        actions: <Widget>[
                          // ボタン領域
                          TextButton(
                            child: Text("やっぱやめる"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(child: Text("おけ"), onPressed: () {}),
                        ],
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'テスト形式',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                      ),
                      child: Text(
                        widget.tesutokeisiki ?? '不明',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                child: Column(
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: Text(""),
                              content: Text(
                                "",
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                // ボタン領域
                                TextButton(
                                  child: Text("やっぱやめる"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(child: Text("おけ"), onPressed: () {}),
                              ],
                            );
                          },
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '講義の面白さ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                          Container(
                              height: 200.h,
                              child: SfRadialGauge(axes: <RadialAxis>[
                                RadialAxis(
                                    minimum: 0,
                                    maximum: 5,
                                    showLabels: false,
                                    showTicks: false,
                                    axisLineStyle: AxisLineStyle(
                                      thickness: 0.2,
                                      cornerStyle: CornerStyle.bothCurve,
                                      color: Color.fromARGB(139, 134, 134, 134),
                                      thicknessUnit: GaugeSizeUnit.factor,
                                    ),
                                    pointers: <GaugePointer>[
                                      RangePointer(
                                        value: widget.omosirosa.toDouble(),
                                        cornerStyle: CornerStyle.bothCurve,
                                        color: Colors.lightGreen,
                                        width: 0.2,
                                        sizeUnit: GaugeSizeUnit.factor,
                                      )
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                          positionFactor: 0.1,
                                          angle: 90,
                                          widget: Text(
                                            widget.omosirosa
                                                    .toDouble()
                                                    .toStringAsFixed(0) +
                                                ' / 5',
                                            style: TextStyle(
                                                fontSize: 50.sp,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ])
                              ])),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: Text(""),
                              content: Text(
                                "",
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                // ボタン領域
                                TextButton(
                                  child: Text("やっぱやめる"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(child: Text("おけ"), onPressed: () {}),
                              ],
                            );
                          },
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '単位の取りやすさ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                          Container(
                            height: 200.h,
                            child: SfRadialGauge(axes: <RadialAxis>[
                              RadialAxis(
                                  minimum: 0,
                                  maximum: 5,
                                  showLabels: false,
                                  showTicks: false,
                                  axisLineStyle: AxisLineStyle(
                                    thickness: 0.2,
                                    cornerStyle: CornerStyle.bothCurve,
                                    color: Color.fromARGB(139, 134, 134, 134),
                                    thicknessUnit: GaugeSizeUnit.factor,
                                  ),
                                  pointers: <GaugePointer>[
                                    RangePointer(
                                      value: widget.toriyasusa.toDouble(),
                                      cornerStyle: CornerStyle.bothCurve,
                                      color: Colors.lightGreen,
                                      width: 0.2,
                                      sizeUnit: GaugeSizeUnit.factor,
                                    )
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        positionFactor: 0.1,
                                        angle: 90,
                                        widget: Text(
                                          widget.toriyasusa
                                                  .toDouble()
                                                  .toStringAsFixed(0) +
                                              ' / 5',
                                          style: TextStyle(
                                              fontSize: 50.sp,
                                              fontWeight: FontWeight.bold),
                                        ))
                                  ])
                            ]),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: Text(""),
                              content: Text(
                                "",
                                textAlign: TextAlign.center,
                              ),
                              actions: <Widget>[
                                // ボタン領域
                                TextButton(
                                  child: Text("やっぱやめる"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(child: Text("おけ"), onPressed: () {}),
                              ],
                            );
                          },
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '総合評価',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                          Container(
                            height: 200.h,
                            child: SfRadialGauge(axes: <RadialAxis>[
                              RadialAxis(
                                  minimum: 0,
                                  maximum: 5,
                                  showLabels: false,
                                  showTicks: false,
                                  axisLineStyle: AxisLineStyle(
                                    thickness: 0.2,
                                    cornerStyle: CornerStyle.bothCurve,
                                    color: Color.fromARGB(139, 134, 134, 134),
                                    thicknessUnit: GaugeSizeUnit.factor,
                                  ),
                                  pointers: <GaugePointer>[
                                    RangePointer(
                                      value: widget.sougouhyouka.toDouble(),
                                      cornerStyle: CornerStyle.bothCurve,
                                      color: Colors.lightGreen,
                                      width: 0.2,
                                      sizeUnit: GaugeSizeUnit.factor,
                                    )
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                        positionFactor: 0.1,
                                        angle: 90,
                                        widget: Text(
                                          widget.sougouhyouka
                                                  .toDouble()
                                                  .toStringAsFixed(0) +
                                              ' / 5',
                                          style: TextStyle(
                                              fontSize: 50.sp,
                                              fontWeight: FontWeight.bold),
                                        ))
                                  ])
                            ]),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text(""),
                            content: Text(
                              "",
                              textAlign: TextAlign.center,
                            ),
                            actions: <Widget>[
                              // ボタン領域
                              TextButton(
                                child: Text("やっぱやめる"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(child: Text("おけ"), onPressed: () {}),
                            ],
                          );
                        },
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '講義に関するコメント',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        Text(
                          widget.komento ?? '不明',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text(""),
                            content: Text(
                              "",
                              textAlign: TextAlign.center,
                            ),
                            actions: <Widget>[
                              // ボタン領域
                              TextButton(
                                child: Text("やっぱやめる"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(child: Text("おけ"), onPressed: () {}),
                            ],
                          );
                        },
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ニックネーム',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 50,
                          ),
                          child: Text(
                            widget.name ?? '不明',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text(""),
                            content: Text(
                              "",
                              textAlign: TextAlign.center,
                            ),
                            actions: <Widget>[
                              // ボタン領域
                              TextButton(
                                child: Text("やっぱやめる"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(child: Text("おけ"), onPressed: () {}),
                            ],
                          );
                        },
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '宣伝',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 50,
                          ),
                          child: Text(
                            widget.senden ?? '不明',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0.h),
                  /*  Container(
                    height: 40.0.h,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.lightGreen,
                              style: BorderStyle.solid,
                              width: 1.0.w),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20.0)),
                      child: GestureDetector(
                        onTap: () async {
                          //ここにブロック関数
                          showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text("この投稿をブロックします。"),
                                content: Text("本当にいい？",textAlign: TextAlign.center,),
                                actions: <Widget>[
                                  // ボタン領域
                                  TextButton(
                                    child: Text("ダメやで"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text("ええで"),
                                    onPressed: () async {
                                      //ブロック処理
                                      FirebaseFirestore.instance.collection(widget.gakubu).doc(widget.doc.id).delete();

                                      await Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (context) {
                                          return Review();
                                        }),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Center(
                          child: Text(
                            'この投稿をブロックする。',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),*/
                  SizedBox(height: 20.0.h),
                  Container(
                    height: 40.0.h,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.lightGreen,
                              style: BorderStyle.solid,
                              width: 1.0.w),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20.0)),
                      child: GestureDetector(
                        onTap: () async {
                          //ここにブロック関数
                          launch(
                              'https://docs.google.com/forms/d/e/1FAIpQLSepC82BWAoARJVh4WeGCFOuIpWLyaPfqqXn524SqxyBSA9LwQ/viewform');
                        },
                        child: Center(
                          child: Text(
                            'この投稿を開発者に報告する',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0.h),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
