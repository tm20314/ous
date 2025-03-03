class CollectionNameUtils {
  static String getDisplayName(String collectionName) {
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
}
