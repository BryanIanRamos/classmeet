import '../../models/reader.dart';

const _week1Highlighted = 'A computer follows the input–process–output cycle.';

const _w1 = 'week-1';

/// Frame 87: week-1 has two sections; other reviewers one short section each.
/// Design sentences are verbatim; the truncated ones (…) are completed.
const sampleSections = <String, List<ReaderSection>>{
  _w1: [
    ReaderSection(
      id: 'week-1-1-1',
      materialId: _w1,
      number: '1.1',
      title: 'What is a computer?',
      paragraphs: [
        'A computer is an electronic device that accepts data as input, '
            'processes that data using instructions, and produces useful '
            'output.',
        _week1Highlighted,
        'For example, typing on a keyboard provides input. The computer '
            'processes it and displays the result on the screen as output.',
      ],
    ),
    ReaderSection(
      id: 'week-1-1-2',
      materialId: _w1,
      number: '1.2',
      title: 'Parts of a computer',
      paragraphs: [
        'The core components of a modern desktop computer work seamlessly '
            'together, with the CPU processing instructions, memory holding '
            'data temporarily, and storage keeping files for the long term.',
        'Input devices such as the keyboard and mouse send data in, while '
            'output devices such as the monitor and speakers present the '
            'results.',
        'The motherboard connects all of these parts, and the power supply '
            'delivers electricity to them.',
      ],
    ),
  ],
  'week-2': [
    ReaderSection(
      id: 'week-2-2-1',
      materialId: 'week-2',
      number: '2.1',
      title: 'Binary, decimal and hexadecimal',
      paragraphs: [
        'Computers store everything as binary numbers, using only the '
            'digits 0 and 1.',
        'Decimal uses ten digits (0 to 9), while hexadecimal uses sixteen '
            'symbols (0 to 9 and A to F) and is a shorter way to write '
            'binary.',
      ],
    ),
  ],
  'week-3': [
    ReaderSection(
      id: 'week-3-3-1',
      materialId: 'week-3',
      number: '3.1',
      title: 'Computer hardware',
      paragraphs: [
        'Hardware is the physical part of a computer that you can touch, '
            'such as the CPU, memory, storage drives and peripherals.',
        'RAM is fast and temporary, while a hard drive or SSD keeps your '
            'files even when the power is off.',
      ],
    ),
  ],
  'week-4': [
    ReaderSection(
      id: 'week-4-4-1',
      materialId: 'week-4',
      number: '4.1',
      title: 'Computer software',
      paragraphs: [
        'Software is the set of programs and instructions that tell the '
            'hardware what to do.',
        'System software, such as an operating system, manages the '
            'computer, while application software helps users do tasks '
            'like writing or browsing.',
      ],
    ),
  ],
  'data-structure-reviewer': [
    ReaderSection(
      id: 'data-structure-reviewer-1',
      materialId: 'data-structure-reviewer',
      number: '1.1',
      title: 'Arrays and linked lists',
      paragraphs: [
        'An array stores items in consecutive memory, so any item can be '
            'reached by its index.',
        'A linked list stores each item with a link to the next one, which '
            'makes inserting and removing items easy.',
      ],
    ),
  ],
  'data-structures-reviewer': [
    ReaderSection(
      id: 'data-structures-reviewer-1',
      materialId: 'data-structures-reviewer',
      number: '1.1',
      title: 'Stacks and queues',
      paragraphs: [
        'A stack is last in, first out: the newest item is removed first.',
        'A queue is first in, first out: the oldest item is removed first.',
      ],
    ),
  ],
};

/// Name used in the AI "Based on your … Reviewer" label.
const sampleMaterialLabels = <String, String>{
  _w1: 'Week 1: Computer Basics',
  'week-2': 'Week 2: Number Systems',
  'week-3': 'Week 3: Hardware',
  'week-4': 'Week 4: Software',
  'data-structure-reviewer': 'Data Structure',
  'data-structures-reviewer': 'Data Structures',
};

/// The text a [Highlight]'s `start`/`end` index into: the section's
/// paragraphs joined by a blank line.
String sectionText(ReaderSection section) => section.paragraphs.join('\n\n');

/// The existing highlight on frame 87.
final sampleHighlights = <Highlight>[
  Highlight(
    id: 'highlight-1',
    materialId: _w1,
    sectionId: 'week-1-1-1',
    start: sectionText(sampleSections[_w1]![0]).indexOf(_week1Highlighted),
    end:
        sectionText(sampleSections[_w1]![0]).indexOf(_week1Highlighted) +
        _week1Highlighted.length,
    text: _week1Highlighted,
  ),
];

/// Frame 88: Computer → Input, Process, Output, Storage.
const sampleMindMap = MindMap(
  materialId: _w1,
  root: MindMapNode(
    id: 'computer',
    label: 'Computer',
    children: [
      MindMapNode(id: 'input', label: 'Input'),
      MindMapNode(id: 'process', label: 'Process'),
      MindMapNode(id: 'output', label: 'Output'),
      MindMapNode(id: 'storage', label: 'Storage'),
    ],
  ),
  caption:
      'Input → Process → Output. This diagram summarizes the core concepts '
      'from your reviewer.',
);

/// Frame 89: the week-1 reviewer is 06:24 long.
const week1AudioLength = Duration(minutes: 6, seconds: 24);

/// Splits the sections into sentences timed in proportion to their length;
/// the last one ends at [total].
Transcript buildTranscript(
  String materialId,
  List<ReaderSection> sections, {
  Duration? total,
}) {
  final sentences = <String>[
    for (final section in sections)
      for (final paragraph in section.paragraphs)
        ...paragraph.split(RegExp(r'(?<=[.!?])\s+')),
  ];
  final length = total ?? Duration(seconds: sentences.length * 12);
  final chars = sentences.fold<int>(0, (sum, s) => sum + s.length);
  var cursor = Duration.zero;
  var used = 0;
  final timed = <TranscriptSentence>[];
  for (var i = 0; i < sentences.length; i++) {
    used += sentences[i].length;
    final end = i == sentences.length - 1
        ? length
        : Duration(milliseconds: length.inMilliseconds * used ~/ chars);
    timed.add(TranscriptSentence(text: sentences[i], start: cursor, end: end));
    cursor = end;
  }
  return Transcript(materialId: materialId, total: length, sentences: timed);
}
