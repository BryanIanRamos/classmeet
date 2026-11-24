import '../../models/login_reward.dart';
import '../../models/quest.dart';
import '../../models/quiz.dart';
import '../../models/survey.dart';

const dailyQuizQuestId = 'daily-gk-quiz';
const streakQuestId = 'streak-milestone-1';
const surveyQuestId = 'weekly-survey';
const weeklySurveyId = 'weekly-survey';

/// The midnight that ends the day of [now].
DateTime nextMidnight(DateTime now) =>
    DateTime(now.year, now.month, now.day + 1);

/// The end of the coming Sunday (today when it is Sunday).
DateTime endOfSunday(DateTime now) => DateTime(
  now.year,
  now.month,
  now.day + (DateTime.sunday - now.weekday) % 7,
  23,
  59,
  59,
);

/// Frame 14. Rewards follow INC-5: +5 for the quiz and the survey.
List<Quest> questSamples(DateTime now) => [
  Quest(
    id: dailyQuizQuestId,
    title: 'Daily General Knowledge Quiz',
    kind: QuestKind.daily,
    rewardTalons: 5,
    done: 6,
    total: 7,
    status: QuestStatus.claimed,
    resetsAt: nextMidnight(now),
  ),
  const Quest(
    id: streakQuestId,
    title: 'Study Streak Milestone I',
    kind: QuestKind.milestone,
    rewardTalons: 10, // sample
    done: 3,
    total: 7,
    status: QuestStatus.locked,
  ),
  Quest(
    id: surveyQuestId,
    title: 'Weekly Survey',
    kind: QuestKind.survey,
    rewardTalons: 5,
    total: 1,
    availableUntil: endOfSunday(now),
    durationMinutes: 1,
  ),
];

/// Frame 15: 5 questions; the 2nd is the design's. The other four are
/// // sample Philippine general-knowledge questions. Options carry no letter
/// prefix; the screen adds "A.", "B.", and so on.
const dailyQuizQuestions = [
  Question(
    id: 'gk-1',
    prompt: 'On what date does the Philippines celebrate Independence Day?',
    category: 'History',
    options: ['June 12', 'July 4', 'August 21', 'November 30'],
    correctIndex: 0,
    explanation: 'Independence from Spain was declared on June 12, 1898.',
  ),
  Question(
    id: 'gk-2',
    prompt:
        'Which Philippine law protects the personal data of students and '
        'other citizens?',
    category: 'Science & Society',
    options: [
      'RA 10173 · Data Privacy Act of 2012',
      'RA 10175 · Cybercrime Prevention Act',
      'RA 10931 · Free Higher Education Act',
      'RA 8293 · Intellectual Property Code',
    ],
    correctIndex: 0,
    explanation:
        'The Data Privacy Act of 2012 (RA 10173) protects personal '
        'information.',
  ),
  Question(
    id: 'gk-3',
    prompt: 'What is the longest river in the Philippines?',
    category: 'Geography',
    options: ['Pasig River', 'Cagayan River', 'Agusan River', 'Pampanga River'],
    correctIndex: 1,
    explanation: 'The Cagayan River in Luzon is about 505 km long.',
  ),
  Question(
    id: 'gk-4',
    prompt: 'What is the highest mountain in the Philippines?',
    category: 'Geography',
    options: ['Mount Pulag', 'Mount Mayon', 'Mount Apo', 'Mount Kanlaon'],
    correctIndex: 2,
    explanation: 'Mount Apo in Mindanao rises about 2,954 m above sea level.',
  ),
  Question(
    id: 'gk-5',
    prompt: 'What is the national language of the Philippines?',
    category: 'Culture',
    options: ['Cebuano', 'Ilocano', 'Spanish', 'Filipino'],
    correctIndex: 3,
    explanation: 'The 1987 Constitution names Filipino the national language.',
  ),
];

/// Frame 16. Which question uses chips or radios is // sample.
const weeklySurvey = Survey(
  id: weeklySurveyId,
  title: "How's your study week going?",
  rewardTalons: 5,
  questions: [
    SurveyQuestion(
      id: 'when',
      prompt: 'When do you usually study?',
      style: SurveyQuestionStyle.chips,
      options: ['Early morning', 'After class', 'Late night'],
    ),
    SurveyQuestion(
      id: 'challenge',
      prompt: "What's your biggest study challenge?",
      style: SurveyQuestionStyle.radios,
      options: [
        'Too many topics to cover',
        'Some concepts are hard to understand',
        'Not enough time because of deadlines',
      ],
    ),
    SurveyQuestion(
      id: 'hours',
      prompt: 'How much time did you spend studying this week?',
      style: SurveyQuestionStyle.chips,
      options: [
        'Under 2 hours',
        '2–5 hours',
        '6–10 hours',
        'More than 10 hours',
      ],
    ),
  ],
);

/// Frame 122: day 3 of 7, days 1 to 3 claimed, a gift on day 7. Talon
/// amounts per day are // sample.
const loginRewardWeek = LoginRewardWeek(
  currentDay: 3,
  days: [
    LoginRewardDay(day: 1, isClaimed: true, rewardTalons: 1),
    LoginRewardDay(day: 2, isClaimed: true, rewardTalons: 1),
    LoginRewardDay(day: 3, isClaimed: true, rewardTalons: 2),
    LoginRewardDay(day: 4, rewardTalons: 2),
    LoginRewardDay(day: 5, rewardTalons: 3),
    LoginRewardDay(day: 6, rewardTalons: 3),
    LoginRewardDay(day: 7, rewardTalons: 5, isGift: true),
  ],
);
