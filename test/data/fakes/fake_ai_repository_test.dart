import 'package:classmeet/data/fakes/fake_ai_repository.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/models/reader.dart';
import 'package:classmeet/data/models/streak.dart';
import 'package:classmeet/data/models/wallet.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:classmeet/data/repositories/wallet_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

const _sentence = 'A computer follows the input–process–output cycle.';

/// Test double: tracks the balance and records every spend.
final class _Wallet implements WalletRepository {
  _Wallet(this.talons);

  int talons;
  final spent = <(int, String)>[];

  @override
  Future<Wallet> spendTalons(int amount, {required String reason}) async {
    if (amount > talons) throw const RepositoryException('Not enough talons');
    talons -= amount;
    spent.add((amount, reason));
    return Wallet(talons: talons);
  }

  @override
  Future<Wallet> earn({int talons = 0, int studyPoints = 0, int xp = 0}) =>
      throw UnimplementedError();

  @override
  Future<Wallet> fetchWallet() async => Wallet(talons: talons);

  @override
  Future<RewardProgress> fetchRewardProgress() => throw UnimplementedError();

  @override
  Future<Streak> fetchStreak() => throw UnimplementedError();
}

void main() {
  late _Wallet wallet;
  late FakeAiRepository repo;
  setUp(() {
    wallet = _Wallet(24);
    repo = FakeAiRepository(FakeConfig.instant, wallet: wallet);
  });

  test('explain returns the frame 91 answer and spends one talon', () async {
    final e = await repo.explain(materialId: 'week-1', text: _sentence);
    expect(
      e.text,
      startsWith('A computer is an electronic machine that receives input, '),
    );
    expect(e.sourceLabel, 'Based on your Week 1: Computer Basics Reviewer');
    expect(e.talonCost, 1);
    expect(e.language, ExplainLanguage.english);
    expect(wallet.talons, 23);
    expect(wallet.spent, hasLength(1));
    expect(wallet.spent.single.$1, 1);
  });

  test('every action and language has an answer, each costing 1', () async {
    for (final action in [
      ExplainAction.explain,
      ExplainAction.example,
      ExplainAction.quizMe,
    ]) {
      for (final language in ExplainLanguage.values) {
        for (final text in [_sentence, 'Zebra crossing']) {
          final e = await repo.explain(
            materialId: 'week-1',
            text: text,
            action: action,
            language: language,
          );
          expect(e.text, isNotEmpty);
          expect(e.language, language);
        }
      }
    }
    expect(wallet.talons, 24 - 3 * 3 * 2);
  });

  test('actions differ and unknown text gets a generic answer', () async {
    Future<String> ask(ExplainAction a, String t) async =>
        (await repo.explain(materialId: 'week-1', text: t, action: a)).text;
    final explain = await ask(ExplainAction.explain, _sentence);
    final example = await ask(ExplainAction.example, _sentence);
    final quiz = await ask(ExplainAction.quizMe, _sentence);
    expect({explain, example, quiz}, hasLength(3));
    expect(example, contains('keyboard'));
    expect(quiz, contains('Process'));
    expect(await ask(ExplainAction.explain, 'Zebra crossing'), isNot(explain));
  });

  test('a low balance makes explain throw and spends nothing', () async {
    final poor = _Wallet(0);
    final r = FakeAiRepository(FakeConfig.instant, wallet: poor);
    await expectLater(
      r.explain(materialId: 'week-1', text: _sentence),
      throwsA(isA<RepositoryException>()),
    );
    expect(poor.spent, isEmpty);
  });

  test('highlight is not an AI action and costs nothing', () async {
    await expectLater(
      repo.explain(
        materialId: 'week-1',
        text: _sentence,
        action: ExplainAction.highlight,
      ),
      throwsA(isA<RepositoryException>()),
    );
    expect(wallet.talons, 24);
  });

  test('unknown material throws without spending', () async {
    await expectLater(
      repo.explain(materialId: 'nope', text: _sentence),
      throwsA(isA<RepositoryException>()),
    );
    expect(wallet.talons, 24);
  });

  test('the empty scenario still answers', () async {
    final r = FakeAiRepository(_empty, wallet: wallet);
    final e = await r.explain(materialId: 'week-1', text: _sentence);
    expect(e.text, isNotEmpty);
  });

  test('the error scenario throws and spends nothing', () async {
    final r = FakeAiRepository(_error, wallet: wallet);
    await expectLater(
      r.explain(materialId: 'week-1', text: _sentence),
      throwsA(isA<RepositoryException>()),
    );
    expect(wallet.talons, 24);
  });
}
