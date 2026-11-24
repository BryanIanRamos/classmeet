import 'package:classmeet/data/models/reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ReaderSection', () {
    const s = ReaderSection(
      id: 's',
      materialId: 'm',
      number: '1.1',
      title: 'T',
      paragraphs: ['p'],
    );
    final c = s.copyWith();
    expect([c.id, c.materialId, c.number, c.title], ['s', 'm', '1.1', 'T']);
    expect(c.paragraphs, ['p']);
    final d = s.copyWith(title: 'U');
    expect(d.title, 'U');
    expect(d.number, '1.1');
  });

  test('Highlight', () {
    const h = Highlight(
      id: 'h',
      materialId: 'm',
      sectionId: 's',
      start: 1,
      end: 5,
      text: 'abc',
    );
    final c = h.copyWith();
    expect([c.id, c.materialId, c.sectionId, c.text], ['h', 'm', 's', 'abc']);
    expect([c.start, c.end], [1, 5]);
    final d = h.copyWith(end: 9);
    expect(d.end, 9);
    expect(d.start, 1);
  });

  test('MindMap and nodes', () {
    const leaf = MindMapNode(id: 'i', label: 'Input');
    const root = MindMapNode(id: 'r', label: 'Computer', children: [leaf]);
    expect(root.copyWith().children, hasLength(1));
    expect(root.copyWith().label, 'Computer');
    expect(root.copyWith(label: 'X').children, hasLength(1));
    const map = MindMap(materialId: 'm', root: root, caption: 'c');
    expect(map.copyWith().caption, 'c');
    expect(map.copyWith().materialId, 'm');
    expect(map.copyWith().root, same(root));
    expect(map.copyWith(caption: 'd').materialId, 'm');
  });

  test('Transcript', () {
    const sentence = TranscriptSentence(
      text: 'Hi',
      start: Duration(seconds: 1),
      end: Duration(seconds: 2),
    );
    expect(sentence.copyWith().text, 'Hi');
    expect(sentence.copyWith().start, const Duration(seconds: 1));
    expect(sentence.copyWith(end: Duration.zero).start, sentence.start);
    const t = Transcript(
      materialId: 'm',
      total: Duration(minutes: 6),
      sentences: [sentence],
    );
    expect(t.copyWith().sentences, hasLength(1));
    expect(t.copyWith().total, const Duration(minutes: 6));
    expect(t.copyWith(materialId: 'n').total, t.total);
  });

  test('Explanation', () {
    const e = Explanation(text: 't', sourceLabel: 's');
    expect(e.language, ExplainLanguage.english);
    expect(e.talonCost, 1);
    final c = e.copyWith();
    expect([c.text, c.sourceLabel, c.talonCost], ['t', 's', 1]);
    expect(c.language, ExplainLanguage.english);
    final d = e.copyWith(language: ExplainLanguage.tagalog);
    expect(d.language, ExplainLanguage.tagalog);
    expect(d.text, 't');
  });

  test('enum labels and factors', () {
    expect(ExplainLanguage.values.map((e) => e.label), [
      'English',
      'Tagalog',
      'Taglish',
    ]);
    expect(PlaybackSpeed.values.map((e) => e.label), [
      '0.75x',
      '1x',
      '1.25x',
      '1.5x',
    ]);
    expect(PlaybackSpeed.values.map((e) => e.factor), [0.75, 1, 1.25, 1.5]);
    expect(ExplainAction.values.map((e) => e.label), [
      'Explain',
      'Example',
      'Quiz me',
      'Highlight',
    ]);
  });
}
