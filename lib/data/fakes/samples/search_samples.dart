import '../../models/profile.dart';
import '../../models/search_result.dart';

/// Frame 12.
const sampleRecentSearches = [
  'Data Structures midterm',
  'Normalization',
  'Networking 112',
];

const sampleClassResults = [
  SearchResult(
    id: 'ite13',
    category: SearchCategory.classes,
    title: 'ITE13 - Introduction to Computing',
    subtitle: 'Prof. Rhea Santos',
  ),
];

const sampleMaterialResults = [
  SearchResult(
    id: 'data-structures-algorithms',
    category: SearchCategory.materials,
    title: 'Data Structures and Algorithms',
    subtitle: 'Created by Ara Matias',
  ),
  SearchResult(
    id: 'visual-computing-fundamentals',
    category: SearchCategory.materials,
    title: 'Visual Computing Fundamentals',
    subtitle: 'Created by Joshua Bete',
  ),
];

const samplePeopleResults = [
  PersonSummary(
    id: 'person-arabela',
    name: 'Arabela Matias',
    programLabel: 'BSIT - II',
    schoolName: 'Caraga State University',
  ),
  PersonSummary(
    id: 'person-bryan',
    name: 'Bryan Ramos',
    programLabel: 'BSIT - IV',
  ),
  PersonSummary(
    id: 'person-joshua',
    name: 'Joshua Bete',
    programLabel: 'BSIT - I',
    schoolName: 'Father Saturnino Urios University',
  ),
];
