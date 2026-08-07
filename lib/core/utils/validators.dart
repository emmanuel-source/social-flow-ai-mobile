abstract final class Validators {
  static String? required(String? value, {String label = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) return '$label est obligatoire.';
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, label: "L'adresse e-mail");
    if (requiredError != null) return requiredError;
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim());
    return valid ? null : 'Adresse e-mail invalide.';
  }
}
