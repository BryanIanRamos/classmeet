import '../models/reader.dart';
import '../repositories/reader_repository.dart';
import '../repositories/repository_exception.dart';
import 'fake_config.dart';
import 'samples/reader_samples.dart';

/// In-memory [ReaderRepository]. Content exists for the materials in
/// `sampleSections`; any other id throws. Highlights added at runtime are kept
/// for the life of the repository.
final class FakeReaderRepository implements ReaderRepository {
  FakeReaderRepository(this._config);

  final FakeConfig _config;

  final List<Highlight> _highlights = [...sampleHighlights];
  int _nextHighlight = 2;

  List<ReaderSection> _sections(String materialId) =>
      sampleSections[materialId] ??
      (throw RepositoryException('Unknown material "$materialId"'));

  @override
  Future<List<ReaderSection>> fetchSections(String materialId) =>
      _config.answerList('fetchSections', () => List.of(_sections(materialId)));

  @override
  Future<List<Highlight>> fetchHighlights(String materialId) =>
      _config.answerList('fetchHighlights', () {
        _sections(materialId);
        return [
          for (final h in _highlights)
            if (h.materialId == materialId) h,
        ];
      });

  @override
  Future<Highlight> addHighlight(Highlight highlight) =>
      _config.answer('addHighlight', () {
        final sections = _sections(highlight.materialId);
        if (!sections.any((s) => s.id == highlight.sectionId)) {
          throw RepositoryException('Unknown section "${highlight.sectionId}"');
        }
        final saved = highlight.id.isEmpty
            ? highlight.copyWith(id: 'highlight-${_nextHighlight++}')
            : highlight;
        _highlights.add(saved);
        return saved;
      });

  @override
  Future<MindMap> fetchMindMap(String materialId) =>
      _config.answer('fetchMindMap', () {
        final sections = _sections(materialId);
        if (materialId == sampleMindMap.materialId) return sampleMindMap;
        return MindMap(
          materialId: materialId,
          root: MindMapNode(
            id: 'root',
            label: sampleMaterialLabels[materialId] ?? materialId,
            children: [
              for (final s in sections) MindMapNode(id: s.id, label: s.title),
            ],
          ),
          caption:
              'This diagram summarizes the core concepts from your '
              'reviewer.',
        );
      });

  @override
  Future<Transcript> fetchTranscript(String materialId) =>
      _config.answer('fetchTranscript', () {
        final sections = _sections(materialId);
        return buildTranscript(
          materialId,
          sections,
          total: materialId == 'week-1' ? week1AudioLength : null,
        );
      });
}
