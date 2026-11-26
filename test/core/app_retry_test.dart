import 'package:classmeet/core/app_retry.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const failure = RepositoryException('offline');

  test('retries a failure twice, quickly, then gives up', () {
    expect(appRetry(0, failure), const Duration(milliseconds: 200));
    expect(appRetry(1, failure), const Duration(milliseconds: 400));
    expect(appRetry(2, failure), isNull);
    expect(appRetry(9, failure), isNull);
  });

  test('never retries a programming error', () {
    expect(appRetry(0, StateError('bug')), isNull);
    expect(appRetry(0, ArgumentError('bug')), isNull);
  });

  test('the error state shows within a second, not ~38 s', () {
    var total = Duration.zero;
    for (var i = 0; ; i++) {
      final delay = appRetry(i, failure);
      if (delay == null) break;
      total += delay;
    }
    expect(total, lessThan(const Duration(seconds: 1)));
  });
}
