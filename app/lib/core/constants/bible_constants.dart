class BibleConstants {
  static const List<Map<String, dynamic>> oldTestament = [
    {'key': 'Genesis', 'name': '창세기', 'chapters': 50},
    {'key': 'Exodus', 'name': '출애굽기', 'chapters': 40},
    {'key': 'Leviticus', 'name': '레위기', 'chapters': 27},
    {'key': 'Numbers', 'name': '민수기', 'chapters': 36},
    {'key': 'Deuteronomy', 'name': '신명기', 'chapters': 34},
    {'key': 'Joshua', 'name': '여호수아', 'chapters': 24},
    {'key': 'Judges', 'name': '사사기', 'chapters': 21},
    {'key': 'Ruth', 'name': '룻기', 'chapters': 4},
    {'key': '1Samuel', 'name': '사무엘상', 'chapters': 31},
    {'key': '2Samuel', 'name': '사무엘하', 'chapters': 24},
    {'key': '1Kings', 'name': '열왕기상', 'chapters': 22},
    {'key': '2Kings', 'name': '열왕기하', 'chapters': 25},
    {'key': '1Chronicles', 'name': '역대상', 'chapters': 29},
    {'key': '2Chronicles', 'name': '역대하', 'chapters': 36},
    {'key': 'Ezra', 'name': '에스라', 'chapters': 10},
    {'key': 'Nehemiah', 'name': '느헤미야', 'chapters': 13},
    {'key': 'Esther', 'name': '에스더', 'chapters': 10},
    {'key': 'Job', 'name': '욥기', 'chapters': 42},
    {'key': 'Psalms', 'name': '시편', 'chapters': 150},
    {'key': 'Proverbs', 'name': '잠언', 'chapters': 31},
    {'key': 'Ecclesiastes', 'name': '전도서', 'chapters': 12},
    {'key': 'SongOfSongs', 'name': '아가', 'chapters': 8},
    {'key': 'Isaiah', 'name': '이사야', 'chapters': 66},
    {'key': 'Jeremiah', 'name': '예레미야', 'chapters': 52},
    {'key': 'Lamentations', 'name': '예레미야애가', 'chapters': 5},
    {'key': 'Ezekiel', 'name': '에스겔', 'chapters': 48},
    {'key': 'Daniel', 'name': '다니엘', 'chapters': 12},
    {'key': 'Hosea', 'name': '호세아', 'chapters': 14},
    {'key': 'Joel', 'name': '요엘', 'chapters': 3},
    {'key': 'Amos', 'name': '아모스', 'chapters': 9},
    {'key': 'Obadiah', 'name': '오바댜', 'chapters': 1},
    {'key': 'Jonah', 'name': '요나', 'chapters': 4},
    {'key': 'Micah', 'name': '미가', 'chapters': 7},
    {'key': 'Nahum', 'name': '나훔', 'chapters': 3},
    {'key': 'Habakkuk', 'name': '하박국', 'chapters': 3},
    {'key': 'Zephaniah', 'name': '스바냐', 'chapters': 3},
    {'key': 'Haggai', 'name': '학개', 'chapters': 2},
    {'key': 'Zechariah', 'name': '스가랴', 'chapters': 14},
    {'key': 'Malachi', 'name': '말라기', 'chapters': 4},
  ];

  static const List<Map<String, dynamic>> newTestament = [
    {'key': 'Matthew', 'name': '마태복음', 'chapters': 28},
    {'key': 'Mark', 'name': '마가복음', 'chapters': 16},
    {'key': 'Luke', 'name': '누가복음', 'chapters': 24},
    {'key': 'John', 'name': '요한복음', 'chapters': 21},
    {'key': 'Acts', 'name': '사도행전', 'chapters': 28},
    {'key': 'Romans', 'name': '로마서', 'chapters': 16},
    {'key': '1Corinthians', 'name': '고린도전서', 'chapters': 16},
    {'key': '2Corinthians', 'name': '고린도후서', 'chapters': 13},
    {'key': 'Galatians', 'name': '갈라디아서', 'chapters': 6},
    {'key': 'Ephesians', 'name': '에베소서', 'chapters': 6},
    {'key': 'Philippians', 'name': '빌립보서', 'chapters': 4},
    {'key': 'Colossians', 'name': '골로새서', 'chapters': 4},
    {'key': '1Thessalonians', 'name': '데살로니가전서', 'chapters': 5},
    {'key': '2Thessalonians', 'name': '데살로니가후서', 'chapters': 3},
    {'key': '1Timothy', 'name': '디모데전서', 'chapters': 6},
    {'key': '2Timothy', 'name': '디모데후서', 'chapters': 4},
    {'key': 'Titus', 'name': '디도서', 'chapters': 3},
    {'key': 'Philemon', 'name': '빌레몬서', 'chapters': 1},
    {'key': 'Hebrews', 'name': '히브리서', 'chapters': 13},
    {'key': 'James', 'name': '야고보서', 'chapters': 5},
    {'key': '1Peter', 'name': '베드로전서', 'chapters': 5},
    {'key': '2Peter', 'name': '베드로후서', 'chapters': 3},
    {'key': '1John', 'name': '요한1서', 'chapters': 5},
    {'key': '2John', 'name': '요한2서', 'chapters': 1},
    {'key': '3John', 'name': '요한3서', 'chapters': 1},
    {'key': 'Jude', 'name': '유다서', 'chapters': 1},
    {'key': 'Revelation', 'name': '요한계시록', 'chapters': 22},
  ];

  static int getChapterCount(String bookKey) {
    for (var book in oldTestament) {
      if (book['key'] == bookKey) return book['chapters'] as int;
    }
    for (var book in newTestament) {
      if (book['key'] == bookKey) return book['chapters'] as int;
    }
    return 0;
  }

  static String getBookName(String bookKey) {
    for (var book in oldTestament) {
      if (book['key'] == bookKey) return book['name'] as String;
    }
    for (var book in newTestament) {
      if (book['key'] == bookKey) return book['name'] as String;
    }
    return bookKey;
  }

  static int calculateTotalChapters(List<String> targetRange) {
    if (targetRange.isEmpty) return 1189; // Default to full bible if empty

    final range = targetRange.first;
    
    // Predefined Ranges
    if (range == 'Genesis-Revelation') return 1189;
    if (range == 'Genesis-Malachi') return 929;
    if (range == 'Matthew-Revelation') return 260;

    // Custom Selection (List of Book Keys)
    int total = 0;
    for (final bookKey in targetRange) {
      total += getChapterCount(bookKey);
    }
    return total;
  }
}
