import '../../models/catalog.dart';

/// Schools (96, 12). Only these two appear in the design.
const sampleSchools = [
  School(id: 'csu', name: 'Caraga State University', shortName: 'CSU'),
  School(
    id: 'fsuu',
    name: 'Father Saturnino Urios University',
    shortName: 'FSUU',
  ),
];

/// Colleges are not designed. // sample
const sampleColleges = [
  College(
    id: 'csu-ccis',
    schoolId: 'csu',
    name: 'College of Computing and Information Sciences',
  ),
  College(
    id: 'csu-coe',
    schoolId: 'csu',
    name: 'College of Engineering and Geosciences',
  ),
  College(
    id: 'fsuu-ccs',
    schoolId: 'fsuu',
    name: 'College of Computer Studies',
  ),
];

/// Programs are not designed. // sample
const samplePrograms = [
  Program(
    id: 'csu-bsit',
    collegeId: 'csu-ccis',
    name: 'BS Information Technology',
  ),
  Program(id: 'csu-bscs', collegeId: 'csu-ccis', name: 'BS Computer Science'),
  Program(
    id: 'csu-bsis',
    collegeId: 'csu-ccis',
    name: 'BS Information Systems',
  ),
  Program(id: 'csu-bsce', collegeId: 'csu-coe', name: 'BS Civil Engineering'),
  Program(
    id: 'fsuu-bsit',
    collegeId: 'fsuu-ccs',
    name: 'BS Information Technology',
  ),
];

/// The six subject chips of frame 97.
const sampleSubjects = [
  Subject(id: 'networking-1', name: 'Networking I'),
  Subject(id: 'database-2', name: 'Database II'),
  Subject(id: 'computer-programming', name: 'Computer Programming'),
  Subject(id: 'intro-computing', name: 'Introduction to Computing'),
  Subject(id: 'hci', name: 'HCI'),
  Subject(id: 'data-structures', name: 'Data Structures and Algorithms'),
];
