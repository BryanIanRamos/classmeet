import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import 'fakes/fake_config.dart';
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

// Home, profile and onboarding (fakes: task 3.7).
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => _pending('AuthRepository', '3.7'),
);
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => _pending('ProfileRepository', '3.7'),
);
final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => _pending('CatalogRepository', '3.7'),
);
final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => _pending('WalletRepository', '3.7'),
);
final questRepositoryProvider = Provider<QuestRepository>(
  (ref) => _pending('QuestRepository', '3.7'),
);
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => _pending('NotificationRepository', '3.7'),
);
final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => _pending('SearchRepository', '3.7'),
);
final classRepositoryProvider = Provider<ClassRepository>(
  (ref) => _pending('ClassRepository', '3.7'),
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

/// Placeholder body until a repository's fake exists. Also refuses
/// `DATA_SOURCE=remote`: there is no backend yet (D-18).
Never _pending(String repository, String task) {
  if (Env.dataSource != 'fake') {
    throw UnsupportedError(
      'DATA_SOURCE=${Env.dataSource}: no backend yet (D-18, Phase 11)',
    );
  }
  throw UnimplementedError('The fake $repository arrives in task $task');
}
