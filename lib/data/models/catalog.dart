/// A school in the academic profile dropdown (96).
final class School {
  const School({required this.id, required this.name, this.shortName});

  final String id;
  final String name;

  /// e.g. "CSU".
  final String? shortName;

  School copyWith({String? id, String? name, String? shortName}) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
    );
  }
}

/// A college within a school (96).
final class College {
  const College({required this.id, required this.schoolId, required this.name});

  final String id;
  final String schoolId;
  final String name;

  College copyWith({String? id, String? schoolId, String? name}) {
    return College(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
    );
  }
}

/// A program within a college (96).
final class Program {
  const Program({
    required this.id,
    required this.collegeId,
    required this.name,
  });

  final String id;
  final String collegeId;
  final String name;

  Program copyWith({String? id, String? collegeId, String? name}) {
    return Program(
      id: id ?? this.id,
      collegeId: collegeId ?? this.collegeId,
      name: name ?? this.name,
    );
  }
}

/// A subject chip in the study subjects step (97).
final class Subject {
  const Subject({required this.id, required this.name, this.code});

  final String id;
  final String name;
  final String? code;

  Subject copyWith({String? id, String? name, String? code}) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
    );
  }
}
