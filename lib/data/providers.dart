import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import 'fakes/fake_ai_repository.dart';
import 'fakes/fake_attempt_repository.dart';
import 'fakes/fake_auth_repository.dart';
import 'fakes/fake_catalog_repository.dart';
import 'fakes/fake_class_repository.dart';
import 'fakes/fake_comment_repository.dart';
import 'fakes/fake_config.dart';
import 'fakes/fake_create_repository.dart';
import 'fakes/fake_download_repository.dart';
import 'fakes/fake_leaderboard_repository.dart';
import 'fakes/fake_material_repository.dart';
import 'fakes/fake_mistake_repository.dart';
import 'fakes/fake_notification_repository.dart';
import 'fakes/fake_profile_repository.dart';
import 'fakes/fake_quest_repository.dart';
import 'fakes/fake_quiz_repository.dart';
import 'fakes/fake_reader_repository.dart';
import 'fakes/fake_search_repository.dart';
import 'fakes/fake_study_plan_repository.dart';
import 'fakes/fake_wallet_repository.dart';
import 'repositories/ai_repository.dart';
import 'repositories/attempt_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/catalog_repository.dart';
import 'repositories/class_repository.dart';
import 'repositories/comment_repository.dart';
import 'repositories/create_repository.dart';
import 'repositories/download_repository.dart';
import 'repositories/leaderboard_repository.dart';
import 'repositories/material_repository.dart';
import 'repositories/mistake_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/quest_repository.dart';
import 'repositories/quiz_repository.dart';
import 'repositories/reader_repository.dart';
import 'repositories/search_repository.dart';
import 'repositories/study_plan_repository.dart';
import 'repositories/wallet_repository.dart';

/// The one place where screens meet data (D-02, D-18).
///
/// Features read repositories only through these providers and never import
/// `lib/data/fakes/`. Today every provider builds a fake with sample data, so
/// the app runs and tests without any server. A backend later swaps the
/// bodies here for remote implementations (Phase 11); screens stay as they
/// are. Tests override [fakeConfigProvider] (e.g. `FakeConfig.instant`, or
/// the empty and error scenarios) or a single repository provider.
final fakeConfigProvider = Provider<FakeConfig>((ref) => FakeConfig.fromEnv());

// Home, profile and onboarding.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FakeAuthRepository(_fakeConfig(ref)),
);
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => FakeProfileRepository(_fakeConfig(ref)),
);
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => FakeCatalogRepository(_fakeConfig(ref)),
);
final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => FakeWalletRepository(_fakeConfig(ref)),
);
final questRepositoryProvider = Provider<QuestRepository>(
  (ref) => FakeQuestRepository(_fakeConfig(ref)),
);
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => FakeNotificationRepository(_fakeConfig(ref)),
);
final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => FakeSearchRepository(_fakeConfig(ref)),
);
final classRepositoryProvider = Provider<ClassRepository>(
  (ref) => FakeClassRepository(_fakeConfig(ref)),
);
final studyPlanRepositoryProvider = Provider<StudyPlanRepository>(
  (ref) => FakeStudyPlanRepository(_fakeConfig(ref)),
);

// Study. The AI fake spends talons from the shared wallet.
final materialRepositoryProvider = Provider<MaterialRepository>(
  (ref) => FakeMaterialRepository(_fakeConfig(ref)),
);
final readerRepositoryProvider = Provider<ReaderRepository>(
  (ref) => FakeReaderRepository(_fakeConfig(ref)),
);
final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => FakeAiRepository(
    _fakeConfig(ref),
    wallet: ref.watch(walletRepositoryProvider),
  ),
);
final downloadRepositoryProvider = Provider<DownloadRepository>(
  (ref) => FakeDownloadRepository(_fakeConfig(ref)),
);

// Play and create. Attempts and quiz generation write into the shared quiz
// and mistake fakes (and the wallet), so the Play screens see the results.
final _fakeQuizzes = Provider<FakeQuizRepository>(
  (ref) => FakeQuizRepository(_fakeConfig(ref)),
);
final _fakeMistakes = Provider<FakeMistakeRepository>(
  (ref) => FakeMistakeRepository(_fakeConfig(ref)),
);
final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => ref.watch(_fakeQuizzes),
);
final attemptRepositoryProvider = Provider<AttemptRepository>(
  (ref) => FakeAttemptRepository(
    _fakeConfig(ref),
    quizzes: ref.watch(_fakeQuizzes),
    mistakes: ref.watch(_fakeMistakes),
    wallet: ref.watch(walletRepositoryProvider),
  ),
);
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => FakeCommentRepository(_fakeConfig(ref)),
);
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => FakeLeaderboardRepository(_fakeConfig(ref)),
);
final mistakeRepositoryProvider = Provider<MistakeRepository>(
  (ref) => ref.watch(_fakeMistakes),
);
final createRepositoryProvider = Provider<CreateRepository>(
  (ref) => FakeCreateRepository(
    _fakeConfig(ref),
    quizzes: ref.watch(_fakeQuizzes),
    wallet: ref.watch(walletRepositoryProvider),
  ),
);

/// The fake config for a fake repository. Refuses `DATA_SOURCE=remote`:
/// there is no backend yet (D-18).
FakeConfig _fakeConfig(Ref ref) {
  _requireFakeSource();
  return ref.watch(fakeConfigProvider);
}

void _requireFakeSource() {
  if (Env.dataSource != 'fake') {
    throw UnsupportedError(
      'DATA_SOURCE=${Env.dataSource}: no backend yet (D-18, Phase 11)',
    );
  }
}
