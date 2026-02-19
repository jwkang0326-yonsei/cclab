/// 성경 절(Verse) 모델
class BibleVerse {
  final int verse;
  final String text;

  const BibleVerse({
    required this.verse,
    required this.text,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      verse: json['verse'] as int,
      text: (json['text'] as String).trim(),
    );
  }

  Map<String, dynamic> toJson() => {
    'verse': verse,
    'text': text,
  };
}

/// 성경 한 장(Chapter) 전체 내용 모델
class BibleChapterContent {
  final String bookName;
  final int chapter;
  final List<BibleVerse> verses;

  const BibleChapterContent({
    required this.bookName,
    required this.chapter,
    required this.verses,
  });

  factory BibleChapterContent.fromGetBibleJson(Map<String, dynamic> json) {
    final versesList = (json['verses'] as List<dynamic>)
        .map((v) => BibleVerse.fromJson(v as Map<String, dynamic>))
        .toList();

    return BibleChapterContent(
      bookName: json['book_name'] as String,
      chapter: json['chapter'] as int,
      verses: versesList,
    );
  }

  /// 로컬 캐시 저장/복원용
  Map<String, dynamic> toJson() => {
    'book_name': bookName,
    'chapter': chapter,
    'verses': verses.map((v) => v.toJson()).toList(),
  };

  factory BibleChapterContent.fromJson(Map<String, dynamic> json) {
    return BibleChapterContent.fromGetBibleJson(json);
  }
}
