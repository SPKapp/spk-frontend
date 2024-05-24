class RepositoryException {
  const RepositoryException({
    this.code = 'unknown',
  });

  final String code;

  @override
  String toString() {
    return 'RepositoryException: $code';
  }
}
