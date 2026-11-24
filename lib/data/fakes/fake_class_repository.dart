import '../models/study_class.dart';
import '../repositories/class_repository.dart';
import '../repositories/repository_exception.dart';
import 'fake_config.dart';
import 'samples/class_samples.dart';

/// In-memory [ClassRepository]. [joinClass] accepts [joinableClassCode] and
/// adds that class to later [fetchClasses] results. [fetchClass] knows every
/// sample class, joined or not, so detail screens work in every scenario.
class FakeClassRepository implements ClassRepository {
  FakeClassRepository(this._config, {DateTime Function()? clock})
    : _classes = _config.isEmpty ? [] : List.of(sampleClasses);

  final FakeConfig _config;
  final List<StudyClass> _classes;

  @override
  Future<List<StudyClass>> fetchClasses() =>
      _config.answer('fetchClasses', () => List.of(_classes));

  @override
  Future<StudyClass> fetchClass(String classId) =>
      _config.answer('fetchClass', () {
        for (final c in [..._classes, ...sampleClasses, joinableClass]) {
          if (c.id == classId) return c;
        }
        throw RepositoryException('Unknown class: $classId');
      });

  @override
  Future<StudyClass> joinClass(String code) => _config.answer('joinClass', () {
    if (code.trim().toUpperCase() != joinableClassCode) {
      throw RepositoryException('Unknown class code: $code');
    }
    if (!_classes.any((c) => c.id == joinableClass.id)) {
      _classes.add(joinableClass);
    }
    return joinableClass;
  });
}
