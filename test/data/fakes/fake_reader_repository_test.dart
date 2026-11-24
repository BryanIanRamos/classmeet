import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/fakes/fake_reader_repository.dart';
import 'package:classmeet/data/models/reader.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  late FakeReaderRepository repo;
  setUp(() => repo = FakeReaderRepository(FakeConfig.instant));

  group('sample', () {
    test('week-1 has the two sections of frame 87', () async {
      final sections = await repo.fetchSections('week-1');
      expect(sections.map((s) => '${s.number} ${s.title}'), [
        '1.1 What is a computer?',
        '1.2 Parts of a computer',
      ]);
      expect(
        sections[0].paragraphs,
        contains('A computer follows the input–process–output cycle.'),
      );
      expect(
        sections[0].paragraphs.last,
        startsWith('For example, typing on a keyboard provides input.'),
      );
      expect(
        sections[0].paragraphs.first,
        startsWith(
          'A computer is an electronic device that accepts data as input, '
          'processes that da',
        ),
      );
      expect(
        sections[1].paragraphs.first,
        startsWith(
          'The core components of a modern desktop computer work seamlessly '
          'together, with ',
        ),
      );
      for (final s in sections) {
        expect(s.paragraphs.length, inInclusiveRange(2, 3));
      }
    });

    test('other materials have one short section', () async {
      expect(await repo.fetchSections('week-3'), hasLength(1));
    });

    test('the sample highlight points at the sentence', () async {
      final highlights = await repo.fetchHighlights('week-1');
      expect(highlights, hasLength(1));
      final h = highlights.single;
      final section = (await repo.fetchSections(
        'week-1',
      )).firstWhere((s) => s.id == h.sectionId);
      final text = section.paragraphs.join('\n\n');
      expect(text.substring(h.start, h.end), h.text);
      expect(h.text, 'A computer follows the input–process–output cycle.');
      expect(await repo.fetchHighlights('week-2'), isEmpty);
    });

    test('mind map is Computer with four branches and the caption', () async {
      final map = await repo.fetchMindMap('week-1');
      expect(map.root.label, 'Computer');
      expect(map.root.children.map((n) => n.label), [
        'Input',
        'Process',
        'Output',
        'Storage',
      ]);
      expect(
        map.caption,
        'Input → Process → Output. This diagram summarizes the core '
        'concepts from your reviewer.',
      );
    });

    test('other materials get a mind map from their sections', () async {
      final map = await repo.fetchMindMap('week-3');
      expect(map.root.children.single.label, 'Computer hardware');
    });

    test('week-1 transcript is 06:24 long and contiguous', () async {
      final t = await repo.fetchTranscript('week-1');
      expect(t.total, const Duration(minutes: 6, seconds: 24));
      expect(t.sentences.first.start, Duration.zero);
      expect(t.sentences.last.end, t.total);
      expect(
        t.sentences.map((s) => s.text),
        contains('A computer follows the input–process–output cycle.'),
      );
      for (var i = 1; i < t.sentences.length; i++) {
        expect(t.sentences[i].start, t.sentences[i - 1].end);
        expect(t.sentences[i].end, greaterThan(t.sentences[i].start));
      }
    });
  });

  group('writes', () {
    test('addHighlight persists and is per material', () async {
      const h = Highlight(
        id: 'h-new',
        materialId: 'week-1',
        sectionId: 'week-1-1-2',
        start: 0,
        end: 10,
        text: 'The core c',
      );
      final saved = await repo.addHighlight(h);
      expect(saved.id, 'h-new');
      final all = await repo.fetchHighlights('week-1');
      expect(all.map((x) => x.id), ['highlight-1', 'h-new']);
    });

    test('an empty id gets one assigned', () async {
      final saved = await repo.addHighlight(
        const Highlight(
          id: '',
          materialId: 'week-1',
          sectionId: 'week-1-1-1',
          start: 0,
          end: 1,
          text: 'A',
        ),
      );
      expect(saved.id, isNotEmpty);
    });

    test('unknown material or section throws', () {
      final throwsRepo = throwsA(isA<RepositoryException>());
      expect(repo.fetchSections('nope'), throwsRepo);
      expect(repo.fetchHighlights('nope'), throwsRepo);
      expect(repo.fetchMindMap('nope'), throwsRepo);
      expect(repo.fetchTranscript('nope'), throwsRepo);
      expect(
        repo.addHighlight(
          const Highlight(
            id: 'x',
            materialId: 'week-1',
            sectionId: 'nope',
            start: 0,
            end: 1,
            text: 'A',
          ),
        ),
        throwsRepo,
      );
    });
  });

  group('empty', () {
    test('lists are empty', () async {
      final r = FakeReaderRepository(_empty);
      expect(await r.fetchSections('week-1'), isEmpty);
      expect(await r.fetchHighlights('week-1'), isEmpty);
    });
  });

  group('error', () {
    test('every method throws RepositoryException', () {
      final r = FakeReaderRepository(_error);
      final throwsRepo = throwsA(isA<RepositoryException>());
      expect(r.fetchSections('week-1'), throwsRepo);
      expect(r.fetchHighlights('week-1'), throwsRepo);
      expect(r.fetchMindMap('week-1'), throwsRepo);
      expect(r.fetchTranscript('week-1'), throwsRepo);
      expect(
        r.addHighlight(
          const Highlight(
            id: 'x',
            materialId: 'week-1',
            sectionId: 'week-1-1-1',
            start: 0,
            end: 1,
            text: 'A',
          ),
        ),
        throwsRepo,
      );
    });
  });
}
