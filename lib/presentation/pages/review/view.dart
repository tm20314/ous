import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ous/domain/review_provider.dart';
import 'package:ous/gen/assets.gen.dart';
import 'package:ous/presentation/pages/review/detail_view.dart';
import 'package:ous/presentation/widgets/review/filter_modal.dart';
import 'package:ous/presentation/widgets/review/review_card.dart';
import 'package:ous/presentation/widgets/review/review_search_delegate.dart';

class ReviewView extends ConsumerStatefulWidget {
  final String gakubu;
  final String title;

  const ReviewView({super.key, required this.gakubu, required this.title});

  @override
  ConsumerState<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends ConsumerState<ReviewView> {
  String _selectedBumon = '';
  String _selectedGakki = '';
  String _selectedTanni = '';
  String _selectedZyugyoukeisiki = '';
  String _selectedSyusseki = '';
  String _selectedDateOrder = ''; // 追加
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(
      reviewsProvider(
        (
          widget.gakubu,
          _selectedBumon,
          _selectedGakki,
          _selectedTanni,
          _selectedZyugyoukeisiki,
          _selectedSyusseki,
          _searchQuery,
          _selectedDateOrder, // 追加
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(getDisplayName(widget.gakubu)),
        bottom: _buildFilterChips(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: ReviewSearchDelegate(
                  gakubu: widget.gakubu,
                  bumon: _selectedBumon,
                  gakki: _selectedGakki,
                  tanni: _selectedTanni,
                  zyugyoukeisiki: _selectedZyugyoukeisiki,
                  syusseki: _selectedSyusseki,
                  selectedDateOrder: _selectedDateOrder,
                ),
              );
              if (result != null) {
                setState(() {
                  _searchQuery = result;
                });
              }
            },
          ),
        ],
      ),
      body: Center(
        child: reviewsAsync.when(
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'レビューを読み込み中...',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'データの読み込みに失敗しました',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('再試行'),
                  onPressed: () => ref.refresh(
                    reviewsProvider(
                      (
                        widget.gakubu,
                        _selectedBumon,
                        _selectedGakki,
                        _selectedTanni,
                        _selectedZyugyoukeisiki,
                        _selectedSyusseki,
                        _searchQuery,
                        _selectedDateOrder,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Image(
                        image: AssetImage(Assets.icon.found.path),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '結果が見つかりませんでした',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasActiveFilters()
                          ? 'フィルターを変更して再度検索してみてください'
                          : '別の条件で検索してみてください',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).hintColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (_hasActiveFilters())
                      ElevatedButton.icon(
                        icon: const Icon(Icons.filter_alt_off),
                        label: const Text('フィルターをクリア'),
                        onPressed: _clearAllFilters,
                      ),
                  ],
                ),
              );
            }
            return Scrollbar(
              child: AnimationLimiter(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0, // 正方形にする
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  padding: const EdgeInsets.all(8),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 300), // 短縮
                      columnCount: 2,
                      child: SlideAnimation(
                        horizontalOffset: 50.0, // より軽量なアニメーション
                        child: FadeInAnimation(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    review: review,
                                    collectionName: widget.gakubu,
                                    documentId: review.ID ?? '',
                                  ),
                                ),
                              );
                            },
                            child: ReviewCard(
                              review: review,
                              collectionName: widget.gakubu,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showFilterModal(
          context,
          _selectedBumon,
          _selectedGakki,
          _selectedTanni,
          _selectedZyugyoukeisiki,
          _selectedSyusseki,
          _selectedDateOrder, // 追加
          (value) => setState(() => _selectedBumon = value),
          (value) => setState(() => _selectedGakki = value),
          (value) => setState(() => _selectedTanni = value),
          (value) => setState(() => _selectedZyugyoukeisiki = value),
          (value) => setState(() => _selectedSyusseki = value),
          (value) => setState(() => _selectedDateOrder = value), // 追加
        ),
        heroTag: 'filter',
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  // コレクション名から表示用の学部名に変換する関数
  String getDisplayName(String collectionName) {
    final Map<String, String> nameMapping = {
      'rigaku': '理学部',
      'kougakubu': '工学部',
      'zyouhou': '情報理工学部',
      'seibutu': '生物地球学部',
      'kyouiku': '教育学部',
      'keiei': '経営学部',
      'zyuui': '獣医学部',
      'seimei': '生命科学部',
      'kiban': '基盤教育科目',
      'kyousyoku': '教職関連科目',
      'active': 'アクティブラーナーズ',
    };

    return nameMapping[collectionName] ?? collectionName;
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDeleted,
      ),
    );
  }

  PreferredSize _buildFilterChips() {
    List<Widget> chips = [];

    if (_selectedBumon.isNotEmpty) {
      chips.add(
        _buildFilterChip(
          '部門: $_selectedBumon',
          () => setState(() => _selectedBumon = ''),
        ),
      );
    }

    if (_selectedGakki.isNotEmpty) {
      chips.add(
        _buildFilterChip(
          '講義: $_selectedGakki',
          () => setState(() => _selectedGakki = ''),
        ),
      );
    }

    if (_selectedTanni.isNotEmpty) {
      chips.add(
        _buildFilterChip(
          '講義の種類: $_selectedTanni',
          () => setState(() => _selectedTanni = ''),
        ),
      );
    }

    if (_selectedZyugyoukeisiki.isNotEmpty) {
      chips.add(
        _buildFilterChip(
          '授業の種類: $_selectedZyugyoukeisiki',
          () => setState(() => _selectedZyugyoukeisiki = ''),
        ),
      );
    }

    if (_selectedSyusseki.isNotEmpty) {
      chips.add(
        _buildFilterChip(
          '授業の評価: $_selectedSyusseki',
          () => setState(() => _selectedSyusseki = ''),
        ),
      );
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(chips.isEmpty ? 0 : 50),
      child: chips.isEmpty
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(children: chips),
            ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedBumon = '';
      _selectedGakki = '';
      _selectedTanni = '';
      _selectedZyugyoukeisiki = '';
      _selectedSyusseki = '';
      _searchQuery = '';
      _selectedDateOrder = '';
    });
  }

  bool _hasActiveFilters() {
    return _selectedBumon.isNotEmpty ||
        _selectedGakki.isNotEmpty ||
        _selectedTanni.isNotEmpty ||
        _selectedZyugyoukeisiki.isNotEmpty ||
        _selectedSyusseki.isNotEmpty ||
        _searchQuery.isNotEmpty;
  }
}
