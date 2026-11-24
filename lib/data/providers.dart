import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import 'fakes/fake_auth_repository.dart';
import 'fakes/fake_catalog_repository.dart';
import 'fakes/fake_class_repository.dart';
import 'fakes/fake_config.dart';
import 'fakes/fake_notification_repository.dart';
import 'fakes/fake_profile_repository.dart';
import 'fakes/fake_quest_repository.dart';
import 'fakes/fake_search_repository.dart';
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

// Study (fakes: task 3.8).
final materialRepositoryProvider = Provider<MaterialRepository>(
  (ref) => _pending('MaterialRepository', '3.8'),
);
final readerRepositoryProvider = Provider<ReaderRepository>(
  (ref) => _pending('ReaderRepository', '3.8'),
);
final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => _pending('AiRepository', '3.8'),
);
final downloadRepositoryProvider = Provider<DownloadRepository>(
  (ref) => _pending('DownloadRepository', '3.8'),
);

// Play and create (fakes: task 3.9).
final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => _pending('QuizRepository', '3.9'),
);
final attemptRepositoryProvider = Provider<AttemptRepository>(
  (ref) => _pending('AttemptRepository', '3.9'),
);
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => _pending('CommentRepository', '3.9'),
);
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => _pending('LeaderboardRepository', '3.9'),
);
final mistakeRepositoryProvider = Provider<MistakeRepository>(
  (ref) => _pending('MistakeRepository', '3.9'),
);
final createRepositoryProvider = Provider<CreateRepository>(
  (ref) => _pending('CreateRepository', '3.9'),
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

/// Placeholder body until a repository's fake exists. Also refuses
/// `DATA_SOURCE=remote`: there is no backend yet (D-18).
Never _pending(String repository, String task) {
  _requireFakeSource();
  throw UnimplementedError('The fake $repository arrives in task $task');
}
