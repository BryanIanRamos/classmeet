/// How a provider retries a failed load (`ProviderScope(retry: appRetry)`).
///
/// Riverpod's default retries up to 10 times, up to 6.4 s apart: about 38 s
/// in all, during which a failing screen keeps its loader before it can show
/// its error state. Every ClassMeet screen has its own "Try again", so this
/// retries twice, quickly (200 ms, then 400 ms), for a passing glitch, and
/// never retries an [Error]: a bug does not go away on its own.
Duration? appRetry(int retryCount, Object error) {
  if (error is Error || retryCount >= maxRetries) return null;
  return Duration(milliseconds: firstRetryDelayMs << retryCount);
}

/// Retries after the first failure.
const maxRetries = 2;

/// Delay before the first retry; each next one doubles it.
const firstRetryDelayMs = 200;
