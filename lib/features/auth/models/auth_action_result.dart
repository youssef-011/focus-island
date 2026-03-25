enum AuthActionStatus {
  success,
  failure,
  requiresConfiguration,
}

class AuthActionResult {
  final AuthActionStatus status;
  final String message;

  const AuthActionResult._({
    required this.status,
    required this.message,
  });

  const AuthActionResult.success(String message)
      : this._(status: AuthActionStatus.success, message: message);

  const AuthActionResult.failure(String message)
      : this._(status: AuthActionStatus.failure, message: message);

  const AuthActionResult.requiresConfiguration(String message)
      : this._(
          status: AuthActionStatus.requiresConfiguration,
          message: message,
        );

  bool get isSuccess => status == AuthActionStatus.success;
  bool get needsConfiguration =>
      status == AuthActionStatus.requiresConfiguration;
}
