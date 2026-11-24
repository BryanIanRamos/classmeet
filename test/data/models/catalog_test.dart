import 'package:classmeet/data/models/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('School', () {
    const s = School(
      id: 's',
      name: 'Caraga State University',
      shortName: 'CSU',
    );
    final k = s.copyWith();
    expect(
      [k.id, k.name, k.shortName],
      ['s', 'Caraga State University', 'CSU'],
    );
    final c = s.copyWith(name: 'X');
    expect([c.id, c.name, c.shortName], ['s', 'X', 'CSU']);
  });

  test('College', () {
    const s = College(id: 'c', schoolId: 's', name: 'CCIS');
    final k = s.copyWith();
    expect([k.id, k.schoolId, k.name], ['c', 's', 'CCIS']);
    final c = s.copyWith(schoolId: 's2');
    expect([c.id, c.schoolId, c.name], ['c', 's2', 'CCIS']);
  });

  test('Program', () {
    const s = Program(id: 'p', collegeId: 'c', name: 'BSIT');
    final k = s.copyWith();
    expect([k.id, k.collegeId, k.name], ['p', 'c', 'BSIT']);
    final c = s.copyWith(name: 'BSCS');
    expect([c.id, c.collegeId, c.name], ['p', 'c', 'BSCS']);
  });

  test('Subject', () {
    const s = Subject(id: 'x', name: 'Networking I', code: 'IT112');
    final k = s.copyWith();
    expect([k.id, k.name, k.code], ['x', 'Networking I', 'IT112']);
    final c = s.copyWith(code: 'IT113');
    expect([c.id, c.name, c.code], ['x', 'Networking I', 'IT113']);
    expect(const Subject(id: 'y', name: 'HCI').code, isNull);
  });
}
