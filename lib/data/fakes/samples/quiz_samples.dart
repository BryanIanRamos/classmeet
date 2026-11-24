import '../../models/create.dart';
import '../../models/quiz.dart';

/// Id of the design's one quiz (122, 123). The route samples use it too.
const sampleQuizId = 'intro-computing';

/// Id of the design's question (124-128): "Which part of the computer ...".
const sampleQuestionId = '$sampleQuizId-q1';

/// 122 "My quizzes" and the Play hub's continue banner (INC-5: the banner
/// shows this quiz, not the design's "Intro to C Programming").
const sampleIntroComputingQuiz = Quiz(
  id: sampleQuizId,
  title: 'Intro to Computing Quiz',
  classCode: 'ITE13',
  questionCount: 20,
  difficulty: Difficulty.mixed,
  // 123 shows these two chips. No Identification question exists yet
  // (GAP-16), so the questions below are multiple choice or true/false only.
  types: {QuestionType.multipleChoice, QuestionType.identification},
  bestPercent: 85,
);

const List<Quiz> sampleQuizzes = [sampleIntroComputingQuiz];

const _tf = ['True', 'False'];

Question _mc(
  int n,
  String prompt,
  List<String> options,
  int correct,
  String explanation,
) => Question(
  id: '$sampleQuizId-q$n',
  prompt: prompt,
  options: options,
  correctIndex: correct,
  explanation: explanation,
);

Question _tfq(int n, String prompt, bool answer, String explanation) =>
    Question(
      id: '$sampleQuizId-q$n',
      prompt: prompt,
      type: QuestionType.trueOrFalse,
      options: _tf,
      correctIndex: answer ? 0 : 1,
      explanation: explanation,
    );

/// The 20 questions of [sampleIntroComputingQuiz]. Question 1 is the design's
/// (124-126); the other 19 are written for the fake and are plain
/// introduction-to-computing facts. Questions 1 to 12 double as the "Week 1:
/// Computer Basics" pool for generated quizzes.
final List<Question> sampleIntroComputingQuestions = [
  const Question(
    id: sampleQuestionId,
    prompt:
        'Which part of the computer carries out instructions from programs?',
    options: ['Monitor', 'Central Processing Unit', 'Hard drive', 'Keyboard'],
    correctIndex: 1,
    explanation:
        'The CPU executes program instructions and performs calculations and '
        'control operations.',
    sourceLabel: 'Based on your Week 1: Computer Basics Reviewer',
  ),
  _mc(
    2,
    'Which of these is an input device?',
    ['Monitor', 'Printer', 'Keyboard', 'Speaker'],
    2,
    'A keyboard sends data into the computer; the others send information out.',
  ),
  _mc(
    3,
    'What does RAM stand for?',
    [
      'Random Access Memory',
      'Read Always Memory',
      'Rapid Application Module',
      'Remote Access Machine',
    ],
    0,
    'RAM is Random Access Memory, the computer’s short-term working memory.',
  ),
  _tfq(
    4,
    'RAM keeps its contents when the computer is turned off.',
    false,
    'RAM is volatile, so its contents are lost when the power is off.',
  ),
  _mc(
    5,
    'Which of these is system software?',
    ['Word processor', 'Operating system', 'Web browser', 'Spreadsheet'],
    1,
    'An operating system manages the computer and runs other programs.',
  ),
  _mc(
    6,
    'How many bits are in one byte?',
    ['4', '8', '16', '32'],
    1,
    'One byte is made of 8 bits.',
  ),
  _tfq(
    7,
    'Binary numbers use only the digits 0 and 1.',
    true,
    'Binary is a base-2 system, so each digit is either 0 or 1.',
  ),
  _mc(
    8,
    'Which of these is an output device?',
    ['Mouse', 'Scanner', 'Printer', 'Microphone'],
    2,
    'A printer produces output on paper; the others bring data in.',
  ),
  _mc(
    9,
    'Which component is used for long-term storage of files?',
    ['RAM', 'Hard drive', 'CPU', 'Monitor'],
    1,
    'A hard drive keeps files even when the computer is switched off.',
  ),
  _mc(
    10,
    'What does URL stand for?',
    [
      'Uniform Resource Locator',
      'Universal Reading Link',
      'United Resource List',
      'Uniform Retrieval Language',
    ],
    0,
    'A URL is a Uniform Resource Locator, the address of a web page.',
  ),
  _tfq(
    11,
    'The Internet and the World Wide Web are exactly the same thing.',
    false,
    'The Web is a service that runs on top of the Internet, which is the '
        'global network itself.',
  ),
  _mc(
    12,
    'Which of these is a web browser?',
    ['Google Chrome', 'Windows', 'Microsoft Excel', 'Linux'],
    0,
    'Google Chrome is a browser; Windows and Linux are operating systems.',
  ),
  _mc(
    13,
    'Which unit of storage is the largest?',
    ['Byte', 'Kilobyte', 'Megabyte', 'Gigabyte'],
    3,
    'A gigabyte is about a thousand megabytes.',
  ),
  _tfq(
    14,
    'Software means the physical parts of a computer.',
    false,
    'The physical parts are hardware; software is the programs that run on it.',
  ),
  _mc(
    15,
    'What is the main circuit board of a computer called?',
    ['Motherboard', 'Power supply', 'Keyboard', 'Heat sink'],
    0,
    'The motherboard connects the CPU, memory and other components.',
  ),
  _mc(
    16,
    'What does an operating system do?',
    [
      'Manages the computer’s hardware and software resources',
      'Only stores photos',
      'Only protects against viruses',
      'Only displays web pages',
    ],
    0,
    'It coordinates hardware, runs programs and gives users an interface.',
  ),
  _tfq(
    17,
    'A file named photo.jpg is most likely an image.',
    true,
    'The .jpg extension marks a JPEG image file.',
  ),
  _mc(
    18,
    'What is the binary number 101 in decimal?',
    ['3', '4', '5', '6'],
    2,
    '101 in binary is 1×4 + 0×2 + 1×1 = 5.',
  ),
  _mc(
    19,
    'Which of these is an application program?',
    ['Microsoft Excel', 'Operating system', 'Device driver', 'Firmware'],
    0,
    'Excel is an application that helps users do a task; the others are '
        'system-level software.',
  ),
  _mc(
    20,
    'Which unit is used to measure CPU clock speed?',
    ['Gigahertz', 'Megapixel', 'Decibel', 'Lumen'],
    0,
    'Clock speed is measured in hertz, commonly gigahertz (GHz).',
  ),
];
