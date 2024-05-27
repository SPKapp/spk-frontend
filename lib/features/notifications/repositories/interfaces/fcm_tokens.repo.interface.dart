abstract class IFcmTokensRepository {
  /// Updates [token] of the current user, or creates a new one if it doesn't exist.
  Future<void> update(String token);

  /// Deletes [token] of the current user.
  Future<void> delete(String token);
}
