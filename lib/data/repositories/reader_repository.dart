import '../models/reader.dart';

/// A reviewer's content in the reader modes: Read (87), Visual (88) and
/// Listen (89), plus the user's highlights.
abstract interface class ReaderRepository {
  Future<List<ReaderSection>> fetchSections(String materialId);

  Future<List<Highlight>> fetchHighlights(String materialId);

  Future<Highlight> addHighlight(Highlight highlight);

  Future<MindMap> fetchMindMap(String materialId);

  Future<Transcript> fetchTranscript(String materialId);
}
