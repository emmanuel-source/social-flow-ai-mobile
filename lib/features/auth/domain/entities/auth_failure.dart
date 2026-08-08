enum AuthFailureType { invalidCredentials, emailAlreadyUsed, generic }

class AuthFailure implements Exception {
  const AuthFailure._(this.type, this.message);

  const AuthFailure.invalidCredentials()
    : this._(
        AuthFailureType.invalidCredentials,
        'E-mail ou mot de passe incorrect.',
      );

  const AuthFailure.generic()
    : this._(
        AuthFailureType.generic,
        'Une erreur est survenue. Veuillez réessayer.',
      );

  const AuthFailure.emailAlreadyUsed()
    : this._(
        AuthFailureType.emailAlreadyUsed,
        'Un compte existe déjà avec cette adresse e-mail.',
      );

  final AuthFailureType type;
  final String message;
}
