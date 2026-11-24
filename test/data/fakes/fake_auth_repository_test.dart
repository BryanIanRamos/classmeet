import 'package:classmeet/data/fakes/fake_auth_repository.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);

void main() {
  late FakeAuthRepository repo;
  setUp(() => repo = FakeAuthRepository(FakeConfig.instant));

  test('starts signed out', () async {
    expect(await repo.currentUser(), isNull);
  });

  test('logIn signs in with the sample student and persists', () async {
    final user = await repo.logIn(email: 'a@example.com', password: 'pw');
    expect(user.username, 'Bryan');
    expect(user.nickname, 'Owl_4821');
    expect(user.email, 'a@example.com');
    expect((await repo.currentUser())?.id, user.id);
  });

  test('logIn with an empty password fails', () async {
    await expectLater(
      repo.logIn(email: 'a@example.com', password: ''),
      throwsA(isA<RepositoryException>()),
    );
    expect(await repo.currentUser(), isNull);
  });

  test('signUp creates the user and persists', () async {
    final user = await repo.signUp(
      username: 'ana_cruz',
      email: 'ana@example.com',
      password: 'pw',
    );
    expect(user.username, 'ana_cruz');
    expect((await repo.currentUser())?.email, 'ana@example.com');
  });

  test('signUp with missing fields fails', () {
    expect(
      repo.signUp(username: '', email: 'a@example.com', password: 'pw'),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('logOut clears the session', () async {
    await repo.logIn(email: 'a@example.com', password: 'pw');
    await repo.logOut();
    expect(await repo.currentUser(), isNull);
  });

  test('requestPasswordReset needs an email', () async {
    await repo.requestPasswordReset('a@example.com');
    expect(repo.requestPasswordReset(' '), throwsA(isA<RepositoryException>()));
  });

  test('empty scenario still logs in', () async {
    final r = FakeAuthRepository(_empty);
    expect(await r.currentUser(), isNull);
    await r.logIn(email: 'a@example.com', password: 'pw');
    expect(await r.currentUser(), isNotNull);
  });

  test('error scenario throws everywhere', () {
    final r = FakeAuthRepository(_error);
    expect(r.currentUser(), throwsA(isA<RepositoryException>()));
    expect(
      r.logIn(email: 'a@example.com', password: 'pw'),
      throwsA(isA<RepositoryException>()),
    );
    expect(
      r.signUp(username: 'A', email: 'a@example.com', password: 'p'),
      throwsA(isA<RepositoryException>()),
    );
    expect(r.logOut(), throwsA(isA<RepositoryException>()));
    expect(
      r.requestPasswordReset('a@example.com'),
      throwsA(isA<RepositoryException>()),
    );
  });
}
