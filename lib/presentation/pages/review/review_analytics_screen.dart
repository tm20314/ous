// Flutter imports:
// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, int>>(
        future: getPostCounts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final postCounts = snapshot.data!;
            final totalPosts = postCounts.values.reduce((a, b) => a + b);
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PieChart(
                      PieChartData(
                        sections: _createPieChartSections(postCounts),
                        centerSpaceRadius: 40,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            // Handle touch events if needed
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '全学科の投稿数合計: $totalPosts件',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: postCounts.length,
                    itemBuilder: (context, index) {
                      final entry = postCounts.entries.elementAt(index);
                      final department = _getDepartmentName(entry.key);
                      final postCount = entry.value;
                      final color =
                          _getColorForDepartment(entry.key, postCounts);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                        ),
                        title: Text(department),
                        trailing: Text('$postCount件'),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<Map<String, int>> getPostCounts() async {
    final postCounts = <String, int>{};
    final collections = [
      'rigaku',
      'kougakubu',
      'zyouhou',
      'seibutu',
      'kyouiku',
      'keiei',
      'zyuui',
      'seimei',
      'kiban',
      'kyousyoku',
    ];

    for (final collection in collections) {
      final querySnapshot =
          await FirebaseFirestore.instance.collection(collection).get();
      postCounts[collection] = querySnapshot.size;
    }

    return postCounts;
  }

  List<PieChartSectionData> _createPieChartSections(
    Map<String, int> postCounts,
  ) {
    final data = postCounts.entries.toList();

    return data.map((entry) {
      final postCount = entry.value;
      final color =
          Colors.primaries[data.indexOf(entry) % Colors.primaries.length];

      return PieChartSectionData(
        value: postCount.toDouble(),
        title: '$postCount',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColorForDepartment(String key, postCounts) {
    final index = postCounts.keys.toList().indexOf(key);
    return Colors.primaries[index % Colors.primaries.length];
  }

  String _getDepartmentName(String key) {
    switch (key) {
      case 'rigaku':
        return '理学部';
      case 'kougakubu':
        return '工学部';
      case 'zyouhou':
        return '情報理工学部';
      case 'seibutu':
        return '生物地球学部';
      case 'kyouiku':
        return '教育学部';
      case 'keiei':
        return '経営学部';
      case 'zyuui':
        return '獣医学部';
      case 'seimei':
        return '生命科学部';
      case 'kiban':
        return '基盤教育科目';
      case 'kyousyoku':
        return '教職関連科目';
      default:
        return '不明';
    }
  }
}
