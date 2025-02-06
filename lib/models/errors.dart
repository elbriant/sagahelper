class NoCacheException implements Exception {
  final String cause;
  final Object? error;

  NoCacheException({
    this.error,
    this.cause = 'No cache',
  });
}
