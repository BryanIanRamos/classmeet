/// Language of an AI explanation (91).
enum ExplainLanguage {
  english('English'),
  tagalog('Tagalog'),
  taglish('Taglish');

  const ExplainLanguage(this.label);
  final String label;
}

/// Playback speed chips in the listen tab (89).
enum PlaybackSpeed {
  x075('0.75x', 0.75),
  x1('1x', 1),
  x125('1.25x', 1.25),
  x15('1.5x', 1.5);

  const PlaybackSpeed(this.label, this.factor);
  final String label;
  final double factor;
}

/// Floating toolbar actions over a selected sentence (87).
enum ExplainAction {
  explain('Explain'),
  example('Example'),
  quizMe('Quiz me'),
  highlight('Highlight');

  const ExplainAction(this.label);
  final String label;
}

/// A numbered section of a reviewer, e.g. "1.1 What is a computer?" (87).
final class ReaderSection {
  const ReaderSection({
    required this.id,
    required this.materialId,
    required this.number,
    required this.title,
    this.paragraphs = const [],
  });

  final String id;
  final String materialId;
  final String number;
  final String title;
  final List<String> paragraphs;

  ReaderSection copyWith({
    String? id,
    String? materialId,
    String? number,
    String? title,
    List<String>? paragraphs,
  }) => ReaderSection(
    id: id ?? this.id,
    materialId: materialId ?? this.materialId,
    number: number ?? this.number,
    title: title ?? this.title,
    paragraphs: paragraphs ?? this.paragraphs,
  );
}

/// A highlighted range inside a section (87).
final class Highlight {
  const Highlight({
    required this.id,
    required this.materialId,
    required this.sectionId,
    required this.start,
    required this.end,
    required this.text,
  });

  final String id;
  final String materialId;
  final String sectionId;
  final int start;
  final int end;
  final String text;

  Highlight copyWith({
    String? id,
    String? materialId,
    String? sectionId,
    int? start,
    int? end,
    String? text,
  }) => Highlight(
    id: id ?? this.id,
    materialId: materialId ?? this.materialId,
    sectionId: sectionId ?? this.sectionId,
    start: start ?? this.start,
    end: end ?? this.end,
    text: text ?? this.text,
  );
}

/// A node of the mind map, e.g. "Computer" with Input/Process/Output/Storage (88).
final class MindMapNode {
  const MindMapNode({
    required this.id,
    required this.label,
    this.children = const [],
  });

  final String id;
  final String label;
  final List<MindMapNode> children;

  MindMapNode copyWith({
    String? id,
    String? label,
    List<MindMapNode>? children,
  }) => MindMapNode(
    id: id ?? this.id,
    label: label ?? this.label,
    children: children ?? this.children,
  );
}

/// The mind map of a material (88).
final class MindMap {
  const MindMap({
    required this.materialId,
    required this.root,
    this.caption = '',
  });

  final String materialId;
  final MindMapNode root;
  final String caption;

  MindMap copyWith({String? materialId, MindMapNode? root, String? caption}) =>
      MindMap(
        materialId: materialId ?? this.materialId,
        root: root ?? this.root,
        caption: caption ?? this.caption,
      );
}

/// One sentence of the listen-tab transcript (89).
final class TranscriptSentence {
  const TranscriptSentence({
    required this.text,
    required this.start,
    required this.end,
  });

  final String text;
  final Duration start;
  final Duration end;

  TranscriptSentence copyWith({String? text, Duration? start, Duration? end}) =>
      TranscriptSentence(
        text: text ?? this.text,
        start: start ?? this.start,
        end: end ?? this.end,
      );
}

/// Transcript of a material for the listen tab (89).
final class Transcript {
  const Transcript({
    required this.materialId,
    required this.total,
    this.sentences = const [],
  });

  final String materialId;
  final Duration total;
  final List<TranscriptSentence> sentences;

  Transcript copyWith({
    String? materialId,
    Duration? total,
    List<TranscriptSentence>? sentences,
  }) => Transcript(
    materialId: materialId ?? this.materialId,
    total: total ?? this.total,
    sentences: sentences ?? this.sentences,
  );
}

/// An AI explanation shown in the explain sheet (91).
final class Explanation {
  const Explanation({
    required this.text,
    this.language = ExplainLanguage.english,
    this.talonCost = 1,
    required this.sourceLabel,
  });

  final String text;
  final ExplainLanguage language;
  final int talonCost;

  /// e.g. "Based on your Week 1: Computer Basics Reviewer".
  final String sourceLabel;

  Explanation copyWith({
    String? text,
    ExplainLanguage? language,
    int? talonCost,
    String? sourceLabel,
  }) => Explanation(
    text: text ?? this.text,
    language: language ?? this.language,
    talonCost: talonCost ?? this.talonCost,
    sourceLabel: sourceLabel ?? this.sourceLabel,
  );
}
