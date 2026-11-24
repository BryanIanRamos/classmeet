/// Kind of study material (85, 92).
enum MaterialKind {
  reviewer('Reviewers'),
  quiz('Quizzes'),
  flashcards('Flashcards'),
  mindMap('Mind maps');

  const MaterialKind(this.label);
  final String label;
}

/// Where a material was imported from (85, 86).
enum MaterialSource {
  pdf('PDF'),
  photo('Photo of handout'),
  powerPoint('PowerPoint'),
  word('Word document'),
  text('Pasted text');

  const MaterialSource(this.label);
  final String label;
}

/// A reviewer, quiz, flashcard set or mind map in the library (85, 86, 92).
final class StudyMaterial {
  const StudyMaterial({
    required this.id,
    this.classId,
    required this.title,
    this.week,
    required this.kind,
    required this.source,
    this.sourceNote,
    this.pagesOrSlides,
    this.modulesLeft = 0,
    this.readDone = 0,
    this.readTotal = 0,
    this.createdBy,
    required this.createdAt,
    this.sizeBytes,
    this.isDownloaded = false,
  });

  final String id;
  final String? classId;
  final String title;
  final int? week;
  final MaterialKind kind;
  final MaterialSource source;

  /// e.g. "Merged from 2 files".
  final String? sourceNote;
  final int? pagesOrSlides;
  final int modulesLeft;
  final int readDone;
  final int readTotal;
  final String? createdBy;
  final DateTime createdAt;
  final int? sizeBytes;
  final bool isDownloaded;

  /// Reading progress, 0..1 (0 when total is 0).
  double get fraction =>
      readTotal <= 0 ? 0 : (readDone / readTotal).clamp(0.0, 1.0);

  StudyMaterial copyWith({
    String? id,
    String? classId,
    String? title,
    int? week,
    MaterialKind? kind,
    MaterialSource? source,
    String? sourceNote,
    int? pagesOrSlides,
    int? modulesLeft,
    int? readDone,
    int? readTotal,
    String? createdBy,
    DateTime? createdAt,
    int? sizeBytes,
    bool? isDownloaded,
  }) => StudyMaterial(
    id: id ?? this.id,
    classId: classId ?? this.classId,
    title: title ?? this.title,
    week: week ?? this.week,
    kind: kind ?? this.kind,
    source: source ?? this.source,
    sourceNote: sourceNote ?? this.sourceNote,
    pagesOrSlides: pagesOrSlides ?? this.pagesOrSlides,
    modulesLeft: modulesLeft ?? this.modulesLeft,
    readDone: readDone ?? this.readDone,
    readTotal: readTotal ?? this.readTotal,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    isDownloaded: isDownloaded ?? this.isDownloaded,
  );
}

/// A file being uploaded in the add-reviewer screen (86).
final class UploadItem {
  const UploadItem({
    required this.fileName,
    this.sentBytes = 0,
    required this.totalBytes,
  });

  final String fileName;
  final int sentBytes;
  final int totalBytes;

  /// Upload progress, 0..1 (0 when total is 0).
  double get fraction =>
      totalBytes <= 0 ? 0 : (sentBytes / totalBytes).clamp(0.0, 1.0);

  bool get isDone => totalBytes > 0 && sentBytes >= totalBytes;

  UploadItem copyWith({String? fileName, int? sentBytes, int? totalBytes}) =>
      UploadItem(
        fileName: fileName ?? this.fileName,
        sentBytes: sentBytes ?? this.sentBytes,
        totalBytes: totalBytes ?? this.totalBytes,
      );
}
