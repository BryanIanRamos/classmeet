import 'package:classmeet/data/models/search_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const r = SearchResult(
    id: 'r1',
    category: SearchCategory.classes,
    title: 'ITE13 – Intermediate Programming',
    subtitle: 'Prof. Rhea Santos',
  );

  test('copyWith() keeps every field', () {
    final c = r.copyWith();
    expect(c.id, 'r1');
    expect(c.category, SearchCategory.classes);
    expect(c.title, 'ITE13 – Intermediate Programming');
    expect(c.subtitle, 'Prof. Rhea Santos');
  });

  test('copyWith changes only the given field', () {
    final c = r.copyWith(category: SearchCategory.materials);
    expect(c.category, SearchCategory.materials);
    expect(c.title, 'ITE13 – Intermediate Programming');
    expect(c.subtitle, 'Prof. Rhea Santos');
  });

  test('subtitle defaults to empty', () {
    const e = SearchResult(id: 'e', category: SearchCategory.all, title: 't');
    expect(e.subtitle, '');
  });

  test('category labels', () {
    expect(SearchCategory.values.map((e) => e.label), [
      'All',
      'Classes',
      'Materials',
      'People',
    ]);
  });
}
